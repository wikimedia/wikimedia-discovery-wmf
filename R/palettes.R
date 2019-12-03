#' @title Wikimedia Design Color Palettes
#' @description The [color palette](https://design.wikimedia.org/style-guide/visual-style_colors.html)
#'   represents our character and brings a hint of freshness to our products.
#'   Use `display_palettes()` to view the palettes and the names associated with
#'   the various colors in them.
#' @param n number of colors (varies by palette)
#' @section Base colors:
#' Base colors define the content surface and the main color for content.
#' Different shades of paper and ink are useful to emphasize or de-emphasize
#' different content areas.
#'
#' Base colors range from pure white (Base100) to true black (Base0).
#' Intermediate shades of gray include a tint of blue for greater harmony with
#' our accent colors.
#'
#' When applying text on a surface, you need to check the
#' [color contrast](http://webaim.org/resources/contrastchecker/) between the
#' text and the background:
#' - Base100...50 are safe text colors for a black surface.
#' - Base30...0 are safe text colors for a white surface.
#' @section Accent colors:
#' Accent colors are used to emphasize actions and to highlight key information.
#' Blue is a natural choice in our context, where it has been the default color
#' used for links and conveys the idea of action.
#'
#' There are three shades provided for when you need a lighter (Accent90),
#' regular (Accent50) or a darker (Accent10) version of blue.
#'
#' Accent50 is suitable to use for text and as background. When used for link
#' text, this color provides sufficient contrast with black text. When used as
#' background, it provides sufficient contrast with white text.
#' @section Utility colors:
#' Utility colors are another type of accent color. Common meanings are
#' associated with them. We use shades of red, green, and yellow as utility
#' colors.
#' @source [Visual Style: Colors](https://design.wikimedia.org/style-guide/visual-style_colors.html)
#' @rdname palettes
#' @name Palettes
NULL

#' @rdname palettes
#' @export
colors_base <- function(n = 9) {
  if (n > 9) stop("only 9 base colors available")
  colors <- c(
    "Base100" = "#ffffff",
    "Base90" = "#f8f9fa",
    "Base80" = "#eaecf0",
    "Base70" = "#c8ccd1",
    "Base50" = "#a2a9b1",
    "Base30" = "#72777d",
    "Base20" = "#54595d",
    "Base10" = "#222222",
    "Base0" = "#000000"
  )
  return(colors[unique(floor(seq.int(1, 9, length.out = n)))])
}

#' @rdname palettes
#' @export
colors_accent <- function(n = 3) {
  if (n > 3) stop("only 3 accent colors available")
  colors <- c(
    "Accent50" = "#3366cc",
    "Accent10" = "#2a4b8d",
    "Accent90" = "#eaf3ff"
  )
  return(colors[seq_len(n)])
}

#' @rdname palettes
#' @export
colors_utility <- function(n = 9) {
  if (n > 9) stop("only 9 utility colors available")
  colors <- c(
    "Red90" = "#fee7e6",
    "Red50" = "#dd3333",
    "Red30" = "#b32424",
    "Green90" = "#d5fdf4",
    "Green50" = "#00af89",
    "Green30" = "#14866d",
    "Yellow90" = "#fef6e7",
    "Yellow50" = "#ffcc33",
    "Yellow30" = "#ac6600"
  )
  if (n < 4) {
    return(colors[c("Red50", "Green50", "Yellow50")][seq_len(n)])
  } else if (n > 3 && n <= 6) {
    return(colors[c(
      "Red90", "Red30",
      "Green90", "Green30",
      "Yellow50", "Yellow30"
    )][seq_len(n)])
  } else {
    return(colors[seq_len(n)])
  }
}

#' @rdname palettes
#' @export
colors_discrete <- function(n = 8) {
  if (n > 8) stop("only 8 discrete colors available")
  colors <- c(
    "Red50" = "#dd3333",
    "Red30" = "#b32424",
    "Green50" = "#00af89",
    "Green30" = "#14866d",
    "Accent50" = "#3366cc",
    "Accent10" = "#2a4b8d",
    "Yellow50" = "#ffcc33",
    "Yellow30" = "#ac6600"
  )
  if (n < 5) {
    return(colors[c("Red50", "Green50", "Accent50", "Yellow50")][seq_len(n)])
  } else {
    return(colors[seq_len(n)])
  }
}

#' @rdname palettes
#' @import ggplot2
#' @export
display_palettes <- function() {
  colors <- list(
    `colors_base()` = colors_base(),
    `colors_accent()` = colors_accent(),
    `colors_utility()` = colors_utility(),
    `colors_discrete()` = colors_discrete()
  )
  colors <- purrr::map_dfr(
    colors,
    ~ data.frame(
      name = names(.x),
      color = unname(.x),
      n = seq_len(length(.x)),
      stringsAsFactors = FALSE),
    .id = "palette"
  )
  color_map <- colors$color
  names(color_map) <- colors$name
  ggplot(colors, aes(x = n, y = 0)) +
    geom_point(size = 4, color = "black") +
    geom_point(aes(color = name), size = 3) +
    geom_label(aes(label = name), hjust = "left", nudge_y = 0.1, label.size = 0) +
    scale_y_continuous(limits = c(-0.5, 1)) +
    scale_x_reverse(breaks = 1:9, minor_breaks = NULL, limits = c(10, 0)) +
    scale_color_manual(values = color_map, guide = FALSE) +
    coord_flip() +
    facet_wrap(~ palette) +
    theme_min(base_size = 14) +
    theme(
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank(),
      strip.background = element_rect(fill = "#3366cc"),
      strip.text = element_text(color = "white"),
      plot.caption = element_text(hjust = 0)
    ) +
    labs(
      title = "Color palettes",
      subtitle = "see ?Palettes for details",
      caption = "Based on Wikimedia Design Style Guide (https://design.wikimedia.org/style-guide/)",
      y = NULL, x = "Index in palette"
    )
}
