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

        if vim.fs.basename(file) ~= vim.fs.basename(vim.api.nvim_buf_get_name(0)) then
            vim.cmd.edit(file)
        end
    end,
    { desc = "Go to (notebook) definition" }
)
