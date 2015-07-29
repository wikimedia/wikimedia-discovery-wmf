#'@title query MySQL databases
#'@description read from, write to, and check data from the MySQL databases and tables in the Wikimedia
#'cluster. Assumes the presence of a validly formatted .my.cnf.
#'
#'@param query a SQL query.
#'
#'@param database the name of the database to query.
#'
#'@param table the name of a table to check for the existence of or create, depending on the
#'function.
#'
#'@param ... further arguments to pass to dbWriteTable. See ?dbWriteTable for more details.
#'
#'@name mysql
#'@rdname mysql
#'@importMethodsFrom RMySQL dbConnect dbSendQuery dbDisconnect dbListResults dbClearResult fetch
#'
#'@seealso \code{\link{hive_query}} or \code{\link{global_query}}
#'
#'@export
mysql_read <- function(query, database){
  con <- dbConnect(drv = "MySQL",
                   host = "analytics-store.eqiad.wmnet",
                   dbname = database,
                   default.file = "/etc/mysql/conf.d/analytics-research-client.cnf")
  to_fetch <- dbSendQuery(con, query)
  data <- fetch(to_fetch, -1)
  dbClearResult(dbListResults(con)[[1]])
  dbDisconnect(con)
  return(data)
}

#'@rdname mysql
#'@importMethodsFrom RMySQL dbExistsTable
#'@export
mysql_exists <- function(database, table_name){
  #Create a connector
  con <- dbConnect(drv = "MySQL",
                   host = "analytics-store.eqiad.wmnet",
                   dbname = database,
                   default.file = "/etc/mysql/conf.d/analytics-research-client.cnf")
  #Grab the results and close off
  table_exists <- dbExistsTable(conn = con, name = table_name)
  dbDisconnect(con)
  #Return
  return(table_exists)
}


#'@rdname mysql
#'@importMethodsFrom RMySQL dbWriteTable
#'@export
mysql_write <- function(x, database, table_name, ...){
  #Open a connection to the db
  con <- dbConnect(drv = "MySQL",
                   host = "analytics-store.eqiad.wmnet",
                   dbname = database,
                   default.file = "/etc/mysql/conf.d/analytics-research-client.cnf")
  #Write
  result <- dbWriteTable(conn = con,
                         name = table_name,
                         value = x,
                         row.names = FALSE,
                         ...)
  #Close connection
  dbDisconnect(con)
  #Return the success/failure
  return(result)
}