local icons = require("utils.icons")

---@param path string
---@return string[]
local split_path = function(path)
	local out = {}
	while true do
		local base = vim.fs.basename(path)
		local dir = vim.fs.dirname(path)

		if path == dir then
			return out
		end
		table.insert(out, base)
		path = dir
	end
end

local file_info = function(buf)
	local devicons = require("nvim-web-devicons")

	local buftype = vim.bo[buf].buftype
	local ft = vim.bo[buf].filetype

	local buf_path = vim.api.nvim_buf_get_name(buf)
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

	local display_name = buf_tail == "" and buf_path or buf_tail

	if buftype == "terminal" then
		if display_name:match("zsh") then
			icon = icons.misc.terminal.symbol
			icon_hl = icons.misc.terminal.group
		elseif display_name:match("claude") or display_name:match("opencode") or display_name:match("copilot") then
			icon = icons.misc.robot.symbol
			icon_hl = icons.misc.robot.group
		elseif display_name:match("python") then
			icon, icon_hl = devicons.get_icon_by_filetype("python", { default = true })
		end
	end

	return {
		icon = icon,
		icon_hl = "%$" .. icon_hl .. "$",
		parts = split_path(buf_path),
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

		local paths = {} ---@type { icon?: string, icon_hl?: string, parts?: string[], display?: string[], unique_part?: number, active: boolean }[]
		for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
			local win = vim.api.nvim_tabpage_get_win(tab)
			local buf = vim.api.nvim_win_get_buf(win)
			local info = file_info(buf)
			info.active = tab == vim.api.nvim_get_current_tabpage()
			table.insert(paths, info)
		end

		for i, p in ipairs(paths) do
			for part, _ in ipairs(p.parts or {}) do
				local collision
				for ii, pp in ipairs(paths) do
					if ii ~= i and pp.parts and p.parts[part] == pp.parts[part] then
						collision = part
						break
					end
				end
				if not collision then
					p.unique_part = part
					break
				end
			end
			p.unique_part = p.unique_part or 1
		end

		local ellipsis = icons.misc.ellipsis.symbol

		local items = {}
		for _, path in ipairs(paths) do
			local base_hl = path.active and hls.active or hls.inactive

			local text
			if not path.parts then
				text = "[No name]"
			elseif path.unique_part == 1 then
				text = path.parts[1]
			elseif path.unique_part == 2 then
				text = hls.dir .. path.parts[2] .. "/" .. base_hl .. path.parts[1]
			elseif path.unique_part > 2 then
				text = hls.dir .. path.parts[path.unique_part] .. "/" .. ellipsis .. "/" .. base_hl .. path.parts[1]
			end
			local icon = path.icon and path.icon .. " " or ""
			local icon_hl = path.active and path.icon_hl and path.icon_hl or ""

			table.insert(items, base_hl .. " " .. icon_hl .. icon .. base_hl .. text)
		end

		return hls.fill .. table.concat(items, " ") .. hls.fill
	end,
}
