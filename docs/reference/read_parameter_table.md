# Read the table of parameters to calibrate for each functional group

Reads the parameter table, which has one row per functional group and
one column per calibration parameter, with `1` if the parameter is
calibrated for that group and `0` if not. Parameter column names are
matched without regard to case or surrounding spaces and renamed to
`mum`, `BHalpha`, `BHbeta`, `KDENR`, `mfc`, `mQ`, `mL`, `C` and `E`.

## Usage

``` r
read_parameter_table(parameter.file)
```

## Arguments

- parameter.file:

  Character. Name of the parameter table CSV file in `inputs`. Must
  contain a `Code` column and one or more parameter columns. Optional
  columns: `GroupType`, `IsTurnedOn` and `IsCalibrated`.

## Value

A data frame with column `Code`, any of the optional columns present,
and one column per parameter in the table.

## Examples

``` r
if (FALSE) { # \dontrun{
  param.table <- read_parameter_table("parameter_table.csv")
} # }
```
