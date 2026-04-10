local ts_select = function(query_string, query_group)
	return function()
		require("nvim-treesitter-textobjects.select").select_textobject(query_string, query_group)
	end
end

local ts_goto = function(type, query_string, query_group)
	return function()
		require("nvim-treesitter-textobjects.move")["goto_" .. type](query_string, query_group)
	end
end

return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		branch = "main",
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		init = function()
			-- Disable entire built-in ftplugin mappings to avoid conflicts.
			-- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
			vim.g.no_plugin_maps = true

			-- Or, disable per filetype (add as you like)
			-- vim.g.no_python_maps = true
			-- vim.g.no_ruby_maps = true
			-- vim.g.no_rust_maps = true
			-- vim.g.no_go_maps = true
		end,
		opts = {
			select = {
				-- Automatically jump forward to textobj, similar to targets.vim
				lookahead = true,
				-- You can choose the select mode (default is charwise 'v')
				--
				-- Can also be a function which gets passed a table with the keys
				-- * query_string: eg '@function.inner'
				-- * method: eg 'v' or 'o'
				-- and should return the mode ('v', 'V', or '<c-v>') or a table
				-- mapping query_strings to modes.
				selection_modes = {
					["@parameter.outer"] = "v", -- charwise
					["@function.outer"] = "V", -- linewise
					-- ['@class.outer'] = '<c-v>', -- blockwise
				},
			},
			move = {
				set_jumps = true,
			},
		},
		keys = {
			{ "af", mode = { "x", "o" }, ts_select("@function.outer", "textobjects") },
			{ "if", mode = { "x", "o" }, ts_select("@function.inner", "textobjects") },
			{ "is", mode = { "x", "o" }, ts_select("@local.scope", "locals") },
			{ "]m", mode = { "n", "x", "o" }, ts_goto("next_start", "@function.outer", "textobjects") },
			{ "[m", mode = { "n", "x", "o" }, ts_goto("previous_start", "@function.outer", "textobjects") },
			{ "]M", mode = { "n", "x", "o" }, ts_goto("next_end", "@function.outer", "textobjects") },
			{ "[M", mode = { "n", "x", "o" }, ts_goto("previous_end", "@function.outer", "textobjects") },
			{ "]s", mode = { "n", "x", "o" }, ts_goto("next_start", "@local.scope", "locals") },
			{ "[s", mode = { "n", "x", "o" }, ts_goto("previous_start", "@local.scope", "locals") },
		},
	},
}
