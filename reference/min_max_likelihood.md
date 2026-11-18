# Min-max likelihood penalty

Penalises model predictions that fall outside the
`[obs_lower, obs_upper]` envelope defined in the observed data.
Predictions within the envelope incur no penalty; predictions below the
lower bound or above the upper bound are penalised proportionally to how
far they deviate, scaled by `1e6` to dominate the objective function.

## Usage

``` r
min_max_likelihood(obs, sim)
```

## Arguments

- obs:

  Numeric matrix with two columns: column 1 is the lower bound
  (`obs_lower`) and column 2 is the upper bound (`obs_upper`) of the
  observed data envelope. One row per time step or observation.

- sim:

  Numeric vector of simulated values, one entry per row of `obs`.

## Value

A non-negative scalar. Returns `0` when all simulated values lie within
their respective `[obs_lower, obs_upper]` bounds, and a large positive
value otherwise (intended to be minimised as part of the calibration
objective function).

## Details

The penalty is computed as a log-ratio: \$\$-10^6 \sum
\min\\\left(\log\frac{s+1}{l+1}, 0\right) + 10^6 \sum
\max\\\left(\log\frac{s+1}{u+1}, 0\right)\$\$ where \\s\\ is the
simulated value, \\l\\ the lower bound, and \\u\\ the upper bound.
Adding 1 to numerator and denominator avoids division by zero when
values are near zero.

## Examples

``` r
if (FALSE) { # \dontrun{
  obs <- cbind(lower = c(10, 20, 30), upper = c(15, 25, 35))
  sim <- c(12, 18, 40)   # 18 below lower[2], 40 above upper[3]
  min_max_likelihood(obs, sim)
} # }
```
