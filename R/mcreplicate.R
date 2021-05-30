#' Multi-core replicate.
#'
#' Use multiple cores for repeated evaluation of an expression.
#' This also works on Windows using a parallel socket cluster.
#'
#' @param n integer; the number of replications.
#' @param expr the expression (a language object, usually a call) to evaluate
#' repeatedly.
#' @param mc.cores number of cores to use.
#' @param cluster logical. If \code{TRUE} then clustering, rather than forking,
#' is used to replicate the specified function in parallel. Note: if you
#' are using Windows, only cluster is available.
#' @param varlist Only used on Windows! Character vector of variable names to
#' export on each worker. Default is all variables in the current environment
#' which do not begin with a ".". See \link[parallel]{clusterExport} for more
#' information.
#' @param envir Only used on Windows! Environment from which  to export
#' variables. Default is the environment from which this function was called.
#' See \link[parallel]{clusterExport} for more information.
#' @param packages Only used on Windows! Environment from which  to export
#' variables. Default is all loaded packages. See \link[parallel]{clusterExport}
#' for more information.
#' @param refresh Not on Windows! status update refresh interval
#'
#' @examples
#' one_sim <- function(n = 100, control_prob = 0.1, rel_effect = 0.01) {
#'   treat_prob <- control_prob + (control_prob * rel_effect)
#'   cy <- rbinom(n = n, size = 1, prob = control_prob)
#'   ty <- rbinom(n = n, size = 1, prob = treat_prob)
#'   mean(ty) - mean(cy)
#'   }
#'
#'   mc_replicate(10, one_sim(), mc.cores = 2)
#'
#'   # On Windows, when no particular packages or additional variables are needed
#'  # mc_replicate(10, one_sim(), , mc.cores = 2, packages = NULL,
#'  #              varlist = "one_sim", envir = environment())
#'
#' @returns  A vector, matrix, or list of length `n`.
#'
#' @source Modified from: Richard McElreath (2020). rethinking: Statistical
#' Rethinking book package. R package version 2.13.
#' <https://github.com/rmcelreath/rethinking>
#'
#' @importFrom parallel mclapply detectCores makePSOCKcluster clusterExport parLapply stopCluster clusterEvalQ
#' @importFrom utils sessionInfo
#'
#' @export
#' @md

mc_replicate <- function(n,
                         expr,
                         mc.cores = detectCores(),
                         cluster,
                         varlist,
                         envir,
                         packages,
                         refresh = 0.1) {
    if (missing(cluster)) cluster <- FALSE
    is_windows <- .Platform$OS.type == "windows"

    if ((is_windows && mc.cores > 1) | isTRUE(cluster)) {
        if (is_windows) {
            message("Running parallel code on Windows: a parallel socket cluster will be used.\n")
        }
        message("Variables and packages needed for code execution must be explicitely specified.\n")
        message("See the help file for more information and current defaults.\n")

        # Default exports
        if (missing(varlist)) {
            varlist <- ls(envir = parent.frame())
            print("varlist")
            print(varlist)

        }
        if (missing(envir)) {
            envir <- parent.frame()
        }
        if (missing(packages)) {
            packages <- c(sessionInfo()$basePkgs, names(sessionInfo()$otherPkgs))
        }

        cl <- parallel::makePSOCKcluster(mc.cores)

        # Export packages
        .mcreplicate.loaded.packages <- packages
        clusterExport(cl = cl, varlist = ".mcreplicate.loaded.packages",
                      envir = environment())
        clusterEvalQ(cl, sapply(.mcreplicate.loaded.packages,
                                function(package) require(package)))

        # Export variables
        clusterExport(cl = cl, varlist = varlist, envir = envir)

        result <- parLapply(cl = cl, 1:n, eval.parent(substitute(function(...){
            expr
        })))

        stopCluster(cl)
        simplify2array(result)

    } else {
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
}

