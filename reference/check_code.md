# Check the subject ID code and return corresponding Room 1 and Room 2 codes.

Check the subject ID code and return corresponding Room 1 and Room 2
codes.

## Usage

``` r
check_code(code, manual, r1_metadata, r2_metadata)
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
# Example metadata for Room 1 and Room 2
r1 <- data.frame(`Subject.ID` = "S001", `Comments` = "Morning")
r2 <- data.frame(`Subject.ID` = "S002", `Comments` = "Afternoon")

# Use subject IDs only
check_code("id", NULL, r1, r2)
#> [1] "S001" "S002"

# Use subject IDs + comments
check_code("id+comment", NULL, r1, r2)
#> [1] "S001_Morning"   "S002_Afternoon"

# Use manual codes
check_code("manual", c("custom1", "custom2"), r1, r2)
#> [1] "custom1" "custom2"
```
