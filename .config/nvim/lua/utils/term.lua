M = { terminals = {} }

M.make_toggler = function(cmd, name, opts)
    M.terminals[name] = {
        buf = -1,
        win = -1,
        channel = -1,
        send = function(self, lines)
            table.insert(lines, "")
            -- To turn on autoscroll
            vim.api.nvim_buf_call(self.buf, function()
                vim.fn.cursor(vim.fn.line("$"), 0)
            end)
            vim.fn.chansend(self.channel, lines)
        end,
        exists = function(self)
            return vim.api.nvim_buf_is_valid(self.buf)
        end
    }

    return function()
        for open_term, info in pairs(M.terminals or {}) do
            if vim.api.nvim_win_is_valid(info.win) then
                vim.api.nvim_win_hide(info.win)
                if open_term == name then return end
            end
        end

        local initial_win = vim.api.nvim_get_current_win()
        local t = M.terminals[name]

        t.buf = vim.api.nvim_buf_is_valid(t.buf) and t.buf or vim.api.nvim_create_buf(false, true)
        local ok, win = pcall(vim.api.nvim_open_win, t.buf, true, { split = "right" })
        t.win = ok and win or vim.api.nvim_get_current_win()

        if vim.bo[t.buf].buftype ~= "terminal" then
            local cmd1 = type(cmd) == "function" and cmd() or cmd
            t.channel = vim.fn.termopen(
                cmd1 or vim.o.shell,
                vim.tbl_extend("force", { detach = 1 }, opts or {})
            )
            if name then pcall(vim.cmd.file, name) end
        end

        vim.fn.cursor(vim.fn.line("$"), 0)
        vim.fn.win_gotoid(initial_win)
    end
end

return M

