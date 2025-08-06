#' Format a JSON file or string
#'
#' Format a JSON file or string, preserving comments.
#'
#' @name format
#'
#' @inheritParams rlang::args_dots_empty
#'
#' @param text A single string containing JSON.
#'
#' @param formatting_options The result of [formatting_options()]. If
#'   `NULL`, a default set of options are used.
#'
#' @examples
#' text <- '{"foo":[1,2]}'
#' cat(text_format(text))
#'
#' formatting_options <- formatting_options(tab_size = 2)
#' cat(text_format(text, formatting_options = formatting_options))
NULL

#' @rdname format
#' @export
text_format <- function(text, ..., formatting_options = NULL) {
  check_dots_empty0(...)

  check_string(text)
  formatting_options <- formatting_options %||% formatting_options()

  jsonc$call('ffi_text_format', text, formatting_options)
}

#' @rdname format
#'
#' @param file Path to file on disk. File must exist.
#'
#' @export
file_format <- function(file, ..., formatting_options = NULL) {
  check_dots_empty0(...)
  text <- read_file(file)
  out <- text_format(text, formatting_options = formatting_options)
  writeLines(out, file)
}

#' @rdname format
#'
#' @param tab_size The number of spaces to use to indicate a single tab when
#'   `insert_spaces` is `TRUE`.
#'
#' @param insert_spaces Whether to use spaces or tabs for indentation.
#'
#' @param eol The character used for the end of a line.
#'
#' @param insert_final_newline Whether or not to insert a final newline.
#'
#' @export
formatting_options <- function(
  tab_size = 4L,
  insert_spaces = TRUE,
  eol = "\n",
  insert_final_newline = TRUE
) {
  check_number_whole(tab_size)
  check_bool(insert_spaces)
  check_string(eol)
  check_bool(insert_final_newline)

  list(
    tabSize = tab_size,
    insertSpaces = insert_spaces,
    eol = eol,
    insertFinalNewline = insert_final_newline
  )
}
