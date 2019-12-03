#' @title Set HTTP and HTTPS proxies
#' @description Sets the HTTP and HTTPS proxies when running R on
#'   Wikimedia machines.
#' @export
set_proxies <- function() {
  Sys.setenv("http_proxy" = "http://webproxy.eqiad.wmnet:8080")
  Sys.setenv("https_proxy" = "http://webproxy.eqiad.wmnet:8080")
}
