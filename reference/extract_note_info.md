# Apply protocol events from note files to room data

Reads a note file, extracts protocol events for each participant,
applies any detected time drift, and updates the protocol column in the
provided room data frames.

## Usage

``` r
extract_note_info(notes_path, df_room1, df_room2, keywords_dict = NULL)
```

## Arguments

- notes_path:

  character Path to the note file containing protocol events.

- df_room1:

  data.frame Data frame for room 1 containing at least a "datetime"
  column.

- df_room2:

  data.frame Data frame for room 2 containing at least a "datetime"
  column.

- keywords_dict:

  list, optional Custom dictionary of keywords to identify protocol
  events. If NULL, a default set is used.

## Value

A list with two elements:

- df_room1:

  Data frame for room 1 with updated protocol column.

- df_room2:

  Data frame for room 2 with updated protocol column.

## Examples

``` r
df1 <- data.frame(datetime = as.POSIXct(c("2023-11-13 22:40:00", "2023-11-13 22:50:00")))
df2 <- data.frame(datetime = as.POSIXct(c("2023-11-13 22:40:00", "2023-11-13 22:50:00")))
note_file <- system.file("extdata", "note.txt", package = "wrictools")
res <- extract_note_info(note_file, df1, df2)
res$df_room1
#>              datetime protocol
#> 1 2023-11-13 22:41:21        1
#> 2 2023-11-13 22:51:21        1
res$df_room2
#>              datetime protocol
#> 1 2023-11-13 22:41:21        1
#> 2 2023-11-13 22:51:21        1
```
