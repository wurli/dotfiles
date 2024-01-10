-- Set vim options ------------------------------------------------------------
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set colorcolumn=80,120")

-- Indentation-sensitive linebreak insert
vim.keymap.set('n', '<C-l>', 'a<cr><C-c>O', {})
vim.keymap.set('i', '<C-l>', '<cr><C-c>O', {})
vim.g.mapleader = " "
vim.wo.relativenumber = true
vim.wo.number = true

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

