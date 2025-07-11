local map = vim.keymap.set

vim.api.nvim_set_keymap("", "\\", "<Nop>", { noremap = true, silent = true })

map({ "n", "t" }, "<M-l>", vim.cmd.tabn, { desc = "Next tabpage" })
map({ "n", "t" }, "<M-h>", vim.cmd.tabp, { desc = "Previous tabpage" })

-- Search within selection
map("x", "g/", "<Esc>/\\%V", { desc = "Search within selection" })

-- Select text after pasting (e.g. for adjusting indentation)
map("n", "<leader>v", "`[v`]", { desc = "Select last operated region" })

-- For multi-line inserts
map("i", "<C-c>", "<Esc>")

-- I like to spam Ctrl-C to remove highlights
map("n", "<C-c>", function()
    vim.cmd[[nohls]]
    return "<C-c>"
end, { expr = true })
map("n", "<Esc>", function()
    vim.cmd[[nohls]]
    return "<Esc>"
end, { expr = true })

-- The above borks up the cmdline window, so temporarily restore default behaviour
vim.api.nvim_create_autocmd("CmdwinEnter", {
    callback = function()
        map("n", "<C-c>", "<C-c>", { buffer = 0 })
        map("n", "<Esc>", "<Esc>", { buffer = 0 })
    end
})

-- My keyboard doesn't have this
map("i", "<C-l>", "<Del>")

-- Terminal mode keymaps
map("t", "<M-c>", "<C-c>",             { desc = "Terminal cancel" })
map("t", "<M-l>", "<C-l>",             { desc = "Terminal clear" })
map("t", "<C-c>", "<C-\\><C-n>",       { desc = "Terminal exit"  })
map("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Terminal exit left" })
map("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Terminal exit down" })
map("t", "<C-k>", "<C-\\C-w>k",      { desc = "Terminal exit up" })
map("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Terminal exit right" })

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
    { "n", "v" }, "<M-j>", function()
        if vim.opt.diff:get() then
            vim.cmd("normal! ]c]")
        elseif vim.fn.mode() == "v" or vim.fn.mode() == "V" then
            -- vim.cmd("m .-2<CR>==")
        else
            vim.cmd("m .+1<CR>==")
        end
    end,
    { desc = "Move line down" }
)

-- Move line up
map(
    { "n", "v" }, "<M-k>",
    function()
        if vim.opt.diff:get() then
            vim.cmd("normal! [c]")
        elseif vim.fn.mode() == "v" or vim.fn.mode() == "V" then
            -- vim.cmd("m .-2<CR>==")
        else
            vim.cmd("m .-2<CR>==")
        end
    end,
    { desc = "Move line up" }
)

-- Workaround for meta-key limitations in terminal emulators
map(
    { "i", "n", "c", "v", "t" },
    "<M-3>", "#",
    { noremap = true, desc = "Insert #" }
)
