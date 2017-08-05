context("Utilities")

test_that("null2na", {
  # e.g. from jsonlite::fromJSON('{"a":1,"b":null,"c":"d"}'):
  x <- list(a = 1, b = NULL, c = "d")
  expect_equal(null2na(x), list(a = 1, b = as.character(NA), c = "d"))
})
