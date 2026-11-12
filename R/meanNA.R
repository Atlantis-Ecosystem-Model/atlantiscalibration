#' Mean ignoring missing values
#'
#' Shorthand for \code{mean(x, na.rm = TRUE)}.
#'
#' @param x Numeric vector.
#'
#' @return Numeric.  The mean of the non-missing values of \code{x}.
#' @keywords internal
#'
#' @examples
#' \dontrun{
#'   meanNA(c(1, 2, NA))
#' }
meanNA <- function(x){return(mean(x, na.rm = T))}

