#'@title set HTTP and HTTPS proxies
#'@description set the HTTP and HTTPS proxies when running R on
#'one of the Wikimedia servers
#'
#'@examples
#'\dontrun{
#'#This will fail in the cluster
#'devtools::install_github("ironholds/urltools")
#'
#'#This will work
#'set_proxies()
#'devtools::install_github("ironholds/urltools")
#'}
#'
#'@export
set_proxies <- function(){
  Sys.setenv("http_proxy" = "http://webproxy.eqiad.wmnet:8080")
  Sys.setenv("https_proxy" = "http://webproxy.eqiad.wmnet:8080")
}