```{r setup-cluster}

start_cluster <- function(control){

cl <- parallel::makeCluster(control$nCores)
doSNOW::registerDoSNOW(cl)

# Objects required on each worker
clusterExport(cl, varlist = c("control", "objfn", "forcing", "observed",
                              "setup",   "likelihood_function"))

# Libraries required on each worker
list("atlantis2ls", "calibrar", "stringr") %>%
  walk(~ clusterEvalQ(cl, library(.x, character.only = TRUE)))

lbfgsb1 <- calibrar::calibrate(
  par     = forcing[["paropt"]],
  fn      = objfn,
  method  = "AHR-ES",
  lower   = forcing[["parmin"]],
  upper   = forcing[["parmax"]],
  phases  = forcing[["parphase"]],
  control = control,
  parallel = TRUE
)

stopCluster(cl)
}
