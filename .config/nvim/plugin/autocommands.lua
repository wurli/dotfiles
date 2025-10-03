if vim.g.vscode then
    return
end

vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup("custom-term-open", { clear = true }),
    callback = function()
        vim.wo.number = false
        vim.wo.relativenumber = false
    end
})

local trim = [[%s/\s\+$//e]]

vim.api.nvim_create_user_command("Trim", trim, {
    desc = "Trim trailing whitespace from lines"
})

vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("trim-on-save", { clear = true }),
    command = trim
})


-- vim.api.nvim_create_autocmd("BufWinEnter", {
--     group = vim.api.nvim_create_augroup("diff-line-nums", { clear = true }),
--     callback = function()
--         local wins = vim.api.nvim_tabpage_list_wins(0)
--         for _, w in ipairs(wins) do
--             if vim.wo[w].diff then
--                 vim.wo[w].relativenumber = false
--             end
--         end
--     end
-- })
