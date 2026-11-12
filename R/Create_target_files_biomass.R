#' Create biomass target files and calibration inputs
#'
#' Creates biomass targets for \pkg{calibrar} from one of two sources:
#' \itemize{
#'   \item \code{initial.conditions = TRUE} (default): the initial biomass of
#'     each functional group (first time step of the Atlantis
#'     \code{<prefix>_OUTBiomIndx.txt} output) is used as a constant target.
#'   \item \code{time.series = TRUE}: the observed biomass time series of each
#'     group in \code{biomass.file} is used as the target.
#' }
#' Writes all the files needed to set up a biomass calibration:
#' \itemize{
#'   \item \code{data/<Code>_biomass.csv}: one target time series per
#'     calibrated group, with columns \code{Time} and \code{Biomass}.
#'   \item \code{calibration_settings.csv}: calibration settings for each
#'     biomass target.
#'   \item \code{calibration-parameters-complete.csv}: parameter factors to
#'     estimate for each group, as set in \code{parameter.file}, with
#'     initial values, bounds and phase.
#'   \item \code{biomass.txt} and \code{biomass_crash.txt}: R code snippets
#'     used to build the output list of the run model function, for a
#'     successful run and for a crashed run (all zeros), respectively.
#' }
#'
#' The parameters to calibrate, and the groups each one applies to, are read
#' from \code{parameter.file} (see \code{\link{read_parameter_table}}).
#' Factors are only created for groups that are turned on and calibrated.
#' \code{BHalpha}, \code{BHbeta} and \code{KDENR} factors are only created
#' for groups with \code{GroupType} \code{FISH}, \code{SHARK}, \code{BIRD}
#' or \code{MAMMAL}, taken from \code{parameter.file} if it has a
#' \code{GroupType} column, or else from \code{fg.file}.  \code{mfc} factors
#' are only created for groups with \code{IsFished == 1} in \code{fg.file}.
#' \code{KDENR} factors are only created for groups whose \code{flagrecruit}
#' in \code{repro.file} is 12, and \code{BHalpha} and \code{BHbeta} factors
#' only for groups whose \code{flagrecruit} is 3 (Beverton-Holt).  Groups
#' with other recruitment options, or missing from
#' \code{repro.file} get none of the three.
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
#'   (\code{<prefix>_OUTBiomIndx.txt}).  Required when
#'   \code{initial.conditions = TRUE}.  Default: \code{NULL}.
#' @param fg.file Character.  Path to the functional groups CSV file.  Must
#'   contain the columns \code{Code}, \code{Name}, \code{IsFished} and
#'   \code{GroupType}.
#' @param output.path Character.  Directory where output files are written.
#'   Target time series are written to its \code{data} sub-directory, which
#'   is created if needed.  Default: \code{inputs}.
#' @param not.calibrated Character vector.  Codes of functional groups to
#'   exclude from calibration.  Default:
#'   \code{c("PS", "PL", "DC", "DL", "DR")}.
#' @param dt.timeseries Integer.  Number of time steps in each target time
#'   series.  Default: \code{5}.
#' @param unfished Logical.  If \code{TRUE}, create targets for an unfished
#'   scenario (see Details).  Default: \code{FALSE}.
#' @param factor.unfished Numeric.  Factor applied to the initial biomass of
#'   fished groups to obtain the unfished biomass target.  Only used when
#'   \code{unfished = TRUE}.  Default: \code{1.3}.
#' @param initial.conditions Logical.  If \code{TRUE}, use the initial biomass
#'   in \code{biom.indx} as a constant target.  Default: \code{TRUE}.
#' @param time.series Logical.  If \code{TRUE}, use the observed biomass time
#'   series in \code{biomass.file} as the target.  Exactly one of
#'   \code{initial.conditions} and \code{time.series} must be \code{TRUE}.
#'   Default: \code{FALSE}.
#' @param biomass.file Character.  Name of the observed biomass CSV file in
#'   \code{inputs/model_configuration}, with columns \code{Code}, \code{Year}
#'   and \code{Biomass}.  Only used when \code{time.series = TRUE}.  Default:
#'   \code{biomass_timeseries.csv}.
#' @param biology.prm Character.  Name of the Atlantis biology parameter file
#'   in \code{inputs/model_configuration}.
#' @param parameter.file Character.  Name of the parameter table CSV file in
#'   \code{inputs}, with one row per functional group and one column per
#'   parameter to calibrate (any of \code{mum}, \code{BHalpha},
#'   \code{BHbeta}, \code{KDENR}, \code{mfc}, \code{mQ}, \code{mL},
#'   \code{C} and \code{E}), set to \code{1} if the parameter is calibrated
#'   for that group.  Default: \code{"parameter_table.csv"}.
#' @param repro.file Character.  Name of the reproduction option CSV file in
#'   \code{inputs}, with columns \code{Code} and \code{flagrecruit}, as
#'   written by \code{\link{repro_option}}.  Default:
#'   \code{"reproduction-option.csv"}.
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
#'
#'   # Observed biomass time series as target
#'   create_target_files_biomass(
#'     fg.file            = "path/to/PugetSoundAtlantisFunctionalGroups_2024.csv",
#'     initial.conditions = FALSE,
#'     time.series        = TRUE
#'   )
#' }
create_target_files_biomass <- function(biom.indx = NULL,
                                        fg.file,
                                        output.path = here::here("inputs"),
                                        not.calibrated,
                                        dt.timeseries = 5,
                                        unfished = FALSE,
                                        factor.unfished = 1.3,
                                        initial.conditions = TRUE,
                                        time.series = FALSE,
                                        biomass.file = "biomass_timeseries.csv",
                                        biology.prm,
                                        parameter.file = "parameter_table.csv",
                                        repro.file = "reproduction-option.csv"){

  # Targets come from either initial conditions or an observed time series
  if (initial.conditions == time.series){
    stop("Set exactly one of initial.conditions or time.series to TRUE")
  }
  if (initial.conditions && is.null(biom.indx)){
    stop("biom.indx is required when initial.conditions = TRUE")
  }

  config <- readr::read_csv(here::here("inputs","model_configuration", fg.file))

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

  if (initial.conditions){

    # Initial biomass is the first time step of the biomass index

    biom.data <- data.table::fread(here::here("inputs","model_configuration","outputFolder",biom.indx), header = TRUE, check.names = FALSE)

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

    Bio.groups <- Bio.ini
  }

  if (time.series){

    # Observed biomass time series, with columns Code, Year and Biomass

    biom.data <- readr::read_csv(here::here("inputs","model_configuration",biomass.file))

    Bio.ts <- merge(biom.data, config[, c("Code", "Name", "IsCalibrated", "IsFished")], by = "Code")
    Bio.ts <- Bio.ts[Bio.ts$IsCalibrated == 1, ]

    # Unfished scenario: only fished groups, with scaled biomass
    if (unfished){
      Bio.ts <- Bio.ts[Bio.ts$IsFished == 1, ]
      Bio.ts$Biomass <- Bio.ts$Biomass * factor.unfished
    }

    Bio.groups <- unique(Bio.ts[, c("Code", "Name", "IsCalibrated", "IsFished")])

    for (i in Bio.groups$Code){
      a <- Bio.ts[Bio.ts$Code == i, ]
      a <- a[order(a$Year), ]
      if (nrow(a) != dt.timeseries){
        warning("Biomass time series for ", i, " has ", nrow(a),
                " years but dt.timeseries is ", dt.timeseries)
      }
      data <- data.frame(Time = a$Year, Biomass = a$Biomass)
      utils::write.csv(data, file.path(data.path, paste0(i, "_biomass.csv")), row.names = FALSE)
    }
  }

  ##################
  # Create calibration setting file
  ##################
  variable <- paste0(Bio.groups$Code, "_biomass")

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
  R_code <- paste0(variable, ' = unname(unlist(atlantis.biomass["', Bio.groups$Name, '"])), ')
  writeLines(R_code, con = file.path(output.path, paste0("biomass", suffix, ".txt")))

  R_code <- paste0(variable, ' = rep(0,', dt.timeseries, '), ')
  writeLines(R_code, con = file.path(output.path, paste0("biomass", suffix, "_crash.txt")))

  ##################
  # Create parameter files
  ##################
  # paste0() on an empty vector would return a single malformed name


  # Parameters to calibrate for each group (1) or not (0)
  param.table <- read_parameter_table(parameter.file)

  # Recruitment option of each group, as written by repro_option()
  repro.option <- utils::read.csv(here::here("inputs", repro.file))

  # Group type from the parameter table, otherwise from the functional group file
  if (!"GroupType" %in% names(param.table)){
    param.table <- merge(param.table, config[, c("Code", "GroupType")], by = "Code")
  }

  # Only groups that are turned on and calibrated
  if ("IsTurnedOn" %in% names(param.table)) param.table <- param.table[param.table$IsTurnedOn == 1, ]
  if ("IsCalibrated" %in% names(param.table)) param.table <- param.table[param.table$IsCalibrated == 1, ]
  param.table <- param.table[param.table$Code %in% Bio.groups$Code, ]

  # Recruitment parameters only apply to vertebrates
  vertebrate.types <- c("FISH", "SHARK", "BIRD", "MAMMAL")

  parameters <- setdiff(names(param.table), c("Code", "GroupType", "IsTurnedOn", "IsCalibrated"))

  calib.param.ls <- list()

  for (eachparameter in parameters){

    # Groups flagged with 1 for this parameter
    codes <- param.table$Code[param.table[[eachparameter]] == 1]

    if (eachparameter %in% c("BHalpha", "BHbeta", "KDENR")){
      codes <- intersect(codes, param.table$Code[param.table$GroupType %in% vertebrate.types])
    }

    # KDENR is used when flagrecruit is 12, BHalpha and BHbeta when it is 3 (Beverton-Holt)
    if (eachparameter == "KDENR"){
      codes <- intersect(codes, repro.option$Code[repro.option$flagrecruit == 12])
    }
    if (eachparameter %in% c("BHalpha", "BHbeta")){
      codes <- intersect(codes, repro.option$Code[repro.option$flagrecruit == 3])
    }

    # Fishing mortality only applies to fished groups
    if (eachparameter == "mfc"){
      codes <- intersect(codes, config$Code[config$IsFished == 1])
    }

    calib.param.ls[[eachparameter]] <- switch(eachparameter,
      # mum
      "mum" = make_param("mum_", codes, "_factor"),
      # BHalpha
      "BHalpha" = make_param("BHalpha_", codes, "_factor"),
      # BHbeta
      "BHbeta" = make_param("BHbeta_", codes, "_factor"),
      # KDENR
      "KDENR" = make_param("KDENR_", codes, "_factor"),
      # mfc, not needed when fishing is turned off
      "mfc" = make_param("mfc_", if (unfished) character(0) else codes, "_factor"),
      # mQ
      "mQ" = make_param("", codes, "_mQ_factor"),
      # mL
      "mL" = make_param("", codes, "_mL_factor"),
      # C
      "C" = make_param("C_", codes, "_factor"),
      # E
      "E" = make_param("E_", codes, "_factor")
    )
  }

  calib.param <- do.call(rbind, unname(calib.param.ls))

  utils::write.csv(calib.param, file.path(output.path, if (unfished) "calibration-parameters-unfished.csv" else "calibration-parameters-complete.csv"), row.names = FALSE)

  invisible(list(settings = settings, parameters = calib.param))
}
