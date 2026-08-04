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
			fuzzy = {
				sorts = {
					function(a, b)
						if (a.client_name == nil or b.client_name == nil) or (a.client_name == b.client_name) then
							return
						end
						return b.client_name:sub(1, 4) == "jet_"
					end,
					"score",
					"sort_text",
				},
			},
			completion = {
				list = {
					selection = { preselect = false, auto_insert = false },
				},
				menu = {
					draw = {
						treesitter = { "lsp" },
						columns = {
							{ "kind_icon" },
							{ "label", "label_description", gap = 1 },
							{ "src" },
						},
						components = {
							src = {
								width = { max = 8 },
								text = function(ctx)
									-- vim.print(ctx)
									if ctx.item.client_name then
										if ctx.item.client_name:sub(1, 4) == "jet_" then
											return "jet"
										else
											return ctx.item.client_name
										end
									end
									return ctx.item.source_id
								end,
								highlight = "BlinkCmpSource",
							},
						},
					},
				},
			},
			cmdline = {
				keymap = {},
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
			},
		},
		-- allows extending the providers array elsewhere in your config
		-- without having to redefine it
		opts_extend = {
			"sources.default",
		},
	},
}
