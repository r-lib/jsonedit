#' Modify a JSON file or string
#'
#' Set or delete fields in a JSON file or string while retaining comments
#' and whitespace.
#'
#' @export
#' @rdname jsonedit
#' @param text string with json
#' @param json_path character vector or list specifies which element to modify.
#' @param value new value. Wrap in [V8::JS()] to specify literal JavaScript value.
#' Use `NULL` to delete the field.
#' @param is_array_insertion whether to treat the modification as an insertion
#' into an array or not. Has no effect when `json_path` doesn't target an array.
#' @examples
#' # update field on existing settings.json
#' json_modify_file('settings.json', c('[r]', 'editor.formatOnSave'), TRUE)
#'
#' # some example operationgs
#' unlink('test.json')
#' json_modify_file('test.json', 'title', "This is a test")
#' json_modify_file('test.json', c("foo", "bar"), 1:3)
#' json_modify_file('test.json', c("foo", "baz"), TRUE)
#' json_modify_file('test.json', list("foo", "bar", 1), 9999)
#' json_modify_file('test.json', list("foo", "bar", 1), 9998, is_array_insertion = TRUE)
json_modify_text <- function(
  text,
  json_path,
  value,
  spaces = 4,
  is_array_insertion = FALSE
) {
  stopifnot(is.character(text))
  text <- paste(text, collapse = '\n')
  if (is.null(value)) {
    value <- V8::JS('undefined')
  }
  opts <- list(isArrayInsertion = is_array_insertion)
  if (length(spaces)) {
    opts[["formattingOptions"]] <- list(
      insertSpaces = spaces > 0,
      tabSize = spaces
    )
  }
  if (!is.null(json_parse_errors(text))) {
    stop("Can't modify when there are existing parse errors.")
  }
  jsonc$call('json_modify', text, as.list(json_path), value, opts)
}

#' @export
#' @rdname jsonedit
#' @param file path to file on disk. File must exist.
json_modify_file <- function(
  file,
  json_path,
  value,
  spaces = 4,
  is_array_insertion = FALSE
) {
  text <- read_file(file)
  out <- json_modify_text(text, json_path, value, spaces, is_array_insertion)
  writeLines(out, file)
}

#' @export
#' @rdname jsonedit
#' @param spaces number of spaces to indent. Use 0 for tabs.
json_format_text <- function(text, spaces = 4) {
  stopifnot(is.character(text))
  text <- paste(text, collapse = '\n')
  opts <- list(insertSpaces = spaces > 0, tabSize = spaces)
  if (!is.null(json_parse_errors(text))) {
    stop("Can't format when there are existing parse errors.")
  }
  jsonc$call('json_format', text, opts)
}

#' @export
#' @rdname jsonedit
json_format_file <- function(file, spaces = 4) {
  text <- read_file(file)
  out <- json_format_text(text, spaces)
  writeLines(out, file)
}

json_file_get_path <- function(file, path) {
  text <- read_file(file)
  json_text_get_path(text, path)
}

json_text_get_path <- function(text, path) {
  if (is.character(path)) {
    # `c("x", "y")` -> `list("x", "y")`
    path <- as.list(path)
  }
  stopifnot(is.list(path))
  paths <- list(path)
  json_text_get_paths(text, paths)[[1L]]
}

json_file_get_paths <- function(file, paths) {
  text <- read_file(file)
  json_text_get_paths(text, paths)
}

json_text_get_paths <- function(text, paths) {
  stopifnot(is.list(paths))
  lapply(paths, function(path) {
    # list(c("x", "y")) -> list(list("x", "y"))
    if (is.character(path)) {
      path <- as.list(path)
    }
    stopifnot(is.list(path))
  })

  if (!is.null(json_parse_errors(text))) {
    stop("Can't modify when there are existing parse errors.")
  }

  # This does parse the `text` for each path, but jsonlite
  # simplification gets in the way a bit otherwise (#3),
  # we can revisit if we care about performance later on
  lapply(paths, function(path) {
    jsonc$call("json_get_path", text, path)
  })
}

json_parse_errors <- function(text) {
  stopifnot(is.character(text), length(text) == 1L)
  out <- jsonc$call("json_parse_errors", text)
  if (identical(out, list())) {
    # No errors
    out <- NULL
  }
  out
}

read_file <- function(file) {
  if (!file.exists(file)) {
    stop("`file` doesn't exist.")
  }
  rawToChar(readBin(file, raw(), file.info(file)$size))
}

#' @importFrom V8 v8 JS
.onLoad <- function(lib, pkg) {
  assign("jsonc", V8::v8(), environment(.onLoad))
  jsonc$source(system.file("js/jsonc.js", package = pkg))
  jsonc$source(system.file("js/bindings.js", package = pkg))
}
