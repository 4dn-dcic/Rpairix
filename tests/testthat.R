library(testthat)
library(Rpairix)

Sys.setenv("R_TESTS" = "")
test_check("Rpairix")
