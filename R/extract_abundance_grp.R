# Function to read abundance outputs

#' Extract abundance time series for all age-class groups
#'
#' Reads every \code{_Nums} variable from the main Atlantis output NetCDF file
#' and sums across all boxes and layers to produce a time series per age-class
#' variable.
#'
#' @param path Character.  Path to the directory containing Atlantis outputs.
#' @param prefix Character.  Prefix of the Atlantis configuration (e.g.
#'   \code{"AMPS"}).
#'
#' @return A named list with one element per \code{_Nums} variable in the
#'   NetCDF.  Each element is a numeric vector of total individuals summed
#'   across all boxes and layers, with one value per time step.
#' @export
#'
#' @examples
#' \dontrun{
#'   abund <- extract_abundance_grp(
#'     path   = "path/to/atlantis/outputs",
#'     prefix = "AMPS"
#'   )
#' }
extract_abundance_grp <- function(path, prefix = NULL){
  outputs.nc <-open_main_nc(path, prefix = prefix)
  vn <- names(outputs.nc$var)[grep("_Nums",outputs.nc$var)]
  Ndat <- purrr::map(1:length(vn), function(x) ncdf4::ncvar_get(outputs.nc,vn[x]))
  names(Ndat)<- vn
  abund_allgrp <- lapply(X = Ndat, FUN = calculate_abund)
  names(abund_allgrp) <- names(Ndat)
  return(abund_allgrp)
}
