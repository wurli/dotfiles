return {
    {
        "wurli/contextindent.nvim",
        config = true
    },
    {
        "junegunn/vim-easy-align",
        config = function()
            vim.keymap.set({ "n", "v" }, "ga", "<Plug>(EasyAlign)")
            vim.g.easy_align_delimiters = {
                ['~'] = { pattern = "\\~" },
                ['<'] = { pattern = "<\\-" },
            }
        end
    },
    {
        'echasnovski/mini.surround',
        version = false,
        opts = {}
    },
    {
        'echasnovski/mini.pairs',
        version = false,
        opts = {}
    },
    {
        "wurli/split.nvim",
        -- dir = "~/Repos/split.nvim",
        opts = {
            keymap_defaults = {
                break_placement = function(line_info, opts)
                    if line_info.filetype == "sql" and not line_info.comment then
                        return "before_pattern"
                    end
                    return "after_pattern"
                end,
            },
        }
    }
}

