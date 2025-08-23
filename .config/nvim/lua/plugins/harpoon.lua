return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    cond = not vim.g.vscode,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require("harpoon")
        harpoon:setup()

        local cur_file = nil
        local cwd = vim.fn.getcwd()

        vim.keymap.set(
            "n",
            "<leader><leader>h",
            function()
                if vim.bo.ft ~= "harpoon" then
                    cur_file = vim.fn.expand("%"):gsub("^" .. cwd .. "/", "")
                end
                harpoon.ui:toggle_quick_menu(harpoon:list())
            end,
            { desc = "Open harpoon UI" }
        )

        vim.keymap.set("n", "<leader>ha", function()
            if vim.bo.ft ~= "harpoon" then
                harpoon:list():add()
                return
            end

            if cur_file then
                local lnum, cnum = unpack(vim.api.nvim_win_get_cursor(0))
                local all_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                for i, line in ipairs(all_lines) do
                    if line == cur_file then
                        vim.api.nvim_buf_set_lines(0, i - 1, i, false, {})
                    end
                end

                vim.api.nvim_buf_set_lines(0, lnum - 1, lnum - 1, false, { cur_file })
                vim.api.nvim_win_set_cursor(0, { lnum, cnum })
            end
        end)

        vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end)
        vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end)
        vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end)
        vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end)
        vim.keymap.set("n", "<leader>5", function() harpoon:list():select(5) end)

        -- Toggle previous & next buffers stored within Harpoon list
        -- vim.keymap.set("n", "<M-p>", function() harpoon:list():prev() end)
        -- vim.keymap.set("n", "<M-n>", function() harpoon:list():next() end)
    end,
}

