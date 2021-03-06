% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/palettes.R
\name{Palettes}
\alias{Palettes}
\alias{colors_base}
\alias{colors_accent}
\alias{colors_utility}
\alias{colors_discrete}
\alias{display_palettes}
\title{Wikimedia Design Color Palettes}
\source{
\href{https://design.wikimedia.org/style-guide/visual-style_colors.html}{Visual Style: Colors}
}
\usage{
colors_base(n = 9)

colors_accent(n = 3)

colors_utility(n = 9)

colors_discrete(n = 8)

display_palettes()
}
\arguments{
\item{n}{number of colors (varies by palette)}
}
\description{
The \href{https://design.wikimedia.org/style-guide/visual-style_colors.html}{color palette}
represents our character and brings a hint of freshness to our products.
Use \code{display_palettes()} to view the palettes and the names associated with
the various colors in them.
}
\section{Base colors}{

Base colors define the content surface and the main color for content.
Different shades of paper and ink are useful to emphasize or de-emphasize
different content areas.

Base colors range from pure white (Base100) to true black (Base0).
Intermediate shades of gray include a tint of blue for greater harmony with
our accent colors.

When applying text on a surface, you need to check the
\href{http://webaim.org/resources/contrastchecker/}{color contrast} between the
text and the background:
\itemize{
\item Base100...50 are safe text colors for a black surface.
\item Base30...0 are safe text colors for a white surface.
}
}

\section{Accent colors}{

Accent colors are used to emphasize actions and to highlight key information.
Blue is a natural choice in our context, where it has been the default color
used for links and conveys the idea of action.

There are three shades provided for when you need a lighter (Accent90),
regular (Accent50) or a darker (Accent10) version of blue.

Accent50 is suitable to use for text and as background. When used for link
text, this color provides sufficient contrast with black text. When used as
background, it provides sufficient contrast with white text.
}

\section{Utility colors}{

Utility colors are another type of accent color. Common meanings are
associated with them. We use shades of red, green, and yellow as utility
colors.
}

