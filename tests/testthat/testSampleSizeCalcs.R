context("Sample size calculations")

test_that("sample_size_odds returns the appropriate estimates", {
  expect_equal(sample_size_odds(odds_ratio = 2, p_treatment = 0.4, p_control = 0.25, power = 0.8, conf_level = 0.95), 311)
  expect_equal(sample_size_odds(p_treatment = 0.4, p_control = 0.25, power = 0.8), 311)
  expect_equal(unname(sample_size_odds(p_treatment = 0.4, p_control = 0.25,
                                       power = c(0.8, 0.9, 0.95))), c(311, 416, 514))
})

test_that("sample_size_odds returns errors when it should", {
  expect_error(sample_size_odds())
  expect_error(sample_size_odds(2))
  expect_error(sample_size_odds(odds_ratio = 2, power = 0.8))
})

test_that("sample_size_odds returns warnings when it should", {
  expect_warning(sample_size_odds(p_treatment = 0.4, p_control = 0.25, power = 0.8, visualize = TRUE),
                 "All parameters known. Nothing to visualize.")
})

test_that("sample_size_effect returns the appropriate estimates", {
  expect_equal(sample_size_effect(0.3), 88)
  expect_equal(sample_size_effect(0.1, groups = 3, power = 0.95), 1545)
  expect_equal(sample_size_effect(),
               c("tiny" = 3140, "small" = 785, "medium" = 88, "large" = 32))
})

test_that("sample_size_effect returns errors when it should", {
  expect_error(sample_size_effect(w = 0.01))
  expect_error(sample_size_effect(w = 0.1, power = 0.001))
  expect_error(sample_size_effect(w = 0.1, sig_level = 2))
})
