return {
	"stevearc/conform.nvim",
	lazy = false,
	enabled = true,
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "ruff_format" },
			rust = { "rustfmt" },
			r = { "air", lsp_format = "fallback" },
			markdown = { "injected" },
		},
		format_on_save = {
			lsp_format = "fallback",
			timeout_ms = 500,
		},
		formatters = {
			rustfmt = {
				commant = "rustfmt",
				args = { "--edition", "2024" },
			},
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
