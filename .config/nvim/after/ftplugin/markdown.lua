vim.opt_local.textwidth = 80

vim.keymap.set(
    "i", "``",
    function()
        local row, col   = vim.fn.line("."), vim.fn.col(".") - 1
        local line       = vim.fn.getline(row)

        local chunkstart = line .. "``` "
        local chunkend   = (" "):rep(col) .. "```"

        vim.api.nvim_buf_set_lines(
            0, row - 1, row, false,
            { chunkstart, chunkend }
        )

        vim.api.nvim_win_set_cursor(0, { row, col + 4 })
    end,
    {
        buffer = 0,
        desc = "Markdown code chunk insert"
    }
)

