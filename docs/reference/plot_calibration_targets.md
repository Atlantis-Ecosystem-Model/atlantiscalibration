# Plot calibration results for all target types and iterations

Reads calibration target output files from each iteration and creates
comparison plots of simulated versus target values. Supports biomass,
abundance, weight at age, and catch targets.

## Usage

``` r
plot_calibration_targets(
  run_dir = here::here("RUN"),
  data_dir = here::here("inputs", "data"),
  settings_dir = here::here("inputs"),
  output_dir = here::here("outputs"),
  parameter_file = here::here("inputs", "parameter_table.csv"),
  output_prefix = "outputSETAS"
)
```

## Arguments

- run_dir:

  Character. Path to the RUN directory containing iteration folders
  (e.g., `i0`, `i1`, `i2`, ...). Default: `here::here("RUN")`.

- data_dir:

  Character. Path to the directory containing target CSV files (e.g.,
  `<Code>_<var.type>.csv`). Default: `here::here("inputs", "data")`.

- settings_dir:

  Character. Path to the directory containing calibration settings files
  (`calibration_settings_*.csv`). Default: `here::here("inputs")`.

- output_dir:

  Character. Directory where PDF plots are saved. Default:
  `here::here("outputs")`.

- parameter_file:

  Character. Path to the parameter table CSV file with an `IsCalibrated`
  column. Used to identify groups to plot. Default:
  `here::here("inputs", "parameter_table.csv")`.

- output_prefix:

  Character. Prefix for biomass index file name (e.g., "outputSETAS" for
  "outputSETASBiomIndx.txt"). Default: `"outputSETAS"`.

## Value

Invisibly, a named list of data frames containing the processed data for
each target type.

## Examples

``` r
if (FALSE) { # \dontrun{
  plot_calibration_targets(
    run_dir = here::here("RUN"),
    data_dir = here::here("inputs", "data"),
    settings_dir = here::here("inputs"),
    output_dir = here::here("outputs")
  )
} # }
```
