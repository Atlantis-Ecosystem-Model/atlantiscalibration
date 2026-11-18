# Edit the maximum fishing capacity (mFC) parameter for a species

Multiplies every value in the mFC vector for a species by a
user-supplied factor. The header line is found by the pattern
`mFC_<species>`; the numeric values reside one line below the header
(Atlantis harvest `.prm` convention).

## Usage

``` r
edit_param_mfc(harvest.lines, factor, species)
```

## Arguments

- harvest.lines:

  Character vector of lines read from the harvest `.prm` file, typically
  the result of [`readLines()`](https://rdrr.io/r/base/readLines.html).

- factor:

  Numeric multiplier applied to every element of the mFC vector.

- species:

  Character string with the species code used in the Atlantis
  configuration (e.g. `"CHY"`).

## Value

The modified `harvest.lines` vector with the mFC values for `species`
updated.

## Examples

``` r
if (FALSE) { # \dontrun{
  harvest.lines <- readLines("AMPSharvest.prm")
  harvest.lines <- edit_param_mfc(harvest.lines, factor = 0.5, species = "CHY")
  writeLines(harvest.lines, "AMPSharvest.prm")
} # }
```
