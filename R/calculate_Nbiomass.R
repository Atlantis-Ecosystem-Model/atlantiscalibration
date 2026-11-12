#' Collapse a spatial nitrogen array to a time series
#'
#' Sums a nitrogen array (boxes x layers x time, or boxes x time) over all
#' spatial dimensions, returning one total per time step.
#'
#' @param biomass_array Numeric array as returned by \code{ncdf4::ncvar_get()}
#'   for a \code{_N} variable.  Either 3-D (boxes x layers x time) or 2-D
#'   (boxes x time).
#'
#' @return Numeric vector of total nitrogen sums, one value per time step.
#' @export
#'
calculate_Nbiomass <- function(biomass_array) {


  if(length(dim(biomass_array))==3) {
    totbio <- apply(biomass_array, 3, sum, na.rm = TRUE)
  } else {
    totbio <- apply(biomass_array, 2, sum, na.rm = TRUE)
  }
  return(totbio)
}
