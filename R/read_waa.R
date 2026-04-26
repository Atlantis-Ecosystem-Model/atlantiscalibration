# Function to read weight-at-age outputs


#' Extract mean weight-at-age from Atlantis outputs
#'
#' Computes weight-at-age (tonnes wet weight per individual) for each age-class
#' group by combining reserve nitrogen (\code{_ResN}) and structural nitrogen
#' (\code{_StructN}), weighted by the relative spatial abundance of each
#' cohort.  The conversion from mg N to tonnes wet weight uses
#' \eqn{20 \times 5.7 / 10^6} (C:N Redfield ratio times energy conversion,
#' scaled to tonnes).
#'
#' @param path Character.  Path to the directory containing Atlantis outputs.
#' @param prefix Character.  Prefix of the Atlantis configuration (e.g.
#'   \code{"AMPS"}).
#'
#' @return A named list with one element per age-class group.  Each element is
#'   a numeric vector of mean individual weight (tonnes wet weight), one value
#'   per time step.
#' @export
#'
#' @examples
#' \dontrun{
#'   waa <- extract_waa(
#'     path   = "path/to/atlantis/outputs",
#'     prefix = "AMPS"
#'   )
#' }
extract_waa <- function(path, prefix = NULL){ #TODO: delete boundary boxes automatically
  outputs.nc <-open_main_nc(path, prefix = prefix)
  vn <- names(outputs.nc$var)[grep("_ResN",outputs.nc$var)]
  data_Res <- purrr::map(1:length(vn), function(x) ncdf4::ncvar_get(outputs.nc,vn[x]))
  names(data_Res)<- vn

  vn <- names(outputs.nc$var)[grep("_StructN",outputs.nc$var)]
  data_Str <- purrr::map(1:length(vn), function(x) ncdf4::ncvar_get(outputs.nc,vn[x]))
  names(data_Str)<- vn

  vn <- names(outputs.nc$var)[grep("_Nums",outputs.nc$var)]
  data_Nums <- purrr::map(1:length(vn), function(x) ncdf4::ncvar_get(outputs.nc,vn[x]))
  names(data_Nums)<- vn

  # Total numbers per age group and time step (sum over all boxes/layers)
  totnums <- data_Nums %>% purrr::map(apply, MARGIN = 3, FUN = sum)
  # Relative abundance: fraction of individuals in each box/layer per time step
  relnums <- purrr::map2(data_Nums, totnums, sweep, MARGIN = 3, FUN = `/`)

  # Weighted mean individual N = (StructN + ResN) * relative abundance;
  # multiply by 20*5.7/1e6 to convert mg N/individual -> tonnes wet weight
  wgt = lapply(purrr::map2(purrr::map2(data_Str, relnums, `*`),
                            purrr::map2(data_Res,  relnums, `*`), `+`),
               "*", 20 * 5.7 / 1e6) %>%
    purrr::map(apply, MARGIN = 3, FUN = sum)
  names(wgt) <- sub("_StructN", "", names(wgt))

  return(wgt)
}
