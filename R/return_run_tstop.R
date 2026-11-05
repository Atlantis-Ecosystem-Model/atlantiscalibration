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
#' \dontrun{
#'   return_run_tstop(path         = "path/to/atlantis/run",
#'                    run.filename = "PugetSound_run.prm")
#' }
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
