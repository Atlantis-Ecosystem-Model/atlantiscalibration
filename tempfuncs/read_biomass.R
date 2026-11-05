# Function to read biomass outputs


#' Extract total biomass from Atlantis outputs
#'
#' Reads biomass for all functional groups from either the main NetCDF output
#' (\code{txt = FALSE}) or the text summary file \code{_OUTBiomIndx.txt}
#' (\code{txt = TRUE}).  When reading from NetCDF, spatial nitrogen
#' concentrations are converted to tonnes using
#' \eqn{N \times V \times 5.7 \times 20 / 10^9}, where 5.7 is the
#' nitrogen-to-carbon Redfield ratio and 20 converts mg C to mg wet weight.
#'
#' @param path Character.  Path to the directory containing Atlantis outputs.
#' @param prefix Character.  Prefix of the Atlantis configuration (e.g.
#'   \code{"AMPS"}).
#' @param fg.file Character.  Path to the functional groups CSV file.
#' @param txt Logical.  If \code{FALSE} (default) read from NetCDF; if
#'   \code{TRUE} read from \code{<prefix>_OUTBiomIndx.txt}.
#' @param dt.timeserie Integer.  When \code{txt = TRUE}, number of most recent
#'   time steps to retain.  Use \code{NA} (default) to keep all rows.
#'
#' @return A named list with one element per functional group.  Each element is
#'   a numeric vector of total biomass (tonnes wet weight), one value per time
#'   step.
#' @export
#'
#' @examples
#' \dontrun{
#'   biomass <- extract_biomass_main(
#'     path    = "path/to/atlantis/outputs",
#'     prefix  = "AMPS",
#'     fg.file = "PugetSoundAtlantisFunctionalGroups.csv"
#'   )
#' }
extract_biomass_main <- function(path, prefix = NULL, fg.file, txt = F, dt.timeserie = NA){
  if (txt == F){
  outputs.nc <-open_main_nc(path, prefix = prefix)

  fg <- process_fg(fg.file)


  vn <- c(paste0(fg$Name,"_N")) # variable name is functional group + "_N"
  ts <- ncdf4::ncvar_get(outputs.nc,varid = "t") %>% as.numeric
  tyrs <- ts/(60*60*24*365) # from s to yrs

  Ndat <- purrr::map(1:length(vn), function(x) ncdf4::ncvar_get(outputs.nc,vn[x]))
  names(Ndat)<- vn

  biomass <- lapply(X = Ndat, FUN = calculate_biomass, fg.file = fg, name = names(Ndat), outputs.nc = outputs.nc)

  names(biomass) <- fg$Name
  }
  if (txt==T){
    fg <- process_fg(fg.file)
    num <- length(fg$Code)

    outputs.txt <- read.table(paste0(path, "/",prefix, "_OUTBiomIndx.txt"), header = T)[,2:(num+1)]
    code_indices <- match(names(outputs.txt), fg$Code)
    names(outputs.txt) <- fg$Name[code_indices]

    if(!is.na(dt.timeserie)){
      length.ts <- dim(outputs.txt)[1]
      outputs.txt <- outputs.txt[(length.ts-dt.timeserie+1):length.ts,]}
    biomass <- lapply(X = outputs.txt, FUN = as.numeric)

  }

  return(biomass)
}

#' Convert a spatial nitrogen array to a total biomass time series
#'
#' Multiplies nitrogen concentration (mg N/m\eqn{^3}) by cell volume (m\eqn{^3})
#' and applies \eqn{5.7 \times 20 / 10^9} to convert to tonnes wet weight.
#' For 3-D groups (vertebrates, plankton) the full volume array is used; for
#' 2-D benthic groups layer 7 volumes serve as a proxy for cell area
#' (layer 7 is 1 m deep, so volume \eqn{\approx} area).
#'
#' @param biomass_array Numeric array from \code{ncdf4::ncvar_get()} for a
#'   \code{_N} variable.  Either 3-D (boxes x layers x time) or 2-D
#'   (boxes x time).
#' @param fg.file Data frame of functional group metadata (output of
#'   \code{\link{process_fg}}).
#' @param name Character.  Variable name (e.g. \code{"CHY_N"}).
#' @param outputs.nc An open \code{ncdf4} connection to the main output file,
#'   used to read the \code{volume} variable.
#'
#' @return Numeric vector of total biomass in tonnes wet weight, one value per
#'   time step.
#' @export
#'
#' @examples
#'
calculate_biomass <- function(biomass_array, fg.file, name, outputs.nc) {

  volumes <- ncdf4::ncvar_get(outputs.nc, "volume")
  volumes_arr <- array(data = unlist(volumes),dim = dim(volumes)[c(1,2)]) # box/layer volumes

  # Layer 7 is 1 m deep, so its volume equals the horizontal cell area (m^2)
  areas_vec <- volumes_arr[7,]

  if(length(dim(biomass_array))==3) {
    totbio <- apply(biomass_array * c(volumes_arr) * (5.7 * 20 / 10^9), 3, sum, na.rm = TRUE)
  } else {
    if (length(dim(biomass_array))==0) {
      totbio = 0
    }else {

      totbio <- apply(biomass_array * areas_vec * (5.7 * 20 / 10^9), 2, sum, na.rm = TRUE)
    }
  }


  # if(btype == "vertebrate" | btype == "plankton") {
  #   totbio <- apply(biomass_array * c(volumes_arr) * (5.7 * 20 / 10^9), 3, sum, na.rm = TRUE)
  # } else if(btype == "2D") {
  #   totbio <- apply(biomass_array * areas_vec * (5.7 * 20 / 10^9), 2, sum, na.rm = TRUE)
  # } else if(btype == "other") {
  #   sum_volumes <- sum(volumes$volume)
  #   totbio <- apply(biomass_array * c(volumes_arr), 3, sum, na.rm = TRUE) / sum_volumes
  # }
  return(totbio)
}


