local term = require("utils.term")

-------------------
-- Regular shell --
-------------------
vim.keymap.set(
    "n", "<leader><leader>t",
    term.make_toggler(nil, "Terminal"),
    { desc = "Open terminal" }
)

-------------
-- IPython --
-------------
local make_python_cmd = function()
    local venv = vim.fs.find("activate", { path = ".venv/bin" })[1]
    local prefix = venv and "source " .. venv .. " && " or ""
    return prefix .. "ipython --no-autoindent"
end

vim.keymap.set(
    "n", "<leader><leader>p",
    term.make_toggler(make_python_cmd, "Python"),
    { desc = "Start IPython" }
)

-------
-- R --
-------
vim.keymap.set(
    "n", "<leader><leader>r",
    term.make_toggler("R --no-save --no-restore", "R", {
        env = {
            R_CRAN_WEB = "http://cran.rstudio.com/",
            R_REPOSITORIES = "NULL"
        }
    }),
    { desc = "Start R" }
)

