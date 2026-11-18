# Edit maximum growth rate (mum) for all age classes across functional groups

Replaces the mum values in a biology parameter file for one or more
functional groups. Each group is matched with `grep` on its code:

- `vector.size > 1`: matches `mum_<Code> <vector.size>` and replaces the
  age-class values on the following line.

- `vector.size = 1`: matches `mum_<Code>_T15` and replaces the value on
  that line.

Groups that are not found in `bio.lines` are skipped with a warning.

## Usage

``` r
edit_param_mum_group_age(
  bio.lines,
  new.mum,
  overwrite = F,
  new.file.name,
  single.group = F,
  vector.size = 10,
  group.name = NULL,
  bio.prm = NULL
)
```

## Arguments

- bio.lines:

  Character vector of lines from the biology `.prm` file, typically the
  result of [`readLines()`](https://rdrr.io/r/base/readLines.html).

- new.mum:

  Numeric matrix of replacement mum values. Rows are named by
  functional-group code; columns correspond to age classes 1 through
  `vector.size`. When `single.group = TRUE`, a numeric vector of length
  `vector.size`.

- overwrite:

  Logical. If `TRUE`, write the modified lines back to `bio.prm`; if
  `FALSE` (default) save a copy at `new.file.name`.

- new.file.name:

  Character. Output file path used when `overwrite = FALSE`.

- single.group:

  Logical. If `TRUE`, only the group named `group.name` is updated.
  Default is `FALSE`.

- vector.size:

  Integer. Number of age classes per functional group. Default is `10`.

- group.name:

  Character. Code of the functional group to update. Required when
  `single.group = TRUE`. Default is `NULL`.

- bio.prm:

  Character. Path to the biology `.prm` file that is overwritten.
  Required when `single.group = TRUE` and `overwrite = TRUE`. Default is
  `NULL`.

## Value

Modified `bio.lines` vector (returned only when `single.group = FALSE`);
otherwise `NULL`, called for its side effect of writing a file.

## Examples

``` r
if (FALSE) { # \dontrun{
  bio.lines <- readLines("AMPSbioparam.prm")
  new.mum <- matrix(0.01, nrow = 2, ncol = 10,
                    dimnames = list(c("CHY", "COH"), NULL))
  bio.lines <- edit_param_mum_group_age(bio.lines, new.mum)
} # }
```
