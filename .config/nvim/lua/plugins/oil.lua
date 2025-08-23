return {
    "stevearc/oil.nvim",
    cond = not vim.g.vscode,
    config = function()
        require("oil").setup({
            view_options = {
                show_hidden = true
            },
            keymaps = {
                ["g?"] = "actions.show_help",
                ["<CR>"] = "actions.select",
                ["<C-s>"] = "actions.select_vsplit",
                ["<C-h>"] = false,
                ["<C-t>"] = "actions.select_tab",
                ["<C-p>"] = "actions.preview",
                ["<C-c>"] = "actions.close",
                ["<C-l>"] = false,
                ["-"] = "actions.parent",
                ["_"] = "actions.open_cwd",
                ["`"] = "actions.cd",
                ["~"] = "actions.tcd",
                ["gs"] = "actions.change_sort",
                ["gx"] = "actions.open_external",
                ["<m-h>"] = "actions.toggle_hidden",
                ["g\\"] = "actions.toggle_trash",
            },
            skip_confirm_for_simple_edits = true,
            -- Set to false to disable all of the above keymaps
            use_default_keymaps = true,
        })

        local api = require("oil")
        vim.keymap.set("n", "-", api.open, { desc = "Open parent directory" })
    end
}
