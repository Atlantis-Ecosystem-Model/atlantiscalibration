# Multiply a parameter in an Atlantis parameter file by a factor

Finds the parameter with `grep` and multiplies its value(s) by `factor`.
Handles the two layouts used in Atlantis `.prm` files:

- Single value: `<name> <value> <comment>` (e.g.
  `BHalpha_FPS 2.00E+9 Alpha in Beverton-Holt`). Parameters with the
  `_T15` suffix (e.g. `mum_ZS_T15`) are matched too.

- Array: `<name> <n>`, with the `n` values on the next line (e.g.
  `mum_FPS 10`).

Parameters that are not found, or found more than once, are left
unchanged with a warning.

## Usage

``` r
edit_param_factor(prm.lines, name, factor)
```

## Arguments

- prm.lines:

  Character vector of lines from an Atlantis `.prm` file, typically the
  result of [`readLines()`](https://rdrr.io/r/base/readLines.html).

- name:

  Character. Name of the parameter in the `.prm` file (e.g. `"mum_FPS"`,
  `"ZS_mQ"`, `"mFC_FPS"`).

- factor:

  Numeric. Factor applied to the parameter value(s).

## Value

The modified `prm.lines`.

## Examples

``` r
if (FALSE) { # \dontrun{
  bio.lines <- readLines("VMPA_setas_biol_fishing_Trunk.prm")
  bio.lines <- edit_param_factor(bio.lines, "mum_FPS", 1.2)
} # }
```
