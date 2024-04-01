---@diagnostic disable: undefined-global
-- Set vim options required for lazy -------------------------------------------
vim.api.nvim_set_keymap("", "\\", "<Nop>", { noremap = true, silent = true })
vim.g.maplocalleader = ","
vim.g.mapleader = " "

-- Install lazy if not available ----------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Set up plugins -------------------------------------------------------------
require("lazy").setup("plugins")

-- Set other vim options ------------------------------------------------------

-- Together give 'hybrid' line numbers
vim.wo.relativenumber = true
vim.wo.number = true

vim.cmd("set expandtab")
vim.cmd("set colorcolumn=80,120")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

vim.api.nvim_create_autocmd("FileType", {
	pattern = "Lua",
	command = "setlocal shiftwidth=4 tabstop=4 softtabstop=4",
})

-- Select text after pasting (e.g. for adjusting indentation)
vim.keymap.set("n", "<leader>p", "p`[v`]", {}) -- Paste and select below cursor
vim.keymap.set("n", "<leader>P", "P`[v`]", {}) -- Paste and select above cursor
vim.keymap.set("n", "<leader>v", "`[v`]", {}) -- Select last paste
vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})

-- Enter insert mode at the correct indentation
local indent = function() if #vim.fn.getline(".") == 0 then return [["_cc]] else return "i" end end
vim.keymap.set("n", "i", indent, { expr = true, desc = "properly indent on empty line when insert" })
vim.keymap.set("n", "a", indent, { expr = true, desc = "properly indent on empty line when insert" })

-- For multi-line inserts
vim.keymap.set("i", "<C-c>", "<Esc>")

