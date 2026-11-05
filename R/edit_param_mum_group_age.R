#' Edit maximum growth rate (mum) for all age classes across functional groups
#'
#' Replaces the mum values in a biology parameter file for one or more
#' functional groups.  Each group is matched with \code{grep} on its code:
#' \itemize{
#'   \item \code{vector.size > 1}: matches \code{mum_<Code> <vector.size>} and
#'     replaces the age-class values on the following line.
#'   \item \code{vector.size = 1}: matches \code{mum_<Code>_T15} and replaces
#'     the value on that line.
#' }
#' Groups that are not found in \code{bio.lines} are skipped with a warning.
#'
#' @param bio.lines Character vector of lines from the biology \code{.prm}
#'   file, typically the result of \code{readLines()}.
#' @param new.mum Numeric matrix of replacement mum values.  Rows are named by
#'   functional-group code; columns correspond to age classes 1 through
#'   \code{vector.size}.  When \code{single.group = TRUE}, a numeric vector
#'   of length \code{vector.size}.
#' @param overwrite Logical.  If \code{TRUE}, write the modified lines back to
#'   \code{bio.prm}; if \code{FALSE} (default) save a copy at
#'   \code{new.file.name}.
#' @param new.file.name Character.  Output file path used when
#'   \code{overwrite = FALSE}.
#' @param single.group Logical.  If \code{TRUE}, only the group named
#'   \code{group.name} is updated.  Default is \code{FALSE}.
#' @param vector.size Integer.  Number of age classes per functional group.
#'   Default is \code{10}.
#' @param group.name Character.  Code of the functional group to update.
#'   Required when \code{single.group = TRUE}.  Default is \code{NULL}.
#' @param bio.prm Character.  Path to the biology \code{.prm} file that is
#'   overwritten.  Required when \code{single.group = TRUE} and
#'   \code{overwrite = TRUE}.  Default is \code{NULL}.
#'
#' @return Modified \code{bio.lines} vector (returned only when
#'   \code{single.group = FALSE}); otherwise \code{NULL}, called for its side
#'   effect of writing a file.
#' @export
#'
#' @examples
#' \dontrun{
#'   bio.lines <- readLines("AMPSbioparam.prm")
#'   new.mum <- matrix(0.01, nrow = 2, ncol = 10,
#'                     dimnames = list(c("CHY", "COH"), NULL))
#'   bio.lines <- edit_param_mum_group_age(bio.lines, new.mum)
#' }
edit_param_mum_group_age <- function(bio.lines, new.mum, overwrite = F,new.file.name,single.group = F, vector.size = 10,
                                     group.name = NULL, bio.prm = NULL){

  if(single.group && is.null(group.name)){
    stop("group.name is required when single.group = TRUE")
  }
  if(single.group && overwrite && is.null(bio.prm)){
    stop("bio.prm is required when overwrite = TRUE")
  }

  # One row of new values per group
  if(single.group){
    new.mum <- matrix(new.mum, nrow = 1, dimnames = list(group.name, NULL))
  }

  for(i in seq_len(nrow(new.mum))){

    code <- row.names(new.mum)[i]
    values <- new.mum[i, 1:vector.size]

    if (vector.size>1){
      # mum_XXX <vector.size>, with the age-class values on the next line
      id <- grep(paste0("^mum_", code, "\\s+", vector.size, "(\\s|$)"), bio.lines)
    }else{
      # mum_XXX_T15 <value> <comment>
      id <- grep(paste0("^mum_", code, "_T15\\s"), bio.lines)
    }

    if(length(id) != 1){
      warning("Found ", length(id), " mum lines for group ", code, "; not edited")
      next
    }

    if (vector.size>1){
      bio.lines[id + 1] <- paste(values, collapse = '\t')
    }else{
      bio.lines[id] <- sub(paste0("^(mum_", code, "_T15\\s+)\\S+"), paste0("\\1", values), bio.lines[id])
    }
  }

  if(!single.group){
    return(bio.lines)
  }

  #overwrite or make copy of biology file
  if(overwrite){
    writeLines(bio.lines, con = bio.prm)
  }else{
    writeLines(bio.lines, con = new.file.name )
  }

}
