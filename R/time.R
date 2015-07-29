#'@title convert to and from common timestamp formats
#'@description convert to and from MediaWiki and request log timestamp formats
#'
#'@param x a vector of timestamps
#'
#'@name timeconverters
#'@rdname timeconverters
#'
#'@examples
#'from_mediawiki("20150101010301")
#'@export
from_mediawiki <- function(x){
  return(strptime(substr(x, 0, 14), format = "%Y%m%d%H%M%S", tz = "UTC"))
}

#'@rdname timeconverters
#'@export
from_requestlog <- function(x){
  return(strptime(substr(iconv(x, to = "UTF-8"), 0, 19), format = "%Y-%m-%dT%H:%M:%S", tz = "UTC"))
}

#'@rdname timeconverters
#'@export
to_mediawiki <- function(x){
  gsub(x = x, pattern = "(:| |-)", replacement = "")
}

#'@rdname timeconverters
#'@export
to_requestlog <- function(x){
  gsub(x = x, pattern = " ", replacement = "T")
}