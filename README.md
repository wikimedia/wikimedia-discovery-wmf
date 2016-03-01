# R tools for WMF Analytics

This package contains functions made for Analysts at Wikimedia Foundation, but can be used by people outside of the Foundation.

1. `set_proxies()` to set http/s proxies on the analytics cluster;
2. `global_query()` for querying all of our MySQL databases;
3. `from_mediawiki` and `from_log` (and corresponding `to_*` functions) to convert between time formats, and;
4. `query_hive` for querying our Hadoop cluster via Hive.
5. `sample_size_odds` and `sample_size_effect` for calculating sample size(s) given an odds ratio or effect size (Cohen's *w*).

More functions as people need them.

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

## Installation

```
devtools::install_github("wikimedia-research/wmf")
```

## Maintainers

- [Oliver Keyes](https://meta.wikimedia.org/wiki/User:Okeyes_(WMF))
- [Mikhail Popov](https://meta.wikimedia.org/wiki/User:MPopov_(WMF))
