test_that("`eol` only applies when we don't know the eol in `text`", {
  formatting_options <- formatting_options(eol = "\r\n")

  text <- '{"a":1}\n'
  expect_identical(
    text_format(text, formatting_options = formatting_options),
    '{\n    "a": 1\n}\n'
  )

  text <- '{"a":1}'
  expect_identical(
    text_format(text, formatting_options = formatting_options),
    '{\r\n    "a": 1\r\n}\r\n'
  )
})

test_that("`tab_size` works", {
  formatting_options <- formatting_options(tab_size = 2)

  text <- '{"a":1}\n'
  expect_identical(
    text_format(text, formatting_options = formatting_options),
    '{\n  "a": 1\n}\n'
  )
})

test_that("`insert_spaces` works", {
  formatting_options <- formatting_options(insert_spaces = FALSE)

  text <- '{"a":1}\n'
  expect_identical(
    text_format(text, formatting_options = formatting_options),
    '{\n\t"a": 1\n}\n'
  )
})

test_that("`insert_final_newline` works", {
  formatting_options <- formatting_options(insert_final_newline = FALSE)

  text <- '{"a":1}\n'
  expect_identical(
    text_format(text, formatting_options = formatting_options),
    '{\n    "a": 1\n}'
  )
})

test_that("`insert_final_newline` works", {
  # Removes if there
  text <- '{"a":1}\n'
  formatting_options <- formatting_options(insert_final_newline = FALSE)
  expect_identical(
    text_format(text, formatting_options = formatting_options),
    '{\n    "a": 1\n}'
  )

  # Adds if missing
  text <- '{"a":1}'
  formatting_options <- formatting_options(insert_final_newline = TRUE)
  expect_identical(
    text_format(text, formatting_options = formatting_options),
    '{\n    "a": 1\n}\n'
  )
})
