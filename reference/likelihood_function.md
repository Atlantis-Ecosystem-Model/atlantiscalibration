# User-defined likelihood function for calibration

Penalises simulated values that fall outside the
`[obs_lower, obs_upper]` envelope defined in the observed data.
Simulated values within the envelope incur no penalty; values below the
lower bound or above the upper bound are penalised in proportion to the
log-ratio of their deviation, scaled by `1e6` so the penalty dominates
the objective function.

## Usage

``` r
likelihood_function(obs, sim)
```

## Arguments

- obs:

  Numeric matrix or data frame with two columns: column 1 is the lower
  bound (`obs_lower`) and column 2 is the upper bound (`obs_upper`) of
  the observed data envelope. One row per time step or observation.

- sim:

  Numeric vector of simulated values, one entry per row of `obs`.

## Value

A non-negative numeric scalar. Returns `0` when all simulated values lie
within their respective `[obs_lower, obs_upper]` bounds, and a large
positive value otherwise (intended to be minimised as part of the
calibration objective function).

## Details

The penalty is computed as: \$\$-10^6 \sum
\log\left(\min\left(\frac{s+1}{l+1}, 1\right)\right) + 10^6 \sum
\log\left(\max\left(\frac{s+1}{u+1}, 1\right)\right)\$\$ where \\s\\ is
the simulated value, \\l\\ the lower bound, and \\u\\ the upper bound.
Adding 1 to numerator and denominator avoids division by zero when
values are near zero. `NA` values are ignored.

This function must be exported to cluster workers (e.g. via
[`clusterExport`](https://rdrr.io/r/parallel/clusterApply.html)) when
running the calibration in parallel.

## See also

[`min_max_likelihood`](min_max_likelihood.md)

## Examples

``` r
obs <- cbind(lower = c(10, 20, 30), upper = c(15, 25, 35))
sim <- c(12, 18, 40)   # 18 below lower[2], 40 above upper[3]
likelihood_function(obs, sim)
#> [1] 230136.6
```
