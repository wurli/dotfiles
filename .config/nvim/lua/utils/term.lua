local Terms = { terminals = {} }

---@param cmd? string|string[]|fun(): string|string[]
---@param name? string May be `nil` if `cmd` is a string.
---@param opts? table|fun(): table Addition options passeed to `jobstart()`
Terms.make_toggler = function(cmd, name, opts)
	if name == nil then
		if type(cmd) == "string" then
			name = cmd
		else
			error("Name must be provided if cmd is not a string")
		end
	end

	---@param args string[]?
	local toggle = function(args)
		for open_term, info in pairs(Terms.terminals or {}) do
			if vim.api.nvim_win_is_valid(info.win) and vim.api.nvim_win_get_buf(info.win) == info.buf then
				vim.api.nvim_win_hide(info.win)
				if open_term == name then
					return
				end
			end
		end

		local initial_win = vim.api.nvim_get_current_win()
		local t = Terms.terminals[name]

		t.buf = vim.api.nvim_buf_is_valid(t.buf) and t.buf or vim.api.nvim_create_buf(false, true)
		local ok, win = pcall(vim.api.nvim_open_win, t.buf, true, { split = "right" })
		t.win = ok and win or vim.api.nvim_get_current_win()

		if vim.bo[t.buf].buftype ~= "terminal" then
			if type(cmd) == "function" then
				cmd = cmd()
			end
			local cmd1 = type(cmd) == "table" and cmd or type(cmd) == "string" and cmd or { vim.o.shell }

			if type(cmd1) == "string" and args then
				for _, arg in ipairs(args) do
					cmd1 = cmd1 .. " " .. arg
				end
			end

			local opts1 = type(opts) == "function" and opts() or opts
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

	Terms.terminals[name] = {
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
		end,
		toggle = toggle,
	}

	return toggle
end

local terms_from_prefix = function(prefix)
	local matched_terms = {}
	for _, term_name in ipairs(vim.tbl_keys(Terms.terminals or {})) do
		if vim.startswith(term_name, prefix) then
			table.insert(matched_terms, term_name)
		end
	end
	return matched_terms
end

vim.api.nvim_create_user_command("T", function(ctx)
	local selected_term = terms_from_prefix(ctx.fargs[1])
	if #selected_term > 1 then
		print(("Multiple terminals found with prefix '%s': %s"):format(ctx.fargs[1], table.concat(selected_term, ", ")))
		return
	elseif #selected_term == 0 then
		print(("No terminal found with name '%s'"):format(ctx.fargs[1]))
		return
	end
	local term = Terms.terminals[selected_term[1]]
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

return Terms
