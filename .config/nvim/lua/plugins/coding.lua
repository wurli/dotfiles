return {
	{
		"wurli/contextindent.nvim",
		config = true,
	},
	{
		"junegunn/vim-easy-align",
		config = function()
			vim.keymap.set({ "n", "v" }, "ga", "<Plug>(EasyAlign)")
			vim.g.easy_align_delimiters = {
				["~"] = { pattern = "\\~" },
				["<"] = { pattern = "<\\-" },
			}
		end,
	},
	{
		"nvim-mini/mini.surround",
		version = false,
		opts = {},
	},
	{
		"nvim-mini/mini.pairs",
		version = false,
		opts = {
			mappings = {
				['"'] = { action = "closeopen", pair = '""', neigh_pattern = '[^"\\].', register = { cr = false } },
				["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^'\\%a].", register = { cr = false } },
				["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^`\\].", register = { cr = false } },
			},
		},
	},
	{
		-- "wurli/split.nvim",
		dir = "~/Repos/split.nvim",
		opts = {
			keymap_defaults = {
				break_placement = function(line_info, opts)
					if line_info.filetype == "sql" and not line_info.comment then
						return "before_pattern"
					end
					return "after_pattern"
				end,
			},
			interactive_options = {
				[","] = ",",
				[";"] = ";",
				[" "] = "%s+",
				["+"] = " [+-/%%] ",
				["<"] = {
					pattern = "[<>=]=?",
					break_placement = "before_pattern",
				},
				["."] = {
					pattern = "[%.?!]%s+",
					unsplitter = " ",
					smart_ignore = "code",
					quote_characters = {},
					brace_characters = {},
				},
				["|"] = {
					pattern = { "%s+%|>", "%s+%%>%%" },
					indenter = "equalprg",
				},
			},
		},
	},
}
