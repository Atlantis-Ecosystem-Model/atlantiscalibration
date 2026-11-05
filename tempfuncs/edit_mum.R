
#' Edit natural mortality (mum) for all age classes across functional groups
#'
#' Replaces the mum age-class vectors in a biology parameter file for multiple
#' functional groups simultaneously.  Lines are matched by the pattern
#' \code{^mum_.*<vector.size>}; groups with a single age class use the T15
#' suffix convention and are handled separately when \code{vector.size = 1}.
#'
#' @param bio.lines Character vector of lines from the biology \code{.prm}
#'   file, typically the result of \code{readLines()}.
#' @param new.mum Numeric matrix of replacement mum values.  Rows are named by
#'   functional-group code; columns correspond to age classes 1 through
#'   \code{vector.size}.
#' @param overwrite Logical.  If \code{TRUE}, write the modified lines back to
#'   \code{bio.prm}; if \code{FALSE} (default) save a copy at
#'   \code{new.file.name}.
#' @param new.file.name Character.  Output file path used when
#'   \code{overwrite = FALSE}.
#' @param single.group Logical.  If \code{TRUE}, only the group named
#'   \code{group.name} is updated.  Default is \code{FALSE}.
#' @param vector.size Integer.  Number of age classes per functional group.
#'   Default is \code{10}.
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
edit_param_mum_group_age = function(bio.lines, new.mum, overwrite = F,new.file.name,single.group = F, vector.size = 10 ){

  #Get mum_XXX bio.prm lines
  bio.lines = bio.lines
  pattern = paste('^mum_.*',vector.size, sep = "")
  bio.lines.id = grep(pattern,bio.lines)
  bio.lines.vals1 = bio.lines[bio.lines.id]

  if (vector.size>1){
    if(length(grep("T15",bio.lines.vals1))!=0){
      bio.lines.id    <- bio.lines.id[   -grep("T15",bio.lines.vals1)]
      bio.lines.vals1 <- bio.lines.vals1[-grep("T15",bio.lines.vals1)]
    }
    pattern = paste('mum_|  ',vector.size,'\t\t\t\t\t\t\t\t\t', sep = "")
    group.names =unname(sapply(bio.lines.vals1,function(x) strsplit(x,pattern)[[1]][2]))

  }else{
    bio.lines.id    <- bio.lines.id[   grep("T15",bio.lines.vals1)]
    bio.lines.vals1 <- bio.lines.vals1[grep("T15",bio.lines.vals1)]
    group.names = unname(sapply(bio.lines.vals1,function(x) strsplit(x,'_T15')[[1]][1]))
    group.names = unname(sapply(group.names,function(x) strsplit(x,'mum_')[[1]][2]))
  }

  if(single.group){

    ind = which(group.name == group.names)
    C.string = paste(new.mum,collapse = '\t')
    bio.lines[bio.lines.id[ind]+1] = C.string
  }else{
    for(i in 1:nrow(new.mum)){

      ind = which(row.names(new.mum)[i] == group.names)
      C.string = paste(new.mum[i,1:(vector.size)],collapse='\t')
      bio.lines[bio.lines.id[i] + 2] = C.string
    }
    return(bio.lines)
  }

  #overwrite or make copy of biology file
  if(overwrite){
    writeLines(bio.lines, con = bio.prm)
  }else{
    file.copy(bio.prm, new.file.name, overwrite = T)
    writeLines(bio.lines, con = new.file.name )
  }

}


#' Edit natural mortality (mum) for a single species
#'
#' Multiplies the current mum value(s) for a species by a user-supplied factor.
#' For species with a single age class (T15 suffix), the scalar on the same
#' line is updated.  For multi-age-class species the numeric vector two lines
#' below the header is updated.
#'
#' @param bio.lines Character vector of lines from the biology \code{.prm}
#'   file, typically the result of \code{readLines()}.
#' @param factor Numeric multiplier applied to the current mum value(s).
#' @param species Character string with the species code used in the Atlantis
#'   configuration (e.g. \code{"CHY"}).
#'
#' @return The modified \code{bio.lines} vector with mum updated for
#'   \code{species}.
#' @export
#'
#' @examples
#' \dontrun{
#'   bio.lines <- readLines("AMPSbioparam.prm")
#'   bio.lines <- edit_param_mum_sp(bio.lines, factor = 0.9, species = "CHY")
#'   writeLines(bio.lines, "AMPSbioparam.prm")
#' }
edit_param_mum_sp = function(bio.lines, factor, species){

  #Get mum_XXX bio.prm lines
  bio.lines = bio.lines
  pattern = paste0('mum_',species)
  bio.lines.id = grep(pattern,bio.lines)
  bio.lines.vals1 = bio.lines[bio.lines.id]
  if (length(bio.lines.vals1)==0) stop("The species does not have mum parameter")

  if (length(grep("T15",bio.lines.vals1)) == 1){
    value <- as.numeric(unlist(strsplit(bio.lines.vals1, "   "))[2])*factor
    name <- unlist(strsplit(bio.lines.vals1, "   "))[1]
    new.line <- paste0(name, "   ", value)
    bio.lines[bio.lines.id] <- new.line
  }else{

    bio.lines.vals1 = bio.lines[bio.lines.id + 2]
    value <- as.numeric(unlist(strsplit(bio.lines.vals1, "   ")))*factor
    value[is.na(value)] <- ""
    new.line <- paste0(paste(as.character(value), collapse = "   "), "   ")
    bio.lines[bio.lines.id + 2] <- new.line
  }

  return(bio.lines)
}



