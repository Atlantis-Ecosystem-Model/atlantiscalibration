#' Read and filter the functional groups CSV file
#'
#' Reads the functional groups CSV and retains only rows where
#' \code{IsTurnedOn == 1}.
#'
#' @param fg.file Character.  Path to the functional groups CSV file.
#'
#' @return A data frame of active functional groups.
#' @export
#'
#' @examples
#' \dontrun{
#'   fg <- open_fg_file("path/to/PugetSoundAtlantisFunctionalGroups.csv")
#' }
open_fg_file <- function(fg.file) {
  fg <- utils::read.csv(fg.file)
  fg <- fg |> dplyr::filter(IsTurnedOn==1)
  return(fg)
}
