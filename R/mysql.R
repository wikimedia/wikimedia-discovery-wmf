RMySQL_version <- function() {
  # Returns 93 if the installed version of RMySQL is 0.9.3
  return(as.numeric(paste0(unlist(packageVersion("RMySQL")), collapse = "")))
}

# Ensure that we recognise and error on 0 rows
stop_on_empty <- function(data){
  if(nrow(data) == 0){
    stop("No rows were returned from the database")
  }
  return(invisible())
}


#'@title Work with MySQL databases
#'@description Read from, write to, and check data from the MySQL databases and
#'  tables in the Wikimedia cluster. Assumes the presence of a validly
#'  formatted configuration file.
#'
#'@param query A SQL query.
#'
#'@param database The name of the database to query.
#'
#'@param con A MySQL connection returned by \code{mysql_connect}.
#'  Optional -- if not provided, a temporary connection will be opened up.
#'
#'@param table The name of a table to check for the existence of or create,
#'  depending on the function.
#'
#'@param ... Further arguments to pass to dbWriteTable. See ?dbWriteTable for more details.
#'
#'@name mysql
#'@rdname mysql
#'@importMethodsFrom RMySQL dbConnect
#'
#'@seealso \code{\link{hive_query}} or \code{\link{global_query}}
#'
#'@export
mysql_connect <- function(database) {
  if (RMySQL_version() > 93) {
    con <- dbConnect(drv = RMySQL::MySQL(),
                             host = "analytics-store.eqiad.wmnet",
                             dbname = database,
                             default.file = "/etc/mysql/conf.d/analytics-research-client.cnf")
  } else { # Using version RMySQL 0.9.3 or older:
    con <- dbConnect(drv = "MySQL",
                             host = "analytics-store.eqiad.wmnet",
                             dbname = database,
                             default.file = "/etc/mysql/conf.d/analytics-research-client.cnf")
  }
  return(con)
}

#'@rdname mysql
#'@importMethodsFrom RMySQL dbSendQuery dbDisconnect dbListResults dbClearResult fetch
#'@export
mysql_read <- function(query, database, con = NULL) {
  already_connected <- !is.null(con)
  if (!already_connected) {
    #Open a temporary connection to the db
    con <- mysql_connect(database)
  }
  to_fetch <- dbSendQuery(con, query)
  data <- fetch(to_fetch, -1)
  message(sprintf("Fetched %.0f rows and %.0f columns.", nrow(data), ncol(data)))
  dbClearResult(dbListResults(con)[[1]])
  if (!already_connected) {
    #Close temporary connection
    dbDisconnect(con)
  }
  stop_on_empty(data)
  return(data)
}

#'@rdname mysql
#'@importMethodsFrom RMySQL dbExistsTable dbDisconnect
#'@export
mysql_exists <- function(database, table_name, con = NULL) {
  already_connected <- !is.null(con)
  if (!already_connected) {
    #Open a temporary connection to the db
    con <- mysql_connect(database)
  }
  #Grab the results and close off
  table_exists <- dbExistsTable(conn = con, name = table_name)
  if (!already_connected) {
    #Close temporary connection
    dbDisconnect(con)
  }
  #Return
  return(table_exists)
}

#'@rdname mysql
#'@importMethodsFrom RMySQL dbWriteTable dbDisconnect
#'@export
mysql_write <- function(x, database, table_name, con = NULL, ...){
  already_connected <- !is.null(con)
  if (!already_connected) {
    #Open a temporary connection to the db
    con <- mysql_connect(database)
  }
  #Write
  result <- dbWriteTable(conn = con,
                         name = table_name,
                         value = x,
                         row.names = FALSE,
                         ...)
  if (!already_connected) {
    #Close temporary connection
    dbDisconnect(con)
  }
  #Return the success/failure
  return(result)
}

#'@rdname mysql
#'@importMethodsFrom RMySQL dbDisconnect
#'@export
mysql_close <- function(con) {
  dbDisconnect(con)
  return(invisible())
}
#'@rdname mysql
#'@export
mysql_disconnect <- function(con) {
  mysql_close(con)
}

#'@title Builds a MySQL query aimed at the EventLogging-centric formats
#'@description constructs a MySQL query with a conditional around date.
#'This is aimed at eventlogging, where the date/time is always "timestamp".
#'
#'@param fields the SELECT statement.
#'
#'@param table the table to use.
#'
#'@param date the date to restrict to. If NULL, yesterday will be used.
#'
#'@param any other conditionals to include in the WHERE statement.
#'
#'@export
build_query <- function(fields, table, date = NULL, conditionals = NULL){

  # Ensure we have a date and deconstruct it into a MW-friendly format
  if (is.null(date)) {
    date <- Sys.Date() - 1
  }
  date <- gsub(x = date, pattern = "-", replacement = "")

  # Build the query proper (this will work for EL schemas where the field is always 'timestamp')
  query <- paste(fields, "FROM", table, "WHERE LEFT(timestamp,8) =", date,
                 ifelse(is.null(conditionals), "", "AND"), conditionals)

  results <- mysql_read(query, "log")
  stop_on_empty(results)
  return(results)
}
