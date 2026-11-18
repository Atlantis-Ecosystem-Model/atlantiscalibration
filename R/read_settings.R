#' Read the calibration settings file
#'
#' Evaluates the settings file (by default \code{inputs/settings_file.txt})
#' and assigns every variable defined there (e.g. \code{fg.file},
#' \code{biology.prm}, \code{var.type}, \code{n.Cores}, \code{maxgen},
#' \code{master}, \code{run}) into \code{envir}, so they can be passed directly
#' to functions such as \code{\link{make_calsettings}} and
#' \code{\link{read_calibration}}.
#'
#' The settings file is plain R code, so values can be R expressions such as
#' \code{here::here("RUN")}, \code{c("biomass", "abundance")} or \code{NULL}.
#' Both \code{=} and \code{<-} assignments are accepted.
#'
#' @param settings.file Character. Path to the settings file. Defaults to
#'   \code{here::here("inputs", "settings_file.txt")}.
#' @param envir Environment where the variables are assigned. Defaults to the
#'   calling environment.
#'
#' @return Invisibly returns a named list with all the settings.
#' @export
#'
#' @examples
#' \dontrun{
#'   read_settings()
#'   make_calsettings(fg.file = fg.file, var.type = var.type, ...)
#'
#'   # or keep the settings in a list without touching the environment
#'   settings <- read_settings(envir = new.env())
#' }
read_settings <- function(settings.file = here::here("inputs", "settings_file.txt"),
                          envir = parent.frame()){

  if(!file.exists(settings.file)) {
    stop("Settings file not found: ", settings.file)
  }

  # evaluate the settings in an isolated environment first
  settings.env <- new.env(parent = baseenv())
  sys.source(settings.file, envir = settings.env, keep.source = FALSE)

  settings <- as.list(settings.env, all.names = TRUE)

  # copy settings to the target environment
  list2env(settings, envir = envir)

  return(invisible(settings))
}
