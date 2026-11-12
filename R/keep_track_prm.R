#' Save the parameter files used in a calibration run
#'
#' Copies the parameter files used in a model run to
#' \code{<track.path>/iteration_<iteration>/run_<run>_<file>}, so the
#' parameters used in every run of every iteration of the calibration are
#' kept.
#'
#' \pkg{calibrar} runs each individual of the population in its own directory
#' \code{<control$run>/i<run>}, and reuses these directories in every
#' iteration (generation).  The run number is taken from the name of the
#' directory, and the iteration from a counter kept in the file
#' \code{.iteration} in that directory, which is increased by one at every
#' run.  The best solution is evaluated in \code{i0} at the end of each
#' phase; these files are saved in \code{<track.path>/final_<phase>}
#' instead.  Outside a \pkg{calibrar} run directory, the run number is
#' \code{0}.
#'
#' @param path Character.  Directory where the model is run.
#' @param track.path Character.  Folder where the files are saved.
#' @param files Character vector.  Names of the files to save, relative to
#'   \code{path}.
#'
#' @return Invisibly, the paths of the saved files.
#' @export
#'
#' @examples
#' \dontrun{
#'   keep_track_prm(getwd(), here::here("outputs", "keep_track_calibration"),
#'                  files = c("calibration-parameters.csv", "VMPA_setas_biol_fishing_Trunk.prm"))
#' }
keep_track_prm <- function(path, track.path, files){

  # Run number from the calibrar run directory, i<run>
  run.dir <- basename(normalizePath(path))
  run <- if (grepl("^i[0-9]+$", run.dir)) as.integer(sub("^i", "", run.dir)) else 0L

  # Iteration from the counter of runs in this directory
  counter.file <- file.path(path, ".iteration")
  iteration <- if (file.exists(counter.file)) as.integer(readLines(counter.file, n = 1)) + 1L else 1L
  writeLines(as.character(iteration), counter.file)

  # i0 is the evaluation of the best solution at the end of each phase
  folder <- if (run == 0 && grepl("^i0$", run.dir)) "final_%03d" else "iteration_%03d"
  iteration.path <- file.path(track.path, sprintf(folder, iteration))
  dir.create(iteration.path, showWarnings = FALSE, recursive = TRUE)

  saved <- file.path(iteration.path, sprintf("run_%03d_%s", run, basename(files)))
  file.copy(file.path(path, files), saved, overwrite = TRUE)

  invisible(saved)
}
