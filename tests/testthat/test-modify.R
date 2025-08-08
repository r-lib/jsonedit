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
