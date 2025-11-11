# Preprocesses multiple wric_files by RedCAP record ID, extracting metadata, creating DataFrames, and optionally saving results.

Preprocesses multiple wric_files by RedCAP record ID, extracting
metadata, creating DataFrames, and optionally saving results.

## Usage

``` r
preprocess_wric_files(
  csv_file,
  fieldname,
  code = "id",
  manual = NULL,
  save_csv = FALSE,
  path_to_save = NULL,
  combine = TRUE,
  method = "mean",
  start = NULL,
  end = NULL,
  path = NULL,
  api_url,
  api_token
)
```

## Arguments

- csv_file:

  Path to the CSV file containing record IDs.

- fieldname:

  The field name for exporting wric data from RedCAP.

- code:

  Method for generating subject IDs ("id", "id+comment", or "manual").

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

- path:

  File path where the exported file will be saved.

- api_url:

  String, URL to the REDCap API, should be specified in your personal
  config.R file

- api_token:

  String, personal token for the REDCap API, should be specified in your
  personal config.R file

## Value

A list where each key is a record ID and each value is a list with:
(r1_metadata, r2_metadata, df_room1, df_room2).

## Examples

``` r
if (FALSE) { # file.exists(path.expand("~/.config.R"))
source(path.expand("~/.config.R"))
tmp_csv <- tempfile(fileext = ".csv")
write.csv(data.frame(X1 = c(1, 2, 3)), tmp_csv, row.names = FALSE)

# Use dummy API URL and token
if (file.exists(tmp_csv)) {
  preprocess_wric_files(
    csv_file = tmp_csv,
    fieldname = "wric_data",
    api_url = api_url,
    api_token = api_token,
    save_csv = FALSE
  )
}
}
```
