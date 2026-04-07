return {
	{
		"saghen/blink.compat",
		version = "*",
		lazy = true,
		opts = { impersonate_nvim_cmp = true },
	},
	{
		"saghen/blink.cmp",
		cond = not vim.g.vscode,
		lazy = false, -- lazy loading handled internally
		-- dependencies = "rafamadriz/friendly-snippets",
		dependencies = {
			{ "L3MON4D3/LuaSnip", version = "v2.*" },
			-- { "R-nvim/cmp-r", opts = {} },
		},
		version = "v0.*",
		---@module "blink.cmp"
		---@type blink.cmp.Config
		---@diagnostic disable: missing-fields
		opts = {
			keymap = {
				preset = "default",
				["<C-l>"] = { "snippet_forward", "fallback" },
				["<C-h>"] = { "snippet_backward", "fallback" },
			},
			completion = {
				list = {
					selection = { preselect = false, auto_insert = false },
				},
			},
			cmdline = {
				keymap = {
					preset = "inherit",
				},
				completion = {
					menu = {
						auto_show = true,
					},
				},
			},
			signature = { enabled = true },
			snippets = { preset = "luasnip" },
			appearance = { nerd_font_variant = "mono" },
			sources = {
				default = {
					"snippets",
					"lsp",
					"path",
					"buffer",
					-- "cmp_r"
				},
				providers = {
					path = {
						opts = {
							-- Always use the CWD rather than the current
							-- buffer's parent directory
							get_cwd = function(_)
								return vim.fn.getcwd()
							end,
							show_hidden_files_by_default = true,
							trailing_slash = false,
						},
					},
				},
				-- providers = {
				--     cmp_r = {
				--         name = "cmp_r",
				--         module = "blink.compat.source",
				--         opts = {}
				--     }
				-- }
			},
			fuzzy = {
				-- Always prioritise snippets if available
				-- sorts = {
				--     function(a, b)
				--         if a.source_id == "snippets" and b.source_id ~= "snippets" then
				--             -- prioritise a
				--             return true
				--         elseif a.source_id ~= "snippets" and b.source_id == "snippets" then
				--             -- prioritise b
				--             return false
				--         else
				--             -- fallback to default
				--             return nil
				--         end
				--     end
				-- }
			},
		},
		-- allows extending the providers array elsewhere in your config
		-- without having to redefine it
		opts_extend = {
			"sources.default",
		},
	},
}
