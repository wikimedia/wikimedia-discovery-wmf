#'@title calculate sample size given odds ratio
#'
#'@param precision Relative precision dictates your margin of error. Optional
#'  only if \code{pa} is provided.
#'@param odds_ratio The expected odds ratio. That is, the ratio of the odds of
#'  the outcome in the test group (b) relative to the control group (a).
#'@param p_a Expected prevalence of outcome in the control group (a). Optional
#'  only if \code{precision} is provided.
#'@param conf_level Desired confidence level. Defaults to 95\%.
#'@param sample_ratio Ratio of test group to control group. 1 is even split.
#'@param visualize Whether to plot relative precision or prevalence of outcome
#'  in the control group vs sample size. Can be used to help make a decision.
#'
#'@return If \code{pa} was not provided, returns a data frame containing
#'  possible values of \eqn{\pi_a} and the appropriate sample size.
#'  If \code{pa} was provided, returns a single sample size estimate.
#'
#'@export
sample_size_odds <- function(odds_ratio, precision = NULL, p_a = NULL, conf_level = 0.95, sample_ratio = 1, visualize = FALSE) {
  if (is.null(precision) && is.null(p_a)) stop("'precision' and 'p_a' cannot both be missing.")
  precision_missing <- is.null(precision)
  prevalence_missing <- is.null(p_a)
  if (precision_missing) {
    if (p_a >= 1 || p_a < 0) stop("'p_a' must be in [0, 1)")
    if ((p_a * odds_ratio) + 1 == 1) stop("p_a * odds_ratio + 1 cannot be equal to 1")
    precision <- seq(0.01, 0.25, 0.005)
  } else if (prevalence_missing) {
    if (precision <= 0 && precision >= 1) stop("'precision' must be in (0, 1)")
    p_a <- seq(0.05, 0.95, 0.01)
  }
  p_b <- round((odds_ratio * p_a) / (p_a * (odds_ratio - 1) + 1), 3)
  x <- 1/(p_b * (1 - p_b) * sample_ratio)
  y <- 1/(p_a * (1 - p_a))
  z <- abs(qnorm((1-conf_level)/2))
  n_a <- ceiling((1/x + 1/y)*((z^2)/(log10(1 - precision))^2))
  n_b <- ceiling(sample_ratio * n_a)
  n <- n_a + n_b
  if (visualize) {
    if (prevalence_missing) {
      plot(p_a, n, type = "l", main = "Sample size as function of prevalence in controls",
           ylab = "N", xlab = "Prevalence of outcome in control group", lwd = 2, xaxt = "n")
      axis(side = 1, at = seq(0.05, 0.95, 0.1), labels = sprintf("%.0f%%", 100*seq(0.05, 0.95, 0.1)))
      abline(v = seq(0.05, 0.95, 0.1), lty = "dotted", col = "lightgray", lwd = par("lwd"))
    } else if (precision_missing) {
      plot(precision, n, type = "l", main = "Sample size as function of relative precision",
           ylab = "N", xlab = "Relative precision of the study", lwd = 2, xaxt = "n")
      axis(side = 1, at = c(0.01, seq(0.05, 0.25, 0.05)),
           labels = sprintf("%.0f%%", 100*c(0.01, seq(0.05, 0.25, 0.05))))
      abline(v = c(0.01, seq(0.05, 0.25, 0.05)), lty = "dotted", col = "lightgray", lwd = par("lwd"))
    } else {
      warning("All parameters known. Nothing to visualize.")
    }
  }
  if (prevalence_missing) {
    return(data.frame("prevalence_in_controls" = p_a,
                      "prevalence_in_test_group" = p_b,
                      "sample_size" = n))
  } else if (precision_missing) {
    return(data.frame("relative_precision" = precision, "sample_size" = n))
  } else {
    return(c("sample_size" = n))
  }
}

#'@title calculate sample size given effect size
#'@description Uses Cohen's w for effect size to calculate sample size for
#'  a chi-squared test of independence.
#'
#'@param w Effect size you want the test to be able to detect. (Optional)
#'@param groups Number of groups. Used in degrees of freedom calculation.
#'  Defaults to 2 (e.g. control group vs treatment group).
#'@param sig_level Probability of Type 1 error. Usually called alpha.
#'  Defaults to 0.05.
#'@param power Ability to detect the effect. (1 - probability of Type 2 error)
#'
#'@return If \code{w} was not provided, returns a data frame containing
#'  possible values of w and the corresponding sample size estimates.
#'
#'@importFrom pwr pwr.chisq.test
#'@export
sample_size_effect <- function(w = NULL, groups = 2,
                               sig_level = 0.05, power = 0.95) {
  w_missing <- is.null(w)
  if (!w_missing && w <= 0.01) stop("'w' must be > 0.01")
  if (power <= 0.1 || power > 1.0) stop("'power' must be in (0.1, 1]")
  if (w_missing) w <- c(0.05, 0.1, 0.3, 0.5)
  if (length(w) > 1) {
    n <- ceiling(sapply(w, function(ww) {
      pwr::pwr.chisq.test(w = ww, N = NULL, df = groups - 1,
                          sig.level = sig_level, power = power)$N
    }))
    return(data.frame("effect_size" = c("tiny", "small", "medium", "large"),
                      "cohen_w" = w,
                      "sample_size" = n))
  } else {
    n <- ceiling(pwr::pwr.chisq.test(w = w, N = NULL, df = groups - 1,
                                     sig.level = sig_level, power = power)$N)
    return(c("sample_size" = n))
  }
}



