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
#' @param fg.file Character.  Name of the functional groups CSV file in
#'   \code{inputs/model_configuration}.  Must contain the columns \code{Code}
#'   and \code{Name}.
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
#'     fg.file    = "PugetSoundAtlantisFunctionalGroups_2024.csv",
#'     plot       = TRUE
#'   )
#' }
create_target_files_catch <- function(catch.file, fg.file,
                                      output.path = here::here("inputs"),
                                      dt.timeseries = 5,
                                      weight = 2,
                                      plot = FALSE){

  row.data <- readr::read_csv(here::here("inputs","model_configuration",catch.file))
  fg.groups <- readr::read_csv(here::here("inputs","model_configuration",fg.file))

  data.path <- file.path(output.path, "data")
  dir.create(data.path, showWarnings = FALSE, recursive = TRUE)

  # Total annual catch per group
  total.catch.sp <- row.data |>
    dplyr::left_join(fg.groups, by ="Code")

  species <- unique(total.catch.sp$Name)

  if (plot){

   median.catch <- total.catch.sp |>
      dplyr::group_by(Code) |>
      dplyr::filter(max(Catch) > 0) |>
      dplyr::summarise(Catch = stats::median(Catch), .groups = "drop")

    # Only plot groups with catch
    plot.data <- total.catch.sp |>
      dplyr::filter(Code %in% median.catch$Code)

    catch.plot <- ggplot2::ggplot(plot.data,
                                  ggplot2::aes(x = Year, y = Catch)) +
      ggplot2::geom_point() +
      ggplot2::geom_hline(data = median.catch,
                          ggplot2::aes(yintercept = Catch),
                          linetype = "dashed") +
      ggplot2::facet_wrap(~ Code, scales = "free_y") +
      ggplot2::expand_limits(y = 0) +
      ggplot2::labs(x = "Year", y = "Catch",
                    subtitle = "Only groups with catch in at least one year are shown") +
      ggplot2::theme_bw()

    plot.path <- here::here("outputs")
    dir.create(plot.path, showWarnings = FALSE, recursive = TRUE)
    ggplot2::ggsave(file.path(plot.path, "calibration_catch_timeseries.pdf"), catch.plot,
                    width = 11, height = 8.5)
  }

  ##################
  # Create data files
  ##################
  for (i in species){
    catch <- stats::median(total.catch.sp$Catch[total.catch.sp$Name == i])
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

  R_code <- paste0(variable, ' = unname(unlist(atlantis.catch["', species, '"])), ')
  writeLines(R_code, con = file.path(output.path, "catch.txt"))

  R_code <- paste0(variable, ' = rep(0,', dt.timeseries, '), ')
  writeLines(R_code, con = file.path(output.path, "catch_crash.txt"))

  invisible(settings)
}
