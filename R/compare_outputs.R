#' Compare initial and optimised Atlantis calibration outputs
#'
#' Reads a saved \pkg{calibrar} results object, builds a side-by-side
#' comparison of the initial and optimised parameter values, and produces a
#' convergence plot showing the per-target fitness over iterations.
#'
#' @param results_file Character.  Path to the RDS file written by
#'   \code{\link[calibrar]{calibrate}} (e.g. via its \code{restart} option).
#'   If \code{NULL}, searches for the most recent restart file in the inputs
#'   directory. Default: \code{NULL}.
#' @param restart_dir Character.  Directory where restart files are saved.
#'   Used when \code{results_file = NULL}. Default: \code{here::here("inputs")}.
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
#'     forcing = forcing
#'   )
#'   print(out$param_comparison)
#'   print(out$plot_changes)
#' }
compare_outputs <- function(results_file = NULL, restart_dir = here::here("inputs"), forcing) {

  if (is.null(results_file)) {
    results_files <- list.files(restart_dir, pattern = "\\.results$", full.names = TRUE)
    if (length(results_files) == 0) {
      stop("No .results files found in ", restart_dir)
    }
    results_file <- results_files[which.max(file.info(results_files)$mtime)]
  }

  results <- readRDS(results_file)

  # Side-by-side table of initial vs optimised parameter values
  param_comparison <- forcing |>
    tibble::rownames_to_column("parameter") |>
    tibble::as_tibble() |>
    dplyr::mutate(paropt_new = results$par,
                  # factor applied to the original value in the .prm file
                  factor_new = exp(paropt_new)) |>
    dplyr::select(parameter, paropt, paropt_new, factor_new, parmin, parmax, parphase)

  # Convergence plot: per-target fitness of the best solution in each
  # generation (rows of trace$fitness after the last generation are NA)
  fitness <- results$trace$fitness
  fitness <- fitness[stats::complete.cases(fitness), , drop = FALSE]

  plot_changes <- fitness |>
    tibble::as_tibble(.name_repair = "unique") |>
    dplyr::mutate(iteration = dplyr::row_number()) |>
    tidyr::pivot_longer(-iteration, names_to = "target", values_to = "fitness") |>
    ggplot2::ggplot(ggplot2::aes(x = iteration, y = fitness, colour = target)) +
    ggplot2::geom_line() +
    ggplot2::scale_y_log10() +
    ggplot2::labs(
      title  = "Calibration convergence by target",
      x      = "Iteration",
      y      = "Fitness (log scale)",
      colour = "Target"
    ) +
    ggplot2::theme_minimal()

  list(param_comparison = param_comparison, plot_changes = plot_changes)
}
