return {
    {
        "tpope/vim-fugitive",
        cond = not vim.g.vscode,
    },
    {
        "NeogitOrg/neogit",
        cond = not vim.g.vscode,
        dependencies = {
            "nvim-lua/plenary.nvim",         -- required
            "nvim-telescope/telescope.nvim",
            {
                "sindrets/diffview.nvim",        -- optional - Diff integration
                opts = { enhanced_diff_hl = true },
            },
        },
        config = function()
            require("neogit").setup({
                integrations = {
                    telescope = true
                },
                telescope_sorter = function()
                    return require("telescope.sorters").get_fzy_sorter()
                end
            })
            vim.keymap.set("n", "<leader>lg", "<cmd>Neogit<cr>")
        end
    },
    {
        "lewis6991/gitsigns.nvim",
        cond = not vim.g.vscode,
        config = function()
            require('gitsigns').setup {
                on_attach = function(bufnr)
                    local gitsigns = require('gitsigns')

                    local function map(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end

                    -- Actions
                    -- map('n', '<leader>hs', gitsigns.stage_hunk)
                    -- map('n', '<leader>hr', gitsigns.reset_hunk)
                    -- map('v', '<leader>hs', function() gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
                    -- map('v', '<leader>hr', function() gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
                    -- map('n', '<leader>hS', gitsigns.stage_buffer)
                    -- map('n', '<leader>hu', gitsigns.undo_stage_hunk)
                    -- map('n', '<leader>hR', gitsigns.reset_buffer)
                    map('n', '<leader>hp', gitsigns.preview_hunk)
                    map('n', '<leader>hb', function() gitsigns.blame_line{ full = true } end)
                    map('n', '<leader>hB', gitsigns.blame)
                    map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
                    map('n', '<leader>hd', gitsigns.diffthis)
                    map('n', '<leader>hD', function() gitsigns.diffthis('~') end)
                    map('n', '<leader>td', gitsigns.preview_hunk_inline)

                    -- Text object
                    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
                end
            }
        end
    },
}
