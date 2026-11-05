#' Load and classify functional groups by biomass type
#'
#' Calls \code{\link{open_fg_file}} and adds a \code{BiomassType} column that
#' classifies each group as \code{"vertebrate"}, \code{"plankton"},
#' \code{"2D"}, or \code{"other"} based on \code{GroupType}.  Only active
#' groups belonging to one of the known \code{GroupType} values are returned.
#'
#' @param fg.file Character.  Path to the functional groups CSV file.
#'
#' @return A data frame of active functional groups with an added
#'   \code{BiomassType} column.
#' @export
#'
#' @examples
#' \dontrun{
#'   fg <- process_fg("path/to/PugetSoundAtlantisFunctionalGroups.csv")
#'   table(fg$BiomassType)
#' }
process_fg <- function(fg.file){

  fg <- open_fg_file(fg.file)
  fg$BiomassType <- fg$GroupType

  fg1 <- fg |>
    dplyr::filter(GroupType%in%c("FISH","SHARK","BIRD","MAMMAL")) |>
    dplyr::mutate(BiomassType="vertebrate")
  fg2 <- fg |>
    dplyr::filter(GroupType%in%c("PWN",'CEP','LG_ZOO','MED_ZOO','SM_ZOO','LG_PHY','SM_PHY')) |>
    dplyr::mutate(BiomassType="plankton")
  fg3 <- fg |>
    dplyr::filter(GroupType%in%c("MOB_EP_OTHER",'SED_EP_FF','SED_EP_OTHER','SEAGRASS','PHYTOBEN')) |>
    dplyr::mutate(BiomassType="2D")
  fg4 <- fg |>
    dplyr::filter(GroupType%in%c("LG_INF","MICROPHTYBENTHOS","SED_BACT","PL_BACT","SM_INF","CARRION","LAB_DET","REF_DET")) |>
    dplyr::mutate(BiomassType="other")

  return(rbind(fg1,fg2,fg3,fg4))
}
