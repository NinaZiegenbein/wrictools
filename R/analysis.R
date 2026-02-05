#' Plot VO2 and VCO2 and calculate basic statistics
#'
#' @param df Data frame with at least `datetime`, `VO2`, and `VCO2` columns.
#' @param start POSIXct or character; optional start time to subset the data.
#' @param end POSIXct or character; optional end time to subset the data.
#' @param title Character; plot title.
#'
#' @return A data frame with variables `variable` (VO2/VCO2), `mean`, `sd`, `min`, `max`, and `slope` (change over time).
#' @keywords internal
#' @noRd
plot_and_stats <- function(df,
                            start = NULL,
                            end = NULL,
                            title) {

  if (!is.null(start)) df <- df[df$datetime >= start, ]
  if (!is.null(end))   df <- df[df$datetime <= end, ]

  df_long <- df %>%
    tidyr::pivot_longer(cols = all_of(c("VO2", "VCO2")), names_to = "variable", values_to = "value")

  p <- ggplot(df_long, aes(.data[["datetime"]], .data[["value"]], colour = .data[["variable"]])) +
    geom_line() +
    labs(
      title = title,
      x = "Time",
      y = "Value",
      colour = NULL
    ) +
    theme_minimal()

  print(p)

  # Basic stats
  stats <- dplyr::bind_rows(
    df |>
      dplyr::summarise(
        variable = "VO2",
        mean = mean(.data[["VO2"]], na.rm = TRUE),
        sd   = stats::sd(.data[["VO2"]], na.rm = TRUE),
        min  = min(.data[["VO2"]], na.rm = TRUE),
        max  = max(.data[["VO2"]], na.rm = TRUE),
        slope = stats::coef(stats::lm(.data[["VO2"]] ~ as.numeric(.data[["datetime"]])))[2]
      ),
    df |>
      dplyr::summarise(
        variable = "VCO2",
        mean = mean(.data[["VCO2"]], na.rm = TRUE),
        sd   = stats::sd(.data[["VCO2"]], na.rm = TRUE),
        min  = min(.data[["VCO2"]], na.rm = TRUE),
        max  = max(.data[["VCO2"]], na.rm = TRUE),
        slope = stats::coef(stats::lm(.data[["VCO2"]] ~ as.numeric(.data[["datetime"]])))[2]
      )
  )


  # p <- ggplot(df, aes(x = .data[["relative_time"]], y = .data[[plot]]))

  return(stats)
}

#' Analyse a Zero Test WRIC file
#'
#' This function preprocesses a WRIC data file, plots VO2 and VCO2 over time,
#' and returns basic statistics (mean, SD, min, max, slope). For version 1 files,
#' separate plots and statistics are returned for Room 1 and Room 2. For version 2 files,
#' a single dataset is processed.
#'
#' @inheritParams preprocess_wric_file
#'
#' @return A named list of data frames with statistics for each room (v1) or for all data (v2).
#' @export
#' @examples
#' filepath <- system.file("extdata", "data.txt", package = "wrictools")
#' analyse_zero_test(filepath)

analyse_zero_test <- function(filepath, code = "id", manual = NULL, save_csv = FALSE, path_to_save = NULL,
                              combine = TRUE, method = "mean", start = NULL, end = NULL, notefilepath = NULL, keywords_dict = NULL, entry_exit_dict = NULL) {

  result <- preprocess_wric_file(filepath, code, manual, save_csv, path_to_save, combine, method, start, end, notefilepath, keywords_dict, entry_exit_dict)
  dfs_list <- result$dfs
  version <- result$version

  stats <- list()

  for (name in names(dfs_list)) {
    title <- "Zero test"
    if (version == "1") {
      title <- paste(title, "- Room", gsub("room", "", name))
    }
    stats[[name]] <- plot_and_stats(df = dfs_list[[name]], start = start, end = end, title = title)
  }
  stats
}
