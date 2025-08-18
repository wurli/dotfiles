vim.keymap.set("n", "<leader><leader>c", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Code companion chat" })
vim.keymap.set("n", "<leader>fa",        "<cmd>CodeCompanionActions<cr>",     { desc = "Code completion actions" })
vim.cmd[[cnoreabbrev CC CodeCompanion]]
vim.cmd[[cnoreabbrev CB CodeCompanion #buffer]]
vim.cmd[[cnoreabbrev CE Copilot enable]]
vim.cmd[[cnoreabbrev CD Copilot disable]]

vim.g.copilot_filetypes = {
    markdown = false,
}

return {
    {
        "github/copilot.vim",
        cmd = "Copilot",
        event = "BufWinEnter",
        cond = not vim.g.vscode,
        config = function()
            vim.keymap.set("i", "<m-e>",     "<Plug>(copilot-dismiss)",     { desc = "Copilot dismiss" })
            vim.keymap.set("i", "<m-n>",     "<Plug>(copilot-next)",        { desc = "Copilot next" })
            vim.keymap.set("i", "<m-p>",     "<Plug>(copilot-previous)",    { desc = "Copilot previous" })
            vim.keymap.set("i", "<m-i>",     "<Plug>(copilot-accept-word)", { desc = "Copilot accept word" })
            vim.keymap.set("i", "<m-space>", "<Plug>(copilot-suggest)",     { desc = "Copilot suggest" })
            vim.keymap.set("i", "<m-y>", 'copilot#Accept("\\<CR>")', {
                desc = "Copilot accept",
                expr = true,
                replace_keycodes = false,
            })
        end,
    },
    {
        "olimorris/codecompanion.nvim",
        cond = not vim.g.vscode,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "j-hui/fidget.nvim",
        },
        init = function()
            require("utils.codecompanion-fidget-spinner"):init()
        end,
        opts = {
            strategies = {
                -- Change the default chat adapter
                chat = {
                    adapter = "copilot",
                    keymaps = {
                        -- I don't think there's a way to remove the insert
                        -- mode keymap altogether
                        close = { modes = { i = "<m-q>", n = "<m-q>" } }
                    }
                },
                inline = { adapter = "copilot" },
            },
            adapters = {
                copilot = function()
                    return require("codecompanion.adapters").extend("copilot", {
                        schema = {
                            model = {
                                -- default = "claude-3.7-sonnet",
                                default = "claude-sonnet-4",
                            },
                        },
                    })
                end
            },
            -- display = {
            --     chat = {
            --         window = {
            --             opts = {
            --                 number = false,
            --                 relativenumber = false
            --             }
            --         }
            --     },
            --     diff = {
            --         -- I really want to use this, but it just feels like it gets
            --         -- in the way :'(
            --         enabled = false,
            --         provider = "default",
            --         opts = { "algorithm:patience" }
            --     }
            -- }
        },
    },
}

