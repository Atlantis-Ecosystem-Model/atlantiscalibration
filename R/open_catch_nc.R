#' Open the Atlantis catch NetCDF output file
#'
#' Opens the \code{<prefix>_OUTCATCH.nc} file found in \code{path}, or
#' \code{<prefix>CATCH.nc} if it does not exist, using
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
#'   catch.nc <- open_catch_nc(path = "path/to/atlantis/outputs", prefix = "AMPS")
#'   ncdf4::nc_close(catch.nc)
#' }
open_catch_nc <- function(path, prefix = NULL) {
  if(is.null(prefix)) stop("Add prefix argument for your Atlantis configuration")
  # <prefix>_OUTCATCH.nc (e.g. -o AMPS_OUT.nc) or <prefix>CATCH.nc (e.g. -o outputSETAS.nc)
  nc.file <- file.path(path, paste0(prefix, "_OUTCATCH.nc"))
  if(!file.exists(nc.file)) nc.file <- file.path(path, paste0(prefix, "CATCH.nc"))
  outputs.nc <- ncdf4::nc_open(nc.file)
  return(outputs.nc)
}
