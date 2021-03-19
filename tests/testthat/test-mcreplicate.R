test_that("mc_replicate basic works", {
  one_sim <- function(n, control_prob, rel_effect) {
    treat_prob <- control_prob + (control_prob * rel_effect)
    cy <- rbinom(n = n, size = 1, prob = control_prob)
    ty <- rbinom(n = n, size = 1, prob = treat_prob)
    mean(ty) - mean(cy)
  }

  x <- mc_replicate(10, one_sim(n = 100, control_prob = 0.1, rel_effect = 0.01))

  expect_equal(length(x), 10)
})
