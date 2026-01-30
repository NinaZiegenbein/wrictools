# Extracts metadata (software v2) for a single subject from text lines and optionally saves it as a CSV file.

Extracts metadata (software v2) for a single subject from text lines and
optionally saves it as a CSV file.

## Usage

``` r
extract_metadata_new(
  lines,
  code,
  manual = NULL,
  save_csv = FALSE,
  path_to_save = NULL
)
```

## Arguments

- lines:

  List of strings containing the wric metadata.

- code:

  Method for generating subject IDs ("id", "id+comment", "study+id"
  (only for software v2), or "manual").

- manual:

  Custom code for the subject if `code` is "manual".

- save_csv:

  Logical, whether to save extracted metadata to a CSV file.

- path_to_save:

  Directory path for saving the CSV file, NULL uses the current
  directory.

## Value

A list containing:

- code:

  The generated subject code.

- metadata:

  A data.frame containing the extracted metadata.

## Examples

``` r
lines <- c(
  "2.0.0.15\tOmnical software by Maastricht Instruments B.V.",
  "file identifier is C:\\Omnical\\Results Room 1\\1 min\\Results.txt",
  "Calibration values\t18.0\t0.795",
  "",
  "Subject ID\tStudy ID\tMeasurement ID\tResearcher ID\tComments",
  "ZeroTest\t\t\tNZ\tZero Test 14.01.2026"
)

# Extract metadata and generate code from subject ID only
extract_metadata_new(lines, code = "id", manual = NULL, save_csv = FALSE)
#> $code
#> [1] "ZeroTest"
#> 
#> $metadata
#>   Subject.ID Study.ID Measurement.ID Researcher.ID             Comments
#> 1   ZeroTest                                    NZ Zero Test 14.01.2026
#> 

# Extract metadata using ID + comment as code
extract_metadata_new(lines, code = "id+comment", manual = NULL, save_csv = FALSE)
#> $code
#> [1] "ZeroTest_Zero Test 14.01.2026"
#> 
#> $metadata
#>   Subject.ID Study.ID Measurement.ID Researcher.ID             Comments
#> 1   ZeroTest                                    NZ Zero Test 14.01.2026
#> 

# Extract metadata using a manual code
extract_metadata_new(lines, code = "manual", manual = "custom_code", save_csv = FALSE)
#> $code
#> [1] "custom_code"
#> 
#> $metadata
#>   Subject.ID Study.ID Measurement.ID Researcher.ID             Comments
#> 1   ZeroTest                                    NZ Zero Test 14.01.2026
#> 
```
