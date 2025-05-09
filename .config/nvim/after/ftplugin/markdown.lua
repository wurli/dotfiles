vim.opt_local.textwidth = 80
vim.opt_local.formatoptions:remove("l")

local ls = require("luasnip")

vim.keymap.set(
    "i", "``",
    function()
        ls.snip_expand(vim.tbl_filter(
            function(x) return x.name == "codeblock-static" end,
            ls.get_snippets("markdown")
        )[1])
    end,
    { buffer = 0, desc = "Markdown code static chunk insert" }
)

