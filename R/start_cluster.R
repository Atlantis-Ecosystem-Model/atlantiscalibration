#' Start a parallel cluster and run the calibration
#'
#' Creates a cluster with \code{control$nCores} workers, exports the objects
#' and libraries each worker needs, runs the AHR-ES optimisation with
#' \code{\link[calibrar]{calibrate}} and stops the cluster.  Same as
#' \code{\link{run_calibration}}, except that the cluster is not stopped if
#' the optimisation fails.
#'
#' The function relies on \code{objfn}, \code{forcing}, \code{observed},
#' \code{setup} and \code{likelihood_function} being present in the calling
#' environment.
#'
#' @param control A named list of calibration control parameters passed to
#'   \code{\link[calibrar]{calibrate}}.  Must contain at minimum
#'   \code{nCores} (integer, number of parallel workers).
#'
#' @return Called for its side effect of running the calibration.  The result
#'   of \code{\link[calibrar]{calibrate}} is not returned.
#' @keywords internal
#'
#' @examples
#' \dontrun{
#'   start_cluster(control = list(nCores = 4, maxit = 5))
#' }
start_cluster <- function(control){

cl <- parallel::makeCluster(control$nCores)
doSNOW::registerDoSNOW(cl)

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

parallel::stopCluster(cl)
}
