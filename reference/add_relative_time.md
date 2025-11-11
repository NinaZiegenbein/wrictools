# Add Relative Time in minutes to DataFrame. Rows before the `start_time` will be indicated negative.

Add Relative Time in minutes to DataFrame. Rows before the `start_time`
will be indicated negative.

## Usage

``` r
add_relative_time(df, start_time = NULL)
```

## Arguments

- df:

  A data frame containing a 'datetime' column.

- start_time:

  Optional; the starting time for calculating relative time. Should be
  in a format compatible with POSIXct (eg. "2023-11-13 11:40:00")

## Value

A data frame with an additional column
'relative_time[min](https://rdrr.io/r/base/Extremes.html)' indicating
the time in minutes from the start time.

## Examples

``` r
# Create example data
df <- data.frame(
  datetime = as.POSIXct(c("2023-11-13 11:40:00", "2023-11-13 11:45:00", "2023-11-13 11:50:00"))
)
add_relative_time(df)
#>              datetime relative_time
#> 1 2023-11-13 11:40:00             0
#> 2 2023-11-13 11:45:00             5
#> 3 2023-11-13 11:50:00            10
add_relative_time(df, start_time = "2023-11-13 11:45:00")
#>              datetime relative_time
#> 1 2023-11-13 11:40:00            -5
#> 2 2023-11-13 11:45:00             0
#> 3 2023-11-13 11:50:00             5
```
