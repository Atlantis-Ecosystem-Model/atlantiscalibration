# Start a parallel cluster and run the calibration

Creates a cluster with `control$nCores` workers, exports the objects and
libraries each worker needs, runs the AHR-ES optimisation with
[`calibrate`](https://roliveros-ramos.github.io/calibrar/reference/calibrate.html)
and stops the cluster. Same as [`run_calibration`](run_calibration.md),
except that the cluster is not stopped if the optimisation fails.

## Usage

``` r
start_cluster(control)
```

## Arguments

- control:

  A named list of calibration control parameters passed to
  [`calibrate`](https://roliveros-ramos.github.io/calibrar/reference/calibrate.html).
  Must contain at minimum `nCores` (integer, number of parallel
  workers).

## Value

Called for its side effect of running the calibration. The result of
[`calibrate`](https://roliveros-ramos.github.io/calibrar/reference/calibrate.html)
is not returned.

## Details

The function relies on `objfn`, `forcing`, `observed`, `setup` and
`likelihood_function` being present in the calling environment.

## Examples

``` r
if (FALSE) { # \dontrun{
  start_cluster(control = list(nCores = 4, maxit = 5))
} # }
```
