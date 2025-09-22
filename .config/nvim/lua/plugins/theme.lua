---@diagnostic disable-next-line: unused-local
local cobalt = {
    "wurli/cobalt.nvim",
    -- dir = "~/Repos/cobalt.nvim/",
    config = function()
        require("cobalt").setup({})
        vim.cmd [[colorscheme cobalt]]
    end
}

local nightfox = {
    "EdenEast/nightfox.nvim",
    config = function()
        require("nightfox").setup({
            colorblind = {
                enable = true,
                severity = {
                    protan = 1,
                    tritan = 1,
                    deutan = 1
                }
            }
        })
        vim.cmd("colorscheme duskfox")
    end
}

---@diagnostic disable-next-line: unused-local
-- This theme is pretty good. But I don"t love the browny-grey background.
-- I"d prefer to look at a blueish theme which doesn"t feel like mould :)
local material = {
    "marko-cerovac/material.nvim",
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
        vim.cmd "colorscheme material"
    end
}

---@diagnostic disable-next-line: unused-local
-- This theme is pretty much ideal... Except that you can"t override specific
-- colours. If you could, I would absolutely change variables to be bright
-- white instead of grey. Just doesn"t *pop* in the way I want.
local night_owl = {
    "oxfist/night-owl.nvim",
    lazy = false,    -- make sure we load this during startup if it is your main colorscheme
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

local get_wordcount = function()
    local wordcount = vim.fn.wordcount()
    local mode = vim.fn.mode()
    if mode == "V" or mode == "v" then
        return string.format("w: %s/%s", wordcount.visual_words, wordcount.words)
    else
        return string.format("w: %s", wordcount.words)
    end
end
local get_charcount = function()
    local wordcount = vim.fn.wordcount()
    local mode = vim.fn.mode()
    if mode == "V" or mode == "v" then
        return string.format("c: %s/%s", wordcount.visual_chars, wordcount.chars)
    else
        return string.format("c: %s", wordcount.chars)
    end
end

return {
    vim.tbl_extend("keep", cobalt, { cond = not vim.g.vscode }),

    -- {
    --     -- Note: default hl is |hl-Whitespace|
    --     -- scope is |hl-LineNr|
    --     "lukas-reineke/indent-blankline.nvim",
    --     cond = not vim.g.vscode,
    --     opts = {
    --         indent = {
    --             char = "│",
    --             tab_char = "│",
    --         },
    --         scope = { show_start = false, show_end = false },
    --         exclude = {
    --             filetypes = {
    --                 "Trouble",
    --                 "alpha",
    --                 "dashboard",
    --                 "help",
    --                 "lazy",
    --                 "mason",
    --                 "neo-tree",
    --                 "notify",
    --                 "snacks_notif",
    --                 "snacks_terminal",
    --                 "snacks_win",
    --                 "toggleterm",
    --                 "trouble",
    --             },
    --         },
    --     },
    --     main = "ibl",
    -- },

    {
        "petertriho/nvim-scrollbar",
        cond = not vim.g.vscode,
        opts = {}
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
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    -- show relative path, not just filename
                    lualine_c = { { "filename", path = 1 } },
                    lualine_x = { "encoding", "fileformat", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" }
                },
                extensions = {
                    {
                        sections = {
                            lualine_a = { "mode" },
                            lualine_b = { "branch", "diff", "diagnostics" },
                            lualine_c = { { "filename", path = 1 } },
                            lualine_x = { get_wordcount, get_charcount },
                            lualine_y = { "progress" },
                            lualine_z = { "location" }
                        },
                        filetypes = { "markdown", "quarto", "txt" }
                    },
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
                names    = false, -- "Name" codes like "Blue"
                RRGGBBAA = true,  -- #RRGGBBAA hex codes
                rgb_fn   = false, -- CSS rgb() and rgba() functions
                hsl_fn   = false, -- CSS hsl() and hsla() functions
                css      = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
                css_fn   = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn

                -- Available modes: foreground, background
                mode     = "background", -- Set the display mode.
            })
        end
    },

    {
        "dimtion/guttermarks.nvim",
        event = "VeryLazy",
    }
}
