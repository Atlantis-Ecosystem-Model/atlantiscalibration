# Collapse a spatial nitrogen array to a time series

Sums a nitrogen array (boxes x layers x time, or boxes x time) over all
spatial dimensions, returning one total per time step.

## Usage

``` r
calculate_Nbiomass(biomass_array)
```

## Arguments

- biomass_array:

  Numeric array as returned by
  [`ncdf4::ncvar_get()`](https://rdrr.io/pkg/ncdf4/man/ncvar_get.html)
  for a `_N` variable. Either 3-D (boxes x layers x time) or 2-D (boxes
  x time).

## Value

Numeric vector of total nitrogen sums, one value per time step.
