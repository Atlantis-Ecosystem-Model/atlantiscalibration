# Execute an Atlantis simulation via shell script

Runs the Atlantis shell script using `sudo`, after fixing Windows-style
line endings (`flip -uv`) and granting execute permissions (`chmod +x`).

## Usage

``` r
run_atlantis(path, sh.file)
```

## Arguments

- path:

  Character. Absolute path to the directory containing the Atlantis run
  files.

- sh.file:

  Character. Name of the shell script to execute (e.g. `"amps_cal.sh"`).

## Value

`NULL`, called for its side effect of running the simulation.

## Examples

``` r
if (FALSE) { # \dontrun{
  run_atlantis(path = "/home/atlantis/runs/run01", sh.file = "amps_cal.sh")
} # }
```
