vim.keymap.set("n", "<leader><leader>c", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Code companion chat" })
vim.keymap.set("n", "<leader>fa", "<cmd>CodeCompanionActions<cr>", { desc = "Code completion actions" })
vim.cmd [[cnoreabbrev CC CodeCompanion]]
vim.cmd [[cnoreabbrev CB CodeCompanion #buffer]]
vim.cmd [[cnoreabbrev CE Copilot enable]]
vim.cmd [[cnoreabbrev CD Copilot disable]]

return {
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        cond = not vim.g.vscode,
        dependencies = { "copilotlsp-nvim/copilot-lsp" },
        config = {
            filetypes = {
                markdown = false,
            },
            suggestion = {
                enabled = true,
                auto_trigger = false,
                keymap = {
                    accept = "<m-y>",
                    accept_word = "<m-i>",
                    accept_line = false,
                    next = "<m-]>",
                    prev = "<m-[>",
                    dismiss = "<c-]>",
                }
            },
            nes = {
                enabled = false,
                auto_trigger = false,
                keymap = {
                    accept_and_goto = "<m-y>",
                    accept = false,
                    dismiss = "<c-]>",
                }
            },
        },
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
            display = {
                chat = {
                    window = {
                        opts = {
                            number = false,
                            relativenumber = false
                        }
                    }
                },
                diff = {
                    -- I really want to use this, but it just feels like it gets
                    -- in the way :'(
                    enabled = false,
                    provider = "default",
                    opts = { "algorithm:patience" }
                }
            }
        },
    },
}
