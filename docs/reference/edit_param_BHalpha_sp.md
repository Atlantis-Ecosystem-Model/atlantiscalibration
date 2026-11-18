# Edit the BHalpha Beverton-Holt recruitment parameter for a species

Multiplies the current BHalpha value in the Atlantis biology parameter
file by a user-supplied factor. The target line is identified by the
pattern `BHalpha_<species>`; name and value are expected to be separated
by three spaces.

## Usage

``` r
edit_param_BHalpha_sp(bio.lines, factor, species)
```

## Arguments

- bio.lines:

  Character vector of lines read from the biology `.prm` file, typically
  the result of [`readLines()`](https://rdrr.io/r/base/readLines.html).

- factor:

  Numeric multiplier applied to the current BHalpha value.

- species:

  Character string with the species code used in the Atlantis
  configuration (e.g. `"CHY"`).

## Value

The modified `bio.lines` vector with the BHalpha line for `species`
updated.

## Examples

``` r
if (FALSE) { # \dontrun{
  bio.lines <- readLines("AMPSbioparam.prm")
  bio.lines <- edit_param_BHalpha_sp(bio.lines, factor = 1.2, species = "CHY")
  writeLines(bio.lines, "AMPSbioparam.prm")
} # }
```
