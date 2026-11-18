# Extract mean weight-at-age from Atlantis outputs

Computes weight-at-age (tonnes wet weight per individual) for each
age-class group by combining reserve nitrogen (`_ResN`) and structural
nitrogen (`_StructN`), weighted by the relative spatial abundance of
each cohort. The conversion from mg N to tonnes wet weight uses \\20
\times 5.7 / 10^6\\ (C:N Redfield ratio times energy conversion, scaled
to tonnes).

## Usage

``` r
extract_waa(path, prefix = NULL)
```

## Arguments

- path:

  Character. Path to the directory containing Atlantis outputs.

- prefix:

  Character. Prefix of the Atlantis configuration (e.g. `"AMPS"`).

## Value

A named list with one element per age-class group. Each element is a
numeric vector of mean individual weight (tonnes wet weight), one value
per time step.

## Examples

``` r
if (FALSE) { # \dontrun{
  waa <- extract_waa(
    path   = "path/to/atlantis/outputs",
    prefix = "AMPS"
  )
} # }
```
