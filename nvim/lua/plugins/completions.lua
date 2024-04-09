return {
	{
		"hrsh7th/cmp-nvim-lsp",
	},
    {
		"R-nvim/cmp-r",
	},
	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		},
	},
	{
		"hrsh7th/nvim-cmp",
		config = function()
			local cmp = require("cmp")
			-- require("luasnip.loaders.from_vscode").lazy_load()

			local opts = {
				snippet = {
					expand = function(args) require("luasnip").lsp_expand(args.body) end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<tab>"] = cmp.mapping.confirm({ select = true }),
					["<CR>"] = cmp.mapping.confirm({ select = false }),
					["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
					["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
				}),
				-- Disable for markdown files - otherwise it's just annoying
				-- enabled = function() return vim.bo.filetype ~= "markdown" end,
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" }, -- For luasnip users.
				}, {
					{ name = "buffer" },
					{ name = "cmp_r" },
				}),
			}

			cmp.setup(opts)
			require("cmp_r").setup(opts)
		end,
	},
}
