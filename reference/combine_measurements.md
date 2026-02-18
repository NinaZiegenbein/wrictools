# Combines S1 and S2 measurements in the DataFrame using the specified method.

Combines S1 and S2 measurements in the DataFrame using the specified
method.

## Usage

``` r
combine_measurements(df, method = "mean")
```

## Arguments

- df:

  DataFrame containing wric data with S1 and S2 measurement columns.

- method:

  String specifying the method to combine measurements ("mean",
  "median", "s1", "s2", "min", "max").

## Value

A DataFrame with combined measurements.

## Examples

``` r
data_txt <- system.file("extdata", "data.txt", package = "wrictools")
lines <- readLines(data_txt)

# Create example WRIC DataFrames
result <- create_wric_df(
  filepath = data_txt,
  lines = lines,
  code_1 = "R1",
  code_2 = "R2",
  path_to_save = tempdir(),
  start = NULL,
  end = NULL,
  notefilepath = NULL
)

# Combine measurements using different methods
combined_mean <- combine_measurements(result$df_room1, method = "mean")
combined_median <- combine_measurements(result$df_room1, method = "median")
combined_s1 <- combine_measurements(result$df_room1)
```
