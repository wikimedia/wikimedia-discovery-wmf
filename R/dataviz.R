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

#' @title Flat violin plot
#' @description Violin plots are a compact display of continuous distributions
#'   but are usually mirrored to mimick boxplots. The "flat" version removes
#'   that mirrorness and makes the violin plots less...suggestive.
#' @inheritParams ggplot2::geom_point
#' @param trim If `TRUE` (default), trim the tails of the violins
#'   to the range of the data. If `FALSE`, don't trim the tails.
#' @param geom,stat Use to override the default connection between
#'   `geom_violin` and `stat_ydensity`.
#' @examples \dontrun{
#' ggplot(diamonds, aes(cut, carat)) +
#'   geom_flat_violin() +
#'   coord_flip()
#' }
#' @author [David Robinson](https://github.com/dgrtwo)
#' @source Gist: [dgrtwo/geom_flat_violin.R](https://gist.github.com/dgrtwo/eb7750e74997891d7c20)
#' @rdname ggplot2-flatviolin
#' @export
geom_flat_violin <- function(mapping = NULL, data = NULL, stat = "ydensity",
                             position = "dodge", trim = TRUE, scale = "area",
                             show.legend = NA, inherit.aes = TRUE, ...) {
  return(ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomFlatViolin,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      trim = trim,
      scale = scale,
      ...
    )
  ))
}

"%||%" <- function(a, b) {
  if (!is.null(a)) {
    return(a)
  } else {
    return(b)
  }
}

#' @rdname ggplot2-flatviolin
#' @format NULL
#' @usage NULL
GeomFlatViolin <- ggplot2::ggproto(
  "GeomFlatViolin",
  ggplot2::Geom,
  setup_data = function(data, params) {
    data$width <- data$width %||%
      params$width %||% (resolution(data$x, FALSE) * 0.9)

    # ymin, ymax, xmin, and xmax define the bounding rectangle for each group
    return(dplyr::mutate(
      dplyr::group_by(data, group), ymin = min(y),
      ymax = max(y),
      xmin = x,
      xmax = x + width / 2
    ))
  },

  draw_group = function(data, panel_scales, coord) {
    # Find the points for the line to go all the way around
    data <- transform(data, xminv = x, xmaxv = x + violinwidth * (xmax - x))

    # Make sure it's sorted properly to draw the outline
    newdata <- rbind(
      plyr::arrange(transform(data, x = xminv), y),
      plyr::arrange(transform(data, x = xmaxv), -y)
    )

    # Close the polygon: set first and last point the same
    # Needed for coord_polar and such
    newdata <- rbind(newdata, newdata[1, ])

    return(ggplot2:::ggname("geom_flat_violin", ggplot2::GeomPolygon$draw_panel(newdata, panel_scales, coord)))
  },

  draw_key = draw_key_polygon,
  default_aes = aes(weight = 1, colour = "grey20", fill = "white", size = 0.5, alpha = NA, linetype = "solid"),
  required_aes = c("x", "y")
)
