# Run one step of the Atlantis calibration model

Model function called by calibrar at every parameter proposal. Receives
a log-scale parameter vector, back-transforms it via
[`exp()`](https://rdrr.io/r/base/Log.html), writes a parameter snapshot
CSV, edits the relevant entries in the Atlantis biology (and harvest)
parameter files, executes the simulation via a shell script, reads the
outputs, and returns a named list of modeled indicators for comparison
against observations.

calibrar calls this function as `run_model(par, ...)`, where `...` are
the extra arguments given to [`make_objfn`](make_objfn.md). It runs in
the working directory set by calibrar (a copy of `control$master`), so
all file names are relative to that directory.

The parameters edited are those in `names`, as created from the
parameter table by
[`create_target_files_biomass`](create_target_files_biomass.md). Each
factor multiplies the original value(s) in the `.prm` file (see
[`edit_param_factor`](edit_param_factor.md)). Parameter names in `names`
must follow these conventions (other names stop with an error):

- `mum`, `BHalpha`, `BHbeta`, `KDENR`, `C` and `E`:
  `<type>_<Code>_factor` (e.g. `"mum_FPS_factor"`), edited in the
  biology parameter file.

- `mQ` and `mL`: `<Code>_<type>_factor` (e.g. `"ZS_mQ_factor"`), edited
  in the biology parameter file.

- `mfc`: `mfc_<Code>_factor`, edited as `mFC_<Code>` in the harvest
  parameter file.

The shell script that runs Atlantis is the only file with extension
`.sh` in the working directory, and the biology and harvest parameter
files are those given to its options `-b` and `-h` (see
[`read_sh_file`](read_sh_file.md)). The edited parameters are written to
these same files, so Atlantis runs with them. The first time
`run_model()` runs in a directory, each original file is copied to
`<file>.original`; the factors are always applied to the values in this
copy, so they are not applied twice when a directory is reused.

The output list has one element per target in `variables`, matched by
the suffix of the target name:

- `<Code>_biomass`: total biomass of the group.

- `<Name><age>_w`: mean weight at age.

- `<Name>_catch`: total catch of the group, summed over fleets.

- `<Name>_Nums`: matrix of abundance with one column per age class.

Only the last `dt.timeseries` time steps of each output are returned, to
match the length of the targets. If the simulation crashed or stopped
before `tstop`, all outputs are zeros.

## Usage

``` r
run_model(
  param,
  names,
  variables,
  prefix,
  fg.file,
  biom.indx,
  run.prm,
  dt.timeseries,
  param.file = "calibration-parameters.csv",
  track.path = NULL,
  ...
)
```

## Arguments

- param:

  Numeric vector of parameters in log scale. Back-transformed via
  [`exp()`](https://rdrr.io/r/base/Log.html) before use.

- names:

  Character vector of parameter names parallel to `param`.

- variables:

  Character vector. Names of the calibration targets (`setup$variable`),
  which are the names of the returned list.

- prefix:

  Character. Prefix path for the Atlantis NetCDF output files (e.g.
  `"outputFolder/AMPS"`).

- fg.file:

  Character. Name of the functional groups CSV file.

- biom.indx:

  Character. Relative path to the biomass index text file written by the
  run (e.g. `"outputFolder/AMPS_OUTBiomIndx.txt"`), used to detect
  whether the simulation completed.

- run.prm:

  Character. Name of the Atlantis run parameter file, used to read
  `tstop`.

- dt.timeseries:

  Integer. Number of time steps in each target.

- param.file:

  Character. Name of the CSV file written with the back-transformed
  parameter values at each run. Default: `"calibration-parameters.csv"`.

- track.path:

  Character. Absolute path of the folder where the parameter files used
  in each run are saved (see [`keep_track_prm`](keep_track_prm.md)). If
  `NULL` (default), they are not saved.

- ...:

  Other arguments passed by calibrar (e.g. `forcing`), not used.

## Value

A named list of modeled output indicators, one element per target in
`variables`.
