# Build the Atlantis calibration objective function

Creates the calibration objective function with
[`calibration_objFn`](https://roliveros-ramos.github.io/calibrar/reference/calibration_objFn.html),
wrapping [`run_model`](run_model.md) and the likelihood computation into
a single callable used by
[`calibrate`](https://roliveros-ramos.github.io/calibrar/reference/calibrate.html).

## Usage

``` r
make_objfn(setup, observed, aggregate = FALSE, forcing, ...)
```

## Arguments

- setup:

  Calibration setup object produced by
  [`calibration_setup`](https://roliveros-ramos.github.io/calibrar/reference/calibration_setup.html),
  defining which targets belong to which phase.

- observed:

  Named list of observed data used to evaluate the likelihood at each
  iteration, produced by
  [`calibration_data`](https://roliveros-ramos.github.io/calibrar/reference/calibration_data.html).

- aggregate:

  Logical. If `FALSE` (default), the objective function returns
  per-target log-likelihood contributions as a named vector, enabling
  phased calibration where different parameter groups are optimised
  separately. If `TRUE`, returns a single aggregated scalar value.

- forcing:

  Data frame of parameter metadata with at minimum columns `paropt`,
  `parmin`, `parmax`, and `parphase`. Row names are used as parameter
  names.

- ...:

  Arguments passed to [`run_model`](run_model.md) at every run:
  `prefix`, `fg.file`, `biom.indx`, `run.prm` and `dt.timeseries`. The
  shell script and the biology and harvest parameter files are found by
  [`run_model`](run_model.md) itself.

## Value

The objective function. It takes `par`, a numeric vector of parameters
in the transformed (log) scale, and returns a named numeric vector of
per-target log-likelihood contributions.

## Details

Setting `aggregate = FALSE` means the objective function returns
per-target log-likelihood contributions as a named vector rather than a
single scalar. This enables phased calibration, where different
parameter groups are optimised in separate phases against their
respective targets.

## Examples

``` r
if (FALSE) { # \dontrun{
  objfn <- make_objfn(setup, observed, forcing,
                      prefix = "outputFolder/outputSETAS",
                      fg.file = "SETasGroupsDem.csv",
                      biom.indx = "outputFolder/outputSETASBiomIndx.txt",
                      run.prm = "VMPA_setas_run_fishing_F_Trunk.prm",
                      dt.timeseries = 5)
  # Evaluate the objective function at the initial parameter values
  objfn(par = forcing[["paropt"]])
} # }
```
