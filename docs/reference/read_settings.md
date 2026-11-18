# Read the calibration settings file

Evaluates the settings file (by default `inputs/settings_file.txt`) and
assigns every variable defined there (e.g. `fg.file`, `biology.prm`,
`var.type`, `n.Cores`, `maxgen`, `master`, `run`) into `envir`, so they
can be passed directly to functions such as
[`make_calsettings`](make_calsettings.md) and
[`read_calibration`](read_calibration.md).

## Usage

``` r
read_settings(
  settings.file = here::here("inputs", "settings_file.txt"),
  envir = parent.frame()
)
```

## Arguments

- settings.file:

  Character. Path to the settings file. Defaults to
  `here::here("inputs", "settings_file.txt")`.

- envir:

  Environment where the variables are assigned. Defaults to the calling
  environment.

## Value

Invisibly returns a named list with all the settings.

## Details

The settings file is plain R code, so values can be R expressions such
as `here::here("RUN")`, `c("biomass", "abundance")` or `NULL`. Both `=`
and `<-` assignments are accepted.

## Examples

``` r
if (FALSE) { # \dontrun{
  read_settings()
  make_calsettings(fg.file = fg.file, var.type = var.type, ...)

  # or keep the settings in a list without touching the environment
  settings <- read_settings(envir = new.env())
} # }
```
