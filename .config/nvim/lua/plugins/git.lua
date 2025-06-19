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
                kind = "floating",
                floating = {
                    width = 0.85,
                    height = 0.85
                },
                integrations = {
                    telescope = true
                },
                telescope_sorter = function()
                    return require("telescope.sorters").get_fzy_sorter()
                end
            })
            vim.keymap.set("n", "<leader>lg", "<cmd>Neogit<cr>")

            -- `NeogitCommitComplete`
            vim.api.nvim_create_autocmd("User", {
                pattern = "NeogitCommitComplete",
                callback = vim.cmd.tabprevious
            })
        end
    },
    -- {
    --     -- Not strictly necessary but does make things nicer overall
    --     "echasnovski/mini.diff",
    --     opts = {
    --         view = {
    --             style = "sign",
    --             signs = { add = "┃", change = "┇", delete = "║" }
    --         },
    --         mappings = {
    --             -- Apply hunks inside a visual/operator region
    --             apply = "gh",
    --
    --             -- Reset hunks inside a visual/operator region
    --             reset = "gH",
    --
    --             -- Hunk range textobject to be used inside operator
    --             -- Works also in Visual mode if mapping differs from apply and reset
    --             textobject = "gh",
    --
    --             -- Go to hunk range in corresponding direction
    --             goto_first = "[H",
    --             goto_prev = "[h",
    --             goto_next = "]h",
    --             goto_last = "]H",
    --         },
    --         options = {
    --             algorithm = "patience",
    --         }
    --     },
    -- },
    {
        "lewis6991/gitsigns.nvim",
        cond = not vim.g.vscode,
        config = function()
            require("gitsigns").setup {
                diff_opts = {
                    algorithm = "patience",
                },
                signs = {
                    add          = { text = "┃" },
                    change       = { text = "┇" },
                    delete       = { text = "║" },
                    topdelete    = { text = "║" },
                    changedelete = { text = "║" },
                    untracked    = { text = "·" },
                },
                signs_staged = {
                    add          = { text = "┃" },
                    change       = { text = "┇" },
                    delete       = { text = "║" },
                    topdelete    = { text = "║" },
                    changedelete = { text = "║" },
                    untracked    = { text = "·" },
                },
                on_attach = function(bufnr)
                    local gitsigns = require("gitsigns")

                    local function map(mode, l, r, desc)
                        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
                    end

                    -- Actions
                    -- map("v", "<leader>hs", function() gitsigns.stage_hunk {vim.fn.line("."), vim.fn.line("v")} end)
                    -- map("v", "<leader>hr", function() gitsigns.reset_hunk {vim.fn.line("."), vim.fn.line("v")} end)
                    -- map("n", "<leader>hu", gitsigns.undo_stage_hunk)
                    map("n", "<leader>hp", gitsigns.preview_hunk,                             "Git Preview Hunk")
                    map("n", "<leader>hb", function() gitsigns.blame_line{ full = true } end, "Git Blame Line")
                    map("n", "<leader>hB", gitsigns.blame,                                    "Git Blame")
                    map("n", "<leader>tb", gitsigns.toggle_current_line_blame,                "Git Toggle Blame")
                    map("n", "<leader>hd", gitsigns.diffthis,                                 "Git Diff Against Index")
                    map("n", "<leader>hD", function() gitsigns.diffthis("~") end,             "Git Diff Against HEAD")
                    map("n", "<leader>td", gitsigns.preview_hunk_inline,                      "Git Preview Hunk")
                    map("n", "<leader>hr", gitsigns.reset_hunk,                               "Git Reset Hunk")
                    map("n", "<leader>hs", gitsigns.stage_hunk,                               "Git Stage Hunk")
                    map("n", "<leader>hr", gitsigns.reset_hunk,                               "Git Reset Hunk")
                    map("n", "<leader>hS", gitsigns.stage_buffer,                             "Git Stage Buffer")
                    map("n", "<leader>hR", gitsigns.reset_buffer,                             "Git Reset Buffer")

                    -- Text object
                    map({"o", "x"}, "ih", ":<C-U>Gitsigns select_hunk<CR>")
                end
            }
        end
    },
}
