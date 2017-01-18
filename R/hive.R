#'@title hive_query
#'@details Hive querying function
#'@description this is the "old" hive querying function - it's deprecated as all hell and waiting
#'until Andrew sticks the hive server on a dedicated and more powerful machine.
#'
#'@param query a Hive query
#'@param override_jars A logical flag indicating whether to override the path.
#'  Hive on WMF's analytics machine(s) loads some JARs by default, so if your
#'  query uses an updated version of an existing UDF and you want to load the
#'  JAR that you built yourself, set this to TRUE. See
#'  \href{https://wikitech.wikimedia.org/wiki/Analytics/Cluster/Hive/QueryUsingUDF#Testing_changes_to_existing_udf}{this section}
#'  for more details.
#'
#'@section escaping:
#'\code{hive_query} works by running the query you provide through the CLI via a system() call.
#'As a result, single escapes for meaningful characters (such as quotes) within the query will not work:
#'R will interpret them only as escaping that character /within R/. Double escaping (\\\) is thus necessary,
#'in the same way that it is for regular expressions.
#'
#'@return a data.frame containing the results of the query, or a boolean TRUE if the user has chosen
#'to write straight to file.
#'
#'@section handling our hadoop/hive setup:
#'
#'The \code{webrequests} table is documented
#'\href{https://wikitech.wikimedia.org/wiki/Analytics/Cluster/Hive}{on Wikitech}, which also provides
#'\href{https://wikitech.wikimedia.org/wiki/Analytics/Cluster/Hive/Queries}{a set of example
#'queries}.
#'
#'When it comes to manipulating the rows with Java before they get to you, Nuria has written a
#'\href{https://wikitech.wikimedia.org/wiki/Analytics/Cluster/Hive/QueryUsingUDF}{brief tutorial on loading UDFs}
#'which should help if you want to engage in that; the example provided is a user agent parser, allowing you to
#'get the equivalent of \code{\link{ua_parse}}'s output further upstream.
#'@seealso \code{\link{log_strptime}} for converting the "dt" column in the webrequests table to POSIXlt,
#'and \code{\link{mysql_query}} and \code{\link{global_query}} for querying our MySQL databases.
#'
#'@examples
#'\dontrun{
#'query_hive("USE wmf; DESCRIBE webrequest;")
#'}
#'
#'@export
query_hive <- function(query, override_jars = FALSE) {

    # Write query out to tempfile and create tempfile for results.
    query_dump <- tempfile()
    cat(query, file = query_dump)
    results_dump <- tempfile()

    filters <- paste0(c("", paste("grep -v", c("JAVA_TOOL_OPTIONS", "parquet.hadoop", "WARN:", ":WARN"))), collapse = " | ")

    # Query and read in the results
    try({
      system(
        paste0("export HADOOP_HEAPSIZE=1024 && hive -S ",
               ifelse(override_jars, "--hiveconf hive.aux.jars.path= ", ""),
               "-f ", query_dump, " 2> /dev/null", filters, " > ", results_dump)
      )
      results <- read.delim(results_dump, sep = "\t", quote = "", as.is = TRUE, header = TRUE)
    })

    # Clean up and return
    file.remove(query_dump, results_dump)
    stop_on_empty(results)
    return(results)

}

#'@title Generate a Date Clause for a Hive query
#'@description what it says on the tin; generates a "WHERE year = foo AND month = bar" using lubridate
#'that can then be combined with other elements to form a Hive query.
#'
#'@param date the date to use. If NULL, yesterday will be used.
#'
#'@return a list containing two elements, "date_clause" and "date"; the returning of
#'the date allows you to include it with.
#'
#'@export
date_clause <- function(date) {
  if (is.null(date)) {
    date <- Sys.Date() - 1
  }

  split_date <- unlist(strsplit(as.character(date), "-"))

  fragment <- (paste("WHERE year =", split_date[1],
                     "AND month =",split_date[2],
                     "AND day =", split_date[3], ""))

  output <- list(date_clause = fragment, date = date)
  return(output)
}