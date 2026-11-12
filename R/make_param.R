#' Create a block of calibration parameters
#'
#' Builds the rows of the calibration parameters table for one parameter type,
#' with one row per functional group.  Parameters are factors applied to the
#' original values, so they start at \code{paropt = 0} with bounds
#' \code{-1} to \code{1}, in phase \code{1}.
#'
#' @param prefix Character.  Prefix of the parameter name (e.g. \code{"mum_"}).
#' @param codes Character vector.  Functional group codes.
#' @param suffix Character.  Suffix of the parameter name (e.g.
#'   \code{"_factor"}).
#'
#' @return A data frame with columns \code{names}, \code{paropt},
#'   \code{parmin}, \code{parmax} and \code{parphase}, and one row per code.
#'   If \code{codes} is empty, a data frame with zero rows.
#' @keywords internal
#'
#' @examples
#' \dontrun{
#'   make_param("mum_", c("FPS", "FPL"), "_factor")
#' }
make_param <- function(prefix, codes, suffix){
  names <- if (length(codes) > 0) paste0(prefix, codes, suffix) else character(0)
  data.frame(
    names = names,
    paropt = rep(0, length(names)),
    parmin = rep(-1, length(names)),
    parmax = rep(1, length(names)),
    parphase = rep(1, length(names))
  )
}
