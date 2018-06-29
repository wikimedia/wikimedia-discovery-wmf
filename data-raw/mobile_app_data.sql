SELECT
  uuid,
  timestamp,
  '{"wmf_app_version": "2.7.235-r-2018-06-21", "os_minor": "0", "os_major": "7", "is_bot": false, "device_family": "Generic Smartphone", "os_family": "Android", "browser_minor": "0", "is_mediawiki": false, "browser_major": "7", "browser_family": "Android"}' AS userAgent,
  wiki,
  event_length,
  event_languages,
  event_client_dt,
  MD5(event_app_install_id) AS event_app_install_id
FROM MobileWikiAppSessions_18115099
LIMIT 20;
