# Checks for discrepancies between S1 and S2 measurements in the DataFrame and prints them to the console. This function is not included in the big pre-processing function, as it is more intended to perform a quality check on your data and not to automatically inform the processing of the data.

Checks for discrepancies between S1 and S2 measurements in the DataFrame
and prints them to the console. This function is not included in the big
pre-processing function, as it is more intended to perform a quality
check on your data and not to automatically inform the processing of the
data.

## Usage

``` r
check_discrepancies(df, threshold = 0.05, individual = FALSE)
```

## Arguments

- df:

  DataFrame containing wric data with columns for S1 and S2
  measurements.

- threshold:

  Numeric threshold percentage for mean relative delta discrepancies
  (default 0.05).

- individual:

  Logical, if TRUE checks and reports individual row discrepancies
  beyond the threshold (default FALSE).

## Value

None. Prints discrepancies to the console.

## Examples

``` r
data_txt <- system.file("extdata", "data.txt", package = "wrictools")
lines <- readLines(data_txt)
# Create example WRIC data frames
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
check_discrepancies(result$df_room1)
#> r1_S1_VO2 and r1_S2_VO2 have a mean relative delta of 0.0267.
#> r1_S1_VO2 and r1_S2_VO2 exceed the 0.05% threshold.
#> r1_S1_VCO2 and r1_S2_VCO2 have a mean relative delta of 0.0151.
#> r1_S1_VCO2 and r1_S2_VCO2 exceed the 0.05% threshold.
#> r1_S1_RER and r1_S2_RER have a mean relative delta of 0.0033.
#> r1_S1_RER and r1_S2_RER exceed the 0.05% threshold.
#> r1_S1_FiO2 and r1_S2_FiO2 have a mean relative delta of -0.0044.
#> r1_S1_FiO2 and r1_S2_FiO2 exceed the 0.05% threshold.
#> r1_S1_FeO2 and r1_S2_FeO2 have a mean relative delta of 0.0011.
#> r1_S1_FeO2 and r1_S2_FeO2 exceed the 0.05% threshold.
#> r1_S1_FiCO2 and r1_S2_FiCO2 have a mean relative delta of 0.0224.
#> r1_S1_FiCO2 and r1_S2_FiCO2 exceed the 0.05% threshold.
#> r1_S1_FeCO2 and r1_S2_FeCO2 have a mean relative delta of 0.0137.
#> r1_S1_FeCO2 and r1_S2_FeCO2 exceed the 0.05% threshold.
#> r1_S1_Flow and r1_S2_Flow have a mean relative delta of 0.0007.
#> r1_S1_Flow and r1_S2_Flow exceed the 0.05% threshold.
#> r1_S1_Energy Expenditure (kcal/min) and r1_S2_Energy Expenditure (kcal/min) have a mean relative delta of 0.0027.
#> r1_S1_Energy Expenditure (kcal/min) and r1_S2_Energy Expenditure (kcal/min) exceed the 0.05% threshold.
#> r1_S1_Energy Expenditure (kJ/min) and r1_S2_Energy Expenditure (kJ/min) have a mean relative delta of 0.0016.
#> r1_S1_Energy Expenditure (kJ/min) and r1_S2_Energy Expenditure (kJ/min) exceed the 0.05% threshold.
```
