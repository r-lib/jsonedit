test_that("can modify objects by name", {
  expect_snapshot(
    cat(text_modify("{}", "foo", 1))
  )
  expect_snapshot(
    cat(text_modify("{}", "foo", 1:2))
  )
  expect_snapshot(
    cat(text_modify("{}", "foo", list(1, "x")))
  )
})

test_that("modification retains comments", {
  text <- '
{
    // a
    "foo": 1, // b
    "bar": [
        // c
        1,
        2, // d
        // e
        3
    ] // f
    // g
}
  '

  expect_snapshot(
    cat(text_modify(text, "foo", 0))
  )

  expect_snapshot({
    options <- modification_options(is_array_insertion = FALSE)
    cat(text_modify(text, list("bar", 2), 0, modification_options = options))
  })
  expect_snapshot({
    options <- modification_options(is_array_insertion = TRUE)
    cat(text_modify(text, list("bar", 2), 0, modification_options = options))
  })

  expect_snapshot(
    cat(text_modify(text, "new", 0))
  )
})

test_that("can't modify non-object non-array parents", {
  expect_snapshot(error = TRUE, {
    text_modify("1", "foo", 0)
  })
  expect_snapshot(error = TRUE, {
    text_modify('"a"', "foo", 0)
  })
  expect_snapshot(error = TRUE, {
    text_modify("true", "foo", 0)
  })
  expect_snapshot(error = TRUE, {
    text_modify("null", "foo", 0)
  })
})
