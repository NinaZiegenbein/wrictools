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
