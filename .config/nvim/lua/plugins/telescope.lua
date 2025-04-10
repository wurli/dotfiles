return {
    {
        "nvim-telescope/telescope.nvim",
        cond = not vim.g.vscode,
        tag = "0.1.5",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
        },
        config = function()
            require("telescope").setup({
                extensions = {
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = "smart_case", -- or "ignore_case" or "respect_case"
                    }
                },
                pickers = {
                    help_tags = {
                        mappings = {
                            i = {
                                ["<Enter>"] = require("telescope.actions").select_vertical
                            }
                        }
                    },
                    man_pages = {
                        mappings = {
                            i = {
                                ["<Enter>"] = require("telescope.actions").select_vertical
                            }
                        }
                    }
                }
            })

            require("telescope").load_extension("fzf")
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

            vim.keymap.set("n", "<leader>fc", function()
                builtin.find_files({
                    cwd = vim.fn.stdpath("config")
                })
            end)

            -- local actions = require("telescope.actions")
            -- actions.file_vsplit(0)
            vim.keymap.set("n", "<leader>fg", function() builtin.live_grep({
                additional_args = { "--hidden", "--no-ignore", "--glob=!.git/*" }
            }) end, {})
            vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
            vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
            vim.keymap.set('n', '<leader>fm', builtin.man_pages, {})
            vim.keymap.set('n', '<leader>fr', builtin.registers, {})
            vim.keymap.set('n', '<leader>fk', builtin.keymaps, {})
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
