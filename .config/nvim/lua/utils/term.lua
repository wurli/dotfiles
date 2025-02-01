M = { info = {} }

M.make_toggler = function(init, name)
    local buf, win = -1, -1
    if type(init) == "function" then init = init() end

    return function()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_hide(win)
        else
            buf = vim.api.nvim_buf_is_valid(buf) and buf or vim.api.nvim_create_buf(false, true)
            win = vim.api.nvim_open_win(buf, true, { split = "right" })

            if vim.bo[buf].buftype ~= "terminal" then
                vim.cmd.terminal()
                -- if init then vim.fn.chansend(vim.bo.channel, init) end
                if init then vim.api.nvim_chan_send(vim.bo.channel, init) end
                if name then pcall(vim.cmd.file, name) end
            end

            M.info[name] = { buf = buf, win = win, channel = vim.bo.channel }
        end
    end
end

return M
