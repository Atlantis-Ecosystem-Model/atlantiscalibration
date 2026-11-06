#' Read the table of parameters to calibrate for each functional group
#'
#' Reads the parameter table, which has one row per functional group and one
#' column per calibration parameter, with \code{1} if the parameter is
#' calibrated for that group and \code{0} if not.  Parameter column names are
#' matched without regard to case or surrounding spaces and renamed to
#' \code{mum}, \code{BHalpha}, \code{BHbeta}, \code{KDENR}, \code{mfc},
#' \code{mQ}, \code{mL}, \code{C} and \code{E}.
#'
#' @param parameter.file Character.  Name of the parameter table CSV file in
#'   \code{inputs}.  Must contain a \code{Code} column and one or more
#'   parameter columns.  Optional columns: \code{GroupType},
#'   \code{IsTurnedOn} and \code{IsCalibrated}.
#'
#' @return A data frame with column \code{Code}, any of the optional columns
#'   present, and one column per parameter in the table.
#' @export
#'
#' @examples
#' \dontrun{
#'   param.table <- read_parameter_table("parameter_table.csv")
#' }
read_parameter_table <- function(parameter.file){

  param.table <- utils::read.csv(here::here("inputs", parameter.file),
                                 check.names = FALSE, fileEncoding = "UTF-8-BOM")
  names(param.table) <- trimws(names(param.table))

  if (!"Code" %in% names(param.table)){
    stop("Parameter table is missing column Code")
  }

  # Standard parameter names, matched without regard to case
  parameters <- c("mum", "BHalpha", "BHbeta", "KDENR", "mfc", "mQ", "mL", "C", "E")
  info.columns <- c("Code", "GroupType", "IsTurnedOn", "IsCalibrated")

  param.columns <- setdiff(names(param.table), info.columns)
  matched <- parameters[match(tolower(param.columns), tolower(parameters))]

  if (anyNA(matched)){
    stop("Unknown parameter column(s) in parameter table: ",
         paste(param.columns[is.na(matched)], collapse = ", "),
         ". Use any of ", paste(parameters, collapse = ", "))
  }

  names(param.table)[match(param.columns, names(param.table))] <- matched

  param.table
}
