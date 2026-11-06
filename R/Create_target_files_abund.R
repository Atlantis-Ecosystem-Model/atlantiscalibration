#' Create abundance-at-age target files and calibration settings from initial conditions
#'
#' Uses the initial abundance at age of each age-structured functional group
#' (the \code{<Group><age>_Nums} variables of the Atlantis initial conditions
#' NetCDF file, summed over boxes and layers) as a constant target for
#' \pkg{calibrar}, and writes all the files needed to set up an abundance
#' calibration:
#' \itemize{
#'   \item \code{data/<Group>_Nums.csv}: one target per group, with a
#'     \code{Time} column and one column per age class.  Age classes with
#'     zero abundance are set to \code{NA}.
#'   \item \code{calibration_settings_abund.csv}: calibration settings for
#'     each abundance target, using a multinomial likelihood.
#'   \item \code{abund.txt} and \code{abund_crash.txt}: R code snippets used
#'     to build the output list of the run model function, for a successful
#'     run and for a crashed run (all zeros), respectively.
#' }
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
#'   create_target_files_abund(
#'     init.file = here::here("inputs", "model_configuration", "AMPS_2024.nc")
#'   )
#' }
create_target_files_abund <- function(init.file,
                                      output.path = here::here("inputs"),
                                      dt.timeseries = 5){

  initial.condi <- ncdf4::nc_open(here::here("inputs","model_configuration",init.file))
  on.exit(ncdf4::nc_close(initial.condi))

  data.path <- file.path(output.path, "data")
  dir.create(data.path, showWarnings = FALSE, recursive = TRUE)

  ##################
  # Create data files
  ##################

  # Total numbers per age class, summed over boxes and layers
  nums.vars <- grep("_Nums$", names(initial.condi$var), value = TRUE)
  nums <- vapply(nums.vars, function(x) sum(ncdf4::ncvar_get(initial.condi, x), na.rm = TRUE),
                 numeric(1))

  group <- sub("[0-9]+_Nums$", "", nums.vars)
  age <- as.integer(sub("^.*?([0-9]+)_Nums$", "\\1", nums.vars))
  species <- unique(group)

  for (i in seq_along(species)){
    is.sp <- group == species[i]
    vector.abund <- nums[is.sp][order(age[is.sp])]
    vector.abund[vector.abund == 0] <- NA

    calibrar.format <- data.frame(Time = 1:dt.timeseries,
                                  matrix(rep(vector.abund, each = dt.timeseries),
                                         nrow = dt.timeseries))
    names(calibrar.format) <- c("Time", seq_along(vector.abund))

    utils::write.csv(calibrar.format, file.path(data.path, paste0(species[i], "_Nums.csv")),
                     row.names = FALSE)
  }

  ##################
  # Create calibration setting file
  ##################
  variable <- paste0(species, "_Nums")

  settings <- data.frame(
    variable = variable,
    type = "multinom",
    calibrate = TRUE,
    weight = 1,
    use_data = TRUE,
    file = paste0("data/", variable, ".csv"),
    varid = NA,
    col_skip = 1  # skip the Time column, keep all age classes
  )

  utils::write.csv(settings, file.path(output.path, "calibration_settings_abund.csv"),
                   row.names = FALSE)

  ##################
  # Create code for runModel function
  ##################
  R_code <- paste0(variable, ' = unname(unlist(atlantis.abundance["', species, '"])), ')
  writeLines(R_code, con = file.path(output.path, "abund.txt"))

  n.ages <- as.vector(table(group)[species])
  R_code <- paste0(variable, ' = matrix(0, nrow = ', dt.timeseries, ', ncol = ', n.ages, '), ')
  writeLines(R_code, con = file.path(output.path, "abund_crash.txt"))

  invisible(settings)
}
