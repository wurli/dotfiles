# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Get the RStudio terminal colours, which highlght R output really nicely.
# These can be used to override the colours for the built-in terminal in
# Neovim.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

library(tidyverse)

readLines("https://raw.githubusercontent.com/rstudio/rstudio/main/src/cpp/tests/testthat/themes/rsthemes/cobalt.rstheme") |>
  str_subset("^\\s*\\.xtermColor") |>
  map(function(x) {
    tibble(
      colour_number = as.integer(str_extract(x, "(?<=Color)\\d+")),
      colour_val = str_extract(x, "(?<=color: )#\\S+")
    )
  }) |>
  list_rbind() |>
  mutate(
    text = glue::glue('vim.g.terminal_color_{colour_number} = "{colour_val}"')
  ) |>
  pull(text)


