context("Sample size calculations")

test_that("sample_size_odds returns the appropriate estimates", {
  expect_equal(sample_size_odds(1.1, 0.01, 0.45, 0.95, 1), c("sample_size" = 200356))
  expect_equal(sample_size_odds(1.1, p_a = 0.45,
                                conf_level = 0.90)[c(1, 10, 20, 40), "sample_size"],
               c(141110, 4454, 1160, 272))
  expect_equal(sample_size_odds(1.1, precision = 0.05,
                                conf_level = 0.90)[c(1, 25, 50, 75, 91), "sample_size"],
               c(1086, 4578, 5392, 3522, 998))
})

test_that("sample_size_odds returns errors when it should", {
  expect_error(sample_size_odds())
  expect_error(sample_size_odds(1.1))
  expect_error(sample_size_odds(precision = 0.01, p_a = 0.45))
})

test_that("sample_size_odds returns warnings when it should", {
  expect_warning(sample_size_odds(1.1, 0.01, 0.45, 0.95, 1, visualize = TRUE),
                 "All parameters known. Nothing to visualize.")
})

test_that("sample_size_effect returns the appropriate estimates", {
  expect_equal(sample_size_effect(0.3), c("sample_size" = 145))
  expect_equal(sample_size_effect(0.1, groups = 3), c("sample_size" = 1545))
  expect_equal(sample_size_effect()$sample_size, c(5198, 1300, 145, 52))
})

test_that("sample_size_effect returns errors when it should", {
  expect_error(sample_size_effect(w = 0.01))
  expect_error(sample_size_effect(w = 0.1, power = 0.001))
  expect_error(sample_size_effect(w = 0.1, sig_level = 2))
})
