return {
    "nvim-tree/nvim-tree.lua",
    cond = not vim.g.vscode,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("nvim-tree").setup {
            modified = { enable = true },
            renderer = {
                icons = {
                    modified_placement = "before",
                    git_placement = "after"
                },
            },
            update_focused_file = { enable = true },
            filters = {
                git_ignored = false
            }
        }
        local api = require("nvim-tree.api")
        vim.keymap.set({ "n", "i" }, "<C-n>", api.tree.toggle)
    end
}
