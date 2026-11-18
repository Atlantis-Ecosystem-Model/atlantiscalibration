# Create the reproduction option file from the biology parameter file

Reads the `flagrecruit<Code>` lines of the Atlantis biology parameter
file and writes the recruitment option of each functional group to
`inputs/reproduction-option.csv`. This file is used by
[`create_target_files_biomass`](create_target_files_biomass.md) to
decide which recruitment parameter (`BHalpha` or `KDENR`) is calibrated
for each group.

## Usage

``` r
repro_option(fg.file, biology.prm)
```

## Arguments

- fg.file:

  Character. Name of the functional groups CSV file in
  `inputs/model_configuration`.

- biology.prm:

  Character. Name of the Atlantis biology parameter file in
  `inputs/model_configuration`.

## Value

Called for its side effect of writing `inputs/reproduction-option.csv`,
with columns `Code` and `flagrecruit`.

## Examples

``` r
if (FALSE) { # \dontrun{
  repro_option(fg.file     = "SETasGroupsDem.csv",
               biology.prm = "VMPA_setas_biol_fishing_Trunk.prm")
} # }
```
