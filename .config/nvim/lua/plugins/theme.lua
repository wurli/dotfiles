---@diagnostic disable-next-line: unused-local
local cobalt = {
    dir = "~/Repos/cobalt.nvim",
    -- "wurli/cobalt.nvim",
    cond = not vim.g.vscode,
    config = function()
        require("cobalt").setup({ })
        vim.cmd[[colorscheme cobalt]]
    end
}

---@diagnostic disable-next-line: unused-local
-- This theme is pretty good. But I don't love the browny-grey background.
-- I'd prefer to look at a blueish theme which doesn't feel like mould :)
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

---@diagnostic disable-next-line: unused-local
-- This theme is pretty much ideal... Except that you can't override specific
-- colours. If you could, I would absolutely change variables to be bright
-- white instead of grey. Just doesn't *pop* in the way I want.
local night_owl = {
    "oxfist/night-owl.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
        -- load the colorscheme here
        require("night-owl").setup()
        vim.cmd.colorscheme("night-owl")
    end,
}

---@diagnostic disable-next-line: unused-local
local rose_pine = {
	"rose-pine/neovim",
	name = "rose-pine",
	config = function()
        require("rose-pine").setup({
            palette = {
                main = {
                    ----------------
                    --- Defaults ---
                    ----------------
                    -- _nc            = "#16141f",
                    -- base           = "#191724",
                    -- surface        = "#1f1d2e",
                    -- overlay        = "#26233a", -- Current line hightlight, indentation guides
                    -- muted          = "#6e6a86",
                    -- subtle         = "#908caa", -- Comments, logical operators
                    -- text           = "#e0def4",
                    -- love           = "#eb6f92",
                    -- gold           = "#f6c177",
                    -- rose           = "#ebbcba",
                    -- pine           = "#31748f", -- Variables
                    -- foam           = "#9ccfd8",
                    -- iris           = "#c4a7e7",
                    -- leaf           = "#95b1ac",
                    -- highlight_low  = "#21202e",
                    -- highlight_med  = "#403d52",
                    -- highlight_high = "#524f67",
                    -- none           = "NONE",
                    -------------------
                    --- Adjustments ---
                    -------------------
                    overlay = "#322f4d",
                    pine = "#c3ebfc"
                }
            },
            highlight_groups = {
                ["@markup.strong"] = { fg = "rose" },
                ["@markup.italic"] = { fg = "iris" },
                ["@markup.raw"]    = { fg = "leaf" },
                ["@markup.quote"]  = { fg = "subtle", italic = true }
            }
        })
		vim.cmd("colorscheme rose-pine")
	end
}

return {
    cobalt,
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

