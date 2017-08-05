context("Queries")

test_that("date clause", {
  expect_equal(date_clause(as.Date("2017-08-01"))$date_clause, "WHERE year = 2017 AND month = 8 AND day = 1 ")
})
