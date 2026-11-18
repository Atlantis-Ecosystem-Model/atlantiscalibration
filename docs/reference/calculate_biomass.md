# Convert a spatial nitrogen array to a total biomass time series

Multiplies nitrogen concentration (mg N/m\\^3\\) by cell volume
(m\\^3\\) and applies \\5.7 \times 20 / 10^9\\ to convert to tonnes wet
weight. For 3-D groups (vertebrates, plankton) the full volume array is
used; for 2-D benthic groups layer 7 volumes serve as a proxy for cell
area (layer 7 is 1 m deep, so volume \\\approx\\ area).

## Usage

``` r
calculate_biomass(biomass_array, fg.file, name, outputs.nc)
```

## Arguments

- biomass_array:

  Numeric array from
  [`ncdf4::ncvar_get()`](https://rdrr.io/pkg/ncdf4/man/ncvar_get.html)
  for a `_N` variable. Either 3-D (boxes x layers x time) or 2-D (boxes
  x time).

- fg.file:

  Data frame of functional group metadata (output of
  [`process_fg`](process_fg.md)).

- name:

  Character. Variable name (e.g. `"CHY_N"`).

- outputs.nc:

  An open `ncdf4` connection to the main output file, used to read the
  `volume` variable.

## Value

Numeric vector of total biomass in tonnes wet weight, one value per time
step.

## Examples

``` r
if (FALSE) { # \dontrun{
  outputs.nc <- open_main_nc(path = "path/to/atlantis/outputs", prefix = "AMPS")
  fg <- process_fg("PugetSoundAtlantisFunctionalGroups.csv")
  biomass <- calculate_biomass(ncdf4::ncvar_get(outputs.nc, "CHY_N"),
                               fg.file = fg, name = "CHY_N",
                               outputs.nc = outputs.nc)
} # }
```
