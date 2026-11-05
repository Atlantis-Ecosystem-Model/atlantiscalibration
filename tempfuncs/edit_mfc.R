#' Edit the maximum fishing capacity (mFC) parameter for a species
#'
#' Multiplies every value in the mFC vector for a species by a user-supplied
#' factor.  The header line is found by the pattern \code{mFC_<species>};
#' the numeric values reside one line below the header (Atlantis harvest
#' \code{.prm} convention).
#'
#' @param harvest.lines Character vector of lines read from the harvest
#'   \code{.prm} file, typically the result of \code{readLines()}.
#' @param factor Numeric multiplier applied to every element of the mFC vector.
#' @param species Character string with the species code used in the Atlantis
#'   configuration (e.g. \code{"CHY"}).
#'
#' @return The modified \code{harvest.lines} vector with the mFC values for
#'   \code{species} updated.
#' @export
#'
#' @examples
#' \dontrun{
#'   harvest.lines <- readLines("AMPSharvest.prm")
#'   harvest.lines <- edit_param_mfc(harvest.lines, factor = 0.5, species = "CHY")
#'   writeLines(harvest.lines, "AMPSharvest.prm")
#' }
edit_param_mfc = function(harvest.lines, factor, species){

  # Locate the mFC_<species> header line
  harvest.lines = harvest.lines
  pattern = paste0('mFC_',species)
  harvest.lines.id = grep(pattern,harvest.lines)
  harvest.lines.vals1 = harvest.lines[harvest.lines.id]
  if (length(harvest.lines.vals1)==0) stop("The species does not have mfc parameter")

  # Values are on the line immediately below the header (standard harvest .prm layout)
  harvest.lines.vals1 = harvest.lines[harvest.lines.id + 1]
  value <- as.numeric(unlist(strsplit(harvest.lines.vals1, " ")))*factor
  value[is.na(value)] <- ""
  new.line <- paste0(paste(as.character(value), collapse = " "), " ")
  harvest.lines[harvest.lines.id + 1] <- new.line

  return(harvest.lines)
}
