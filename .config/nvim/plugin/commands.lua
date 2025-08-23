vim.api.nvim_create_user_command(
    "Dump",
    function(x)
        vim.cmd(string.format("put =execute('%s')", x.args))
    end,
    {
        nargs = "+",
        desc = "Dump the output of a command at the cursor position"
    }
)

vim.api.nvim_create_user_command(
    "Tab",
    function()
        local win = vim.api.nvim_get_current_win()
        vim.cmd [[ tab split ]]
        vim.api.nvim_win_close(win, true)
    end,
    { desc = "Move current window to its own tab" }
)

vim.api.nvim_create_user_command(
    "LspFormat",
    function(x)
        vim.lsp.buf.format({
            name = x.fargs[1],
            range = x.range == 0 and nil or {
                ["start"] = { x.line1, 0 },
                ["end"] = { x.line2, 0 }
            }
        })
    end,
    { nargs = "?", range = "%", desc = "LSP format" }
)


local go_to_relative_file = function(n, relative_to)
    return function()
        local this_dir = vim.fs.dirname(vim.fs.normalize(vim.fn.expand("%:p")))

        local files = {}
        for file, type in vim.fs.dir(this_dir) do
            if type == "file" then
                table.insert(files, file)
            end
        end

        local this_file = relative_to or vim.fs.basename(vim.fn.bufname())
        local this_file_pos = -1

        for i, file in ipairs(files) do
            if file == this_file then
                this_file_pos = i
            end
        end

        if this_file_pos == -1 then
            error(("File `%s` not found in current directory"):format(this_file))
        end

        local new_file = files[((this_file_pos + n - 1) % #files) + 1]

        if not new_file then
            error(("Could not find file relative to `%s`"):format(this_file))
        end

        vim.cmd("edit " .. this_dir .. "/" .. new_file)
    end
end


vim.api.nvim_create_user_command("FileNext", go_to_relative_file(1), {})
vim.api.nvim_create_user_command("FilePrev", go_to_relative_file(-1), {})


vim.api.nvim_create_user_command(
    "RuffFixAll",
    function()
        vim.lsp.buf.code_action({
            context = { only = {"source.fixAll.ruff"} },
            apply = true
        })
    end,
    { desc = "Ruff fix all" }
)

vim.api.nvim_create_user_command(
    "RuffOrganizeImports",
    function()
        vim.lsp.buf.code_action({
            context = { only = {"source.organizeImports.ruff"} },
            apply = true
        })
    end,
    { desc = "Ruff organize imports" }
)

vim.api.nvim_create_user_command(
    "Positron",
    function()
        vim.system({
            "positron",
            "--goto",
            vim.fn.expand("%:p") .. ":" .. vim.api.nvim_win_get_cursor(0)[1],
            vim.fn.getcwd()
        })
    end,
    { desc = "Open current file in Positron" }
)
