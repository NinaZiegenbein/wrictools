# Extracts metadata for two subjects from text lines and optionally saves it as CSV files.

Extracts metadata for two subjects from text lines and optionally saves
it as CSV files.

## Usage

``` r
extract_meta_data(lines, code, manual, save_csv = FALSE, path_to_save)
```

## Arguments

- lines:

  List of strings containing the wric metadata.

- code:

  Method for generating subject IDs ("id", "id+comment", or "manual").

- manual:

  Custom codes for Room 1 and Room 2 subjects if `code` is "manual".

- save_csv:

  Logical, whether to save extracted metadata to CSV files.

- path_to_save:

  Directory path for saving CSV files, NULL uses the current directory.

## Value

A list containing the Room 1 code, Room 2 code, and DataFrames for
r1_metadata and r2_metadata.

## Examples

``` r
lines <- c(
  "OmniCal software by ing.P.F.M.Schoffelen, Dept. of Human Biology, Maastricht University",
  "file identifier is C:\\MI_Room_Calorimeter\\Results_online\\1_minute\\Results.txt",
  "",
  "Room 1\tProject\tSubject ID\tExperiment performed by\tComments",
  "\tPROJECT\tXXXX\tJANE DOE\t",
  "Room 2\tProject\tSubject ID\tExperiment performed by\tComments",
  "\tPROJECT\tYYYY\tJOHN DOE\t"
)

extract_meta_data(lines, code = "id", manual = NULL, save_csv = FALSE, path_to_save = NULL)
#> $code_1
#> [1] "XXXX"
#> 
#> $code_2
#> [1] "YYYY"
#> 
#> $r1_metadata
#>   Project Subject.ID Experiment.performed.by Comments
#> 1 PROJECT       XXXX                JANE DOE     <NA>
#> 
#> $r2_metadata
#>   Project Subject.ID Experiment.performed.by Comments
#> 1 PROJECT       YYYY                JOHN DOE     <NA>
#> 
```
