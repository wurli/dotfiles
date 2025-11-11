local n = 0
return {
    {
        "saghen/blink.compat",
        version = "*",
        lazy = true,
        opts = { impersonate_nvim_cmp = true },
    },
    {
        "saghen/blink.cmp",
        cond = not vim.g.vscode,
        lazy = false, -- lazy loading handled internally
        -- dependencies = "rafamadriz/friendly-snippets",
        dependencies = {
            { "L3MON4D3/LuaSnip", version = "v2.*" },
            -- { "R-nvim/cmp-r", opts = {} },
        },
        version = "v0.*",
        ---@module "blink.cmp"
        ---@type blink.cmp.Config
        ---@diagnostic disable: missing-fields
        opts = {
            keymap = {
                preset = "default",
                ["<C-l>"] = { "snippet_forward", "fallback" },
                ["<C-h>"] = { "snippet_backward", "fallback" },
            },
            completion = {
                list = {
                    selection = { preselect = false, auto_insert = false }
                }
            },
            signature = { enabled = true },
            snippets = { preset = "luasnip" },
            appearance = { nerd_font_variant = "mono" },
            sources = {
                default = {
                    "snippets",
                    "lsp",
                    "path",
                    "buffer",
                    -- "cmp_r"
                },
                providers = {
                    path = {
                        opts = {
                            -- Always use the CWD rather than the current
                            -- buffer's parent directory
                            get_cwd = function(_) return vim.fn.getcwd() end,
                            show_hidden_files_by_default = true,
                            trailing_slash = false,
                        },
                    },
                }
                -- providers = {
                --     cmp_r = {
                --         name = "cmp_r",
                --         module = "blink.compat.source",
                --         opts = {}
                --     }
                -- }
            },
            fuzzy = {
                -- Always prioritise snippets if available
                -- sorts = {
                --     function(a, b)
                --         if a.source_id == "snippets" and b.source_id ~= "snippets" then
                --             -- prioritise a
                --             return true
                --         elseif a.source_id ~= "snippets" and b.source_id == "snippets" then
                --             -- prioritise b
                --             return false
                --         else
                --             -- fallback to default
                --             return nil
                --         end
                --     end
                -- }
            }
        },
        -- allows extending the providers array elsewhere in your config
        -- without having to redefine it
        opts_extend = {
            "sources.default"
        }
    },
    --     Snippet Engine & its associated nvim-cmp source
    --     {
    --         "L3MON4D3/LuaSnip",
    --         build = (
    --             function()
    --                 -- Build Step is needed for regex support in snippets.
    --                 -- This step is not supported in many windows environments.
    --                 -- Remove the below condition to re-enable on windows.
    --                 if vim.fn.has "win32" == 1 or vim.fn.executable "make" == 0 then
    --                     return
    --                 end
    --                 return "make install_jsregexp"
    --             end
    --         )(),
    --     },
    --     {
    --         "hrsh7th/nvim-cmp",
    --         cond = not vim.g.vscode,
    --         event = "InsertEnter",
    --         dependencies = {
    --             "saadparwaiz1/cmp_luasnip",
    --             "hrsh7th/cmp-nvim-lsp",
    --             "hrsh7th/cmp-path",
    --             -- "R-nvim/cmp-r",
    --         },
    --         config = function()
    --             -- See `:help cmp`
    --             local cmp = require "cmp"
    --             local luasnip = require "luasnip"
    --             luasnip.config.setup {}
    --             cmp.setup {
    --                 snippet = {
    --                     expand = function(args)
    --                         luasnip.lsp_expand(args.body)
    --                     end,
    --                 },
    --                 -- This should in theory:
    --                 completion = { completeopt = "menu,menuone,noselect" },
    --
    --                 -- For an understanding of why these mappings were
    --                 -- chosen, you will need to read `:help ins-completion`
    --                 --
    --                 -- No, but seriously. Please read `:help ins-completion`, it is really good!
    --                 mapping = cmp.mapping.preset.insert {
    --                     ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
    --                     -- Select the [p]revious item
    --                     ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
    --
    --                     -- Scroll the documentation window [b]ack / [f]orward
    --                     ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    --                     ["<C-f>"] = cmp.mapping.scroll_docs(4),
    --
    --                     -- Accept ([y]es) the completion.
    --                     --  This will auto-import if your LSP supports it.
    --                     --  This will expand snippets if the LSP sent a snippet.
    --                     -- ["<C-y>"] = cmp.mapping.confirm { select = true },
    --                     ["<tab>"] = cmp.mapping.confirm { select = true },
    --                     ["<cr>"] = cmp.mapping.confirm { select = false },
    --
    --                     -- Manually trigger a completion from nvim-cmp.
    --                     --  Generally you don"t need this, because nvim-cmp will display
    --                     --  completions whenever it has completion options available.
    --                     ["<C-Space>"] = cmp.mapping.complete {},
    --
    --                     -- Think of <c-l> as moving to the right of your snippet expansion.
    --                     --  So if you have a snippet that"s like:
    --                     --  function $name($args)
    --                     --    $body
    --                     --  end
    --                     --
    --                     -- <c-l> will move you to the right of each of the expansion locations.
    --                     -- <c-h> is similar, except moving you backwards.
    --                     ["<C-l>"] = cmp.mapping(function()
    --                         if luasnip.expand_or_locally_jumpable() then
    --                             luasnip.expand_or_jump()
    --                         end
    --                     end, { "i", "s" }),
    --                     ["<C-k>"] = cmp.mapping(function()
    --                         if luasnip.locally_jumpable(-1) then
    --                             luasnip.jump(-1)
    --                         end
    --                     end, { "i", "s" }),
    --                     --
    --                     -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
    --                     --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
    --                 },
    --                 sources = {
    --                     { name = "nvim_lsp" },
    --                     { name = "luasnip" },
    --                     { name = "path" },
    --                     { name = "cmp_r" }
    --                 },
    --             }
    --
    --             for _, ftpath in ipairs(vim.api.nvim_get_runtime_file("lua/custom/snippets/*.lua", true)) do
    --                 loadfile(ftpath)()
    --             end
    --         end,
    --     }
}
