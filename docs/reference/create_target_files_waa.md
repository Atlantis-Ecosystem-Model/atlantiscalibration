# Create weight-at-age target files and calibration settings from initial conditions

Uses the initial individual weight of each age class (cohort) as a
constant target for calibrar. The weight is calculated from the
`_FillValue` attribute of the `<Cohort>_ResN` and `<Cohort>_StructN`
variables of the Atlantis initial conditions NetCDF file as \\(ResN +
StructN) \times 20 \times 5.7 / 10^6\\, which converts mg N per
individual to tonnes wet weight. Only creates targets for cohorts
belonging to groups with `IsCalibrated == 1` in the parameter table.
Writes all the files needed to set up a weight-at-age calibration:

- `data/<Cohort>_w.csv`: one target time series per cohort, with columns
  `Time` and `Weight`.

- `calibration_settings_weight.csv`: calibration settings for each
  weight-at-age target.

- `Waa.txt` and `Waa_crash.txt`: R code snippets used to build the
  output list of the run model function, for a successful run and for a
  crashed run (all zeros), respectively.

## Usage

``` r
create_target_files_waa(
  init.file,
  output.path = here::here("inputs"),
  dt.timeseries = 5,
  parameter.file = "parameter_table.csv"
)
```

## Arguments

- init.file:

  Character. Path to the Atlantis initial conditions NetCDF file.

- output.path:

  Character. Directory where output files are written. Target files are
  written to its `data` sub-directory, which is created if needed.
  Default: `inputs`.

- dt.timeseries:

  Integer. Number of time steps in each target time series. Default:
  `5`.

- parameter.file:

  Character. Name of the parameter table CSV file in `inputs/`, used to
  filter which groups to create targets for. Default:
  `"parameter_table.csv"`.

## Value

Invisibly, the calibration settings data frame. Called for its side
effect of writing files to `output.path`.

## Details

A warning lists any cohorts with an initial weight of zero.

## Examples

``` r
if (FALSE) { # \dontrun{
  create_target_files_waa(
    init.file = here::here("inputs", "model_configuration", "AMPS_2024.nc")
  )
} # }
```
