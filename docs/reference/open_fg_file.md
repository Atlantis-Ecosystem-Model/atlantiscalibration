# Read and filter the functional groups CSV file

Reads the functional groups CSV and retains only rows where
`IsTurnedOn == 1`.

## Usage

``` r
open_fg_file(fg.file)
```

## Arguments

- fg.file:

  Character. Path to the functional groups CSV file.

## Value

A data frame of active functional groups.

## Examples

``` r
if (FALSE) { # \dontrun{
  fg <- open_fg_file("path/to/PugetSoundAtlantisFunctionalGroups.csv")
} # }
```
