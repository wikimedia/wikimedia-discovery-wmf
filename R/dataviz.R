#'@title Theme inspired by fivethirtyeight.com plots
#'@description A modification of \code{ggthemes::theme_fivethirtyeight}
#'
#'@param base_size base font size
#'@param base_family base font family
#'
#'@details Basically it adds axis titles (with some modification on the y to
#'  allow for long titles) back in and does a small amount of reduction of the
#'  overall plot size to avoid an absolute ton of extraneous spacing.
#'
#'@name FiveThirtyNine
#'@rdname FiveThirtyNine
#'@import ggplot2
#'@import ggthemes
#'
#'@export
#'
theme_fivethirtynine <- function(base_size = 12, base_family = "sans"){
  (theme_foundation(base_size = base_size, base_family = base_family) +
     theme(line = element_line(), rect = element_rect(fill = ggthemes::ggthemes_data$fivethirtyeight["ltgray"],
                                                      linetype = 0, colour = NA),
           text = element_text(colour = ggthemes::ggthemes_data$fivethirtyeight["dkgray"]),
           axis.title.y = element_text(size = rel(1.5), angle = 90, vjust = 1.5), axis.text = element_text(),
           axis.title.x = element_text(size = rel(1.5)),
           axis.ticks = element_blank(), axis.line = element_blank(),
           legend.background = element_rect(), legend.position = "bottom",
           legend.direction = "horizontal", legend.box = "vertical",
           panel.grid = element_line(colour = NULL),
           panel.grid.major = element_line(colour = ggthemes_data$fivethirtyeight["medgray"]),
           panel.grid.minor = element_blank(),
           plot.title = element_text(hjust = 0, size = rel(1.5), face = "bold"),
           strip.background = element_rect()))
}
