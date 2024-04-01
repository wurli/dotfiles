return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
    config = function()
        local config = require("nvim-treesitter.configs")
        config.setup({
            auto_install = true,
            ensure_installed = { "lua", "python", "r" },
            highlight = { enable = true },
            indent = { enable = true },
            -- textobjects = { enable = true },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "tis",
                    node_incremental = "ni",
                    scope_incremental = "si",
                    node_decremental = "nd",
                },
            },
        })
    end,
}
