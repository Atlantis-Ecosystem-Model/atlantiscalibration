#' Create weight-at-age target files and calibration settings from initial conditions
#'
#' Uses the initial individual weight of each age class (cohort) as a constant
#' target for \pkg{calibrar}.  The weight is calculated from the
#' \code{_FillValue} attribute of the \code{<Cohort>_ResN} and
#' \code{<Cohort>_StructN} variables of the Atlantis initial conditions NetCDF
#' file as \eqn{(ResN + StructN) \times 20 \times 5.7 / 10^6}, which converts
#' mg N per individual to tonnes wet weight.  Writes all the files needed to set
#' up a weight-at-age calibration:
#' \itemize{
#'   \item \code{data/<Cohort>_w.csv}: one target time series per cohort,
#'     with columns \code{Time} and \code{Weight}.
#'   \item \code{calibration_settings_waa.csv}: calibration settings for each
#'     weight-at-age target.
#'   \item \code{Waa.txt} and \code{Waa_crash.txt}: R code snippets used to
#'     build the output list of the run model function, for a successful run
#'     and for a crashed run (all zeros), respectively.
#' }
#'
#' A warning lists any cohorts with an initial weight of zero.
#'
#' @param init.file Character.  Path to the Atlantis initial conditions
#'   NetCDF file.
#' @param output.path Character.  Directory where output files are written.
#'   Target files are written to its \code{data} sub-directory, which is
#'   created if needed.  Default: \code{inputs}.
#' @param dt.timeseries Integer.  Number of time steps in each target time
#'   series.  Default: \code{5}.
#'
#' @return Invisibly, the calibration settings data frame.  Called for its
#'   side effect of writing files to \code{output.path}.
#' @export
#'
#' @examples
#' \dontrun{
#'   create_target_files_waa(
#'     init.file = here::here("inputs", "model_configuration", "AMPS_2024.nc")
#'   )
#' }
create_target_files_waa <- function(init.file,
                                    output.path = here::here("inputs"),
                                    dt.timeseries = 5){

  initial.condi <- ncdf4::nc_open(here::here("inputs","model_configuration",init.file))
  on.exit(ncdf4::nc_close(initial.condi))

  data.path <- file.path(output.path, "data")
  dir.create(data.path, showWarnings = FALSE, recursive = TRUE)

  ##################
  # Create data files
  ##################
  var <- names(initial.condi$var)
  get_fill <- function(x) ncdf4::ncatt_get(initial.condi, x)$`_FillValue`

  # Cohorts are identified from the reserve nitrogen variables
  cohort <- sub("_ResN$", "", grep("_ResN$", var, value = TRUE))

  list.weight <- vapply(cohort, function(x)
    (get_fill(paste0(x, "_ResN")) + get_fill(paste0(x, "_StructN"))) * 20 * 5.7 / 1e6,
    numeric(1))

  if (any(list.weight == 0)){
    warning("Initial weight is zero for: ",
            paste(cohort[list.weight == 0], collapse = ", "))
  }

  variable <- paste0(cohort, "_w")

  for (i in seq_along(cohort)){
    data <- data.frame(Time = 1:dt.timeseries, Weight = rep(list.weight[i], dt.timeseries))
    utils::write.csv(data, file.path(data.path, paste0(variable[i], ".csv")), row.names = FALSE)
  }

  ##################
  # Create calibration setting file
  ##################
  settings <- data.frame(
    variable = variable,
    type = "lnorm2",
    calibrate = TRUE,
    weight = 1,
    use_data = TRUE,
    file = paste0("data/", variable, ".csv"),
    varid = "Weight"
  )

  utils::write.csv(settings, file.path(output.path, "calibration_settings_waa.csv"),
                   row.names = FALSE)

  ##################
  # Create code for runModel function
  ##################
  # Add a blank line after the last cohort of each group
  group <- sub("[0-9]+$", "", cohort)
  last.cohort <- c(group[-1] != group[-length(group)], TRUE)

  R_code <- paste0(variable, ' = unname(unlist(atlantis.meanSizeByAge["', cohort, '"])),',
                   ifelse(last.cohort, " \n", ""))
  writeLines(R_code, con = file.path(output.path, "Waa.txt"))

  R_code <- paste0(variable, ' = rep(0,', dt.timeseries, '), ')
  writeLines(R_code, con = file.path(output.path, "Waa_crash.txt"))

  invisible(settings)
}
