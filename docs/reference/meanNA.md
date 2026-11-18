# Mean ignoring missing values

Shorthand for `mean(x, na.rm = TRUE)`.

## Usage

``` r
meanNA(x)
```

## Arguments

- x:

  Numeric vector.

## Value

Numeric. The mean of the non-missing values of `x`.

## Examples

``` r
if (FALSE) { # \dontrun{
  meanNA(c(1, 2, NA))
} # }
```
