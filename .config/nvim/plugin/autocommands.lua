if vim.g.vscode then
	return
end

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("custom-filetype", { clear = true }),
	pattern = {
		"bash",
		"c",
		"html",
		"lua",
		"luadoc",
		"markdown",
		"markdown_inline",
		"python",
		"r",
		"rnoweb",
		"vim",
		"vimdoc",
	},
	callback = function()
		vim.treesitter.start()
		local new_ft = vim.fn.expand("<amatch>")
		if not vim.tbl_contains({
			"markdown",
			"markdown_inline",
		}, new_ft) then
			vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end

		if not vim.tbl_contains({
			"vimdoc",
		}, new_ft) then
			-- For some reason these often get turned off, e.g. when switching
			-- to/from the built-in terminal
			vim.wo.number = true
			vim.wo.relativenumber = true
		end
	end,
})

-- I don't know why these seem to be generally unreliable; maybe some plugin
-- is messing with them? Either way this seems to give the behaviour I want.
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("custom-line-numbers", { clear = true }),
	callback = function()
		local use_nums = vim.bo.buftype == ""
		vim.wo.number = use_nums
		vim.wo.relativenumber = use_nums
	end,
})
