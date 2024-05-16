return {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("nvim-tree").setup {
            modified = { enable = true },
            update_focused_file = { enable = true },
        }
        local api = require("nvim-tree.api")
        vim.keymap.set({ "n", "i" }, "<C-n>", api.tree.toggle)
    end
}
