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
    pivot_longer(cols = all_of(c("VO2", "VCO2")), names_to = "variable", values_to = "value")

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
  stats <- bind_rows(
    df %>% summarise(
        variable = "VO2",
        mean = mean(.data[["VO2"]], na.rm = TRUE),
        sd   = sd(.data[["VO2"]], na.rm = TRUE),
        min  = min(.data[["VO2"]], na.rm = TRUE),
        max  = max(.data[["VO2"]], na.rm = TRUE),
        slope = coef(lm(.data[["VO2"]] ~ as.numeric(.data[["datetime"]])))[2]
      ),
    df %>% summarise(
        variable = "VCO2",
        mean = mean(.data[["VCO2"]], na.rm = TRUE),
        sd   = sd(.data[["VCO2"]], na.rm = TRUE),
        min  = min(.data[["VCO2"]], na.rm = TRUE),
        max  = max(.data[["VCO2"]], na.rm = TRUE),
        slope = coef(lm(.data[["VCO2"]] ~ as.numeric(.data[["datetime"]])))[2]
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

#' Analyse methanol burn experiment
#'
#' @inheritParams preprocess_wric_file
#' @param methanolfilepath File path to a csv or Excel file with columns:
#'   \describe{
#'     \item{datetime}{Timestamp of measurement, format \code{\%d-\%m-\%y \%H:\%M} by default. Can override with \code{datetime_format}.}
#'     \item{methanol}{Methanol mass (g) at each timestamp.}
#'   }
#' @param room1 Logical; if TRUE uses room1 data from WRIC file, else room2. This is only relevant for files generates by software version 1. Default is TRUE.
#' @param datetime_format Character; format string for parsing methanol datetime column. Default is "%d-%m-%y %H:%M" (25-03-25 13:58).
#' @return A list with:
#'   \describe{
#'     \item{per_interval}{Data frame with per-timestep methanol burn, predicted CO2/O2, measured VO2/VCO2, deviations, RER}
#'     \item{overall}{Summary for the whole session}
#'     \item{plots}{List of ggplot objects (values shown correspond to the end of each interval)}
#'   }
#' @export
#' @examplesIf file.exists(path.expand("~/methanol.xlsx"))
#' methanol <- source(path.expand("~/methanol.xlsx"))
#' data_txt <- system.file("extdata", "data.txt", package = "wrictools")
#' analyse_methanol_burn (data_txt, methanol, room1 = FALSE)
analyse_methanol_burn <- function(filepath, methanolfilepath, room1 = TRUE, datetime_format = "%d-%m-%y %H:%M", code = "id", manual = NULL, save_csv = FALSE, path_to_save = NULL,
                                  combine = TRUE, method = "mean", start = NULL, end = NULL, notefilepath = NULL, keywords_dict = NULL, entry_exit_dict = NULL) {
  # load wric data
  result <- preprocess_wric_file(filepath, code = code, method = method, start = start, end = end)
  df_wric <- if (result$version == "1") {
    if (room1) {
      result$dfs$room1
    }
    else {
      result$dfs$room2
    }
  } else {
    result$dfs$data
  }

  # load methanol csv
  ext <- file_ext(methanolfilepath)

  df_methanol <- switch(tolower(ext),
                        "xlsx" = read_excel(methanolfilepath),
                        "xls"  = read_excel(methanolfilepath),
                        "csv"  = read_csv(methanolfilepath, show_col_types = FALSE),
                        stop("Unsupported methanol file format. Use .csv, .xls, or .xlsx")
  )

  required_cols <- c("datetime", "methanol")
  missing_cols <- setdiff(required_cols, names(df_methanol))
  if (length(missing_cols) > 0) {
    stop(sprintf("Methanol file must contain columns: %s. Missing: %s", paste(required_cols, collapse = ", "),
                 paste(missing_cols, collapse = ", ")), call. = FALSE)
  }
  df_methanol$datetime <- as.POSIXct(df_methanol$datetime, format = datetime_format)
  if (any(is.na(df_methanol$datetime))) {
    stop(
      "Failed to parse 'datetime'. Check datetime_format.",
      call. = FALSE
    )
  }

  df_methanol <- df_methanol %>% arrange(.data$datetime)

  # compute values for each interval
  intervals <- tibble(
    t1 = df_methanol$datetime[-nrow(df_methanol)],
    t2 = df_methanol$datetime[-1],
    delta_methanol_g = df_methanol$methanol[-nrow(df_methanol)] - df_methanol$methanol[-1]
  )

  intervals <- intervals %>%
    mutate(
      delta_CO2_L = .data$delta_methanol_g * 22.41383 / 32.04,
      delta_O2_L  = .data$delta_CO2_L * 1.5,
      delta_time_min = as.numeric(difftime(.data$t2, .data$t1, units = "mins")),
      CO2_ml_min = .data$delta_CO2_L / .data$delta_time_min * 1000,
      O2_ml_min  = .data$delta_O2_L / .data$delta_time_min * 1000,
      methanol_g_min = .data$delta_methanol_g / .data$delta_time_min
    )

  # compute measured VO2/VCO2 per interval
  intervals <- intervals %>%
    rowwise() %>%
    mutate(
      VO2_measured = mean(df_wric$VO2[df_wric$datetime >= .data$t1 & df_wric$datetime <= .data$t2], na.rm = TRUE),
      VCO2_measured = mean(df_wric$VCO2[df_wric$datetime >= .data$t1 & df_wric$datetime <= .data$t2], na.rm = TRUE),
      VO2_dev = .data$VO2_measured / .data$O2_ml_min - 1,
      VCO2_dev = .data$VCO2_measured / .data$CO2_ml_min - 1,
      RER = .data$VCO2_measured / .data$VO2_measured
    ) %>%
    ungroup()

  # overall session summary
  overall <- intervals %>%
    summarise(
      VO2_avg_meas = mean(.data$VO2_measured, na.rm = TRUE),
      VCO2_avg_meas = mean(.data$VCO2_measured, na.rm = TRUE),
      O2_avg_calc = mean(.data$O2_ml_min, na.rm = TRUE),
      CO2_avg_calc = mean(.data$CO2_ml_min, na.rm = TRUE),
      VO2_dev_avg = mean(.data$VO2_dev, na.rm = TRUE),
      VCO2_dev_avg = mean(.data$VCO2_dev, na.rm = TRUE),
      RER_avg = mean(.data$RER, na.rm = TRUE)
    )

  # plots
  p1 <- ggplot(intervals) +
    geom_line(aes(x = .data$t2, y = .data$VO2_measured, color = "VO2 measured")) +
    geom_line(aes(x = .data$t2, y = .data$O2_ml_min, color = "O2 predicted")) +
    labs(title = "O2: Measured vs Predicted", x = "Time", y = "ml/min") +
    theme_minimal() +
    scale_color_manual(values = c("blue", "red"))

  p2 <- ggplot(intervals) +
    geom_line(aes(x = .data$t2, y = .data$VCO2_measured, color = "VCO2 measured")) +
    geom_line(aes(x = .data$t2, y = .data$CO2_ml_min, color = "CO2 predicted")) +
    labs(title = "CO2: Measured vs Predicted", x = "Time", y = "ml/min") +
    theme_minimal() +
    scale_color_manual(values = c("blue", "red"))

  p3 <- ggplot(intervals) +
    geom_line(aes(x = .data$t2, y = .data$RER)) +
    labs(title = "RER over time", x = "Time", y = "VCO2 / VO2") +
    theme_minimal()

  p4 <- ggplot(intervals, aes(x = .data$t2, y = .data$methanol_g_min)) +
    geom_line(linewidth = 1) +
    geom_point(size = 2) +
    labs(
      title = "Methanol burn rate over time",
      x = "Time",
      y = "Methanol burn rate (g/min)"
    ) +
    theme_minimal()

  list(
    per_interval = intervals,
    overall = overall,
    plots = list(O2 = p1, CO2 = p2, RER = p3, burn_rate = p4)
  )
}
