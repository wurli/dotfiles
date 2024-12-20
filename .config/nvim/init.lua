---@diagnostic disable: undefined-global

if vim.g.vscode then
    vim.cmd[[unmap =]]
    vim.cmd[[unmap ==]]
end

-- Set vim options required for lazy -------------------------------------------
vim.api.nvim_set_keymap("", "\\", "<Nop>", { noremap = true, silent = true })
vim.g.maplocalleader = "\\"
vim.g.mapleader = " "
vim.opt.termguicolors = true
vim.opt.splitright = true
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.so = 7

-- Install lazy if not available ----------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim" if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
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

vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup("custom-term-open", { clear = true }),
    callback = function()
        vim.opt.number = false
        vim.opt.relativenumber = false
    end
})

local trim = function()
    local lines = vim.api.nvim_buf_get_lines(0, 1, -1, true)
    for lnum, line in ipairs(lines) do
        lines[lnum] = line:gsub("%s+$", "")
    end
    vim.api.nvim_buf_set_lines(0, 1, -1, true, lines)
end

vim.api.nvim_create_user_command("Trim", trim, { desc = "Trim trailing whitespace from lines" })

vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("trim-on-save", { clear = true }),
    callback = trim
})

local command_exists = function(cmd)
    local res = vim.system(
        { "which", "-s", cmd },
        { text = true },
        function(_) end
    ):wait()

    return res.code == 0
end


vim.api.nvim_create_user_command(
    "Preview",
    function()
        if not command_exists("quarto") then
            print("Could not find quarto binary")
            vim.fn.getchar()
        end

        local file = vim.api.nvim_buf_get_name(0)

        vim.system(
            { "quarto", "preview", file },
            { text = true },
            function(_) end
        )
    end,
    { desc = "A wrapper for `quarto preview`" }
)

vim.api.nvim_create_user_command(
    "Render",
    function(args)
        if not command_exists("quarto") then
            print("Could not find quarto binary")
            vim.fn.getchar()
        end

        local file = vim.api.nvim_buf_get_name(0)

        vim.system(
            { "quarto", "render", file },
            { text = true },
            function(_) end
        )
    end,
    { desc = "A wrapper for `quarto render`" }
)


-- Workaround for meta-key limitations in iterm2
vim.keymap.set({ "i", "c" }, "<M-3>", "#", { noremap = true })

