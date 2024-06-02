return {
    "junegunn/vim-easy-align",
    config = function()
        vim.keymap.set({ "n", "v" }, "ga", "<Plug>(EasyAlign)")
        vim.g.easy_align_delimiters = {
            ['~'] = { pattern = "\\~" },
            ['<'] = { pattern = "<\\-" },
        }
    end
}


-- This is pretty nice, but it doesn't handle leading whitespace - things
-- only get shifted right, never left. Also kinda hard to specify delimiters.
-- return {
--     "echasnovski/mini.align",
--     config = function()
--         require("mini.align").setup()
--     end
-- }
--
