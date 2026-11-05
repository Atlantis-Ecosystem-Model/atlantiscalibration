
repro_option <- function(fg.file, biology.prm){

  fg.groups <- readr::read_csv(here::here("inputs","model_configuration",fg.file))

  # Read the .prm file
  prm.data <- readr::read_file(here::here("inputs", "model_configuration", biology.prm))

  # Extract flagrecruit lines

  flagrecruit.lines <- prm.data %>%
    strsplit("\n") %>%
    unlist() %>%
    grep("^flagrecruit", ., value = TRUE) %>%
    tibble::tibble(parameter=(.)) %>%
    dplyr::mutate(parameter_corr = gsub("  "," ", parameter)) %>%
    tidyr::separate_wider_delim(parameter_corr, delim=" ", names=c("parameter_name","flagrecruit","extra")) %>%
    dplyr::mutate(Code=gsub("flagrecruit","",parameter_name)) %>%
    dplyr::select(Code, flagrecruit)


  readr::write_csv(flagrecruit.lines, here::here("inputs","reproduction-option.csv"))


}
