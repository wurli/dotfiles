return {
    {
        "wurli/cobalt.nvim",
        config = function()
            vim.cmd[[colorscheme cobalt]]
        end
    },
    {
        "nvim-lualine/lualine.nvim",
        config = function()
            require("lualine").setup({
                options = { theme = "cobalt" },
                sections = {
                    -- show relative path, not just filename
                    lualine_c = {{ 'filename', path = 1 }},
                }
            })
        end,
    },
    {
        -- Colour hex codes like #000000
        "norcalli/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup()
        end
    },
}

