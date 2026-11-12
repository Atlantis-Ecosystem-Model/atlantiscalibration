#' @title Create Atlantis Model Calibration Settings
#' @description
#' Generates a calibration settings file for functional groups in an Atlantis model.
#' Creates a dataframe specifying which groups to calibrate, their associated variables,
#' calibration weights, and data file paths.
#'
#' Only groups with \code{IsTurnedOn == 1} and \code{IsCalibrated == 1} in the
#' functional group file are calibrated.  For each target type in
#' \code{var.type}, the corresponding target files are also created (see
#' \code{\link{create_target_files_biomass}},
#' \code{\link{create_target_files_waa}},
#' \code{\link{create_target_files_abund}} and
#' \code{\link{create_target_files_catch}}).
#'
#' @param fg.file Character. Name of the functional group configuration file (CSV) located
#'   in inputs/model_configuration/.  Must contain the columns \code{Code},
#'   \code{Name}, \code{IsTurnedOn}, \code{IsCalibrated} and \code{NumCohorts}.
#' @param var.type Character vector. Target types to calibrate: any of
#'   "biomass", "weight", "abundance" and "catch".
#' @param fun.type Character. Calibrar package optimization function for calibration
#' @param dt.timeseries Integer. Number of time steps in each target time series.
#' @param w.vector Data frame. Optional custom weights with columns "Code" and
#'   "weight_new" to override default weights.  If NULL, default weights are used.
#' @param biology.prm Character. Name of the Atlantis biology parameter file in
#'   inputs/model_configuration/.
#' @param biom.indx Character. Name of the Atlantis biomass index output file
#'   (\code{<prefix>_OUTBiomIndx.txt}), used to create biomass targets.
#' @param init.file Character. Name of the Atlantis initial conditions NetCDF
#'   file, used to create weight-at-age and abundance targets.
#' @param catch.file Character. Name of the observed catch CSV file, used to
#'   create catch targets.
#' @param parameter.file Character. Name of the parameter table CSV file in
#'   inputs/, with one row per functional group and one column per parameter
#'   to calibrate, set to 1 if the parameter is calibrated for that group (see
#'   \code{\link{create_target_files_biomass}}).  Default: "parameter_table.csv".
#'
#' @return Invisibly returns NULL. Writes calibration settings CSV to
#'   inputs/calibration_settings.csv
#'
#' @examples
#' \dontrun{
#' make_calsettings(fg.file       = "SETasGroupsDem.csv",
#'                  var.type      = c("biomass", "weight"),
#'                  fun.type      = "lnorm2",
#'                  dt.timeseries = 5,
#'                  w.vector      = NULL,
#'                  biology.prm   = "VMPA_setas_biol_fishing_Trunk.prm",
#'                  biom.indx     = "outputSETASBiomIndx.txt",
#'                  init.file     = "INIT_VMPA_Jan2015.nc",
#'                  catch.file    = "catch_timeseries.csv",
#'                  parameter.file = "parameter_table.csv")
#' }
#'
#' @export
make_calsettings <- function(fg.file, var.type, fun.type, dt.timeseries,
                             w.vector, biology.prm, biom.indx, init.file, catch.file,
                             parameter.file = "parameter_table.csv"){

  # Read functional group configuration file
  fg.groups <- readr::read_csv(here::here("inputs","model_configuration", fg.file))

  # Check that the functional group file indicates which groups to calibrate
  if(!"IsCalibrated" %in% names(fg.groups)){
    stop("Functional group file is missing column IsCalibrated which indicates to calibrate the group (1) or not (0)")
  }

  # Codes of groups that are turned off or not calibrated
  no.cal.vector <- fg.groups |>
    dplyr::filter(IsTurnedOn==0 | IsCalibrated==0) |>
    dplyr::pull(Code)


  # Extract group codes
  group.names <- fg.groups |>
    dplyr::filter(IsCalibrated==1 & IsTurnedOn==1) |>
    dplyr::select(Code)

  settings.ls <- list()

  for(eachvariable in var.type){

    print(eachvariable)

    if(eachvariable=="biomass"){

      these.settings <- group.names |>
        dplyr::mutate(variable= paste(Code,eachvariable, sep="_"),
                      type = fun.type, calibrate = TRUE,
                      weight = 1, use_data = TRUE,
                      file = paste0("data/", Code,"_",eachvariable,".csv"), #data/MA_biomass.csv
                      varid = stringr::str_to_sentence(eachvariable))

      settings.ls[[eachvariable]] <- these.settings

      create_target_files_biomass(biom.indx = biom.indx,
                                  fg.file = fg.file,
                                  output.path = here::here("inputs"),
                                  not.calibrated=no.cal.vector,
                                  dt.timeseries = dt.timeseries,
                                  unfished = FALSE,
                                  factor.unfished = 1.3,
                                  initial.conditions = TRUE,
                                  time.series = FALSE,
                                  biomass.file = "biomass_timeseries.csv",
                                  biology.prm = biology.prm,
                                  parameter.file = parameter.file)
      # It is possible to create targets for an unfished scenario instead: only fished groups (\code{IsFished == 1}) are included, and their
      #initial biomass is multiplied by


    }

    if(eachvariable=="weight"){

      #subset only age structured groups that are turned on and calibrated
      waa.groups <- fg.groups[fg.groups$NumCohorts > 2 & fg.groups$Code %in% group.names$Code, ]

      waa.names <- unlist(lapply(seq_len(nrow(waa.groups)), function(i)
        paste0(waa.groups$Name[i], seq_len(waa.groups$NumCohorts[i]), "_w")
      ))

      waa.code <- rep(waa.groups$Code, times = waa.groups$NumCohorts)

      these.settings <- tibble::tibble(variable=waa.names, Code = waa.code) |>
        dplyr::mutate(type = fun.type, calibrate = TRUE,
                      weight = 1, use_data = TRUE,
                      file = paste0("data/", variable,".csv"), #Raptors6_w
                      varid = stringr::str_to_sentence(eachvariable))

      waa.settings <- create_target_files_waa(init.file,
                                              output.path = here::here("inputs"),
                                              dt.timeseries)

      # keep only cohorts with a target file (e.g. invertebrates have no weight at age)
      settings.ls[[eachvariable]] <- these.settings |>
        dplyr::filter(variable %in% waa.settings$variable)


    }

    if(eachvariable=="abundance"){

      #subset only age structured groups that are turned on and calibrated
      waa.groups <- fg.groups[fg.groups$NumCohorts > 2 & fg.groups$Code %in% group.names$Code, ]

      # one target per group with all age classes, as written by create_target_files_abund
      these.settings <- tibble::tibble(variable = paste0(waa.groups$Name, "_Nums"),
                                       Code = waa.groups$Code) |>
        dplyr::mutate(type = "multinom", calibrate = TRUE,
                      weight = 1, use_data = TRUE,
                      file = paste0("data/", variable,".csv"), #Raptors_Nums
                      varid = NA,
                      col_skip = 1) # skip the Time column, keep all age classes

      abund.settings <- create_target_files_abund(init.file,
                                                  output.path = here::here("inputs"),
                                                  dt.timeseries)

      # keep only groups with a target file (e.g. invertebrates have no numbers at age)
      settings.ls[[eachvariable]] <- these.settings |>
        dplyr::filter(variable %in% abund.settings$variable)

      }


    if(eachvariable=="catch"){

      #subset only groups that are turned on and calibrated
      catch.groups <- fg.groups[fg.groups$Code %in% group.names$Code, ]

      # target files are named by group Name, as written by create_target_files_catch
      these.settings <- tibble::tibble(variable = paste0(catch.groups$Name, "_", eachvariable),
                                       Code = catch.groups$Code) |>
        dplyr::mutate(type = fun.type, calibrate = TRUE,
                      weight = 1, use_data = TRUE,
                      file = paste0("data/", variable,".csv"), #data/Raptors_catch.csv
                      varid = stringr::str_to_sentence(eachvariable))

      catch.settings <- create_target_files_catch(catch.file = catch.file,
                                                  fg.file = fg.file,
                                                  output.path = here::here("inputs"),
                                                  dt.timeseries = dt.timeseries,
                                                  weight = 2,
                                                  plot = FALSE)

      # keep only groups with a target file (groups in the catch file)
      settings.ls[[eachvariable]] <- these.settings |>
        dplyr::filter(variable %in% catch.settings$variable)

    }
  }
  # Create base calibration settings with variable names, file paths, and default values

    cal.settings <- settings.ls |> dplyr::bind_rows()

      # Exclude specified groups from calibration if provided
  if(!is.null(no.cal.vector)){
    cal.settings <- cal.settings |>
      dplyr::mutate(calibrate=dplyr::if_else(Code %in% no.cal.vector, FALSE, calibrate))
  }

  # Apply custom weights if provided
  if(!is.null(w.vector)){
    cal.settings <- cal.settings |>
      dplyr::left_join(w.vector, by="Code") |>
      dplyr::mutate(weight=dplyr::if_else(!is.na(weight_new), weight_new, weight)) |>
      dplyr::select(-weight_new)
  }

  # Write calibration settings to CSV file
  cal.settings |>
    dplyr::select(-Code) |>
    readr::write_csv(here::here("inputs", "calibration_settings.csv"))

}
