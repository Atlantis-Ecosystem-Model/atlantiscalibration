#' Extract total biomass of each functional group from Atlantis outputs
#'
#' Reads the biomass of each active functional group either from the main
#' output NetCDF file (\code{<group>_N} variables converted to tonnes wet
#' weight with \code{\link{calculate_biomass}}) or from the
#' \code{<prefix>_OUTBiomIndx.txt} text output.
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


    ts <- ncdf4::ncvar_get(outputs.nc,varid = "t") |> as.numeric()
    tyrs <- ts/(60*60*24*365) # from s to yrs
    all.var <- names(outputs.nc$var)

    # variable name is functional group + "_N"; stage-structured groups
    # (e.g. cephalopods) have one variable per stage, <Name>_N1, <Name>_N2, ...
    biomass <- lapply(fg$Name, function(name){
      vn <- paste0(name, "_N")
      if (!vn %in% all.var) vn <- grep(paste0("^", name, "_N[0-9]+$"), all.var, value = TRUE)
      if (length(vn) == 0){
        warning("No nitrogen variable found for ", name, "; biomass set to 0")
        return(rep(0, length(ts)))
      }
      Reduce(`+`, lapply(vn, function(x) calculate_biomass(ncdf4::ncvar_get(outputs.nc, x),
                                                            fg.file = fg, name = x, outputs.nc = outputs.nc)))
    })

    names(biomass) <- fg$Name
  }
  if (txt==T){
    fg <- process_fg(fg.file)
    num <- length(fg$Code)

    outputs.txt <- utils::read.table(paste0(path, "/",prefix, "_OUTBiomIndx.txt"), header = T)[,2:(num+1)]
    code_indices <- match(names(outputs.txt), fg$Code)
    names(outputs.txt) <- fg$Name[code_indices]

    if(!is.na(dt.timeserie)){
      length.ts <- dim(outputs.txt)[1]
      outputs.txt <- outputs.txt[(length.ts-dt.timeserie+1):length.ts,]}
    biomass <- lapply(X = outputs.txt, FUN = as.numeric)

  }

  return(biomass)
}
