return {
	"stevearc/conform.nvim",
	lazy = false,
	enabled = true,
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "ruff_format" },
			rust = { "rustfmt", lsp_format = "fallback" },
			r = { "air", lsp_format = "fallback" },
		},
		format_on_save = {
			lsp_format = "fallback",
			timeout_ms = 500,
		},
	},
	keys = {
		{
			"<leader>lf",
			function()
				require("conform").format()
			end,
			{ "n", "v" },
			desc = "Format File",
		},
	},
}
