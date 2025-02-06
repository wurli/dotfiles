vim.api.nvim_create_user_command(
    "Dump",
    function(x)
        local cmd = ("put =execute('%s')"):format(x.args)
        vim.cmd(cmd)
    end,
    {
        nargs = "+",
        desc = "Dump the output of a command at the cursor position"
    }
)

vim.api.nvim_create_user_command(
    "Tab",
    function()
        local win = vim.api.nvim_get_current_win()
        vim.cmd [[ tab split ]]
        vim.api.nvim_win_close(win, true)
    end,
    { desc = "Move current window to its own tab" }
)

vim.api.nvim_create_user_command(
    "LspFormat",
    function(x)
        vim.lsp.buf.format({
            name = x.fargs[1],
            range = x.range == 0 and nil or {
                ["start"] = { x.line1, 0 },
                ["end"] = { x.line2, 0 }
            }
        })
    end,
    { nargs = "?", range = "%", desc = "LSP format" }
)


