context("Utilities")

test_that("null2na", {
  # e.g. from jsonlite::fromJSON('{"a":1,"b":null,"c":"d"}'):
  x <- list(a = 1, b = NULL, c = "d")
  expect_equal(null2na(x), list(a = 1, b = as.character(NA), c = "d"))
})

test_that("parse_json", {
  x <- c('{"a":[1,2]}', '{"b":3,"c":[4,5]}')
  y <- parse_json(x)
  z <- list(list(a = c(1, 2)), list(b = 3, c = c(4, 5)))
  expect_equal(z, y)
})

test_that("invert_list", {
  x <- list("x" = c(1, 2), y = c(), z = c(2, 3))
  y <- list(`1` = "x", `2` = c("x", "z"), `3` = "z")
  expect_equal(invert_list(x), y)
  z <- suppressWarnings(invert_list(list(x = c(), y = c(), z = c())))
  expect_equal(z, list())
})

library(zeallot)
test_that("ymd_extraction", {
  dates <- as.Date(c("2019-02-06", "2018-12-31"))
  c(year, month, day) %<-% extract_ymd(dates[1])
  expect_equal(year, 2019)
  expect_equal(month, 2)
  expect_equal(day, 6)
  ymds <- extract_ymd(dates)
  expect_equal(ymds$year, c(2019, 2018))
  expect_equal(ymds$month, c(2, 12))
  expect_equal(ymds$day, c(6, 31))
})
