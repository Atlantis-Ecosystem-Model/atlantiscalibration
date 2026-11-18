# Run the Atlantis model calibration

Sets up a parallel cluster, exports the required objects and libraries
to each worker, and runs the AHR-ES optimisation algorithm via
[`calibrate`](https://roliveros-ramos.github.io/calibrar/reference/calibrate.html).
The cluster is stopped on exit regardless of whether optimisation
succeeds or fails.

## Usage

``` r
run_calibration(calibration)
```

## Arguments

- calibration:

  Named list returned by [`read_calibration`](read_calibration.md), with
  elements `setup`, `observed`, `forcing` (data frame with columns
  `paropt`, `parmin`, `parmax` and `parphase`), `objfn` (the objective
  function) and `control` (control parameters passed to
  [`calibrate`](https://roliveros-ramos.github.io/calibrar/reference/calibrate.html),
  with at minimum `nCores`).

## Value

The object returned by
[`calibrate`](https://roliveros-ramos.github.io/calibrar/reference/calibrate.html):
a list with the optimised parameter vector, objective function value,
and convergence diagnostics. The results are also saved by calibrar in
`<control$restart.file>.results`.

## Examples

``` r
if (FALSE) { # \dontrun{
  calibration <- read_calibration(...)
  result <- run_calibration(calibration)
} # }
```
