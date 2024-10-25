return {
    {
        "nvim-telescope/telescope.nvim",
        cond = not vim.g.vscode,
        tag = "0.1.5",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                pickers = {
                    help_tags = {
                        mappings = {
                            i = {
                                ["<Enter>"] = require("telescope.actions").select_vertical
                            }
                        }
                    }
                }
            })

            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>ff", function() builtin.find_files({
                hidden = true,
                find_command = {
                    "rg",
                    "--files",
                    "--hidden",
                    "--glob=!**/.git/*",
                    "--glob=!**/.idea/*",
                    "--glob=!**/.vscode/*",
                    "--glob=!**/build/*",
                    "--glob=!**/dist/*",
                    "--glob=!**/yarn.lock",
                    "--glob=!**/package-lock.json",
                },
            }) end, {})

            -- local actions = require("telescope.actions")
            -- actions.file_vsplit(0)
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
            vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
            vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
            vim.keymap.set('n', '<leader>fm', builtin.man_pages, {})
        end,
    },
    {
        "nvim-telescope/telescope-ui-select.nvim",
        cond = not vim.g.vscode,
        config = function()
            require("telescope").setup({
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown({}),
                    },
                },
            })
            require("telescope").load_extension("ui-select")
        end,
    },
}
