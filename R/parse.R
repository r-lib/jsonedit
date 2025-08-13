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

  # In particular, JSON arrays can have mixed types like `[1, "a"]` and we
  # don't want those to be forcibly simplified to `c("1", "a")` on the way in.
  #
  # We don't need this for every function, but when we parse a JSON file
  # we want predictable output, and for us that means no simplification
  simplify <- FALSE

  jsonc$call("ffi_text_parse", text, parse_options, simplify = simplify)
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
  jsonc$call(
    "ffi_text_parse_at_path",
    text,
    path,
    parse_options,
    simplify = FALSE
  )
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
# Returns a structured list of errors where each error has 3 elements:
# - `error` code
# - `offset` into the `text` where the error starts
# - `length` that the error extends for
#
# Newer versions also include `startLine` and `startCharacter`
# https://github.com/microsoft/node-jsonc-parser/blob/fe330190baba3ba630934d27ea2083638feddadc/src/main.ts#L147
text_parse_errors <- function(text, ..., parse_options = NULL) {
  check_dots_empty0(...)
  check_string(text, .internal = TRUE)
  parse_options <- parse_options %||% parse_options()
  jsonc$call("ffi_text_parse_errors", text, parse_options, simplify = FALSE)
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

  if (is_empty(errors)) {
    return(invisible(NULL))
  }

  # Limit to just 2 errors at most, it can be overwhelming and not useful
  # to get repetitive errors about the same location
  if (length(errors) > 2) {
    errors <- errors[1:2]
  }

  header <- cli::format_inline("Can't {action} when there are parse errors.")

  bullets <- map_chr(errors, function(error) format_error_bullet(text, error))
  bullets <- set_names(bullets, "i")

  abort(c(header, bullets), call = call)
}

# The goal is to use the translated error code as the bullet, and show a slice
# of `text` relevant to the error location, which the actual error location
# highlighted in red
format_error_bullet <- function(text, error) {
  message <- error_code_to_error_message(error$error)
  offset <- error$offset
  length <- error$length

  n <- nchar(text)
  context <- 20L

  # It's useful to make this the start of the line so you always show leading
  # indentation
  front_start <- location_right_after_previous_newline(
    text,
    offset - context
  )
  front_start <- max(0L, front_start)
  front_end <- max(0L, offset - 1L)

  back_start <- min(n + 1L, offset + length + 1L)
  back_end <- min(n + 1L, offset + length + context)

  front <- substr(text, front_start, front_end)
  back <- substr(text, back_start, back_end)

  middle <- substr(text, offset, offset + length)
  middle <- cli::col_red(middle)

  text <- paste0(front, middle, back)

  paste0(message, "\n", text)
}

location_right_after_previous_newline <- function(text, loc) {
  newlines <- gregexpr("\n", text, fixed = TRUE)[[1L]]

  if (length(newlines) == 1L && newlines == -1L) {
    # No newlines, use start of text
    return(1L)
  }

  newlines <- newlines[which(newlines < loc)]

  if (length(newlines) == 0L) {
    # Newlines exist, but none before this line, use start of text
    return(1L)
  }

  # Find last newline before `loc` and add 1 to move to the location just past it
  newlines[[length(newlines)]] + 1L
}

# https://github.com/microsoft/node-jsonc-parser/blob/fe330190baba3ba630934d27ea2083638feddadc/src/main.ts#L151
error_code_to_error_message <- function(code) {
  lookup <- c(
    "Invalid symbol",
    "Invalid number format",
    "Property name expected",
    "Value expected",
    "Colon expected",
    "Comma expected",
    "Close brace expected",
    "Close bracket expected",
    "End of file expected",
    "Invalid comment token",
    "Unexpected end of comment",
    "Unexpected end of string",
    "Unexpected end of number",
    "Invalid unicode",
    "Invalid escape character",
    "Invalid character"
  )

  if (code > length(lookup) || code <= 0) {
    cli::cli_abort("Error `code` {code} is invalid.", .internal = TRUE)
  }

  lookup[[code]]
}
