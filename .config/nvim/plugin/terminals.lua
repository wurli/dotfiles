local term = require("utils.term")

-------------------
-- Regular shell --
-------------------
vim.keymap.set("n", "<leader><leader>t", term.make_toggler(nil, "terminal"), { desc = "Open terminal" })

-------------
-- IPython --
-------------
local has_ipython = function()
	local cmd = { "uv", "pip", "show", "ipython" }
	local res = vim.system(cmd, { text = true }):wait()
	return res.code == 0
end

local make_python_cmd = function()
	local venv = vim.fs.find("activate", { path = ".venv/bin" })[1]
	local source_venv_cmd = venv and "source " .. venv .. " && " or ""
	local run_python_cmd = has_ipython() and "ipython --no-autoindent" or "python3"
	return source_venv_cmd .. run_python_cmd
end

local make_python_opts = function()
	local opts = { env = {} }
	if vim.uv.fs_stat("pyproject.toml") then
		local lines = vim.fn.readfile("pyproject.toml")
		for _, l in ipairs(lines) do
			-- NOTE: This parsing really sucks a lot - e.g. it only pulls out
			-- one path where there may be multiple (spread over several
			-- lines). Works well enough for my use, for now.
			-- Could maybe use something like
			-- https://github.com/woodruffw/toml2json in the future.
			local pythonpath = l:match([====[src%s*=%s*%["([^"]*)"]====])
			if pythonpath then
				opts.env.PYTHONPATH = pythonpath
				vim.cmd.echo(('"Settng $PYTHONPATH to %s using pyproject.toml"'):format(pythonpath))
				break
			end
		end
	end

	-- Seems to cause issues if env is empty
	if vim.tbl_isempty(opts.env) then
		opts.env = nil
	end

	return opts
end

vim.keymap.set(
	"n",
	"<leader><leader>p",
	term.make_toggler(make_python_cmd, "python", make_python_opts),
	{ desc = "Start IPython" }
)

-----------------
-- Claude Code --
-----------------
vim.keymap.set(
	"n",
	"<leader><leader>c",
	term.make_toggler("claude --allow-dangerously-skip-permissions"),
	{ desc = "Start Claude Code" }
)

-- -------
-- -- R --
-- -------
-- vim.keymap.set(
--     "n", "<leader><leader>r",
--     term.make_toggler("R --no-save --no-restore", "R", {
--         env = {
--             R_CRAN_WEB = "http://cran.rstudio.com/",
--             R_REPOSITORIES = "NULL"
--         }
--     }),
--     { desc = "Start R" }
-- )

-- ----------
-- -- Jobs --
-- ----------
-- vim.keymap.set(
--     "n", "<leader><leader>j",
--     function()
--         require("utils.jobs"):toggle()
--     end,
--     { desc = "Open jobs pane" }
-- )
