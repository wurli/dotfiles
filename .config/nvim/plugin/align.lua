---@see https://github.com/neovim/neovim/discussions/41626
local align_cursors = function()
	local buf = vim.api.nvim_get_current_buf()
	local ns = vim.api.nvim_create_namespace("nvim.multicursor")
	local ext_cursors = vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {})
	if #ext_cursors == 0 then
		return
	end

	local pcursor = vim.pos.cursor()
	local nlines = vim.api.nvim_buf_line_count(buf)

	local cursors = vim.iter(ext_cursors)
		:filter(function(m) return m[2] < nlines end)
		:map(function(m) return vim.pos.extmark(buf, m[2], m[3]) end)
		:totable()

	cursors[#cursors + 1] = pcursor
	cursors = vim.iter(cursors):unique(function(p) return ("%d:%d"):format(p.row, p.col) end):totable()

	-- Group cursors by row, and count max cursors per row.
	local groups = {} ---@type table<integer, integer[]>
	local max_group_count = 0
	for _, pos in ipairs(cursors) do
		local cols = groups[pos.row] or {}
		groups[pos.row] = cols
		cols[#cols + 1] = pos.col
		max_group_count = math.max(max_group_count, #cols)
	end

	for _, cols in pairs(groups) do
		table.sort(cols)
	end

	local target_cols = {} ---@type integer[]
	for i = 1, max_group_count do
		local max_gap = 0
		for _, cols in pairs(groups) do
			if cols[i] then
				max_gap = math.max(max_gap, cols[i] - (cols[i - 1] or 0))
			end
		end
		target_cols[i] = (target_cols[i - 1] or 0) + max_gap
	end

	for row, cols in pairs(groups) do
		for i = #cols, 1, -1 do
			local prev_target = i > 1 and target_cols[i - 1] or 0
			local prev_col = i > 1 and cols[i - 1] or 0
			---@diagnostic disable-next-line: need-check-nil
			local spaces = ((target_cols[i] - prev_target) - (cols[i] - prev_col)) --[[@as integer]]
			if spaces > 0 then
				vim.api.nvim_buf_set_text(buf, row, cols[i], row, cols[i], { string.rep(" ", spaces) })
			end
		end
	end

	local cols = groups[pcursor.row]
	for i, col in ipairs(cols) do
		if col == pcursor.col then
			---@diagnostic disable-next-line: assign-type-mismatch
			vim.api.nvim_win_set_cursor(0, { pcursor.row + 1, target_cols[i] })
			break
		end
	end
end

-- |foo|bar|baz|
-- |--|--|--|
-- |1|2|3|

vim.keymap.set({ "n", "v" }, "<c-m>", align_cursors, { desc = "Align multicursor" })
