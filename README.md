
# mcreplicate

<!-- badges: start -->

[![R-CMD-check](https://github.com/christophergandrud/mcreplicate/workflows/R-CMD-check/badge.svg)](https://github.com/christophergandrud/mcreplicate/actions)
<!-- badges: end -->

## Purpose

Multi-core replication to make Monte Carlo simulation faster more
easily. Based on the `mcreplicate` function from the rethinking package.
The [rethinking](https://github.com/rmcelreath/rethinking) package
requires installing [rstan](https://cran.r-project.org/package=rstan),
which can be a hurdle, while also not adding capabilities to this
function.

**Note:** multi-core support is not available on Windows.

## Installation

Install the package from GitHub:

``` r
xfun::pkg_attach2("remotes")

install_github("christophergandrud/mcreplicate")
```

## Use

`mc_replicate()` works just like `replicate()`, but distributes the
replications.

``` r
library(mcreplicate)

# Function to replicate
one_sim <- function(n, control_prob, rel_effect) {
  treat_prob <- control_prob + (control_prob * rel_effect)
    
  cy <- rbinom(n = n, size = 1, prob = control_prob)
  ty <- rbinom(n = n, size = 1, prob = treat_prob)
  
  mean(ty) - mean(cy)
}

diff_means <- mc_replicate(10, one_sim(n = 100, control_prob = 0.1, 
                                      rel_effect = 0.01))
```

``` r
diff_means
```

    ##  [1] -0.01  0.02  0.08  0.02  0.07 -0.01 -0.02  0.01  0.01  0.06
