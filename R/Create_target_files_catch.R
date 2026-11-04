#' Create catch target files and calibration settings from observed catch
#'
#' Sums observed catch by functional group and year, and uses the median
#' annual catch of each group as a constant target for \pkg{calibrar}.  Writes
#' all the files needed to set up a catch calibration:
#' \itemize{
#'   \item \code{data/<Name>_catch.csv}: one target time series per group,
#'     with columns \code{Time} and \code{Catch}.
#'   \item \code{calibration_settings_catch.csv}: calibration settings for
#'     each catch target.
#'   \item \code{catch.txt} and \code{catch_crash.txt}: R code snippets used
#'     to build the output list of the run model function, for a successful
#'     run and for a crashed run (all zeros), respectively.
#' }
#'
#' Fishing mortality parameters (\code{mfc}) are not created here; they are
#' written by \code{\link{create_target_files_biomass}}.
#'
#' @param catch.file Character.  Path to the observed catch CSV file.  Must
#'   contain the columns \code{Name}, \code{Code}, \code{year} and
#'   \code{catch_tons}.  Multiple rows per group and year (e.g. by fleet or
#'   area) are summed.
#' @param output.path Character.  Directory where output files are written.
#'   Target files are written to its \code{data} sub-directory, which is
#'   created if needed.  Default: \code{inputs}.
#' @param dt.timeseries Integer.  Number of time steps in each target time
#'   series.  Default: \code{5}.
#' @param weight Numeric.  Calibration weight given to each catch target.
#'   Default: \code{2}.
#' @param plot Logical.  If \code{TRUE}, plots the annual catch time series of
#'   each group, with its median as a horizontal line.  Default: \code{FALSE}.
#'
#' @return Invisibly, the calibration settings data frame.  Called for its
#'   side effect of writing files to \code{output.path}.
#' @export
#'
#' @examples
#' \dontrun{
#'   create_target_files_catch(
#'     catch.file = here::here("inputs", "PS_catch_2011-2019.csv"),
#'     plot       = TRUE
#'   )
#' }
create_target_files_catch <- function(catch.file,
                                      output.path = here::here("inputs"),
                                      dt.timeseries = 5,
                                      weight = 2,
                                      plot = FALSE,
                                      ){

  row_data <- readr::read_table(catch.file)

  cal.period.ts = dt.timeseries * 365

  data.path <- file.path(output.path, "data")
  dir.create(data.path, showWarnings = FALSE, recursive = TRUE)

  # Total annual catch per group
  total_catch_sp <- row_data |>
    dplyr::filter(Time <= cal.period.ts) |>
    dplyr::select(-dplyr::contains("TsArow")) |>
    tidyr::pivot_longer(cols = (-Time),
                        names_to = "Code", values_to = "catch_tons") |>
    dplyr::group_by(Code, year) |>
    dplyr::summarise(catch_tons = sum(catch_tons), .groups = "drop")

  species <- unique(total_catch_sp$Name)

  if (plot){
    old.par <- graphics::par(mfrow = c(4, 5), mar = c(2, 2, 2, 2))
    on.exit(graphics::par(old.par))
    for (i in species){
      a <- total_catch_sp[total_catch_sp$Name == i, ]
      plot(a$year, a$catch_tons, ylim = c(0, max(a$catch_tons)),
           main = unique(a$Code))
      graphics::abline(h = stats::median(a$catch_tons), lty = 2)
    }
  }

  ##################
  # Create data files
  ##################
  for (i in species){
    catch <- stats::median(total_catch_sp$catch_tons[total_catch_sp$Name == i])
    data <- data.frame(Time = 1:dt.timeseries, Catch = rep(catch, dt.timeseries))
    utils::write.csv(data, file.path(data.path, paste0(i, "_catch.csv")), row.names = FALSE)
  }

  ##################
  # Create calibration setting file
  ##################
  variable <- paste0(species, "_catch")

  settings <- data.frame(
    variable = variable,
    type = "lnorm2",
    calibrate = TRUE,
    weight = weight,
    use_data = TRUE,
    file = paste0("data/", variable, ".csv"),
    varid = "Catch"
  )

  utils::write.csv(settings, file.path(output.path, "calibration_settings_catch.csv"),
                   row.names = FALSE)

  ##################
  # Create code for runModel function
  ##################
  R_code <- paste0(variable, ' = unname(unlist(atlantis.catch["', species, '"])), ')
  writeLines(R_code, con = file.path(output.path, "catch.txt"))

  R_code <- paste0(variable, ' = rep(0,', dt.timeseries, '), ')
  writeLines(R_code, con = file.path(output.path, "catch_crash.txt"))

  invisible(settings)
}
