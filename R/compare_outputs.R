#' Compare initial and optimised Atlantis calibration outputs
#'
#' Reads a saved \pkg{calibrar} results object, builds a side-by-side
#' comparison of the initial and optimised parameter values, and produces a
#' convergence plot showing the per-target fitness over iterations.
#'
#' @param results_file Character.  Path to the RDS file written by
#'   \code{\link[calibrar]{calibrate}} (e.g. via its \code{restart} option).
#'   Default: \code{"restart_file.results"}.
#' @param forcing Data frame of parameter metadata with row names used as
#'   parameter identifiers.  Must contain at minimum the columns
#'   \code{paropt} (initial values), \code{parmin}, \code{parmax}, and
#'   \code{parphase}.
#'
#' @return A named list with two elements:
#' \describe{
#'   \item{\code{param_comparison}}{A tibble with one row per parameter and
#'     columns \code{parameter}, \code{paropt} (initial), \code{paropt_new}
#'     (optimised), \code{parmin}, \code{parmax}, and \code{parphase}.}
#'   \item{\code{plot_changes}}{A \code{ggplot} object showing calibration
#'     fitness per target over iterations on a log\eqn{_{10}} scale.}
#' }
#' @export
#'
#' @examples
#' \dontrun{
#'   out <- compare_outputs(
#'     results_file = "restart_file.results",
#'     forcing      = forcing
#'   )
#'   print(out$param_comparison)
#'   print(out$plot_changes)
#' }
compare_outputs <- function(results_file = "restart_file.results", forcing) {

  results <- readRDS(results_file)

  # Side-by-side table of initial vs optimised parameter values
  param_comparison <- forcing %>%
    rownames_to_column("parameter") %>%
    as_tibble() %>%
    mutate(paropt_new = results$par) %>%
    select(parameter, paropt, paropt_new, parmin, parmax, parphase)

  # Convergence plot: per-target fitness across calibration iterations
  plot_changes <- results$fitness %>%
    as_tibble() %>%
    mutate(iteration = row_number()) %>%
    pivot_longer(-iteration, names_to = "target", values_to = "fitness") %>%
    ggplot(aes(x = iteration, y = fitness, colour = target)) +
    geom_line() +
    scale_y_log10() +
    labs(
      title  = "Calibration convergence by target",
      x      = "Iteration",
      y      = "Fitness (log scale)",
      colour = "Target"
    ) +
    theme_minimal()

  list(param_comparison = param_comparison, plot_changes = plot_changes)
}
