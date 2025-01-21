local map = vim.keymap.set

vim.api.nvim_set_keymap("", "\\", "<Nop>", { noremap = true, silent = true })

map("n", "<M-h>", "gT", { desc = "Cycle through tabs" })
map("n", "<M-l>", "gt", { desc = "Cycle through tabs" })

-- Clear search highlight
map("n", "<C-c>", function() vim.v.hlsearch = 0 end, { desc = "Clear search highlights" })
map("n", "<Esc>", function() vim.v.hlsearch = 0 end, { desc = "Clear search highlights" })

-- Select text after pasting (e.g. for adjusting indentation)
map("n", "<leader>v", "`[v`]", { desc = "Select last operated region" })

-- For multi-line inserts
map("i", "<C-c>", "<Esc>")

-- My keyboard doesn't have this
map("i", "<C-x>", "<Del>")

-- Terminal mode keymaps
map("t", "<C-c>", "<C-\\><C-n>",       { desc = "Terminal exit"  })
map("t", "<C-.>", "<C-c>",             { desc = "Terminal clear" })
map("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Terminal clear" })
map("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Terminal clear" })
map("t", "<C-k>", "<C-\\C-w>k", { desc = "Terminal clear" })
map("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Terminal clear" })

-- Source stuff
map("n", "<leader>x",         "<cmd>.lua<CR>",     { desc = "Execute the current line" })
map("n", "<leader><leader>x", "<cmd>source %<CR>", { desc = "Execute the current file" })

-- Reindent on paste; use leader to not indent
map({ "n", "v" }, "p",         "p`[=`]", { desc = "Reindent on paste" })
map({ "n", "v" }, "P",         "P`[=`]", { desc = "Reindent on paste" })
map({ "n", "v" }, "<leader>p", "p",      { desc = "Normal paste"      })
map({ "n", "v" }, "<leader>P", "P",      { desc = "Normal paste"      })

map("n", "gj", function() vim.fn.append(vim.fn.line("."),     "") end, { desc = "Insert blank line below" })
map("n", "gk", function() vim.fn.append(vim.fn.line(".") - 1, "") end, { desc = "Insert blank line above" })

-- Delete without adding to register
map({"n", "v"}, "<leader>d", [["_d]], { desc = "Delete into empty register" })

-- These mappings control the size of splits (height/width)
map("n", "<M-,>", "<c-w>5<", { desc = "Descrease split width" })
map("n", "<M-.>", "<c-w>5>", { desc = "Increase split width"  })
map("n", "<M-;>", "<C-W>-",  { desc = "Decrease split height" })
map("n", "<M-'>", "<C-W>+",  { desc = "Increase split height" })

-- Move line down
map(
    "n", "<M-j>",
    function() vim.cmd(vim.opt.diff:get() and "normal! ]c]" or "m .+1<CR>==") end,
    { desc = "Move line down" }
)

-- Move line up
map(
    "n", "<M-k>",
    function() vim.cmd(vim.opt.diff:get() and "normal! [c]" or "m .-2<CR>==") end,
    { desc = "Move line up" }
)

-- Workaround for meta-key limitations in terminal emulators
map({ "i", "c" }, "<M-3>", "#", { noremap = true, desc = "Insert #" })
