#' Check the subject ID code and return corresponding Room 1 and Room 2 codes.
#'
#' @param code Method for generating subject IDs ("id", "id+comment", "study+id", or "manual").
#' @param manual A custom code(string), required if `code` is "manual".
#' @param metadata DataFrame for metadata of Room 1.
#' @param v1 Boolean, Software Version, default FALSE.
#' @return String, the resulting code.
#' @export
#' @examples
#' # Example metadata
#' metadata <- data.frame(`Subject.ID` = "S001", `Study.ID` = "studyname", `Comments` = "Morning")
#'
#' # Use subject ID only
#' check_code("id", NULL, metadata)
#'
#' # Use subject ID + comment
#' check_code("id+comment", NULL, metadata)
#'
#' # Use study ID + subject ID
#' check_code("study+id", NULL, metadata)
#'
#' # Use manual codes
#' check_code("manual", "custom1", metadata)
check_code <- function(code, manual, metadata, v1 = FALSE) {
  if (code == "id") {
    code_out <- metadata$`Subject.ID`[1]
  } else if (code == "id+comment") {
    code_out <- paste0(metadata$`Subject.ID`[1], "_", metadata$`Comments`[1])
  } else if (code == "study+id" && !v1) { # only available for v2
    code_out <- paste0(metadata$`Study.ID`[1], "_", metadata$`Subject.ID`[1])
  } else if (code == "manual" && !is.null(manual)) {
    code_out <- manual
  } else {
    stop("Invalid code parameter. Choose 'id', 'id+comment', or 'manual' and provide a manual code.")
  }
  return(code_out)
}

#' Extracts metadata (software v1) for two subjects from text lines and optionally saves it as CSV files.
#'
#' @param lines List of strings containing the wric metadata.
#' @inheritParams preprocess_wric_file
#' @param manual Custom codes for Room 1 and Room 2 subjects if `code` is "manual".
#' @param save_csv Logical, whether to save extracted metadata to CSV files.
#' @param path_to_save Directory path for saving CSV files, NULL uses the current directory.
#' @return A list containing the Room 1 code, Room 2 code, and DataFrames for r1_metadata and r2_metadata.
#' @export
#' @examples
#' lines <- c(
#'   "OmniCal software by ing.P.F.M.Schoffelen, Dept. of Human Biology, Maastricht University",
#'   "file identifier is C:\\MI_Room_Calorimeter\\Results_online\\1_minute\\Results.txt",
#'   "",
#'   "Room 1\tProject\tSubject ID\tExperiment performed by\tComments",
#'   "\tPROJECT\tXXXX\tJANE DOE\t",
#'   "Room 2\tProject\tSubject ID\tExperiment performed by\tComments",
#'   "\tPROJECT\tYYYY\tJOHN DOE\t"
#' )
#'
#' extract_meta_data(lines, code = "id", manual = NULL, save_csv = FALSE, path_to_save = NULL)
extract_meta_data <- function(lines, code, manual, save_csv = FALSE, path_to_save) {
  header_lines <- lapply(lines[4:7], function(line) unlist(strsplit(trimws(line), "\t")))

  # Standardize lengths to avoid errors - might have to rename your documents manually if there are eg IDs missing
  adjust_length <- function(data, reference) {
    length_diff <- length(reference) - length(data)
    if (length_diff > 0) {
      data <- c(data, rep(NA, length_diff))  # Pad with NAs if too short (no comment)
    } else if (length_diff < 0) {
      data <- head(data, length(reference))  # Truncate if too long (new lines in comment)
    }
    return(data)
  }

  header_lines[[2]] <- adjust_length(header_lines[[2]], header_lines[[1]][-1])
  header_lines[[4]] <- adjust_length(header_lines[[4]], header_lines[[3]][-1])

  data_r1 <- setNames(as.list(header_lines[[2]]), header_lines[[1]][-1])
  data_r2 <- setNames(as.list(header_lines[[4]]), header_lines[[3]][-1])

  r1_metadata <- as.data.frame(data_r1, stringsAsFactors = FALSE)
  r2_metadata <- as.data.frame(data_r2, stringsAsFactors = FALSE)

  code_1 <- check_code(code, if (!is.null(manual)) manual[1] else NULL, r1_metadata, v1 = TRUE)
  code_2 <- check_code(code, if (!is.null(manual)) manual[2] else NULL, r2_metadata, v1 = TRUE)

  if (save_csv) {
    room1_filename <- ifelse(!is.null(path_to_save), paste0(path_to_save, "/", code_1, "_wric_metadata.csv"), paste0(code_1, "_wric_metadata.csv"))
    room2_filename <- ifelse(!is.null(path_to_save), paste0(path_to_save, "/", code_2, "_wric_metadata.csv"), paste0(code_2, "_wric_metadata.csv"))
    write.csv(r1_metadata, room1_filename, row.names = FALSE)
    write.csv(r2_metadata, room2_filename, row.names = FALSE)
  }

  return(list(code_1 = code_1, code_2 = code_2, r1_metadata = r1_metadata, r2_metadata = r2_metadata))
}

#' Extracts metadata (software v2) for a single subject from text lines and optionally saves it as a CSV file.
#'
#' @param lines List of strings containing the wric metadata.
#' @param manual Custom code for the subject if `code` is "manual".
#' @inheritParams preprocess_wric_file
#' @param save_csv Logical, whether to save extracted metadata to a CSV file.
#' @param path_to_save Directory path for saving the CSV file, NULL uses the current directory.
#' @return A list containing:
#' \describe{
#'   \item{code}{The generated subject code.}
#'   \item{metadata}{A data.frame containing the extracted metadata.}
#' }
#' @export
#' @examples
#' lines <- c(
#'   "2.0.0.15\tOmnical software by Maastricht Instruments B.V.",
#'   "file identifier is C:\\Omnical\\Results Room 1\\1 min\\Results.txt",
#'   "Calibration values\t18.0\t0.795",
#'   "",
#'   "Subject ID\tStudy ID\tMeasurement ID\tResearcher ID\tComments",
#'   "ZeroTest\t\t\tNZ\tZero Test 14.01.2026"
#' )
#'
#' # Extract metadata and generate code from subject ID only
#' extract_metadata_new(lines, code = "id", manual = NULL, save_csv = FALSE)
#'
#' # Extract metadata using ID + comment as code
#' extract_metadata_new(lines, code = "id+comment", manual = NULL, save_csv = FALSE)
#'
#' # Extract metadata using a manual code
#' extract_metadata_new(lines, code = "manual", manual = "custom_code", save_csv = FALSE)

extract_metadata_new <- function(lines, code, manual = NULL, save_csv = FALSE, path_to_save = NULL) {

  header_line <- unlist(strsplit(trimws(lines[5]), "\t"))
  data_line <- unlist(strsplit(trimws(lines[6]), "\t"))

  # Adjust lengths to match header
  adjust_length <- function(data, reference) {
    length_diff <- length(reference) - length(data)
    if (length_diff > 0) {
      data <- c(data, rep(NA, length_diff))  # pad with NAs
    } else if (length_diff < 0) {
      data <- head(data, length(reference))  # truncate if too long
    }
    return(data)
  }

  data_line <- adjust_length(data_line, header_line)

  metadata <- as.data.frame(
    setNames(as.list(data_line), header_line),
    stringsAsFactors = FALSE
    )
  code <- check_code(code, if (!is.null(manual)) manual[1] else NULL, metadata, v1 = FALSE)

  # Save CSV if requested
  if (save_csv) {
    filename <- ifelse(
      !is.null(path_to_save),
      paste0(path_to_save, "/", code, "_wric_metadata.csv"),
      paste0(code, "_wric_metadata.csv")
    )
    write.csv(metadata, filename, row.names = FALSE)
  }
  return(list(code = code, metadata = metadata))
}


#' Opens a WRIC .txt file and reads its contents, identifying the software version.
#'
#' @param filepath description filepath
#' @return A list with two elements:
#'   - lines: the lines of the file
#'   - v1: TRUE if version 1, FALSE if version 2
#' @note Raises an error if the file is not a valid wric data file.
#' @keywords internal
open_file <- function(filepath) {
  if (!grepl("\\.txt$", tolower(filepath))) {
    stop("The file must be a .txt file.")
  }
  lines <- readLines(filepath)
  if (length(lines) == 0) {
    stop("The file is empty and not a valid WRIC data file.")
  }

  # Check for version 1 header
  if (grepl("^OmniCal software by ing\\.P\\.F\\.M\\.Schoffelen", lines[1])) {
    v1 <- TRUE
  }
  # Check for version 2 header
  else if (grepl("^2\\.[0-9]+\\.[0-9]+\\.[0-9]+\\s+Omnical software by Maastricht Instruments B\\.V\\.", lines[1])) {
    v1 <- FALSE
  }
  else {
    stop("The provided file is not a recognized Maastricht Instruments WRIC data file (neither version 1 nor 2).")
  }

  return(list(lines = lines, v1 = v1))
}

#' Add Relative Time in minutes to DataFrame. Rows before the `start_time` will be indicated negative.
#'
#' @param df A data frame containing a 'datetime' column.
#' @param start_time Optional; the starting time for calculating relative time.
#'                   Should be in a format compatible with POSIXct (eg. "2023-11-13 11:40:00")
#' @return A data frame with an additional column 'relative_time[min]' indicating
#'         the time in minutes from the start time.
#' @export
#' @examples
#' # Create example data
#' df <- data.frame(
#'   datetime = as.POSIXct(c("2023-11-13 11:40:00", "2023-11-13 11:45:00", "2023-11-13 11:50:00"))
#' )
#' add_relative_time(df)
#' add_relative_time(df, start_time = "2023-11-13 11:45:00")
add_relative_time <- function(df, start_time = NULL) {
  if (is.null(start_time)) {
    start_time <- df$datetime[1]
  }
  start_time <- as.POSIXct(start_time)
  df$`relative_time` <- as.numeric(difftime(df$datetime, start_time, units = "mins"))
  return(df)
}

#' Filters rows in a DataFrame based on an optional start and end datetime range.
#'
#' @param df data.frame
#'   DataFrame with a "datetime" column to filter.
#' @param start character or POSIXct or NULL, optional;
#'    Start datetime; rows before this will be removed. If NULL, uses the earliest datetime in the DataFrame.
#' @param end character or POSIXct or NULL, optional
#'   End datetime; rows after this will be removed. If NULL, uses the latest datetime in the DataFrame.
#' @return data.frame
#'   DataFrame with rows between the specified start and end dates, or the full DataFrame if both are NULL.
#' @details
#'   Throws an error if filtering by start and end results in an empty DataFrame:
#'   no rows remain after applying the start/end window.
#' @export
#' @examples
#' df <- data.frame(
#'   datetime = as.POSIXct(c(
#'     "2023-11-13 11:40:00",
#'     "2023-11-13 11:45:00",
#'     "2023-11-13 11:50:00"
#'   ))
#' )
#'
#' # Filter rows from 11:45 onward
#' cut_rows(df, start = "2023-11-13 11:45:00")
#'
#' # Filter rows between 11:40 and 11:45
#' cut_rows(df, start = "2023-11-13 11:40:00", end = "2023-11-13 11:45:00")
#'
#' # No filtering (both NULL)
#' cut_rows(df)
cut_rows <- function(df, start = NULL, end = NULL) {
  df$datetime <- as.POSIXct(df$datetime)

  start <- if (is.null(start) || is.na(start)) min(df$datetime, na.rm = TRUE) else as.POSIXct(start)
  end   <- if (is.null(end)   || is.na(end))   max(df$datetime, na.rm = TRUE) else as.POSIXct(end)

  start <- as.POSIXct(start)
  end <- as.POSIXct(end)

  df_cut <- df[df$datetime >= start & df$datetime <= end, , drop = FALSE]

  if (nrow(df_cut) == 0) {
    stop("No rows left after applying start and end filter. Check your time window.")
  }

  return(df[df$datetime >= start & df$datetime <= end, , drop = FALSE])
}

#' Assign protocol values to rows based on timestamps
#'
#' Helper for [extract_note_info()]. Updates the `protocol` column in `df`
#' according to change points defined in `protocol_list`.
#'
#' @param df A data frame with a `datetime` column; a `protocol` column will be updated.
#' @param protocol_list A data frame with `timestamp` and `protocol` columns.
#'
#' @return The input data frame with updated `protocol` values.
#' @keywords internal
#' @noRd
update_protocol <- function(df, protocol_list) {
  current_protocol <- 0
  current_index <- 1

  # Ensure protocol_list is a data frame and check for empty data frame
  if (nrow(protocol_list) == 0) {
    return(df)  # If no protocols, return original DataFrame
  }

  # initialize protocol column
  if (!"protocol" %in% colnames(df)) {
    df[["protocol"]] <- NA
  }

  for (i in seq_len(nrow(df))) {
    # While there are more timestamps and the current row's datetime is greater than or equal to the timestamp
    while (current_index <= nrow(protocol_list) &&
           df$datetime[i] >= protocol_list[current_index, "timestamp"]) {
      current_protocol <- protocol_list[current_index, "protocol"]  # Update current protocol
      current_index <- current_index + 1  # Move to the next timestamp
    }

    df$protocol[i] <- current_protocol
  }

  return(df)
}

#' Automatically detect enter and exit from the chamber based on the notefile.
#' Returns the start and end times for two participants.
#'
#' @param notes_path string - path to the note file
#' @param v1 Boolean, Software Version, default FALSE.
#' @param entry_exit_dict Nested List, used to extract entry/exit times from note file
#' @return list - A list of two elements ("1" and "2"), each containing a tuple (start, end) time.
#'                Returns NA if not possible to find start or end time.
#' @export
#' @examples
#' notes_path <- system.file("extdata", "note.txt", package = "wrictools")
#' detect_start_end(notes_path)
detect_start_end <- function(notes_path, v1 = FALSE, entry_exit_dict = NULL) {
  keywords_dict <- list(
    end = c("ud", "exit", "out"),
    start = c("ind i kammer", "enter", "ind", "entry", "in")
  )

  # Read the note file and create a DataFrame
  notes_content <- readLines(notes_path)
  lines <- strsplit(notes_content[-c(1, 2)], "\t")
  df_note <- data.frame(matrix(unlist(lines), ncol = length(lines[[1]]), byrow = TRUE))
  colnames(df_note) <- unlist(lines[[1]])
  df_note <- na.omit(df_note)

  # Combine to datetime
  df_note$datetime <- as.POSIXct(
    paste(df_note$Date, df_note$Time),
    format = if (v1) "%m/%d/%y %H:%M:%S" else "%d/%m/%Y %H:%M:%S"
  )
  df_note <- df_note[, !(names(df_note) %in% c("Date", "Time"))]

  start_end_times <- list("1" = c(NA, NA), "2" = c(NA, NA))

  for (i in seq_len(nrow(df_note))) {
    comment <- tolower(df_note$Comment[i])
    participants <- if (grepl("^1", comment)) {
      c("1")
    } else if (grepl("^2", comment)) {
      c("2")
    } else {
      c("1", "2")
    }

    for (participant in participants) {
      if (is.na(start_end_times[[participant]][1]) &&
          any(grepl(paste(keywords_dict$start, collapse = "|"), comment))) {
        first_three <- head(df_note$datetime, 4) #there is one empty line, one for clock check and then up to two saying when there going in, rest is not searched
        if (df_note$datetime[i] %in% first_three) {
          start_end_times[[participant]][1] <- df_note$datetime[i]
        }
      } else if (is.na(start_end_times[[participant]][2]) &&
                 any(grepl(paste(keywords_dict$end, collapse = "|"), comment))) {
        last_two <- tail(df_note$datetime, 2) #only checking the last two rows
        if (df_note$datetime[i] %in% last_two) {
          start_end_times[[participant]][2] <- df_note$datetime[i]
        }
      }
    }
  }
  # convert back to POSIXct datetime format
  start_end_times <- lapply(start_end_times, function(times) {
    lapply(times, function(t) as.POSIXct(t, origin = "1970-01-01"))
  })
  return(start_end_times)
}

#' Append protocol entry to participant dictionary
#'
#' Internal helper for protocol handling. Iterates over participants
#' and appends a protocol value with timestamp to their dictionary.
#'
#' @param dict_protocol List of protocol data per participant.
#' @param participant One or more participant IDs.
#' @param timestamp Timestamp of the protocol entry.
#' @param value Protocol value to append.
#'
#' @return Updated `dict_protocol` list.
#' @noRd
#' @keywords internal
append_protocol_entry <- function(dict_protocol, participant, timestamp, value) {
  for (p in participant) {

    dict_protocol[[p]] <- append(dict_protocol[[p]], list(list(timestamp = timestamp, protocol = value)))
  }
  return(dict_protocol)
}

.get_keywords_dict <- function() {
  keywords_dict <- list(
    sleeping = list(keywords = list(c("seng", "sleeping", "bed", "sove", "soeve", "godnat", "night", "sleep")), value = 1),
    eating = list(keywords = list(c("start", "begin", "began"), c("maaltid", "eat", "meal", "food", "spis", "maal", "maad", "mad", "frokost", "morgenmad", "middag", "snack", "aftensmad")), value = 2),
    stop_sleeping = list(keywords = list(c("vaagen", "vaekke", "vaek", "wake", "woken", "vaagnet")), value = 0),
    stop_anything = list(keywords = list(c("faerdig", "faerdig", "stop", "end ", "finished", "slut")), value = 0),
    activity = list(keywords = list(c("start", "begin", "began"), c("step", "exercise", "physical activity", "active", "motion", "aktiv")), value = 3),
    ree_start = list(keywords = list(c("start", "begin", "began"), c("REE", "BEE", "BMR", "RMR", "RER")), value = 4)
  )
  return(keywords_dict)
}



#' Extract protocol events from a note file (without applying to dataframes)
#'
#' @param notes_path Path to the note file (.txt)
#' @param keywords_dict Optional custom keywords dictionary
#' @param v1 Logical, TRUE if old software format (two participants), FALSE for new format (single participant / all)
#' @return A list with two elements:
#'   \describe{
#'     \item{protocols}{A list of protocol events structured by participant ("1", "2") for v1, or "all" for v2. Each entry contains a timestamp and protocol value.}
#'     \item{drift}{POSIXct time difference applied to timestamps, or NULL if no drift was detected.}
#'   }
#' @keywords internal
#' @noRd
extract_protocol_events <- function(notes_path, keywords_dict = NULL, v1 = FALSE) {

  if (is.null(keywords_dict)) {
    keywords_dict <- .get_keywords_dict()
  }

  # Read note file
  notes_content <- readLines(notes_path, encoding = "UTF-8")
  lines <- strsplit(notes_content[-(1:2)], "\t")
  df_note <- as.data.frame(do.call(rbind, lines[-(1:2)]), stringsAsFactors = FALSE)
  colnames(df_note) <- unlist(lines[[1]])
  df_note <- na.omit(df_note)

  # Convert to datetime
  if (v1) {# old software: mm/dd/yy
    df_note$datetime <- as.POSIXct(paste(df_note$Date, df_note$Time), format = "%m/%d/%y %H:%M:%S")
  } else {# new software: dd/mm/yyyy
    df_note$datetime <- as.POSIXct(paste(df_note$Date, df_note$Time), format = "%d/%m/%Y %H:%M:%S")
  }

  df_note <- df_note[, !names(df_note) %in% c("Date", "Time")]

  # Patterns
  time_pattern <- "([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5]\\d"
  drift_pattern <- "^\\d{2}:\\d{2}(:\\d{2})?$"
  drift <- NULL

  # Initialize empty protocol list
  if (v1) {
    dict_protocol <- list("1" = list(), "2" = list())
  } else {
    dict_protocol <- list("all" = list())
  }

  for (i in seq_len(nrow(df_note))) {
    row <- df_note[i, ]
    comment <- tolower(row$Comment)
    comment <- iconv(comment, to = "UTF-8")

    # Determine participants
    if (v1) {
      if (grepl("^1", comment)) {
        participants <- "1"
      } else if (grepl("^2", comment)) {
        participants <- "2"
      } else {
        participants <- c("1", "2")
      }
    } else {
      participants <- "all"
    }

    # Handle first-row drift
    if (i == 1 && grepl(drift_pattern, row$Comment)) {
      if (grepl("^\\d{2}:\\d{2}$", row$Comment)) {
        row$Comment <- paste0(row$Comment, ":00")
      }
      new_datetime <- as.POSIXct(paste(as.Date(row$datetime), row$Comment), format = "%Y-%m-%d %H:%M:%S")
      drift <- new_datetime - row$datetime
      next
    }

    # Loop over keywords
    for (category in names(keywords_dict)) {
      entry <- keywords_dict[[category]]
      keywords <- entry$keywords
      value <- entry$value

      match_found <- FALSE
      if (length(keywords) > 1) {
        # Multi-group keyword check
        if (all(sapply(keywords, function(group) any(grepl(paste(group, collapse = "|"), comment, ignore.case = TRUE))))) {
          match_found <- TRUE
        }
      } else {
        # Single-group keyword check
        if (any(sapply(keywords, function(group) any(grepl(paste(group, collapse = "|"), comment, ignore.case = TRUE))))) {
          match_found <- TRUE
        }
      }

      if (match_found) {
        match_time <- regmatches(comment, regexpr(time_pattern, comment))
        if (length(match_time) > 0) {
          timestamp <- as.POSIXct(paste(as.Date(row$datetime), match_time), format = "%Y-%m-%d %H:%M")
        } else {
          timestamp <- row$datetime
        }

        # Append to protocol list
        for (p in participants) {
          dict_protocol[[p]] <- append(dict_protocol[[p]], list(list(timestamp = timestamp, protocol = value)))
        }
      }
    }
  }

  # Apply drift to timestamps if any
  if (!is.null(drift)) {
    for (p in names(dict_protocol)) {
      dict_protocol[[p]] <- lapply(dict_protocol[[p]], function(x) {
        x$timestamp <- x$timestamp + drift
        x
      })
    }
  }

  return(list(protocols = dict_protocol, drift = drift))
}

#' Apply protocol events from note files to room data
#'
#' Reads a note file, extracts protocol events for each participant, applies any detected time drift,
#' and updates the protocol column in the provided room data frames.
#'
#' @param notes_path character
#'   Path to the note file containing protocol events.
#' @param df_room1 data.frame
#'   Data frame for room 1 containing at least a "datetime" column.
#' @param df_room2 data.frame
#'   Data frame for room 2 containing at least a "datetime" column.
#' @param keywords_dict list, optional
#'   Custom dictionary of keywords to identify protocol events. If NULL, a default set is used.
#'
#' @return A list with two elements:
#'   \describe{
#'     \item{df_room1}{Data frame for room 1 with updated protocol column.}
#'     \item{df_room2}{Data frame for room 2 with updated protocol column.}
#'   }
#' @export
#'
#' @examples
#' df1 <- data.frame(datetime = as.POSIXct(c("2023-11-13 22:40:00", "2023-11-13 22:50:00")))
#' df2 <- data.frame(datetime = as.POSIXct(c("2023-11-13 22:40:00", "2023-11-13 22:50:00")))
#' note_file <- system.file("extdata", "note.txt", package = "wrictools")
#' res <- extract_note_info(note_file, df1, df2)
#' res$df_room1
#' res$df_room2
extract_note_info <- function(notes_path, df_room1, df_room2, keywords_dict = NULL) {
  # Extract events from notes
  res <- extract_protocol_events(notes_path = notes_path, keywords_dict = keywords_dict, v1 = TRUE)

  # Convert protocol lists to data frames and sort
  protocol_list_1 <- do.call(rbind, lapply(res$protocols[["1"]], function(x) data.frame(timestamp = x$timestamp, protocol = x$protocol)))
  protocol_list_2 <- do.call(rbind, lapply(res$protocols[["2"]], function(x) data.frame(timestamp = x$timestamp, protocol = x$protocol)))
  protocol_list_1 <- protocol_list_1[order(protocol_list_1$timestamp), ]
  protocol_list_2 <- protocol_list_2[order(protocol_list_2$timestamp), ]

  # Apply drift if present
  if (!is.null(res$drift)) {
    df_room1$datetime <- df_room1$datetime + res$drift
    df_room2$datetime <- df_room2$datetime + res$drift
  }

  # Update dataframes using update_protocol
  df_room1 <- update_protocol(df_room1, protocol_list_1)
  df_room2 <- update_protocol(df_room2, protocol_list_2)

  return(list(df_room1 = df_room1, df_room2 = df_room2))
}

#' Apply protocol events from note files to a single room data frame (new software)
#'
#' Reads a note file, extracts protocol events, applies any detected time drift,
#' and updates the protocol column in the provided data frame. Designed for notes
#' generated by the newer software version where all participants are in a single data frame.
#'
#' @param df data.frame
#'   Data frame containing at least a "datetime" column.
#' @param notes_path character
#'   Path to the note file containing protocol events.
#' @param keywords_dict list, optional
#'   Custom dictionary of keywords to identify protocol events. If NULL, a default set is used.
#'
#' @return data.frame
#'   The input data frame with an updated "protocol" column based on extracted events.
#' @export
#'
#' @examples
#' df <- data.frame(datetime = as.POSIXct(c("2023-11-13 22:40:00", "2023-11-13 22:50:00")))
#' note_file <- system.file("extdata", "note_v2.txt", package = "wrictools")
#' df_updated <- extract_note_info_new(df, note_file)
#' df_updated
extract_note_info_new <- function(df, notes_path, keywords_dict = NULL) {
  # Extract events from notes
  res <- extract_protocol_events(notes_path = notes_path, keywords_dict = keywords_dict, v1 = FALSE)

  # Convert protocol list to data frame and sort
  protocol_list <- do.call(rbind, lapply(res$protocols[["all"]], function(x) data.frame(timestamp = x$timestamp, protocol = x$protocol)))
  protocol_list <- protocol_list[order(protocol_list$timestamp), ]

  # Apply drift if present
  if (!is.null(res$drift)) {
    df$datetime <- df$datetime + res$drift
  }

  # Update dataframe using update_protocol
  df <- update_protocol(df, protocol_list)

  return(df)
}


#' Creates DataFrames for wric data from a file and optionally saves them as CSV files.
#'
#' @param filepath Path to the wric .txt file.
#' @param lines List of strings read from the file to locate the data start.
#' @param code_1 String representing the codes for Room 1.
#' @param code_2 String representing the codes for Room 2.
#' @param path_to_save Directory path for saving CSV files, NULL uses the current directory.
#' @param start character or POSIXct or NULL, rows before this will be removed, if NULL takes first row e.g "2023-11-13 11:43:00"
#' @param end  character or POSIXct or NULL, rows after this will be removed, if NULL takes last row e.g "2023-11-13 11:43:00"
#' @param notefilepath String, The path to the notefile
#' @param entry_exit_dict Nested List, used to extract entry/exit times from note file
#' @return A list containing DataFrames for Room 1 and Room 2 measurements.
#' @note Raises an error if Date or Time columns are inconsistent across rows.
#' @export
#' @examples
#' # Load example files from the package
#' data_txt <- system.file("extdata", "data.txt", package = "wrictools")
#' notes_txt <- system.file("extdata", "note.txt", package = "wrictools")
#'
#' # Create the data lines for parsing
#' lines <- readLines(data_txt)
#'
#' # Call the function
#' result <- create_wric_df(
#'   filepath = data_txt,
#'   lines = lines,
#'   code_1 = "XXXX",
#'   code_2 = "YYYY",
#'   path_to_save = tempdir(),
#'   start = NULL,
#'   end = NULL,
#'   notefilepath = notes_txt
#' )
create_wric_df <- function(filepath, lines, code_1, code_2, path_to_save = NULL, start = NULL, end = NULL, notefilepath = NULL, entry_exit_dict = NULL) {

  data_start_index <- which(grepl("^Room 1 Set 1", lines)) + 1
  df <- read_tsv(filepath, skip = data_start_index, col_names = FALSE)

  # Drop columns with all NA values
  df <- df %>% select(where(~ !all(is.na(.))))

  # Define new column names
  columns <- c("Date", "Time", "VO2", "VCO2", "RER", "FiO2", "FeO2", "FiCO2", "FeCO2", "Flow",
               "Activity Monitor", "Energy Expenditure (kcal/min)", "Energy Expenditure (kJ/min)",
               "Pressure Ambient", "Temperature Room", "Relative Humidity Room")
  new_columns <- c()
  for (set_num in c("S1", "S2")) {
    for (room in c("r1", "r2")) {
      new_columns <- c(new_columns, paste0(room, "_", set_num, "_", columns))
    }
  }
  colnames(df) <- new_columns

  # Check for consistent Date and Time columns
  date_columns <- df %>% select(contains("Date"))
  time_columns <- df %>% select(contains("Time"))
  if (!all(apply(date_columns, 1, function(x) length(unique(x)) == 1)) ||
      !all(apply(time_columns, 1, function(x) length(unique(x)) == 1))) {
    stop("Date or Time columns do not match in some rows")
  }

  # Combine Date and Time to DateTime
  df <- df %>%
    mutate(
      r1_S1_Date = as.character(.data$r1_S1_Date),
      r1_S1_Time = as.character(.data$r1_S1_Time)
    )
  datetime <- as.POSIXct(paste(df$r1_S1_Date, df$r1_S1_Time), format = "%m/%d/%y %H:%M:%S")
  df$datetime <- datetime

  # delete now unnecessary date and time columns
  columns_to_drop <- c(grep("Time", names(df), ignore.case = FALSE, value = TRUE), grep("Date", names(df), ignore.case = FALSE, value = TRUE))
  df <- df %>% select(-all_of(columns_to_drop))

  df_room1 <- df %>%
    select(contains("r1")) %>%
    mutate(datetime = df$datetime)
  df_room2 <- df %>%
    select(contains("r2")) %>%
    mutate(datetime = df$datetime)

  # Cut to only include desired rows (do before setting the relative time)
  if (!is.null(start) && !is.null(end)) {
    df_room1 <- cut_rows(df_room1, start, end)
    df_room2 <- cut_rows(df_room2, start, end)
  } else if (!is.null(notefilepath)) {
    se_times <- detect_start_end(notefilepath, v1 = TRUE, entry_exit_dict)
    start_1 <- as.POSIXct(se_times[[1]][[1]], origin = "1970-01-01")
    end_1 <- as.POSIXct(se_times[[1]][[2]], origin = "1970-01-01")
    start_2 <- as.POSIXct(se_times[[2]][[1]], origin = "1970-01-01")
    end_2 <- as.POSIXct(se_times[[2]][[2]], origin = "1970-01-01")

    if (!is.null(start)) {
      start_1 <- start
      start_2 <- start
    }
    if (!is.null(end)) {
      end_1 <- end
      end_2 <- end
    }
    df_room1 <- cut_rows(df_room1, start_1, end_1)
    df_room2 <- cut_rows(df_room2, start_2, end_2)
    print(paste("Starting time for room 1 is", start_1, "and end", end_1,
                "and for room 2 start is", start_2, "and end", end_2))
  } else {
    df_room1 <- cut_rows(df_room1, start, end)
    df_room2 <- cut_rows(df_room2, start, end)
  }
  df_room1 <- add_relative_time(df_room1)
  df_room2 <- add_relative_time(df_room2)

  return(list(df_room1 = df_room1, df_room2 = df_room2))
}

#' Creates a DataFrame for WRIC data from the new Omnical software format.
#'
#' @param filepath Path to the new-format WRIC .txt file.
#' @param lines List of strings read from the file to locate the data start (used to find "Set 1").
#' @param code String representing the study or participant code, used for naming outputs.
#' @param path_to_save Directory path for saving CSV files or outputs. Currently not used for saving; default NULL.
#' @param start Character or POSIXct or NULL. Rows before this time will be removed. If NULL, uses the earliest available row.
#' @param end Character or POSIXct or NULL. Rows after this time will be removed. If NULL, uses the latest available row.
#' @param notefilepath String or NULL. Path to a note file. If provided, `detect_start_end()` is called to determine start and end times.
#' @param entry_exit_dict Nested list, used by `detect_start_end()` to extract entry/exit times from note file.
#' @return A data frame containing the parsed WRIC measurements, including all sets (S1 and S2), a `datetime` column (POSIXct), and `relative_time` column (seconds from start).
#' @note
#' * Raises an error if the "Set 1" header cannot be found in the file.
#' * Raises an error if Date or Time columns are inconsistent across sets in any row.
#' * Handles the extra empty column between Set 1 and Set 2 to avoid parsing issues.
#' @export
#' @examples
#' # Load example files from the package
#' data_v2_txt <- system.file("extdata", "data_v2.txt", package = "wrictools")
#' notes_v2_txt <- system.file("extdata", "note_v2.txt", package = "wrictools")
#'
#' # Create the data lines for parsing
#' lines <- readLines(data_v2_txt)
#'
#' # Call the function
#' df <- create_wric_df_new(
#'   filepath = data_v2_txt,
#'   lines = lines,
#'   code = "study+id",
#'   path_to_save = NULL,
#'   start = NULL,
#'   end = NULL,
#'   notefilepath = notes_v2_txt
#' )
create_wric_df_new <- function(filepath, lines, code, path_to_save = NULL, start = NULL, end = NULL, notefilepath = NULL, entry_exit_dict = NULL) {

  header_start_index <- which(grepl("^Set 1", lines))
  if (length(header_start_index) == 0) {
    stop("Could not find 'Set 1' header in file.")
  }

  # Due to an empty column between Set1 and Set2 "normal" parsing fails or throws warnings,
  # which is why I delete this column manually before parsing. This is far from
  # ideal and needs to be handled, if future updates ever delete that column.
  data_lines <- lines[(header_start_index + 3):length(lines)]
  data_lines <- gsub("\t\t", "\t", data_lines)

  df <- read_tsv(I(data_lines), col_names = FALSE, show_col_types = FALSE)

  # Drop completely empty columns and rows
  df <- df %>% dplyr::select(where(~ !all(is.na(.))))


  # Define new column names
  base_columns <- c(
    "Date", "Time", "VO2", "VCO2", "RER", "Energy Expenditure (kJ/min)", "Energy Expenditure (kcal/min)",
    "FiO2", "FeO2", "FiCO2", "FeCO2", "Flow", "Pressure Ambient", "Temperature Flow",
    "Relative Humidity Flow", "Temperature Room", "Relative Humidity Room")

  new_columns <- c(paste0("S1_", base_columns), paste0("S2_", base_columns))

  if (ncol(df) != length(new_columns)) {
    stop("Unexpected number of columns in new WRIC file.")
  }

  colnames(df) <- new_columns

  # Check for consistent Date and Time columns
  date_cols <- df %>% dplyr::select(contains("_Date"))
  time_cols <- df %>% dplyr::select(contains("_Time"))
  if (!all(apply(date_cols, 1, function(x) length(unique(x)) == 1)) ||
      !all(apply(time_cols, 1, function(x) length(unique(x)) == 1))) {
    stop("Date or Time columns do not match across sets in some rows.")
  }

  # Combine Date and Time to DateTime
  df <- df %>% mutate(S1_Date = as.character(.data$S1_Date), S1_Time = as.character(.data$S1_Time))
  datetime <- as.POSIXct(paste(df$S1_Date, df$S1_Time), format = "%d/%m/%Y %H:%M:%S")
  df$datetime <- datetime

  # delete now unnecessary date and time columns
  df <- df %>%
    dplyr::select(-contains("_Date"), -contains("_Time"))

  # Cut to only include desired rows
  if (!is.null(start) && !is.null(end)) {
    df <- cut_rows(df, start, end)
  } else if (!is.null(notefilepath)) {
    se_times <- detect_start_end(notefilepath, v1 = FALSE, entry_exit_dict = entry_exit_dict)
    start_time <- as.POSIXct(se_times[[1]][[1]], origin = "1970-01-01")
    end_time   <- as.POSIXct(se_times[[1]][[2]], origin = "1970-01-01")

    if (!is.null(start)) start_time <- start
    if (!is.null(end))   end_time   <- end

    df <- cut_rows(df, start_time, end_time)
  }

  df <- add_relative_time(df)

  return(df)
}



#' Checks for discrepancies between S1 and S2 measurements in the DataFrame and prints them to the console.
#' This function is not included in the big pre-processing function, as it is more intended to
#' perform a quality check on your data and not to automatically inform the processing of the data.
#'
#' @param df DataFrame containing wric data with columns for S1 and S2 measurements.
#' @param threshold Numeric threshold percentage for mean relative delta discrepancies (default 0.05).
#' @param individual Logical, if TRUE checks and reports individual row discrepancies beyond the threshold (default FALSE).
#' @return None. Prints discrepancies to the console.
#' @export
#' @examples
#' data_txt <- system.file("extdata", "data.txt", package = "wrictools")
#' lines <- readLines(data_txt)
#' # Create example WRIC data frames
#' result <- create_wric_df(
#'   filepath = data_txt,
#'   lines = lines,
#'   code_1 = "R1",
#'   code_2 = "R2",
#'   path_to_save = tempdir(),
#'   start = NULL,
#'   end = NULL,
#'   notefilepath = NULL
#' )
#' check_discrepancies(result$df_room1)
check_discrepancies <- function(df, threshold = 0.05, individual = FALSE) {

  env_params <- c("Pressure Ambient", "Temperature", "Relative Humidity", "Activity Monitor")
  df_filtered <- df %>% select(-contains(env_params))

  s1_columns <- df_filtered %>% select(contains("_S1_")) %>% names()
  s2_columns <- df_filtered %>% select(contains("_S2_")) %>% names()

  discrepancies <- c()

  for (i in seq_along(s1_columns)) {
    s1_values <- df[[s1_columns[i]]]
    s2_values <- df[[s2_columns[i]]]
    avg_values <- (s1_values + s2_values) / 2

    relative_deltas <- (s1_values - s2_values) / avg_values
    mean_relative_delta <- mean(relative_deltas, na.rm = TRUE)

    discrepancies <- c(discrepancies, sprintf("%s and %s have a mean relative delta of %.4f.", s1_columns[i], s2_columns[i], mean_relative_delta))

    if (abs(mean_relative_delta) > (threshold / 100)) {
      discrepancies <- c(discrepancies, sprintf("%s and %s exceed the %.2f%% threshold.", s1_columns[i], s2_columns[i], threshold))
    } else {
      discrepancies <- c(discrepancies, sprintf("%s and %s are within the %.2f%% threshold.", s1_columns[i], s2_columns[i], threshold))
    }

    if (individual) {
      for (j in seq_along(relative_deltas)) {
        if (abs(relative_deltas[j]) > (threshold / 100)) {
          discrepancies <- c(discrepancies, sprintf("Row %d: %s and %s differ by a relative delta of %.4f.", j, s1_columns[i], s2_columns[i], relative_deltas[j]))
        }
      }
    }
  }

  cat(discrepancies, sep = "\n")
}

#' Combines S1 and S2 measurements in the DataFrame using the specified method.
#'
#' @param df DataFrame containing wric data with S1 and S2 measurement columns.
#' @param method String specifying the method to combine measurements ("mean", "median", "s1", "s2", "min", "max").
#' @return A DataFrame with combined measurements.
#' @export
#' @examples
#' data_txt <- system.file("extdata", "data.txt", package = "wrictools")
#' lines <- readLines(data_txt)
#'
#' # Create example WRIC DataFrames
#' result <- create_wric_df(
#'   filepath = data_txt,
#'   lines = lines,
#'   code_1 = "R1",
#'   code_2 = "R2",
#'   path_to_save = tempdir(),
#'   start = NULL,
#'   end = NULL,
#'   notefilepath = NULL
#' )
#'
#' # Combine measurements using different methods
#' combined_mean <- combine_measurements(result$df_room1, method = "mean")
#' combined_median <- combine_measurements(result$df_room1, method = "median")
#' combined_s1 <- combine_measurements(result$df_room1)
#'
combine_measurements <- function(df, method = "mean") {
  s1_columns <- df %>% select(contains("S1_")) %>% names()
  s2_columns <- df %>% select(contains("S2_")) %>% names()
  non_s_columns <- names(df)[!names(df) %in% c(s1_columns, s2_columns)]

  combined <- df[, non_s_columns]
  combined <- as.data.frame(combined)

  for (i in seq_along(s1_columns)) {
    if (method == "mean") {
      combined_values <- (df[[s1_columns[i]]] + df[[s2_columns[i]]]) / 2
    } else if (method == "median") {
      combined_values <- apply(cbind(df[[s1_columns[i]]], df[[s2_columns[i]]]), 1, median)
    } else if (method == "s1") {
      combined_values <- df[[s1_columns[i]]]
    } else if (method == "s2") {
      combined_values <- df[[s2_columns[i]]]
    } else if (method == "min") {
      combined_values <- pmin(df[[s1_columns[i]]], df[[s2_columns[i]]], na.rm = TRUE)
    } else if (method == "max") {
      combined_values <- pmax(df[[s1_columns[i]]], df[[s2_columns[i]]], na.rm = TRUE)
    } else {
      stop("Method not supported. Use 'mean', 'median', 's1', 's2', 'min', or 'max'.")
    }
    column_name <- sub("^(r[12]_)?S[12]_", "", s1_columns[i])
    combined[[column_name]] <- combined_values
  }
  return(combined)
}

#' Preprocesses a wric data file, extracting metadata, creating DataFrames, and optionally saving results.
#'
#' @param filepath Path to the wric .txt file.
#' @param code Method for generating subject IDs ("id", "id+comment", "study+id" (only for software v2), or "manual").
#' @param manual Custom codes for subjects in Room 1 and Room 2 if `code` is "manual".
#' @param save_csv Logical, whether to save extracted metadata and data to CSV files.
#' @param path_to_save Directory path for saving CSV files, NULL uses the current directory.
#' @param combine Logical, whether to combine S1 and S2 measurements.
#' @param method Method for combining measurements ("mean", "median", "s1", "s2", "min", "max").
#' @param start character or POSIXct or NULL, rows before this will be removed, if NULL takes first row e.g "2023-11-13 11:43:00"
#' @param end character or POSIXct or NULL, rows after this will be removed, if NULL takes last row e.g "2023-11-13 11:43:00"
#' @param notefilepath String, Directory path of the corresponding note file (.txt)
#' @param keywords_dict Nested List, used to extract protocol values from note file
#' @param entry_exit_dict Nested List, used to extract entry/exit times from note file
#' @return list
#'   A list with the following components:
#'   \describe{
#'     \item{version}{Character string indicating the detected software version
#'       (`"1"` for old software, `"2"` for new software).}
#'     \item{metadata}{A named list containing extracted metadata.
#'       For version 1, this includes `r1` and `r2`.
#'       For version 2, this contains a single `metadata` entry.}
#'     \item{dfs}{A named list containing processed data frames.
#'       For version 1: `room1` and `room2`.
#'       For version 2: `data`.}
#'   }
#' @export
#' @examples
#' outdir <- file.path(tempdir(), "wrictools")
#' dir.create(outdir, showWarnings = FALSE)
#' data_txt <- system.file("extdata", "data_no_comment.txt", package = "wrictools")
#' result <- preprocess_wric_file(data_txt, path_to_save = outdir)
#' unlink(outdir, recursive = TRUE)
preprocess_wric_file <- function(filepath, code = "id", manual = NULL, save_csv = FALSE, path_to_save = NULL, combine = TRUE, method = "mean", start = NULL, end = NULL, notefilepath = NULL, keywords_dict = NULL, entry_exit_dict = NULL) {
  res <- open_file(filepath)
  lines <- res$lines
  v1 <- res$v1

  # Extract Metadata
  if (v1) {
    meta <- extract_meta_data(lines, code, manual, save_csv, path_to_save)
    r1_metadata <- meta$r1_metadata
    r2_metadata <- meta$r2_metadata
    code_1 <- meta$code_1
    code_2 <- meta$code_2
  } else {
    meta <- extract_metadata_new(lines, code, manual, save_csv, path_to_save)
    metadata <- meta$metadata
    code_new <- meta$code
  }

  # Create WRIC Dataframe
  if (v1) {
    res_df <- create_wric_df(filepath, lines, code_1, code_2, path_to_save, start, end, notefilepath, entry_exit_dict)
    df_room1 <- res_df$df_room1
    df_room2 <- res_df$df_room2
  } else {
    df <- create_wric_df_new(filepath, lines, code_new, path_to_save, start, end, notefilepath, entry_exit_dict)
  }

  # Combine Measurement
  if (combine) {
    if (v1) {
      df_room1 <- combine_measurements(df_room1, method)
      df_room2 <- combine_measurements(df_room2, method)
    } else {
      df <- combine_measurements(df, method)
    }
  }

  # Extract notes
  if (!is.null(notefilepath)) {
    if (v1) {
      res_note <- extract_note_info(notefilepath, df_room1, df_room2, keywords_dict)
      df_room1 <- res_note$df_room1
      df_room2 <- res_note$df_room2
    } else {
      df <- extract_note_info_new(df, notefilepath, keywords_dict)
    }
  }

  # Save CSV
  if (save_csv) {
    if (v1) {
      f1 <- if (!is.null(path_to_save)) file.path(path_to_save, paste0(code_1, "_wric_data.csv")) else paste0(code_1, "_wric_data.csv")
      f2 <- if (!is.null(path_to_save)) file.path(path_to_save, paste0(code_2, "_wric_data.csv")) else paste0(code_2, "_wric_data.csv")
      write.csv(df_room1, f1, row.names = FALSE)
      write.csv(df_room2, f2, row.names = FALSE)
    } else {
      f <- if (!is.null(path_to_save)) file.path(path_to_save, paste0(code_new, "_wric_data.csv")) else paste0(code_new, "_wric_data.csv")
      write.csv(df, f, row.names = FALSE)
    }
  }

  # Return
  if (v1) {
    return(list(
      version = "1",
      metadata = list(r1 = r1_metadata, r2 = r2_metadata),
      dfs = list(room1 = df_room1, room2 = df_room2)
      ))
  } else {
    return(list(
      version = "2",
      metadata = list(metadata = metadata),
      dfs = list(data = df)
    ))
  }
}

#' Exports a file from REDCap based on the specified record ID and field name.
#'
#' If you do not specify a path, the data will be downloaded to a temporary folder
#' which is deleted when your R session ends.
#'
#' @param record_id String containing the unique identifier for the record in REDCap.
#' @param fieldname Field name from which to export the file.
#' @param path File path where the exported file will be saved.
#' @param api_url String, URL to the REDCap API, should be specified in your personal config.R file
#' @param api_token String, personal token for the REDCap API, should be specified in your personal config.R file
#' @return None. The file is saved to the specified path.
#' @export
#' @examplesIf file.exists(path.expand("~/.config.R"))
#' source(path.expand("~/.config.R"))
#' export_file_from_redcap(record_id = "1", fieldname = "wric_data",
#'                         api_url = api_url, api_token = api_token)
export_file_from_redcap <- function(record_id, fieldname, path = NULL, api_url, api_token) {

  # avoid cross-plattform errors by setting the certificate globally
  download.file(url = "https://curl.se/ca/cacert.pem", destfile = "cacert.pem")
  options(RCurlOptions = list(cainfo = "cacert.pem"))

  result <- postForm(
    api_url = api_url,
    token = api_token,
    content = "file",
    action = "export",
    record = record_id,
    field = fieldname
  )

  filepath <- if (!is.null(path)) path else tempfile(pattern = "redcap_export_", fileext = ".txt")

  f <- file(filepath, "wb")
  writeLines(result, f)
  close(f)

}

#' Uploads a file to REDCap for a specified record ID and field name.
#'
#' @param filepath Path to the file to be uploaded.
#' @param record_id String containing the unique identifier for the record in REDCap.
#' @param fieldname Field name to which the file will be uploaded.
#' @param api_url String, URL to the REDCap API, should be specified in your personal config.R file
#' @param api_token String, personal token for the REDCap API, should be specified in your personal config.R file
#' @return None. Prints the HTTP status code of the request.
#' @export
#' @examplesIf file.exists(path.expand("~/.config.R"))
#' source(path.expand("~/.config.R"))
#' tmp <- tempfile(fileext = ".txt")
#' writeLines(c("Example content"), tmp)
#' upload_file_to_redcap(filepath = tmp, record_id = "1", fieldname = "wric_data",
#'                         api_url = api_url, api_token = api_token)
upload_file_to_redcap <- function(filepath, record_id, fieldname, api_url, api_token) {

  # avoid cross-plattform errors by setting the certificate globally
  download.file(url = "https://curl.se/ca/cacert.pem", destfile = "cacert.pem")
  options(RCurlOptions = list(cainfo = "cacert.pem"))

  file_content <- paste(readLines(filepath), collapse = "\n")
  result <- postForm(
    api_url = api_url,
    token = api_token,
    content = "file",
    action = "import",
    record = record_id,
    field = fieldname,
    returnFormat = "json",
    file = file_content
  )
}

#' Preprocesses multiple wric_files by RedCAP record ID, extracting metadata, creating DataFrames, and optionally saving results.
#'
#' @param csv_file Path to the CSV file containing record IDs.
#' @param fieldname The field name for exporting wric data from RedCAP.
#' @inheritParams preprocess_wric_file
#' @inheritParams export_file_from_redcap
#' @return A list where each key is a record ID and each value is a list with: (r1_metadata, r2_metadata, df_room1, df_room2).
#' @export
#' @examplesIf file.exists(path.expand("~/.config.R"))
#' source(path.expand("~/.config.R"))
#' tmp_csv <- tempfile(fileext = ".csv")
#' write.csv(data.frame(X1 = c(1, 2, 3)), tmp_csv, row.names = FALSE)
#'
#' # Use dummy API URL and token
#' if (file.exists(tmp_csv)) {
#'   preprocess_wric_files(
#'     csv_file = tmp_csv,
#'     fieldname = "wric_data",
#'     api_url = api_url,
#'     api_token = api_token,
#'     save_csv = FALSE
#'   )
#' }
preprocess_wric_files <- function(csv_file, fieldname, code = "id", manual = NULL,
                                  save_csv = FALSE, path_to_save = NULL, combine = TRUE,
                                  method = "mean", start = NULL, end = NULL,
                                  path = NULL, api_url, api_token) {
  # Read record IDs from CSV
  record_ids <- read_csv(csv_file, col_names = FALSE)$X1

  # Initialize list to store data for each record ID
  dataframes <- list()

  for (record_id in record_ids) {
    # export the file from redcap
    export_file_from_redcap(record_id, fieldname, path = NULL, api_url, api_token)

    # call preprocess_wric_file function
    result <- preprocess_wric_file("./tmp/export.raw.txt", code, manual, save_csv, path_to_save, combine, method, start, end)

    # store the results for the record ID
    dataframes[[as.character(record_id)]] <- list(
      r1_metadata = result$r1_metadata,
      r2_metadata = result$r2_metadata,
      df_room1 = result$df_room1,
      df_room2 = result$df_room2
    )
  }

  return(dataframes)
}

