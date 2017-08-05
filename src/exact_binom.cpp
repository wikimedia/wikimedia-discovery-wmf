#include <Rcpp.h>
using namespace Rcpp;
#include <climits> // UINT_MAX
#include <cmath>   // std::abs
#include <boost/math/distributions/binomial.hpp>
using boost::math::binomial_distribution;

//' @title Sample size for exact, one sample binomial test
//' @description Estimates sample size required to detect difference from a
//'   constant proportion.
//' @param constant_prop The proportion under the null hypothesis.
//' @param effect_size Positive size of the difference between your null
//'   hypothesis and the alternative hypothesis that you hope to detect.
//'   **Heads-up** that values less than 1\% might take a while to calculate.
//' @param alpha Probability of rejecting the null hypothesis even though it is
//'   true.
//' @param power Probability of rejecting the null hypothesis (getting a
//'   significant result) when the real difference is equal to the minimum
//'   effect size.
//' @param two_tail Whether to perform two-tail or one-tail power analysis.
//'   `TRUE` (default) tests in both directions of difference.
//' @examples
//' exact_binom(0.75, 0.03)
//' @references [Power analysis](http://www.biostathandbook.com/power.html) and
//'   [Exact test of goodness-of-fit](http://www.biostathandbook.com/exactgof.html) from
//'   John H. McDonald's [_Handbook of Biological Statistics_](http://www.biostathandbook.com/)
//' @export
// [[Rcpp::export]]
unsigned int exact_binom(double constant_prop, double effect_size, double alpha = 0.05, double power = 0.8, bool two_tail = true) {
  if (two_tail) {
    alpha = alpha / 2;
  }
  unsigned int i = 10;
  double beta = 1 - power;
  bool end_condition = true;
  do {
    i += 1;
    if (i == INT_MAX) {
      break;
    }
    end_condition = (std::abs(cdf(binomial_distribution<>(i, constant_prop + effect_size), quantile(binomial_distribution<>(i, constant_prop), 1 - alpha)) - beta) / beta >= 0.01);
  } while (end_condition);
  return i;
}

/*** R
exact_binom(0.75, 0.01, power = 0.9)
exact_binom(0.75, 0.03, power = 0.9)
exact_binom(0.75, 0.03, power = 0.9, two_tail = FALSE)
*/
