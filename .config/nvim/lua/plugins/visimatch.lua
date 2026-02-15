return {
	"wurli/visimatch.nvim",
	cond = not vim.g.vscode,
	event = "ModeChanged",
	opts = {
		buffers = function(buf)
			if vim.bo[buf].buftype == "terminal" then
				return true
			end
			return vim.bo.filetype == vim.bo[buf].filetype
		end,
	},
}
