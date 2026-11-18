# Edit the catchability coefficient (mQ) for a species

Multiplies the current scalar mQ value for a species by a user-supplied
factor. The line is identified by the pattern `<species>_mQ` and the
name-value pair is expected to be tab-delimited. Only scalar
(single-value) mQ entries are supported; a vector mQ will raise an
error.

## Usage

``` r
edit_param_mq_sp(bio.lines, factor, species)
```

## Arguments

- bio.lines:

  Character vector of lines read from the biology `.prm` file, typically
  the result of [`readLines()`](https://rdrr.io/r/base/readLines.html).

- factor:

  Numeric multiplier applied to the current mQ value.

- species:

  Character string with the species code used in the Atlantis
  configuration (e.g. `"CHY"`).

## Value

The modified `bio.lines` vector with the mQ line for `species` updated.

## Examples

``` r
if (FALSE) { # \dontrun{
  bio.lines <- readLines("AMPSbioparam.prm")
  bio.lines <- edit_param_mq_sp(bio.lines, factor = 1.1, species = "CHY")
  writeLines(bio.lines, "AMPSbioparam.prm")
} # }
```
