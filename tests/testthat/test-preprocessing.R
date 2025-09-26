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
data_no_comment_txt <- system.file("extdata", "data_no_comment.txt", package = "wrictools")
note_txt <- system.file("extdata", "note.txt", package = "wrictools")
note_new_txt <- system.file("extdata", "note_new.txt", package = "wrictools")
tmp <- tempdir()

test_that("preprocess_wric_file does not throw errors with various inputs", {

  # Test with only filepath and default parameters
  expect_error({
    result <- preprocess_wric_file(data_txt)
  }, NA)

  # Test with specific filepath and code parameter
  expect_error({
    result <- preprocess_wric_file(data_no_comment_txt)
  }, NA)

  expect_error({
    result <- preprocess_wric_file(
      data_txt,
      code = "id+comment",
      notefilepath = note_txt,
      keywords_dict = example_dict
    )
  }, NA)

  # Test with filepath, code and notefilepath
  expect_error({
    result <- preprocess_wric_file(data_txt,
                                   code = "id+comment",
                                   notefilepath = note_txt)
  }, NA)

  # Test with filepath, code, notefilepath, and start & end time
  expect_error({
    result <- preprocess_wric_file(data_txt,
                                   code = "id+comment",
                                   notefilepath = note_txt,
                                   start = "2023-11-13 11:43:00",
                                   end = "2023-11-13 12:09:00")
  }, NA)

  # Test with filepath, method and code
  expect_error({
    result <- preprocess_wric_file(data_txt,
                                   code = "id",
                                   method = "mean")
  }, NA)

  # Test with filepath, start & end time
  expect_error({
    result <- preprocess_wric_file(data_txt,
                                   code = "id+comment",
                                   start = "2023-11-13 11:43:00",
                                   end = "2023-11-13 12:09:00")
  }, NA)

  # Test with filepath, code, and manual custom codes (assuming this applies for code == "manual")
  expect_error({
    result <- preprocess_wric_file(data_txt,
                                   code = "manual",
                                   manual = list("R1_code1", "R1_code2"))
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
                                   combine = TRUE)
  }, NA)

  # Test with filepath and combine = FALSE
  expect_error({
    result <- preprocess_wric_file(data_txt,
                                   combine = FALSE)
  }, NA)

})
