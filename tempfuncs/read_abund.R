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

#' Extract and sum abundance for a single species across age classes
#'
#' Calls \code{\link{extract_abundance_grp}} and then sums abundance across all
#' age-class groups whose variable name contains the species code.
#'
#' @param path Character.  Path to the directory containing Atlantis outputs.
#' @param prefix Character.  Prefix of the Atlantis configuration.
#' @param species Character.  Species code to match against variable names
#'   (e.g. \code{"CHY"}).
#'
#' @return Numeric vector of total abundance summed across matched age-class
#'   groups and all spatial cells, one value per time step.  Returns \code{NA}
#'   if no matching variables are found.
#' @export
#'
#' @examples
#' \dontrun{
#'   abund_chy <- extract_abundance_sp(
#'     path    = "path/to/atlantis/outputs",
#'     prefix  = "AMPS",
#'     species = "CHY"
#'   )
#' }
extract_abundance_sp <- function(path, prefix = NULL, species){
  data <- extract_abundance_grp(path, prefix = prefix)
  i.species = grep(species,names(data))
  if (length(i.species)>0){
    return(Reduce('+', data[i.species]))
  }else{
    return(NA)
  }
}

#' Extract abundance for all functional groups defined in a groups file
#'
#' Loops over functional groups listed in \code{fg.file} and calls
#' \code{\link{extract_abundance_sp}} for each, returning a named list.
#'
#' @param path Character.  Path to the directory containing Atlantis outputs.
#' @param prefix Character.  Prefix of the Atlantis configuration.
#' @param fg.file Character.  Path to the functional groups CSV file.
#'
#' @return A named list (names = functional group names) where each element is
#'   the summed abundance time series for that group.
#' @export
#'
#' @examples
#' \dontrun{
#'   abund_all <- extract_abund_main(
#'     path    = "path/to/atlantis/outputs",
#'     prefix  = "AMPS",
#'     fg.file = "PugetSoundAtlantisFunctionalGroups.csv"
#'   )
#' }
extract_abund_main <- function(path, prefix = NULL, fg.file){
  fg <- process_fg(fg.file)
  abund <- lapply(X = fg$Name, FUN = extract_abundance_sp, path = path, prefix = prefix)
  names(abund) <- fg$Name
  return(abund)
}

#' Collapse an abundance array to a time series
#'
#' Sums a 3-D abundance array (boxes x layers x time) over all boxes and
#' layers, returning one total per time step.
#'
#' @param abund_array Numeric 3-D array as returned by
#'   \code{ncdf4::ncvar_get()} for a \code{_Nums} variable
#'   (boxes x layers x time).
#'
#' @return Numeric vector of total abundance, one value per time step.
#' @export
#'
#' @examples
calculate_abund <- function(abund_array) {
  return(apply(abund_array , 3, sum, na.rm = TRUE))
}
