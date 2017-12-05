context("test-px_query.R")

test_that("px_query works for query chrX|chrX on 4dn pairs file", {
  filename = system.file(".","test_4dn.pairs.gz",package="Rpairix")

  # function
  x1 = px_query(filename,"chrX|chrX", linecount.only=TRUE)

  # benchmark
  command = paste("gunzip -c ",filename," | awk '$2==\"chrX\" && $4==\"chrX\"' |wc -l", sep="")
  x2=system(command, intern=TRUE)
  x2 = as.integer(x2)

  # compare
  expect_equal(x1, x2)
})

