-- To anyone reading this code on GitHub, I strongly recommend not using this
-- for your own purposes. The code is very much a "quick and dirty" solution to
-- my own needs, and is not intended to be a general-purpose terminal manager.
--
-- TODO: at some point rewrite to be a bit more extensible.

local term_hl_ns = vim.api.nvim_create_namespace("term_highlights")
vim.api.nvim_set_hl(term_hl_ns, "Normal", { link = "NormalFloat" })

---@class Terms
---@field terminals table<string, CustomTerm>
local terms = { terminals = {} }

---@class MakeTogglerOpts
---@field name? string Name of the terminal. Required if `cmd` is not a string.
---@field job_opts? table | fun() Options passed to `jobstart()`
---@field init? fun() Optional function called when the terminal is first created

---@param cmd? string|string[]|fun(): string|string[]
---@param opts? MakeTogglerOpts
terms.make_toggler = function(cmd, opts)
	opts = opts or {}
	local name = opts.name
	local job_opts = opts.job_opts

	if name == nil then
		if type(cmd) == "string" then
			name = cmd
		else
			error("Name must be provided if cmd is not a string")
		end
	end

	---@param args string[]? Additional args passed to the shell command on startup
	local toggle = function(args)
		for open_term, info in pairs(terms.terminals or {}) do
			if vim.api.nvim_win_is_valid(info.win) and vim.api.nvim_win_get_buf(info.win) == info.buf then
				vim.api.nvim_win_hide(info.win)
				if open_term == name then
					return
				end
			end
		end

		local initial_win = vim.api.nvim_get_current_win()
		local t = terms.terminals[name]

		if not vim.api.nvim_buf_is_valid(t.buf) then
			t.buf = vim.api.nvim_create_buf(false, true)

			local make_ns_setter = function(ns)
				return function()
					vim.api.nvim_win_set_hl_ns(0, ns)
				end
			end

			vim.api.nvim_create_autocmd("BufWinEnter", { buffer = t.buf, callback = make_ns_setter(term_hl_ns) })
			vim.api.nvim_create_autocmd("BufWinLeave", { buffer = t.buf, callback = make_ns_setter(0) })
		end

		local ok, win = pcall(vim.api.nvim_open_win, t.buf, true, { split = "right" })
		t.win = ok and win or vim.api.nvim_get_current_win()

		if vim.bo[t.buf].buftype ~= "terminal" then
			if opts.init then
				opts.init()
			end

			if type(cmd) == "function" then
				cmd = cmd()
			end
			local cmd1 = type(cmd) == "table" and cmd or type(cmd) == "string" and cmd or { vim.o.shell }

			if type(cmd1) == "string" and args then
				for _, arg in ipairs(args) do
					cmd1 = cmd1 .. " " .. arg
				end
			end

			local opts1 = type(job_opts) == "function" and job_opts() or job_opts
			t.channel = vim.fn.jobstart(
				cmd1,
				vim.tbl_extend("force", {
					detach = 1,
					term = true,
				}, opts1 or {})
			)
			if name then
				pcall(vim.cmd.file, name)
			end
		end

		vim.fn.cursor(vim.fn.line("$"), 0)
		vim.fn.win_gotoid(initial_win)
	end

	---@class CustomTerm
	terms.terminals[name] = {
		buf = -1,
		win = -1,
		channel = -1,
		send = function(self, lines)
			table.insert(lines, "")
			-- To turn on autoscroll
			vim.api.nvim_buf_call(self.buf, function()
				vim.fn.cursor(vim.fn.line("$"), 0)
			end)
			self:send_raw(lines)
		end,
		send_raw = function(self, text)
			vim.fn.chansend(self.channel, text)
		end,
		exists = function(self)
			return vim.api.nvim_buf_is_valid(self.buf)
		end,
		toggle = toggle,
	}

	return toggle
end

local terms_from_prefix = function(prefix)
	local matched_terms = {}
	for _, term_name in ipairs(vim.tbl_keys(terms.terminals or {})) do
		if vim.startswith(term_name, prefix) then
			table.insert(matched_terms, term_name)
		end
	end
	return matched_terms
end

vim.api.nvim_create_user_command("T", function(ctx)
	local term_name = terms_from_prefix(ctx.fargs[1])
	if #term_name > 1 then
		print(("Multiple terminals found with prefix '%s': %s"):format(ctx.fargs[1], table.concat(term_name, ", ")))
		return
	elseif #term_name == 0 then
		print(("No terminal found with name '%s'"):format(ctx.fargs[1]))
		return
	end
	local term = terms.terminals[term_name[1]]
	term.toggle(vim.list_slice(ctx.fargs, 2))
end, {
	nargs = "+",
	complete = function(arg_lead, cmdline)
		if #vim.split(cmdline, "%s+") > 2 then
			return {}
		end
		return terms_from_prefix(arg_lead)
	end,
	desc = "Toggle a terminal by name. Usage: :T <name> [args...]",
})

return terms
