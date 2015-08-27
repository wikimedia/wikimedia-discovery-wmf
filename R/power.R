oddsRatio <- function(p_treatment, p_control) {
  return( (p_treatment/(1-p_treatment)) / (p_control/(1-p_control)) )
}
pTreatment <- function(p_control, odds_ratio) {
  return( (odds_ratio*p_control) / ((p_control*(odds_ratio-1)) + 1) )
}
pControl <- function(p_treatment, odds_ratio) {
  return( 1/( (odds_ratio * ((1/p_treatment) - 1)) + 1 ) )
}

#'@title calculate sample size given odds ratio
#'
#'@param odds_ratio The expected odds ratio. That is, the ratio of the odds of
#'  the outcome in the test group relative to the control group. Optional,
#'  but see \strong{Details}.
#'@param p_control Your guess for prevalence of outcome in the control group.
#'  Optional but see \strong{Details}.
#'@param p_treatment Your guess for prevalence of outcome in the test group.
#'  Optional but see \strong{Details}.
#'@param power The ability of the test to detect an effect where there is one.
#'  Power = 1 - Prob(Type 2 error). Optional. See \strong{Value} for details.
#'@param conf_level Desired confidence level. Defaults to 95\%.
#'@param sample_ratio Ratio of test group to control group. 1 is even split.
#'@param visualize Whether to plot power or prevalence of outcome in the
#'  control group vs sample size. Can be used to help make a decision.
#'
#'@details The function only needs to know two of the following three:
#' \code{odds_ratio}, \code{p_control}, and \code{p_treatment}. If given
#' all three, it will check to make sure the odds ratio is correct. It
#' will figure out the missing third value from the other two.
#'
#'@return If \code{power} was not provided, returns vector containing
#'  possible power values and the appropriate sample size for each \%.
#'  If all values were provided, returns a single sample size estimate.
#'
#'@section References:
#'Wang, H., Chow, S.-C., & Li, G. (2002). On sample size calculation based on
#'  odds ratio in clinical trials. \emph{Journal of Biopharmaceutical
#'  Statistics}, \strong{12}(4), 471–483.
#'  \url{http://doi.org/10.1081/BIP-120016231}
#'
#'@examples
#'sample_size_odds(p_treatment = 0.4, p_control = 0.25, power = 0.8)
#'sample_size_odds(odds_ratio = 2, p_control = 0.4, power = c(0.8, 0.9, 0.95))
#'sample_size_odds(odds_ratio = 2, p_control = 0.4)
#'sample_size_odds(odds_ratio = 2, p_control = 0.4, visualize = TRUE)
#'
#'@export
sample_size_odds <- function(odds_ratio = NULL,
                             p_control = NULL,
                             p_treatment = NULL,
                             power = NULL, conf_level = 0.95,
                             sample_ratio = 1,
                             visualize = FALSE) {
  # Checks
  power_missing <- is.null(power)
  pC_missing <- is.null(p_control)
  pT_missing <- is.null(p_treatment)
  oR_missing <- is.null(odds_ratio)
  if ( (oR_missing + pC_missing + pT_missing) > 1) {
    stop("Only one of {odds_ratio, p_control, p_treatment} can be missing.")
  }

  # Imputations (Part 1)
  if (power_missing) {
    power <- seq(0.5, 0.99, 0.01)
  }
  # Imputations (Part 2)
  if (pC_missing) {
    p_control <- pControl(p_treatment, odds_ratio)
  } else if (pT_missing) {
    p_treatment <- pTreatment(p_control, odds_ratio)
  } else if (oR_missing) {
    odds_ratio <- oddsRatio(p_treatment, p_control)
  }

  # Calculations
  x <- p_treatment * (1 - p_treatment) * sample_ratio
  y <- p_control * (1 - p_control)
  z_alpha <- qnorm((1-conf_level)/2)
  z_beta <- qnorm(1-power)
  n_b <- (1/x + 1/y) * (((z_alpha + z_beta)^2) / (log(odds_ratio)^2))
  n_a <- sample_ratio * n_b
  n <- ceiling(n_a + n_b)

  # Visualization
  if (visualize) {
    if (power_missing || length(power) > 1) {
      plot(power, n, type = "l", main = "Sample size as function of statistical power",
           ylab = "N", xlab = "Power to detect effect", lwd = 2, xaxt = "n")
      axis(side = 1, at = seq(0.5, 1, 0.1),
           labels = sprintf("%.0f%%", 100*seq(0.5, 1, 0.1)))
      abline(v = seq(0.5, 1, 0.1), lty = "dotted", col = "lightgray", lwd = par("lwd"))
    } else {
      warning("All parameters known. Nothing to visualize.")
    }
  }

  # Output
  if (power_missing || length(power) > 1) {
    names(n) <- sprintf("%.0f%%", power*100)
  }
  return(n)

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
#'  Defaults to 80\%.
#'@return If \code{w} was not provided, returns a data frame containing
#'  possible values of w and the corresponding sample size estimates.
#'
#'@examples
#'sample_size_effect()
#'sample_size_effect(0.1)
#'sample_size_effect(w = 0.1, groups = 3, sig_level = 0.001, power = 0.9)
#'
#'@importFrom pwr pwr.chisq.test
#'@export
sample_size_effect <- function(w = NULL, groups = 2,
                               sig_level = 0.05, power = 0.8) {
  # Checks
  w_missing <- is.null(w)
  if (!w_missing && w <= 0.01) stop("'w' must be > 0.01")
  if (power <= 0.1 || power > 1.0) stop("'power' must be in (0.1, 1]")

  # Imputation
  if (w_missing) w <- c(0.05, 0.1, 0.3, 0.5)

  # Calculation and output
  if (length(w) > 1) {
    n <- ceiling(sapply(w, function(ww) {
      pwr::pwr.chisq.test(w = ww, N = NULL, df = groups - 1,
                          sig.level = sig_level, power = power)$N
    }))
    names(n) <- c("tiny", "small", "medium", "large")
  } else {
    n <- ceiling(pwr::pwr.chisq.test(w = w, N = NULL, df = groups - 1,
                                     sig.level = sig_level, power = power)$N)
  }
  return(n)
}



