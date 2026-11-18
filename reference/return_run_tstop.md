# Read the scheduled stop time from the run parameter file

Parses the `tstop` line from the Atlantis `run.prm` file and returns the
configured simulation stop time in seconds.

## Usage

``` r
return_run_tstop(path, run.filename)
```

## Arguments

- path:

  Character. Path to the Atlantis run directory.

- run.filename:

  Character. Name of the run parameter file relative to `path` (e.g.
  `"PugetSound_run.prm"`).

## Value

Numeric. The scheduled stop time in seconds as set by `tstop`.

## Examples

``` r
if (FALSE) { # \dontrun{
  return_run_tstop(path         = "path/to/atlantis/run",
                   run.filename = "PugetSound_run.prm")
} # }
```
