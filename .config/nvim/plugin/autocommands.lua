if vim.g.vscode then
	return
end

vim.api.nvim_create_autocmd("TermOpen", {
	group = vim.api.nvim_create_augroup("custom-term-open", { clear = true }),
	callback = function()
		vim.wo.number = false
		vim.wo.relativenumber = false
	end,
})

vim.api.nvim_create_autocmd("BufAdd", {
	group = vim.api.nvim_create_augroup("bla", { clear = true }),
	pattern = "*.ipynb",
	callback = function()
		print("hi")
	end,
})
