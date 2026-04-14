-- Create a new buffer
vim.cmd.enew()

-- Open a terminal in the new buffer
vim.fn.jobstart({ "zsh" }, {
	term = true,
	env = {
		EDITOR = string.format('nvim --server "%s" --remote "$@"', vim.v.servername),
	},
})
