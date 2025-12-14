if vim.g.vscode then
	return
end

vim.opt_local.signcolumn = "yes"

local term = require("utils.term").terminals.Python
local fn = vim.fn

-- --- NOTE -------------------------
-- ty now formats hover docs as md
-- ----------------------------------
-- The ty language server records python documentation as plan text. Usually,
-- however, the documentation is written in reStructuredText (rst) format.
-- It's not really possible to hook into the built-in vim.lsp.buf.hover() to
-- update the hover contents, but it's possible to use some heuristics to figure
-- out if a new window is a float, then update 'text' code blocks to 'rst'.
--
-- This is (hopefully) a temporary workaround while ty is still in alpha.
vim.api.nvim_create_autocmd("BufWinEnter", {
	group = vim.api.nvim_create_augroup("python-float-ns", { clear = true }),
	callback = function(e)
		if not vim.bo[e.buf].filetype == "markdown" then
			return
		end
		if not vim.bo[e.buf].modifiable then
			return
		end

		local win = vim.fn.bufwinid(e.buf)
		if not vim.api.nvim_win_is_valid(win) then
			return
		end

		local is_floating_window = vim.api.nvim_win_get_config(win).relative ~= ""
		if not is_floating_window then
			return
		end

		local lines = vim.api.nvim_buf_get_lines(e.buf, 0, -1, false)
		local needs_update = false

		-- for lnum, line in ipairs(lines) do
		-- 	if line:match("```%s*text") then
		-- 		needs_update = true
		-- 		lines[lnum] = line:gsub("```%s*text", "``` rst")
		-- 		break
		-- 	end
		-- end
		for lnum, line in ipairs(lines) do
			needs_update = true
			-- Strange seemingly VSCode-specific markdown escapes
			lines[lnum] = line:gsub("\\([_%[%]])", "%1"):gsub("&nbsp;", " ")
		end

		if needs_update then
			vim.api.nvim_buf_set_lines(e.buf, 0, -1, false, lines)
		end
	end,
})

local function get_statement_range(pos)
	local row, col = fn.line(".") - 1, fn.col(".") - 1
	local ok, node = pcall(vim.treesitter.get_node, { pos = { row, col } })
	if not ok or not node then
		return
	end

	local is_skipping_blanks = false
	local n_iterations = 0
	while node:type() == "comment" or node:type() == "module" do
		n_iterations = n_iterations + 1
		if n_iterations > 100 then
			print("Quitting: exceeded 100 iterations when ascending treesitter tree")
			return
		end
		is_skipping_blanks = true
		row = row + 1
		ok, node = pcall(vim.treesitter.get_node, { pos = { row, 0 } })
		if not ok or not node then
			return
		end
	end

	if is_skipping_blanks then
		fn.cursor(row, 0)
		return
	end

	local top_level_nodes = {
		"assert_statement",
		"class_definition",
		"decorated_definition",
		"delete_statement",
		"expression_statement",
		"for_statement",
		"function_definition",
		"global_statement",
		"if_statement",
		"import_from_statement",
		"import_statement",
		"nonlocal_statement",
		"try_statement",
		"while_statement",
		"with_statement",
	}

	local id = node:id()

	while true do
		if vim.list_contains(top_level_nodes, node:type()) then
			break
		end
		node = node:parent()
		if not node then
			return
		end
		local parent_id = node:id()
		if id == parent_id then
			return
		end
		id = parent_id
	end

	return { node:range() }
end

local send_to_python = function(x)
	x = vim.tbl_filter(function(l)
		return not l:match("^%s*$")
	end, x)
	-- If the last line has indent, then we need to append *2* trailing lines
	-- in order to send the statement to IPython
	if x[#x]:match("^%s") then
		table.insert(x, "")
	end
	term:send(x)
end

vim.keymap.set("n", "<Enter>", function()
	if not term:exists() then
		return
	end
	local rng = get_statement_range()

	if not rng then
		fn.cursor(fn.nextnonblank(fn.line(".") + 1), 0)
		return
	end

	send_to_python(vim.api.nvim_buf_get_text(0, rng[1], rng[2], rng[3], rng[4], {}))
	fn.cursor(fn.nextnonblank(math.min(rng[3] + 2, fn.line("$"))), 0)
end, { buffer = 0, desc = "Send python code to terminal" })

vim.keymap.set("v", "<Enter>", function()
	if not term:exists() then
		return
	end
	local start, stop = fn.getpos("v"), fn.getpos(".")

	send_to_python(fn.getregion(start, stop, { type = fn.mode() }))
	local escape_keycode = "\27"
	fn.feedkeys(escape_keycode, "L")
	fn.cursor(math.min(fn.nextnonblank(stop[2] + 1), stop[2]), 0)
end)

vim.keymap.set({ "n", "v" }, "<leader><Enter>", function()
	if not term:exists() then
		return
	end
	send_to_python(fn.getline("^", "$"))
end)

vim.keymap.set({ "n", "v" }, "<leader><leader><Enter>", function()
	if not term:exists() then
		return
	end
	send_to_python(vim.fn.getline("^", "."))
end)

vim.keymap.set({ "n", "v", "i" }, "<c-Enter>", function()
	local venv = vim.fs.find("python", { path = ".venv/bin" })[1]
	local python = venv and venv or "python"

	local file = vim.api.nvim_buf_get_name(0)
	local wd = vim.fn.getcwd():gsub("%p", "%%%1") .. "%/"
	local file_rel = file:gsub(wd, "")

	local mod = file_rel:gsub("/", "."):gsub("%.py$", "")

	local cmd = python .. " -m " .. mod

	require("utils.jobs"):open()
	require("utils.jobs"):run(cmd)
end)
