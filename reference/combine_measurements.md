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
  save_csv = FALSE,
  code_1 = "R1",
  code_2 = "R2",
  path_to_save = tempdir(),
  start = NULL,
  end = NULL,
  notefilepath = NULL
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

# Combine measurements using different methods
combined_mean <- combine_measurements(result$df_room1, method = "mean")
combined_median <- combine_measurements(result$df_room1, method = "median")
combined_s1 <- combine_measurements(result$df_room1)
```
