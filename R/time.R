#' @title Convert to and from common timestamp formats
#' @description Convert to and from MediaWiki and request log timestamp formats
#' @param x a vector of timestamps
#' @name timeconverters
#' @rdname timeconverters
#' @examples
#' from_mediawiki("20150101010301")
#' @author Oliver Keyes
#' @seealso [lubridate::ymd_hms()]
#' @export
from_mediawiki <- function(x) {
  return(strptime(substr(x, 0, 14), format = "%Y%m%d%H%M%S", tz = "UTC"))
}

#' @rdname timeconverters
#' @export
from_log <- function(x) {
  return(strptime(substr(iconv(x, to = "UTF-8"), 0, 19), format = "%Y-%m-%dT%H:%M:%S", tz = "UTC"))
}

#' @rdname timeconverters
#' @export
to_mediawiki <- function(x) {
  gsub(x = x, pattern = "(:| |-)", replacement = "")
}

#' @rdname timeconverters
#' @export
to_log <- function(x) {
  gsub(x = x, pattern = " ", replacement = "T")
}
