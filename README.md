
# mcreplicate: multi-core replications

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![R-CMD-check](https://github.com/christophergandrud/mcreplicate/workflows/R-CMD-check/badge.svg)](https://github.com/christophergandrud/mcreplicate/actions)
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
one_sim <- function(n, control_prob, rel_effect) {
  treat_prob <- control_prob + (control_prob * rel_effect)
    
  cy <- rbinom(n = n, size = 1, prob = control_prob)
  ty <- rbinom(n = n, size = 1, prob = treat_prob)
  
  mean(ty) - mean(cy)
}

diff_means <- mc_replicate(10, one_sim(n = 100, control_prob = 0.1, 
                                      rel_effect = 0.01))

diff_means
```

    ##  [1] -0.04 -0.03  0.00  0.04 -0.03 -0.05  0.02 -0.03 -0.02  0.09

### Windows users

On Windows, **mcreplicate** relies on a parallel socket cluster backend.
This requires the user to explicitely specify which packages and
variables should be used to populate the workers’ environments. By
default, **mcreplicate** attaches all currently loaded packages and all
variables from the current environment which do not start with a “.”.
This can be changed using the `packages`, `varlist` and `envir` optional
arguments. You can learn more on the function’s help file.

#### Example

``` r
k = 2

# The following works as intended, since the variable "k" is exported by default to each worker.
mc_replicate(10, rnorm(k))
```

    ##            [,1]       [,2]       [,3]       [,4]      [,5]      [,6]       [,7]
    ## [1,] -1.0895637 -0.9291322 -2.2835993 -0.1549158 0.8148598 0.9499048 -0.1366499
    ## [2,] -0.7789176  0.4655108  0.8965296  1.0131903 0.6792686 0.4009201 -1.2437706
    ##           [,8]        [,9]       [,10]
    ## [1,] 0.6370209 -0.85375635 -0.09725082
    ## [2,] 0.6277709  0.04385849  1.38561286

``` r
# For a reduced overhead, you can specify to *only* export the variable "k" from the current environment and to not load any particular package.
mc_replicate(10, rnorm(k), packages=NULL, varlist=c("k"), envir=environment())
```

    ##             [,1]       [,2]       [,3]       [,4]       [,5]       [,6]
    ## [1,]  0.09733941  0.1128511  0.4345149  0.5349322  0.3969553  0.5870589
    ## [2,] -1.04747904 -0.2757685 -1.1179181 -0.5689403 -1.7737434 -1.9930214
    ##            [,7]       [,8]      [,9]     [,10]
    ## [1,] -0.7326846 -0.1059534 0.3731130  1.307534
    ## [2,]  0.7220340  1.1426576 0.6124631 -1.013255

## References

This is inspired by the `mcreplicate` function from the
[rethinking](https://github.com/rmcelreath/rethinking) package.
