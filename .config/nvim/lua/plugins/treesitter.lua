return { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects"
    },
    opts = {
        ensure_installed = {
            "bash", "c", "html", "lua", "luadoc", "markdown",
            "markdown_inline", "python", "r", "rnoweb", "vim", "vimdoc"
        },
        -- Autoinstall languages that are not installed
        auto_install = true,
        highlight = {
            enable = true,
            disable = { "csv" },
            -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
            --  If you are experiencing weird indenting issues, add the language to
            --  the list of additional_vim_regex_highlighting and disabled languages for indent.
            additional_vim_regex_highlighting = { "ruby" },
        },
        indent = {
            enable = true,
            disable = { "ruby", "markdown" }
        },
        textobjects = {
            -- enable = true,
            select = {
                enable = true,

                -- Automatically jump forward to textobj, similar to targets.vim
                lookahead = true,

                keymaps = {
                    -- You can use the capture groups defined in textobjects.scm
                    ["af"] = "@function.outer",
                    ["if"] = "@function.inner",
                    ["ar"] = "@parameter.outer",
                    ["ir"] = "@parameter.inner",
                    ["ac"] = "@class.outer",
                    -- You can optionally set descriptions to the mappings (used in the desc parameter of
                    -- nvim_buf_set_keymap) which plugins like which-key display
                    ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
                    -- You can also use captures from other query groups like `locals.scm`
                    ["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },
                },
                -- You can choose the select mode (default is charwise 'v')
                --
                -- Can also be a function which gets passed a table with the keys
                -- * query_string: eg '@function.inner'
                -- * method: eg 'v' or 'o'
                -- and should return the mode ('v', 'V', or '<c-v>') or a table
                -- mapping query_strings to modes.
                selection_modes = {
                    ['@parameter.outer'] = 'v', -- charwise
                    ['@function.outer'] = 'V', -- linewise
                    ['@class.outer'] = '<c-v>', -- blockwise
                },
            },
        },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "tis",
                node_incremental = "ni",
                scope_incremental = "si",
                node_decremental = "nd",
            },
        },
    },
    config = function(_, opts)
        ---@diagnostic disable-next-line: missing-fields
        require('nvim-treesitter.configs').setup(opts)
        vim.treesitter.language.register("r", "R")
    end,
}

