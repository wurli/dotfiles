local icons = require("utils.icons")

---@param group string
---@return string
local sl_hl = function(group)
	return "%#" .. group .. "#"
end

---@param group string
---@return vim.api.keyset.get_hl_info
local get_hl = function(group)
	return vim.api.nvim_get_hl(0, { name = group, link = false, create = false })
end

---@param icon CustomIcon
---@return string
local highlight_icon = function(icon)
	return sl_hl(icon.group) .. icon.symbol .. sl_hl("StatusLine")
end

local set_hl_groups = function()
	---@type table<string, vim.api.keyset.highlight>
	local statusline_groups = {
		StatusLineModeNormal = { fg = get_hl("StatusLine").bg, bg = get_hl("StatusLine").fg },
		StatusLineModePending = { fg = get_hl("StatusLine").bg, bg = get_hl("Comment").fg },
		StatusLineModeVisual = { fg = get_hl("StatusLine").bg, bg = get_hl("SpecialKey").fg },
		StatusLineModeInsert = { fg = get_hl("StatusLine").bg, bg = get_hl("diffAdded").fg },
		StatusLineModeCommand = { fg = get_hl("StatusLine").bg, bg = get_hl("Number").fg },
		StatusLineModeReplace = { fg = get_hl("StatusLine").bg, bg = get_hl("Constant").fg },
		StatusLineModeOther = { link = "StatusLine" },
		StatusLineBold = { bold = true },
		StatusLineDim = { fg = get_hl("LineNr").fg },
		StatusLineDimItalic = { fg = get_hl("LineNr").fg, italic = true },
		StatusLineInverted = { link = "StatusLineModeNormal" },
	}

	for group, opts in pairs(statusline_groups) do
		vim.api.nvim_set_hl(0, group, opts)
	end
end

set_hl_groups()

-- Re-apply highlights when colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("jscott/statusline_colors", { clear = true }),
	desc = "Re-apply statusline highlights on colorscheme change",
	callback = set_hl_groups,
})

---@return number
local sl_winid = function()
	return vim.g.statusline_winid or 0
end

---@return number
local sl_bufnr = function()
	return vim.api.nvim_win_get_buf(sl_winid())
end

---@return string
local mode_component = function()
	-- Note that: \19 = ^S and \22 = ^V.
	-- stylua: ignore start
	local mode_settings = {
		["n"]     = { name = "NORMAL",     hl = "Normal" },
		["no"]    = { name = "OP-PENDING", hl = "Pending" },
		["nov"]   = { name = "OP-PENDING", hl = "Pending" },
		["noV"]   = { name = "OP-PENDING", hl = "Pending" },
		["no\22"] = { name = "OP-PENDING", hl = "Pending" },
		["niI"]   = { name = "NORMAL",     hl = "Normal" },
		["niR"]   = { name = "NORMAL",     hl = "Normal" },
		["niV"]   = { name = "NORMAL",     hl = "Normal" },
		["nt"]    = { name = "NORMAL",     hl = "Normal" },
		["ntT"]   = { name = "NORMAL",     hl = "Normal" },
		["v"]     = { name = "VISUAL",     hl = "Visual" },
		["vs"]    = { name = "VISUAL",     hl = "Visual" },
		["V"]     = { name = "V-LINE",     hl = "Visual" },
		["Vs"]    = { name = "V-LINE",     hl = "Visual" },
		["\22"]   = { name = "V-BLOCK",    hl = "Visual" },
		["\22s"]  = { name = "V-BLOCK",    hl = "Visual" },
		["s"]     = { name = "SELECT",     hl = "Insert" },
		["S"]     = { name = "S-LINE",     hl = "Normal" },
		["\19"]   = { name = "S-BLOCK",    hl = "Normal" },
		["i"]     = { name = "INSERT",     hl = "Insert" },
		["ic"]    = { name = "INSERT",     hl = "Insert" },
		["ix"]    = { name = "INSERT",     hl = "Insert" },
		["R"]     = { name = "REPLACE",    hl = "Replace" },
		["Rc"]    = { name = "REPLACE",    hl = "Replace" },
		["Rx"]    = { name = "REPLACE",    hl = "Replace" },
		["Rv"]    = { name = "V-REPLACE",  hl = "Replace" },
		["Rvc"]   = { name = "V-REPLACE",  hl = "Replace" },
		["Rvx"]   = { name = "V-REPLACE",  hl = "Replace" },
		["c"]     = { name = "COMMAND",    hl = "Command" },
		["cv"]    = { name = "EX",         hl = "Command" },
		["ce"]    = { name = "EX",         hl = "Command" },
		["r"]     = { name = "REPLACE",    hl = "Normal" },
		["rm"]    = { name = "MORE",       hl = "Normal" },
		["r?"]    = { name = "CONFIRM",    hl = "Normal" },
		["!"]     = { name = "SHELL",      hl = "Normal" },
		["t"]     = { name = "TERMINAL",   hl = "Command" },
	}
	-- stylua: ignore end

	local settings = mode_settings[vim.api.nvim_get_mode().mode] or {}
	local mode = settings.name or "UNKNOWN"
	local hl = settings.hl or "Other"

	return sl_hl("StatusLineMode" .. hl) .. " " .. mode .. " "
end

---@return string?
local git_component = function()
	local head = vim.b.gitsigns_head
	if not head or head == "" then
		return
	end

	local component = highlight_icon(icons.misc.branch) .. " " .. sl_hl("StatusLine") .. head

	local n_hunks = #(require("gitsigns").get_hunks(sl_bufnr()) or {})
	if n_hunks > 0 then
		local s = n_hunks == 1 and "" or "s"
		component = component .. sl_hl("StatusLineDimItalic") .. string.format(" (%d hunk%s)", n_hunks, s)
	end

	return component
end

---@return string?
local dap_component = function()
	if not package.loaded["dap"] or require("dap").status() == "" then
		return
	end

	return string.format("%%#%s#%s  %s", "Special", icons.misc.bug.symbol, require("dap").status())
end

---@type table<string, string?>
local progress_status = {
	client = nil,
	kind = nil,
	title = nil,
}

vim.api.nvim_create_autocmd("LspProgress", {
	group = vim.api.nvim_create_augroup("jscott/statusline", { clear = true }),
	desc = "Update LSP progress in statusline",
	pattern = { "begin", "end" },
	callback = function(args)
		-- This should in theory never happen, but I've seen weird errors.
		if not args.data then
			return
		end

		progress_status = {
			client = vim.lsp.get_client_by_id(args.data.client_id).name,
			kind = args.data.params.value.kind,
			title = args.data.params.value.title,
		}

		if progress_status.kind == "end" then
			progress_status.title = nil
			-- Wait a bit before clearing the status.
			vim.defer_fn(function()
				vim.api.nvim__redraw({ statusline = true })
			end, 3000)
		else
			vim.api.nvim__redraw({ statusline = true })
		end
	end,
})

---@return string?
local lsp_progress_component = function()
	if not progress_status.client or not progress_status.title then
		return
	end

	-- Avoid noisy messages while typing.
	if vim.startswith(vim.api.nvim_get_mode().mode, "i") then
		return
	end

	return highlight_icon(icons.misc.lsp)
		.. " "
		.. sl_hl("StatusLineDim")
		.. progress_status.client
		.. ": "
		.. sl_hl("StatusLineDimItalic")
		.. progress_status.title
end

---@return string
---@return number
local diagnostic_component = function()
	-- Add some padding around the actual info; need to use patterns so
	-- highlights are also applied to the padding.
	return vim.diagnostic.status(sl_bufnr()):gsub("%w+:", " %0", 1):gsub("(:%d+)%%", "%1 %%")
end

--- The buffer's filetype.
---@return string
local file_component = function()
	local devicons = require("nvim-web-devicons")

	local buf = sl_bufnr()
	local buftype = vim.bo[buf].buftype
	local ft = vim.bo[buf].filetype

	local buf_path = vim.api.nvim_buf_get_name(sl_bufnr())
	local buf_name = vim.fn.fnamemodify(buf_path, ":t")
	local buf_ext = vim.fn.fnamemodify(buf_path, ":e")

	local icon = (icons.ft[ft] or {}).symbol
	local icon_hl = (icons.ft[ft] or {}).group

	if not icon then
		icon, icon_hl = devicons.get_icon(buf_name, buf_ext)
	end

	if not icon then
		icon, icon_hl = devicons.get_icon_by_filetype(ft, { default = true })
	end

	local display_name = buf_name == "" and buf_path or buf_name

	if buftype == "terminal" then
		if display_name:match("^zsh") then
			icon = icons.misc.terminal.symbol
			icon_hl = icons.misc.terminal.group
		elseif display_name:match("^claude") or display_name:match("^opencode") or display_name:match("^copilot") then
			icon = icons.misc.robot.symbol
			icon_hl = icons.misc.robot.group
		elseif display_name:match("^python ?") then
			icon, icon_hl = devicons.get_icon_by_filetype("python", { default = true })
		end
	end

	return sl_hl(icon_hl) .. icon .. " " .. sl_hl("StatusLineBold") .. display_name
end

---@return string?
local modified_component = function()
	if vim.bo[sl_bufnr()].modified then
		return sl_hl("StatusLineModified") .. "[+]"
	end
end

-- --- File-content encoding for the current buffer.
-- ---@return string
-- local encoding_component = function()
-- 	local encoding = vim.opt.fileencoding:get()
-- 	return encoding == "" and "" or status_hl(" " .. encoding, "StatusLineModeSeparatorOther")
-- end

---@return string
local wordcount_component = function()
	local wc = vim.api.nvim_buf_call(sl_bufnr(), vim.fn.wordcount)
	local visual = vim.fn.mode():match("^[vV\22]")

	return sl_hl("StatusLineDim")
		.. " "
		.. string.format("w: %s%s", visual and wc.visual_words .. "/" or "", wc.words)
		.. " "
		.. string.format("c: %s%s", visual and wc.visual_chars .. "/" or "", wc.chars)
		.. " "
end

--- The current line, total line count, and column position.
---@return string
local position_component = function()
	return sl_hl("StatusLineInverted") .. string.format(" %2d:%-2d ", vim.fn.line("."), vim.fn.virtcol("."))
end

local M = {}

---@return string
function M.render()
	local win_is_active = sl_winid() == vim.fn.win_getid()

	if not win_is_active then
		return " " .. file_component()
	end

	local ft = vim.bo[sl_bufnr()].filetype

	local components = {
		mode_component(),
		file_component(),
		modified_component(),
		" ",
		dap_component() or lsp_progress_component(),
		"%=",
		diagnostic_component(),
		ft == "markdown" and wordcount_component() or "",
		git_component(),
		position_component(),
	}

	-- Flatten removes any nil components
	return table.concat(vim.iter(components):flatten():totable(), sl_hl("StatusLine") .. " ")
end

return M
