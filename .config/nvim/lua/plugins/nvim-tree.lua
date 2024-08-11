return {
    "nvim-tree/nvim-tree.lua",
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
        }
        local api = require("nvim-tree.api")
        vim.keymap.set({ "n", "i" }, "<C-n>", api.tree.toggle)
    end
}
