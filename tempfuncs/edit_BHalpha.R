#' Edit the BHalpha Beverton-Holt recruitment parameter for a species
#'
#' Multiplies the current BHalpha value in the Atlantis biology parameter file
#' by a user-supplied factor.  The target line is identified by the pattern
#' \code{BHalpha_<species>}; name and value are expected to be separated by
#' three spaces.
#'
#' @param bio.lines Character vector of lines read from the biology \code{.prm}
#'   file, typically the result of \code{readLines()}.
#' @param factor Numeric multiplier applied to the current BHalpha value.
#' @param species Character string with the species code used in the Atlantis
#'   configuration (e.g. \code{"CHY"}).
#'
#' @return The modified \code{bio.lines} vector with the BHalpha line for
#'   \code{species} updated.
#' @export
#'
#' @examples
#' \dontrun{
#'   bio.lines <- readLines("AMPSbioparam.prm")
#'   bio.lines <- edit_param_BHalpha_sp(bio.lines, factor = 1.2, species = "CHY")
#'   writeLines(bio.lines, "AMPSbioparam.prm")
#' }
edit_param_BHalpha_sp = function(bio.lines, factor, species){

  bio.lines = bio.lines
  pattern = paste0('BHalpha_',species)
  bio.lines.id = grep(pattern,bio.lines)
  bio.lines.vals1 = bio.lines[bio.lines.id]
  if (length(bio.lines.vals1)==0) stop("The species does not have a BHalpha parameter")
  value <- as.numeric(unlist(strsplit(bio.lines.vals1, "   "))[2])*factor
  name <- unlist(strsplit(bio.lines.vals1, "   "))[1]
  new.line <- paste0(name, "   ", value)
  bio.lines[bio.lines.id] <- new.line

  return(bio.lines)
}

