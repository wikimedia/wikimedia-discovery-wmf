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

#' @title Refine EventLogging data
#' @description Converts date-time and JSON columns, removes "event_" prefix
#'   fom column names, and returns `tibble`s.
#' @param el_data EventLogging data
#' @param dt_cols character vector of timestamp and date-time column names to
#'   parse; can also be a named list of parsing functions to apply on a
#'   per-column basis, as [lubridate::ymd_hms()] is used by default
#' @param json_cols character vector of JSON-containing column names that need
#'   to be parsed; can also be a named list of parsing functions to apply on a
#'   per-column basis, as [parse_json()] is used by default
#' @return A `tibble` (see [tibble::`tibble-package`] for more info)
#' @author Mikhail Popov
#' @export
refine_eventlogs <- function(el_data, dt_cols = NULL, json_cols = NULL) {
  el_data <- tibble::as_tibble(el_data)
  # Check column specifications and construct parsers if needed:
  if (!is.null(dt_cols)) {
    if (is.list(dt_cols)) {
      per_col_dt <- all(vapply(dt_cols, is.function, TRUE))
      if (!per_col_dt && any(vapply(dt_cols, is.function, TRUE))) {
        stop("You have an incomplete 'dt_cols' (not all columns are assigned a date-time parser)")
      }
    } else {
      per_col_dt <- FALSE
    }
    # Parse date-time columns:
    if (!per_col_dt) {
      dt_cols <- setNames(replicate(length(dt_cols), lubridate::ymd_hms), dt_cols)
    }
    for (dt_col in names(dt_cols)) {
      el_data[[dt_col]] <- dt_cols[[dt_col]](el_data[[dt_col]])
    }
  }
  if (!is.null(json_cols)) {
    if (is.list(json_cols)) {
      per_col_json <- all(vapply(json_cols, is.function, TRUE))
      if (!per_col_json && any(vapply(json_cols, is.function, TRUE))) {
        stop("You have an incomplete 'json_cols' (not all columns are assigned a JSON parser)")
      }
    } else {
      per_col_json <- FALSE
    }
    # Parse JSON-containing columns:
    if (!per_col_json) {
      json_cols <- setNames(replicate(length(json_cols), parse_json), json_cols)
    }
    for (json_col in names(json_cols)) {
      el_data[[json_col]] <- json_cols[[json_col]](el_data[[json_col]])
    }
  }
  names(el_data) <- sub("^event_", "", names(el_data))
  return(el_data)
}
