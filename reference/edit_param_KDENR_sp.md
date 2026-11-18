# Edit the KDENR half-saturation density parameter for a species

Multiplies every value in the KDENR vector for a species by a
user-supplied factor. The header line is found by the pattern
`KDENR_<species>`; the numeric values reside two lines below the header
(Atlantis `.prm` convention for vector parameters).

## Usage

``` r
edit_param_KDENR_sp(bio.lines, factor, species)
```

## Arguments

- bio.lines:

  Character vector of lines read from the biology `.prm` file, typically
  the result of [`readLines()`](https://rdrr.io/r/base/readLines.html).

- factor:

  Numeric multiplier applied to every element of the KDENR vector.

- species:

  Character string with the species code used in the Atlantis
  configuration (e.g. `"CHY"`).

## Value

The modified `bio.lines` vector with the KDENR values for `species`
updated.

## Examples

``` r
if (FALSE) { # \dontrun{
  bio.lines <- readLines("AMPSbioparam.prm")
  bio.lines <- edit_param_KDENR_sp(bio.lines, factor = 1.5, species = "CHY")
  writeLines(bio.lines, "AMPSbioparam.prm")
} # }
```
