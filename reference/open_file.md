# Opens a WRIC .txt file and reads its contents, identifying the software version.

Opens a WRIC .txt file and reads its contents, identifying the software
version.

## Usage

``` r
open_file(filepath)
```

## Arguments

- filepath:

  description filepath

## Value

A list with two elements:

- lines: the lines of the file

- v1: TRUE if version 1, FALSE if version 2

## Note

Raises an error if the file is not a valid wric data file.
