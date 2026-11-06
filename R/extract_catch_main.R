# Function to read catch outputs

#' Extract catch (landings) time series from Atlantis outputs
#'
#' When fishery is active, reads the \code{_Catch_FC} variables from the catch
#' NetCDF file and sums across all fleet dimensions for each species.  When
#' fishery is inactive, returns a zero-filled list for every functional group.
#'
#' @param path Character.  Path to the directory containing Atlantis outputs.
#' @param prefix Character.  Prefix of the Atlantis configuration (e.g.
#'   \code{"AMPS"}).
#' @param fg.file Character.  Path to the functional groups CSV file.
#' @param dt.timeserie Integer.  Number of time steps in the run, used to
#'   size the zero-filled catch vectors when \code{fishery = FALSE}.
#' @param fishery Logical.  Whether the fishery module was activated in this
#'   Atlantis run.
#' @param ... Additional arguments (currently unused).
#'
#' @return A named list with one element per functional group.  Each element is
#'   a numeric vector of total catch summed across all fleets, one value per
#'   time step.  Returns zeros for all groups when \code{fishery = FALSE}.
#' @export
#'
#' @examples
#' \dontrun{
#'   catch <- extract_catch_main(
#'     path         = "path/to/atlantis/outputs",
#'     prefix       = "AMPS",
#'     fg.file      = "PugetSoundAtlantisFunctionalGroups.csv",
#'     dt.timeserie = 50,
#'     fishery      = TRUE
#'   )
#' }
extract_catch_main <- function(path, prefix = NULL, fg.file, dt.timeserie, fishery, ...){
  fg <- process_fg(fg.file)

  if (fishery == F){
    fg <- process_fg(fg.file)
    catch <- rep(list(rep(0,dt.timeserie)),length(fg$Name))
    names(catch) <- fg$Name
    print("Creating 0 for catches as Fishery is not activating")
  }else{
    print("Reading catch outputs")
    outputs.nc <-open_catch_nc(path, prefix = prefix)

    fg <- process_fg(fg.file)

    all.var <- names(outputs.nc$var)
    vn <-  all.var[grep("_Catch", all.var)]
    vn <-  vn[grep("_FC", vn)]
    ts <- ncdf4::ncvar_get(outputs.nc,varid = "t") |> as.numeric()
    tyrs <- ts/(60*60*24*365) # from s to yrs


    Ndat <- purrr::map(1:length(vn), function(x) ncdf4::ncvar_get(outputs.nc,vn[x]))
    names(Ndat)<- vn
    catch<-list()

    species_code <- stringr::str_extract(names(Ndat), "^[^_]*")
    for (i in unique(species_code)){
      Name <- fg$Name[fg$Code==i]
      # groups that are turned off are not in fg
      if (length(Name) == 0) next
      # sum over boxes for each fleet, then over all fleets catching the group
      fleets <- lapply(Ndat[species_code==i], function(x) apply(x, MARGIN = 2, FUN = sum))
      catch[[Name]] <- Reduce(`+`, fleets)
    }
  }
  return(catch)
}
