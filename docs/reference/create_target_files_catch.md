# Create catch target files and calibration settings from observed catch

Sums observed catch by functional group and year, and uses the median
annual catch of each group as a constant target for calibrar. Writes all
the files needed to set up a catch calibration:

- `data/<Name>_catch.csv`: one target time series per group, with
  columns `Time` and `Catch`.

- `calibration_settings_catch.csv`: calibration settings for each catch
  target.

- `catch.txt` and `catch_crash.txt`: R code snippets used to build the
  output list of the run model function, for a successful run and for a
  crashed run (all zeros), respectively.

## Usage

``` r
create_target_files_catch(
  catch.file,
  fg.file,
  output.path = here::here("inputs"),
  dt.timeseries = 5,
  weight = 2,
  plot = FALSE
)
```

## Arguments

- catch.file:

  Character. Path to the observed catch CSV file. Must contain the
  columns `Name`, `Code`, `year` and `catch_tons`. Multiple rows per
  group and year (e.g. by fleet or area) are summed.

- fg.file:

  Character. Name of the functional groups CSV file in
  `inputs/model_configuration`. Must contain the columns `Code` and
  `Name`.

- output.path:

  Character. Directory where output files are written. Target files are
  written to its `data` sub-directory, which is created if needed.
  Default: `inputs`.

- dt.timeseries:

  Integer. Number of time steps in each target time series. Default:
  `5`.

- weight:

  Numeric. Calibration weight given to each catch target. Default: `2`.

- plot:

  Logical. If `TRUE`, plots the annual catch time series of each group,
  with its median as a horizontal line. Default: `FALSE`.

## Value

Invisibly, the calibration settings data frame. Called for its side
effect of writing files to `output.path`.

## Details

Fishing mortality parameters (`mfc`) are not created here; they are
written by
[`create_target_files_biomass`](create_target_files_biomass.md).

## Examples

``` r
if (FALSE) { # \dontrun{
  create_target_files_catch(
    catch.file = here::here("inputs", "PS_catch_2011-2019.csv"),
    fg.file    = "PugetSoundAtlantisFunctionalGroups_2024.csv",
    plot       = TRUE
  )
} # }
```
