#' Set up initial calibration configuration
#'
#' Wrapper function that performs all initial calibration setup steps in sequence:
#' \enumerate{
#'   \item Verifies and displays the shell script configuration
#'   \item Reads reproduction options from the biology parameter file
#'   \item Reads and validates the parameter table
#'   \item Updates forcing file paths to absolute paths
#'   \item Creates calibration settings and target files
#' }
#'
#' @param fg.file Character. Name of the functional groups CSV file in
#'   \code{inputs/model_configuration}.
#' @param biology.prm Character. Name of the Atlantis biology parameter file in
#'   \code{inputs/model_configuration}.
#' @param parameter.file Character. Name of the parameter table CSV file in
#'   \code{inputs/}. Default: \code{"parameter_table.csv"}.
#' @param var.type Character vector. Target types to calibrate: any of
#'   \code{"biomass"}, \code{"weight"}, \code{"abundance"} and \code{"catch"}.
#' @param fun.type Character. Calibrar package likelihood function for calibration.
#' @param dt.timeseries Integer. Number of time steps in each target time series.
#' @param w.vector Data frame. Optional custom weights with columns \code{"Code"}
#'   and \code{"weight_new"}. If \code{NULL}, default weights are used.
#' @param biom.indx Character. Name of the Atlantis biomass index output file
#'   (\code{<prefix>_OUTBiomIndx.txt}), used to create biomass targets.
#' @param init.file Character. Name of the Atlantis initial conditions NetCDF
#'   file, used to create weight-at-age and abundance targets.
#' @param catch.file Character. Name of the observed catch CSV file, used to
#'   create catch targets.
#' @param run.prm Character. Name of the Atlantis run parameter file in
#'   \code{inputs/model_configuration/}.
#' @param pkg_path Character. Optional path to the atlantiscalibration package
#'   directory. If \code{NULL} (default), uses \code{here::here()} to find the
#'   project root.
#'
#' @return Invisibly returns a list with the results of each setup step:
#'   \item{reproduction_options}{Data frame of reproduction options}
#'   \item{parameter_table}{Data frame of calibration parameters}
#'   \item{forcing_paths}{Data frame of updated forcing paths}
#'   \item{calsettings}{Result from make_calsettings()}
#'
#' @details
#' This is a convenience wrapper that combines five setup steps:
#' \enumerate{
#'   \item \code{\link{read_sh_file}} - Verifies and displays shell script configuration
#'   \item \code{\link{repro_option}} - Creates \code{inputs/reproduction-option.csv}
#'   \item \code{\link{read_parameter_table}} - Reads and validates parameters
#'   \item \code{\link{setup_forcing_paths}} - Updates all forcing file paths
#'   \item \code{\link{make_calsettings}} - Creates calibration settings and targets
#' }
#'
#' @seealso
#' \code{\link{read_sh_file}}, \code{\link{repro_option}}, \code{\link{read_parameter_table}},
#' \code{\link{setup_forcing_paths}}, \code{\link{make_calsettings}}
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   setup_calibration(
#'     fg.file       = "SETasGroupsDem.csv",
#'     biology.prm   = "VMPA_setas_biol_fishing_Trunk.prm",
#'     parameter.file = "parameter_table.csv",
#'     var.type      = c("biomass", "weight"),
#'     fun.type      = "lnorm2",
#'     dt.timeseries = 5,
#'     biom.indx     = "outputSETASBiomIndx.txt",
#'     init.file     = "INIT_VMPA_Jan2015.nc",
#'     catch.file    = "catch_timeseries.csv",
#'     run.prm       = "VMPA_setas_run_fishing_F_Trunk.prm"
#'   )
#' }
setup_calibration <- function(fg.file,
                              biology.prm,
                              parameter.file = "parameter_table.csv",
                              var.type,
                              fun.type,
                              dt.timeseries,
                              w.vector = NULL,
                              biom.indx,
                              init.file,
                              catch.file,
                              run.prm,
                              pkg_path = NULL) {

  message(paste(rep("=", 70), collapse = ""))
  message("Step 1: Verifying shell script configuration...")
  message(paste(rep("=", 70), collapse = ""))
  sh_config <- read_sh_file(here::here("inputs", "model_configuration"))
  message("Shell script: ", sh_config$sh.file)
  message("Configuration files:")
  for (opt in names(sh_config$files)) {
    message("  -", opt, " : ", sh_config$files[[opt]])
  }

  message("")
  message(paste(rep("=", 70), collapse = ""))
  message("Step 2: Reading reproduction options...")
  message(paste(rep("=", 70), collapse = ""))
  repro_option(fg.file, biology.prm)

  message("")
  message(paste(rep("=", 70), collapse = ""))
  message("Step 3: Reading parameter table...")
  message(paste(rep("=", 70), collapse = ""))
  parameter_table <- read_parameter_table(parameter.file)
  print(head(parameter_table))

  message("")
  message(paste(rep("=", 70), collapse = ""))
  message("Step 4: Setting up forcing file paths...")
  message(paste(rep("=", 70), collapse = ""))
  forcing_paths <- setup_forcing_paths(pkg_path = pkg_path)

  message("")
  message(paste(rep("=", 70), collapse = ""))
  message("Step 5: Creating calibration settings...")
  message(paste(rep("=", 70), collapse = ""))
  make_calsettings(
    fg.file       = fg.file,
    var.type      = var.type,
    fun.type      = fun.type,
    dt.timeseries = dt.timeseries,
    w.vector      = w.vector,
    biology.prm   = biology.prm,
    biom.indx     = biom.indx,
    init.file     = init.file,
    catch.file    = catch.file,
    run.prm       = run.prm,
    parameter.file = parameter.file
  )

  message("")
  message(paste(rep("=", 70), collapse = ""))
  message("Calibration setup complete!")
  message(paste(rep("=", 70), collapse = ""))

  return(invisible(list(
    reproduction_options = NULL,
    parameter_table = parameter_table,
    forcing_paths = forcing_paths
  )))
}
