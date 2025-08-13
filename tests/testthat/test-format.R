test_that("formatting retains comments", {
  text <- '
  {
    // a comment

  "a":1, // another one
    "b": {
      "c":2
    }
  } // trailing
  '
  expect_snapshot(cat(text_format(text)))
})

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

test_that("`indent_width` works", {
  formatting_options <- formatting_options(indent_width = 2)

  text <- '{"a":1}\n'
  expect_identical(
    text_format(text, formatting_options = formatting_options),
    '{\n  "a": 1\n}\n'
  )
})

test_that("`indent_style` works", {
  formatting_options <- formatting_options(indent_style = "tab")

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
