# Find the Atlantis shell script and read the files it uses

Finds the shell script (the only file with extension `.sh` in `path`)
and reads the file names given to each option of the Atlantis command
line, e.g. `-b` (biology parameters), `-h` (harvest parameters), `-r`
(run parameters), `-s` (functional groups), `-o` (output file) and `-d`
(output folder).

## Usage

``` r
read_sh_file(path = getwd())
```

## Arguments

- path:

  Character. Directory with the shell script. Default: the working
  directory.

## Value

A list with elements `sh.file` (name of the shell script) and `files`
(named character vector of file names, named by option letter, e.g.
`files[["b"]]`).

## Examples

``` r
if (FALSE) { # \dontrun{
  sh <- read_sh_file("inputs/model_configuration")
  sh$sh.file
  sh$files[["b"]]  # biology parameter file
} # }
```
