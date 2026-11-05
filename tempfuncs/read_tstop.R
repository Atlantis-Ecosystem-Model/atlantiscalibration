#' Read the scheduled stop time from the run parameter file
#'
#' Parses the \code{tstop} line from the Atlantis \code{run.prm} file and
#' returns the configured simulation stop time in seconds.
#'
#' @param path Character.  Path to the Atlantis run directory.
#' @param run.filename Character.  Name of the run parameter file relative to
#'   \code{path} (e.g. \code{"PugetSound_run.prm"}).
#'
#' @return Numeric.  The scheduled stop time in seconds as set by \code{tstop}.
#' @export
#'
#' @examples
return_run_tstop <- function(path, run.filename) {
  prm <- paste0(path, "/", run.filename)
  bio.lines <- readLines(prm)
  pattern = paste0('tstop')
  bio.lines.id = grep(pattern,bio.lines)
  bio.lines.vals1 = bio.lines[bio.lines.id]

  a <- strsplit(bio.lines.vals1, "\t")[[1]][2]
  value <- as.numeric(unlist(strsplit(a, " "))[1])

  return(value)
}


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
return_real_tstop <- function(path, txt.filename) {
  prm <- paste0(path, "/", txt.filename)
  bio.lines <- read.table(prm)
  last.raw <- length(bio.lines$V1)
  value <- as.numeric(bio.lines$V1[last.raw])
  return(value)
}


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
is.stopped <- function(path, txt.filename, run.filename) {

  return(return_real_tstop(path, txt.filename) < (return_run_tstop(path, run.filename)-1)) #TODO: Not hard coded the limit around tstop
}
