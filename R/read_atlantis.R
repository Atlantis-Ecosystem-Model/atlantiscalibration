#' Read Atlantis model outputs
#'
#' Reads the outputs of an Atlantis run and returns the indicators used in the
#' calibration: biomass, landings, abundance and weight at age.  If the run
#' stopped before its scheduled end (see \code{\link{is.stopped}}), returns
#' the same structure filled with zeros, so a crashed run can still be scored
#' by \pkg{calibrar}.
#'
#' @param path Character.  Path to the Atlantis run directory.
#' @param prefix Character.  Prefix of the Atlantis configuration files (e.g.
#'   \code{"AMPS"} for Puget Sound).
#' @param fg.file Character.  Path to the functional groups CSV file.
#' @param fishery Logical.  Whether fishing is turned on in the model.
#' @param spatial Logical.  Read the data per polygon.  Only \code{FALSE} is
#'   currently available.  Default: \code{FALSE}.
#' @param N_only Logical.  If \code{TRUE}, only read the raw nitrogen biomass
#'   (see \code{\link{extract_Nbiomass_main}}).  Default: \code{FALSE}.
#' @param txt.filename Character.  Path to the biomass index text file,
#'   relative to \code{path}.  Default:
#'   \code{"outputFolder/AMPS_OUTBiomIndx.txt"} (Puget Sound).
#' @param run.filename Character.  Name of the run parameter file, relative to
#'   \code{path}.  Default: \code{"PugetSound_run.prm"} (Puget Sound).
#' @param dt.timeserie Integer.  Number of time steps in each indicator when
#'   the run crashed; all values are set to zero.  Default: \code{2}.
#' @param ... Not used.
#'
#' @return An object of class \code{atlantis}: a list with elements
#'   \code{biomass}, \code{landings}, \code{abundance} and \code{waa}, each a
#'   named list with one element per functional group.  If
#'   \code{N_only = TRUE}, a list with a single element \code{Nbiomass}.
#' @export
#'
#' @examples
#' \dontrun{
#'   outputs <- read_atlantis(path    = "path/to/atlantis/run",
#'                            prefix  = "AMPS",
#'                            fg.file = "PugetSoundAtlantisFunctionalGroups.csv",
#'                            fishery = TRUE)
#' }
read_atlantis <- function(path, prefix = NULL, fg.file, fishery, spatial = F, N_only = F,
                         txt.filename = "outputFolder/AMPS_OUTBiomIndx.txt",
                         run.filename = "PugetSound_run.prm",
                         dt.timeserie = 2, ...) {
  if(!dir.exists(path)) stop("The output directory does not exist.")

  print("Reading Atlantis outputs")

  if (N_only == T){
    output = list(Nbiomass = extract_Nbiomass_main(path = path, prefix = prefix, fg.file = fg.file))
    class(output$Nbiomass) = "atlantis.Nbiomass"
    class(output) = "atlantis"
  }else{
    if (is.stopped(path, txt.filename, run.filename)){
      fg.data = process_fg(fg.file)
      output <- list(
        biomass = stats::setNames(lapply(fg.data$Name, function(x) rep(0, dt.timeserie)), fg.data$Name),
        landings = stats::setNames(lapply(fg.data$Name, function(x) rep(0, dt.timeserie)), fg.data$Name),
        abundance = stats::setNames(lapply(fg.data$Name, function(x) rep(0, dt.timeserie)), fg.data$Name),
        waa = stats::setNames(lapply(fg.data$Name, function(x) rep(0, dt.timeserie)), fg.data$Name)
      )

    }else{
      output.path = paste0(path, "/outFolder")
      output = list(biomass= extract_biomass_main(path = path, prefix = prefix, fg.file = fg.file),
                    landings=extract_catch_main(path, prefix = prefix, fg.file = fg.file, dt.timeserie = dt.timeserie, fishery = fishery),
                    abundance= extract_abund_main(path, prefix = prefix, fg.file),
                    waa = extract_waa(path=path, prefix = prefix))
    }

    class(output$biomass) = "atlantis.biomass"
    class(output$landings) = "atlantis.landings"
    class(output$abundance) = "atlantis.abundance"
    class(output) = "atlantis"
  }



  return(output)
}

