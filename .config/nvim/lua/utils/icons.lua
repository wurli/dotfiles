local M = {}

---@param group string
---@return vim.api.keyset.get_hl_info
local hl = function(group)
	return vim.api.nvim_get_hl(0, { name = group, link = false, create = false })
end

---@class CustomIcon
---@field symbol string
---@field group string
---@field hl vim.api.keyset.highlight

--stylua: ignore
local compile_icons = function()
	---@type table<string, CustomIcon>>
	M.diagnostics = {
		ERROR               = { symbol = "",                  group = "IconDiagnosticError",       hl = { fg = hl("Special").fg } },
		WARN                = { symbol = "",                  group = "IconDiagnosticWarn",        hl = { fg = hl("Special").fg } },
		HINT                = { symbol = "",                  group = "IconDiagnosticHint",        hl = { fg = hl("Special").fg } },
		INFO                = { symbol = "",                  group = "IconDiagnosticInfo",        hl = { fg = hl("Special").fg } },
	}

	---@type table<string, CustomIcon>>
	M.arrows = {
		right               = { symbol = "",                  group = "IconArrowRight",            hl = { fg = hl("Special").fg } },
		left                = { symbol = "",                  group = "IconArrowLeft",             hl = { fg = hl("Special").fg } },
		up                  = { symbol = "",                  group = "IconArrowUp",               hl = { fg = hl("Special").fg } },
		down                = { symbol = "",                  group = "IconArrowDown",             hl = { fg = hl("Special").fg } },
	}

	---@type table<string, CustomIcon>>
	M.lsp = {
		Array               = { symbol = "󰅪",                  group = "IconLspArray",              hl = { fg = hl("Special").fg } },
		Class               = { symbol = "",                  group = "IconLspClass",              hl = { fg = hl("Special").fg } },
		Color               = { symbol = "󰏘",                  group = "IconLspColor",              hl = { fg = hl("Special").fg } },
		Constant            = { symbol = "󰏿",                  group = "IconLspConstant",           hl = { fg = hl("Special").fg } },
		Constructor         = { symbol = "",                  group = "IconLspConstructor",        hl = { fg = hl("Special").fg } },
		Enum                = { symbol = "",                  group = "IconLspEnum",               hl = { fg = hl("Special").fg } },
		EnumMember          = { symbol = "",                  group = "IconLspEnumMember",         hl = { fg = hl("Special").fg } },
		Event               = { symbol = "",                  group = "IconLspEvent",              hl = { fg = hl("Special").fg } },
		Field               = { symbol = "󰜢",                  group = "IconLspField",              hl = { fg = hl("Special").fg } },
		File                = { symbol = "󰈙",                  group = "IconLspFile",               hl = { fg = hl("Special").fg } },
		Folder              = { symbol = "󰉋",                  group = "IconLspFolder",             hl = { fg = hl("Special").fg } },
		Function            = { symbol = "󰆧",                  group = "IconLspFunction",           hl = { fg = hl("Special").fg } },
		Interface           = { symbol = "",                  group = "IconLspInterface",          hl = { fg = hl("Special").fg } },
		Keyword             = { symbol = "󰌋",                  group = "IconLspKeyword",            hl = { fg = hl("Special").fg } },
		Method              = { symbol = "󰆧",                  group = "IconLspMethod",             hl = { fg = hl("Special").fg } },
		Module              = { symbol = "",                  group = "IconLspModule",             hl = { fg = hl("Special").fg } },
		Operator            = { symbol = "󰆕",                  group = "IconLspOperator",           hl = { fg = hl("Special").fg } },
		Property            = { symbol = "󰜢",                  group = "IconLspProperty",           hl = { fg = hl("Special").fg } },
		Reference           = { symbol = "󰈇",                  group = "IconLspReference",          hl = { fg = hl("Special").fg } },
		Snippet             = { symbol = "",                  group = "IconLspSnippet",            hl = { fg = hl("Special").fg } },
		Struct              = { symbol = "",                  group = "IconLspStruct",             hl = { fg = hl("Special").fg } },
		Text                = { symbol = "",                  group = "IconLspText",               hl = { fg = hl("Special").fg } },
		TypeParameter       = { symbol = "",                  group = "IconLspTypeParameter",      hl = { fg = hl("Special").fg } },
		Unit                = { symbol = "",                  group = "IconLspUnit",               hl = { fg = hl("Special").fg } },
		Value               = { symbol = "",                  group = "IconLspValue",              hl = { fg = hl("Special").fg } },
		Variable            = { symbol = "󰀫",                  group = "IconLspVariable",           hl = { fg = hl("Special").fg } },
	}


	---@type table<string, CustomIcon>>
	M.misc = {
		bug                 = { symbol = "",                  group = "IconMiscBug",               hl = { fg = hl("Special").fg } },
		dashed_bar          = { symbol = "┊",                  group = "IconMiscDashedBar",         hl = { fg = hl("Special").fg } },
		ellipsis            = { symbol = "…",                  group = "IconMiscEllipsis",          hl = { fg = hl("Special").fg } },
		git                 = { symbol = "",                  group = "IconMiscGit",               hl = { fg = hl("Special").fg } },
		branch              = { symbol = "",                  group = "IconMiscBranch",            hl = { fg = hl("Special").fg } },
		palette             = { symbol = "󰏘",                  group = "IconMiscPalette",           hl = { fg = hl("Special").fg } },
		robot               = { symbol = "󰚩",                  group = "IconMiscRobot",             hl = { fg = hl("Special").fg } },
		search              = { symbol = "",                  group = "IconMiscSearch",            hl = { fg = hl("Special").fg } },
		terminal            = { symbol = "",                  group = "IconMiscTerminal",          hl = { fg = hl("Special").fg } },
		toolbox             = { symbol = "󰦬",                  group = "IconMiscToolbox",           hl = { fg = hl("Special").fg } },
		vertical_bar        = { symbol = "│",                  group = "IconMiscVerticalBar",       hl = { fg = hl("Special").fg } },
		lsp                 = { symbol = "󱑟",                  group = "IconMiscLsp",               hl = { fg = hl("Special").fg } },
	}


	---@type table<string, CustomIcon>>
	M.ft = {
		DiffviewFileHistory = { symbol = M.misc.git.symbol,      group = "IconFtDiffviewFileHistory", hl = { fg = hl("Number").fg} },
		DiffviewFiles       = { symbol = M.misc.git.symbol,      group = "IconFtDiffviewFiles",       hl = { fg = hl("Number").fg} },
		["grug-far"]        = { symbol = M.misc.search.symbol,   group = "IconFtGrugFar",             hl = { fg = hl("Constant").fg} },
		fzf                 = { symbol = M.misc.terminal.symbol, group = "IconFtFzf",                 hl = { fg = hl("Special").fg} },
		gitcommit           = { symbol = M.misc.git.symbol,      group = "IconFtGitCommit",           hl = { fg = hl("Number").fg} },
		gitrebase           = { symbol = M.misc.git.symbol,      group = "IconFtGitRebase",           hl = { fg = hl("Number").fg} },
		fugitive            = { symbol = M.misc.git.symbol,      group = "IconFtFugitive",            hl = { fg = hl("Number").fg} },
		lazy                = { symbol = M.lsp.Method.symbol,    group = "IconFtLazy",                hl = { fg = hl("Special").fg} },
		lazyterm            = { symbol = M.misc.terminal.symbol, group = "IconFtLazyTerm",            hl = { fg = hl("Special").fg} },
		minifiles           = { symbol = M.lsp.Folder.symbol,    group = "IconFtMiniFiles",           hl = { fg = hl("Directory").fg} },
		qf                  = { symbol = M.misc.search.symbol,   group = "IconFtQf",                  hl = { fg = hl("Conditional").fg} },
	}


	for _, group in pairs(M) do
		for _, icon in pairs(group) do
			vim.api.nvim_set_hl(0, icon.group, icon.hl)
		end
	end
end

compile_icons()

-- Re-apply highlights when colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("jscott/icon_colours", { clear = true }),
	desc = "Re-apply icon highlights when colorscheme changes",
	callback = compile_icons,
})

return M
