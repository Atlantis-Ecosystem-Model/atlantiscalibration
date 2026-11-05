make_param <- function(prefix, codes, suffix){
  names <- if (length(codes) > 0) paste0(prefix, codes, suffix) else character(0)
  data.frame(
    names = names,
    paropt = rep(0, length(names)),
    parmin = rep(-1, length(names)),
    parmax = rep(1, length(names)),
    parphase = rep(1, length(names))
  )
}
