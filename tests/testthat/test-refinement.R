context("Refinement")

mobile_app_data <- readr::read_rds("mobile_app_data.rds")

test_that("refine_eventlogs (universal parsers)", {
  refined_eventlogs <- refine_eventlogs(
    mobile_app_data,
    dt_cols = c("timestamp", "event_client_dt"),
    json_cols = c("userAgent", "event_languages")
  )
  expect_true(tibble::is_tibble(refined_eventlogs))
  expect_true(lubridate::is.POSIXct(refined_eventlogs$timestamp))
  expect_true(lubridate::is.POSIXct(refined_eventlogs$client_dt))
  expect_equal(refined_eventlogs[["userAgent"]][[1]]$wmf_app_version, "2.7.235-r-2018-06-21")
  expect_equal(refined_eventlogs[1, "languages"][[1]][[1]], "de")
})

test_that("refine_eventlogs (per-column parsers)", {
  refined_eventlogs <- refine_eventlogs(
    mobile_app_data,
    dt_cols = list(
      "timestamp" = from_mediawiki,
      "event_client_dt" = lubridate::ymd_hms
    ),
    json_cols = c("userAgent", "event_languages")
  )
  expect_true(tibble::is_tibble(refined_eventlogs))
  expect_true(lubridate::is.POSIXlt(refined_eventlogs$timestamp))
  expect_true(lubridate::is.POSIXct(refined_eventlogs$client_dt))
  expect_equal(refined_eventlogs[["userAgent"]][[1]]$wmf_app_version, "2.7.235-r-2018-06-21")
  expect_equal(refined_eventlogs[1, "languages"][[1]][[1]], "de")
})
