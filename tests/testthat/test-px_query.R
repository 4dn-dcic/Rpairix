context("test-px_query.R")

test_that("px_query works for query chrX|chrX on 4dn pairs file", {
  x1 = px_query("inst/test_4dn.pairs.gz","chrX|chrX", linecount.only=TRUE)
  x2 = system("gunzip -c inst/test_4dn.pairs.gz | awk '$2==\"chrX\" && $4==\"chrX\"' |wc -l", intern=TRUE)
  x2 = as.integer(x2)
  expect_equal(x1, x2)
})

