#' Build the Atlantis calibration objective function
#'
#' Creates the calibration objective function with
#' \code{\link[calibrar]{calibration_objFn}}, wrapping \code{\link{run_model}}
#' and the likelihood computation into a single callable used by
#' \code{\link[calibrar]{calibrate}}.
#'
#' Setting \code{aggregate = FALSE} means the objective function returns
#' per-target log-likelihood contributions as a named vector rather than a
#' single scalar.  This enables phased calibration, where different parameter
#' groups are optimised in separate phases against their respective targets.
#'
#' @param setup Calibration setup object produced by
#'   \code{\link[calibrar]{calibration_setup}}, defining which targets belong
#'   to which phase.
#' @param observed Named list of observed data used to evaluate the
#'   likelihood at each iteration, produced by
#'   \code{\link[calibrar]{calibration_data}}.
#' @param forcing Data frame of parameter metadata with at minimum columns
#'   \code{paropt}, \code{parmin}, \code{parmax}, and \code{parphase}.  Row
#'   names are used as parameter names.
#'
#' @return The objective function.  It takes \code{par}, a numeric vector of
#'   parameters in the transformed (log) scale, plus additional arguments
#'   forwarded to \code{\link{run_model}}, and returns a named numeric vector
#'   of per-target log-likelihood contributions.
#' @export
#'
#' @examples
#' \dontrun{
#'   objfn <- make_objfn(setup, observed, forcing)
#'   # Evaluate the objective function at the initial parameter values
#'   objfn(par = forcing[["paropt"]])
#' }
make_objfn <- function(setup, observed, forcing){
  calibrar::calibration_objFn(
    model    = run_model,
    setup    = setup,
    observed = observed,
    aggregate = FALSE,
    forcing  = forcing,
    names    = row.names(forcing)
  )
}
