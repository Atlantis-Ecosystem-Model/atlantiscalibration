
#' @title Run one step of the Atlantis calibration model
#' @description
#' Core objective function designed for use with the \pkg{calibrar} package.
#' Receives a log-scale parameter vector, back-transforms it via \code{exp()},
#' writes a parameter snapshot CSV, edits the relevant entries in the Atlantis
#' biology parameter file (\code{bio.prm}), executes the simulation via a shell
#' script, reads the outputs, and returns a named list of modeled indicators
#' for comparison against observations.
#'
#' Parameter names in \code{names} must follow the convention
#' \code{<type>_<species>_factor} for biology parameters (e.g.
#' \code{"mum_CHY_factor"}, \code{"BHalpha_CHY_factor"},
#' \code{"KDENR_CHY_factor"}) or \code{"<species>_mQ_factor"} for
#' catchability.
#'
#' @param bio.prm Character.  Path to the Atlantis biology parameter
#'   \code{.prm} file that will be edited in place.
#' @param param Numeric vector of parameters in log scale.  Back-transformed
#'   via \code{exp()} before use.
#' @param names Character vector of parameter names parallel to \code{param}.
#'   Used to assign names to \code{param} and to identify which parameter type
#'   each element belongs to.
#' @param param.file Character.  Path of the CSV file written with the
#'   back-transformed parameter values at each iteration.  Default:
#'   \code{"calibration-parameters.csv"}.
#' @param sh.file Character.  Name of the shell script used to launch the
#'   Atlantis run.  Default: \code{"amps_cal.sh"}.
#' @param prefix Character.  Prefix path for the Atlantis NetCDF output files
#'   (e.g. \code{"outputFolder/AMPS"}).  Default: \code{"outputFolder/AMPS"}.
#' @param fg.file Character.  Path to the functional groups CSV file containing
#'   at minimum the columns \code{Code}, \code{Name}, \code{NumCohorts}, and
#'   \code{IsTurnedOn}.  Default: \code{<path>/PugetSoundAtlantisFunctionalGroups_2024_V1.csv}.
#' @param biom.indx Character.  Relative path to the biomass index text file
#'   used to detect whether the simulation completed.  Default:
#'   \code{"outputFolder/AMPS_OUTBiomIndx.txt"}.
#'
#' @return A named list of modeled output indicators.  Biomass elements are
#'   named \code{<Code>_biomass} where \code{Code} comes from the functional
#'   groups CSV (e.g. \code{MA_biomass}).  Weight-at-age elements are named
#'   \code{<Name><age>_w} where \code{Name} is the functional group long name
#'   and \code{age} runs from \code{1} to \code{NumCohorts}
#'   (e.g. \code{ChinookY_Fish1_w}, \code{Trans_Orca10_w}).  If the simulation
#'   stopped prematurely all indicators are zero-filled vectors of length
#'   \code{dt.timestep}.
run_model   <-  function(bio.prm,
                     param,
                     names,
                     param.file="calibration-parameters.csv",
                     sh.file,
                     prefix,
                     bio.prm,
                     fg.file,
                     biom.indx
) {

  # set parameter names
  names(param) = names
  param = exp(param)
  write.table(param, file=param.file, sep=",",
              col.names=FALSE, quote=FALSE)
  mum.factor = grep(x=names, pattern="mum")
  BHalpha.factor = grep(x=names, pattern="BHalpha")
  mq.factor = grep(x=names, pattern="mQ")
  KDENR.factor = grep(x=names, pattern="KDENR_")
  bio.lines = readLines(bio.prm)

    for (i in 1:length(mum.factor)){
      species <- names[mum.factor[i]]
      factor  <- param[mum.factor[i]]
      species <- sub("mum_", "", species)
      species <- sub("_factor", "", species)

      bio.lines = atlantis2ls::edit_param_mum_sp(bio.lines, factor, species)
    }
    for (i in 1:length(BHalpha.factor)){
      species <- names[BHalpha.factor[i]]
      factor  <- param[BHalpha.factor[i]]
      species <- sub("BHalpha_", "", species)
      species <- sub("_factor", "", species)

      bio.lines = atlantis2ls::edit_param_BHalpha_sp(bio.lines, factor, species)
    }

    for (i in 1:length(KDENR.factor)){
      species <- names[KDENR.factor[i]]
      factor  <- param[KDENR.factor[i]]
      species <- sub("KDENR_", "", species)
      species <- sub("_factor", "", species)
      bio.lines = atlantis2ls::edit_param_KDENR_sp(bio.lines, factor, species)
    }

    for (i in 1:length(mq.factor)){
      species <- names[mq.factor[i]]
      factor  <- param[mq.factor[i]]
      species <- sub("_mQ_factor", "", species)
      bio.lines = atlantis2ls::edit_param_mq_sp(bio.lines, factor, species)
    }

    writeLines(bio.lines, "bio.prm")


##########################################################################################
    # run Atlantis
    path = getwd()

    atlantis2ls::run_atlantis(path = path, sh.file = sh.file)

    outputs <- atlantis2ls::read_atlantis(path = path, prefix = prefix, fg.file = fg.file,
                                          txt.filename = biom.indx)


##########################################################################################

# Process the outputs so that calibrar like them
    if(length(atlantis.biomass)==2){
      # Check if the configuration has run, if not return 0
      dt.timestep = 2 # Equal to the number of timestep in data
      fg.data <- read.csv(fg.file)
      fg.data <- fg.data[fg.data$IsTurnedOn == 1, ]
      biomass_zeros <- setNames(
        lapply(fg.data$Code, function(x) rep(0, dt.timestep)),
        paste0(fg.data$Code, "_biomass")
      )
      waa_groups <- fg.data[fg.data$NumCohorts > 1, ]
      waa_names <- unlist(lapply(seq_len(nrow(waa_groups)), function(i)
        paste0(waa_groups$Name[i], seq_len(waa_groups$NumCohorts[i]), "_w")
      ))
      waa_zeros <- setNames(
        lapply(waa_names, function(x) rep(0, dt.timestep)),
        waa_names
      )
      output <- c(biomass_zeros, waa_zeros)

    }

    return(output)
}
