print("hello")
vim.keymap.set({ "n", "v" }, "<leader>y", function()
	vim.o.operatorfunc = "v:lua._G._bible_handle_curr_motion"
	return "g@"
end, {
	desc = "Yank Bible verse",
	expr = true,
})

---@param mode "line" | "block" | "char"
_G._bible_handle_curr_motion = function(mode)
	local cur_file = vim.api.nvim_buf_get_name(0)

	print("yo")

	if not cur_file:match("bible/") then
		print("not bible")
		return
	end

	local chapter = tonumber(vim.fs.basename(cur_file):match("^(%d+).md"))
	local book = vim.fs.basename(vim.fs.dirname(cur_file)):match("^%d%d (.+)$")

	local selection_start, selection_end = vim.fn.getpos("'["), vim.fn.getpos("']")
	local start_verse, end_verse = 1, 1

	for lnum, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
		local cur_verse = tonumber(line:match("^%d+"))
		if cur_verse then
			if lnum <= selection_start[2] then
				start_verse = cur_verse
			end
			if lnum <= selection_end[2] then
				end_verse = cur_verse
			end
		end
	end

	local ref = ""
	if start_verse == end_verse then
		ref = book .. " " .. chapter .. ":" .. start_verse
	else
		ref = book .. " " .. chapter .. ":" .. start_verse .. "-" .. end_verse
	end

	local text = vim.fn.getregion(selection_start, selection_end, {
		type = mode == "line" and "V" or mode == "block" and "" or mode == "char" and "v",
	})

	for i, line in ipairs(text) do
		text[i] = "> " .. line
	end

	table.insert(text, 1, ref)

	vim.fn.setreg("+", text)
end
