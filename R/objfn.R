#' Atlantis calibration objective function
#'
#' A calibration objective function built by
#' \code{\link[calibrar]{calibration_objFn}} that wraps \code{\link{runModel}}
#' and the likelihood computation into a single callable used by
#' \code{\link[calibrar]{calibrate}}.
#'
#' Setting \code{aggregate = FALSE} means the function returns per-target
#' log-likelihood contributions as a named vector rather than a single scalar.
#' This enables phased calibration, where different parameter groups are
#' optimised in separate phases against their respective targets.
#'
#' The function closes over three objects that must exist in the calling
#' environment before \code{objfn} is constructed:
#' \describe{
#'   \item{\code{setup}}{Calibration setup object produced by
#'     \code{\link[calibrar]{calibrar_setup}}, defining which targets belong
#'     to which phase.}
#'   \item{\code{observed}}{Named list of observed data used to evaluate the
#'     likelihood at each iteration.}
#'   \item{\code{forcing}}{Data frame of parameter metadata with at minimum
#'     columns \code{paropt}, \code{parmin}, \code{parmax}, and
#'     \code{parphase}. Row names are used as parameter names.}
#' }
#'
#' @param par Numeric vector of parameters in the transformed (log) scale,
#'   passed directly to \code{\link{runModel}}.
#' @param ... Additional arguments forwarded to \code{\link{runModel}}.
#'
#' @return A named numeric vector of per-target log-likelihood contributions
#'   (one value per calibration target) when \code{aggregate = FALSE}.
#'   \code{\link[calibrar]{calibrate}} aggregates these internally during
#'   optimisation.
#' @export
#'
#' @examples
#' \dontrun{
#'   # Evaluate the objective function at the initial parameter values
#'   objfn(par = forcing[["paropt"]])
#' }
objfn <- calibrar::calibration_objFn(
  model    = runModel,
  setup    = setup,
  observed = observed,
  aggregate = FALSE,
  forcing  = forcing,
  names    = row.names(forcing)
)
