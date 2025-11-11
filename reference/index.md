# Package index

## All functions

- [`add_relative_time()`](https://ninaziegenbein.github.io/wrictools/reference/add_relative_time.md)
  :

  Add Relative Time in minutes to DataFrame. Rows before the
  `start_time` will be indicated negative.

- [`check_code()`](https://ninaziegenbein.github.io/wrictools/reference/check_code.md)
  : Check the subject ID code and return corresponding Room 1 and Room 2
  codes.

- [`check_discrepancies()`](https://ninaziegenbein.github.io/wrictools/reference/check_discrepancies.md)
  : Checks for discrepancies between S1 and S2 measurements in the
  DataFrame and prints them to the console. This function is not
  included in the big pre-processing function, as it is more intended to
  perform a quality check on your data and not to automatically inform
  the processing of the data.

- [`combine_measurements()`](https://ninaziegenbein.github.io/wrictools/reference/combine_measurements.md)
  : Combines S1 and S2 measurements in the DataFrame using the specified
  method.

- [`create_wric_df()`](https://ninaziegenbein.github.io/wrictools/reference/create_wric_df.md)
  : Creates DataFrames for wric data from a file and optionally saves
  them as CSV files.

- [`cut_rows()`](https://ninaziegenbein.github.io/wrictools/reference/cut_rows.md)
  : Filters rows in a DataFrame based on an optional start and end
  datetime range.

- [`detect_start_end()`](https://ninaziegenbein.github.io/wrictools/reference/detect_start_end.md)
  : Automatically detect enter and exit from the chamber based on the
  notefile. Returns the start and end times for two participants.

- [`export_file_from_redcap()`](https://ninaziegenbein.github.io/wrictools/reference/export_file_from_redcap.md)
  : Exports a file from REDCap based on the specified record ID and
  field name.

- [`extract_meta_data()`](https://ninaziegenbein.github.io/wrictools/reference/extract_meta_data.md)
  : Extracts metadata for two subjects from text lines and optionally
  saves it as CSV files.

- [`extract_note_info()`](https://ninaziegenbein.github.io/wrictools/reference/extract_note_info.md)
  : Extracts and processes note information from a specified notes file,
  categorizing events based on predefined keywords, and updates two
  DataFrames with protocol information for different participants.

- [`preprocess_wric_file()`](https://ninaziegenbein.github.io/wrictools/reference/preprocess_WRIC_file.md)
  : Preprocesses a wric data file, extracting metadata, creating
  DataFrames, and optionally saving results.

- [`preprocess_wric_files()`](https://ninaziegenbein.github.io/wrictools/reference/preprocess_WRIC_files.md)
  : Preprocesses multiple wric_files by RedCAP record ID, extracting
  metadata, creating DataFrames, and optionally saving results.

- [`upload_file_to_redcap()`](https://ninaziegenbein.github.io/wrictools/reference/upload_file_to_redcap.md)
  : Uploads a file to REDCap for a specified record ID and field name.

- [`visualize_with_protocol()`](https://ninaziegenbein.github.io/wrictools/reference/visualize_with_protocol.md)
  : Visualizes time-series data from a WRIC CSV file, highlighting
  protocol changes and optionally saving the plot.
