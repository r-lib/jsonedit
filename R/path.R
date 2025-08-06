file_path <- function(file, path, ..., parse_options = NULL) {
  check_dots_empty0(...)
  text <- read_file(file)
  text_path(text, path, parse_options = parse_options)
}

text_path <- function(text, path, ..., parse_options = NULL) {
  check_dots_empty0(...)
  check_string(text)
  paths <- list(path)
  text_paths(text, paths, parse_options = parse_options)[[1L]]
}

file_paths <- function(file, paths, ..., parse_options = NULL) {
  check_dots_empty0(...)
  text <- read_file(file)
  text_paths(text, paths, parse_options = parse_options)
}

text_paths <- function(text, paths, ..., parse_options = NULL) {
  check_dots_empty0(...)
  check_string(text)
  paths <- check_and_normalize_list_of_paths(paths)
  parse_options <- parse_options %||% parse_options()

  check_no_parse_errors("retrieve paths", text, parse_options = parse_options)

  # This does parse the `text` for each path, but jsonlite
  # simplification gets in the way a bit otherwise (#3),
  # we can revisit if we care about performance later on
  lapply(paths, function(path) {
    jsonc$call("ffi_text_paths", text, path, parse_options)
  })
}
