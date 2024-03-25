return {
  {
    "neanias/everforest-nvim",
    version = false,
    lazy = false,
    priority = 1000,
    config = function()
      local everforest = require("everforest")
      everforest.setup({
        background = "hard",
        transparent_background_level = 0,
        italics = true,
        disable_italic_comments = false,
        sign_column_background = "none",
        ui_contrast = "high",
        dim_inactive_windows = false,
        diagnostic_text_highlight = true,
        diagnostic_virtual_text = "coloured",
        spell_foreground = false,
        colours_override = function(palette)
          -- Swap the sidebar and main pane background colours - main pane
          -- is a little too washed out for me (aesthetically v nice though)
          palette.bg0, palette.bg_dim = palette.bg_dim, palette.bg0
        end
      })
      everforest.load()
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = { theme = "everforest" },
        --[[ options = { theme = "dracula" }, ]]
      })
    end,
  }
}
-- return {
--   "catppuccin/nvim",
--   name = "catppuccin",
--   priority = 1000,
--   lazy = false,
--   flavour = "mocha",
--   config = function()
--     vim.cmd.colorscheme "catppuccin"
--   end
-- }
--
