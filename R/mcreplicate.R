#' Multi-core replicate.
#'
#' @param n integer: the number of replications.
#' @param expr the expression (a language object, usually a call) to evaluate repeatedly.
#' @param refresh status update refresh interval
#' @param mc.cores number of cores to use
#'
#' @examples
#' one_sim <- function(n, control_prob, rel_effect) {
#'   treat_prob <- control_prob + (control_prob * rel_effect)
#'   cy <- rbinom(n = n, size = 1, prob = control_prob)
#'   ty <- rbinom(n = n, size = 1, prob = treat_prob)
#'   mean(ty) - mean(cy)
#'   }
#'
#'   mc_replicate(10, one_sim(n = 100, control_prob = 0.1, rel_effect = 0.01))
#'
#' @returns  A vector, matrix, or list of length `n`.
#'
#' @source Modified from: Richard McElreath (2020). rethinking: Statistical
#' Rethinking book package. R package version 2.13.
#' <https://github.com/rmcelreath/rethinking>
#'
#' @importFrom parallel mclapply
#' @export
#' @md

mc_replicate <- function(n, expr, refresh = 0.1, mc.cores = 2) {
    # check if windows and set cores to 1
    if (.Platform$OS.type == "windows") {
        mc.cores <- 1
        message("Only 1 core is supported on Windows.\nRunning sequentially.")
    }

    show_progress <- function(i_) {
        intervaln <- floor(n * refresh)
        if (floor(i_/intervaln) == i_/intervaln) {
            cat(paste("[", i_, "/", n, "]\r"))
        }
    }
    result <- simplify2array(mclapply(1:n, eval.parent(substitute(function(i_, ...) {
        if (refresh > 0) show_progress(i_)
        expr
    })), mc.cores = mc.cores))
    if (refresh > 0)
        cat("\n")
    result
}
