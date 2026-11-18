# Edit a biology parameter for a species by name

Dispatcher that routes to the appropriate parameter-editing function
based on the value of `param`. Accepted parameter names
(case-insensitive): `"mum"`, `"bhbeta"`, `"bhaphla"`, `"mq"`.

## Usage

``` r
edit_param_sp(bio.lines, param, factor, species)
```

## Arguments

- bio.lines:

  Character vector of lines from the biology `.prm` file, typically the
  result of [`readLines()`](https://rdrr.io/r/base/readLines.html).

- param:

  Character string naming the parameter to edit. Must be one of `"mum"`,
  `"bhbeta"`, `"bhaphla"`, or `"mq"` (case-insensitive).

- factor:

  Numeric multiplier applied to the current parameter value.

- species:

  Character string with the species code used in the Atlantis
  configuration (e.g. `"CHY"`).

## Value

The modified `bio.lines` vector.

## Examples

``` r
if (FALSE) { # \dontrun{
  bio.lines <- readLines("AMPSbioparam.prm")
  bio.lines <- edit_param_sp(bio.lines, param = "mum", factor = 1.1, species = "CHY")
  writeLines(bio.lines, "AMPSbioparam.prm")
} # }
```
