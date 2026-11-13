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
#' @param aggregate Logical. If \code{FALSE} (default), the objective function
#'   returns per-target log-likelihood contributions as a named vector, enabling
#'   phased calibration where different parameter groups are optimised separately.
#'   If \code{TRUE}, returns a single aggregated scalar value.
#' @param forcing Data frame of parameter metadata with at minimum columns
#'   \code{paropt}, \code{parmin}, \code{parmax}, and \code{parphase}.  Row
#'   names are used as parameter names.
#' @param ... Arguments passed to \code{\link{run_model}} at every run:
#'   \code{prefix}, \code{fg.file}, \code{biom.indx}, \code{run.prm} and
#'   \code{dt.timeseries}.  The shell script and the biology and harvest
#'   parameter files are found by \code{\link{run_model}} itself.
#'
#' @return The objective function.  It takes \code{par}, a numeric vector of
#'   parameters in the transformed (log) scale, and returns a named numeric
#'   vector of per-target log-likelihood contributions.
#' @export
#'
#' @examples
#' \dontrun{
#'   objfn <- make_objfn(setup, observed, forcing,
#'                       prefix = "outputFolder/outputSETAS",
#'                       fg.file = "SETasGroupsDem.csv",
#'                       biom.indx = "outputFolder/outputSETASBiomIndx.txt",
#'                       run.prm = "VMPA_setas_run_fishing_F_Trunk.prm",
#'                       dt.timeseries = 5)
#'   # Evaluate the objective function at the initial parameter values
#'   objfn(par = forcing[["paropt"]])
#' }
make_objfn <- function(setup, observed, aggregate=FALSE, forcing, ...){
  calibrar::calibration_objFn(
    model     = run_model,
    setup     = setup,
    observed  = observed,
    aggregate = aggregate,
    forcing   = forcing,
    names     = row.names(forcing),
    variables = setup$variable,
    ...
  )

 }
