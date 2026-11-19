#' Update forcing file paths with absolute paths
#'
#' Reads all forcing files from \code{inputs/forcing} directory and updates
#' all \code{.prm} files in \code{model_configuration/} that reference them
#' with absolute paths. This ensures the model can locate forcing files
#' regardless of the working directory or package installation path.
#'
#' @param pkg_path Character. Optional path to the atlantiscalibration package
#'   directory. If \code{NULL} (default), uses \code{here::here()} to find the
#'   project root.
#' @param run_only Logical. If \code{TRUE}, only updates files matching
#'   \code{*_run_*.prm} pattern. If \code{FALSE} (default), updates all
#'   \code{.prm} files in the model configuration directory.
#'
#' @return Invisibly returns a data frame with details of updated files and
#'   the number of paths updated in each.
#'
#' @details
#' This function performs the following operations:
#' \itemize{
#'   \item Finds all forcing files in the \code{inputs/forcing} directory
#'   \item Locates parameter files in \code{model_configuration/}
#'   \item Scans for relative paths pointing to forcing files
#'   \item Replaces them with absolute paths pointing to the package location
#'   \item Preserves all other content and formatting of the parameter files
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   setup_forcing_paths()
#'   setup_forcing_paths(run_only = TRUE)
#' }
setup_forcing_paths <- function(pkg_path = NULL, run_only = FALSE) {
  if (is.null(pkg_path)) {
    pkg_path <- here::here()
  }

  # Ensure the path is absolute
  pkg_path <- normalizePath(pkg_path)

  # Construct expected paths
  forcing_dir <- file.path(pkg_path, "inputs", "forcing")
  model_config_dir <- file.path(pkg_path, "inputs", "model_configuration")

  # Validate directories exist
  if (!dir.exists(forcing_dir)) {
    stop("Forcing directory not found: ", forcing_dir)
  }

  if (!dir.exists(model_config_dir)) {
    stop("Model configuration directory not found: ", model_config_dir)
  }

  # Find .prm files to update
  if (run_only) {
    prm_files <- list.files(
      model_config_dir,
      pattern = ".*_run_.*\\.prm$",
      full.names = TRUE
    )
    if (length(prm_files) == 0) {
      stop("No file matching '*_run_*.prm' found in: ", model_config_dir)
    }
  } else {
    prm_files <- list.files(
      model_config_dir,
      pattern = "\\.prm$",
      full.names = TRUE
    )
    if (length(prm_files) == 0) {
      stop("No .prm files found in: ", model_config_dir)
    }
  }

  # Find all forcing files
  forcing_files <- list.files(
    forcing_dir,
    recursive = TRUE,
    full.names = FALSE
  )

  if (length(forcing_files) == 0) {
    warning("No forcing files found in: ", forcing_dir)
    return(invisible(data.frame()))
  }

  # Create a data frame to track changes across all files
  summary <- data.frame(
    file = character(),
    paths_updated = integer(),
    stringsAsFactors = FALSE
  )

  # Build a master list of all relative paths to absolute paths
  # Sort by length (longest first) to avoid partial replacements
  path_replacements <- data.frame(
    relative = character(),
    absolute = character(),
    stringsAsFactors = FALSE
  )

  for (forcing_file in forcing_files) {
    relative_paths <- c(
      file.path("inputs", "forcing", forcing_file),
      file.path("atlantiscalibration", "inputs", "forcing", forcing_file),
      forcing_file
    )
    absolute_path <- file.path(forcing_dir, forcing_file)

    for (rel_path in relative_paths) {
      path_replacements <- rbind(
        path_replacements,
        data.frame(
          relative = rel_path,
          absolute = absolute_path,
          stringsAsFactors = FALSE
        )
      )
    }
  }

  # Sort by length (longest first) to avoid partial path replacements
  path_replacements$length <- nchar(path_replacements$relative)
  path_replacements <- path_replacements[order(-path_replacements$length), ]

  # Process each .prm file
  for (prm_file in prm_files) {
    # Read the parameter file
    prm_content <- readLines(prm_file, warn = FALSE)
    original_content <- prm_content

    # Apply replacements in order (longest paths first)
    for (i in seq_len(nrow(path_replacements))) {
      rel_path <- path_replacements$relative[i]
      abs_path <- path_replacements$absolute[i]

      # Only replace paths that are not already absolute (don't start with /)
      prm_content <- gsub(
        paste0("(?<![/a-zA-Z0-9_-])", gsub("/", "\\\\/", rel_path), "(?![/a-zA-Z0-9._-])"),
        abs_path,
        prm_content,
        perl = TRUE,
        fixed = FALSE
      )
    }

    # Count changes
    changes <- sum(prm_content != original_content)

    if (changes > 0) {
      # Write the updated content back to the file
      writeLines(prm_content, prm_file)
      message("Updated ", basename(prm_file), " - ", changes, " line(s) modified")

      summary <- rbind(
        summary,
        data.frame(
          file = basename(prm_file),
          paths_updated = changes,
          stringsAsFactors = FALSE
        )
      )
    }
  }

  if (nrow(summary) == 0) {
    message("No forcing file paths found to update in .prm files")
  } else {
    message("\nTotal files updated: ", nrow(summary))
    message("Total lines modified: ", sum(summary$paths_updated))
  }

  return(invisible(summary))
}
