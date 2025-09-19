vim.opt.autoindent  = true
vim.opt.clipboard   = "unnamedplus"
vim.opt.colorcolumn = { 80, 120 }
vim.opt.cursorline  = true
vim.opt.expandtab   = true
vim.opt.inccommand  = "split"
vim.opt.incsearch   = true
vim.opt.ignorecase  = true
vim.opt.smartcase   = true
vim.opt.scrolloff   = 7
vim.opt.shiftwidth  = 4
vim.opt.signcolumn  = "yes"
vim.opt.smartindent = true
vim.opt.softtabstop = 4
vim.opt.splitright  = true
vim.opt.swapfile    = false
vim.opt.tabstop     = 4
vim.opt.updatetime  = 500
vim.opt.winborder   = "rounded"

vim.opt.fillchars:append "diff:╱"
vim.opt.formatoptions:remove "o"

vim.opt.jumpoptions:append "stack"

-- Together give 'hybrid' line numbers
vim.wo.number = true
vim.wo.relativenumber = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.diffopt:append "algorithm:patience"

