local icons = require("utils.icons")

local colors = {
	green = "#87E58E",
	grey = "#A9ABAC",
	orange = "#FFBFA9",
	pink = "#E48CC1",
	purple = "#BAA0E8",
	transparent_black = "#1E1F29",
	yellow = "#E8EDA2",
	cyan = "#A7DFEF",
}

-- Groups used for my statusline.
---@type table<string, vim.api.keyset.highlight>
local statusline_groups = {}
for mode, color in pairs({
	Normal = "purple",
	Pending = "pink",
	Visual = "yellow",
	Insert = "green",
	Command = "cyan",
	Other = "orange",
}) do
	statusline_groups["StatuslineMode" .. mode] = { fg = colors.transparent_black, bg = colors[color] }
	statusline_groups["StatuslineModeSeparator" .. mode] = { fg = colors[color], bg = colors.transparent_black }
end
statusline_groups = vim.tbl_extend("error", statusline_groups, {
	StatuslineItalic = { fg = colors.grey, bg = colors.transparent_black, italic = true },
	StatuslineSpinner = { fg = colors.bright_green, bg = colors.transparent_black, bold = true },
	StatuslineTitle = { fg = colors.bright_white, bg = colors.transparent_black, bold = true },
})

for group, opts in pairs(statusline_groups) do
	vim.api.nvim_set_hl(0, group, opts)
end

--- Keeps track of the highlight groups I've already created.
---@type table<string, boolean>
local statusline_hls = {}

---@param hl string
---@return string
local get_or_create_hl = function(hl)
	local hl_name = "Statusline" .. hl

	if not statusline_hls[hl] then
		-- If not in the cache, create the highlight group using the icon's foreground color
		-- and the statusline's background color.
		local bg_hl = vim.api.nvim_get_hl(0, { name = "StatusLine" })
		local fg_hl = vim.api.nvim_get_hl(0, { name = hl })
		vim.api.nvim_set_hl(0, hl_name, { bg = ("#%06x"):format(bg_hl.bg), fg = ("#%06x"):format(fg_hl.fg) })
		statusline_hls[hl] = true
	end

	return hl_name
end

---@param x string
---@param group string
---@return string
local sl_hl = function(x, group)
	return "%#" .. group .. "#" .. x
end

---@return number
local sl_winid = function()
	return vim.g.statusline_winid or 0
end

---@return number
local sl_bufnr = function()
	return vim.api.nvim_win_get_buf(sl_winid())
end

--- Current mode.
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
		["R"]     = { name = "REPLACE",    hl = "Normal" },
		["Rc"]    = { name = "REPLACE",    hl = "Normal" },
		["Rx"]    = { name = "REPLACE",    hl = "Normal" },
		["Rv"]    = { name = "V-REPLACE",  hl = "Normal" },
		["Rvc"]   = { name = "V-REPLACE",  hl = "Normal" },
		["Rvx"]   = { name = "V-REPLACE",  hl = "Normal" },
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

	return table.concat({
		sl_hl("", "StatuslineModeSeparator" .. hl),
		sl_hl(mode, "StatuslineMode" .. hl),
		sl_hl("", "StatuslineModeSeparator" .. hl),
	})
end

--- Git status (if any).
---@return string
local git_component = function()
	local head = vim.b.gitsigns_head
	if not head or head == "" then
		return ""
	end

	local component = string.format(" %s", head)

	local num_hunks = #(require("gitsigns").get_hunks(1) or {})
	if num_hunks > 0 then
		component = component .. string.format(" (#Hunks: %d)", num_hunks)
	end

	return component
end

--- The current debugging status (if any).
---@return string?
local dap_component = function()
	if not package.loaded["dap"] or require("dap").status() == "" then
		return nil
	end

	return string.format("%%#%s#%s  %s", get_or_create_hl("Special"), icons.misc.bug, require("dap").status())
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

--- The latest LSP progress message.
---@return string
local lsp_progress_component = function()
	if not progress_status.client or not progress_status.title then
		return ""
	end

	-- Avoid noisy messages while typing.
	if vim.startswith(vim.api.nvim_get_mode().mode, "i") then
		return ""
	end

	return table.concat({
		sl_hl(icons.misc.lsp .. " ", "StatuslineSpinner"),
		sl_hl(progress_status.client .. "  ", "StatuslineTitle"),
		sl_hl(progress_status.title .. "...", "StatuslineItalic"),
	})
end

--- The buffer's filetype.
---@return string
local file_component = function()
	local devicons = require("nvim-web-devicons")

	-- Special icons for some filetypes.
	-- stylua: ignore start
	local ft_icons = {
		DiffviewFileHistory = { icon = icons.misc.git,            hl = "Number" },
		DiffviewFiles       = { icon = icons.misc.git,            hl = "Number" },
		["ccc-ui"]          = { icon = icons.misc.palette,        hl = "Comment" },
		["dap-view"]        = { icon = icons.misc.bug,            hl = "Special" },
		["grug-far"]        = { icon = icons.misc.search,         hl = "Constant" },
		fzf                 = { icon = icons.misc.terminal,       hl = "Special" },
		gitcommit           = { icon = icons.misc.git,            hl = "Number" },
		gitrebase           = { icon = icons.misc.git,            hl = "Number" },
		fugitive            = { icon = icons.misc.git,            hl = "Number" },
		lazy                = { icon = icons.symbol_kinds.Method, hl = "Special" },
		lazyterm            = { icon = icons.misc.terminal,       hl = "Special" },
		minifiles           = { icon = icons.symbol_kinds.Folder, hl = "Directory" },
		qf                  = { icon = icons.misc.search,         hl = "Conditional" },
	}
	-- stylua: ignore end

	local buf = sl_bufnr()
	local ft = vim.bo[buf].filetype
	local buftype = vim.bo[buf].buftype

	ft = ft == "" and "[No Name]" or ft
	local buf_name = vim.api.nvim_buf_get_name(sl_bufnr())

	local icon, icon_hl
	local ft_settings = ft_icons[ft]

	if ft_settings then
		icon = ft_settings.icon
		icon_hl = ft_settings.hl
	else
		local name = vim.fn.fnamemodify(buf_name, ":t")
		local ext = vim.fn.fnamemodify(buf_name, ":e")

		icon, icon_hl = devicons.get_icon(name, ext)
		if not icon then
			icon, icon_hl = devicons.get_icon_by_filetype(ft, { default = true })
		end
	end
	icon_hl = get_or_create_hl(icon_hl)

	local basename = vim.fn.fnamemodify(buf_name, ":t")
	local display_name = basename == "" and buf_name or basename

	if buftype == "terminal" then
		if display_name:match("^zsh ?") then
			icon = icons.misc.terminal
			icon_hl = get_or_create_hl("Special")
		elseif display_name:match("^python ?") then
			icon, icon_hl = devicons.get_icon_by_filetype("python", { default = true })
		elseif
			display_name:match("^claude ?")
			or display_name:match("^opencode ?")
			or display_name:match("^copilot ?")
		then
			icon = icons.misc.robot
			icon_hl = get_or_create_hl("Special")
		end
	end

	return sl_hl(icon, icon_hl) .. " " .. sl_hl(display_name, "StatuslineTitle")
end

---@return string
local modified_component = function()
	if vim.bo[sl_bufnr()].modified then
		return sl_hl("[+]", "StatuslineModified")
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

--- The current line, total line count, and column position.
---@return string
local position_component = function()
	return sl_hl(string.format("%2d:%-2d", vim.fn.line("."), vim.fn.virtcol(".")), "StatuslineTitle")
end

local M = {}

--- Renders the statusline.
---@return string
function M.render()
	-- Active window
	if sl_winid() == vim.fn.win_getid() then
		return table.concat({
			mode_component(),
			"  ",
			file_component(),
			" ",
			modified_component(),
			"  ",
			dap_component() or lsp_progress_component(),
			-- Separates lhs and rhs
			sl_hl("%=", "StatusLine"),
			vim.diagnostic.status(),
			"  ",
			git_component(),
			"  ",
			-- M.encoding_component(),
			-- "  ",
			position_component(),
		})
	-- Inactive windows
	else
		return file_component()
	end
end

return M
