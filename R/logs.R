parse_date <- function(date) {
  return(gsub(x = date, pattern = "-", replacement = ""))
}

#' @title Retrieve a vector of sampled log files
#' @description Grabs sampled log files to be piped into [read_sampled_log()].
#'   By default this retrieves all sampled log files; it can be used to
#'   retrieve a particular date range of files through the "earliest" and
#'   "latest" arguments.
#' @param earliest a `Date` object. Set to `NULL` by default, which triggers
#'   the retrieval of all log file names.
#' @param latest a `Date` object; set to `NULL` by default. In the event that
#'   `earliest` is set but `latest` is not, the files retrieved will span from
#'   `earliest` to the current date; in the event that both arguments are set,
#'   the retrieved files will be those in that range.
#' @return A vector of filenames that can be passed into [read_sampled_log()]
#' @author Os Keyes
#' @export
get_logfile <- function(earliest = NULL, latest = NULL) {
  # Begin Exclude Linting
  files <- list.files("/a/squid/archive/sampled", full.names = TRUE, pattern = "gz$")
  # End Exclude Linting
  if (!is.null(earliest)) {
    file_dates <- as.numeric(substring(files, 47, 55))
    if (!is.null(latest)) {
      files <- files[file_dates >= as.numeric(parse_date(earliest)) & file_dates <= as.numeric(parse_date(latest))]
    } else {
      files <- files[file_dates >= as.numeric(parse_date(earliest))]
    }
  }
  return(files)
}

#' @title Read a sampled log file
#' @description Reads a sampled log file identified with [get_logfile()].
#'   The sampled logs are returned as a data.frame with 16 columns - see
#'   the **Value** documentation.
#' @param file a filename, retrieved with [get_logfile()]
#' @param transparent a logical flag whether to gunzip the log file explicitly
#'   first (default) or read it in directly.
#' @param nrows number of rows to read in; *optional*
#' @return a `data.frame` containing 16 columns:
#' - squid
#' - sequence_no
#' - timestamp
#' - servicetime
#' - ip_address
#' - status_code
#' - reply_size
#' - request_method
#' - url
#' - squid_status
#' - mime_type
#' - referer
#' - x_forwarded
#' - user_agent
#' - lang
#' - x_analytics
#' @importFrom urltools url_decode
#' @author Os Keyes
#' @export
read_sampled_log <- function(file, transparent = FALSE, nrows = NULL) {
  is_gzipped <- grepl("gz$", file)
  if (is_gzipped) { # gzipped log file
    if (transparent) { # read the file in directly w/o gunzipping first
      output_file <- file
    } else {
      output_file <- tempfile()
      system(paste("gunzip -c", file, ">", output_file))
    }
  } else {
    # an already gunzipped log file
    output_file <- file
  }
  if (is.null(nrows)) {
    nrows <- -1
  }
  data <- utils::read.delim(
    output_file, as.is = TRUE, quote = "", nrows = nrows,
    col.names = c(
      "squid", "sequence_no",
      "timestamp", "servicetime",
      "ip_address", "status_code",
      "reply_size", "request_method",
      "url", "squid_status",
      "mime_type", "referer",
      "x_forwarded", "user_agent",
      "lang", "x_analytics"
    )
  )
  if (is_gzipped && !transparent) {
    file.remove(output_file)
  }
  data$url <- urltools::url_decode(data$url)
  data$referer <- urltools::url_decode(data$referer)
  return(data)
}
