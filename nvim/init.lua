-- @diagnostic disable: undefined-global
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
vim.keymap.set("n", "<leader>v", "`[v`]", {}) -- Select last paste
vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})

-- Enter insert mode at the correct indentation
vim.keymap.set(
    "n", "i",
    function() if #vim.fn.getline(".") == 0 then return [["_cc]] else return "i" end end,
    { expr = true, desc = "properly indent on empty line when insert" }
)
vim.keymap.set(
    "n", "a",
    function() if #vim.fn.getline(".") == 0 then return [["_cc]] else return "a" end end,
    { expr = true, desc = "properly indent on empty line when insert" }
)

-- For multi-line inserts
vim.keymap.set("i", "<C-c>", "<Esc>")

-- Move out of terminal mode
vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h")
vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j")
vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k")
vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l")
-- vim.keymap.set("t", "<C-c>", "<C-\\><C-n>", { noremap = false })

-- Paste without overwriting buffer:
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Yank into system clipboard
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Delete without adding to buffer
vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])
