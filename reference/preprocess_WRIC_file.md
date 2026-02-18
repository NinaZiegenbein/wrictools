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

  list, optional A dictionary of keywords used to extract protocol
  events from a note file. Each entry should be a named list with:

  keywords

  :   A character vector of keywords or phrases to match in the note
      comment. Matching is case-insensitive.

  value

  :   Numeric protocol value to assign when the keyword is detected.

  type

  :   Optional character, either "instant" or omitted. "instant" events
      are applied at the specified timestamp and revert to the previous
      protocol immediately after. Non-instant events set the protocol
      until another event occurs.

  Behavior rules:

  Non-instant events

  :   Set the protocol value from their timestamp until another event
      overwrites it or until a stop keyword sets it to 0.

  Instant events

  :   Apply only at the timestamp of the note line, then revert to the
      protocol that was active immediately before.

  Stop keywords

  :   Always set the protocol to 0, regardless of previous state, unless
      overridden by an instant event.

  If `NULL`, a default set of keywords is used.

- entry_exit_dict:

  Nested List, used to extract entry/exit times from note file

## Value

list A list with the following components:

- version:

  Character string indicating the detected software version (`"1"` for
  old software, `"2"` for new software).

- metadata:

  A named list containing extracted metadata. For version 1, this
  includes `r1` and `r2`. For version 2, this contains a single
  `metadata` entry.

- dfs:

  A named list containing processed data frames. For version 1: `room1`
  and `room2`. For version 2: `data`.

## Examples

``` r
outdir <- file.path(tempdir(), "wrictools")
dir.create(outdir, showWarnings = FALSE)
data_txt <- system.file("extdata", "data.txt", package = "wrictools")
result <- preprocess_wric_file(data_txt, path_to_save = outdir)
unlink(outdir, recursive = TRUE)
```
