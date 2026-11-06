#' Multiply a parameter in an Atlantis parameter file by a factor
#'
#' Finds the parameter with \code{grep} and multiplies its value(s) by
#' \code{factor}.  Handles the two layouts used in Atlantis \code{.prm} files:
#' \itemize{
#'   \item Single value: \code{<name> <value> <comment>} (e.g.
#'     \code{BHalpha_FPS 2.00E+9 Alpha in Beverton-Holt}).  Parameters with
#'     the \code{_T15} suffix (e.g. \code{mum_ZS_T15}) are matched too.
#'   \item Array: \code{<name> <n>}, with the \code{n} values on the next line
#'     (e.g. \code{mum_FPS 10}).
#' }
#' Parameters that are not found, or found more than once, are left unchanged
#' with a warning.
#'
#' @param prm.lines Character vector of lines from an Atlantis \code{.prm}
#'   file, typically the result of \code{readLines()}.
#' @param name Character.  Name of the parameter in the \code{.prm} file
#'   (e.g. \code{"mum_FPS"}, \code{"ZS_mQ"}, \code{"mFC_FPS"}).
#' @param factor Numeric.  Factor applied to the parameter value(s).
#'
#' @return The modified \code{prm.lines}.
#' @export
#'
#' @examples
#' \dontrun{
#'   bio.lines <- readLines("VMPA_setas_biol_fishing_Trunk.prm")
#'   bio.lines <- edit_param_factor(bio.lines, "mum_FPS", 1.2)
#' }
edit_param_factor <- function(prm.lines, name, factor){

  id <- grep(paste0("^", name, "(_T15)?(\\s|$)"), prm.lines)

  if (length(id) != 1){
    warning("Found ", length(id), " lines for parameter ", name, "; not edited")
    return(prm.lines)
  }

  tokens <- strsplit(trimws(prm.lines[id]), "\\s+")[[1]]

  # Array layout: "<name> <n>" followed by a line with n numeric values
  n <- suppressWarnings(as.integer(tokens[2]))
  next.values <- if (id < length(prm.lines)) {
    suppressWarnings(as.numeric(strsplit(trimws(prm.lines[id + 1]), "\\s+")[[1]]))
  } else numeric(0)
  is.array <- length(tokens) == 2 && !is.na(n) && length(next.values) == n && !anyNA(next.values)

  if (is.array){
    prm.lines[id + 1] <- paste(next.values * factor, collapse = " ")
  } else {
    value <- suppressWarnings(as.numeric(tokens[2]))
    if (is.na(value)){
      warning("Could not read a value for parameter ", name, "; not edited")
      return(prm.lines)
    }
    prm.lines[id] <- sub("^(\\S+\\s+)\\S+", paste0("\\1", value * factor), prm.lines[id])
  }

  prm.lines
}
