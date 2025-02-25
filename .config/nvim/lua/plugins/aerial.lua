return {
    'stevearc/aerial.nvim',
    cond = not vim.g.vscode,
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons"
    },
    config = function()
        require("aerial").setup({
            layout = {
                max_width = { 50, 0.2 },
                min_width = 30,
                default_direction = "right"
            },
            on_attach = function(bufnr)
                -- Jump forwards/backwards with '{' and '}'
                vim.keymap.set("n", "<leader>{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
                vim.keymap.set("n", "<leader>}", "<cmd>AerialNext<CR>", { buffer = bufnr })
            end,
            get_highlight = function(symbol, _, _)
                return symbol.kind == "String" and "Comment" or nil
            end
        })
        vim.keymap.set("n", "<leader>at", "<cmd>AerialToggle<CR>")
    end
}
