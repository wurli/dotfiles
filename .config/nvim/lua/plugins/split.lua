return {
    -- "wurli/split.nvim",
    dir = "~/Repos/split.nvim",
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

