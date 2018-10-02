# R Tools for Wikimedia Foundation's Analysts

[This package](https://phabricator.wikimedia.org/diffusion/1821/) contains functions made for Analysts at Wikimedia Foundation, but can be used by people outside of the Foundation.

- `set_proxies` to set http(s) proxies on the analytics cluster
- `global_query` for querying all of our MySQL databases
- Utilities for working with logs, including EventLogging data:
  - `from_mediawiki` and `from_log` (and corresponding `to_*` functions) to convert between time formats
  - `refine_eventlogs`
    - parses date-time columns and JSON columns (via `parse_json`)
    - removes the "event_" prefix from column names
- `query_hive` for querying our Hadoop cluster via Hive
- Sample size calculations:
    - `chisq_test_odds` estimates sample size for a chi-squared test given an odds ratio
    - `chisq_test_effect` estimates sample size for a chi-squared test given Cohen's *w*
- Functions for estimating preference of ranking functions using clicks on interleaved search results:
    - `interleaved_preference` estimates preference; see vignette for details
    - `interleaved_bootstraps` resamples sessions with replacement to yield bootstrapped sample of preferences
    - `interleaved_confint` uses `interleaved_bootstraps` and `stats::quantile` to yield a bootstrapped confidence interval

Also includes [Wikimedia Design visual style colors](https://design.wikimedia.org/style-guide/visual-style_colors.html):

![Color palettes included in the package based on Wikimedia Design Style Guide](palettes.png)

## Installation

This package requires compilation with a compiler that supports [C++11](https://en.wikipedia.org/wiki/C%2B%2B11). `g++-5` and `clang++` 3.3 have (near-)complete C++11 support. `g++-6` and `g++-7` are pretty common on Linux and if you have the most recent version of Command Line Tools for Xcode (via `xcode-select --install`) for macOS, you should have `clang++` 5.0.0 (or later), which includes full C++11 support.

```R
# install.packages("devtools", repos = c(CRAN = "https://cran.rstudio.com/"))

devtools::install_git("https://gerrit.wikimedia.org/r/wikimedia/discovery/wmf", build_vignettes = TRUE)

# Alternatively, you can install from GitHub mirror:
devtools::install_github("wikimedia/wikimedia-discovery-wmf", build_vignettes = TRUE)
```

## Maintainers

- [Mikhail Popov](https://meta.wikimedia.org/wiki/User:MPopov_(WMF))
- [Chelsy Xie](https://meta.wikimedia.org/wiki/User:CXie_(WMF))

## Additional Information

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
