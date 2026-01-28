# Check the subject ID code and return corresponding Room 1 and Room 2 codes.

Check the subject ID code and return corresponding Room 1 and Room 2
codes.

## Usage

``` r
check_code(code, manual, metadata)
```

## Arguments

- code:

  Method for generating subject IDs ("id", "id+comment", or "manual").

- manual:

  A list of custom codes for Room 1 and Room 2, required if `code` is
  "manual".

- r1_metadata:

  DataFrame for metadata of Room 1, containing "Subject ID" and
  "Comments".

- r2_metadata:

  DataFrame for metadata of Room 2, containing "Subject ID" and
  "Comments".

## Value

A list containing the codes for Room 1 and Room 2.

## Examples

``` r
# Example metadata
metadata <- data.frame(`Subject.ID` = "S001", `Comments` = "Morning")

# Use subject IDs only
check_code("id", NULL, metadata)
#> [1] "S001"

# Use subject IDs + comments
check_code("id+comment", NULL, metadata)
#> [1] "S001_Morning"

# Use manual codes
check_code("manual", "custom1", metadata)
#> [1] "custom1"
```
