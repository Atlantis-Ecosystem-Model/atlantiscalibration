#' Run the Atlantis model calibration
#'
#' Sets up a parallel cluster, exports the required objects and libraries to
#' each worker, and runs the AHR-ES optimisation algorithm via
#' \code{\link[calibrar]{calibrate}}.  The cluster is stopped on exit
#' regardless of whether optimisation succeeds or fails.
#'
#' The function relies on several objects being present in the calling
#' environment: \code{objfn} (the objective function), \code{forcing}
#' (a list with elements \code{paropt}, \code{parmin}, \code{parmax}, and
#' \code{parphase}), \code{observed} (calibration targets), \code{setup},
#' and \code{likelihood_function}.
#'
#' @param control A named list of calibration control parameters passed to
#'   \code{\link[calibrar]{calibrate}}.  Must contain at minimum
#'   \code{nCores} (integer, number of parallel workers).
#'
#' @return The object returned by \code{\link[calibrar]{calibrate}}: a list
#'   with the optimised parameter vector, objective function value, and
#'   convergence diagnostics.
#' @export
#'
#' @examples
#' \dontrun{
#'   ctrl <- list(nCores = 4, maxIter = 500)
#'   result <- run_calibration(control = ctrl)
#' }
run_calibration <- function(control){

  cl <- parallel::makeCluster(control$nCores)
  doSNOW::registerDoSNOW(cl)
  on.exit(parallel::stopCluster(cl), add = TRUE)

  # Objects required on each worker
  parallel::clusterExport(cl, varlist = c("control", "objfn", "forcing", "observed",
                                          "setup",   "likelihood_function"))

  # Libraries required on each worker
  for (pkg in c("atlantiscalibration", "calibrar", "stringr")){
    parallel::clusterCall(cl, library, pkg, character.only = TRUE)
  }


  lbfgsb1 <- calibrar::calibrate(
    par     = forcing[["paropt"]],
    fn      = objfn,
    method  = "AHR-ES",
    lower   = forcing[["parmin"]],
    upper   = forcing[["parmax"]],
    phases  = forcing[["parphase"]],
    control = control,
    parallel = TRUE
  )

  lbfgsb1
}
