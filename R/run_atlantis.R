#' @title Execute an Atlantis simulation via shell script
#' @description
#' Runs the Atlantis shell script using \code{sudo}, after fixing Windows-style
#' line endings (\code{flip -uv}) and granting execute permissions
#' (\code{chmod +x}).
#'
#' @param path Character.  Absolute path to the directory containing the
#'   Atlantis run files.
#' @param sh.file Character.  Name of the shell script to execute (e.g.
#'   \code{"amps_cal.sh"}).
#'
#' @return \code{NULL}, called for its side effect of running the simulation.
#' @export
#'
#' @examples
#' \dontrun{
#'   run_atlantis(path = "/home/atlantis/runs/run01", sh.file = "amps_cal.sh")
#' }
run_atlantis <- function(path, sh.file) {
  system(paste0("cd ",path ," sudo flip -uv *; sudo chmod +x ", sh.file,"; sudo sh ./", sh.file), wait = TRUE)
  print("Atlantis run is done!")
}
