local live_multigrep = function(opts)
    local pickers    = require "telescope.pickers"
    local finders    = require "telescope.finders"
    local make_entry = require "telescope.make_entry"
    local conf       = require "telescope.config".values
    local sorters    = require "telescope.sorters"

    opts = opts or {}
    opts.cwd = opts.cwd or vim.uv.cwd()

    local finder = finders.new_async_job {
        command_generator = function(prompt)
            if not prompt or prompt == "" then
                return nil
            end

            local pieces = vim.split(prompt, "  ")
            local args = { "rg" }

            if pieces[1] then
                table.insert(args, "-e")
                table.insert(args, pieces[1])
            end

            if pieces[2] then
                table.insert(args, "-g")
                table.insert(args, pieces[2])
            end

            for _, arg in ipairs({
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
                "--smart-case"
            }) do
                table.insert(args, arg)
            end

            return args
        end,

        entry_maker = make_entry.gen_from_vimgrep(opts),
        cwd = opts.cwd,
    }

    pickers.new(opts, {
        debounce = 100,
        prompt_title = "Multi Grep",
        finder = finder,
        previewer = conf.grep_previewer(opts),
        sorter = sorters.empty(),
    }):find()
end

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
                    "--glob=!**/.databricks/*",
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
                    cwd = vim.fn.stdpath("config"),
                    prompt_title = "Config Files",
                })
            end, { desc = "Telescope find config files" })

            vim.keymap.set("n", "<leader>fl", builtin.git_commits, { desc = "Telescope git commits" })
            vim.keymap.set("n", "<leader>fL", builtin.git_bcommits, { desc = "Telescope git buffer commits" })
            vim.keymap.set("n", "<leader>fL", builtin.git_bcommits, { desc = "Telescope git buffer commits" })
            vim.keymap.set("n", "<leader>ft", builtin.git_branches, { desc = "Telescope git branches" })

            vim.keymap.set("n", "<leader>fg", live_multigrep, { desc = "Telescope multigrep" })
            -- vim.keymap.set("n", "<leader>fg", function() builtin.live_grep({
            --     additional_args = {
            --         "--hidden",
            --         "--no-ignore",
            --         "--glob=!**/.databricks/*",
            --         "--glob=!**/.venv/*",
            --         "--glob=!**/.git/*",
            --     }
            -- }) end, { desc = "Telescope grep" })

            vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "Telescope find help tags" })
            vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "Telescope find buffers" })
            vim.keymap.set('n', '<leader>fm', builtin.man_pages, { desc = "Telescope find man pages" })
            vim.keymap.set('n', '<leader>fr', builtin.registers, { desc = "Telescope find registers" })
            vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = "Telescope find keymaps" })
            vim.keymap.set('n', '<leader>fm', builtin.marks, { desc = "Telescope find marks" })
            vim.keymap.set('n', '<leader>fp', function()
                builtin.find_files({
                    cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy")
                })
            end, { desc = "Telescope find package files" })
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
