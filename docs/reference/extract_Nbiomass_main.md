# Extract total nitrogen biomass from Atlantis output NetCDF

Reads the `<group>_N` variables from the main Atlantis output NetCDF
file and sums across all boxes and layers for each time step.

## Usage

``` r
extract_Nbiomass_main(path, prefix = NULL, fg.file)
```

## Arguments

- path:

  Character. Path to the directory containing Atlantis outputs.

- prefix:

  Character. Prefix of the Atlantis configuration (e.g. `"AMPS"`).

- fg.file:

  Character. Path to the functional groups CSV file (must contain at
  minimum `Name` and `IsTurnedOn` columns).

## Value

A named list with one element per functional group. Each element is a
numeric vector of total nitrogen (mg N) summed across all boxes and
layers, with one value per time step.

## Examples

``` r
if (FALSE) { # \dontrun{
  nbiomass <- extract_Nbiomass_main(
    path    = "path/to/atlantis/outputs",
    prefix  = "AMPS",
    fg.file = "PugetSoundAtlantisFunctionalGroups.csv"
  )
} # }
```
