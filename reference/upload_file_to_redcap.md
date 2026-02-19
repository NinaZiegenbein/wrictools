# Uploads a file to REDCap for a specified record ID and field name.

Uploads a file to REDCap for a specified record ID and field name.

## Usage

``` r
upload_file_to_redcap(filepath, record_id, fieldname, api_url, api_token)
```

## Arguments

- filepath:

  Path to the file to be uploaded.

- record_id:

  String containing the unique identifier for the record in REDCap.

- fieldname:

  Field name to which the file will be uploaded.

- api_url:

  String, URL to the REDCap API, should be specified in your personal
  config.R file

- api_token:

  String, personal token for the REDCap API, should be specified in your
  personal config.R file

## Value

The HTTP status code of the request.

## Examples

``` r
if (FALSE) { # file.exists(path.expand("~/.config.R"))
source(path.expand("~/.config.R"))
tmp <- tempfile(fileext = ".txt")
writeLines(c("Example content"), tmp)
upload_file_to_redcap(
  filepath = tmp, record_id = "1", fieldname = "wric_data",
  api_url = api_url, api_token = api_token
)
}
```
