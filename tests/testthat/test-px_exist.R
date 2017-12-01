context("test-px_exist.R")

test_that("px_exist works", {
  expect_equal(px_exist("inst/test_4dn.pairs.gz", "chr1"), TRUE)
  expect_equal(px_exist("inst/test_4dn.pairs.gz", "2"), FALSE)
})
