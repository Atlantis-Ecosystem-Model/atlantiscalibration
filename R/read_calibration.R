#' Read calibration inputs and save the optimiser control settings
#'
#' Reads the calibration settings and observed targets with \pkg{calibrar},
#' reads the calibration parameters table, builds the objective function
#' with \code{\link{make_objfn}} and sets up the optimiser control list.
#' Writes the parameters to \code{inputs/forcing.csv} and the optimiser
#' control list to \code{inputs/control.rds}.
#'
#' @param calibration.settings Character.  Pattern to match calibration settings
#'   CSV files in \code{inputs} (e.g. \code{"calibration_settings_*.csv"}), as
#'   written by \code{\link{make_calsettings}}. All matching files are read and
#'   combined. Alternatively, a single filename for backward compatibility.
#' @param calibration.parameters Character.  Name of the calibration
#'   parameters CSV file in \code{inputs} (e.g.
#'   \code{"calibration-parameters-complete.csv"}), with parameter names in
#'   the first column.
#' @param n.Cores Integer.  Number of parallel workers, also used as the
#'   population size (number of model runs per generation).
#' @param master Character.  Directory with all the files needed to run
#'   Atlantis (model files and the \code{.sh} shell script).  It is copied to a run
#'   directory for each model run.
#' @param run Character.  Directory where the model runs are done.
#' @param restart.file Character.  Name of the restart file, used to restart
#'   an interrupted calibration and to save the results.
#' @param maxgen Integer.  Maximum number of generations (iterations) of the
#'   optimiser.  Default: \code{5}.
#' @param track.path Character.  Folder where the parameter files used in
#'   each run of each iteration are saved, as
#'   \code{iteration_<iteration>/run_<run>_<file>} (see
#'   \code{\link{keep_track_prm}}).  Set to \code{NULL} to not save them.
#'   Default: \code{outputs/keep_track_calibration}.
#' @param ... Arguments passed to \code{\link{run_model}} through
#'   \code{\link{make_objfn}} (\code{prefix}, \code{fg.file},
#'   \code{biom.indx}, \code{run.prm} and \code{dt.timeseries}).
#'
#' @return Invisibly, a named list with elements \code{setup},
#'   \code{observed}, \code{forcing}, \code{objfn} (see
#'   \code{\link{make_objfn}}) and \code{control}. The \code{control} element
#'   is a list containing optimiser settings including \code{REPORT}
#'   (number of iterations before saving), \code{parallel} (logical, enable
#'   parallel computing), and \code{trace} (verbosity level for global fitness
#'   and partial fitness output).  Also writes
#'   \code{inputs/forcing.csv} and \code{inputs/control.rds}.
#' @export
#'
#' @examples
#' \dontrun{
#'   calibration <- read_calibration(
#'     calibration.settings   = "calibration_settings_*.csv",
#'     calibration.parameters = "calibration-parameters-complete.csv",
#'     n.Cores      = 32,
#'     master       = "model_configuration/",
#'     run          = "RUN",
#'     restart.file = "restart_file",
#'     prefix = "outputFolder/outputSETAS", fg.file = "SETasGroupsDem.csv",
#'     biom.indx = "outputFolder/outputSETASBiomIndx.txt",
#'     run.prm = "VMPA_setas_run_fishing_F_Trunk.prm", dt.timeseries = 5)
#' }
read_calibration <- function(calibration.settings, calibration.parameters, n.Cores,
                             master, run, restart.file, maxgen = 5,
                             track.path = here::here("outputs", "keep_track_calibration"),
                             REPORT = 1, parallel = TRUE, no.trace = 3, ...){

   # Find and read all calibration settings files matching the pattern
   calibration_files <- list.files(here::here("inputs"),
                                   pattern = gsub("\\*", ".*", calibration.settings),
                                   full.names = FALSE)

   if(length(calibration_files) == 0){
     stop("No calibration settings files found matching pattern: ", calibration.settings)
   }

   # Read and combine all calibration settings files
   # Use flexible column specification since not all files have the same columns
   col_spec <- readr::cols(
     variable = readr::col_character(),
     type = readr::col_character(),
     calibrate = readr::col_logical(),
     weight = readr::col_double(),
     use_data = readr::col_logical(),
     file = readr::col_character(),
     varid = readr::col_character(),
     .default = readr::col_guess()
   )

   cal_settings_combined <- dplyr::bind_rows(
     lapply(calibration_files, function(f){
       readr::read_csv(here::here("inputs", f), col_types = col_spec)
     })
   )

   # Write combined settings to temporary file for calibrar
   temp_cal_file <- tempfile(pattern = "calibration_settings_", fileext = ".csv")
   readr::write_csv(cal_settings_combined, temp_cal_file)

   setup  <- calibrar::calibration_setup(file=temp_cal_file)

   # Clean up temporary file after setup is created
   unlink(temp_cal_file)

   observed <- calibrar::calibration_data(setup = setup,
                                         path=here::here("inputs"),
                                         file = NULL,
                                         sep = ",")


  # load calibration parameters
  forcing = utils::read.csv(file=here::here("inputs",calibration.parameters),
                            header=TRUE,
                            sep=",",
                            row.names=1)

  # keep the parameter names in the first column
  utils::write.csv(forcing, file=here::here("inputs","forcing.csv"))

  # create an objective function, with the arguments of the run model function
  # absolute path, so the model runs in the run directories can find it
  if (!is.null(track.path)){
    track.path <- normalizePath(track.path, mustWork = FALSE)
    dir.create(track.path, showWarnings = FALSE, recursive = TRUE)
  }

  objfn <- make_objfn(setup, observed, aggregate = FALSE, forcing, track.path = track.path, ...)

  control = list()
  control$maxit = maxgen   # maximum number of iterations (former gen.max parameter)
  control$maxgen = maxgen   # maximum number of iterations (former gen.max parameter)
  control$master = master   # directory that will be copied
  control$run = run   # run directory
  control$restart.file = restart.file   # name of the restart file
  control$REPORT = REPORT    # number of iterations to run before saving a restart
  control$parallel = parallel
  control$nCores = n.Cores
  control$popsize = n.Cores  # population  size (former seed parameter)
  control$trace = no.trace #global fitness and partial fitness

  saveRDS(control, file = here::here("inputs","control.rds"))

  invisible(list(setup = setup, observed = observed, forcing = forcing,
                 objfn = objfn, control = control))
}
