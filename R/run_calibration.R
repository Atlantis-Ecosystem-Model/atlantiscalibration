#' Run the Atlantis model calibration
#'
#' Sets up a parallel cluster, exports the required objects and libraries to
#' each worker, and runs the AHR-ES optimisation algorithm via
#' \code{\link[calibrar]{calibrate}}.  The cluster is stopped on exit
#' regardless of whether optimisation succeeds or fails.
#'
#' @param calibration Named list returned by \code{\link{read_calibration}},
#'   with elements \code{setup}, \code{observed}, \code{forcing} (data frame
#'   with columns \code{paropt}, \code{parmin}, \code{parmax} and
#'   \code{parphase}), \code{objfn} (the objective function) and
#'   \code{control} (control parameters passed to
#'   \code{\link[calibrar]{calibrate}}, with at minimum \code{nCores}).
#'
#' @return The object returned by \code{\link[calibrar]{calibrate}}: a list
#'   with the optimised parameter vector, objective function value, and
#'   convergence diagnostics.  The results are also saved by \pkg{calibrar}
#'   in \code{<control$restart.file>.results}.
#' @export
#'
#' @examples
#' \dontrun{
#'   calibration <- read_calibration(...)
#'   result <- run_calibration(calibration)
#' }
run_calibration <- function(calibration){

  control  <- calibration$control
  objfn    <- calibration$objfn
  forcing  <- calibration$forcing
  observed <- calibration$observed
  setup    <- calibration$setup

  # creates a user defined likelihood function
  minmaxt = function(obs, sim) {
    output = -1e+6*sum(log(pmin((sim+1)/(obs[, 1]+1), 1)), na.rm=TRUE) +
      1e+6*sum(log(pmax((sim+1)/(obs[, 2]+1), 1)), na.rm=TRUE)
    return(output)
  }

  # call the RMPI/Snow make cluster (note here that there are no arguments!)
  NumberOfCluster <- control$nCores
  cl <-  parallel::makeCluster(NumberOfCluster)

  # call the registerDoSNOW function instead of the registerDoParallel
  doSNOW::registerDoSNOW (cl)

  # send the variables and loaded libraries defined in the above to the nodes
  parallel::clusterExport(cl, c("control","objfn", "forcing", "observed", "setup", "minmaxt"), envir = environment())
  parallel::clusterEvalQ(cl, library("atlantiscalibration"))
  parallel::clusterEvalQ(cl, library("calibrar"))
  parallel::clusterEvalQ(cl, library("stringr"))

  # run the calibration

  lbfgsb1 = calibrar::calibrate(par=forcing['paropt'], fn=objfn,
                                method='AHR-ES',
                                lower=forcing['parmin'],
                                upper=forcing['parmax'],
                                phases=forcing['parphase'],
                                control=control, parallel = TRUE)

  # stop the cluster
  parallel::stopCluster(cl)


  return(lbfgsb1)

}
