#include <Rcpp.h>
using namespace Rcpp;

std::map<std::string, int> interleaved_map(std::vector<std::string> sessions, std::vector<std::string> clicks) {
  std::map<std::string, int> wins; // 0 if tie, -1 if B was preferred, 1 if A was preferred
  int perSessionWinsA = 0;
  int perSessionWinsB = 0;
  if (clicks[0] == "A") {
    perSessionWinsA++;
  } else {
    perSessionWinsB++;
  }
  for (int i = 1; i < sessions.size(); i++) {
    if (sessions[i] != sessions[i - 1]) {
      // We're now looking at a new session, so let's process
      // the previous session's tally of wins:
      wins.insert(std::make_pair(sessions[i - 1], (perSessionWinsA == perSessionWinsB) ? 0 : ((perSessionWinsA > perSessionWinsB) ? 1 : -1)));
      // Reset tallies:
      perSessionWinsA = 0;
      perSessionWinsB = 0;
    }
    if (clicks[i] == "A") {
      perSessionWinsA++;
    } else {
      perSessionWinsB++;
    }
  }
  return wins;
}
