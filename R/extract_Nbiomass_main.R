# Function to read nitrogen biomass outputs


#' Extract total nitrogen biomass from Atlantis output NetCDF
#'
#' Reads the \code{<group>_N} variables from the main Atlantis output NetCDF
#' file and sums across all boxes and layers for each time step.
#'
#' @param path Character.  Path to the directory containing Atlantis outputs.
#' @param prefix Character.  Prefix of the Atlantis configuration (e.g.
#'   \code{"AMPS"}).
#' @param fg.file Character.  Path to the functional groups CSV file (must
#'   contain at minimum \code{Name} and \code{IsTurnedOn} columns).
#'
#' @return A named list with one element per functional group.  Each element is
#'   a numeric vector of total nitrogen (mg N) summed across all boxes and
#'   layers, with one value per time step.
#' @export
#'
#' @examples
#' \dontrun{
#'   nbiomass <- extract_Nbiomass_main(
#'     path    = "path/to/atlantis/outputs",
#'     prefix  = "AMPS",
#'     fg.file = "PugetSoundAtlantisFunctionalGroups.csv"
#'   )
#' }
extract_Nbiomass_main <- function(path, prefix = NULL, fg.file){
  outputs.nc <-open_main_nc(path, prefix = prefix)
  fg <- process_fg(fg.file)
  vn <- c(paste0(fg$Name,"_N")) # variable name is functional group + "_N"
  Ndat <- purrr::map(1:length(vn), function(x) ncdf4::ncvar_get(outputs.nc,vn[x]))
  names(Ndat)<- vn

  biomass <- lapply(X = Ndat, FUN = calculate_Nbiomass)

  names(biomass) <- fg$Name

  return(biomass)
}

