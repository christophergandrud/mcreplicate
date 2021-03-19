#' Multi-core replicate. From the rethinking package:
#' <https://github.com/rmcelreath/rethinking/blob/3b48ec8dfda4840b9dce096d0cb9406589ef7923/R/utilities.r#L206>
#' 
#' @param n integer: the number of replications.
#' @param expr the expression (a language object, usually a call) to evaluate repeatedly.
#' @param refresh status update refresh interval
#' @param mc.cores number of cores to use
#' 
#' @importFrom parallel mclapply
#' @export 

mcreplicate <- function(n, expr, refresh = 0.1, mc.cores = 2) {
    # require(parallel)
    show_progress <- function(i) {
        intervaln <- floor(n * refresh)
        if (floor(i/intervaln) == i/intervaln) {
            cat(paste("[", i, "/", n, "]\r"))
        }
    }
    result <- simplify2array(mclapply(1:n, eval.parent(substitute(function(i, ...) {
        if (refresh > 0) show_progress(i)
        expr
    })), mc.cores = mc.cores))
    if (refresh > 0) 
        cat("\n")
    result
}