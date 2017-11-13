RMySQL_version <- function() {
  # Returns 93 if the installed version of RMySQL is 0.9.3
  return(as.numeric(paste0(unlist(utils::packageVersion("RMySQL")), collapse = "")))
}

# Ensure that we recognise and error on 0 rows
stop_on_empty <- function(data) {
  if (nrow(data) == 0) {
    stop("No rows were returned from the database")
  }
  return(invisible())
}

#' @title Work with MySQL databases
#' @description Read from, write to, and check data from the MySQL databases and
#'   tables in the Wikimedia cluster. Assumes the presence of a validly
#'   formatted configuration file.
#' @param query SQL query
#' @param database name of the database to query
#' @param hostname name of the machine to connect to, which depends on whether
#'   `query` is used to fetch from the **log** `database` (in which case
#'   connect to "db1047.eqiad.wmnet") or a MediaWiki ("content") DB (in which
#'   case connect to "analytics-store.eqiad.wmnet" as before)
#' @param con MySQL connection returned by [mysql_connect()]; *optional* -- if
#'   not provided, a temporary connection will be opened up
#' @param table_name name of a table to check for the existence of or create,
#'   depending on the function
#' @param default_file name of a config file containing username and password
#'   to use when connecting
#' @name mysql
#' @rdname mysql
#' @seealso [query_hive()] or [global_query()]
#' @export
mysql_connect <- function(
  database, default_file = NULL,
  hostname = ifelse(database == "log", "db1108.eqiad.wmnet", "analytics-store.eqiad.wmnet")
) {
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
  if (RMySQL_version() > 93) {
    con <- RMySQL::dbConnect(
      drv = RMySQL::MySQL(), host = hostname,
      dbname = database, default.file = default_file
    )
  } else {
    # Using version RMySQL 0.9.3 or older:
    con <- RMySQL::dbConnect(
      drv = "MySQL", host = hostname,
      dbname = database, default.file = default_file
    )
  }
  # End Exclude Linting
  return(con)
}

#' @rdname mysql
#' @export
mysql_read <- function(query, database, con = NULL) {
  already_connected <- !is.null(con)
  if (!already_connected) {
    # Open a temporary connection to the db:
    con <- mysql_connect(database)
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
mysql_exists <- function(database, table_name, con = NULL) {
  already_connected <- !is.null(con)
  if (!already_connected) {
    # Open a temporary connection to the db:
    con <- mysql_connect(database)
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
mysql_write <- function(x, database, table_name, con = NULL, ...){
  already_connected <- !is.null(con)
  if (!already_connected) {
    # Open a temporary connection to the db:
    con <- mysql_connect(database)
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
