test_that("empty file parsing works", {
  expect_identical(text_parse(""), NULL)
  expect_identical(text_parse_at_path("", "a"), NULL)
})

test_that("works outside of a base object `{`", {
  expect_identical(text_parse("1"), 1L)
  expect_identical(text_parse("1.5"), 1.5)
  expect_identical(text_parse("true"), TRUE)
  expect_identical(text_parse("[1,2]"), c(1L, 2L))
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
    list(a = 1:2)
  )

  # Heterogeneous forced to homogenous character
  text <- '
  {
    "a": [1, "2"]
  }
  '
  expect_identical(
    text_parse(text),
    list(a = c("1", "2"))
  )
})

test_that("works with homogenous array of array as property value", {
  text <- '
  {
    "a": [[1], [2]]
  }
  '
  expect_identical(
    text_parse(text),
    list(a = matrix(1:2, nrow = 2))
  )

  text <- '
  {
    "a": [[1,2], [3,4]]
  }
  '
  expect_identical(
    text_parse(text),
    list(a = matrix(1:4, nrow = 2, byrow = TRUE))
  )

  # This is treated as homogeneous by jsonlite
  # (all same lengths, common type of character)
  text <- '
  {
    "a": [["a"], [1]]
  }
  '
  expect_identical(
    text_parse(text),
    list(a = matrix(c("a", "1"), nrow = 2, byrow = TRUE))
  )
})

test_that("works with heterogenous array of array as property value", {
  # Different lengths force list output
  text <- '
  {
    "a": [[1], [2, 3]]
  }
  '
  expect_identical(
    text_parse(text),
    list(a = list(1L, 2:3))
  )
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
