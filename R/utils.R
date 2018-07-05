#' @title Turn Null Into Character "NA"
#' @description This function turns `NULL` in a list into character "NA", which
#'   can be very useful when processing JSON data that has `null` values.
#' @param x A list
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
#' @param x A character vector of JSON
#' @export
parse_json <- function(x) {
  return(purrr::map(x, jsonlite::fromJSON))
}

#' @title Invert list
#' @description Inverts a (named) list such that the values become the keys and
#'   the keys become the values.
#' @param x A named list
#' @return A list with values as keys and keys as values.
#' @examples
#' invert_list(list(x = c(1, 2), y = c(2, 3)))
#' @author Mikhail Popov
#' @export
invert_list <- function(x) {
  if (is.null(names(x))) stop("expecting input to be a named list")
  new_fields <- Reduce(union, x)
  if (length(new_fields) == 0) warning("inverted list will be empty")
  names(new_fields) <- new_fields
  return(lapply(new_fields, function(field) {
    y <- purrr::map_lgl(x, ~ field %in% .x)
    return(names(y)[y])
  }))
}
