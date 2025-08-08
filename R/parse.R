#' Parse a JSON file or string
#'
#' @description
#'
#' - `text_parse()` and `file_parse()` parse JSON into an R object.
#'
#' - `text_parse_at_path()` and `file_parse_at_path()` parse JSON at a requested
#'   JSON path, i.e. `c("[r]", "editor.formatOnSave")`.
#'
#' @name parse
#'
#' @inheritParams rlang::args_dots_empty
#'
#' @param text A single string containing JSON.
#'
#' @param file Path to file on disk. File must exist.
#'
#' @param path Either:
#'
#'   - A character vector representing a path to a JSON element by name, i.e.
#'    `c("[r]", "editor.formatOnSave")`.
#'
#'   - A list of strings or numbers representing a path to a JSON element by
#'     name and position, i.e. `list("[r]", "editor.rulers", 2)`.
#'
#'   Numeric positions are specified as positive integers and are only
#'   applicable for arrays.
#'
#' @param parse_options The result of [parse_options()]. If `NULL`, a default
#'   set of options are used.
#'
#' @param allow_comments Whether or not to allow comments when parsing.
#'
#' @param allow_trailing_comma Whether or not to allow a trailing comma when
#'   parsing.
#'
#' @param allow_empty_content Whether or not to allow empty strings or empty
#'   files when parsing.
#'
#' @examples
#' text <- '
#' {
#'   "a": 1,
#'   "b": [2, 3, 4],
#'   "[r]": {
#'     "this": "setting",
#'     // A comment!
#'     "that": true
#'   }, // A trailing comma!
#' }
#' '
#'
#' # Parse the JSON, allowing comments (i.e. JSONC)
#' str(text_parse(text))
#'
#' # Try to parse the JSON, but comments aren't allowed!
#' parse_options <- parse_options(allow_comments = FALSE)
#' try(text_parse(text, parse_options = parse_options))
#'
#' # Try to parse the JSON, but trailing commas aren't allowed!
#' parse_options <- parse_options(allow_trailing_comma = FALSE)
#' try(text_parse(text, parse_options = parse_options))
#'
#' # Parse only a subset of the JSON
#' text_parse_at_path(text, "b")
#' text_parse_at_path(text, "[r]")
#' text_parse_at_path(text, c("[r]", "that"))
#'
#' # Use a `list()` combining strings and positional indices when
#' # arrays are involved
#' text_parse_at_path(text, list("b", 2))
NULL

#' @rdname parse
#' @export
text_parse <- function(text, ..., parse_options = NULL) {
  check_dots_empty0(...)
  check_string(text)
  parse_options <- parse_options %||% parse_options()
  check_no_text_parse_errors("parse", text, parse_options = parse_options)
  out <- jsonc$call("ffi_text_parse", text, parse_options)
  out
}

#' @rdname parse
#' @export
file_parse <- function(file, ..., parse_options = NULL) {
  check_dots_empty0(...)
  text <- read_file(file)
  text_parse(text, parse_options = parse_options)
}

#' @rdname parse
#' @export
text_parse_at_path <- function(text, path, ..., parse_options = NULL) {
  check_dots_empty0(...)
  check_string(text)
  path <- check_and_normalize_path(path)
  parse_options <- parse_options %||% parse_options()
  check_no_text_parse_errors("parse", text, parse_options = parse_options)
  out <- jsonc$call("ffi_text_parse_at_path", text, path, parse_options)
  out
}

#' @rdname parse
#' @export
file_parse_at_path <- function(file, path, ..., parse_options = NULL) {
  check_dots_empty0(...)
  text <- read_file(file)
  text_parse_at_path(text, path, parse_options = parse_options)
}

#' @rdname parse
#' @export
parse_options <- function(
  allow_comments = TRUE,
  allow_trailing_comma = TRUE,
  allow_empty_content = TRUE
) {
  check_bool(allow_comments)
  check_bool(allow_trailing_comma)
  check_bool(allow_empty_content)

  list(
    disallowComments = !allow_comments,
    allowTrailingComma = allow_trailing_comma,
    allowEmptyContent = allow_empty_content
  )
}

# Internal helper to determine if there are parse errors in a document
#
# Returns a structured data frame of 3 columns:
# - `error` code
# - `offset` into the `text` where the error starts
# - `length` that the error extends for
#
# Newer versions also include `startLine` and `startCharacter`
# https://github.com/microsoft/node-jsonc-parser/blob/fe330190baba3ba630934d27ea2083638feddadc/src/main.ts#L147
#
# We should use this information to throw a good error message when there are
# errors
text_parse_errors <- function(text, ..., parse_options = NULL) {
  check_dots_empty0(...)
  check_string(text, .internal = TRUE)
  parse_options <- parse_options %||% parse_options()

  out <- jsonc$call("ffi_text_parse_errors", text, parse_options)

  if (identical(out, list())) {
    # No errors
    out <- NULL
  }

  out
}

check_no_text_parse_errors <- function(
  action,
  text,
  ...,
  parse_options = NULL,
  call = caller_env()
) {
  check_dots_empty0(...)

  errors <- text_parse_errors(text, parse_options = parse_options)

  if (is.null(errors)) {
    return(invisible(NULL))
  }

  abort(paste0("Can't ", action, " when there are parse errors."), call = call)
}
