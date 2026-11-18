# Extract total biomass of each functional group from Atlantis outputs

Reads the biomass of each active functional group either from the main
output NetCDF file (`<group>_N` variables converted to tonnes wet weight
with [`calculate_biomass`](calculate_biomass.md)) or from the
`<prefix>_OUTBiomIndx.txt` text output.

## Usage

``` r
extract_biomass_main(path, prefix = NULL, fg.file, txt = F, dt.timeserie = NA)
```

## Arguments

- path:

  Character. Path to the directory containing Atlantis outputs.

- prefix:

  Character. Prefix of the Atlantis configuration (e.g. `"AMPS"`).

- fg.file:

  Character. Path to the functional groups CSV file.

- txt:

  Logical. If `FALSE` (default) read from NetCDF; if `TRUE` read from
  `<prefix>_OUTBiomIndx.txt`.

- dt.timeserie:

  Integer. When `txt = TRUE`, number of most recent time steps to
  retain. Use `NA` (default) to keep all rows.

## Value

A named list with one element per functional group. Each element is a
numeric vector of total biomass (tonnes wet weight), one value per time
step.

## Examples

``` r
if (FALSE) { # \dontrun{
  biomass <- extract_biomass_main(
    path    = "path/to/atlantis/outputs",
    prefix  = "AMPS",
    fg.file = "PugetSoundAtlantisFunctionalGroups.csv"
  )
} # }
```
