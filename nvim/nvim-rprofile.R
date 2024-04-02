options(repos = c(CRAN = "http://cran.rstudio.com", getOption("repos")))

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# A possible way to set a faster device for previewing plots if on macOS 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# if (Sys.info()["sysname"] == "Darwin" && 
#     requireNamespace("withr", quietly = TRUE) &&
#     requireNamespace("ragg", quietly = TRUE)) {
#
#   options(device = function(expand = getOption("plot_expand", 5)) {
#     file <- getOption("last_plot_file")
#     if (is.null(file)) {
#       file <- tempfile("last_plot_", fileext = ".png")
#       options(last_plot_file = file)
#     }
#     ragg::agg_png(file, height = 480 * expand, width = 480 * expand, scaling = expand)
#     withr::defer({
#       dev.off()
#       browseURL(file)
#     }, sys.frame(1))
#   })
#
# }

