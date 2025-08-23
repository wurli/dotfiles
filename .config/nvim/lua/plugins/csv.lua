return {
    "hat0uma/csvview.nvim",
    config = function()
        require("csvview").setup({
            view = {
                header_lnum = 1
            },
            parser = { comments = { "#", "//" } },
            keymaps = {
                -- Text objects for selecting fields
                textobject_field_inner = { "if", mode = { "o", "x" } },
                textobject_field_outer = { "af", mode = { "o", "x" } },
                -- Excel-like navigation:
                -- Use <Tab> and <S-Tab> to move horizontally between fields.
                -- Use <Enter> and <S-Enter> to move vertically between rows and place the cursor at the end of the field.
                -- Note: In terminals, you may need to enable CSI-u mode to use <S-Tab> and <S-Enter>.
                jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
                jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
                jump_next_row = { "<Enter>", mode = { "n", "v" } },
                jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
            },
        })

        vim.api.nvim_create_autocmd("BufEnter", {
            pattern = "*.csv",
            callback = function()
                vim.opt_local.virtualedit = "all"
                require("csvview").enable(0)
            end,
        })
    end,
    ft = "csv",
    -- cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
}
