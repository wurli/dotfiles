-- For autocomplete
_G.conform_off = false

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
		format_on_save = function(buf)
			if not _G.conform_off then
				require("conform").format({
					bufnr = buf,
					lsp_format = "fallback",
					timeout_ms = 500,
				})
			end
		end,
		formatters = {
			rustfmt = {
				command = "rustfmt",
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
