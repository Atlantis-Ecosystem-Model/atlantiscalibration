# Save the parameter files used in a calibration run

Copies the parameter files used in a model run to
`<track.path>/iteration_<iteration>/run_<run>_<file>`, so the parameters
used in every run of every iteration of the calibration are kept.

## Usage

``` r
keep_track_prm(path, track.path, files)
```

## Arguments

- path:

  Character. Directory where the model is run.

- track.path:

  Character. Folder where the files are saved.

- files:

  Character vector. Names of the files to save, relative to `path`.

## Value

Invisibly, the paths of the saved files.

## Details

calibrar runs each individual of the population in its own directory
`<control$run>/i<run>`, and reuses these directories in every iteration
(generation). The run number is taken from the name of the directory,
and the iteration from a counter kept in the file `.iteration` in that
directory, which is increased by one at every run. The best solution is
evaluated in `i0` at the end of each phase; these files are saved in
`<track.path>/final_<phase>` instead. Outside a calibrar run directory,
the run number is `0`.

## Examples

``` r
if (FALSE) { # \dontrun{
  keep_track_prm(getwd(), here::here("outputs", "keep_track_calibration"),
                 files = c("calibration-parameters.csv", "VMPA_setas_biol_fishing_Trunk.prm"))
} # }
```
