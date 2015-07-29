## Internal tools for WMF data analysts

A lot of code is generalisable. Some code is not. This package contains functions generalisable to "people at the Wikimedia Foundation"
but "too scattered and not useful enough for people outside it" including:

1. `set_proxies()` to set http/s proxies on the analytics cluster;
2. `global_query()` for querying all of our MySQL databases;
3. `from_mediawiki` and `from_log` (and corresponding `to_*` functions) to convert between time formats, and;
4. `hive_query` for hitting up our HDFS store.

More functions as people need them.

### Installation

```
    devtools::install_github("ironholds/wmf")
    
```