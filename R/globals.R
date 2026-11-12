# Column names used in dplyr, tidyr and ggplot2 calls, declared so that
# R CMD check does not report them as undefined global variables
utils::globalVariables(c(
  "calibrate", "Catch", "Code", "factor_new", "fitness", "flagrecruit", "GroupType", "Ini",
  "IsCalibrated", "IsTurnedOn", "iteration", "parameter", "parameter_corr",
  "parameter_name", "parmax", "parmin", "paropt", "paropt_new", "parphase",
  "target", "Time", "variable", "weight", "weight_new", "Year"
))

# Objects that start_cluster() expects in the global
# environment (see their documentation)
utils::globalVariables(c("forcing", "objfn"))
