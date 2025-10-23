local map = vim.keymap.set

vim.api.nvim_set_keymap("", "\\", "<Nop>", { noremap = true, silent = true })

map("n", "<leader>yf", function()
    vim.fn.setreg("+", vim.fn.expand("%"))
end, { desc = "Yank the current file path" })

map("n", "<leader>tc", function()
    local cur_colorschema = vim.trim(vim.fn.execute("colorscheme"))

    if cur_colorschema == "cobalt" then
        vim.cmd.colorscheme("tokyonight-day")
    elseif cur_colorschema == "tokyonight-day" then
        vim.cmd.colorscheme("cobalt")
    end
end, { desc = "Toggle light/dark colorscheme" })

-- Ctrl-Z is my tmux leader and I never use :suspend
map({ "n", "v" }, "<c-z>", "<Nop>", { noremap = true, silent = true })

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
map("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Terminal exit up" })
map("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Terminal exit right" })


map("n", "<C-h>", "<C-w><C-h>", { desc = "Window navigate left" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Window navigate down" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Window navigate up" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Window navigate right" })

-- Source stuff
map("n", "<leader>x",         "<cmd>.lua<CR>",     { desc = "Execute the current line" })
map("n", "<leader><leader>x", "<cmd>source %<CR>", { desc = "Execute the current file" })

-- Reindent on paste; use leader to not indent
-- map({ "n", "v" }, "p",         "p`[=`]", { desc = "Reindent on paste" })
-- map({ "n", "v" }, "P",         "P`[=`]", { desc = "Reindent on paste" })
-- map({ "n", "v" }, "<leader>p", "p",      { desc = "Normal paste"      })
-- map({ "n", "v" }, "<leader>P", "P",      { desc = "Normal paste"      })

-- Delete without adding to register
map({"n", "v"}, "<leader>d", [["_d]], { desc = "Delete into empty register" })

-- These mappings control the size of splits (height/width)
map("n", "<M-,>", "<c-w>5<", { desc = "Descrease split width" })
map("n", "<M-.>", "<c-w>5>", { desc = "Increase split width"  })
map("n", "<M-;>", "<C-W>-",  { desc = "Decrease split height" })
map("n", "<M-'>", "<C-W>+",  { desc = "Increase split height" })

-- Move line down
map(
    "n", "<M-j>", function()
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
    "n", "<M-k>",
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

map("v", "<M-j>", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
map("v", "<M-k>", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })

-- Workaround for meta-key limitations in terminal emulators
map(
    { "i", "n", "c", "v", "t" },
    "<M-3>", "#",
    { noremap = true, desc = "Insert #" }
)

vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<M-u>", "<cmd>silent !tmux neww tmux-sessionizer -s 0<CR>")
vim.keymap.set("n", "<M-i>", "<cmd>silent !tmux neww tmux-sessionizer -s 1<CR>")
vim.keymap.set("n", "<M-o>", "<cmd>silent !tmux neww tmux-sessionizer -s 2<CR>")
vim.keymap.set("n", "<M-p>", "<cmd>silent !tmux neww tmux-sessionizer -s 3<CR>")

local go_to_next_jumplist_buf = function(dir)
    local jl = vim.fn.getjumplist()
    local jumplist, cur_jump_index = unpack(jl)

    local cur_buf = jumplist[cur_jump_index].bufnr

    local n_jumps = 1
    while true do
        local jump = jumplist[cur_jump_index + dir * n_jumps]
        if not jump then return end
        if jump.bufnr ~= cur_buf then
            local command = dir == -1 and "<c-o>" or "<c-i>"
            local cmd = 'execute "normal! ' .. tostring(n_jumps) .. "\\" .. command .. '"'
            vim.print(cmd)
            vim.cmd(cmd)
            return
        end
        n_jumps = n_jumps + 1
    end
end

map(
    "n", "<m-n>", function() go_to_next_jumplist_buf(-1) end,
    { desc = "Go to previous buffer in jumplist" }
)

map(
    "n", "<m-p>", function() go_to_next_jumplist_buf(1) end,
    { desc = "Go to next buffer in jumplist" }
)

map("n", "<leader>lz", "<cmd>Lazy<CR>", { desc = "Open Lazy" })
