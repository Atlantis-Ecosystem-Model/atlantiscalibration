#' Edit the KDENR half-saturation density parameter for a species
#'
#' Multiplies every value in the KDENR vector for a species by a user-supplied
#' factor.  The header line is found by the pattern \code{KDENR_<species>};
#' the numeric values reside two lines below the header (Atlantis \code{.prm}
#' convention for vector parameters).
#'
#' @param bio.lines Character vector of lines read from the biology \code{.prm}
#'   file, typically the result of \code{readLines()}.
#' @param factor Numeric multiplier applied to every element of the KDENR
#'   vector.
#' @param species Character string with the species code used in the Atlantis
#'   configuration (e.g. \code{"CHY"}).
#'
#' @return The modified \code{bio.lines} vector with the KDENR values for
#'   \code{species} updated.
#' @export
#'
#' @examples
#' \dontrun{
#'   bio.lines <- readLines("AMPSbioparam.prm")
#'   bio.lines <- edit_param_KDENR_sp(bio.lines, factor = 1.5, species = "CHY")
#'   writeLines(bio.lines, "AMPSbioparam.prm")
#' }
edit_param_KDENR_sp = function(bio.lines, factor, species){

  # Locate the KDENR_<species> header line
  bio.lines = bio.lines
  pattern = paste0('KDENR_',species)
  bio.lines.id = grep(pattern,bio.lines)
  bio.lines.vals1 = bio.lines[bio.lines.id]
  if (length(bio.lines.vals1)==0) stop("The species does not have KDENR parameter")

  # Values are on the line two rows below the header (standard .prm vector layout)
  bio.lines.vals1 = bio.lines[bio.lines.id + 2]
  value <- as.numeric(unlist(strsplit(bio.lines.vals1, "   ")))*factor
  value[is.na(value)] <- ""
  new.line <- paste0(paste(as.character(value), collapse = "   "), "   ")
  bio.lines[bio.lines.id + 2] <- new.line

  return(bio.lines)
}



