# Sum ignoring missing values

Shorthand for `sum(x, na.rm = TRUE)`.

## Usage

``` r
sumNA(x)
```

## Arguments

- x:

  Numeric vector.

## Value

Numeric. The sum of the non-missing values of `x`.

## Examples

``` r
if (FALSE) { # \dontrun{
  sumNA(c(1, 2, NA))
} # }
```
