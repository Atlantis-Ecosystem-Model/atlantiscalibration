# Edit the BHbeta Beverton-Holt recruitment parameter for a species

Multiplies the current BHbeta value in the Atlantis biology parameter
file by a user-supplied factor. The target line is identified by the
pattern `BHbeta_<species>`; name and value are expected to be
tab-delimited.

## Usage

``` r
edit_param_BHbeta_sp(bio.lines, factor, species)
```

## Arguments

- bio.lines:

  Character vector of lines read from the biology `.prm` file, typically
  the result of [`readLines()`](https://rdrr.io/r/base/readLines.html).

- factor:

  Numeric multiplier applied to the current BHbeta value.

- species:

  Character string with the species code used in the Atlantis
  configuration (e.g. `"CHY"`).

## Value

The modified `bio.lines` vector with the BHbeta line for `species`
updated.

## Examples

``` r
if (FALSE) { # \dontrun{
  bio.lines <- readLines("AMPSbioparam.prm")
  bio.lines <- edit_param_BHbeta_sp(bio.lines, factor = 0.8, species = "CHY")
  writeLines(bio.lines, "AMPSbioparam.prm")
} # }
```
