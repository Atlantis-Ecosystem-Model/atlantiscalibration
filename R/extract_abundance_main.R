#' Extract abundance for all functional groups defined in a groups file
#'
#' Loops over functional groups listed in \code{fg.file} and calls
#' \code{\link{extract_abundance_sp}} for each, returning a named list.
#'
#' @param path Character.  Path to the directory containing Atlantis outputs.
#' @param prefix Character.  Prefix of the Atlantis configuration.
#' @param fg.file Character.  Path to the functional groups CSV file.
#'
#' @return A named list (names = functional group names) where each element is
#'   the summed abundance time series for that group.
#' @export
#'
#' @examples
#' \dontrun{
#'   abund_all <- extract_abund_main(
#'     path    = "path/to/atlantis/outputs",
#'     prefix  = "AMPS",
#'     fg.file = "PugetSoundAtlantisFunctionalGroups.csv"
#'   )
#' }
extract_abund_main <- function(path, prefix = NULL, fg.file){
  fg <- process_fg(fg.file)
  abund <- lapply(X = fg$Name, FUN = extract_abundance_sp, path = path, prefix = prefix)
  names(abund) <- fg$Name
  return(abund)
}
