#' @title Theme inspired by fivethirtyeight.com plots
#' @description A modification of [ggthemes::theme_fivethirtyeight()]
#' @param base_size base font size
#' @param base_family base font family
#' @details Basically it adds axis titles (with some modification on the y to
#'   allow for long titles) back in and does a small amount of reduction of the
#'   overall plot size to avoid an absolute ton of extraneous spacing.
#' @name FiveThirtyNine
#' @rdname FiveThirtyNine
#' @import ggplot2
#' @import ggthemes
#' @author Oliver Keyes
#' @export
theme_fivethirtynine <- function(base_size = 12, base_family = "sans") {
  theme_foundation(base_size = base_size, base_family = base_family) +
    theme(
      line = element_line(),
      rect = element_rect(
        fill = ggthemes::ggthemes_data$fivethirtyeight["ltgray"],
        linetype = 0, colour = NA),
      text = element_text(
        colour = ggthemes::ggthemes_data$fivethirtyeight["dkgray"],
        margin = ggplot2::margin(), debug = FALSE
      ),
      axis.title.y = element_text(
        size = rel(2), angle = 90, vjust = 1.5,
        margin = ggplot2::margin(0, 12),
        debug = FALSE
      ),
      axis.text = element_text(size = rel(1.5)),
      axis.title.x = element_text(size = rel(2), margin = ggplot2::margin(12), debug = FALSE),
      axis.ticks = element_blank(), axis.line = element_blank(),
      legend.background = element_rect(), legend.position = "bottom",
      legend.direction = "horizontal", legend.box = "vertical",
      panel.grid = element_line(colour = NULL),
      panel.grid.major = element_line(colour = ggthemes::ggthemes_data$fivethirtyeight["medgray"]),
      panel.grid.minor = element_blank(),
      plot.title = element_text(hjust = 0, size = rel(1.5), face = "bold", margin = ggplot2::margin(), debug = FALSE),
      strip.background = element_rect(),
      legend.text = element_text(size = 18),
      legend.title = element_text(size = rel(1.5), margin = ggplot2::margin(4), debug = FALSE),
      legend.key.size = unit(1, "in"),
      panel.background = element_rect(fill = "transparent", color = NA),
      plot.background = element_rect(fill = "transparent", color = NA)
    )
}

#' @title Simple theme for ggplots
#' @description A minimal theme that puts the legend at the bottom.
#' @param base_size font size
#' @param base_family font family
#' @param ... additional parameters to pass to `theme()`
#' @author Mikhail Popov
#' @export
theme_min <- function(base_size = 12, base_family = "", ...) {
  ggplot2::theme_minimal(base_size, base_family) +
    ggplot2::theme(
      legend.position = "bottom",
      strip.placement = "outside",
      ...
    )
}

#' @title Simple theme for facet-ed ggplots
#' @description A minimal theme that puts the legend at the bottom and puts the
#'   facet labels into gray boxes. The border around those can be disabled.
#' @param base_size font size
#' @param base_family font family
#' @param border whether to add a border around facets
#' @param clean_xaxis whether to remove ticks & labels from x-axis
#' @param ... additional parameters to pass to `theme()`
#' @author Mikhail Popov & Chelsy Xie
#' @export
theme_facet <- function(base_size = 12, base_family = "", border = TRUE, clean_xaxis = FALSE, ...) {
  theme <- theme_min(base_size, base_family, ...) +
    ggplot2::theme(strip.background = element_rect(fill = "gray90"))
  if (border) {
    theme <- theme + ggplot2::theme(panel.border = element_rect(color = "gray30", fill = NA))
  }
  if (clean_xaxis) {
    theme <- theme +
      ggplot2::theme(
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.text.x = element_blank()
      )
  }
  return(theme)
}
