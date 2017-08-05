#include <RcppArmadilloExtensions/sample.h>
#include "interleaved_map.h"
#include <algorithm> // std::unique_copy, std::sort
#include <vector>    // std::vector
#include <iterator>  // std::back_insert_iterator
// [[Rcpp::depends(RcppArmadillo)]]
using namespace Rcpp;

//' @param bootstraps number of times to sample unique sessions
//'   (with replacement); 1000 by default
//' @examples
//' data("interleaved_data", package = "wmf")
//' x <- interleaved_data[interleaved_data$event == "click", ]
//' x <- x[order(x$session_id, x$timestamp), ]
//' data("interleaved_data_a", package = "wmf")
//' y <- interleaved_data_a[interleaved_data_a$event == "click", ]
//' y <- y[order(y$session_id, y$timestamp), ]
//' data("interleaved_data_b", package = "wmf")
//' z <- interleaved_data_b[interleaved_data_b$event == "click", ]
//' z <- z[order(z$session_id, z$timestamp), ]
//'
//' # Bootstrapped preference statistics:
//'
//' ## Data without a clear preference:
//' b <- interleaved_bootstraps(x$session_id, x$ranking_function)
//' hist(b)
//'
//' ## Data where A is preferred over B:
//' b <- interleaved_bootstraps(y$session_id, y$ranking_function)
//' hist(b)
//'
//' ## Data where B is preferred over A:
//' b <- interleaved_bootstraps(z$session_id, z$ranking_function)
//' hist(b)
//' @rdname interleaved
//' @export
// [[Rcpp::export]]
std::vector<double> interleaved_bootstraps(std::vector<std::string> sessions, std::vector<std::string> clicks, int bootstraps = 1000) {
  std::map<std::string, int> wins = interleaved_map(sessions, clicks);
  std::vector<double> preferences(bootstraps);
  // Get a vector of unique session IDs:
  std::sort(sessions.begin(), sessions.end());
  std::vector<std::string> uniques;
  std::unique_copy(sessions.begin(), sessions.end(), std::back_inserter(uniques));
  // Bootstrap preferences:
  int winsA, winsB, ties;
  std::vector<std::string> resampled;
  for (int i = 0; i < bootstraps; i++) {
    // Sample sessions with replacement:
    resampled = RcppArmadillo::sample(uniques, uniques.size(), true);
    // Compute preference:
    winsA = 0; winsB = 0; ties = 0; // reset tallies
    for (std::string &session : resampled)
    {
      switch(wins[session]) {
      case 0 : ties++;
        break;
      case 1 : winsA++;
        break;
      case -1: winsB++;
        break;
      }
    }
    preferences[i] = (((winsA + (ties / 2.0)) / (winsA + winsB + ties)) - 0.5);
  }
  return preferences;
}

//' @param confidence level; 0.95 by default
//' @examples
//'
//' # Preference statistic confidence intervals:
//'
//' ## Data without a clear preference:
//' interleaved_confint(x$session_id, x$ranking_function)
//'
//' ## Data where A is preferred over B:
//' interleaved_confint(y$session_id, y$ranking_function)
//'
//' ## Data where B is preferred over A:
//' interleaved_confint(z$session_id, z$ranking_function)
//' @rdname interleaved
//' @export
// [[Rcpp::export]]
List interleaved_confint(std::vector<std::string> sessions, std::vector<std::string> clicks, int bootstraps = 1000, double confidence = 0.95) {
  std::vector<double> preferences = interleaved_bootstraps(sessions, clicks, bootstraps);
  Environment stats("package:stats");
  Function quantile = stats["quantile"];
  double alpha = 1 - confidence;
  double median = as<double>(quantile(preferences, 0.5));
  double lower = as<double>(quantile(preferences, alpha / 2));
  double upper = as<double>(quantile(preferences, (1 - (alpha / 2))));
  return List::create(_["point.est"] = median, _["lower"] = lower, _["upper"] = upper);
}
