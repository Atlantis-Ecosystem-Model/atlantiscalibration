# Open the main Atlantis NetCDF output file

Opens the `<prefix>_OUT.nc` file found in `path`, or `<prefix>.nc` if it
does not exist, using
[`ncdf4::nc_open()`](https://rdrr.io/pkg/ncdf4/man/nc_open.html).

## Usage

``` r
open_main_nc(path, prefix = NULL)
```

## Arguments

- path:

  Character. Path to the directory containing Atlantis outputs.

- prefix:

  Character. Prefix of the Atlantis configuration (e.g. `"AMPS"`).
  Required; stops with an error if `NULL`.

## Value

An open `ncdf4` connection object.

## Examples

``` r
if (FALSE) { # \dontrun{
  outputs.nc <- open_main_nc(path = "path/to/atlantis/outputs", prefix = "AMPS")
  ncdf4::nc_close(outputs.nc)
} # }
```
