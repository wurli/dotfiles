---@diagnostic disable: undefined-global
-- Set vim options required for lazy -------------------------------------------
vim.api.nvim_set_keymap("", "\\", "<Nop>", { noremap = true, silent = true })
vim.g.maplocalleader = "\\"
vim.g.mapleader = " "
vim.opt.termguicolors = true
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

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

vim.g.ftplugin_sql_omni_key = "<C-s>"

-- Together give 'hybrid' line numbers
vim.wo.relativenumber = true
vim.wo.number = true

vim.opt.autoindent = true
vim.opt.smartindent = true

vim.opt.expandtab = true
vim.opt.colorcolumn = { 80, 120 }
vim.opt.tabstop = 4
vim.opt.cursorline = true
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.swapfile = false

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.api.nvim_create_autocmd("FileType", {
	pattern = "[Rr]",
	command = "setlocal shiftwidth=2 tabstop=2 softtabstop=2",
})

-- Select text after pasting (e.g. for adjusting indentation)
vim.keymap.set("n", "<leader>v", "`[v`]", {}) -- Select last paste
vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})

-- For multi-line inserts
vim.keymap.set("i", "<C-c>", "<Esc>")

-- Move out of terminal mode
-- vim.keymap.set("t", "<C-c>", "<C-\\><C-n>", { noremap = false })
vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h")
vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j")
vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k")
vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l")

-- Source stuff 
vim.keymap.set("n", "<leader>x", "<cmd>.lua<CR>", { desc = "Execute the current line" })
vim.keymap.set("n", "<leader><leader>x", "<cmd>source %<CR>", { desc = "Execute the current file" })

-- Paste without overwriting buffer:
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Yank into system clipboard
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Delete without adding to buffer
vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

-- These mappings control the size of splits (height/width)
vim.keymap.set("n", "<M-,>", "<c-w>5<")
vim.keymap.set("n", "<M-.>", "<c-w>5>")
vim.keymap.set("n", "<M-s>", "<C-W>-")
vim.keymap.set("n", "<M-t>", "<C-W>+")

-- Move line down
vim.keymap.set("n", "<M-j>", function()
  if vim.opt.diff:get() then
    vim.cmd [[normal! ]c]]
  else
    vim.cmd [[m .+1<CR>==]]
  end
end)

-- Move line up
vim.keymap.set("n", "<M-k>", function()
  if vim.opt.diff:get() then
    vim.cmd [[normal! [c]]
  else
    vim.cmd [[m .-2<CR>==]]
  end
end)

-- Split a line into mutliple lines based on a delimiter
local split_current_line = function(sep, keep_sep)
    if keep_sep == nil then keep_sep = true end
    local line = vim.api.nvim_get_current_line()

    -- Detect and (temporarily) remove any indentation
    local _, indent_end, indent = line:find("^(%s*)")
    indent = indent or ""
    line = line:sub(indent_end + 1)

    -- Replace separator with line breaks
    if keep_sep then
        line = string.gsub(line, "(" .. sep .. ")", "%1\n")
    else
        line = string.gsub(line, "(" .. sep .. ")", "\n")
    end

    -- Perform the split
    local line_split = vim.fn.split(line, "\n", false)

    for i, l in ipairs(line_split) do
        l = string.gsub(l, "^%s*", "") -- Remove leading whitespace
        l = string.gsub(l, "%s*$", "") -- Remove trailing whitespace
        line_split[i] = indent .. l    -- (Re)apply any indentation
    end

    -- Replace lines in the buffer
    local line_no = vim.api.nvim_win_get_cursor(0)[1] - 1
    vim.api.nvim_buf_set_lines(0, line_no, line_no + 1, true, line_split)
end

-- Split lines by comma
vim.keymap.set("n", "<C-s>", function() split_current_line(",") end)

-- Split by any pattern
vim.keymap.set("n", "<leader><C-s>", function()
    local esc_keycode = "\27"
    local keep_sep = true
    local pattern = ""
    local keep_prompting = true
    local was_cancelled = false

    while pattern == "" and keep_prompting do
        -- Detect if user enters Esc (in which case pattern will be "")
        vim.on_key(function(k) was_cancelled = k == esc_keycode end)

        if keep_sep then
            keep_prompting, pattern = pcall(vim.fn.input, "Enter a split pattern (keeping separator): ")
        else
            keep_prompting, pattern = pcall(vim.fn.input, "Enter a split pattern (removing separator): ")
        end

        if pattern == "" then keep_sep = not keep_sep end
        if not keep_prompting or was_cancelled then return end
    end

    split_current_line(pattern, keep_sep)
end)

-- Workaround for meta-key limitations in iterm2
vim.keymap.set({ "i", "c" }, "<M-3>", "#", { noremap = true })

