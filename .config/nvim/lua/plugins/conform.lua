return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "ruff" },
			rust = { "rustfmt", lsp_format = "fallback" },
			r = { "air", lsp_format = "fallback" },
		},
	},
	keys = {
		{
			"<leader>lf",
			function() require("conform").format() end,
			{ "n", "v" },
			desc = "Format File",
		},
	},
}
