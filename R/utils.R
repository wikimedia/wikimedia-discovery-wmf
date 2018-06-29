#' @title Turn Null Into Character "NA"
#' @description This function turns `NULL` in a list into character "NA", which
#'   can be very useful when processing JSON data that has `null` values.
#' @param x a list
#' @return If any element from the input list is NULL, they will be turned into character
#'  "NA". Otherwise, return the original list.
#' @examples \dontrun{
#' result <- mysql_read("SELECT userAgent FROM ...", "log")
#' ua <- purrr::map_df(
#'   result$userAgent,
#'   ~ null2na(jsonlite::fromJSON(.x, simplifyVector = FALSE))
#' )
#' }
#' @export
null2na <- function(x) {
  return(lapply(x, function(y) {
    if (is.null(y)) {
      return(as.character(NA))
    } else {
      return(y)
    }
  }))
}

#' @title Parse character vector of JSON
#' @description This is a shortcut for using [purrr::map()] with
#'   [jsonlite::fromJSON()]. Useful when a column in a `data.frame` has JSON.
#'   **Note**: if the intention is to have the parsed data in a column such as
#'   when parsing in [dplyr::mutate()], it is *highly* recommended to switch
#'   to a `tibble` via [tibble::as_tibble()] *first*.
#' @param x character vector of JSON
#' @export
parse_json <- function(x) {
  return(purrr::map(x, jsonlite::fromJSON))
}
