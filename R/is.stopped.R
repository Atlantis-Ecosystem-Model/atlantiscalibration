#' Test whether an Atlantis simulation stopped prematurely
#'
#' Compares the last time step written to the output against the configured
#' \code{tstop} value.  Returns \code{TRUE} when the simulation ended more than
#' one step before the scheduled stop, indicating a crash or early termination.
#'
#' @param path Character.  Path to the Atlantis run directory.
#' @param txt.filename Character.  Relative path to the biomass index text file
#'   (e.g. \code{"outputFolder/AMPS_OUTBiomIndx.txt"}).
#' @param run.filename Character.  Name of the run parameter file relative to
#'   \code{path} (e.g. \code{"PugetSound_run.prm"}).
#'
#' @return Logical.  \code{TRUE} if the simulation ended prematurely,
#'   \code{FALSE} otherwise.
#' @export
#'
#' @examples
#' \dontrun{
#'   is.stopped(path         = "path/to/atlantis/run",
#'              txt.filename = "outputFolder/AMPS_OUTBiomIndx.txt",
#'              run.filename = "PugetSound_run.prm")
#' }
is.stopped <- function(path, txt.filename, run.filename) {

  return(return_real_tstop(path, txt.filename) < (return_run_tstop(path, run.filename)-1)) #TODO: Not hard coded the limit around tstop
}
