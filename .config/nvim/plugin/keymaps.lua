vim.api.nvim_set_keymap("", "\\", "<Nop>", { noremap = true, silent = true })

-- Select text after pasting (e.g. for adjusting indentation)
vim.keymap.set("n", "<leader>v", "`[v`]", {}) -- Select last paste
vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})

-- For multi-line inserts
vim.keymap.set("i", "<C-c>", "<Esc>")

-- Move out of terminal mode
-- vim.keymap.set("t", "<C-c>", "<C-\\><C-n>", { noremap = false })
vim.keymap.set("t", "<C-c>", "<C-\\><C-n>")
vim.keymap.set("t", "<C-.>", "<C-c>")

vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h")
vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j")
vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k")
vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l")

-- Source stuff
vim.keymap.set("n", "<leader>x", "<cmd>.lua<CR>", { desc = "Execute the current line" })
vim.keymap.set("n", "<leader><leader>x", "<cmd>source %<CR>", { desc = "Execute the current file" })

-- Reindent on paste; user leader to not indent
vim.keymap.set({ "n", "v" }, "p", "p`[=`]")
vim.keymap.set({ "n", "v" }, "P",  "P`[=`]")
vim.keymap.set({ "n", "v" }, "<leader>p", "p")
vim.keymap.set({ "n", "v" }, "<leader>P", "P")

vim.keymap.set("n", "gj", function() vim.fn.append(vim.fn.line("."), "") end)
vim.keymap.set("n", "gk", function() vim.fn.append(vim.fn.line(".") - 1, "") end)

-- Yank into system clipboard
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Delete without adding to buffer
vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

-- These mappings control the size of splits (height/width)
vim.keymap.set("n", "<M-,>", "<c-w>5<")
vim.keymap.set("n", "<M-.>", "<c-w>5>")
vim.keymap.set("n", "<M-;>", "<C-W>-")
vim.keymap.set("n", "<M-'>", "<C-W>+")


vim.keymap.set("n", "<M-j>", function()
    vim.cmd(vim.opt.diff:get() and "normal! ]c]" or "m .+1<CR>==")
end)

-- Move line up
vim.keymap.set("n", "<M-k>", function()
    vim.cmd(vim.opt.diff:get() and "normal! [c]" or "m .-2<CR>==")
end)

-- Workaround for meta-key limitations in terminal emulators
vim.keymap.set({ "i", "c" }, "<M-3>", "#", { noremap = true })
