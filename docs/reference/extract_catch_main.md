# Extract catch (landings) time series from Atlantis outputs

When fishery is active, reads the `_Catch_FC` variables from the catch
NetCDF file and sums across all fleet dimensions for each species. When
fishery is inactive, returns a zero-filled list for every functional
group.

## Usage

``` r
extract_catch_main(path, prefix = NULL, fg.file, dt.timeserie, fishery, ...)
```

## Arguments

- path:

  Character. Path to the directory containing Atlantis outputs.

- prefix:

  Character. Prefix of the Atlantis configuration (e.g. `"AMPS"`).

- fg.file:

  Character. Path to the functional groups CSV file.

- dt.timeserie:

  Integer. Number of time steps in the run, used to size the zero-filled
  catch vectors when `fishery = FALSE`.

- fishery:

  Logical. Whether the fishery module was activated in this Atlantis
  run.

- ...:

  Additional arguments (currently unused).

## Value

A named list with one element per functional group. Each element is a
numeric vector of total catch summed across all fleets, one value per
time step. Returns zeros for all groups when `fishery = FALSE`.

## Examples

``` r
if (FALSE) { # \dontrun{
  catch <- extract_catch_main(
    path         = "path/to/atlantis/outputs",
    prefix       = "AMPS",
    fg.file      = "PugetSoundAtlantisFunctionalGroups.csv",
    dt.timeserie = 50,
    fishery      = TRUE
  )
} # }
```
