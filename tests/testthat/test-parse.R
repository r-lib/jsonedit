test_that("empty file parsing works", {
  expect_identical(text_parse(""), NULL)
  expect_identical(text_parse_at_path("", "a"), NULL)
})

test_that("Output is always returned visibly", {
  expect_identical(withVisible(text_parse("{}"))$visible, TRUE)
  expect_identical(
    withVisible(text_parse_at_path('{ "a": 1 }', "a"))$visible,
    TRUE
  )

  # These must return visible `NULL`
  expect_identical(withVisible(text_parse(""))$visible, TRUE)
  expect_identical(withVisible(text_parse_at_path("", "a"))$visible, TRUE)

  # These must return visible `NULL`
  expect_identical(withVisible(text_parse("null"))$visible, TRUE)
  expect_identical(
    withVisible(text_parse_at_path('{ "a": null }', "a"))$visible,
    TRUE
  )
})

test_that("works outside of a base object `{`", {
  expect_identical(text_parse("1"), 1L)
  expect_identical(text_parse("1.5"), 1.5)
  expect_identical(text_parse("true"), TRUE)
  expect_identical(text_parse("[1,2]"), list(1L, 2L))
  expect_identical(text_parse("[1,true]"), list(1L, TRUE))
})

test_that("`null` converts correctly", {
  expect_identical(text_parse("null"), NULL)
  expect_identical(text_parse('[null]'), list(NULL))
  expect_identical(text_parse('[null, null]'), list(NULL, NULL))
  expect_identical(text_parse('[null, 1, null]'), list(NULL, 1L, NULL))
  expect_identical(text_parse('{"a": null}'), list(a = NULL))
})

test_that("works with objects", {
  text <- '
  {
    "a": 1,
    "b": {
      "c": 2
    }
  }
  '
  expect_identical(
    text_parse(text),
    list(a = 1L, b = list(c = 2L))
  )
})

test_that("works with array as property value", {
  # Homogenous
  text <- '
  {
    "a": [1, 2]
  }
  '
  expect_identical(
    text_parse(text),
    list(a = list(1L, 2L))
  )

  # Heterogeneous
  text <- '
  {
    "a": [1, "2"]
  }
  '
  expect_identical(
    text_parse(text),
    list(a = list(1L, "2"))
  )
})

test_that("works with array of array as property value", {
  text <- '
  {
    "a": [[1], [2]]
  }
  '
  expect_identical(
    text_parse(text),
    list(a = list(list(1L), list(2L)))
  )

  text <- '
  {
    "a": [[1,2], [3,4]]
  }
  '
  expect_identical(
    text_parse(text),
    list(a = list(list(1L, 2L), list(3L, 4L)))
  )

  # Mixed types are allowed in JSON!
  # This is one big reason we don't simplify!
  text <- '
  {
    "a": [[1,"2"], [true,4]]
  }
  '
  expect_identical(
    text_parse(text),
    list(a = list(list(1L, "2"), list(TRUE, 4L)))
  )

  text <- '
  {
    "a": [["a"], [1]]
  }
  '
  expect_identical(
    text_parse(text),
    list(a = list(list("a"), list(1L)))
  )

  # This is another reason we don't try and simplify.
  # If the lengths were the same jsonlite simplifies to a matrix,
  # but if they aren't we'd get a list. That's hard to program around.
  text <- '
  {
    "a": [[1], [2, 3]]
  }
  '
  expect_identical(
    text_parse(text),
    list(a = list(list(1L), list(2L, 3L)))
  )
})

test_that("error messaging is reasonably helpful", {
  text <- trimws(
    '
{
  "a" 1
}
    '
  )
  expect_snapshot(error = TRUE, text_parse(text))

  text <- trimws(
    '
{
  "a": ]
}
    '
  )
  expect_snapshot(error = TRUE, text_parse(text))

  text <- trimws(
    '
{
  "a": [
    1,
    2,
    b"
  ]
}
    '
  )
  expect_snapshot(error = TRUE, text_parse(text))

  text <- trimws(
    '
{
  "a": [
    b",
    2,
    3
  ]
}
    '
  )
  expect_snapshot(error = TRUE, text_parse(text))
})

test_that("`allow_comments` works", {
  options <- parse_options(allow_comments = FALSE)

  text <- '
  {
    // A comment!
    "a": 1
  }
  '

  expect_snapshot(error = TRUE, {
    text_parse(text, parse_options = options)
  })
})

test_that("`allow_trailing_comma` works", {
  options <- parse_options(allow_trailing_comma = FALSE)

  text <- '
  {
    "a": 1,
  }
  '

  expect_snapshot(error = TRUE, {
    text_parse(text, parse_options = options)
  })
})

test_that("`allow_empty_content` works", {
  options <- parse_options(allow_empty_content = FALSE)

  # Fine when there are comments
  expect_identical(text_parse('"a"', parse_options = options), "a")

  expect_snapshot(error = TRUE, {
    text_parse("", parse_options = options)
  })
})
