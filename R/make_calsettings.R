#' @title Create Atlantis Model Calibration Settings
#' @description
#' Generates a calibration settings file for functional groups in an Atlantis model.
#' Creates a dataframe specifying which groups to calibrate, their associated variables,
#' calibration weights, and data file paths.
#'
#' @param fg.file Character. Name of the functional group configuration file (CSV) located
#'   in inputs/model_configuration/
#' @param var.type Character. Variable type suffix (e.g., "biomass", "recruitment")
#' @param fun.type Character. Calibrar package optimization function for calibration
#' @param no.cal.vector Character vector. Optional group codes to exclude from calibration.
#'   If NULL, all groups are calibrated.
#' @param w.vector Data frame. Optional custom weights with columns "Code" and
#'   "weight_new" to override default weights.
#'
#' @return Invisibly returns NULL. Writes calibration settings CSV to
#'   inputs/calibration_settings.csv
#'
#' @examples
#' \dontrun{
#' make_calsettings(fg.file, var.type, fun.type, no.cal.vector, w.vector)
#' }
#'
#' @export
make_calsettings <- function(fg.file, var.type, fun.type, no.cal.vector, w.vector){

  # Read functional group configuration file
  fg.groups <- readr::read_csv(here::here("inputs","model_configuration", fg.file))

  # Extract group codes
  group.names <- fg.groups %>% dplyr::select(Code)

  settings.ls <- list()

  for(eachvariable in var.type){

    print(eachvariable)

    if(eachvariable=="biomass"){

      these.settings <- group.names %>%
        dplyr::mutate(variable= paste(Code,eachvariable, sep="_"),
                      type = fun.type, calibrate = TRUE,
                      weight = 1, use_data = TRUE,
                      file = paste0("data/", Code,"_",eachvariable,".csv"), #data/MA_biomass.csv
                      varid = stringr::str_to_sentence(eachvariable))

      settings.ls[[eachvariable]] <- these.settings

    }

    if(eachvariable=="weight"){

      #subset only age structured groups
      waa.groups <- fg.groups[fg.groups$NumCohorts > 1, ]

      waa.names <- unlist(lapply(seq_len(nrow(waa_groups)), function(i)
        paste0(waa_groups$Name[i], seq_len(waa_groups$NumCohorts[i]), "_w")
      ))

      waa.code <- rep(waa.groups$Code, times = waa.groups$NumCohorts)

      these.settings <- tibble::tibble(variable=waa.names, Code = waa.code) %>%
        dplyr::mutate(type = fun.type, calibrate = TRUE,
                      weight = 1, use_data = TRUE,
                      file = paste0("data/", variable,".csv"), #Raptors6_w
                      varid = stringr::str_to_sentence(eachvariable))

      settings.ls[[eachvariable]] <- these.settings

    }
  }
  # Create base calibration settings with variable names, file paths, and default values

    cal.settings <- settings.ls %>% dplyr::bind_rows()

      # Exclude specified groups from calibration if provided
  if(!is.null(no.cal.vector)){
    cal.settings <- cal.settings %>%
      dplyr::mutate(calibrate=dplyr::if_else(Code %in% no.cal.vector, FALSE, calibrate))
  }

  # Apply custom weights if provided
  if(!is.null(weight.vector)){
    cal.settings <- cal.settings %>%
      dplyr::left_join(weight.vector, by="Code") %>%
      dplyr::mutate(weight=dplyr::if_else(!is.na(weight_new), weight_new, weight)) %>%
      dplyr::select(-weight_new)
  }

  # Write calibration settings to CSV file
  cal.settings %>%
    dplyr::select(-Code) %>%
    readr::write_csv(here::here("inputs", "calibration_settings.csv"))

}
