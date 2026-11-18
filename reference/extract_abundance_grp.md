# Extract abundance time series for all age-class groups

Reads every `_Nums` variable from the main Atlantis output NetCDF file
and sums across all boxes and layers to produce a time series per
age-class variable.

## Usage

``` r
extract_abundance_grp(path, prefix = NULL)
```

## Arguments

- path:

  Character. Path to the directory containing Atlantis outputs.

- prefix:

  Character. Prefix of the Atlantis configuration (e.g. `"AMPS"`).

## Value

A named list with one element per `_Nums` variable in the NetCDF. Each
element is a numeric vector of total individuals summed across all boxes
and layers, with one value per time step.

## Examples

``` r
if (FALSE) { # \dontrun{
  abund <- extract_abundance_grp(
    path   = "path/to/atlantis/outputs",
    prefix = "AMPS"
  )
} # }
```
