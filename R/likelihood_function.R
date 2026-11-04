#' User-defined likelihood function for calibration
#'
#' Penalises simulated values that fall outside the
#' \code{[obs_lower, obs_upper]} envelope defined in the observed data.
#' Simulated values within the envelope incur no penalty; values below the
#' lower bound or above the upper bound are penalised in proportion to the
#' log-ratio of their deviation, scaled by \code{1e6} so the penalty
#' dominates the objective function.
#'
#' The penalty is computed as:
#' \deqn{-10^6 \sum \log\left(\min\left(\frac{s+1}{l+1}, 1\right)\right)
#'        + 10^6 \sum \log\left(\max\left(\frac{s+1}{u+1}, 1\right)\right)}
#' where \eqn{s} is the simulated value, \eqn{l} the lower bound, and
#' \eqn{u} the upper bound.  Adding 1 to numerator and denominator avoids
#' division by zero when values are near zero.  \code{NA} values are ignored.
#'
#' This function must be exported to cluster workers (e.g. via
#' \code{\link[parallel]{clusterExport}}) when running the calibration in
#' parallel.
#'
#' @param obs Numeric matrix or data frame with two columns: column 1 is the
#'   lower bound (\code{obs_lower}) and column 2 is the upper bound
#'   (\code{obs_upper}) of the observed data envelope.  One row per time step
#'   or observation.
#' @param sim Numeric vector of simulated values, one entry per row of
#'   \code{obs}.
#'
#' @return A non-negative numeric scalar.  Returns \code{0} when all
#'   simulated values lie within their respective
#'   \code{[obs_lower, obs_upper]} bounds, and a large positive value
#'   otherwise (intended to be minimised as part of the calibration
#'   objective function).
#' @seealso \code{\link{min_max_likelihood}}
#' @export
#'
#' @examples
#' obs <- cbind(lower = c(10, 20, 30), upper = c(15, 25, 35))
#' sim <- c(12, 18, 40)   # 18 below lower[2], 40 above upper[3]
#' likelihood_function(obs, sim)
likelihood_function <- function(obs, sim) {
  output = -1e+6*sum(log(pmin((sim+1)/(obs[, 1]+1), 1)), na.rm=TRUE) +
    1e+6*sum(log(pmax((sim+1)/(obs[, 2]+1), 1)), na.rm=TRUE)
  return(output)
}
