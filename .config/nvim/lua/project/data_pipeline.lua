vim.keymap.set(
    "n",
    "<leader>gd",
    function()
        local url = vim.ui._get_urls()[1]

        if not url then
            vim.lsp.buf.definition({})
            return
        end

        local file = vim.fs.find(url .. ".py", {})[1]

        if not file then
            vim.lsp.buf.definition({})
            return
        end

        vim.cmd.edit(file)
    end,
    { desc = "Go to (notebook) definition" }
)
