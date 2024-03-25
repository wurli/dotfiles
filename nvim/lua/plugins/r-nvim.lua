return {
  "R-nvim/R.nvim",
  config = function ()

    -- Create a table with the options to be passed to setup()
    local opts = {
      R_args = {"--quiet", "--no-save"},
      hook = {
        after_config = function ()
          -- This function will be called at the FileType event
          -- of files supported by R.nvim. This is an
          -- opportunity to create mappings local to buffers.
          if vim.o.syntax ~= "rbrowser" then
            vim.api.nvim_buf_set_keymap(0, "n", "<Enter>", "<Plug>RDSendLine", {})
            vim.api.nvim_buf_set_keymap(0, "v", "<Enter>", "<Plug>RSendSelection", {})
          end

          -- Use <C-L> for devtools::load_all() like RStudio
          vim.api.nvim_buf_set_keymap(0, "n", "<C-S-l>",
            "<Cmd>lua require('r.send').cmd('devtools::load_all()')<CR>", {}
          )
          vim.api.nvim_buf_set_keymap(0, "i", "<C-S-l>",
            "<Cmd>lua require('r.send').cmd('devtools::load_all()')<CR>", {}
          )

          -- Pipe operator
          vim.api.nvim_buf_set_keymap(0, "i", "<C-S-m>", " |>", {})

        end
      },

      -- Note that on macOS, you need to set the option key as the 'meta'
      -- key, e.g. in your iterm2 profile, for this to work
      assign_map = "<M-->",

      auto_start = "always",

      -- For some reason gets set to 'Rterm' on windows
      R_cmd = "R",
      R_app = "R",

      -- Windows testing 
      -- R_path = "C:\\Program Files\\R\\R-4.3.2\\bin",

      min_editor_width = 72,
      rconsole_width = 78,

      disable_cmds = {
        "RClearConsole",
        "RCustomStart",
        "RSPlot",
        "RSaveClose",
      },

    }

    -- Check if the environment variable "R_AUTO_START" exists.
    -- If using fish shell, you could put in your config.fish:
    -- alias r "R_AUTO_START=true nvim"
    if vim.env.R_AUTO_START == "true" then
      opts.auto_start = 1
      opts.objbr_auto_start = true
    end

    require("r").setup(opts)

    -- Use tidyverse-style indentation (instead of weird stackoverflow style)
    vim.g.r_indent_align_args = 0

    -- Highlight R output using normal colourscheme
    vim.g.rout_follow_colorscheme = true

  end,
  lazy = false
}

