# Exports a file from REDCap based on the specified record ID and field name.

If you do not specify a path, the data will be downloaded to a temporary
folder which is deleted when your R session ends.

## Usage

``` r
export_file_from_redcap(record_id, fieldname, path = NULL, api_url, api_token)
```

## Arguments

- record_id:

  String containing the unique identifier for the record in REDCap.

- fieldname:

  Field name from which to export the file.

- path:

  File path where the exported file will be saved.

- api_url:

  String, URL to the REDCap API, should be specified in your personal
  config.R file

- api_token:

  String, personal token for the REDCap API, should be specified in your
  personal config.R file

## Value

None. The file is saved to the specified path.

## Examples

``` r
if (FALSE) { # file.exists(path.expand("~/.config.R"))
source(path.expand("~/.config.R"))
export_file_from_redcap(record_id = "1", fieldname = "wric_data",
                        api_url = api_url, api_token = api_token)
}
```
