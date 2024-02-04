-- Set vim options ------------------------------------------------------------
vim.g.mapleader = " "
vim.wo.relativenumber = true -- | Together give 'hybrid' line numbers
vim.wo.number = true         -- |

vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set colorcolumn=80,120")

-- Indentation-sensitive linebreak insert
vim.keymap.set('n', '<C-l>', 'a<cr><C-c>O', {})
vim.keymap.set('i', '<C-l>', '<cr><C-c>O', {})

-- Select text after pasting (e.g. for adjusting indentation)
vim.keymap.set('n', '<leader>p', 'p`[v`]', {}) -- Paste and select below cursor
vim.keymap.set('n', '<leader>P', 'P`[v`]', {}) -- Paste and select above cursor
vim.keymap.set('n', '<leader>v', '`[v`]', {})  -- Select last paste

-- For multi-line inserts
vim.keymap.set("i", "<C-c>", "<Esc>")


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

