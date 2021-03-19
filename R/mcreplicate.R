#' Multi-core replicate.
#'
#' Use multiple cores for repeated evaluation of an expression. This also works on Windows using a parallel socket cluster (see notes below regarding Windows-specific usage).
#'
#' @usage mc_replicate(n, expr, simplify = "array", mc.cores = detectCores(), ...)
#'
#' @param n integer; the number of replications.
#' @param expr the expression (a language object, usually a call) to evaluate repeatedly.
#' @param simplify logical or character string. See \link[base]{sapply} for more information.
#' @param mc.cores number of cores to use.
#' @param ... additional parameters for usage on Windows.
#'
#' @note On Windows, variables and packages needed for code execution must be explicitely specified. By default, all loaded packages are also loaded on the cluster's workers, and all variables from the current environment which do not start with a "." are exported. Use the following optional arguments to control how to populate each worker's environment:
#' \describe{
#'   \item{packages}{character vector of packages to require for each worker.}
#'   \item{varlist}{character vector of variable names to export on each worker. See \link[parallel]{clusterExport} for more information.}
#'   \item{envir}{Environment from which  to export variables. See \link[parallel]{clusterExport} for more information.}
#' }
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
#'   # On Windows, when no particular packages or variables are needed:
#'   mc_replicate(10, one_sim(), , mc.cores = 2, packages = NULL, varlist = NULL)
#'
#' @references This is inspired from the rethinking package:
#' <https://github.com/rmcelreath/rethinking/blob/3b48ec8dfda4840b9dce096d0cb9406589ef7923/R/utilities.r#L206
#'
#' @importFrom parallel mclapply detectCores makePSOCKcluster clusterExport parLapply stopCluster clusterEvalQ
#' @importFrom utils sessionInfo
#' @export
mc_replicate <- function(n, expr, simplify = "array", mc.cores = detectCores(), ...) {
    # check if windows and set cores to 1
    if (.Platform$OS.type == "windows" && mc.cores > 1) {
        cat("Running parallel code on Windows: a parallel socket cluster will be used.")
        cat("Variables and packages needed for code execution must be explicitely specified. See the help file for more information and current defaults.")

        # Default exports
        if (missing(varlist)) {
            varlist = ls(envir=parent.frame())
        }
        if (missing(envir)) {
            envir = parent.frame()
        }
        if (missing(packages)) {
            packages = c(sessionInfo()$basePkgs, names(sessionInfo()$otherPkgs))
        }

        cl <- parallel::makePSOCKcluster(mc.cores)

        # Export packages
        .mcreplicate.loaded.packages = packages
        clusterExport(cl = cl, varlist = ".mcreplicate.loaded.packages", envir=environment())
        clusterEvalQ(cl, sapply(.mcreplicate.loaded.packages, function(package) require(package)))

        # Export variables
        clusterExport(cl = cl, varlist = varlist, envir = envir)

        result <- parLapply(cl = cl, 1:n, function(i) eval(substitute(expr)))
        stopCluster(cl)

    } else {
        result <- mclapply(1:n, function(i) eval(substitute(expr)), mc.cores = mc.cores)
    }

    if (!isFALSE(simplify) && length(result))
        simplify2array(result, higher = (simplify == "array"))
    else result
}

