# Creates DataFrames for wric data from a file and optionally saves them as CSV files.

Creates DataFrames for wric data from a file and optionally saves them
as CSV files.

## Usage

``` r
create_wric_df(
  filepath,
  lines,
  code_1,
  code_2,
  path_to_save = NULL,
  start = NULL,
  end = NULL,
  notefilepath = NULL,
  entry_exit_dict = NULL
)
```

## Arguments

- filepath:

  Path to the wric .txt file.

- lines:

  List of strings read from the file to locate the data start.

- code_1:

  String representing the codes for Room 1.

- code_2:

  String representing the codes for Room 2.

- path_to_save:

  Directory path for saving CSV files, NULL uses the current directory.

- start:

  character or POSIXct or NULL, rows before this will be removed, if
  NULL takes first row e.g "2023-11-13 11:43:00"

- end:

  character or POSIXct or NULL, rows after this will be removed, if NULL
  takes last row e.g "2023-11-13 11:43:00"

- notefilepath:

  String, The path to the notefile

- entry_exit_dict:

  Nested List, used to extract entry/exit times from note file

## Value

A list containing DataFrames for Room 1 and Room 2 measurements.

## Note

Raises an error if Date or Time columns are inconsistent across rows.

## Examples

``` r
# Load example files from the package
data_txt <- system.file("extdata", "data.txt", package = "wrictools")
notes_txt <- system.file("extdata", "note.txt", package = "wrictools")

# Create the data lines for parsing
lines <- readLines(data_txt)

# Call the function
result <- create_wric_df(
  filepath = data_txt,
  lines = lines,
  code_1 = "XXXX",
  code_2 = "YYYY",
  path_to_save = tempdir(),
  start = NULL,
  end = NULL,
  notefilepath = notes_txt
)
#> Rows: 717 Columns: 67
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: "\t"
#> chr   (4): X1, X18, X35, X52
#> dbl  (56): X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, X15, X16, X2...
#> lgl   (3): X17, X34, X51
#> time  (4): X2, X19, X36, X53
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
#> [1] "Starting time for room 1 is 2023-11-13 21:14:22 and end 2023-11-14 08:47:48 and for room 2 start is 2023-11-13 21:14:22 and end 2023-11-14 08:51:36"
```
