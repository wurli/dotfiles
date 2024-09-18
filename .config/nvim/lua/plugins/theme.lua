return {
    {
        -- dir = "~/Repos/cobalt.nvim",
        "wurli/cobalt.nvim",
        cond = not vim.g.vscode,
        config = function()
            require("cobalt").setup({ })
            vim.cmd[[colorscheme cobalt]]
        end
    },
    {
        "nvim-lualine/lualine.nvim",
        cond = not vim.g.vscode,
        lazy = false,
        config = function()
            require("lualine").setup({
                options = {
                    theme = "cobalt",
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
        cond = not vim.g.vscode,
        config = function()
            require("colorizer").setup({ "*" }, {
                RGB      = true,  -- #RGB hex codes 
                RRGGBB   = true,  -- #RRGGBB hex codes like #000000
                names    = false, -- "Name" codes like 'Blue'
                RRGGBBAA = false, -- #RRGGBBAA hex codes
                rgb_fn   = false, -- CSS rgb() and rgba() functions
                hsl_fn   = false, -- CSS hsl() and hsla() functions
                css      = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
                css_fn   = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn

                -- Available modes: foreground, background
                mode     = 'background', -- Set the display mode.
            })
        end
    },
}

