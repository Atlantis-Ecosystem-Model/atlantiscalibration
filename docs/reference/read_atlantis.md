# Read Atlantis model outputs

Reads the outputs of an Atlantis run and returns the indicators used in
the calibration: biomass, landings, abundance and weight at age. If the
run stopped before its scheduled end (see
[`is.stopped`](is.stopped.md)), returns the same structure filled with
zeros, so a crashed run can still be scored by calibrar.

## Usage

``` r
read_atlantis(
  path,
  prefix = NULL,
  fg.file,
  fishery,
  spatial = F,
  N_only = F,
  txt.filename = "outputFolder/AMPS_OUTBiomIndx.txt",
  run.filename = "PugetSound_run.prm",
  dt.timeserie = 2,
  ...
)
```

## Arguments

- path:

  Character. Path to the Atlantis run directory.

- prefix:

  Character. Prefix of the Atlantis configuration files (e.g. `"AMPS"`
  for Puget Sound).

- fg.file:

  Character. Path to the functional groups CSV file.

- fishery:

  Logical. Whether fishing is turned on in the model.

- spatial:

  Logical. Read the data per polygon. Only `FALSE` is currently
  available. Default: `FALSE`.

- N_only:

  Logical. If `TRUE`, only read the raw nitrogen biomass (see
  [`extract_Nbiomass_main`](extract_Nbiomass_main.md)). Default:
  `FALSE`.

- txt.filename:

  Character. Path to the biomass index text file, relative to `path`.
  Default: `"outputFolder/AMPS_OUTBiomIndx.txt"` (Puget Sound).

- run.filename:

  Character. Name of the run parameter file, relative to `path`.
  Default: `"PugetSound_run.prm"` (Puget Sound).

- dt.timeserie:

  Integer. Number of time steps in each indicator when the run crashed;
  all values are set to zero. Default: `2`.

- ...:

  Not used.

## Value

An object of class `atlantis`: a list with elements `biomass`,
`landings`, `abundance` and `waa`, each a named list with one element
per functional group. If `N_only = TRUE`, a list with a single element
`Nbiomass`.

## Examples

``` r
if (FALSE) { # \dontrun{
  outputs <- read_atlantis(path    = "path/to/atlantis/run",
                           prefix  = "AMPS",
                           fg.file = "PugetSoundAtlantisFunctionalGroups.csv",
                           fishery = TRUE)
} # }
```
