# Ensure that we recognise and error on 0 rows
stop_on_empty <- function(data) {
  if (nrow(data) == 0) {
    stop("No rows were returned from the database")
  }
  return(invisible())
}

# Check if the host machine is a remote WMF machine
# e.g. stat100* or notebook100* as opposed to local
is_wmnet <- function() {
  suppressWarnings(domain <- system("hostname -d", intern = TRUE))
  if (length(domain) == 0) {
    return(FALSE)
  } else {
    return(grepl("\\.wmnet$", domain))
  }
}

#' @title Update shard map
#' @description Fetches the latest DB configuration from WMF's MediaWiki
#'   Configuration for mapping
#' @param dev logical flag; if true, will write to inst/extdata; updates the
#'   installed map otherwise
#' @export
update_shardmap <- function(dev = FALSE) {
  # Begin Exclude Linting
  message("reading wmf's mediawiki db config")
  url <- "https://phabricator.wikimedia.org/source/mediawiki-config/browse/master/wmf-config/db-eqiad.php?as=source&blame=off&view=raw" # nolint
  db_config <- readLines(url)
  # nolint start
  # find where the shard config starts & ends:
  sectionsByDB_start <- which(grepl("'sectionsByDB' => [", db_config, fixed = TRUE))
  sectionsByDB_end <- which(grepl("],", db_config, fixed = TRUE))
  sectionsByDB_end <- min(sectionsByDB_end[sectionsByDB_end > sectionsByDB_start])
  # extract & parse the relevant data:
  sectionsByDB <- gsub("[\t ',]", "", db_config[(sectionsByDB_start + 1):(sectionsByDB_end - 1)])
  sectionsByDB <- sectionsByDB[sectionsByDB != "" & !grepl("^#", sectionsByDB)]
  sectionsByDB <- strsplit(sectionsByDB, "=>")
  sections_by_db <- purrr::map_dfr(
    sectionsByDB[purrr::map_lgl(sectionsByDB, ~ .x[2] != "wikitech")],
    ~ tibble::tibble(dbname = .x[1], shard = sub("^s([0-9]+)$", "\\1", .x[2]))
  )
  # nolint end
  # s3 is the default shard for other wikis (as of 2019-02-13)
  if (dev) {
    file_path <- "inst/extdata/sections_by_db.csv"
  } else {
    file_path <- system.file("extdata", "sections_by_db.csv", package = "wmf")
  }
  message("saving sectionsByDB to ", file_path)
  write.csv(sections_by_db, file_path)
  # End Exclude Linting
}

#' @title Connection details
#' @description Figure out connection details (host name and port) based on
#'   database name.
#' @param dbname e.g. "enwiki"; can be a vector of multiple database names
#' @param use_x1 logical flag; use if querying an extension-related table that
#'   is hosted on x1 (e.g. `echo_*` tables); default `FALSE`
#' @return a named `list` of `list(host, port)`s
# nolint start
#' @references [wikitech:Data_access#MariaDB_replicas](https://wikitech.wikimedia.org/wiki/Analytics/Data_access#MariaDB_replicas)
# nolint end
#' @export
connection_details <- function(dbname, use_x1 = FALSE) {
  # 331 + the digit of the section in case of sX.
  #   Example: s5 will be accessible to s5-analytics-replica.eqiad.wmnet:3315
  # 3320 for x1. Example: x1-analytics-replica.eqiad.wmnet:3320
  # 3350 for staging
  shardmap <- system.file("extdata", "sections_by_db.csv", package = "wmf")
  if (file.exists(shardmap)) {
    sections_by_db <- read.csv(shardmap)
  } else {
    stop("no shard map found; use update_shardmap() to download latest shard mapping")
  }
  shards <- purrr::map(purrr::set_names(dbname, dbname), function(db) {
    if (use_x1) {
      return(list(host = "x1-analytics-replica.eqiad.wmnet", port = 3320))
    } else {
      if (db %in% sections_by_db$dbname) {
        shard <- sections_by_db$shard[sections_by_db$dbname == db]
      } else {
        shard <- 3
      }
      return(list(
        host = sprintf("s%i-analytics-replica.eqiad.wmnet", shard),
        port = as.numeric(sprintf("331%i", shard))
      ))
    }
  })
  return(shards)
}

#' @title Work with MySQL databases
#' @description Read from, write to, and check data from the MySQL databases and
#'   tables in the Wikimedia cluster. Assumes the presence of a validly
#'   formatted configuration file.
#' @param query SQL query
#' @param database name of the database to query; *optional* if passing a `con`
#' @param use_x1 logical flag; use if querying an extension-related table that
#'   is hosted on x1 (e.g. `echo_*` tables); default `FALSE`
#' @param hostname name of the machine to connect to, which depends on whether
#'   `query` is used to fetch from the **log** `database` (in which case
#'   connect to "db1108.eqiad.wmnet") or a MediaWiki ("content") DB, in which
#'   case [connection_details()] is used to return the appropriate shard host
#'   name and port based on the stored mapping (use [update_shardmap()] prior
#'   to make sure the latest mapping is used)
#' @param con MySQL connection returned by [mysql_connect()]; *optional* -- if
#'   not provided, a temporary connection will be opened up
#' @param table_name name of a table to check for the existence of or create,
#'   depending on the function
#' @param default_file name of a config file containing username and password
#'   to use when connecting
#' @examples \dontrun{
#' # Connection details (which shard to connect to) are fetched automatically:
#' mysql_read("SELECT * FROM image LIMIT 100", "commonswiki")
#' mysql_read("SELECT * FROM wbc_entity_usage LIMIT 100", "wikidatawiki")
#'
#' # Echo extension tables are on the x1 host:
#' mysql_read("SELECT *
#'   FROM echo_event
#'   LEFT JOIN echo_notification
#'     ON echo_event.event_id = echo_notification.notification_event
#'   LIMIT 10;",
#' "enwiki", use_x1 = TRUE)
#'
#' # If querying multiple databases in the same shard
#' # a shared connection may be used:
#' con <- mysql_connect("frwiki")
#' results <- purrr::map(
#'   c("frwiki", "jawiki"),
#'   mysql_read,
#'   query = "SELECT...",
#'   con = con
#' )
#' mysql_disconnect(con)
#' }
#' @name mysql
#' @rdname mysql
#' @seealso [query_hive()] or [global_query()]
#' @export
mysql_connect <- function(
  database, use_x1 = FALSE,
  default_file = NULL, hostname = NULL, port = NULL
) {
  if (is.null(hostname)) {
    if (database == "log") {
      if (use_x1) stop("using x1 does not make sense when connecting to 'log' db")
      hostname <- "db1108.eqiad.wmnet"
      if (is.null(port)) port <- 3306
    } else {
      con_deets <- connection_details(database, use_x1 = use_x1)[[database]]
      hostname <- con_deets$host
      if (is.null(port)) port <- con_deets$port
    }
  }
  # Begin Exclude Linting
  if (is.null(default_file)) {
    possible_cnfs <- c(
      "discovery-stats-client.cnf", # on stat1005
      "statistics-private-client.cnf", # on stat1005
      "analytics-research-client.cnf", # on stat1005
      "stats-research-client.cnf", # on stat1006 and also on stat1005
      "research-client.cnf" # on notebook1001
    )
    for (cnf in file.path("/etc/mysql/conf.d", possible_cnfs)) {
      if (file.exists(cnf)) {
        default_file <- cnf
        break
      }
    }
    if (is.null(default_file)) {
      if (dir.exists("/etc/mysql/conf.d")) {
        cnfs <- dir("/etc/mysql/conf.d", pattern = "*.cnf")
        if (length(cnfs) == 0) {
          stop("no credentials found in mysql conf dir")
        } else {
          stop(
            "didn't find any of the specified credentials (",
            paste0(possible_cnfs, collapse = ", "), ")"
          )
        }
      } else {
        stop("no configuration directory for mysql credentials")
      }
    }
  }
  con <- RMySQL::dbConnect(
    drv = RMySQL::MySQL(), host = hostname, port = port,
    dbname = database, default.file = default_file
  )
  # End Exclude Linting
  return(con)
}

#' @rdname mysql
#' @export
mysql_read <- function(query, database = NULL, use_x1 = NULL, con = NULL) {
  already_connected <- !is.null(con)
  if (!already_connected && !is.null(database)) {
    # Open a temporary connection to the db:
    if (is.null(use_x1)) use_x1 <- FALSE
    con <- mysql_connect(database, use_x1 = use_x1)
  }
  # Begin Exclude Linting
  to_fetch <- RMySQL::dbSendQuery(con, query)
  data <- RMySQL::fetch(to_fetch, -1)
  message(sprintf("Fetched %.0f rows and %.0f columns.", nrow(data), ncol(data)))
  RMySQL::dbClearResult(RMySQL::dbListResults(con)[[1]])
  # End Exclude Linting
  if (!already_connected) {
    # Close temporary connection:
    mysql_close(con)
  }
  stop_on_empty(data)
  return(data)
}

#' @rdname mysql
#' @export
mysql_exists <- function(database, table_name, use_x1 = NULL, con = NULL) {
  already_connected <- !is.null(con)
  if (!already_connected) {
    # Open a temporary connection to the db:
    if (is.null(use_x1)) use_x1 <- FALSE
    con <- mysql_connect(database, use_x1 = use_x1)
  }
  # Grab the results and close off:
  # Begin Exclude Linting
  table_exists <- RMySQL::dbExistsTable(conn = con, name = table_name)
  # End Exclude Linting
  if (!already_connected) {
    # Close temporary connection:
    mysql_close(con)
  }
  #Return
  return(table_exists)
}

#' @param x a `data.frame` to write
#' @param ... additional arguments to pass to `dbWriteTable`
#' @rdname mysql
#' @export
mysql_write <- function(x, database, table_name, use_x1 = NULL, con = NULL, ...) {
  already_connected <- !is.null(con)
  if (!already_connected) {
    # Open a temporary connection to the db:
    if (is.null(use_x1)) use_x1 <- FALSE
    con <- mysql_connect(database, use_x1 = use_x1)
  }
  # Write:
  # Begin Exclude Linting
  result <- RMySQL::dbWriteTable(
    conn = con,
    name = table_name,
    value = x,
    row.names = FALSE,
    ...
  )
  # End Exclude Linting
  if (!already_connected) {
    # Close temporary connection:
    mysql_close(con)
  }
  # Return the success/failure:
  return(result)
}

#' @rdname mysql
#' @export
mysql_close <- function(con) {
  # Begin Exclude Linting
  RMySQL::dbDisconnect(con)
  # End Exclude Linting
  return(invisible())
}

#' @rdname mysql
#' @export
mysql_disconnect <- function(con) {
  mysql_close(con)
}

#' @title Builds a MySQL query aimed at the EventLogging-centric formats
#' @description Constructs a MySQL query with a conditional around date.
#'   This is aimed at eventlogging, where the date/time is always "timestamp".
#' @param fields the `SELECT` statement
#' @param table the table to use
#' @param date the date to restrict to. If `NULL`, yesterday will be used
#' @param conditionals other conditions to include in the `WHERE` statement
#' @export
build_query <- function(fields, table, date = NULL, conditionals = NULL) {

  # Ensure we have a date and deconstruct it into a MW-friendly format
  if (is.null(date)) {
    date <- Sys.Date() - 1
  }
  date <- gsub(x = date, pattern = "-", replacement = "")

  # Build the query proper (this will work for EL schemas where the field is always 'timestamp')
  query <- paste0(
    fields, " FROM ", table, " WHERE LEFT(timestamp, 8) = '", date, "'",
    ifelse(is.null(conditionals), "", " AND "),
    conditionals
  )

  results <- mysql_read(query, "log")
  stop_on_empty(results)
  return(results)
}
