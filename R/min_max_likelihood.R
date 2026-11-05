
#' Min-max likelihood penalty
#'
#' Penalises model predictions that fall outside the
#' \code{[obs_lower, obs_upper]} envelope defined in the observed data.
#' Predictions within the envelope incur no penalty; predictions below the
#' lower bound or above the upper bound are penalised proportionally to how
#' far they deviate, scaled by \code{1e6} to dominate the objective function.
#'
#' The penalty is computed as a log-ratio:
#' \deqn{-10^6 \sum \min\!\left(\log\frac{s+1}{l+1}, 0\right)
#'        + 10^6 \sum \max\!\left(\log\frac{s+1}{u+1}, 0\right)}
#' where \eqn{s} is the simulated value, \eqn{l} the lower bound, and
#' \eqn{u} the upper bound.  Adding 1 to numerator and denominator avoids
#' division by zero when values are near zero.
#'
#' @param obs Numeric matrix with two columns: column 1 is the lower bound
#'   (\code{obs_lower}) and column 2 is the upper bound (\code{obs_upper})
#'   of the observed data envelope.  One row per time step or observation.
#' @param sim Numeric vector of simulated values, one entry per row of
#'   \code{obs}.
#'
#' @return A non-negative scalar.  Returns \code{0} when all simulated values
#'   lie within their respective \code{[obs_lower, obs_upper]} bounds, and a
#'   large positive value otherwise (intended to be minimised as part of the
#'   calibration objective function).
#' @export
#'
#' @examples
#' \dontrun{
#'   obs <- cbind(lower = c(10, 20, 30), upper = c(15, 25, 35))
#'   sim <- c(12, 18, 40)   # 18 below lower[2], 40 above upper[3]
#'   min_max_likelihood(obs, sim)
#' }
min_max_likelihood <- function(obs, sim) {
  ratio <- (sim + 1) / (obs + 1)

  lower_penalty <- ratio[, 1] |> pmin(1) |> log() |> sum(na.rm = TRUE)
  upper_penalty <- ratio[, 2] |> pmax(1) |> log() |> sum(na.rm = TRUE)

  -1e6 * lower_penalty + 1e6 * upper_penalty
}
