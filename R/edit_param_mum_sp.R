#' Edit natural mortality (mum) for a single species
#'
#' Multiplies the current mum value(s) for a species by a user-supplied factor.
#' For species with a single age class (T15 suffix), the scalar on the same
#' line is updated.  For multi-age-class species the numeric vector two lines
#' below the header is updated.
#'
#' @param bio.lines Character vector of lines from the biology \code{.prm}
#'   file, typically the result of \code{readLines()}.
#' @param factor Numeric multiplier applied to the current mum value(s).
#' @param species Character string with the species code used in the Atlantis
#'   configuration (e.g. \code{"CHY"}).
#'
#' @return The modified \code{bio.lines} vector with mum updated for
#'   \code{species}.
#' @export
#'
#' @examples
#' \dontrun{
#'   bio.lines <- readLines("AMPSbioparam.prm")
#'   bio.lines <- edit_param_mum_sp(bio.lines, factor = 0.9, species = "CHY")
#'   writeLines(bio.lines, "AMPSbioparam.prm")
#' }
edit_param_mum_sp  <- function(bio.lines, factor, species){

  #Get mum_XXX bio.prm lines
  bio.lines = bio.lines
  pattern = paste0('mum_',species)
  bio.lines.id = grep(pattern,bio.lines)
  bio.lines.vals1 = bio.lines[bio.lines.id]
  if (length(bio.lines.vals1)==0) stop("The species does not have mum parameter")

  if (length(grep("T15",bio.lines.vals1)) == 1){
    value <- as.numeric(unlist(strsplit(bio.lines.vals1, "   "))[2])*factor
    name <- unlist(strsplit(bio.lines.vals1, "   "))[1]
    new.line <- paste0(name, "   ", value)
    bio.lines[bio.lines.id] <- new.line
  }else{

    bio.lines.vals1 = bio.lines[bio.lines.id + 2]
    value <- as.numeric(unlist(strsplit(bio.lines.vals1, "   ")))*factor
    value[is.na(value)] <- ""
    new.line <- paste0(paste(as.character(value), collapse = "   "), "   ")
    bio.lines[bio.lines.id + 2] <- new.line
  }

  return(bio.lines)
}



