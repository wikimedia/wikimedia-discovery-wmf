#' @title Query Hadoop cluster with Hive
#' @description Queries Hive
#' @param query a Hive query
#' @param heap_size `HADOOP_HEAPSIZE`; default is 1024 (alt: 2048 or 4096)
#' @param use_nice Whether to use `nice` for less greedy CPU usage in a multi-user environment. The default is `TRUE`.
#' @param use_ionice Whether to use `ionice` for less greedy I/O in a multi-user environment. The default is `TRUE`.
#' @param use_beeline Whether to use `beeline` to connect with Hive instead of `hive`. The default is `FALSE`.
#' @param debug Whether to print the query and any messages/info which could be useful for debugging.
#' @section Escaping:
#' `hive_query` works by running the query you provide through the CLI via a
#'   [system()] call. As a result, single escapes for meaningful characters
#'   (such as quotes) within the query will not work: R will interpret them
#'   only as escaping that character /within R/. Double escaping (\\\) is thus
#'   necessary, in the same way that it is for regular expressions.
#' @return A `data.frame` containing the results of the query, or a `TRUE` if
#'   the user has chosen to write straight to file.
# nolint start
#' @section Handling our hadoop/hive setup:
#' The `webrequests` table is documented [on Wikitech](https://wikitech.wikimedia.org/wiki/Analytics/Systems/Cluster/Hive),
#' which also provides [a set of example queries](https://wikitech.wikimedia.org/wiki/Analytics/Systems/Cluster/Hive/Queries). When it comes to manipulating the rows with Java before they get to you, Nuria has written a
#' [brief tutorial on loading UDFs](https://wikitech.wikimedia.org/wiki/Analytics/Systems/Cluster/Hive/QueryUsingUDF)
#' which should help if you want to engage in that.
# nolint end
#' @seealso [lubridate::ymd_hms()] for converting the "dt" column in the
#'   webrequests table to proper datetime, and [mysql_read()] and
#'   [global_query()] for querying our MySQL databases
#' @examples
#' \dontrun{
#' query_hive("USE wmf; DESCRIBE webrequest;")
#' }
#' @export
query_hive <- function(query, heap_size = 1024,
                       use_nice = TRUE, use_ionice = TRUE, use_beeline = FALSE,
                       debug = FALSE) {

  message("Don't forget to authenticate with Kerberos using kinit")

  # Write query out to tempfile and create tempfile for results.
  query_dump <- fs::file_temp(pattern = "temp_query", tmp_dir = ".", ext = ".hql")
  cat(query, file = query_dump)
  results_dump <- fs::file_temp(pattern = "temp_results", tmp_dir = ".", ext = ".tsv")

  if (debug) {
    message("Query written to: ", query_dump)
    message("Results will be written to: ", results_dump)
  }

  cli <- dplyr::case_when(
    use_beeline && debug ~ "beeline",
    use_beeline && ~debug ~ "beeline --silent=true",
    !use_beeline && debug ~ "hive",
    !use_beeline && !debug ~ "hive -S"
  )
  if (use_nice) cli <- paste("nice", cli)
  if (use_ionice) cli <- paste("ionice", cli)

  # Query and read in the results
  cmd <- "export HADOOP_HEAPSIZE={heap_size} && {cli} -f {query_dump} 2>&1"
  cmd <- paste(cmd, "> {results_dump}")
  cmd <- glue::glue(cmd)
  if (debug) message("Command to run: ", cmd)

  std_err <- system(cmd, intern = TRUE)
  if (debug) message("stderr:\n\t", std_err)
  if (fs::file_exists(results_dump)) {
    results <- utils::read.delim(results_dump, sep = "\t", quote = "", as.is = TRUE, header = TRUE)
    if (debug) message("First few rows of read-in results:\n", head(results))
  } else {
    stop("The file '", results_dump, "' does not exist")
  }

  # Clean up and return
  if (debug) {
    message("Query and results files were not automatically deleted to allow for inspection.")
    message(glue::glue("Do not forget to clean up using:\nrm {query_dump}\nrm {results_dump}"))
  } else {
    file.remove(query_dump, results_dump)
  }
  stop_on_empty(results)
  return(results)
}
