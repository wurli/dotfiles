vim.opt_local.filetype = "markdown"

-- Annoyingly, vim's default quarto ftplugin does something which
-- stops a simple `vim.bo.indentexpr = ""` working
vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("quarto-indent", {}),
    pattern = "*.qmd",
    callback = function()
        vim.bo.indentexpr = "v:lua.require('contextindent').context_indent('')"
    end
})

local ls = require("luasnip")

vim.keymap.set(
    "i", "``",
    function()
        ls.snip_expand(vim.tbl_filter(
            function(x) return x.name == "codeblock-runnable" end,
            ls.get_snippets("markdown")
        )[1])
    end,
    { buffer = 0, desc = "Markdown runnable code chunk insert" }
)

