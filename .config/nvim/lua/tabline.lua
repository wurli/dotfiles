local icons = require("utils.icons")

---Use ripgrep to list files for a few reasons:
---1. It's fast
---2. It respects .gitignore
local rg_list_files = function()
	local res = vim.system({ "rg", "--hidden", "--files" }):wait()

	if res.code ~= 0 or not res.stdout then
		return {}
	end

	local files = vim.split(res.stdout, "\n")
	local out = {}

	for _, file in ipairs(files) do
		if not vim.startswith(file, ".git/") then
			table.insert(out, file)
		end
	end

	return out
end

---@param path string
---@param sep? string
---@return string[]
local split_path2 = function(path, sep)
	return vim.split(path, sep or "/", { plain = true, trimempty = true })
end

---Example:
---
---```lua
---local compare = {
---	{ "hi", "there", "jacob" },
---	{ "hi", "there", "mulisa" },
---	{ "hi", "there", "jacob", "you", "guy" },
---	{ "yo" },
---	{ "yo", "yo", "yo" },
---}
---sort_arrays(compare)
---vim.print(compare)
---```
---@param x string[][]
local array_sort = function(x)
	-- Arrays are compared itemwise until one item is greater
	-- Shorter arrays are sorted first
	return table.sort(x, function(a, b)
		for i = 1, math.max(#a, #b) do
			if a[i] == nil then
				return true
			elseif b[i] == nil then
				return false
			elseif a[i] ~= b[i] then
				return a[i] < b[i]
			end
		end
		return false
	end)
end

---@param x any[]
local last_key = function(x)
	return math.max(0, unpack(vim.tbl_keys(x)))
end

---@param x any[]
---@param y any[]
---@return boolean
local array_eq = function(x, y)
	local x_len = last_key(x)
	local y_len = last_key(y)
	if x_len ~= y_len then
		return false
	end
	for i = 1, math.max(x_len, y_len) do
		if y[i] ~= x[i] then
			return false
		end
	end
	return true
end

---Assumes `x` is pre-sorted
---@param x any[][]
---@return any[][]
local array_unique = function(x)
	local out = { x[1] }
	for i = 2, #x do
		if not array_eq(x[i], x[i - 1]) then
			table.insert(out, x[i])
		end
	end
	return out
end

---@param x any[][]
---@param y any[]
---@return integer?
local array_find_occurrances = function(x, y)
	local occurrances = 0
	for _, xi in ipairs(x) do
		if array_eq(xi, y) then
			occurrances = occurrances + 1
		end
	end
	return occurrances
end

---If an array has gaps (sequences of nil values) then compress them so that at
---most one nil value appears at a time.
---@param x any[]
local array_compact = function(x)
	local max_i = last_key(x)
	local prev_i = 0
	local out = {}
	for i = 1, max_i do
		if x[i] then
			if i == prev_i + 1 then
				out[prev_i + 1] = x[i]
				prev_i = prev_i + 1
			else
				out[prev_i + 2] = x[i]
				prev_i = prev_i + 2
			end
		end
	end
	return out
end

-- TODO: at some point would be nice to have an algorithm which can efficiently
-- and correctly deduplicate arbitrary paths.
---@param paths string[]
---@param extra? string[]
---@return string[]
local abbreviate_paths = function(paths, extra)
	local split_paths = {}
	for _, path in ipairs(paths) do
		table.insert(split_paths, split_path2(path))
	end

	local compare
	if extra == nil then
		compare = vim.deepcopy(split_paths)
	else
		compare = vim.tbl_map(split_path2, extra)
		for _, path in ipairs(split_paths) do
			table.insert(compare, path)
		end
	end

	array_sort(compare)
	compare = array_unique(compare)

	local max_path_len = 0
	for _, path_parts in ipairs(split_paths) do
		max_path_len = math.max(max_path_len, #path_parts)
	end

	local squash_dir = function(x, i)
		for mi, path in ipairs(x) do
			if i < last_key(path) then
				path[i] = nil
				x[mi] = array_compact(path)
			end
		end
		return x
	end

	for i = max_path_len - 1, 1, -1 do
		local compare_squashed = vim.deepcopy(compare)
		compare_squashed = squash_dir(compare_squashed, i)
		local paths_squashed = vim.deepcopy(split_paths)
		paths_squashed = squash_dir(paths_squashed, i)

		local any_dupes = false

		for ii, squashed_path in ipairs(paths_squashed) do
			if array_find_occurrances(compare_squashed, squashed_path) == 1 then
				split_paths[ii] = squashed_path
			else
				any_dupes = true
			end
		end

		if not any_dupes then
			compare = compare_squashed
		end
	end

	local out = {}

	for _, path in ipairs(split_paths) do
		for i = 1, last_key(path) do
			if not path[i] then
				path[i] = icons.misc.ellipsis.symbol
			end
		end
		table.insert(out, table.concat(path, "/"))
	end

	return out
end

local file_info = function(buf)
	local devicons = require("nvim-web-devicons")

	local buftype = vim.bo[buf].buftype
	local ft = vim.bo[buf].filetype

	local buf_path = vim.api.nvim_buf_get_name(buf)
	local buf_path_short = vim.fn.fnamemodify(buf_path, ":~:.")
	local buf_tail = vim.fn.fnamemodify(buf_path, ":t")
	local buf_ext = vim.fn.fnamemodify(buf_path, ":e")

	if ft == "" and buf_path == "" then
		return {}
	end

	local icon = (icons.ft[ft] or {}).symbol
	local icon_hl = (icons.ft[ft] or {}).group

	if not icon then
		icon, icon_hl = devicons.get_icon(buf_tail, buf_ext)
	end

	if not icon then
		icon, icon_hl = devicons.get_icon_by_filetype(ft, { default = true })
	end

	if buftype == "terminal" then
		if buf_path:match("zsh") then
			icon = icons.misc.terminal.symbol
			icon_hl = icons.misc.terminal.group
		elseif buf_path:match("claude") or buf_path:match("opencode") or buf_path:match("copilot") then
			icon = icons.misc.robot.symbol
			icon_hl = icons.misc.robot.group
		elseif buf_path:match("python") then
			icon, icon_hl = devicons.get_icon_by_filetype("python", { default = true })
		end
	end

	return {
		icon = icon,
		icon_hl = "%$" .. icon_hl .. "$",
		path = buf_path_short,
	}
end

return {
	render = function()
		local hls = {
			inactive = "%#TabLine#",
			active = "%#TabLineSel#",
			fill = "%#TabLineFill#",
			dir = "%$Directory$",
		}

		local path_info = {}
		local paths = {}
		for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
			local win = vim.api.nvim_tabpage_get_win(tab)
			local buf = vim.api.nvim_win_get_buf(win)
			local info = file_info(buf)
			table.insert(paths, info.path or "[No Name]")
			table.insert(path_info, {
				active = tab == vim.api.nvim_get_current_tabpage(),
				icon = info.icon,
				icon_hl = info.icon_hl,
			})
		end

		local paths_abbv = abbreviate_paths(paths, rg_list_files())

		local items = {}
		for i = 1, #paths do
			local path = paths_abbv[i]
			local info = path_info[i]
			local base_hl = info.active and hls.active or hls.inactive
			local icon = info.icon and info.icon .. " " or ""
			local icon_hl = info.active and info.icon_hl and info.icon_hl or ""

			table.insert(items, base_hl .. " " .. icon_hl .. icon .. base_hl .. path)
		end

		return hls.fill .. table.concat(items, " ") .. hls.fill
	end,
}
