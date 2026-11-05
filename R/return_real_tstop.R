#' Read the actual stop time reached during a simulation
#'
#' Reads the last time stamp from the \code{_OUTBiomIndx.txt} text output,
#' which records the last time step written before the simulation ended.
#'
#' @param path Character.  Path to the Atlantis run directory.
#' @param txt.filename Character.  Relative path to the biomass index text file
#'   (e.g. \code{"outputFolder/AMPS_OUTBiomIndx.txt"}).
#'
#' @return Numeric.  The last time step value recorded in the output file.
#' @export
#'
#' @examples
#' \dontrun{
#'   return_real_tstop(path         = "path/to/atlantis/run",
#'                     txt.filename = "outputFolder/AMPS_OUTBiomIndx.txt")
#' }
return_real_tstop <- function(path, txt.filename) {
  prm <- paste0(path, "/", txt.filename)
  bio.lines <- utils::read.table(prm)
  last.raw <- length(bio.lines$V1)
  value <- as.numeric(bio.lines$V1[last.raw])
  return(value)
}
