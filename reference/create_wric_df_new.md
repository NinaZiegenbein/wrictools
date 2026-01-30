# Creates a DataFrame for WRIC data from the new Omnical software format.

Creates a DataFrame for WRIC data from the new Omnical software format.

## Usage

``` r
create_wric_df_new(
  filepath,
  lines,
  code,
  path_to_save = NULL,
  start = NULL,
  end = NULL,
  notefilepath = NULL,
  entry_exit_dict = NULL
)
```

## Arguments

- filepath:

  Path to the new-format WRIC .txt file.

- lines:

  List of strings read from the file to locate the data start (used to
  find "Set 1").

- code:

  String representing the study or participant code, used for naming
  outputs.

- path_to_save:

  Directory path for saving CSV files or outputs. Currently not used for
  saving; default NULL.

- start:

  Character or POSIXct or NULL. Rows before this time will be removed.
  If NULL, uses the earliest available row.

- end:

  Character or POSIXct or NULL. Rows after this time will be removed. If
  NULL, uses the latest available row.

- notefilepath:

  String or NULL. Path to a note file. If provided,
  [`detect_start_end()`](https://ninaziegenbein.github.io/wrictools/reference/detect_start_end.md)
  is called to determine start and end times.

- entry_exit_dict:

  Nested list, used by
  [`detect_start_end()`](https://ninaziegenbein.github.io/wrictools/reference/detect_start_end.md)
  to extract entry/exit times from note file.

## Value

A data frame containing the parsed WRIC measurements, including all sets
(S1 and S2), a `datetime` column (POSIXct), and `relative_time` column
(seconds from start).

## Note

- Raises an error if the "Set 1" header cannot be found in the file.

- Raises an error if Date or Time columns are inconsistent across sets
  in any row.

- Handles the extra empty column between Set 1 and Set 2 to avoid
  parsing issues.

## Examples

``` r
# Load example files from the package
data_v2_txt <- system.file("extdata", "data_v2.txt", package = "wrictools")
notes_v2_txt <- system.file("extdata", "note_v2.txt", package = "wrictools")

# Create the data lines for parsing
lines <- readLines(data_v2_txt)

# Call the function
df <- create_wric_df_new(
  filepath = data_v2_txt,
  lines = lines,
  code = "study+id",
  path_to_save = NULL,
  start = NULL,
  end = NULL,
  notefilepath = notes_v2_txt
)
```
