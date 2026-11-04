read_calibration <- function(calibration.settings){

  setup  <- calibrar::calibration_setup(file=here::here("inputs",calibration.settings))

   observed <- calibrar::calibration_data(setup = setup,
                                         path=here::here("inputs"),
                                         file = NULL,
                                         sep = ",")


  # load calibration parameters
  forcing = read.csv(file="calibration-parameters-complete.csv",
                     path=here::here("inputs"),
                     header=TRUE,
                     sep=",",
                     row.names=1)
}

