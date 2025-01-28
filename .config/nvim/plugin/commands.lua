vim.api.nvim_create_user_command(
    "Dump",
    function(x)
        local cmd = ("put =execute('%s')"):format(x.args)
        vim.cmd(cmd)
    end,
    {
        nargs = "+",
        desc = "Dump the output of a command at the cursor position"
    }
)

-- local system_command_exists = function(cmd)
--     local res = vim.system(
--         { "which", "-s", cmd },
--         { text = true },
--         function(_) end
--     ):wait()
--
--     return res.code == 0
-- end
--
-- vim.api.nvim_create_user_command(
--     "Preview",
--     function()
--         if not system_command_exists("quarto") then
--             print("Could not find quarto binary")
--             vim.fn.getchar()
--         end
--
--         local file = vim.api.nvim_buf_get_name(0)
--
--         vim.system(
--             { "quarto", "preview", file },
--             { text = true },
--             function(_) end
--         )
--     end,
--     { desc = "A wrapper for `quarto preview`" }
-- )
--
-- vim.api.nvim_create_user_command(
--     "Render",
--     function()
--         if not system_command_exists("quarto") then
--             print("Could not find quarto binary")
--             vim.fn.getchar()
--         end
--
--         local file = vim.api.nvim_buf_get_name(0)
--
--         vim.system(
--             { "quarto", "render", file },
--             { text = true },
--             function(_) end
--         )
--     end,
--     { desc = "A wrapper for `quarto render`" }
-- )
--
