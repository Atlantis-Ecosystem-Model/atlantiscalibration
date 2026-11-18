# Read the actual stop time reached during a simulation

Reads the last time stamp from the `_OUTBiomIndx.txt` text output, which
records the last time step written before the simulation ended.

## Usage

``` r
return_real_tstop(path, txt.filename)
```

## Arguments

- path:

  Character. Path to the Atlantis run directory.

- txt.filename:

  Character. Relative path to the biomass index text file (e.g.
  `"outputFolder/AMPS_OUTBiomIndx.txt"`).

## Value

Numeric. The last time step value recorded in the output file.

## Examples

``` r
if (FALSE) { # \dontrun{
  return_real_tstop(path         = "path/to/atlantis/run",
                    txt.filename = "outputFolder/AMPS_OUTBiomIndx.txt")
} # }
```
