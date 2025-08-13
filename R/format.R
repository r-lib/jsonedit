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
#' formatting_options <- formatting_options(indent_width = 2)
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
#' @param indent_width The number of spaces to use to indicate a single indent
#'   when `indent_style = "space"`.
#'
#' @param indent_style The style of indentation to use. Either:
#'
#'   - `"space"` for spaces.
#'
#'   - `"tab"` for tabs.
#'
#' @param eol The character used for the end of a line. This is only applicable
#'   when the text doesn't already contain an existing line ending, i.e. an
#'   empty string or a string spanning a single line.
#'
#' @param insert_final_newline Whether or not to insert a final newline.
#'
#' @export
formatting_options <- function(
  indent_width = 4L,
  indent_style = "space",
  eol = "\n",
  insert_final_newline = TRUE
) {
  check_number_whole(indent_width)
  check_string(eol)
  check_bool(insert_final_newline)

  indent_style <- arg_match0(indent_style, c("space", "tab"))
  insert_spaces <- indent_style == "space"

  list(
    tabSize = indent_width,
    insertSpaces = insert_spaces,
    eol = eol,
    insertFinalNewline = insert_final_newline
  )
}
