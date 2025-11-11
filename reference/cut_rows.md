# Filters rows in a DataFrame based on an optional start and end datetime range.

Filters rows in a DataFrame based on an optional start and end datetime
range.

## Usage

``` r
cut_rows(df, start = NULL, end = NULL)
```

## Arguments

- df:

  data.frame DataFrame with a "datetime" column to filter.

- start:

  character or POSIXct or NULL, optional; Start datetime; rows before
  this will be removed. If NULL, uses the earliest datetime in the
  DataFrame.

- end:

  character or POSIXct or NULL, optional End datetime; rows after this
  will be removed. If NULL, uses the latest datetime in the DataFrame.

## Value

data.frame DataFrame with rows between the specified start and end
dates, or the full DataFrame if both are NULL.

## Examples

``` r
df <- data.frame(
  datetime = as.POSIXct(c(
    "2023-11-13 11:40:00",
    "2023-11-13 11:45:00",
    "2023-11-13 11:50:00"
  ))
)

# Filter rows from 11:45 onward
cut_rows(df, start = "2023-11-13 11:45:00")
#>              datetime
#> 2 2023-11-13 11:45:00
#> 3 2023-11-13 11:50:00

# Filter rows between 11:40 and 11:45
cut_rows(df, start = "2023-11-13 11:40:00", end = "2023-11-13 11:45:00")
#>              datetime
#> 1 2023-11-13 11:40:00
#> 2 2023-11-13 11:45:00

# No filtering (both NULL)
cut_rows(df)
#>              datetime
#> 1 2023-11-13 11:40:00
#> 2 2023-11-13 11:45:00
#> 3 2023-11-13 11:50:00
```
