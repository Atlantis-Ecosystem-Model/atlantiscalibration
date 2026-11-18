# Extract and sum abundance for a single species across age classes

Calls [`extract_abundance_grp`](extract_abundance_grp.md) and then sums
abundance across all age-class groups whose variable name contains the
species code.

## Usage

``` r
extract_abundance_sp(path, prefix = NULL, species)
```

## Arguments

- path:

  Character. Path to the directory containing Atlantis outputs.

- prefix:

  Character. Prefix of the Atlantis configuration.

- species:

  Character. Species code to match against variable names (e.g.
  `"CHY"`).

## Value

Numeric vector of total abundance summed across matched age-class groups
and all spatial cells, one value per time step. Returns `NA` if no
matching variables are found.

## Examples

``` r
if (FALSE) { # \dontrun{
  abund_chy <- extract_abundance_sp(
    path    = "path/to/atlantis/outputs",
    prefix  = "AMPS",
    species = "CHY"
  )
} # }
```
