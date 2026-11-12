
#' @title Run one step of the Atlantis calibration model
#' @description
#' Model function called by \pkg{calibrar} at every parameter proposal.
#' Receives a log-scale parameter vector, back-transforms it via \code{exp()},
#' writes a parameter snapshot CSV, edits the relevant entries in the Atlantis
#' biology (and harvest) parameter files, executes the simulation via a shell
#' script, reads the outputs, and returns a named list of modeled indicators
#' for comparison against observations.
#'
#' \pkg{calibrar} calls this function as \code{run_model(par, ...)}, where
#' \code{...} are the extra arguments given to \code{\link{make_objfn}}.  It
#' runs in the working directory set by \pkg{calibrar} (a copy of
#' \code{control$master}), so all file names are relative to that directory.
#'
#' The parameters edited are those in \code{names}, as created from the
#' parameter table by \code{\link{create_target_files_biomass}}.  Each factor
#' multiplies the original value(s) in the \code{.prm} file (see
#' \code{\link{edit_param_factor}}).  Parameter names in \code{names} must
#' follow these conventions (other names stop with an error):
#' \itemize{
#'   \item \code{mum}, \code{BHalpha}, \code{BHbeta}, \code{KDENR},
#'     \code{C} and \code{E}: \code{<type>_<Code>_factor} (e.g.
#'     \code{"mum_FPS_factor"}), edited in the biology parameter file.
#'   \item \code{mQ} and \code{mL}: \code{<Code>_<type>_factor} (e.g.
#'     \code{"ZS_mQ_factor"}), edited in the biology parameter file.
#'   \item \code{mfc}: \code{mfc_<Code>_factor}, edited as \code{mFC_<Code>}
#'     in the harvest parameter file.
#' }
#' The shell script that runs Atlantis is the only file with extension
#' \code{.sh} in the working directory, and the biology and harvest parameter
#' files are those given to its options \code{-b} and \code{-h} (see
#' \code{\link{read_sh_file}}).  The edited parameters are written to these
#' same files, so Atlantis runs with them.  The first time \code{run_model()}
#' runs in a directory, each original file is copied to
#' \code{<file>.original}; the factors are always applied to the values in
#' this copy, so they are not applied twice when a directory is reused.
#'
#' The output list has one element per target in \code{variables}, matched
#' by the suffix of the target name:
#' \itemize{
#'   \item \code{<Code>_biomass}: total biomass of the group.
#'   \item \code{<Name><age>_w}: mean weight at age.
#'   \item \code{<Name>_catch}: total catch of the group, summed over fleets.
#'   \item \code{<Name>_Nums}: matrix of abundance with one column per age
#'     class.
#' }
#' Only the last \code{dt.timeseries} time steps of each output are returned,
#' to match the length of the targets.  If the simulation crashed or stopped
#' before \code{tstop}, all outputs are zeros.
#'
#' @param param Numeric vector of parameters in log scale.  Back-transformed
#'   via \code{exp()} before use.
#' @param names Character vector of parameter names parallel to \code{param}.
#' @param variables Character vector.  Names of the calibration targets
#'   (\code{setup$variable}), which are the names of the returned list.
#' @param prefix Character.  Prefix path for the Atlantis NetCDF output files
#'   (e.g. \code{"outputFolder/AMPS"}).
#' @param fg.file Character.  Name of the functional groups CSV file.
#' @param biom.indx Character.  Relative path to the biomass index text file
#'   written by the run (e.g. \code{"outputFolder/AMPS_OUTBiomIndx.txt"}),
#'   used to detect whether the simulation completed.
#' @param run.prm Character.  Name of the Atlantis run parameter file, used
#'   to read \code{tstop}.
#' @param dt.timeseries Integer.  Number of time steps in each target.
#' @param param.file Character.  Name of the CSV file written with the
#'   back-transformed parameter values at each run.  Default:
#'   \code{"calibration-parameters.csv"}.
#' @param track.path Character.  Absolute path of the folder where the
#'   parameter files used in each run are saved (see
#'   \code{\link{keep_track_prm}}).  If \code{NULL} (default), they are not
#'   saved.
#' @param ... Other arguments passed by \pkg{calibrar} (e.g. \code{forcing}),
#'   not used.
#'
#' @return A named list of modeled output indicators, one element per target
#'   in \code{variables}.
#' @export
run_model <- function(param,
                      names,
                      variables,
                      prefix,
                      fg.file,
                      biom.indx,
                      run.prm,
                      dt.timeseries,
                      param.file = "calibration-parameters.csv",
                      track.path = NULL,
                      ...) {

  # set parameter names
  names(param) = names
  param = exp(param)
  utils::write.table(param, file=param.file, sep=",",
              col.names=FALSE, quote=FALSE)

  # Names of the calibrated factors for each parameter type
  patterns <- c(
    "mum"     = "^mum_.+_factor$",     # maximum growth rate
    "BHalpha" = "^BHalpha_.+_factor$", # Beverton-Holt alpha
    "BHbeta"  = "^BHbeta_.+_factor$",  # Beverton-Holt beta
    "KDENR"   = "^KDENR_.+_factor$",   # recruits per adult
    "mfc"     = "^mfc_.+_factor$",     # fishing mortality
    "mQ"      = "^.+_mQ_factor$",      # quadratic mortality
    "mL"      = "^.+_mL_factor$",      # linear mortality
    "C"       = "^C_.+_factor$",       # clearance rate
    "E"       = "^E_.+_factor$"        # assimilation efficiency
  )

  # The parameter types to edit are those in the parameter names
  unknown <- names[!Reduce(`|`, lapply(patterns, grepl, x = names))]
  if (length(unknown) > 0){
    stop("Unknown parameter name(s): ", paste(unknown, collapse = ", "))
  }

  path = getwd()

  # Shell script (the .sh file) and the parameter files it gives to Atlantis
  sh <- read_sh_file(path)
  bio.prm <- unname(sh$files["b"])
  harvest.prm <- unname(sh$files["h"])

  # The edited parameters overwrite the files used by Atlantis, so the
  # original values are kept in <file>.original and always read from there,
  # so the factors are not applied twice if the directory is reused
  read_original <- function(prm.file){
    original <- paste0(prm.file, ".original")
    if (!file.exists(original)) file.copy(prm.file, original)
    readLines(original)
  }

  bio.lines = read_original(bio.prm)

  # mfc is in the harvest parameter file
  edit.harvest <- any(grepl(patterns[["mfc"]], names))
  if (edit.harvest){
    if (is.na(harvest.prm)) stop("The shell script ", sh$sh.file, " has no harvest file (-h), needed to calibrate mfc")
    harvest.lines = read_original(harvest.prm)
  }

  for (eachparameter in names(patterns)){

    for (eachname in grep(patterns[[eachparameter]], names, value = TRUE)){

      # Parameter name in the .prm file, e.g. mum_FPS_factor -> mum_FPS
      prm.name <- sub("_factor$", "", eachname)

      if (eachparameter == "mfc"){
        harvest.lines = edit_param_factor(harvest.lines, sub("^mfc_", "mFC_", prm.name), param[[eachname]])
      }else{
        bio.lines = edit_param_factor(bio.lines, prm.name, param[[eachname]])
      }
    }
  }

  writeLines(bio.lines, bio.prm)
  if (edit.harvest){
    writeLines(harvest.lines, harvest.prm)
  }

  # Keep track of the parameter files used in each run of each iteration
  if (!is.null(track.path)){
    keep_track_prm(path, track.path,
                   files = c(param.file, bio.prm, if (edit.harvest) harvest.prm))
  }

##########################################################################################
  # run Atlantis

  run_atlantis(path = path, sh.file = sh$sh.file)

##########################################################################################
  # Process the outputs so that calibrar like them

  fg <- process_fg(fg.file)

  is.biomass <- grepl("_biomass$", variables)
  is.waa     <- grepl("_w$", variables)
  is.catch   <- grepl("_catch$", variables)
  is.abund   <- grepl("_Nums$", variables)

  if (any(!(is.biomass | is.waa | is.catch | is.abund))){
    stop("Unknown target type for: ",
         paste(variables[!(is.biomass | is.waa | is.catch | is.abund)], collapse = ", "))
  }

  # Group name and number of age classes of each abundance target
  abund.names <- sub("_Nums$", "", variables[is.abund])
  n.ages <- fg$NumCohorts[match(abund.names, fg$Name)]

  # Last dt.timeseries values, to match the length of the targets
  last_steps <- function(x){
    x <- as.numeric(x)
    if (length(x) == 0) return(rep(0, dt.timeseries))
    x[max(1, length(x) - dt.timeseries + 1):length(x)]
  }

  output <- stats::setNames(vector("list", length(variables)), variables)

  crashed <- !file.exists(file.path(path, biom.indx)) ||
    is.stopped(path, biom.indx, run.prm)

  if (crashed){
    # The configuration did not run until tstop, return 0
    output[!is.abund] <- lapply(seq_len(sum(!is.abund)), function(x) rep(0, dt.timeseries))
    output[is.abund] <- lapply(n.ages, function(n) matrix(0, nrow = dt.timeseries, ncol = n))

  }else{

    outputs <- read_atlantis(path = path, prefix = prefix, fg.file = fg.file,
                             fishery = any(is.catch),
                             txt.filename = biom.indx, run.filename = run.prm,
                             dt.timeserie = dt.timeseries)

    # Biomass targets are named by group Code, outputs by group Name
    for (eachvariable in variables[is.biomass]){
      name <- fg$Name[fg$Code == sub("_biomass$", "", eachvariable)]
      output[[eachvariable]] <- last_steps(unlist(outputs$biomass[name]))
    }

    for (eachvariable in variables[is.waa]){
      output[[eachvariable]] <- last_steps(unlist(outputs$waa[sub("_w$", "", eachvariable)]))
    }

    for (eachvariable in variables[is.catch]){
      output[[eachvariable]] <- last_steps(unlist(outputs$landings[sub("_catch$", "", eachvariable)]))
    }

    # Abundance at age: one column per age class
    if (any(is.abund)){
      abund.age <- extract_abundance_grp(path, prefix = prefix)
      for (i in seq_along(abund.names)){
        ages <- lapply(seq_len(n.ages[i]), function(age)
          last_steps(abund.age[[paste0(abund.names[i], age, "_Nums")]]))
        output[[variables[is.abund][i]]] <- do.call(cbind, ages)
      }
    }
  }

  return(output)
}
