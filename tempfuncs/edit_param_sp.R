
#' Edit a biology parameter for a species by name
#'
#' Dispatcher that routes to the appropriate parameter-editing function based on
#' the value of \code{param}.  Accepted parameter names (case-insensitive):
#' \code{"mum"}, \code{"bhbeta"}, \code{"bhaphla"}, \code{"mq"}.
#'
#' @param bio.lines Character vector of lines from the biology \code{.prm}
#'   file, typically the result of \code{readLines()}.
#' @param param Character string naming the parameter to edit.  Must be one of
#'   \code{"mum"}, \code{"bhbeta"}, \code{"bhaphla"}, or \code{"mq"}
#'   (case-insensitive).
#' @param factor Numeric multiplier applied to the current parameter value.
#' @param species Character string with the species code used in the Atlantis
#'   configuration (e.g. \code{"CHY"}).
#'
#' @return The modified \code{bio.lines} vector.
#' @export
#'
#' @examples
#' \dontrun{
#'   bio.lines <- readLines("AMPSbioparam.prm")
#'   bio.lines <- edit_param_sp(bio.lines, param = "mum", factor = 1.1, species = "CHY")
#'   writeLines(bio.lines, "AMPSbioparam.prm")
#' }
edit_param_sp = function(bio.lines, param, factor, species){
  if (tolower(param) == "mum"){
    bio.lines <- edit_param_mum_sp(bio.lines, factor, species)
  }
  if (tolower(param) == "bhbeta"){
    bio.lines <- edit_param_BHbeta_sp(bio.lines, factor, species)
  }
  if (tolower(param) == "bhaphla"){
    bio.lines <- edit_param_BHalpha_sp(bio.lines, factor, species)
  }
  if (tolower(param) == "mq"){
    bio.lines <- edit_param_mq_sp(bio.lines, factor, species)
  }

  return(bio.lines)

}
