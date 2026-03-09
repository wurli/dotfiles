return {
	"wurli/urlpreview.nvim",
	event = "VeryLazy",
	cond = not vim.g.vscode,
	opts = {
		auto_preview = true,
		keymap = "<leader>K",
		hl_group_title = false,
	},
}
