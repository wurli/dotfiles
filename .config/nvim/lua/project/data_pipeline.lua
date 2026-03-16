vim.keymap.set({ "n", "v" }, "<leader>gd", function()
	local url = vim.ui._get_urls()[1]

	if not url then
		vim.lsp.buf.definition({})
		return
	end

	local file = vim.fs.find(url .. ".py", {})[1]

	if not file then
		vim.lsp.buf.definition({})
		return
	end

	if vim.fs.basename(file) ~= vim.fs.basename(vim.api.nvim_buf_get_name(0)) then
		vim.cmd.edit(file)
	end
end, { desc = "Go to (notebook) definition" })

local get_yaml_task = function()
	local lines = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
	local path = vim.fn.expand("%")
	local cwd = vim.fn.getcwd() .. "/"

	if path:find(cwd, 1, true) == 1 then
		path = path:sub(#cwd + 1)
	end

	if path:sub(-3) == ".py" then
		path = path:sub(1, -4)
	end

	local basename = vim.fs.basename(path)

	local deps = {}
	for tbl in lines:gmatch([===[tbl_[a-zA-Z_]*%(%s*['"][a-zA-Z_]+['"]]===]) do
		if
			vim.startswith(tbl, "tbl_stg")
			or vim.startswith(tbl, "tbl_processed")
			or vim.startswith(tbl, "tbl_mart")
			or vim.startswith(tbl, "tbl_int")
			or vim.startswith(tbl, "tbl_log")
			or vim.startswith(tbl, "tbl_checks")
		then
			tbl = tbl:match([===[['"]([a-zA-Z_]+)['"]]===])
			if tbl then
				deps[tbl] = true
			end
		end
	end
	deps = vim.tbl_keys(deps)
	table.sort(deps)

	local yaml = { "- task_key: " .. basename }

	if #deps > 0 then
		table.insert(yaml, "  depends_on:")
		for _, dep in ipairs(deps) do
			table.insert(yaml, "    - task_key: " .. dep)
		end
	end

	for _, line in ipairs({
		"  notebook_task:",
		"    notebook_path: ${workspace.file_path}/" .. path,
		"    source: WORKSPACE",
	}) do
		table.insert(yaml, line)
	end

	for i, line in ipairs(yaml) do
		yaml[i] = "        " .. line
	end

	table.insert(yaml, "")

	vim.fn.setreg("+", yaml)
end

vim.keymap.set("n", "<leader>yt", get_yaml_task, { desc = "Get YAML task" })
