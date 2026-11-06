#' Total abundance of an age class per time step
#'
#' Sums a \code{<Group><age>_Nums} array over boxes and layers, giving the
#' total number of individuals of that age class at each time step.
#'
#' @param abund_array Numeric array from \code{ncdf4::ncvar_get()} for a
#'   \code{_Nums} variable (boxes x layers x time).
#'
#' @return Numeric vector of total abundance, one value per time step.
#' @export
#'
#' @examples
#' \dontrun{
#'   outputs.nc <- open_main_nc(path = "path/to/atlantis/outputs", prefix = "AMPS")
#'   calculate_abund(ncdf4::ncvar_get(outputs.nc, "Planktiv_S_Fish1_Nums"))
#' }
calculate_abund <- function(abund_array) {
  return(apply(abund_array , 3, sum, na.rm = TRUE))
}
