#' Modify a JSON file or string
#'
#' Set or delete fields in a JSON file or string while retaining comments
#' and whitespace.
#'
#' @name modify
#'
#' @inheritParams rlang::args_dots_empty
#'
#' @param text A single string containing JSON to modify.
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
#'   applicable for arrays. `-1` is specially recognized as a request to
#'   _insert_ at the end of an array.
#'
#' @param value New value. Wrap in [V8::JS()] to specify literal JavaScript
#'   value. Use `NULL` to delete the field.
#'
#' @param parse_options The result of [parse_options()]. If `NULL`, a default
#'   set of options are used.
#'
#' @param modification_options The result of [modification_options()]. If
#'   `NULL`, a default set of options are used.
#'
#' @examples
#' text <- "{}"
#'
#' text <- text_modify(text, c('[r]', 'editor.formatOnSave'), TRUE)
#' cat(text)
#'
#' text <- text_modify(text, c('[r]', 'editor.formatOnSave'), NULL)
#' cat(text)
#'
#' # Insert an array
#' text <- text_modify(text, "foo", 1:3)
#' cat(text)
#'
#' # Update the array at location 2
#' cat(text_modify(text, list("foo", 2), 0))
#'
#' # Insert at location 2
#' cat(text_modify(
#'   text,
#'   list("foo", 2),
#'   0,
#'   modification_options = modification_options(is_array_insertion = TRUE)
#' ))
#'
#' # Insert at the end of the array. `-1` is treated as an insertion regardless
#' # of the value of `is_array_insertion`.
#' cat(text_modify(text, list("foo", -1), 0))
#'
#' # Only the modified elements are reformatted
#' text <- '{"foo":[1,2],\n"bar":1}'
#' cat(text_modify(text, list("foo", 3), 0))
#'
#' # You can control how those elements are formatted
#' cat(text_modify(
#'   text,
#'   list("foo", 3),
#'   0,
#'   modification_options = modification_options(
#'     formatting_options = formatting_options(indent_width = 2),
#'     is_array_insertion = TRUE
#'   )
#' ))
NULL

#' @rdname modify
#' @export
text_modify <- function(
  text,
  path,
  value,
  ...,
  parse_options = NULL,
  modification_options = NULL
) {
  check_dots_empty0(...)

  check_string(text)
  path <- check_and_normalize_path(path)

  parse_options <- parse_options %||% parse_options()
  modification_options <- modification_options %||% modification_options()

  # Enforcement of parse options like trailing commas and comments is checked
  # here. `ffi_text_modify` calls `$modify()`, which parses the file again
  # but does not expose a way to pass in `parse_options`, instead it fixes the
  # options to:
  # - `disallowComments: false`
  #   - Fine, this is the lax option
  # - `allowTrailingComma: true`
  #   - Fine, this is the lax option
  # - `allowEmptyContent: false`
  #   - In theory not fine, as this logs an error when the file is empty.
  #     But the parser is "resilient" and recovers easily from this, so
  #     it ends up not being an issue
  check_no_text_parse_errors("modify", text, parse_options = parse_options)

  if (is.null(value)) {
    value <- V8::JS('undefined')
  }

  jsonc$call('ffi_text_modify', text, path, value, modification_options)
}

#' @rdname modify
#'
#' @param file Path to file on disk. File must exist.
#'
#' @export
file_modify <- function(
  file,
  path,
  value,
  ...,
  parse_options = NULL,
  modification_options = NULL
) {
  check_dots_empty0(...)

  text <- read_file(file)

  out <- text_modify(
    text = text,
    path = path,
    value = value,
    parse_options = parse_options,
    modification_options = modification_options
  )

  writeLines(out, file)
}

#' @rdname modify
#'
#' @param formatting_options The result of a call to [formatting_options()]. If
#'   `NULL`, a default set of options are used.
#'
#' @param is_array_insertion Whether or not to treat the change as an
#'   _insertion_ at the specified `path` rather than a _modification_ at that
#'   `path`. Only applicable for arrays.
#'
#' @export
modification_options <- function(
  formatting_options = NULL,
  is_array_insertion = FALSE
) {
  formatting_options <- formatting_options %||% formatting_options()
  check_bool(is_array_insertion)

  list(
    formattingOptions = formatting_options,
    isArrayInsertion = is_array_insertion
  )
}
