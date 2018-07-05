#' @title Formatters
#' @description Formatting utilities
#' @param x A vector to format
#' @details
#' - `percent2`: multiply by one hundred, display percent sign, clear "NA%"'s,
#'   and optionally prepend a "+" to positive percentages
#' - `pretty_num`: shortcut to formatting 1e6 as 1,000,000
#' @rdname formatters
#' @name Formatters
NULL

#' @rdname formatters
#' @export
percent2 <- function(x, digits = 1, add_plus = FALSE) {
  y <- sprintf(paste0("%.", digits, "f%%"), 100 * x)
  y[y == "NA%"] <- ""
  if (add_plus) y[x > 0 & !is.na(x)] <- paste0("+", y[x > 0 & !is.na(x)])
  return(y)
}

#' @param ... Additional parameters to pass to [base::prettyNum()]
#' @rdname formatters
#' @export
pretty_num <- function(x, ...) {
  return(prettyNum(x, big.mark = ",", ...))
}
