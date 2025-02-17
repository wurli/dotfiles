local jobpane = { _buf = -1, _win = -1, jobs = {} }

function jobpane:has_buf()
    return vim.api.nvim_buf_is_valid(self._buf)
end

function jobpane:is_open()
    return vim.api.nvim_win_is_valid(self._win)
end

function jobpane:buf()
    if not self:has_buf() then
        self._buf = vim.api.nvim_create_buf(false, true)
        vim.bo[self._buf].modifiable = false
        pcall(vim.api.nvim_buf_set_name, self._buf, "Jobs")
    end
    return self._buf
end

function jobpane:open()
    if not self:is_open() then
        self._win = vim.api.nvim_open_win(self:buf(), false, {
            width = 40,
            split = "right"
        })
        vim.wo[self._win].number = false
        vim.wo[self._win].relativenumber = false
        vim.wo[self._win].fillchars = "eob: "
    end
    return self
end

function jobpane:close()
    if jobpane:is_open() then vim.api.nvim_win_hide(self._win) end
    return self
end

function jobpane:toggle()
    return self:is_open() and self:close() or self:open()
end

function jobpane:send(lines)
    vim.bo[self:buf()].modifiable = true
    -- vim.bo[self:buf()].filetype = "markdown"
    vim.api.nvim_buf_set_text(self:buf(), -1, -1, -1, -1, lines)
    vim.bo[self:buf()].modifiable = false

    if self:is_open() then
        local line = vim.api.nvim_win_call(self._win, function() return vim.fn.line("$") end)
        vim.api.nvim_win_set_cursor(self._win, { line, 0 })
    end
    return self
end

local job = { channel = -1, active = true }

function job:name()
    return self._name or self.command
end

function job:start()
    jobpane:send({ "", "## Starting " .. self:name(), "" })

    self.channel = vim.fn.jobstart(self.command, {
        on_stdout = function(_, data, _) jobpane:send(data) end,
        on_exit = function() self.active = false end,
    })

    return self
end

function job:new(cmd, name, id)
    local out = setmetatable({ command = cmd, _name = name, id = id }, self)
    self.__index = self
    return out
end

function jobpane:run(cmd, name)
    local id = #self.jobs + 1
    self.jobs[id] = job:new(cmd, name, id):start()
    return self.jobs[id]
end

return jobpane
