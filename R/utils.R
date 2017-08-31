#'@title Turns Null Into Character "NA"
#'@description The function turns NULL in a list into character "NA".
#'
#'@param x A list
#'
#'@return If any element from the input list is NULL, they will be turned into character
#'  "NA". Otherwise, return the original list.
#'
#'@export
null2na <- function(x) {
  return(lapply(x, function(y) {
    if (is.null(y)) {
      return(as.character(NA))
    } else {
      return(y)
    }
  }))
}
