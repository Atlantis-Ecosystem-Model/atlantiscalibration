# Create abundance-at-age target files and calibration settings from initial conditions

Uses the initial abundance at age of each age-structured functional
group (the `<Group><age>_Nums` variables of the Atlantis initial
conditions NetCDF file, summed over boxes and layers) as a constant
target for calibrar, and writes all the files needed to set up an
abundance calibration. Only creates targets for groups with
`IsCalibrated == 1` in the parameter table.

- `data/<Group>_Nums.csv`: one target per group, with a `Time` column
  and one column per age class. Age classes with zero abundance are set
  to `NA`.

- `calibration_settings_abundance.csv`: calibration settings for each
  abundance target, using a multinomial likelihood.

- `abund.txt` and `abund_crash.txt`: R code snippets used to build the
  output list of the run model function, for a successful run and for a
  crashed run (all zeros), respectively.

## Usage

``` r
create_target_files_abund(
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

## Examples

``` r
if (FALSE) { # \dontrun{
  create_target_files_abund(
    init.file = here::here("inputs", "model_configuration", "AMPS_2024.nc")
  )
} # }
```
