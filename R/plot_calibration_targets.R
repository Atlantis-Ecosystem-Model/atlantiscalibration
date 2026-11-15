#' Plot calibration results for all target types and iterations
#'
#' Reads calibration target output files from each iteration and creates
#' comparison plots of simulated versus target values. Supports biomass,
#' abundance, weight at age, and catch targets.
#'
#' @param run_dir Character. Path to the RUN directory containing iteration
#'   folders (e.g., \code{i0}, \code{i1}, \code{i2}, ...).
#'   Default: \code{here::here("RUN")}.
#' @param data_dir Character. Path to the directory containing target CSV
#'   files (e.g., \code{<Code>_<var.type>.csv}).
#'   Default: \code{here::here("inputs", "data")}.
#' @param settings_dir Character. Path to the directory containing calibration
#'   settings files (\code{calibration_settings_*.csv}).
#'   Default: \code{here::here("inputs")}.
#' @param output_dir Character. Directory where PDF plots are saved.
#'   Default: \code{here::here("outputs")}.
#' @param parameter_file Character. Path to the parameter table CSV file with
#'   an \code{IsCalibrated} column. Used to identify groups to plot.
#'   Default: \code{here::here("inputs", "parameter_table.csv")}.
#' @param output_prefix Character. Prefix for biomass index file name
#'   (e.g., "outputSETAS" for "outputSETASBiomIndx.txt").
#'   Default: \code{"outputSETAS"}.
#'
#' @return Invisibly, a named list of data frames containing the processed
#'   data for each target type.
#' @export
#'
#' @examples
#' \dontrun{
#'   plot_calibration_targets(
#'     run_dir = here::here("RUN"),
#'     data_dir = here::here("inputs", "data"),
#'     settings_dir = here::here("inputs"),
#'     output_dir = here::here("outputs")
#'   )
#' }
plot_calibration_targets <- function(
    run_dir = here::here("RUN"),
    data_dir = here::here("inputs", "data"),
    settings_dir = here::here("inputs"),
    output_dir = here::here("outputs"),
    parameter_file = here::here("inputs", "parameter_table.csv"),
    output_prefix = "outputSETAS") {

  # Validate input directories
  if (!dir.exists(run_dir)) {
    stop("Run directory not found: ", run_dir)
  }
  if (!dir.exists(data_dir)) {
    stop("Data directory not found: ", data_dir)
  }
  if (!dir.exists(settings_dir)) {
    stop("Settings directory not found: ", settings_dir)
  }
  if (!file.exists(parameter_file)) {
    stop("Parameter file not found: ", parameter_file)
  }

  # Create output directory if needed
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
  }

  # Read parameter table to identify calibrated groups
  param_table <- utils::read.csv(parameter_file)
  calibrated_groups <- param_table$Code[param_table$IsCalibrated == 1]

  if (length(calibrated_groups) == 0) {
    warning("No calibrated groups found in parameter file")
    return(invisible(list()))
  }

  # Find all calibration settings files
  settings_files <- list.files(settings_dir,
                               pattern = "^calibration_settings_.*\\.csv$",
                               full.names = TRUE)

  if (length(settings_files) == 0) {
    stop("No calibration_settings_*.csv files found in ", settings_dir)
  }

  # Get iteration directories
  iteration_dirs <- sort(list.dirs(run_dir, full.names = TRUE, recursive = FALSE))
  iteration_dirs <- iteration_dirs[grepl("i[0-9]+$", basename(iteration_dirs))]

  if (length(iteration_dirs) == 0) {
    stop("No iteration directories found in ", run_dir)
  }

  # Extract iteration numbers and assign labels
  iteration_nums <- as.numeric(sub(".*i", "", basename(iteration_dirs)))
  iteration_labels <- sprintf("%02d", iteration_nums)
  names(iteration_dirs) <- iteration_labels

  # Define colors for iterations
  n_iterations <- length(iteration_labels)
  iteration_colors <- grDevices::hcl.colors(n_iterations, palette = "viridis")
  names(iteration_colors) <- sort(iteration_labels)

  # Process each target type
  results_list <- list()

  for (settings_file in settings_files) {
    # Extract target type from filename
    var_type <- sub("calibration_settings_", "", basename(settings_file))
    var_type <- sub("\\.csv$", "", var_type)

    # Read settings file
    settings <- utils::read.csv(settings_file)

    # Get groups for this target type
    target_groups <- intersect(
      sub("_.*", "", settings$variable),
      calibrated_groups
    )
    target_groups <- unique(target_groups)

    if (length(target_groups) == 0) {
      next
    }

    # Process data based on target type
    if (var_type == "biomass") {
      plot_data <- .read_biom_indx_iterations(
        iteration_dirs, iteration_labels, target_groups, output_prefix
      )
    } else if (var_type == "abundance") {
      plot_data <- .read_abundance_iterations(
        iteration_dirs, iteration_labels, target_groups, output_prefix
      )
    } else if (var_type == "weight") {
      plot_data <- .read_weight_iterations(
        iteration_dirs, iteration_labels, target_groups, output_prefix
      )
    } else if (var_type == "catch") {
      plot_data <- .read_catch_iterations(
        iteration_dirs, iteration_labels, target_groups, output_prefix
      )
    } else {
      warning("Unknown target type: ", var_type)
      next
    }

    if (is.null(plot_data) || nrow(plot_data) == 0) {
      warning("No data found for target type: ", var_type)
      next
    }

    # Create plots for each group
    pdf_file <- file.path(output_dir, paste0(var_type, "_calibration.pdf"))
    grDevices::pdf(pdf_file, width = 11, height = 8.5)

    for (group_code in target_groups) {
      group_data <- plot_data[plot_data$group == group_code, ]

      if (nrow(group_data) == 0) {
        next
      }

      # Read target file
      target_file <- file.path(data_dir, paste0(group_code, "_", var_type, ".csv"))
      if (file.exists(target_file)) {
        target_df <- utils::read.csv(target_file)

        # Standardize column names: rename the value column to "Value"
        var_col <- setdiff(names(target_df), "Time")
        if (length(var_col) > 0) {
          names(target_df)[names(target_df) == var_col[1]] <- "Value"
        }

        target_df$iteration <- NA
        target_df$source <- "Target"
        target_df$group <- group_code

        group_data$source <- "Simulated"

        # Combine simulated and target data
        plot_data_combined <- rbind(group_data, target_df)
      } else {
        warning("Target file not found for ", group_code, " (", var_type, ")")
        plot_data_combined <- group_data
      }

      # Create plot
      p <- ggplot2::ggplot(
        data = plot_data_combined,
        ggplot2::aes(x = Time, y = Value, colour = iteration, linetype = source)
      ) +
        ggplot2::geom_line(linewidth = 0.8) +
        ggplot2::scale_color_manual(
          values = iteration_colors,
          na.value = "black",
          name = "Iteration",
          breaks = sort(unique(group_data$iteration))
        ) +
        ggplot2::scale_linetype_manual(
          values = c("Simulated" = "solid", "Target" = "solid"),
          guide = "none"
        ) +
        ggplot2::labs(
          title = paste(toupper(var_type), "Calibration:", group_code),
          x = "Time (days)",
          y = .get_y_label(var_type, group_code)
        ) +
        ggplot2::theme_minimal() +
        ggplot2::theme(
          legend.position = "right",
          panel.grid.major = ggplot2::element_line(colour = "grey90"),
          panel.grid.minor = ggplot2::element_blank(),
          plot.title = ggplot2::element_text(size = 12, face = "bold")
        )

      print(p)
    }

    grDevices::dev.off()
    message("Saved plots to: ", pdf_file)

    results_list[[var_type]] <- plot_data
  }

  invisible(results_list)
}


#' Read biomass index files from iteration directories
#' @keywords internal
.read_biom_indx_iterations <- function(iteration_dirs, iteration_labels,
                                       target_groups, output_prefix) {
  all_biom <- list()

  for (i in seq_along(iteration_dirs)) {
    biom_file <- file.path(iteration_dirs[i], "outputFolder",
                           paste0(output_prefix, "BiomIndx.txt"))
    if (file.exists(biom_file)) {
      biom <- utils::read.table(biom_file, header = TRUE)
      biom$iteration <- iteration_labels[i]
      all_biom[[i]] <- biom
    }
  }

  if (length(all_biom) == 0) {
    return(NULL)
  }

  biom_data <- do.call(rbind, all_biom)
  rownames(biom_data) <- NULL

  # Reshape to long format
  biom_long <- tidyr::pivot_longer(
    biom_data,
    cols = -c("Time", "iteration"),
    names_to = "group",
    values_to = "Value"
  )

  biom_long <- biom_long[biom_long$group %in% target_groups, ]
  biom_long$Value <- as.numeric(biom_long$Value)

  biom_long
}


#' Read abundance output from NetCDF files via biom.indx file
#' @keywords internal
.read_abundance_iterations <- function(iteration_dirs, iteration_labels,
                                       target_groups, output_prefix) {
  # For abundance, typically stored in AnnualAgeBiomIndx or other files
  # This is a placeholder that attempts to read from available files
  all_abund <- list()

  for (i in seq_along(iteration_dirs)) {
    # Try reading from AnnualAgeBiomIndx
    abund_file <- file.path(iteration_dirs[i], "outputFolder",
                            paste0(output_prefix, "AnnualAgeBiomIndx.txt"))
    if (file.exists(abund_file)) {
      abund <- utils::read.table(abund_file, header = TRUE)
      abund$iteration <- iteration_labels[i]
      all_abund[[i]] <- abund
    }
  }

  if (length(all_abund) == 0) {
    return(NULL)
  }

  abund_data <- do.call(rbind, all_abund)
  rownames(abund_data) <- NULL

  # Reshape to long format
  abund_long <- tidyr::pivot_longer(
    abund_data,
    cols = -c("Time", "iteration"),
    names_to = "group",
    values_to = "Value"
  )

  abund_long <- abund_long[abund_long$group %in% target_groups, ]
  abund_long$Value <- as.numeric(abund_long$Value)

  abund_long
}


#' Read weight at age output files
#' @keywords internal
.read_weight_iterations <- function(iteration_dirs, iteration_labels,
                                    target_groups, output_prefix) {
  # Weight at age data placeholder
  # This would typically be extracted from NetCDF or specialized output files
  message("Weight at age calibration plots not yet implemented")
  return(NULL)
}


#' Read catch output files
#' @keywords internal
.read_catch_iterations <- function(iteration_dirs, iteration_labels,
                                   target_groups, output_prefix) {
  # Catch data placeholder
  # This would typically be extracted from catch output files
  message("Catch calibration plots not yet implemented")
  return(NULL)
}


#' Get appropriate y-axis label for plot
#' @keywords internal
.get_y_label <- function(var_type, group_code) {
  switch(var_type,
    "biomass" = "Biomass (tonnes)",
    "abundance" = "Abundance (numbers)",
    "weight" = "Weight (grams)",
    "catch" = "Catch (tonnes)",
    "Value"
  )
}
