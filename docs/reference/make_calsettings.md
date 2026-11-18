# Create Atlantis Model Calibration Settings

Generates a calibration settings file for functional groups in an
Atlantis model. Creates a dataframe specifying which groups to
calibrate, their associated variables, calibration weights, and data
file paths.

Only groups with `IsCalibrated == 1` and `IsTurnedOn == 1` in the
parameter table are calibrated. For each target type in `var.type`, a
separate calibration settings file and corresponding target files are
created (see
[`create_target_files_biomass`](create_target_files_biomass.md),
[`create_target_files_waa`](create_target_files_waa.md),
[`create_target_files_abund`](create_target_files_abund.md) and
[`create_target_files_catch`](create_target_files_catch.md)).

## Usage

``` r
make_calsettings(
  fg.file,
  var.type,
  fun.type,
  dt.timeseries,
  w.vector,
  biology.prm,
  biom.indx,
  init.file,
  catch.file,
  run.prm,
  parameter.file = "parameter_table.csv"
)
```

## Arguments

- fg.file:

  Character. Name of the functional group configuration file (CSV)
  located in inputs/model_configuration/. Must contain the columns
  `Code`, `Name`, `IsTurnedOn`, and `NumCohorts`.

- var.type:

  Character vector. Target types to calibrate: any of "biomass",
  "weight", "abundance" and "catch".

- fun.type:

  Character. Calibrar package optimization function for calibration

- dt.timeseries:

  Integer. Number of time steps in each target time series.

- w.vector:

  Data frame. Optional custom weights with columns "Code" and
  "weight_new" to override default weights. If NULL, default weights are
  used.

- biology.prm:

  Character. Name of the Atlantis biology parameter file in
  inputs/model_configuration/.

- biom.indx:

  Character. Name of the Atlantis biomass index output file
  (`<prefix>_OUTBiomIndx.txt`), used to create biomass targets.

- init.file:

  Character. Name of the Atlantis initial conditions NetCDF file, used
  to create weight-at-age and abundance targets.

- catch.file:

  Character. Name of the observed catch CSV file, used to create catch
  targets.

- run.prm:

  Character. Name of the Atlantis run parameter file in
  inputs/model_configuration/. The tstop parameter will be set to
  dt.timeseries.

- parameter.file:

  Character. Name of the parameter table CSV file in inputs/, with one
  row per functional group and one column per parameter to calibrate,
  set to 1 if the parameter is calibrated for that group (see
  [`create_target_files_biomass`](create_target_files_biomass.md)).
  Default: "parameter_table.csv".

## Value

Invisibly returns NULL. Writes one calibration settings CSV file for
each target type (e.g., `calibration_settings_biomass.csv`,
`calibration_settings_weight.csv`) to inputs/.

## Examples

``` r
if (FALSE) { # \dontrun{
make_calsettings(fg.file       = "SETasGroupsDem.csv",
                 var.type      = c("biomass", "weight"),
                 fun.type      = "lnorm2",
                 dt.timeseries = 5,
                 w.vector      = NULL,
                 biology.prm   = "VMPA_setas_biol_fishing_Trunk.prm",
                 biom.indx     = "outputSETASBiomIndx.txt",
                 init.file     = "INIT_VMPA_Jan2015.nc",
                 catch.file    = "catch_timeseries.csv",
                 parameter.file = "parameter_table.csv")
} # }
```
