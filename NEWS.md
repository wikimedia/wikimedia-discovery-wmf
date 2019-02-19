wmf 0.7.1
=========
* Updated for new sharded MariaDB replicas ([T212386](https://phabricator.wikimedia.org/T212386))
* Updated for x1 replica (cf. [T172410#4965383](https://phabricator.wikimedia.org/T172410#4965383))

wmf 0.6.0
=========
* Added color palettes based on [Wikimedia Design Style Guide](https://design.wikimedia.org/style-guide/)

wmf 0.5.2
=========
* Added `use_beeline` argument in the `query_hive` function to use `beeline` instead of Hive CLI.

wmf 0.5.0
=========
* Added `invert_list()` for inverting keys and values in named lists
* Added formatting helpers: `percent2()` and `pretty_num()`
* Added [David Robinson's `geom_flat_violin`](https://gist.github.com/dgrtwo/eb7750e74997891d7c20)

wmf 0.4.0
=========
* Added `parse_json()`
* Added `refine_eventlogs()`

wmf 0.3.1
=========
* Switched host name from db1047.eqiad.wmnet to db1108.eqiad.wmnet per [T156844](https://phabricator.wikimedia.org/T156844)

wmf 0.3.0
=========
* C++-based `exact_binomial()` to quickly estimate sample size for exact binomial tests
* Functions for working with interleaved search results experiments
  * See `?interleaved` for details
  * See `vignette("interleaved", package = "wmf")` for an example
  * Requires a compiler that supports C++11
* ggplot themes `theme_min()` and `theme_facet()`
* Documentation updates
* Syntax-checking unit test
* MIT licensing

wmf 0.2.7
=========
* Changes which host MySQL functions connect to, depending on the database:
  - "db1047.eqiad.wmnet" for event logging data from "log" db
  - "analytics-store.eqiad.wmnet" (same as before) for wiki content
* See [T176639](https://phabricator.wikimedia.org/T176639) for more details.

wmf 0.2.6
=========
* Adds support for more MySQL config filenames since those vary between the different machines
* Smarter about choosing a config file

wmf 0.2.5
=========
* Fixes Hive query execution to remove messages/warnings.

wmf 0.2.4
=========
* Ungroups grouped data frames when rewriting. See [T146422](https://phabricator.wikimedia.org/T146422) for more details.

wmf 0.2.3
=========
* Fixes ggplot2 theme margin bug [discovered & fixed](https://github.com/wikimedia/wikimedia-discovery-wmf/pull/1) by Oliver Keyes.

wmf 0.2.2
=========
* Updates `query_hive()` to support [JAR path overriding](https://wikitech.wikimedia.org/wiki/Analytics/Cluster/Hive/QueryUsingUDF#Testing_changes_to_existing_udf)
* Updates the MySQL config file path so the package can now also be used on stat1003
* Updates maintainer contact info in README

wmf 0.2.1
=========
* Adds a Contributor Code of Conduct

wmf 0.2.0
=========
* Adds compatibility with RMySQL 0.9.4+

wmf 0.1.1
=========
* Fix a bug in global_query

wmf 0.1.0
=========
Initial release
