context("test-px_exists.R")

test_that("px_exists works", {
  filename1 = system.file(".","test_4dn.pairs.gz",package="Rpairix")
  filename2 = system.file(".","SRR1171591.variants.snp.vqsr.p.vcf.gz",package="Rpairix")

  expect_true(px_exists(filename1, "chr1|chr1"))
  expect_equal(px_exists(filename1, "chr1"), FALSE)
  expect_equal(px_exists(filename1, "2|4"), FALSE)
  expect_true(px_exists(filename2, "chrX"))
  expect_equal(px_exists(filename2, "Z"), FALSE)
})
