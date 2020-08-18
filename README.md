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
- `mysql_read` for querying our MariaDB databases
  - uses automatic shard detection, see `?connection_details` for more info
- Sample size calculations:
    - `chisq_test_odds` estimates sample size for a chi-squared test given an odds ratio
    - `chisq_test_effect` estimates sample size for a chi-squared test given Cohen's *w*

Also includes [Wikimedia Design visual style colors](https://design.wikimedia.org/style-guide/visual-style_colors.html):

![Color palettes included in the package based on Wikimedia Design Style Guide](palettes.png)

## Installation

```R
# install.packages("remotes", repos = c(CRAN = "https://cran.rstudio.com/"))
remotes::install_github("wikimedia/wmfdata-r")
```

## Maintainers

- [Mikhail Popov](https://meta.wikimedia.org/wiki/User:MPopov_(WMF))

## Additional Information

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

Working in Python? Check out [wmfdata](https://github.com/wikimedia/wmfdata-python) tools for working with Wikimedia data on the [analytics clients](https://wikitech.wikimedia.org/wiki/Analytics/Systems/Clients).


