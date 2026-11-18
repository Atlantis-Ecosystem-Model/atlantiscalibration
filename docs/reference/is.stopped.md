# Test whether an Atlantis simulation stopped prematurely

Compares the last time step written to the output against the configured
`tstop` value. Returns `TRUE` when the simulation ended more than one
step before the scheduled stop, indicating a crash or early termination.

## Usage

``` r
is.stopped(path, txt.filename, run.filename)
```

## Arguments

- path:

  Character. Path to the Atlantis run directory.

- txt.filename:

  Character. Relative path to the biomass index text file (e.g.
  `"outputFolder/AMPS_OUTBiomIndx.txt"`).

- run.filename:

  Character. Name of the run parameter file relative to `path` (e.g.
  `"PugetSound_run.prm"`).

## Value

Logical. `TRUE` if the simulation ended prematurely, `FALSE` otherwise.

## Examples

``` r
if (FALSE) { # \dontrun{
  is.stopped(path         = "path/to/atlantis/run",
             txt.filename = "outputFolder/AMPS_OUTBiomIndx.txt",
             run.filename = "PugetSound_run.prm")
} # }
```
