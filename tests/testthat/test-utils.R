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
