# Todo: Figure out a nice way of setting this each time R.nvim starts up on macOS
ragg_interactive_device <- function(expand = getOption("plot_expand", 5)) {
  file <- getOption("last_plot_file")
  if (is.null(file)) {
    file <- tempfile("last_plot_", fileext = ".png")
    options(last_plot_file = file)
  }
  ragg::agg_png(file, height = 480 * expand, width = 480 * expand, scaling = expand)
  withr::defer({
    dev.off()
    browseURL(file)
  }, sys.frame(1))
}

options(device = ragg_interactive_device)



