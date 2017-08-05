#' @title Conditionally write out to a file
#' @description If the file already exists, append. If it doesn't, create!
#' @param x the object to write out
#' @param file the path to the file to use
#' @seealso [rewrite_conditional()]
#' @export
write_conditional <- function(x, file) {
  if (file.exists(file)) {
    utils::write.table(x, file, append = TRUE, sep = "\t", row.names = FALSE, col.names = FALSE, quote = FALSE)
  } else {
    utils::write.table(x, file, append = FALSE, sep = "\t", row.names = FALSE, quote = FALSE)
  }
}

#' @title Conditionally write to a (rolling) file
#' @description Writes out temporal data to a file while ensuring
#'   the file only has `n_days` worth of data in it.
#' @inheritParams write_conditional
#' @param n_days the number of days worth of data to have in the file;
#'   30 by default
#' @importFrom readr read_tsv
#' @seealso [write_conditional()]
#' @export
rewrite_conditional <- function(x, file, n_days = 30) {
  if ("grouped_df" %in% class(x) && requireNamespace("dplyr", quietly = TRUE)) {
    x <- dplyr::ungroup(x)
  }
  if (file.exists(file)) {
    y <- readr::read_tsv(file)
    y <- y[order(y$date, decreasing = FALSE), ]
    if ((Sys.Date() - min(y$date)) > (n_days + 1)) {
      z <- rbind(y[y$date >= (Sys.Date() - 1 - n_days), ], x)
      utils::write.table(z, file, append = FALSE, sep = "\t", row.names = FALSE, quote = FALSE)
      return(invisible())
    }
  }
  write_conditional(x, file)
}
