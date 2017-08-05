#include <Rcpp.h>
#include "interleaved_map.h"
// [[Rcpp::plugins(cpp11)]]
using namespace Rcpp;

//' @param sessions vector of session IDs used to group `positions` and
//'   `ranking_functions`
//' @param clicks vector that shows which ranking function the
//'   clicked search result came from ("A" or "B")
//' @examples
//'
//' # Preference statistic calculation:
//'
//' ## Data without a clear preference:
//' interleaved_preference(x$session_id, x$ranking_function)
//'
//' ## Data where A is preferred over B:
//' interleaved_preference(y$session_id, y$ranking_function)
//'
//' ## Data where B is preferred over A:
//' interleaved_preference(z$session_id, z$ranking_function)
//' @rdname interleaved
//' @export
// [[Rcpp::export]]
double interleaved_preference(std::vector<std::string> sessions, std::vector<std::string> clicks) {
  std::map<std::string, int> wins = interleaved_map(sessions, clicks);
  int winsA = 0;
  int winsB = 0;
  int ties = 0;
  for (auto const& session : wins)
  {
    switch(session.second) {
    case 0 : ties++;
      break;
    case 1 : winsA++;
      break;
    case -1: winsB++;
      break;
    }
  }
  double preference = (((winsA + (ties / 2.0)) / (winsA + winsB + ties)) - 0.5);
  return preference;
}
