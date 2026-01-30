
test_that("preprocess_wric_file does not throw errors with various inputs", {
  # Defining an example dictionary
  example_dict <- list(
    sleeping = list(keywords = list(c("blabla", "sleeping", "bed", "sove", "soeve", "godnat", "night", "sleep")), value = 1),
    eating = list(keywords = list(c("start", "begin", "began"), c("maaltid", "måltid", "eat", "meal", "food", "spis", "maal", "måd", "mad", "frokost", "morgenmad", "middag", "snack", "aftensmad")), value = 2),
    stop_sleeping = list(keywords = list(c("vaagen", "vågen", "vaekke", "væk", "wake", "woken", "vaagnet")), value = 0),
    stop_anything = list(keywords = list(c("faerdig", "færdig", "stop", "end ", "finished", "slut")), value = 0),
    activity = list(keywords = list(c("start", "begin", "began"), c("step", "exercise", "physical activity", "active", "motion", "aktiv")), value = 3),
    ree_start = list(keywords = list(c("start", "begin", "began"), c("REE", "BEE", "BMR", "RMR", "RER")), value = 4)
  )

  data_txt <- system.file("extdata", "data.txt", package = "wrictools")
  data_v2_txt <- system.file("extdata", "data_v2.txt", package = "wrictools")
  data_no_comment_txt <- system.file("extdata", "data_no_comment.txt", package = "wrictools")
  note_txt <- system.file("extdata", "note.txt", package = "wrictools")
  note_v2_txt <- system.file("extdata", "note_v2.txt", package = "wrictools")
  note_new_txt <- system.file("extdata", "note_new.txt", package = "wrictools")
  tmp <- tempdir()

  # Test with only filepath and default parameters
  expect_error({
    result <- preprocess_wric_file(data_txt, path_to_save = tmp)
  }, NA)

  print("old version")
  str(result$df_room1)

  # Test with specific filepath and code parameter
  expect_error({
    result <- preprocess_wric_file(data_no_comment_txt, path_to_save = tmp)
  }, NA)

  expect_error({
    result <- preprocess_wric_file(
      data_txt,
      code = "id+comment",
      notefilepath = note_txt,
      keywords_dict = example_dict,
      path_to_save = tmp
    )
  }, NA)

  # Test with filepath, code and notefilepath
  expect_error({
    result <- preprocess_wric_file(data_txt,
                                   code = "id+comment",
                                   notefilepath = note_txt,
                                   path_to_save = tmp)
  }, NA)

  # Test with filepath, code, notefilepath, and start & end time
  expect_error({
    result <- preprocess_wric_file(data_txt,
                                   code = "id+comment",
                                   notefilepath = note_txt,
                                   start = "2023-11-13 11:43:00",
                                   end = "2023-11-13 12:09:00",
                                   path_to_save = tmp)
  }, NA)

  # Test with filepath, method and code
  expect_error({
    result <- preprocess_wric_file(data_txt,
                                   code = "id",
                                   method = "mean",
                                   path_to_save = tmp)
  }, NA)

  # Test with filepath, start & end time
  expect_error({
    result <- preprocess_wric_file(data_txt,
                                   code = "id+comment",
                                   start = "2023-11-13 11:43:00",
                                   end = "2023-11-13 12:09:00",
                                   path_to_save = tmp)
  }, NA)

  # Test with filepath, code, and manual custom codes (assuming this applies for code == "manual")
  expect_error({
    result <- preprocess_wric_file(data_txt,
                                   code = "manual",
                                   manual = list("R1_code1", "R1_code2"),
                                   path_to_save = tmp)
  }, NA)

  # Test with filepath, save_csv and path_to_save
  expect_error({
    result <- preprocess_wric_file(data_txt,
                                   save_csv = TRUE,
                                   path_to_save = tmp)
  }, NA)

  # Test with filepath and combine = TRUE
  expect_error({
    result <- preprocess_wric_file(data_txt,
                                   combine = TRUE,
                                   path_to_save = tmp)
  }, NA)

  # Test with filepath and combine = FALSE
  expect_error({
    result <- preprocess_wric_file(data_txt,
                                   combine = FALSE,
                                   path_to_save = tmp)
  }, NA)

})

test_that("open_file detects version correctly", {
  # Path to test files in inst/extdata
  data_txt <- system.file("extdata", "data.txt", package = "wrictools")
  data_v2_txt <- system.file("extdata", "data_v2.txt", package = "wrictools")

  # Make sure the files exist (sanity check)
  expect_true(file.exists(data_txt))
  expect_true(file.exists(data_v2_txt))

  # Test version 1 file
  result_v1 <- open_file(data_txt)
  expect_true(result_v1$v1)
  expect_type(result_v1$lines, "character")
  expect_gt(length(result_v1$lines), 0)  # not empty

  # Test version 2 file
  result_v2 <- open_file(data_v2_txt)
  expect_false(result_v2$v1)
  expect_type(result_v2$lines, "character")
  expect_gt(length(result_v2$lines), 0)  # not empty
})

library(testthat)

test_that("check_code works with different code options", {
  # Example metadata for Room 1 and Room 2
  r1 <- data.frame(`Subject.ID` = "S001", `Comments` = "Morning")
  r2 <- data.frame(`Subject.ID` = "S001", `Study.ID` = "studyname", `Comments` = "Morning")

  # Test ID only
  expect_equal(check_code("id", NULL, r1, v1 = TRUE), "S001")

  # Test ID + comment
  expect_equal(check_code("id+comment", NULL, r1, v1 = TRUE), "S001_Morning")

  # Test study+ID
  expect_equal(check_code("study+id", NULL, r2, v1 = FALSE), "studyname_S001")

  # Test ID + comment
  expect_error(check_code("study+id", NULL, r2, v1 = TRUE))

  # Test manual code
  expect_equal(check_code("manual", "custom", r1, v1 = TRUE), "custom")

  # Test invalid input
  expect_error(check_code("invalid_option", NULL, r1, v1 = TRUE))
  expect_error(check_code("manual", NULL, r1, v1 = TRUE))  # manual must be provided
})

test_that("extract_metadata_new works", {
  # Path to test files in inst/extdata
  data_v2_txt <- system.file("extdata", "data_v2.txt", package = "wrictools")
  tmp <- tempdir()

  res <- open_file(data_v2_txt)
  result <- extract_metadata_new(res$lines, code = "id", manual = NULL, save_csv = FALSE)

  expect_type(result, "list")
  expect_true("code" %in% names(result))
  expect_true("metadata" %in% names(result))

  metadata <- result$metadata
  # Check correct alignment of values
  expect_equal(metadata$Subject.ID[1], "ZeroTest")
  expect_equal(metadata$Researcher.ID[1], "XX")
  expect_equal(metadata$Comments[1], "Zero Test 14.01.2026")
  expect_equal(metadata$Study.ID[1], "")
  expect_equal(metadata$Measurement.ID[1], "")
})

test_that("detect_start_end works for v1 and v2 note files", {
  note_v1_path <- system.file("extdata", "note.txt", package = "wrictools")
  note_v2_path <- system.file("extdata", "note_v2.txt", package = "wrictools")

  # Test v1
  times_v1 <- detect_start_end(note_v1_path, v1 = TRUE)
  expected_times <- list(
    "1" = list(
      as.POSIXct("2023-11-13 21:14:22"),
      as.POSIXct("2023-11-14 08:47:48")
    ),
    "2" = list(
      as.POSIXct("2023-11-13 21:14:22"),
      as.POSIXct("2023-11-14 08:51:36")
    )
  )
  expect_equal(times_v1, expected_times)

  # Test v2
  times_v2 <- detect_start_end(note_v2_path, v1 = FALSE)
  expected_times <- list(
    "1" = list(
      as.POSIXct("2026-01-14 11:59:43"),
      as.POSIXct("2026-01-14 12:20:15")
    ),
    "2" = list(
      as.POSIXct("2026-01-14 11:59:43"),
      as.POSIXct("2026-01-14 12:20:15")
    )
  )
  expect_equal(times_v2, expected_times)
})

test_that("create_wric_df_new parses new WRIC format correctly", {
  data_v2_path  <- system.file("extdata", "data_v2.txt", package = "wrictools")
  note_v2_path  <- system.file("extdata", "note_v2.txt", package = "wrictools")

  res <- open_file(data_v2_path)
  lines <- res$lines

  # ---- Case 1: With note file ----
  df <- create_wric_df_new(
    filepath = data_v2_path,
    lines = lines,
    code = "study+id",
    path_to_save = NULL,
    start = NULL,
    end = NULL,
    notefilepath = note_v2_path
  )
  expect_s3_class(df, "data.frame")
  expect_true("datetime" %in% names(df))
  expect_true("relative_time" %in% names(df))

  expect_true(any(grepl("^S1_VO2", names(df))))
  expect_true(any(grepl("^S2_VO2", names(df))))
  expect_s3_class(df$datetime, "POSIXct")

  expect_equal(
    as.numeric(min(df$datetime)),
    as.numeric(as.POSIXct("2026-01-14 11:59:43"))
  )

  expect_equal(
    as.numeric(max(df$datetime)),
    as.numeric(as.POSIXct("2026-01-14 12:20:15"))
  )

  # ---- Case 2: Without note file ----
  df2 <- create_wric_df_new(filepath = data_v2_path, lines = lines, code = "study+id")
  expect_equal(
    as.numeric(min(df2$datetime)),
    as.numeric(as.POSIXct("2026-01-14 11:58:00"))
  )
  expect_equal(
    as.numeric(max(df2$datetime)),
    as.numeric(as.POSIXct("2026-01-14 12:21:00"))
  )

  # ---- Case 3: Specified start and end ----
  start_time <- as.POSIXct("2026-01-14 11:59:00")
  end_time   <- as.POSIXct("2026-01-14 12:10:00")

  df3 <- create_wric_df_new(filepath = data_v2_path, lines = lines,
    code = "study+id", start = start_time, end = end_time)

  expect_s3_class(df3, "data.frame")
  expect_equal(as.numeric(min(df3$datetime)), as.numeric(start_time))
  expect_equal(as.numeric(max(df3$datetime)), as.numeric(end_time))
})

test_that("Make sure combine_measurements works for both old and new version", {
  # ---- Load example files ----
  data_v2_path <- system.file("extdata", "data_v2.txt", package = "wrictools")
  note_v2_path <- system.file("extdata", "note_v2.txt", package = "wrictools")

  res <- open_file(data_v2_path)
  lines <- res$lines
  df <- create_wric_df_new(filepath = data_v2_path, lines = lines,
    code = "study+id", notefilepath = note_v2_path)
  df_combined <- combine_measurements(df, method = "mean")

  expect_s3_class(df_combined, "data.frame")
  expect_true("VO2" %in% names(df_combined))
})
