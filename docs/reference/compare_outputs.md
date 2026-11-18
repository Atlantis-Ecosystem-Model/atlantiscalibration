# Compare initial and optimised Atlantis calibration outputs

Reads a saved calibrar results object, builds a side-by-side comparison
of the initial and optimised parameter values, and produces a
convergence plot showing the per-target fitness over iterations.

## Usage

``` r
compare_outputs(
  results_file = NULL,
  restart_dir = here::here("inputs"),
  forcing
)
```

## Arguments

- results_file:

  Character. Path to the RDS file written by
  [`calibrate`](https://roliveros-ramos.github.io/calibrar/reference/calibrate.html)
  (e.g. via its `restart` option). If `NULL`, searches for the most
  recent restart file in the inputs directory. Default: `NULL`.

- restart_dir:

  Character. Directory where restart files are saved. Used when
  `results_file = NULL`. Default: `here::here("inputs")`.

- forcing:

  Data frame of parameter metadata with row names used as parameter
  identifiers. Must contain at minimum the columns `paropt` (initial
  values), `parmin`, `parmax`, and `parphase`.

## Value

A named list with two elements:

- `param_comparison`:

  A tibble with one row per parameter and columns `parameter`, `paropt`
  (initial), `paropt_new` (optimised), `parmin`, `parmax`, and
  `parphase`.

- `plot_changes`:

  A `ggplot` object showing calibration fitness per target over
  iterations on a log\\\_{10}\\ scale.

## Examples

``` r
if (FALSE) { # \dontrun{
  out <- compare_outputs(
    forcing = forcing
  )
  print(out$param_comparison)
  print(out$plot_changes)
} # }
```
