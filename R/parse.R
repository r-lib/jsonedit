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
parse_errors <- function(text, ..., parse_options = NULL) {
  check_dots_empty0(...)
  check_string(text, .internal = TRUE)
  parse_options <- parse_options %||% parse_options()

  out <- jsonc$call("ffi_parse_errors", text, parse_options)

  if (identical(out, list())) {
    # No errors
    out <- NULL
  }

  out
}

check_no_parse_errors <- function(
  action,
  text,
  ...,
  parse_options = NULL,
  call = caller_env()
) {
  check_dots_empty0(...)

  errors <- parse_errors(text, parse_options = parse_options)

  if (is.null(errors)) {
    return(invisible(NULL))
  }

  abort(paste0("Can't ", action, " when there are parse errors."), call = call)
}

parse_options <- function(
  allow_comments = TRUE,
  allow_trailing_comma = TRUE,
  allow_empty_content = TRUE
) {
  check_bool(allow_comments)
  check_bool(allow_trailing_comma)
  check_bool(allow_empty_content)

  list(
    allowComments = allow_comments,
    allowTrailingComma = allow_trailing_comma,
    allowEmptyContent = allow_empty_content
  )
}
