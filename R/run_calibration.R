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

  cl <- parallel::makeCluster(control$nCores)
  doSNOW::registerDoSNOW(cl)
  on.exit(parallel::stopCluster(cl), add = TRUE)

  # Objects required on each worker
  objfn_env <- environment(objfn)
  parallel::clusterExport(cl, varlist = c("control", "objfn", "forcing", "observed", "setup"),
                          envir = environment())

  # Export variables from objective function's closure
  # Extract variables from the function's closure and parent environments
  closure_vars <- list()
  env <- objfn_env

  while (!identical(env, emptyenv())) {
    for (var in names(env)) {
      if (!(var %in% names(closure_vars))) {
        tryCatch(
          closure_vars[[var]] <- get(var, envir = env, inherits = FALSE),
          error = function(e) NULL
        )
      }
    }
    env <- parent.env(env)
  }

  # Export the closure variables to the cluster
  if (length(closure_vars) > 0) {
    tmp_env <- list2env(closure_vars, parent = emptyenv())
    parallel::clusterExport(cl, varlist = names(closure_vars), envir = tmp_env)
  }

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
