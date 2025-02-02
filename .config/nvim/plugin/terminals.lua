local term = require("utils.term")
local toggleterm = require("toggleterm.terminal")

---@param t Terminal
local smart_toggle = function(t, focus)
    local initial_win  = vim.api.nvim_get_current_win()
    local already_open = t:is_open()

    vim.tbl_map(function(x) x:close() end, toggleterm.get_all())

    if not already_open then
        t:open()
        if not focus then vim.fn.win_gotoid(initial_win) end
    end
end

-------------------
-- Regular shell --
-------------------
vim.keymap.set(
    "n", "<leader><leader>t",
    term.make_toggler(nil, "Terminal"),
    { desc = "Open terminal" }
)

-- vim.fn.jobstart({ "ipython" }, { pty = true })

-- vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), true, { split = "right" })
-- vim.fn.termopen("ipython")

-------------
-- IPython --
-------------
local venv        = vim.fs.find("activate", { path = ".venv/bin" })[1]
local prefix      = venv and "source " .. venv .. " && " or ""
local cmd         = prefix .. "ipython --no-autoindent"
local python_repl = toggleterm.Terminal:new({
    cmd = cmd,
    direction = "vertical",
    display_name = "IPython"
})

vim.keymap.set(
    "n", "<leader><leader>p",
    function() smart_toggle(python_repl) end,
    { desc = "Toggle IPython REPL" }
)

-------
-- R --
-------
local r_repl = toggleterm.Terminal:new({
    cmd = "R",
    direction = "vertical",
    display_name = "R"
})

vim.keymap.set(
    "n", "<leader><leader>r",
    function() smart_toggle(r_repl) end,
    { desc = "Toggle R REPL" }
)

return M
