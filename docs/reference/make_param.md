# Create a block of calibration parameters

Builds the rows of the calibration parameters table for one parameter
type, with one row per functional group. Parameters are factors applied
to the original values, so they start at `paropt = 0` with bounds `-1`
to `1`, in phase `1`.

## Usage

``` r
make_param(prefix, codes, suffix)
```

## Arguments

- prefix:

  Character. Prefix of the parameter name (e.g. `"mum_"`).

- codes:

  Character vector. Functional group codes.

- suffix:

  Character. Suffix of the parameter name (e.g. `"_factor"`).

## Value

A data frame with columns `names`, `paropt`, `parmin`, `parmax` and
`parphase`, and one row per code. If `codes` is empty, a data frame with
zero rows.

## Examples

``` r
if (FALSE) { # \dontrun{
  make_param("mum_", c("FPS", "FPL"), "_factor")
} # }
```
