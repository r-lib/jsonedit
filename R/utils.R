check_and_normalize_list_of_paths <- function(
  x,
  ...,
  arg = caller_arg(x),
  call = caller_env()
) {
  check_list(x)

  for (i in seq_along(x)) {
    x[[i]] <- check_and_normalize_path(
      x[[i]],
      arg = paste0(arg, "[[", i, "]]"),
      call = call
    )
  }

  x
}

check_and_normalize_path <- function(
  x,
  ...,
  arg = caller_arg(x),
  call = caller_env()
) {
  if (is.character(x)) {
    # `c("x", "y")` -> `list("x", "y")`
    return(as.list(x))
  }

  if (is.list(x)) {
    for (i in seq_along(x)) {
      x[[i]] <- check_and_normalize_path_element(
        x[[i]],
        i = i,
        parent_arg = arg,
        call = call
      )
    }
    return(x)
  }

  stop_input_type(
    x,
    "a character vector or a list",
    arg = arg,
    call = call
  )
}

check_and_normalize_path_element <- function(
  x,
  ...,
  i,
  parent_arg,
  call = caller_env()
) {
  if (is_string(x)) {
    return(x)
  }
  if (is_number(x)) {
    if (x >= 0) {
      # Positions are 0-based on the JavaScript side,
      # but negative positions select from the back,
      # i.e. `-1` is "at the end"
      x <- x - 1L
    }
    return(x)
  }

  header <- paste0(
    "Each element of `",
    parent_arg,
    "` must be a string or a number."
  )
  bullet <- c(
    i = paste0("Element ", i, " is not.")
  )

  abort(c(header, bullet), call = call)
}

is_number <- function(x) {
  (is.integer(x) || is.numeric(x)) &&
    length(x) == 1L &&
    !is.na(x) &&
    !is.infinite(x)
}

check_list <- function(
  x,
  ...,
  allow_null = FALSE,
  arg = caller_arg(x),
  call = caller_env()
) {
  if (is.list(x) || (allow_null && is.null(x))) {
    return(invisible(NULL))
  }

  stop_input_type(
    x,
    "a list",
    ...,
    arg = arg,
    call = call
  )
}

read_file <- function(file, ..., arg = caller_arg(file), call = caller_env()) {
  check_string(file, arg = arg, call = call)

  if (!file.exists(file)) {
    cli::cli_abort("{.file {file}} doesn't exist.", call = call)
  }

  rawToChar(readBin(file, raw(), file.info(file)$size))
}
