#' @title Interleaved search results
#' @description Tools for analysis of experiments that use interleaved search
#'   results wherein users receive results from multiple sets of retrieval
#'   functions.
#'   - `interleaved_data` is a fake dataset used for testing and examples;
#'     refer to **Format** section below
#'   - `interleaved_data_a` is a fake dataset used for testing and examples;
#'     "A" is preferred over "B"
#'   - `interleaved_data_b` is a fake dataset used for testing and examples;
#'     "B" is preferred over "A"
#'   - `interleaved_preference` returns a test statistic summarizing the
#'     interleaving experiment; a positive value indicates that A is better
#'     than B, a negative value indicates that B is better than A
#'   - `interleaved_bootstraps` returns a bootstrapped sample of preference
#'     statistics computed by resampling sessions with replacements
#'   - `interleaved_confint` returns a `list` with elements "point.est",
#'     "lower", and "upper" (uses `interleaved_bootstraps` internally)
#'   - `interleaved_sample_size` estimates the sample size required to detect
#'     a particular effect size with a specified power and significance level
#' @references
#' - Chapelle, O., Joachims, T., Radlinski, F., & Yue, Y. (2012). Large-scale
#'   validation and analysis of interleaved search evaluation.
#'   *ACM Transactions on Information Systems*, **30**(1), 1-41.
#'   [doi:10.1145/2094072.2094078](https://doi.org/10.1145/2094072.2094078)
#' - Radlinski, F. and Craswell, N. (2013). [Optimized interleaving for online retrieval evaluation](https://www.microsoft.com/en-us/research/publication/optimized-interleaving-for-online-retrieval-evaluation/).
#'   *ACM International Conference on Web Search and Data Mining (WSDM)*.
#'   [doi:10.1145/2433396.2433429](https://doi.org/10.1145/2433396.2433429)
#' @name interleaved
NULL

fake_interleaved_data <- function(dev = FALSE, n_sessions = 1000, seed = 0) {
  set.seed(seed)
  fake_timestamps <- function(n) {
    return(as.POSIXct(
      stats::runif(n, 0, 60 * 10),
      origin = "2018-08-01 00:00:00",
      tz = "UTC"
    ))
  }
  fake_session <- function(preference = NULL) {
    n_events <- sample.int(10, 1)
    if (n_events == 1) {
      return(data.frame(
        session_id = paste0(sample(c(letters, 0:9), 10), collapse = ""),
        timestamp = fake_timestamps(1),
        event = "serp",
        position = as.numeric(NA),
        ranking_function = as.character(NA),
        stringsAsFactors = FALSE
      ))
    } else {
      if (is.null(preference)) {
        probability <- c(0.5, 0.5)
      } else if (preference == "A") {
        probability <- c(0.75, 0.25)
      } else {
        probability <- c(0.25, 0.75)
      }
      df <- data.frame(
        session_id = rep_len(paste0(sample(c(letters, 0:9), 10), collapse = ""), n_events),
        timestamp = sort(fake_timestamps(n_events), decreasing = FALSE),
        event = c("serp", rep_len("click", n_events - 1)),
        position = c(NA, sample.int(20, n_events - 1, replace = FALSE)),
        ranking_function = c(NA, sample(c("A", "B"), n_events - 1, replace = TRUE, prob = probability)),
        stringsAsFactors = FALSE
      )
      if (n_events %in% c(3, 5, 7, 9) && stats::rbinom(1, 1, 0.005) == 1) {
        df$ranking_function[df$event == "click"] <- rep_len(c("A", "B"), n_events - 1)
      }
      return(df)
    }
  }
  message("Generating unbiased data...")
  interleaved_data <- do.call(rbind, replicate(n_sessions, fake_session(), simplify = FALSE))
  if (dev) {
    devtools::use_data(interleaved_data, overwrite = TRUE)
  }
  message("Generating A-biased data...")
  interleaved_data_a <- do.call(rbind, replicate(n_sessions, fake_session("A"), simplify = FALSE))
  if (dev) {
    devtools::use_data(interleaved_data_a, overwrite = TRUE)
  }
  message("Generating B-biased data...")
  interleaved_data_b <- do.call(rbind, replicate(n_sessions, fake_session("B"), simplify = FALSE))
  if (dev) {
    devtools::use_data(interleaved_data_b, overwrite = TRUE)
  }
  if (!dev) {
    return(list(
      no_preference = interleaved_data,
      a_preferred = interleaved_data_a,
      b_preferred = interleaved_data_b
    ))
  }
}

#' @format `interleaved_data*` are `data.frame`-s of generated search sessions with
#'   the following columns:
#'   \describe{
#'     \item{session_id}{10-character alphanumeric ID; for grouping events}
#'     \item{timestamp}{when the event occurred; uses [POSIXct][base::DateTimeClasses] format}
#'     \item{event}{"serp" or "click"}
#'     \item{position}{position ("ranking") of the clicked search result}
#'     \item{ranking_function}{"A" or "B"}
#'   }
#'   Users in `interleaved_data` have no preference, users in
#'     `interleaved_data_a` have preference for ranking function "A", and users
#'     in `interleaved_data_b` have preference for ranking function "B".
#' @rdname interleaved
"interleaved_data"

#' @rdname interleaved
"interleaved_data_a"

#' @rdname interleaved
"interleaved_data_b"
