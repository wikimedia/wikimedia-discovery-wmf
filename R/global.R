#' @title Global SQL queries for analytics-store.eqiad.wmnet
#' @description `global_query` is a simple wrapper around the MySQL queries
#'   that allows a useR to send a query to all production dbs on
#'   analytics-store.eqiad.wmnet, joining the results from each query into a
#'   single object.
#' @param query the SQL query you want to run
#' @param project_type what class of wiki (e.g. "wikisource", "wiktionary")
#'   you want to run against. Set to "all" by default.
#' @author Os Keyes
#' @seealso [mysql_read()] for querying an individual db, [from_mediawiki()]
#'   for converting MediaWiki timestamps into `POSIXlt` timestamps, or
#'   [query_hive()] for accessing the Hive datastore
#' @export
global_query <- function(query, project_type = "all") {
  # Construct the query
  if (!project_type == "all") {
    info_query <- paste("SELECT wiki FROM wiki_info WHERE code = '", project_type, "'", sep = "")
  } else {
    info_query <- "SELECT wiki FROM wiki_info"
  }
  # Run query
  wikis <- mysql_read(query = info_query, database = "staging")$wiki
  # Instantiate progress bar and note environment
  pb <- progress::progress_bar$new(total = length(wikis))
  # Retrieve data
  data <- lapply(wikis, function(x, query) {
    # Retrieve the data
    data <- mysql_read(query = query, database = x)
    if (nrow(data) > 0) {
      data$project <- x # Add the wiki
    } else {
      data <- NULL
    }
    # Increment the progress bar
    pb$tick()
    # Return
    return(data)
  }, query = query)
  cat("\n")
  # Bind it into a single object and return
  return(do.call(what = "rbind", args = data))
}
