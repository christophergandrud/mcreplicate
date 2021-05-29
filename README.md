
# mcreplicate: Multi-Core Replications

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![R-CMD-check](https://github.com/christophergandrud/mcreplicate/workflows/R-CMD-check/badge.svg)](https://github.com/christophergandrud/mcreplicate/actions)
[![Codecov test
coverage](https://codecov.io/gh/christophergandrud/mcreplicate/branch/main/graph/badge.svg)](https://codecov.io/gh/christophergandrud/mcreplicate?branch=main)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
<!-- badges: end -->

**mcreplicate** adds multi-core functionality to R’s `replicate`
function. It allows easy parallelization on all platforms, including on
Windows.

## Installation

Install the package from GitHub:

``` r
if (!require(remotes)) install.packages("remotes")
remotes::install_github("christophergandrud/mcreplicate")
```

## Use

`mc_replicate()` works just like `replicate()`, but distributes the
replications on multiple cores

``` r
library(mcreplicate)

# Function to replicate
one_sim <- function(n = 100, control_prob = 0.1, rel_effect = 0.01) {
  treat_prob <- control_prob + (control_prob * rel_effect)
    
  cy <- rbinom(n = n, size = 1, prob = control_prob)
  ty <- rbinom(n = n, size = 1, prob = treat_prob)
  
  mean(ty) - mean(cy)
}

mc_replicate(10, one_sim())
```

    ##  [1]  0.00 -0.02 -0.02 -0.06 -0.05 -0.03 -0.01 -0.04  0.08  0.02

### Windows users

On Windows, **mcreplicate** relies on a parallel socket cluster backend.
This requires the user to explicitly specify which packages and
variables should be used to populate the workers’ environments. By
default, **mcreplicate** attaches all currently loaded packages and all
variables from the current environment which do not start with a “.”.
This can be changed using the `packages`, `varlist` and `envir` optional
arguments. You can learn more on the function’s help file.

#### Example

``` r
k = 2

# The following works as intended since the variable "k" is exported by 
# default to each worker.
mc_replicate(10, rnorm(k))

# For a reduced overhead, you can specify to *only* export the variable "k" 
# from the current environment and to not load any particular package.
mc_replicate(10, rnorm(k), packages = NULL, varlist = c("k"), 
             envir = environment())
```

## References

This is inspired by the `mcreplicate` function from the
[rethinking](https://github.com/rmcelreath/rethinking) package. We added
Windows support and we provide a lightweight package.
