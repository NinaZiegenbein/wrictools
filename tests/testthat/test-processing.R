
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

  # Test ID only
  expect_equal(check_code("id", NULL, r1), "S001")

  # Test ID + comment
  expect_equal(check_code("id+comment", NULL, r1), "S001_Morning")

  # Test manual code
  expect_equal(check_code("manual", "custom", r1), "custom")

  # Test invalid input
  expect_error(check_code("invalid_option", NULL, r1))
  expect_error(check_code("manual", NULL, r1))  # manual must be provided
})

test_that("extract_metadata_new works", {
  # Path to test files in inst/extdata
  data_v2_txt <- system.file("extdata", "data_v2.txt", package = "wrictools")
  res <- open_file(data_v2_txt)
  result <- extract_metadata_new(res$lines, code = "id", manual = NULL, save_csv = FALSE)

  expect_type(result, "list")
  expect_true("code" %in% names(result))
  expect_true("metadata" %in% names(result))

  #TODO: Check that output correct, also when empty tabs
})
