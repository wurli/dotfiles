---@diagnostic disable-next-line: unused-local
local cobalt = {
    -- dir = "~/Repos/cobalt.nvim",
    "wurli/cobalt.nvim",
    cond = not vim.g.vscode,
    config = function()
        require("cobalt").setup({ })
        vim.cmd[[colorscheme cobalt]]
    end
}

---@diagnostic disable-next-line: unused-local
local material = {
    'marko-cerovac/material.nvim',
    config = function()
        require("material").setup({
            high_visibility = {
                darker = true
            },
            plugins = {
                "harpoon",
                "neogit",
                "telescope"
            },
            custom_colors = function(clr)
                clr.editor.fg_dark  = clr.editor.fg
                clr.editor.fg       = clr.main.white
                clr.syntax.variable = clr.main.white
                clr.syntax.field    = clr.main.white
            end
        })
        vim.g.material_style = "darker"
        vim.cmd 'colorscheme material'
    end
}

return {
    material,
    {
        "lukas-reineke/indent-blankline.nvim",
        cond = not vim.g.vscode,
        opts = {
            indent = {
                char = "│",
                tab_char = "│",
            },
            scope = { show_start = false, show_end = false },
            exclude = {
                filetypes = {
                    "Trouble",
                    "alpha",
                    "dashboard",
                    "help",
                    "lazy",
                    "mason",
                    "neo-tree",
                    "notify",
                    "snacks_notif",
                    "snacks_terminal",
                    "snacks_win",
                    "toggleterm",
                    "trouble",
                },
            },
        },
        main = "ibl",
    },
    {
        "nvim-lualine/lualine.nvim",
        cond = not vim.g.vscode,
        lazy = false,
        config = function()
            require("lualine").setup({
                options = {
                    theme = "material",
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

