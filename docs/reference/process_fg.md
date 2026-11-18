# Load and classify functional groups by biomass type

Calls [`open_fg_file`](open_fg_file.md) and adds a `BiomassType` column
that classifies each group as `"vertebrate"`, `"plankton"`, `"2D"`, or
`"other"` based on `GroupType`. Only active groups belonging to one of
the known `GroupType` values are returned.

## Usage

``` r
process_fg(fg.file)
```

## Arguments

- fg.file:

  Character. Path to the functional groups CSV file.

## Value

A data frame of active functional groups with an added `BiomassType`
column.

## Examples

``` r
if (FALSE) { # \dontrun{
  fg <- process_fg("path/to/PugetSoundAtlantisFunctionalGroups.csv")
  table(fg$BiomassType)
} # }
```
