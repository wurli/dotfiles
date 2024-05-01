# -- Set the CRAN mirror ------------------------------------------------------
local({
  repos <- getOption("repos")
  repos["CRAN"] <- "http://cran.rstudio.com"
  options(repos = repos)
})

# -- Set some Windows stuff ---------------------------------------------------
if (.Platform[["OS.type"]] == "Windows") {
  # Manually set cli to use more terminal colours (e.g. for tibble printing)
  options(cli.num_colors = 256)

  # Hack `getOption()` to always update the console width, which for some
  # reason doesn't happen with the default windows R console
  if (requireNamespace("cli", quietly = TRUE)) {
    assignInNamespace(
      "getOption",
      function(x, default = NULL) {
        # Check and maybe update console width
        if (x %in% c("width", "pillar.width")) {
          options(width = cli::console_width())
          options(pillar.width = cli::console_width())
        }

        # Default getOption() implementation from here:
        if (missing(default)) {
          .Internal(getOption(x))
        } else {
          ans <- .Internal(getOption(x))
          if (is.null(ans)) {
            default
          } else {
            ans
          }
        }
      }, 
      ns = "base"
    )
  }
}

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

