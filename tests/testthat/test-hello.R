context("test-hello.R")

test_that("hello", {
  expect_equal(hello(), 12)
  expect_equal(hello('hahaha'), 6)
})
