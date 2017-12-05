context("test-px_exists.R")

test_that("px_exists works", {
  filename1 = system.file(".","test_4dn.pairs.gz",package="Rpairix")
  filename2 = system.file(".","SRR1171591.variants.snp.vqsr.p.vcf.gz",package="Rpairix")

  print(filename1)
  print(filename2)

  expect_equal(px_exists(filename1, "chr1|chr1"), TRUE)
  expect_equal(px_exists(filename1, "chr1"), FALSE)
  expect_equal(px_exists(filename1, "2|4"), FALSE)
  expect_equal(px_exists(filename2, "X"), TRUE)
  expect_equal(px_exists(filename2, "Z"), FALSE)
})
