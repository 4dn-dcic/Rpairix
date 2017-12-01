context("test-px_exists.R")

test_that("px_exists works", {
  expect_equal(px_exists("inst/test_4dn.pairs.gz", "chr1|chr1"), TRUE)
  expect_equal(px_exists("inst/test_4dn.pairs.gz", "chr1"), FALSE)
  expect_equal(px_exists("inst/test_4dn.pairs.gz", "2|4"), FALSE)
  expect_equal(px_exists("SRR1171591.variants.snp.vqsr.p.vcf.gz", "X"), TRUE)
  expect_equal(px_exists("SRR1171591.variants.snp.vqsr.p.vcf.gz", "Z"), FALSE)
})
