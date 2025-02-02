return {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = {
        shade_terminals = false,
        on_open = function(t) pcall(vim.cmd.f, t.display_name) end,
        size = function(t)
            local vert = t.direction == "vertical"
            return vert and vim.o.columns / 2 or 20
        end,
        start_in_insert = false
    }
}
