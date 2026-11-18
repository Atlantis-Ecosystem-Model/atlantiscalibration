# Total abundance of an age class per time step

Sums a `<Group><age>_Nums` array over boxes and layers, giving the total
number of individuals of that age class at each time step.

## Usage

``` r
calculate_abund(abund_array)
```

## Arguments

- abund_array:

  Numeric array from
  [`ncdf4::ncvar_get()`](https://rdrr.io/pkg/ncdf4/man/ncvar_get.html)
  for a `_Nums` variable (boxes x layers x time).

## Value

Numeric vector of total abundance, one value per time step.

## Examples

``` r
if (FALSE) { # \dontrun{
  outputs.nc <- open_main_nc(path = "path/to/atlantis/outputs", prefix = "AMPS")
  calculate_abund(ncdf4::ncvar_get(outputs.nc, "Planktiv_S_Fish1_Nums"))
} # }
```
