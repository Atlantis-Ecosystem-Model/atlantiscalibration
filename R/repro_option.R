#' Create the reproduction option file from the biology parameter file
#'
#' Reads the \code{flagrecruit<Code>} lines of the Atlantis biology parameter
#' file and writes the recruitment option of each functional group to
#' \code{inputs/reproduction-option.csv}.  This file is used by
#' \code{\link{create_target_files_biomass}} to decide which recruitment
#' parameter (\code{BHalpha} or \code{KDENR}) is calibrated for each group.
#'
#' @param fg.file Character.  Name of the functional groups CSV file in
#'   \code{inputs/model_configuration}.
#' @param biology.prm Character.  Name of the Atlantis biology parameter file
#'   in \code{inputs/model_configuration}.
#'
#' @return Called for its side effect of writing
#'   \code{inputs/reproduction-option.csv}, with columns \code{Code} and
#'   \code{flagrecruit}.
#' @export
#'
#' @examples
#' \dontrun{
#'   repro_option(fg.file     = "SETasGroupsDem.csv",
#'                biology.prm = "VMPA_setas_biol_fishing_Trunk.prm")
#' }

repro_option <- function(fg.file, biology.prm){

  fg.groups <- readr::read_csv(here::here("inputs","model_configuration",fg.file))

  # Read the .prm file
  prm.data <- readr::read_file(here::here("inputs", "model_configuration", biology.prm))

  # Extract flagrecruit lines

  prm.lines <- unlist(strsplit(prm.data, "\n"))

  flagrecruit.lines <- tibble::tibble(parameter = grep("^flagrecruit", prm.lines, value = TRUE)) |>
    dplyr::mutate(parameter_corr = gsub("  "," ", parameter)) |>
    tidyr::separate_wider_delim(parameter_corr, delim=" ", names=c("parameter_name","flagrecruit","extra")) |>
    dplyr::mutate(Code=gsub("flagrecruit","",parameter_name)) |>
    dplyr::select(Code, flagrecruit)


  readr::write_csv(flagrecruit.lines, here::here("inputs","reproduction-option.csv"))


}
