# Check the subject ID code and return corresponding Room 1 and Room 2 codes.

Check the subject ID code and return corresponding Room 1 and Room 2
codes.

## Usage

``` r
check_code(code, manual, metadata, v1 = FALSE)
```

## Arguments

- code:

  Method for generating subject IDs ("id", "id+comment", "study+id", or
  "manual").

- manual:

  A custom code(string), required if `code` is "manual".

- metadata:

  DataFrame for metadata of Room 1.

- v1:

  Boolean, Software Version, default FALSE.

## Value

String, the resulting code.

## Examples

``` r
# Example metadata
metadata <- data.frame(`Subject.ID` = "S001", `Study.ID` = "studyname", `Comments` = "Morning")

# Use subject ID only
check_code("id", NULL, metadata)
#> [1] "S001"

# Use subject ID + comment
check_code("id+comment", NULL, metadata)
#> [1] "S001_Morning"

# Use study ID + subject ID
check_code("study+id", NULL, metadata)
#> [1] "studyname_S001"

# Use manual codes
check_code("manual", "custom1", metadata)
#> [1] "custom1"
```
