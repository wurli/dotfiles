local icons = require("utils.icons")

local file_component = function(buf)
	local devicons = require("nvim-web-devicons")

	local buftype = vim.bo[buf].buftype
	local ft = vim.bo[buf].filetype

	local buf_path = vim.api.nvim_buf_get_name(buf)
	local buf_tail = vim.fn.fnamemodify(buf_path, ":t")
	local buf_ext = vim.fn.fnamemodify(buf_path, ":e")

	if ft == "" and buf_path == "" then
		return
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
		icon_hl = "%#" .. icon_hl .. "#",
		filename = display_name,
	}
end

return {
	render = function()
		local hl = {
			inactive = "%#TabLine#",
			active = "%#TabLineSel#",
		}

		local items = {}
		for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
			local win = vim.api.nvim_tabpage_get_win(tab)
			local buf = vim.api.nvim_win_get_buf(win)
			local item = file_component(buf)
			local active = tab == vim.api.nvim_get_current_tabpage()

			local text = item and item.filename or "[No Name]"
			local icon = item and item.icon .. " " or ""
			local icon_hl = active and item and item.icon_hl or ""
			local text_hl = active and hl.active or hl.inactive

			table.insert(items, text_hl .. " " .. icon_hl .. icon .. text_hl .. text)
		end

		return table.concat(items, " ")
	end,
}
