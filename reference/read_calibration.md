# Read calibration inputs and save the optimiser control settings

Reads the calibration settings and observed targets with calibrar, reads
the calibration parameters table, builds the objective function with
[`make_objfn`](make_objfn.md) and sets up the optimiser control list.
Writes the parameters to `inputs/forcing.csv` and the optimiser control
list to `inputs/control.rds`.

## Usage

``` r
read_calibration(
  calibration.settings,
  calibration.parameters,
  n.Cores,
  maxgen,
  master,
  run,
  restart.file,
  track.path = here::here("outputs", "keep_track_calibration"),
  REPORT = 1,
  parallel = TRUE,
  no.trace = 3,
  ...
)
```

## Arguments

- calibration.settings:

  Character. Pattern to match calibration settings CSV files in `inputs`
  (e.g. `"calibration_settings_*.csv"`), as written by
  [`make_calsettings`](make_calsettings.md). All matching files are read
  and combined. Alternatively, a single filename for backward
  compatibility.

- calibration.parameters:

  Character. Name of the calibration parameters CSV file in `inputs`
  (e.g. `"calibration-parameters-complete.csv"`), with parameter names
  in the first column.

- n.Cores:

  Integer. Number of parallel workers, also used as the population size
  (number of model runs per generation).

- maxgen:

  Integer. Maximum number of generations (iterations) of the optimiser.
  Default: `5`.

- master:

  Character. Directory with all the files needed to run Atlantis (model
  files and the `.sh` shell script). It is copied to a run directory for
  each model run.

- run:

  Character. Directory where the model runs are done.

- restart.file:

  Character. Name of the restart file, used to restart an interrupted
  calibration and to save the results.

- track.path:

  Character. Folder where the parameter files used in each run of each
  iteration are saved, as `iteration_<iteration>/run_<run>_<file>` (see
  [`keep_track_prm`](keep_track_prm.md)). Set to `NULL` to not save
  them. Default: `outputs/keep_track_calibration`.

- ...:

  Arguments passed to [`run_model`](run_model.md) through
  [`make_objfn`](make_objfn.md) (`prefix`, `fg.file`, `biom.indx`,
  `run.prm` and `dt.timeseries`).

## Value

Invisibly, a named list with elements `setup`, `observed`, `forcing`,
`objfn` (see [`make_objfn`](make_objfn.md)) and `control`. The `control`
element is a list containing optimiser settings including `REPORT`
(number of iterations before saving), `parallel` (logical, enable
parallel computing), and `trace` (verbosity level for global fitness and
partial fitness output). Also writes `inputs/forcing.csv` and
`inputs/control.rds`.

## Examples

``` r
if (FALSE) { # \dontrun{
  calibration <- read_calibration(
    calibration.settings   = "calibration_settings_*.csv",
    calibration.parameters = "calibration-parameters-complete.csv",
    n.Cores      = 32,
    master       = "model_configuration/",
    run          = "RUN",
    restart.file = "restart_file",
    prefix = "outputFolder/outputSETAS", fg.file = "SETasGroupsDem.csv",
    biom.indx = "outputFolder/outputSETASBiomIndx.txt",
    run.prm = "VMPA_setas_run_fishing_F_Trunk.prm", dt.timeseries = 5)
} # }
```
