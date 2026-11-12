#' Convert a spatial nitrogen array to a total biomass time series
#'
#' Multiplies nitrogen concentration (mg N/m\eqn{^3}) by cell volume (m\eqn{^3})
#' and applies \eqn{5.7 \times 20 / 10^9} to convert to tonnes wet weight.
#' For 3-D groups (vertebrates, plankton) the full volume array is used; for
#' 2-D benthic groups layer 7 volumes serve as a proxy for cell area
#' (layer 7 is 1 m deep, so volume \eqn{\approx} area).
#'
#' @param biomass_array Numeric array from \code{ncdf4::ncvar_get()} for a
#'   \code{_N} variable.  Either 3-D (boxes x layers x time) or 2-D
#'   (boxes x time).
#' @param fg.file Data frame of functional group metadata (output of
#'   \code{\link{process_fg}}).
#' @param name Character.  Variable name (e.g. \code{"CHY_N"}).
#' @param outputs.nc An open \code{ncdf4} connection to the main output file,
#'   used to read the \code{volume} variable.
#'
#' @return Numeric vector of total biomass in tonnes wet weight, one value per
#'   time step.
#' @export
#'
#' @examples
#' \dontrun{
#'   outputs.nc <- open_main_nc(path = "path/to/atlantis/outputs", prefix = "AMPS")
#'   fg <- process_fg("PugetSoundAtlantisFunctionalGroups.csv")
#'   biomass <- calculate_biomass(ncdf4::ncvar_get(outputs.nc, "CHY_N"),
#'                                fg.file = fg, name = "CHY_N",
#'                                outputs.nc = outputs.nc)
#' }
calculate_biomass <- function(biomass_array, fg.file, name, outputs.nc) {

  volumes <- ncdf4::ncvar_get(outputs.nc, "volume")
  volumes_arr <- array(data = unlist(volumes),dim = dim(volumes)[c(1,2)]) # box/layer volumes

  # Layer 7 is 1 m deep, so its volume equals the horizontal cell area (m^2)
  areas_vec <- volumes_arr[7,]

  if(length(dim(biomass_array))==3) {
    totbio <- apply(biomass_array * c(volumes_arr) * (5.7 * 20 / 10^9), 3, sum, na.rm = TRUE)
  } else {
    if (length(dim(biomass_array))==0) {
      totbio = 0
    }else {

      totbio <- apply(biomass_array * areas_vec * (5.7 * 20 / 10^9), 2, sum, na.rm = TRUE)
    }
  }


  # if(btype == "vertebrate" | btype == "plankton") {
  #   totbio <- apply(biomass_array * c(volumes_arr) * (5.7 * 20 / 10^9), 3, sum, na.rm = TRUE)
  # } else if(btype == "2D") {
  #   totbio <- apply(biomass_array * areas_vec * (5.7 * 20 / 10^9), 2, sum, na.rm = TRUE)
  # } else if(btype == "other") {
  #   sum_volumes <- sum(volumes$volume)
  #   totbio <- apply(biomass_array * c(volumes_arr), 3, sum, na.rm = TRUE) / sum_volumes
  # }
  return(totbio)
}


