#################################
## GENERAL TOOLS TO OPEN FILES ##
#################################

#' Open the main Atlantis NetCDF output file
#'
#' Opens the \code{<prefix>_OUT.nc} file found in \code{path} using
#' \code{ncdf4::nc_open()}.
#'
#' @param path Character.  Path to the directory containing Atlantis outputs.
#' @param prefix Character.  Prefix of the Atlantis configuration (e.g.
#'   \code{"AMPS"}).  Required; stops with an error if \code{NULL}.
#'
#' @return An open \code{ncdf4} connection object.
#' @export
#'
#' @examples
#' \dontrun{
#'   outputs.nc <- open_main_nc(path = "path/to/atlantis/outputs", prefix = "AMPS")
#'   ncdf4::nc_close(outputs.nc)
#' }
open_main_nc <- function(path, prefix = NULL) {
  if(is.null(prefix)) stop("Add prefix argument for your Atlantis configuration")
  if(stringr::str_sub(path,-1)=="/"){
    outputs.nc <- ncdf4::nc_open(paste(path, "/", prefix, "_OUT.nc", sep = ""))
  }else{
    outputs.nc <- ncdf4::nc_open(paste(path, "/", prefix, "_OUT.nc", sep = ""))
  }
  return(outputs.nc)
}
