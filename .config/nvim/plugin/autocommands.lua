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

vim.api.nvim_create_user_command("Trim", trim, {
    desc = "Trim trailing whitespace from lines"
})

vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("trim-on-save", { clear = true }),
    callback = trim
})

