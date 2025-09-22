vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("project-settings", {}),
    callback = function()
        local cwd_name = vim.fs.basename(vim.fn.getcwd()):lower()

        -- If the current working dir matches any of these patterns, require
        -- the corresponding lua module
        for pattern, module in pairs({
            ["notes"] = "notes",
            ["data_pipeline$"] = "data_pipeline"
        }) do
            if cwd_name:match(pattern) then
                require("project." .. module)
            end
        end
    end
})
