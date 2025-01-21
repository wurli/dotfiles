vim.opt_local.filetype = "markdown"

-- Annoyingly, vim's default quarto ftplugin does something which
-- stops a simple `vim.bo.indentexpr = ""` working
vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("quarto-indent", {}),
    callback = function() vim.bo.indentexpr = "" end
})

