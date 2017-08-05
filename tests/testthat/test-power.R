context("Sample size calculations")

test_that("chisq_test_odds returns the appropriate estimates", {
  expect_equal(
    chisq_test_odds(odds_ratio = 2, p_treatment = 0.4, p_control = 0.25, power = 0.8, conf_level = 0.95),
    311
  )
  expect_equal(chisq_test_odds(p_treatment = 0.4, p_control = 0.25, power = 0.8), 311)
  expect_equal(
    unname(chisq_test_odds(p_treatment = 0.4, p_control = 0.25, power = c(0.8, 0.9, 0.95))),
    c(311, 416, 514)
  )
})

test_that("chisq_test_odds returns errors when it should", {
  expect_error(chisq_test_odds())
  expect_error(chisq_test_odds(2))
  expect_error(chisq_test_odds(odds_ratio = 2, power = 0.8))
})

test_that("chisq_test_odds returns warnings when it should", {
  expect_warning(
    chisq_test_odds(p_treatment = 0.4, p_control = 0.25, power = 0.8, visualize = TRUE),
    "All parameters known. Nothing to visualize."
  )
})

test_that("chisq_test returns the appropriate estimates", {
  expect_equal(chisq_test_effect(0.3), 88)
  expect_equal(chisq_test_effect(0.1, groups = 3, power = 0.95), 1545)
  expect_equal(chisq_test_effect(), c("tiny" = 3140, "small" = 785, "medium" = 88, "large" = 32))
})

test_that("chisq_test returns errors when it should", {
  expect_error(chisq_test_effect(w = 0.01))
  expect_error(chisq_test_effect(w = 0.1, power = 0.001))
  expect_error(chisq_test_effect(w = 0.1, sig_level = 2))
})

test_that("exact_binom calculates appropriate sample sizes", {
  expect_equal(exact_binom(0.75, 0.03, alpha = 0.05, power = 0.9, two_tail = TRUE), 2105)
  expect_equal(exact_binom(0.75, 0.03, alpha = 0.05, power = 0.9, two_tail = FALSE), 1716)
  expect_equal(exact_binom(0.75, 0.01, alpha = 0.05, power = 0.9, two_tail = TRUE), 19394)
})
