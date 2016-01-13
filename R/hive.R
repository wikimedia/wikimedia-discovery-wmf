#'@title hive_query
#'@details Hive querying function
#'@description this is the "old" hive querying function - it's deprecated as all hell and waiting
#'until Andrew sticks the hive server on a dedicated and more powerful machine.
#'
#'@param query a query, or the location of a .hql file containing a query.
#'
#'@param file a file name. If this is provided, the results of the query will be written straight
#'there, and a boolean TRUE returned. If not provided (it's NULL by default), the results of the query
#'will be returned as a data.frame
#'
#'@param dt Whether to return it as a data.table or not.
#'
#'@param ... other arguments to pass to read.delim.
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
#'@export
hive_query <- function(query, file = NULL, ...){

  to_R <- FALSE
  
  #If the user wants it passed straight to R...
  if(is.null(file)){

    #Create temp file
    file <- tempfile(pattern = "file", fileext = ".tsv")

    #Note
    to_R <- TRUE

  }

  #Run query. If the query is /not/ a file, make it one
  if(!grepl(x = query, pattern = "\\.hql$")){
    query_file <- tempfile(fileext = ".hql")
    cat(query, file = query_file)
    query <- query_file
  }

  #Run
  system(paste("export HADOOP_HEAPSIZE=1024 && hive -f", query, ">", file))

  #Read, remove the file and return(if appropriate)
  if(to_R){
    data <- read.delim(file = file, header = TRUE, as.is = TRUE, quote = "", ...)
    file.remove(file)
    return(data)
  }
  return(TRUE)



}
