test_that("mc_replicate basic works", {
  one_sim <- function(n = 100, control_prob = 0.1, rel_effect = 0.01) {
    treat_prob <- control_prob + (control_prob * rel_effect)
    cy <- rbinom(n = n, size = 1, prob = control_prob)
    ty <- rbinom(n = n, size = 1, prob = treat_prob)
    mean(ty) - mean(cy)
  }

  x <- mc_replicate(10, one_sim(), mc.cores = 2)

  expect_equal(length(x), 10)

  # Check clustered implementation returns a double array with at least 5 of
  # 10 values unique. 5 is more than the number of cores.
#  clustered <- mc_replicate(100, one_sim(), mc.cores = 3, cluster = TRUE)
#  expect_type(clustered, "double")
#  expect_gt(length(unique(clustered)), 5)
})
