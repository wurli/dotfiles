M = { terminals = {} }

M.make_toggler = function(cmd, name)
    M.terminals[name] = {
        buf = -1,
        win = -1,
        channel = -1,
    }

    return function()
        for open_term, info in pairs(M.terminals) do
            if vim.api.nvim_win_is_valid(info.win) then
                vim.api.nvim_win_hide(info.win)
                if open_term == name then return end
            end
        end

        local t = M.terminals[name]

        t.buf = vim.api.nvim_buf_is_valid(t.buf) and t.buf or vim.api.nvim_create_buf(false, true)
        t.win = vim.api.nvim_open_win(t.buf, true, { split = "right" })

        if vim.bo[t.buf].buftype ~= "terminal" then
            local cmd1 = type(cmd) == "function" and cmd() or cmd
            t.channel = vim.fn.termopen(cmd1 or vim.o.shell)
            if name then pcall(vim.cmd.file, name) end
        end

        vim.fn.cursor(vim.fn.line("$"), 0)
    end
end

return M

