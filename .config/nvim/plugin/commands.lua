vim.api.nvim_create_user_command("Dump", function(x)
	vim.cmd(string.format("put =execute('%s')", x.args))
end, {
	nargs = "+",
	desc = "Dump the output of a command at the cursor position",
})

vim.api.nvim_create_user_command("LspFormat", function(x)
	vim.lsp.buf.format({
		name = x.fargs[1],
		range = x.range == 0 and nil or {
			["start"] = { x.line1, 0 },
			["end"] = { x.line2, 0 },
		},
	})
end, { nargs = "?", range = "%", desc = "LSP format" })

local go_to_relative_file = function(n, relative_to)
	return function()
		local this_dir = vim.fs.dirname(vim.fs.normalize(vim.fn.expand("%:p")))

		local files = {}
		for file, type in vim.fs.dir(this_dir) do
			if type == "file" then
				table.insert(files, file)
			end
		end

		local this_file = relative_to or vim.fs.basename(vim.fn.bufname())
		local this_file_pos = -1

		for i, file in ipairs(files) do
			if file == this_file then
				this_file_pos = i
			end
		end

		if this_file_pos == -1 then
			error(("File `%s` not found in current directory"):format(this_file))
		end

		local new_file = files[((this_file_pos + n - 1) % #files) + 1]

		if not new_file then
			error(("Could not find file relative to `%s`"):format(this_file))
		end

		vim.cmd("edit " .. this_dir .. "/" .. new_file)
	end
end

vim.api.nvim_create_user_command("FileNext", go_to_relative_file(1), {})
vim.api.nvim_create_user_command("FilePrev", go_to_relative_file(-1), {})

vim.api.nvim_create_user_command("RuffFixAll", function()
	vim.lsp.buf.code_action({
		context = { only = { "source.fixAll.ruff" } },
		apply = true,
	})
end, { desc = "Ruff fix all" })

vim.api.nvim_create_user_command("RuffOrganizeImports", function()
	vim.lsp.buf.code_action({
		context = { only = { "source.organizeImports.ruff" } },
		apply = true,
	})
end, { desc = "Ruff organize imports" })

vim.api.nvim_create_user_command("Positron", function()
	vim.system({
		"positron",
		"--goto",
		vim.fn.expand("%:p") .. ":" .. vim.api.nvim_win_get_cursor(0)[1],
		vim.fn.getcwd(),
	})
end, { desc = "Open current file in Positron" })

local open_daily_note = function(create, now)
	local is_notes = vim.fn.getcwd():find("notes") ~= nil
	local is_work = vim.fn.getenv("USER") == "JACOB.SCOTT1"
	local default_dir = vim.fn.expand("~/Repos/") .. (is_work and "work-notes" or "personal-notes")
	local notes_dir = is_notes and vim.fn.getcwd() or default_dir

	local time = now or vim.fn.localtime()
	-- Date included in 2 formats for easier fuzzy finding
	local filename = vim.fn.strftime("%Y-%m-%d %a, %d %b.md", time or vim.fn.localtime())
	local path = notes_dir .. "/" .. filename

	if vim.fn.findfile(path) == "" and create then
		local file_io = io.open(path, "w")

		if file_io then
			print(("Creating new file `%s`"):format(filename))
			file_io:write(vim.fn.strftime("# Notes on %A, %d %B\n\n", time))
			file_io:close()
		end
	end

	if vim.fn.findfile(path) ~= "" then
		vim.cmd("edit " .. path)
	else
		print(("File `%s` does not exist."):format(path))
	end
end

vim.api.nvim_create_user_command("Note", function(opts)
	local n = tonumber(opts.fargs[1]) or 0
	open_daily_note(n == 0, vim.fn.localtime() + n * 24 * 60 * 60)
end, { nargs = "?", desc = "Open daily note. Pass -1 for yesterday's note" })
