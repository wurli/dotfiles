return { "Vigemus/iron.nvim",
    config = function()
        local iron = require("iron.core")

        iron.setup {
            config = {
                -- Whether a repl should be discarded or not
                scratch_repl = true,
                repl_definition = {
                    sh = { command = { "zsh" } },
                    python = require("iron.fts.python").python,
                    lua = require("iron.fts.lua").lua
                },
                -- How the repl window will be displayed
                -- See below for more information
                repl_open_cmd = require('iron.view').split.horizontal.botright(18),
            },
            -- Iron doesn't set keymaps by default anymore.
            -- You can set them here or manually add keymaps to the functions in iron.core
            keymaps = {
                -- send_motion = "<enter>",
                visual_send = "<enter>",
                -- send_file = "<localleader>sf",
                -- send_line = "<localleader>sl",
                send_paragraph = "<enter>",
                -- send_until_cursor = "<localleader>su",
                -- send_mark = "<localleader>sm",
                -- mark_motion = "<localleader>mc",
                -- mark_visual = "<localleader>mc",
                -- remove_mark = "<localleader>md",
                -- cr = "<localleader>s<cr>",
                -- interrupt = "<localleader>s<localleader>",
                -- exit = "<localleader>sq",
                -- clear = "<localleader>cl",
            },
            -- If the highlight is on, you can change how it looks
            -- For the available options, check nvim_set_hl
            highlight = {
                italic = true
            },
            ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
        }


        -- iron also has a list of commands, see :h iron-commands for all available commands
        vim.keymap.set('n', '<leader>rs', '<cmd>IronRepl<cr>')
        vim.keymap.set('n', '<leader>rr', '<cmd>IronRestart<cr>')
        vim.keymap.set('n', '<leader>rf', '<cmd>IronFocus<cr>')
        vim.keymap.set('n', '<leader>rq', '<cmd>IronHide<cr>')
    end
}
