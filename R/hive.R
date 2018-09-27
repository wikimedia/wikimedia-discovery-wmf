#' @title Query Hadoop cluster with Hive
#' @description Queries Hive
#' @param query a Hive query
#' @param override_jars A logical flag indicating whether to override the path.
#'   Hive on WMF's analytics machine(s) loads some JARs by default, so if your
#'   query uses an updated version of an existing UDF and you want to load the
#'   JAR that you built yourself, set this to `TRUE`. See
#'   [Testing changes to existing UDF](https://wikitech.wikimedia.org/wiki/Analytics/Systems/Cluster/Hive/QueryUsingUDF#Testing_changes_to_existing_udf)
#'   for more details.
#' @param heap_size `HADOOP_HEAPSIZE`; default is 1024 (alt: 2048 or 4096)
#' @param use_beeline A logical flag indicating whether to use `beeline` to connect with Hive instead of `hive`. The default is `FALSE`.
#' @section escaping:
#' `hive_query` works by running the query you provide through the CLI via a
#'   [system()] call. As a result, single escapes for meaningful characters
#'   (such as quotes) within the query will not work: R will interpret them
#'   only as escaping that character /within R/. Double escaping (\\\) is thus
#'   necessary, in the same way that it is for regular expressions.
#' @return a `data.frame` containing the results of the query, or a `TRUE` if
#'   the user has chosen to write straight to file.
#' @section Handling our hadoop/hive setup:
#' The `webrequests` table is documented [on Wikitech](https://wikitech.wikimedia.org/wiki/Analytics/Systems/Cluster/Hive),
#' which also provides [a set of example queries](https://wikitech.wikimedia.org/wiki/Analytics/Systems/Cluster/Hive/Queries). When it comes to manipulating the rows with Java before they get to you, Nuria has written a
#' [brief tutorial on loading UDFs](https://wikitech.wikimedia.org/wiki/Analytics/Systems/Cluster/Hive/QueryUsingUDF)
#' which should help if you want to engage in that.
#' @seealso [lubridate::ymd_hms()] for converting the "dt" column in the
#'   webrequests table to proper datetime, and [mysql_read()] and
#'   [global_query()] for querying our MySQL databases
#' @examples
#' \dontrun{
#' query_hive("USE wmf; DESCRIBE webrequest;")
#' }
#' @export
query_hive <- function(query, override_jars = FALSE, heap_size = 1024, use_beeline = FALSE) {

    # Write query out to tempfile and create tempfile for results.
    query_dump <- tempfile()
    cat(query, file = query_dump)
    results_dump <- tempfile()

    filters <- paste0(
      c("", paste("grep -v", c("JAVA_TOOL_OPTIONS", "parquet.hadoop", "WARN:", ":WARN"))),
      collapse = " | "
    )

    # Query and read in the results
    try({
      system(paste0(
        "export HADOOP_HEAPSIZE=", heap_size,
        ifelse(use_beeline, " && beeline --silent=true ", " && hive -S "),
        ifelse(override_jars, "--hiveconf hive.aux.jars.path= ", ""),
        "-f ", query_dump, " 2> /dev/null", filters, " > ", results_dump
      ))
      results <- utils::read.delim(results_dump, sep = "\t", quote = "", as.is = TRUE, header = TRUE)
    })

    # Clean up and return
    file.remove(query_dump, results_dump)
    stop_on_empty(results)
    return(results)

}

#' @title Generate a Date Clause for a Hive query
#' @description What it says on the tin; generates a
#'   `WHERE year = foo AND month = bar`
#'   that can then be combined with other elements to form a Hive query.
#' @param date if `NULL`, yesterday will be used
#' @return a list containing two elements: "date_clause" and "date"; the
#'   returning of the date allows you to include it
#' @export
date_clause <- function(date) {
  if (is.null(date)) {
    date <- Sys.Date() - 1
  }
  fragment <- sprintf(
    "WHERE year = %s AND month = %s AND day = %s ",
    lubridate::year(date),
    lubridate::month(date),
    lubridate::mday(date)
  )
  output <- list(date_clause = fragment, date = date)
  return(output)
}
