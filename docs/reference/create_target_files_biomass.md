# Create biomass target files and calibration inputs

Creates biomass targets for calibrar from one of two sources:

- `initial.conditions = TRUE` (default): the initial biomass of each
  functional group (first time step of the Atlantis
  `<prefix>_OUTBiomIndx.txt` output) is used as a constant target.

- `time.series = TRUE`: the observed biomass time series of each group
  in `biomass.file` is used as the target.

Writes all the files needed to set up a biomass calibration:

- `data/<Code>_biomass.csv`: one target time series per calibrated
  group, with columns `Time` and `Biomass`.

- `calibration_settings_biomass.csv`: calibration settings for each
  biomass target.

- `calibration-parameters-complete.csv`: parameter factors to estimate
  for each group, as set in `parameter.file`, with initial values,
  bounds and phase.

- `biomass.txt` and `biomass_crash.txt`: R code snippets used to build
  the output list of the run model function, for a successful run and
  for a crashed run (all zeros), respectively.

## Usage

``` r
create_target_files_biomass(
  biom.indx = NULL,
  fg.file,
  output.path = here::here("inputs"),
  not.calibrated,
  dt.timeseries = 5,
  unfished = FALSE,
  factor.unfished = 1.3,
  initial.conditions = TRUE,
  time.series = FALSE,
  biomass.file = "biomass_timeseries.csv",
  biology.prm,
  parameter.file = "parameter_table.csv",
  repro.file = "reproduction-option.csv"
)
```

## Arguments

- biom.indx:

  Character. Path to the Atlantis biomass index text file
  (`<prefix>_OUTBiomIndx.txt`). Required when
  `initial.conditions = TRUE`. Default: `NULL`.

- fg.file:

  Character. Path to the functional groups CSV file. Must contain the
  columns `Code`, `Name`, `IsFished` and `GroupType`.

- output.path:

  Character. Directory where output files are written. Target time
  series are written to its `data` sub-directory, which is created if
  needed. Default: `inputs`.

- not.calibrated:

  Character vector. Codes of functional groups to exclude from
  calibration. Default: `c("PS", "PL", "DC", "DL", "DR")`.

- dt.timeseries:

  Integer. Number of time steps in each target time series. Default:
  `5`.

- unfished:

  Logical. If `TRUE`, create targets for an unfished scenario (see
  Details). Default: `FALSE`.

- factor.unfished:

  Numeric. Factor applied to the initial biomass of fished groups to
  obtain the unfished biomass target. Only used when `unfished = TRUE`.
  Default: `1.3`.

- initial.conditions:

  Logical. If `TRUE`, use the initial biomass in `biom.indx` as a
  constant target. Default: `TRUE`.

- time.series:

  Logical. If `TRUE`, use the observed biomass time series in
  `biomass.file` as the target. Exactly one of `initial.conditions` and
  `time.series` must be `TRUE`. Default: `FALSE`.

- biomass.file:

  Character. Name of the observed biomass CSV file in
  `inputs/model_configuration`, with columns `Code`, `Year` and
  `Biomass`. Only used when `time.series = TRUE`. Default:
  `biomass_timeseries.csv`.

- biology.prm:

  Character. Name of the Atlantis biology parameter file in
  `inputs/model_configuration`.

- parameter.file:

  Character. Name of the parameter table CSV file in `inputs`, with one
  row per functional group and one column per parameter to calibrate
  (any of `mum`, `BHalpha`, `BHbeta`, `KDENR`, `mfc`, `mQ`, `mL`, `C`
  and `E`), set to `1` if the parameter is calibrated for that group.
  Default: `"parameter_table.csv"`.

- repro.file:

  Character. Name of the reproduction option CSV file in `inputs`, with
  columns `Code` and `flagrecruit`, as written by
  [`repro_option`](repro_option.md). Default:
  `"reproduction-option.csv"`.

## Value

Invisibly, a named list with elements `settings` (calibration settings
data frame) and `parameters` (calibration parameters data frame). Called
for its side effect of writing files to `output.path`.

## Details

The parameters to calibrate, and the groups each one applies to, are
read from `parameter.file` (see
[`read_parameter_table`](read_parameter_table.md)). Factors are only
created for groups that are turned on and calibrated. `BHalpha`,
`BHbeta` and `KDENR` factors are only created for groups with
`GroupType` `FISH`, `SHARK`, `BIRD` or `MAMMAL`, taken from
`parameter.file` if it has a `GroupType` column, or else from `fg.file`.
`mfc` factors are only created for groups with `IsFished == 1` in
`fg.file`. `KDENR` factors are only created for groups whose
`flagrecruit` in `repro.file` is 12, and `BHalpha` and `BHbeta` factors
only for groups whose `flagrecruit` is 3 (Beverton-Holt). Groups with
other recruitment options, or missing from `repro.file` get none of the
three.

If `unfished = TRUE`, targets are created for an unfished scenario
instead: only fished groups (`IsFished == 1`) are included, and their
initial biomass is multiplied by `factor.unfished`. Outputs are written
with an `_unfished` suffix so they do not overwrite the standard biomass
calibration files: targets go to `data_unfished/`, and the other files
are `calibration_settings_unfished.csv`,
`calibration-parameters-unfished.csv`, `biomass_unfished.txt` and
`biomass_unfished_crash.txt`. `mfc` factors are not created in this
case, as fishing is turned off.

## Examples

``` r
if (FALSE) { # \dontrun{
  create_target_files_biomass(
    biom.indx = "path/to/outputs/AMPS_OUTBiomIndx.txt",
    fg.file   = "path/to/PugetSoundAtlantisFunctionalGroups_2024.csv"
  )

  # Unfished scenario
  create_target_files_biomass(
    biom.indx     = "path/to/outputs/AMPS_OUTBiomIndx.txt",
    fg.file       = "path/to/PugetSoundAtlantisFunctionalGroups_2024.csv",
    unfished      = TRUE
  )

  # Observed biomass time series as target
  create_target_files_biomass(
    fg.file            = "path/to/PugetSoundAtlantisFunctionalGroups_2024.csv",
    initial.conditions = FALSE,
    time.series        = TRUE
  )
} # }
```
