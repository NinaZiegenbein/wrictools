# Extracts and processes note information from a specified notes file, categorizing events based on predefined keywords, and updates two DataFrames with protocol information for different participants.

Extracts and processes note information from a specified notes file,
categorizing events based on predefined keywords, and updates two
DataFrames with protocol information for different participants.

## Usage

``` r
extract_note_info(notes_path, df_room1, df_room2, keywords_dict = NULL)
```

## Arguments

- notes_path:

  string - The file path to the notes file containing event data.

- df_room1:

  DataFrame - DataFrame for participant 1, to be updated with protocol
  info.

- df_room2:

  DataFrame - DataFrame for participant 2, to be updated with protocol
  info.

- keywords_dict:

  nested list - used to identify keywords to extract protocol values

## Value

list - A list containing two updated DataFrames: - `df_room1`: Updated
DataFrame for participant 1 with protocol data. - `df_room2`: Updated
DataFrame for participant 2 with protocol data.

## Note

- The 'Comment' field should start with '1' or '2' to indicate the
  participant, or it may be empty to indicate both.

- The `keywords_dict` can be modified to fit specific study protocols,
  with multi-group checks for keyword matching.

- See ReadMe or vignettes for more detailed examples.

## Examples

``` r
notes_file <- system.file("extdata", "note.txt", package = "wrictools")
df1 <- data.frame(datetime = as.POSIXct("2023-11-13 11:40:00") + 0:2*300)
df2 <- data.frame(datetime = as.POSIXct("2023-11-13 11:40:00") + 0:2*300)
result <- extract_note_info(notes_file, df1, df2)
#> Drift: 1.35
#>             timestamp protocol
#> 1 2023-11-13 22:39:53        1
#> 2 2023-11-14 06:45:00        0
#> 3 2023-11-14 07:01:36        4
#> 4 2023-11-14 07:32:50        0
#> 5 2023-11-14 08:13:27        2
#> 6 2023-11-14 08:26:00        0
#> 7 2023-11-14 08:30:27        2
#> 8 2023-11-14 08:39:23        0
#>             timestamp protocol
#> 1 2023-11-13 22:39:53        1
#> 2 2023-11-14 06:57:25        0
#> 3 2023-11-14 07:19:48        4
#> 4 2023-11-14 07:43:24        0
#> 5 2023-11-14 08:17:00        2
#> 6 2023-11-14 08:22:00        0
#> 7 2023-11-14 08:30:27        2
#> 8 2023-11-14 08:39:23        0
```
