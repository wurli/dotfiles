local icons = require("icons")

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

local status_hl = function(string, group)
	return "%#" .. group .. "#" .. string
end

local M = {}

--- Keeps track of the highlight groups I've already created.
---@type table<string, boolean>
local statusline_hls = {}

---@param hl string
---@return string
function M.get_or_create_hl(hl)
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

--- Current mode.
---@return string
function M.mode_component()
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
		status_hl("", "StatuslineModeSeparator" .. hl),
		status_hl(mode, "StatuslineMode" .. hl),
		status_hl("", "StatuslineModeSeparator" .. hl),
	})
end

--- Git status (if any).
---@return string
function M.git_component()
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
function M.dap_component()
	if not package.loaded["dap"] or require("dap").status() == "" then
		return nil
	end

	return string.format("%%#%s#%s  %s", M.get_or_create_hl("Special"), icons.misc.bug, require("dap").status())
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
				vim.cmd.redrawstatus()
			end, 3000)
		else
			vim.cmd.redrawstatus()
		end
	end,
})
--- The latest LSP progress message.
---@return string
function M.lsp_progress_component()
	if not progress_status.client or not progress_status.title then
		return ""
	end

	-- Avoid noisy messages while typing.
	if vim.startswith(vim.api.nvim_get_mode().mode, "i") then
		return ""
	end

	return table.concat({
		status_hl("󱥸 ", "StatuslineSpinner"),
		status_hl(progress_status.client .. "  ", "StatuslineTitle"),
		status_hl(progress_status.title .. "...", "StatuslineItalic"),
	})
end

--- The buffer's filetype.
---@return string
function M.file_component()
	local devicons = require("nvim-web-devicons")

	-- Special icons for some filetypes.
	local special_icons = {
		DiffviewFileHistory = { icons.misc.git, "Number" },
		DiffviewFiles = { icons.misc.git, "Number" },
		["ccc-ui"] = { icons.misc.palette, "Comment" },
		["dap-view"] = { icons.misc.bug, "Special" },
		["grug-far"] = { icons.misc.search, "Constant" },
		fzf = { icons.misc.terminal, "Special" },
		gitcommit = { icons.misc.git, "Number" },
		gitrebase = { icons.misc.git, "Number" },
		lazy = { icons.symbol_kinds.Method, "Special" },
		lazyterm = { icons.misc.terminal, "Special" },
		minifiles = { icons.symbol_kinds.Folder, "Directory" },
		qf = { icons.misc.search, "Conditional" },
	}

	local filetype = vim.bo.filetype
	if filetype == "" then
		filetype = "[No Name]"
	end

	local icon, icon_hl
	if special_icons[filetype] then
		icon, icon_hl = unpack(special_icons[filetype])
	else
		local buf_name = vim.api.nvim_buf_get_name(0)
		local name, ext = vim.fn.fnamemodify(buf_name, ":t"), vim.fn.fnamemodify(buf_name, ":e")

		icon, icon_hl = devicons.get_icon(name, ext)
		if not icon then
			icon, icon_hl = devicons.get_icon_by_filetype(filetype, { default = true })
		end
	end
	icon_hl = M.get_or_create_hl(icon_hl)

	local filename = vim.fs.basename(vim.api.nvim_buf_get_name(0))

	return status_hl(icon, icon_hl) .. " " .. status_hl(filename, "StatuslineTitle")
end

--- File-content encoding for the current buffer.
---@return string
function M.encoding_component()
	local encoding = vim.opt.fileencoding:get()
	return encoding == "" and "" or status_hl(" " .. encoding, "StatuslineModeSeparatorOther")
end

--- The current line, total line count, and column position.
---@return string
function M.position_component()
	return status_hl(string.format("%2d:%-2d", vim.fn.line("."), vim.fn.virtcol(".")), "StatuslineTitle")
end

--- Renders the statusline.
---@return string
function M.render()
	return table.concat({
		M.mode_component(),
		"  ",
		M.file_component(),
		"  ",
		M.dap_component() or M.lsp_progress_component(),
		-- Separates lhs and rhs
		status_hl("%=", "StatusLine"),
		vim.diagnostic.status(),
		"  ",
		M.git_component(),
		"  ",
		-- M.encoding_component(),
		-- "  ",
		M.position_component(),
	})
end

return M
