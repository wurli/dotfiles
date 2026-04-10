local icons = require("utils.icons")

local mode_separators = {} -- { "", "" }

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
	-- stylua: ignore start
	---@type table<string, vim.api.keyset.highlight>
	local statusline_groups = {
		StatuslineItalic    = { italic = true },
		StatusLineBold      = { bold = true },
		StatuslineDim       = { fg = get_hl("LineNr").fg },
		StatuslineDimItalic = { fg = get_hl("LineNr").fg, italic = true },
		StatuslineInverted  = { fg = get_hl("Statusline").bg, bg = get_hl("Statusline").fg },
		StatuslineIcon      = { fg = get_hl("Special").fg },
	}
	for mode, color in pairs({
		Normal  = { fg = get_hl("Statusline").bg, bg = get_hl("Statusline").fg },
		Pending = { fg = get_hl("Statusline").bg, bg = get_hl("Comment").fg },
		Visual  = { fg = get_hl("Statusline").bg, bg = get_hl("SpecialKey").fg },
		Insert  = { fg = get_hl("Statusline").bg, bg = get_hl("diffAdded").fg  },
		Command = { fg = get_hl("Statusline").bg, bg = get_hl("Number").fg     },
		Replace = { fg = get_hl("Statusline").bg, bg = get_hl("Constant").fg   },
		Other   = { link = "StatusLine" },
	}) do
		statusline_groups["StatuslineMode"          .. mode] = { fg = color.fg, bg = color.bg }
		statusline_groups["StatuslineModeSeparator" .. mode] = { fg = color.bg, bg = color.fg }
	end
	-- stylua: ignore end

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

	local lsep = mode_separators[1]
	local rsep = mode_separators[2]

	if lsep and rsep then
		return table.concat({
			sl_hl("StatuslineModeSeparator" .. hl) .. lsep,
			sl_hl("StatuslineMode" .. hl) .. mode,
			sl_hl("StatuslineModeSeparator" .. hl) .. rsep,
		})
	else
		return sl_hl("StatuslineMode" .. hl) .. " " .. mode .. " "
	end
end

---@return string
local git_component = function()
	local head = vim.b.gitsigns_head
	if not head or head == "" then
		return ""
	end

	local component = highlight_icon(icons.misc.branch) .. " " .. sl_hl("StatusLine") .. head

	local num_hunks = #(require("gitsigns").get_hunks(1) or {})
	if num_hunks > 0 then
		component = component .. string.format(" (#Hunks: %d)", num_hunks)
	end

	return component
end

---@return string?
local dap_component = function()
	if not package.loaded["dap"] or require("dap").status() == "" then
		return nil
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

---@return string
local lsp_progress_component = function()
	if not progress_status.client or not progress_status.title then
		return ""
	end

	-- Avoid noisy messages while typing.
	if vim.startswith(vim.api.nvim_get_mode().mode, "i") then
		return ""
	end

	return highlight_icon(icons.misc.lsp)
		.. " "
		.. sl_hl("StatuslineDim")
		.. progress_status.client
		.. ": "
		.. sl_hl("StatuslineDimItalic")
		.. progress_status.title
end

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
	local ft = vim.bo[buf].filetype
	local buftype = vim.bo[buf].buftype

	ft = ft == "" and "[No Name]" or ft
	local buf_name = vim.api.nvim_buf_get_name(sl_bufnr())

	local icon, icon_hl
	local ft_settings = icons.ft[ft]

	if ft_settings then
		icon = ft_settings.symbol
		icon_hl = ft_settings.group
	else
		local name = vim.fn.fnamemodify(buf_name, ":t")
		local ext = vim.fn.fnamemodify(buf_name, ":e")

		icon, icon_hl = devicons.get_icon(name, ext)
		if not icon then
			icon, icon_hl = devicons.get_icon_by_filetype(ft, { default = true })
		end
	end

	local basename = vim.fn.fnamemodify(buf_name, ":t")
	local disp_name = basename == "" and buf_name or basename

	if buftype == "terminal" then
		if disp_name:match("^zsh") then
			icon = icons.misc.terminal.symbol
			icon_hl = icons.misc.terminal.group
		elseif disp_name:match("^claude") or disp_name:match("^opencode") or disp_name:match("^copilot") then
			icon = icons.misc.robot.symbol
			icon_hl = icons.misc.robot.group
		elseif disp_name:match("^python ?") then
			icon, icon_hl = devicons.get_icon_by_filetype("python", { default = true })
		end
	end

	return sl_hl(icon_hl) .. icon .. " " .. sl_hl("StatusLineBold") .. disp_name
end

---@return string
local modified_component = function()
	if vim.bo[sl_bufnr()].modified then
		return sl_hl("StatuslineModified") .. "[+]"
	else
		return ""
	end
end

-- --- File-content encoding for the current buffer.
-- ---@return string
-- local encoding_component = function()
-- 	local encoding = vim.opt.fileencoding:get()
-- 	return encoding == "" and "" or status_hl(" " .. encoding, "StatuslineModeSeparatorOther")
-- end

local wordcount_component = function()
	local wc = vim.api.nvim_buf_call(sl_bufnr(), vim.fn.wordcount)
	local visual = vim.fn.mode():match("^[vV\22]")

	return sl_hl("StatuslineDim")
		.. " "
		.. string.format("w: %s%s", visual and wc.visual_words .. "/" or "", wc.words)
		.. " "
		.. string.format("c: %s%s", visual and wc.visual_chars .. "/" or "", wc.chars)
		.. " "
end

--- The current line, total line count, and column position.
---@return string
local position_component = function()
	return sl_hl("StatuslineInverted") .. string.format(" %2d:%-2d ", vim.fn.line("."), vim.fn.virtcol("."))
end

local M = {}

--- Renders the statusline.
---@return string
function M.render()
	-- Active window
	if sl_winid() == vim.fn.win_getid() then
		return table.concat({
			mode_component(),
			file_component(),
			modified_component(),
			dap_component() or lsp_progress_component(),
			"%=",
			diagnostic_component(),
			vim.bo[sl_bufnr()].filetype == "markdown" and wordcount_component() or "",
			git_component(),
			-- M.encoding_component(),
			position_component(),
		}, sl_hl("StatusLine") .. " ")
	-- Inactive windows
	else
		return " " .. file_component()
	end
end

return M
