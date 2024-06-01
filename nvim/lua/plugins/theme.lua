return {
    -- {
    --     dir = "~/Repos/cobalt.nvim",
    --     event = { "ColorSchemePre" }, -- if you want to lazy load
    --     dependencies = { "tjdevries/colorbuddy.nvim", tag = "v1.0.0" },
    --     init = function()
    --         require("colorbuddy").colorscheme("cobalt2")
    --     end,
    -- },
    -- {
    --     -- dir = "~/Repos/cobalt.nvim",
    --     "wurli/cobalt.nvim",
    --     config = function()
    --         vim.cmd[[colorscheme cobalt]]
    --     end
    -- },
    {
        "oxfist/night-owl.nvim",
        lazy = false, -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            -- load the colorscheme here
            require("night-owl").setup()
            vim.cmd.colorscheme("night-owl")
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        lazy = false,
        config = function()
            require("lualine").setup({
                options = {
                    theme = "night-owl",
                    section_separators = "",
                },
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

