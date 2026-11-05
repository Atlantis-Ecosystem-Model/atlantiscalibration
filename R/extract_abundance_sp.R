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
