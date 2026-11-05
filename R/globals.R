# Column names used in dplyr, tidyr and ggplot2 calls, declared so that
# R CMD check does not report them as undefined global variables
utils::globalVariables(c(
  "calibrate", "Catch", "Code", "fitness", "flagrecruit", "GroupType", "Ini",
  "IsCalibrated", "IsTurnedOn", "iteration", "parameter", "parameter_corr",
  "parameter_name", "parmax", "parmin", "paropt", "paropt_new", "parphase",
  "target", "Time", "variable", "weight", "weight_new", "Year"
))

# Objects that run_calibration() and start_cluster() expect in the global
# environment (see their documentation)
utils::globalVariables(c("forcing", "objfn"))
