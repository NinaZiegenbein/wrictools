#' Pipe operator
#'
#' See \code{magrittr::\link[magrittr:pipe]{\%>\%}} for details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
#' @param lhs A value or the magrittr placeholder.
#' @param rhs A function call using the magrittr semantics.
#' @return The result of calling `rhs(lhs)`.
NULL

# Import from dplyr
#' @importFrom dplyr select mutate filter contains all_of where
NULL

# Import from readr
#' @importFrom readr read_csv read_tsv
NULL

# Import from stats
#' @importFrom stats median na.omit setNames
NULL

# Import from utils
#' @importFrom utils download.file head tail write.csv
NULL

# Import from RCurl
#' @importFrom RCurl postForm
NULL

# Import from rlang
#' @importFrom rlang .data
NULL
