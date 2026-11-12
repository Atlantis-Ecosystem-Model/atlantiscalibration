#' Sum ignoring missing values
#'
#' Shorthand for \code{sum(x, na.rm = TRUE)}.
#'
#' @param x Numeric vector.
#'
#' @return Numeric.  The sum of the non-missing values of \code{x}.
#' @keywords internal
#'
#' @examples
#' \dontrun{
#'   sumNA(c(1, 2, NA))
#' }
sumNA <- function(x){return(sum(x, na.rm = T))}
