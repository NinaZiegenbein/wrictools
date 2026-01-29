# Preprocesses a wric data file, extracting metadata, creating DataFrames, and optionally saving results.

Preprocesses a wric data file, extracting metadata, creating DataFrames,
and optionally saving results.

## Usage

``` r
preprocess_wric_file(
  filepath,
  code = "id",
  manual = NULL,
  save_csv = FALSE,
  path_to_save = NULL,
  combine = TRUE,
  method = "mean",
  start = NULL,
  end = NULL,
  notefilepath = NULL,
  keywords_dict = NULL,
  entry_exit_dict = NULL
)
```

## Arguments

- filepath:

  Path to the wric .txt file.

- code:

  Method for generating subject IDs ("id", "id+comment", "study+id"
  (only for software v2), or "manual").

- manual:

  Custom codes for subjects in Room 1 and Room 2 if `code` is "manual".

- save_csv:

  Logical, whether to save extracted metadata and data to CSV files.

- path_to_save:

  Directory path for saving CSV files, NULL uses the current directory.

- combine:

  Logical, whether to combine S1 and S2 measurements.

- method:

  Method for combining measurements ("mean", "median", "s1", "s2",
  "min", "max").

- start:

  character or POSIXct or NULL, rows before this will be removed, if
  NULL takes first row e.g "2023-11-13 11:43:00"

- end:

  character or POSIXct or NULL, rows after this will be removed, if NULL
  takes last row e.g "2023-11-13 11:43:00"

- notefilepath:

  String, Directory path of the corresponding note file (.txt)

- keywords_dict:

  Nested List, used to extract protocol values from note file

- entry_exit_dict:

  Nested List, used to extract entry/exit times from note file

## Value

A list containing the metadata and DataFrames for Room 1 and Room 2.

## Examples

``` r
outdir <- file.path(tempdir(), "wrictools")
dir.create(outdir, showWarnings = FALSE)
data_txt <- system.file("extdata", "data_no_comment.txt", package = "wrictools")
result <- preprocess_wric_file(data_txt, path_to_save = outdir)
#> Rows: 4 Columns: 67
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: "\t"
#> chr   (4): X1, X18, X35, X52
#> dbl  (56): X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, X15, X16, X2...
#> lgl   (3): X17, X34, X51
#> time  (4): X2, X19, X36, X53
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
unlink(outdir, recursive = TRUE)
```
