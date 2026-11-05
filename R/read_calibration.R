read_calibration <- function(calibration.settings, calibration.parameters){

   setup  <- calibrar::calibration_setup(file=here::here("inputs",calibration.settings))

   observed <- calibrar::calibration_data(setup = setup,
                                         path=here::here("inputs"),
                                         file = NULL,
                                         sep = ",")


  # load calibration parameters
  forcing = read.csv(file=here::here("inputs",calibration.parameters),
                     header=TRUE,
                     sep=",",
                     row.names=1)

  readr::write_csv(forcing, file=here::here("inputs","forcing.csv"))

  # create an objective function
  # additional arguments to the runModel function
  # are provided here.
  objfn = calibrar::calibration_objFn(model=runModel,
                                      setup=setup,
                                      observed=observed,
                                      aggregate=FALSE,
                                      forcing = forcing,
                                      names=row.names(forcing))

  control = list()
  control$maxit = c(5)   # maximum number of iterations (former gen.max parameter)
  control$maxgen = c(5)   # maximum number of iterations (former gen.max parameter)
  control$master = "/home/atlantis/psatlantismodel/Atlantis_Calibration/configuration/"   # directory that will be copied
  control$run = "/home/atlantis/psatlantismodel/Atlantis_Calibration/RUN"   # run directory
  control$restart.file = "/home/atlantis/psatlantismodel/Atlantis_Calibration/restart_file"   # name of the restart file
  control$REPORT = 1    # number of iterations to run before saving a restart
  control$parallel = TRUE
  control$nCores = 32
  control$popsize = 32  # population  size (former seed parameter)
  control$trace = 3 #global fitness and partial fitness

  saveRDS(control, file = here::here("inputs","control.rds"))

}

