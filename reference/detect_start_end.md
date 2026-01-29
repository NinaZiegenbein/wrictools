# Automatically detect enter and exit from the chamber based on the notefile. Returns the start and end times for two participants.

Automatically detect enter and exit from the chamber based on the
notefile. Returns the start and end times for two participants.

## Usage

``` r
detect_start_end(notes_path, v1 = FALSE, entry_exit_dict = NULL)
```

## Arguments

- notes_path:

  string - path to the note file

- entry_exit_dict:

  Nested List, used to extract entry/exit times from note file

## Value

list - A list of two elements ("1" and "2"), each containing a tuple
(start, end) time. Returns NA if not possible to find start or end time.

## Examples

``` r
notes_path <- system.file("extdata", "note.txt", package = "wrictools")
detect_start_end(notes_path)
#> $`1`
#> $`1`[[1]]
#> [1] NA
#> 
#> $`1`[[2]]
#> [1] NA
#> 
#> 
#> $`2`
#> $`2`[[1]]
#> [1] NA
#> 
#> $`2`[[2]]
#> [1] NA
#> 
#> 
```
