-- vim.opt.formatoptions:remove "o"
vim.opt.autoindent     = true
vim.opt.breakindent    = true
vim.opt.colorcolumn    = { 80, 120 }
vim.opt.confirm        = true
vim.opt.cursorline     = true
vim.opt.expandtab      = true
vim.opt.ignorecase     = true
vim.opt.inccommand     = "split"
vim.opt.incsearch      = true
vim.opt.linebreak      = true
vim.opt.list           = true
vim.opt.listchars      = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.number         = true
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.relativenumber = true
vim.opt.scrolloff      = 7
vim.opt.shiftwidth     = 4
vim.opt.showbreak      = "↪ "
vim.opt.showmode       = false
vim.opt.smartcase      = true
vim.opt.smartindent    = true
vim.opt.softtabstop    = 4
vim.opt.splitright     = true
vim.opt.swapfile       = false
vim.opt.tabstop        = 4
vim.opt.timeoutlen     = 300
vim.opt.updatetime     = 250
vim.opt.winborder      = "rounded"

-- Scheduling as this can impact startup time
vim.schedule(function() vim.opt.clipboard = "unnamedplus" end)

vim.opt.fillchars:append "diff:╱"
vim.opt.jumpoptions:append "stack"
vim.opt.diffopt:append "algorithm:patience"
