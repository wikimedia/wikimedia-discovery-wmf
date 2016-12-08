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
