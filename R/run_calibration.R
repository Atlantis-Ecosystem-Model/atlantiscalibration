
run_calibration <- function(control, forcing){# call the RMPI/Snow make cluster (note here that there are no arguments!)
NumberOfCluster <- control$nCores
cl <-  makeCluster(NumberOfCluster)

# call the registerDoSNOW function instead of the registerDoParallel
registerDoSNOW (cl)

# send the variables and loaded libraries defined in the above to the nodes
clusterExport(cl, c("control","objfn", "forcing", "observed", "setup", "minmaxt"))
clusterEvalQ(cl, library("calibrar"))
clusterEvalQ(cl, library("stringr"))

# run the calibration

lbfgsb1 = calibrar::calibrate(par=forcing['paropt'], fn=objfn,
                              method='AHR-ES',
                              lower=forcing['parmin'],
                              upper=forcing['parmax'],
                              phases=forcing['parphase'],
                              control=control, parallel = TRUE)

# stop the cluster
stopCluster(cl)


# readRDS('restart_file.restart')
a<- readRDS('restart_file.results')
}
