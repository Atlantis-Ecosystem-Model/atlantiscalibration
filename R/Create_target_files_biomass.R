#' Create biomass target files and calibration inputs from initial conditions
#'
#' Uses the initial biomass of each functional group (first time step of the
#' Atlantis \code{<prefix>_OUTBiomIndx.txt} output) as a constant target for
#' \pkg{calibrar}, and writes all the files needed to set up a biomass
#' calibration:
#' \itemize{
#'   \item \code{data/<Code>_biomass.csv}: one target time series per
#'     calibrated group, with columns \code{Time} and \code{Biomass}.
#'   \item \code{calibration_settings.csv}: calibration settings for each
#'     biomass target.
#'   \item \code{calibration-parameters-complete.csv}: parameter factors to
#'     estimate (\code{mum}, \code{BHalpha}, \code{KDENR}, \code{mfc} and
#'     \code{mQ}), with initial values, bounds and phase.
#'   \item \code{biomass.txt} and \code{biomass_crash.txt}: R code snippets
#'     used to build the output list of the run model function, for a
#'     successful run and for a crashed run (all zeros), respectively.
#' }
#'
#' \code{BHalpha} factors are created for groups whose \code{flagrecruit} is
#' not 12, \code{KDENR} factors for groups whose \code{flagrecruit} is 12, and
#' \code{mfc} factors for groups with \code{IsFished == 1}.
#'
#' If \code{unfished = TRUE}, targets are created for an unfished scenario
#' instead: only fished groups (\code{IsFished == 1}) are included, and their
#' initial biomass is multiplied by \code{factor.unfished}.  Outputs are
#' written with an \code{_unfished} suffix so they do not overwrite the
#' standard biomass calibration files: targets go to \code{data_unfished/},
#' and the other files are \code{calibration_settings_unfished.csv},
#' \code{calibration-parameters-unfished.csv}, \code{biomass_unfished.txt}
#' and \code{biomass_unfished_crash.txt}.  \code{mfc} factors are not created
#' in this case, as fishing is turned off.
#'
#' @param biom.indx Character.  Path to the Atlantis biomass index text file
#'   (\code{<prefix>_OUTBiomIndx.txt}).
#' @param fg.file Character.  Path to the functional groups CSV file.  Must
#'   contain the columns \code{Code}, \code{Name} and \code{IsFished}.
#' @param repro.file Character.  Path to the reproduction option CSV file with
#'   columns \code{Code} and \code{flagrecruit}, as written by
#'   \code{repro_option}.  Default: \code{inputs/reproduction-option.csv}.
#' @param output.path Character.  Directory where output files are written.
#'   Target time series are written to its \code{data} sub-directory, which
#'   is created if needed.  Default: \code{inputs}.
#' @param not.calibrated Character vector.  Codes of functional groups to
#'   exclude from calibration.  Default:
#'   \code{c("PS", "PL", "DC", "DL", "DR")}.
#' @param dt.timeseries Integer.  Number of time steps in each target time
#'   series.  Default: \code{5}.
#' @param mq.groups Character vector.  Codes of the groups for which an
#'   \code{mQ} factor is calibrated.  Default: \code{c("ZS", "ZM", "ZL")}.
#' @param unfished Logical.  If \code{TRUE}, create targets for an unfished
#'   scenario (see Details).  Default: \code{FALSE}.
#' @param factor.unfished Numeric.  Factor applied to the initial biomass of
#'   fished groups to obtain the unfished biomass target.  Only used when
#'   \code{unfished = TRUE}.  Default: \code{1.3}.
#'
#' @return Invisibly, a named list with elements \code{settings} (calibration
#'   settings data frame) and \code{parameters} (calibration parameters data
#'   frame).  Called for its side effect of writing files to
#'   \code{output.path}.
#' @export
#'
#' @examples
#' \dontrun{
#'   create_target_files_biomass(
#'     biom.indx = "path/to/outputs/AMPS_OUTBiomIndx.txt",
#'     fg.file   = "path/to/PugetSoundAtlantisFunctionalGroups_2024.csv"
#'   )
#'
#'   # Unfished scenario
#'   create_target_files_biomass(
#'     biom.indx     = "path/to/outputs/AMPS_OUTBiomIndx.txt",
#'     fg.file       = "path/to/PugetSoundAtlantisFunctionalGroups_2024.csv",
#'     unfished      = TRUE
#'   )
#' }
create_target_files_biomass <- function(biom.indx, fg.file,
                                        repro.file = here::here("inputs", "reproduction-option.csv"),
                                        output.path = here::here("inputs"),
                                        not.calibrated = c("PS", "PL", "DC", "DL", "DR"),
                                        dt.timeseries = 5,
                                        mq.groups = c("ZS", "ZM", "ZL"),
                                        unfished = FALSE,
                                        factor.unfished = 1.3){

  config <- readr::read_csv(here::here("inputs","model_configuration", fg.file))
  biom.data <- data.table::fread(here::here("inputs","model_configuration","outputFolder",biom.indx), header = TRUE, check.names = FALSE)
  repro.option <- utils::read.csv(here::here("inputs",repro.file))

  # Suffix for output files, so unfished outputs do not overwrite standard ones
  suffix <- if (unfished) "_unfished" else ""
  data.dir <- paste0("data", suffix)

  data.path <- file.path(output.path, data.dir)
  dir.create(data.path, showWarnings = FALSE, recursive = TRUE)

  # Define who is calibrated
  config$IsCalibrated <- as.integer(!config$Code %in% not.calibrated)

  ##################
  # Create data files
  ##################

  # Initial biomass is the first time step of the biomass index
  Bio.ini <- biom.data[1, ] |>
    dplyr::select(-dplyr::contains("Rel"), -Time) |>
    tidyr::pivot_longer(cols = dplyr::everything(),
                        names_to = "Code", values_to = "Ini") |>
    dplyr::mutate(Ini = round(as.numeric(Ini)))

  Bio.ini <- merge(Bio.ini, config[, c("Code", "Name", "IsCalibrated", "IsFished")], by = "Code")
  Bio.ini <- Bio.ini[Bio.ini$IsCalibrated == 1, ]
  Bio.ini$Biomass <- Bio.ini$Ini

  # Unfished scenario: only fished groups, with scaled initial biomass
  if (unfished){
    Bio.ini <- Bio.ini[Bio.ini$IsFished == 1, ]
    Bio.ini$Biomass <- Bio.ini$Ini * factor.unfished
  }

  for (i in seq_along(Bio.ini$Code)){
    data <- data.frame(Time = 1:dt.timeseries, Biomass = rep(Bio.ini$Biomass[i], dt.timeseries))
    utils::write.csv(data, file.path(data.path, paste0(Bio.ini$Code[i], "_biomass.csv")), row.names = FALSE)
  }

  ##################
  # Create calibration setting file
  ##################
  variable <- paste0(Bio.ini$Code, "_biomass")

  settings <- data.frame(
    variable = variable,
    type = "lnorm2",
    calibrate = TRUE,
    weight = 1,
    use_data = TRUE,
    file = paste0(data.dir, "/", variable, ".csv"),
    varid = "Biomass"
  )

  utils::write.csv(settings, file.path(output.path, paste0("calibration_settings", suffix, ".csv")), row.names = FALSE)

  ##################
  # Create code for runModel function
  ##################
  R_code <- paste0(variable, ' = unname(atlantis.biomass["', Bio.ini$Code, '"]), ')
  writeLines(R_code, con = file.path(output.path, paste0("biomass", suffix, ".txt")))

  R_code <- paste0(variable, ' = rep(0,', dt.timeseries, '), ')
  writeLines(R_code, con = file.path(output.path, paste0("biomass", suffix, "_crash.txt")))

  ##################
  # Create parameter files
  ##################
  # paste0() on an empty vector would return a single malformed name
  make_param <- function(prefix, codes, suffix){
    names <- if (length(codes) > 0) paste0(prefix, codes, suffix) else character(0)
    data.frame(
      names = names,
      paropt = rep(0, length(names)),
      parmin = rep(-1, length(names)),
      parmax = rep(1, length(names)),
      parphase = rep(1, length(names))
    )
  }

  Bio.ini_repro <- merge(Bio.ini, repro.option, by = "Code")

  calib.param <- rbind(
    # mum
    make_param("mum_", Bio.ini$Code, "_factor"),
    # BHalpha
    make_param("BHalpha_", Bio.ini_repro$Code[Bio.ini_repro$flagrecruit != 12], "_factor"),
    # KDENR
    make_param("KDENR_", Bio.ini_repro$Code[Bio.ini_repro$flagrecruit == 12], "_factor"),
    # mfc, not needed when fishing is turned off
    make_param("mfc_", if (unfished) character(0) else Bio.ini$Code[Bio.ini$IsFished == 1], "_factor"),
    # mQ
    make_param("", mq.groups, "_mQ_factor")
  )

  utils::write.csv(calib.param, file.path(output.path, if (unfished) "calibration-parameters-unfished.csv" else "calibration-parameters-complete.csv"), row.names = FALSE)

  invisible(list(settings = settings, parameters = calib.param))
}
