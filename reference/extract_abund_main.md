# Extract abundance for all functional groups defined in a groups file

Loops over functional groups listed in `fg.file` and calls
[`extract_abundance_sp`](extract_abundance_sp.md) for each, returning a
named list.

## Usage

``` r
extract_abund_main(path, prefix = NULL, fg.file)
```

## Arguments

- path:

  Character. Path to the directory containing Atlantis outputs.

- prefix:

  Character. Prefix of the Atlantis configuration.

- fg.file:

  Character. Path to the functional groups CSV file.

## Value

A named list (names = functional group names) where each element is the
summed abundance time series for that group.

## Examples

``` r
if (FALSE) { # \dontrun{
  abund_all <- extract_abund_main(
    path    = "path/to/atlantis/outputs",
    prefix  = "AMPS",
    fg.file = "PugetSoundAtlantisFunctionalGroups.csv"
  )
} # }
```
