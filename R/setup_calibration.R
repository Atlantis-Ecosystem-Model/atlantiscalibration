#' Set up initial calibration configuration
#'
#' Wrapper function that performs all initial calibration setup steps in sequence.
#' By default, reads all settings from \code{inputs/settings_file.txt}, but
#' individual parameters can be overridden by passing them as arguments.
#'
#' \enumerate{
#'   \item Verifies and displays the shell script configuration
#'   \item Reads reproduction options from the biology parameter file
#'   \item Reads and validates the parameter table
#'   \item Updates forcing file paths to absolute paths
#'   \item Creates calibration settings and target files
#' }
#'
#' @param fg.file Character. Name of the functional groups CSV file in
#'   \code{inputs/model_configuration}. If \code{NULL}, read from settings file.
#' @param biology.prm Character. Name of the Atlantis biology parameter file in
#'   \code{inputs/model_configuration}. If \code{NULL}, read from settings file.
#' @param parameter.file Character. Name of the parameter table CSV file in
#'   \code{inputs/}. If \code{NULL}, read from settings file.
#' @param var.type Character vector. Target types to calibrate: any of
#'   \code{"biomass"}, \code{"weight"}, \code{"abundance"} and \code{"catch"}.
#'   If \code{NULL}, read from settings file.
#' @param fun.type Character. Calibrar package likelihood function for calibration.
#'   If \code{NULL}, read from settings file.
#' @param dt.timeseries Integer. Number of time steps in each target time series.
#'   If \code{NULL}, read from settings file.
#' @param w.vector Data frame. Optional custom weights with columns \code{"Code"}
#'   and \code{"weight_new"}. If \code{NULL}, default weights are used.
#' @param init.file Character. Name of the Atlantis initial conditions NetCDF
#'   file, used to create weight-at-age and abundance targets.
#'   If \code{NULL}, read from settings file.
#' @param catch.file Character. Name of the observed catch CSV file, used to
#'   create catch targets. If \code{NULL}, read from settings file.
#' @param run.prm Character. Name of the Atlantis run parameter file in
#'   \code{inputs/model_configuration/}. If \code{NULL}, read from settings file.
#' @param settings.file Character. Path to the calibration settings file.
#'   Defaults to \code{inputs/settings_file.txt}.
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
#' \code{\link{setup_forcing_paths}}, \code{\link{make_calsettings}}, \code{\link{read_settings}}
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   # Use default settings from inputs/settings_file.txt
#'   setup_calibration()
#'
#'   # Or override specific parameters
#'   setup_calibration(
#'     var.type      = c("biomass", "weight"),
#'     fun.type      = "lnorm2"
#'   )
#' }
setup_calibration <- function(fg.file = NULL,
                              biology.prm = NULL,
                              parameter.file = NULL,
                              var.type = NULL,
                              fun.type = NULL,
                              dt.timeseries = NULL,
                              w.vector = NULL,
                              init.file = NULL,
                              catch.file = NULL,
                              run.prm = NULL,
                              settings.file = NULL,
                              pkg_path = NULL) {

  # If settings.file not provided, use default location
  if (is.null(settings.file)) {
    settings.file <- here::here("inputs", "settings_file.txt")
  }

  if (!file.exists(settings.file)) {
    stop("Settings file not found: ", settings.file, "\n",
         "Make sure you have inputs/settings_file.txt in your project directory.")
  }

  # Read settings from file into calling environment AND temporary environment
  read_settings(settings.file, envir = parent.frame())

  # Also load into temporary environment for validation
  settings_env <- new.env()
  read_settings(settings.file, envir = settings_env)

  # Use provided arguments, or fall back to settings file values
  if (is.null(fg.file)) {
    fg.file <- tryCatch(settings_env$fg.file, error = function(e) NULL)
    if (is.null(fg.file)) stop("fg.file not found in settings file or provided as argument")
  }
  if (is.null(biology.prm)) {
    biology.prm <- tryCatch(settings_env$biology.prm, error = function(e) NULL)
    if (is.null(biology.prm)) stop("biology.prm not found in settings file or provided as argument")
  }
  if (is.null(parameter.file)) {
    parameter.file <- tryCatch(settings_env$parameter.file, error = function(e) NULL)
    if (is.null(parameter.file)) parameter.file <- "parameter_table.csv"
  }
  if (is.null(var.type)) {
    var.type <- tryCatch(settings_env$var.type, error = function(e) NULL)
    if (is.null(var.type)) stop("var.type not found in settings file or provided as argument")
  }
  if (is.null(fun.type)) {
    fun.type <- tryCatch(settings_env$fun.type, error = function(e) NULL)
    if (is.null(fun.type)) stop("fun.type not found in settings file or provided as argument")
  }
  if (is.null(dt.timeseries)) {
    dt.timeseries <- tryCatch(settings_env$dt.timeseries, error = function(e) NULL)
    if (is.null(dt.timeseries)) stop("dt.timeseries not found in settings file or provided as argument")
  }
  if (is.null(init.file)) {
    init.file <- tryCatch(settings_env$init.file, error = function(e) NULL)
    if (is.null(init.file)) stop("init.file not found in settings file or provided as argument")
  }
  if (is.null(catch.file)) {
    catch.file <- tryCatch(settings_env$catch.file, error = function(e) NULL)
    if (is.null(catch.file)) stop("catch.file not found in settings file or provided as argument")
  }
  if (is.null(run.prm)) {
    run.prm <- tryCatch(settings_env$run.prm, error = function(e) NULL)
    if (is.null(run.prm)) stop("run.prm not found in settings file or provided as argument")
  }

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
