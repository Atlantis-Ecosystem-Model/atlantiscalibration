#' Find the Atlantis shell script and read the files it uses
#'
#' Finds the shell script (the only file with extension \code{.sh} in
#' \code{path}) and reads the file names given to each option of the Atlantis
#' command line, e.g. \code{-b} (biology parameters), \code{-h} (harvest
#' parameters), \code{-r} (run parameters), \code{-s} (functional groups),
#' \code{-o} (output file) and \code{-d} (output folder).
#'
#' @param path Character.  Directory with the shell script.  Default: the
#'   working directory.
#'
#' @return A list with elements \code{sh.file} (name of the shell script) and
#'   \code{files} (named character vector of file names, named by option
#'   letter, e.g. \code{files[["b"]]}).
#' @export
#'
#' @examples
#' \dontrun{
#'   sh <- read_sh_file("inputs/model_configuration")
#'   sh$sh.file
#'   sh$files[["b"]]  # biology parameter file
#' }
read_sh_file <- function(path = getwd()){

  sh.file <- list.files(path, pattern = "\\.sh$")

  if (length(sh.file) != 1){
    stop("Found ", length(sh.file), " .sh files in ", path,
         "; there must be exactly one shell script to run Atlantis")
  }

  # Join lines continued with "\" and keep the Atlantis command line
  sh.lines <- readLines(file.path(path, sh.file), warn = FALSE)
  sh.lines <- unlist(strsplit(gsub("\\\\\\s*\n", " ", paste(sh.lines, collapse = "\n")), "\n"))
  command <- grep("\\s-b\\s", sh.lines, value = TRUE)

  if (length(command) != 1){
    stop("Could not find the Atlantis command line (with option -b) in ", sh.file)
  }

  # Each option "-x" is followed by its file name
  tokens <- strsplit(trimws(command), "\\s+")[[1]]
  is.option <- grepl("^-[a-zA-Z]$", tokens) & seq_along(tokens) < length(tokens)
  files <- stats::setNames(tokens[which(is.option) + 1], sub("^-", "", tokens[is.option]))

  list(sh.file = sh.file, files = files)
}
