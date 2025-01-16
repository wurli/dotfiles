vim.opt_local.filetype = "markdown"

-- I think the vim runtime does something unusual for quarto files, since
-- just setting indentexpr using vim.opt in this file doesn't work; the setting
-- just gets overwritten whenever you open a quarto file. Setting an
-- autocommand seems to be the only reliable way to make this option
-- persistent.
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*.qmd",
    group = vim.api.nvim_create_augroup("quarto-custom", {}),
    callback = function()
        -- Defined in after/markdown.lua
        vim.opt.indentexpr = "v:lua._G.markdown_indent()"
    end
})

