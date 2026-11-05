#' Read calibration inputs and save the optimiser control settings
#'
#' Reads the calibration settings and observed targets with \pkg{calibrar},
#' reads the calibration parameters table, and builds the objective function
#' with \code{\link[calibrar]{calibration_objFn}}.  Writes the parameters to
#' \code{inputs/forcing.csv} and the optimiser control list to
#' \code{inputs/control.rds}.
#'
#' @param calibration.settings Character.  Name of the calibration settings
#'   CSV file in \code{inputs} (e.g. \code{"calibration_settings.csv"}), as
#'   written by \code{\link{make_calsettings}}.
#' @param calibration.parameters Character.  Name of the calibration
#'   parameters CSV file in \code{inputs} (e.g.
#'   \code{"calibration-parameters-complete.csv"}), with parameter names in
#'   the first column.
#'
#' @return Invisibly, a named list with elements \code{setup},
#'   \code{observed}, \code{forcing}, \code{objfn} (see
#'   \code{\link{make_objfn}}) and \code{control}.  Also writes
#'   \code{inputs/forcing.csv} and \code{inputs/control.rds}.
#' @export
#'
#' @examples
#' \dontrun{
#'   read_calibration(calibration.settings   = "calibration_settings.csv",
#'                    calibration.parameters = "calibration-parameters-complete.csv")
#' }
read_calibration <- function(calibration.settings, calibration.parameters){

   setup  <- calibrar::calibration_setup(file=here::here("inputs",calibration.settings))

   observed <- calibrar::calibration_data(setup = setup,
                                         path=here::here("inputs"),
                                         file = NULL,
                                         sep = ",")


  # load calibration parameters
  forcing = utils::read.csv(file=here::here("inputs",calibration.parameters),
                            header=TRUE,
                            sep=",",
                            row.names=1)

  readr::write_csv(forcing, file=here::here("inputs","forcing.csv"))

  # create an objective function
  objfn <- make_objfn(setup, observed, forcing)

  control = list()
  control$maxit = c(5)   # maximum number of iterations (former gen.max parameter)
  control$maxgen = c(5)   # maximum number of iterations (former gen.max parameter)
  control$master = "/home/atlantis/psatlantismodel/Atlantis_Calibration/configuration/"   # directory that will be copied
  control$run = "/home/atlantis/psatlantismodel/Atlantis_Calibration/RUN"   # run directory
  control$restart.file = "/home/atlantis/psatlantismodel/Atlantis_Calibration/restart_file"   # name of the restart file
  control$REPORT = 1    # number of iterations to run before saving a restart
  control$parallel = TRUE
  control$nCores = 32
  control$popsize = 32  # population  size (former seed parameter)
  control$trace = 3 #global fitness and partial fitness

  saveRDS(control, file = here::here("inputs","control.rds"))

  invisible(list(setup = setup, observed = observed, forcing = forcing,
                 objfn = objfn, control = control))
}

