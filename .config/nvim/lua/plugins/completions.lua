return {
    {
        'saghen/blink.cmp',
        lazy = false, -- lazy loading handled internally
        -- optional: provides snippets for the snippet source
        -- dependencies = 'rafamadriz/friendly-snippets',

        -- use a release tag to download pre-built binaries
        version = 'v0.*',
        -- OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
        -- build = 'cargo build --release',
        -- If you use nix, you can build from source using latest nightly rust with:
        -- build = 'nix run .#build-plugin',

        dependencies = {
        },

        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        ---@diagnostic disable: missing-fields
        opts = {
            -- 'default' for mappings similar to built-in completion
            -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
            -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
            -- see the "default configuration" section below for full documentation on how to define
            -- your own keymap.
            keymap = {
                preset = "default",
                ['<C-l>'] = { 'snippet_forward', 'fallback' },
                ['<C-h>'] = { 'snippet_backward', 'fallback' },
                ['<Tab>'] = { 'select_and_accept' },
            },
            completion = {
                list = {
                    selection = "manual"
                }
            },
            appearance = {
                nerd_font_variant = 'mono'
            },
            --
            -- default list of enabled providers defined so that you can extend it
            -- elsewhere in your config, without redefining it, via `opts_extend`
            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer' },
                -- optionally disable cmdline completions
                -- cmdline = {},
            },
            --
            -- experimental signature help support
            -- signature = { enabled = true }
        },
        -- allows extending the providers array elsewhere in your config
        -- without having to redefine it
        opts_extend = {
            "sources.default"
        }
    },
    -- {
    --     'hrsh7th/nvim-cmp',
    --     cond = not vim.g.vscode and false,
    --     event = 'InsertEnter',
    --     dependencies = {
    --         -- Snippet Engine & its associated nvim-cmp source
    --         {
    --             'L3MON4D3/LuaSnip',
    --             build = (function()
    --                 -- Build Step is needed for regex support in snippets.
    --                 -- This step is not supported in many windows environments.
    --                 -- Remove the below condition to re-enable on windows.
    --                 if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
    --                     return
    --                 end
    --                 return 'make install_jsregexp'
    --             end)(),
    --             dependencies = {
    --                 -- `friendly-snippets` contains a variety of premade snippets.
    --                 --    See the README about individual language/framework/plugin snippets:
    --                 --    https://github.com/rafamadriz/friendly-snippets
    --                 -- {
    --                 --   'rafamadriz/friendly-snippets',
    --                 --   config = function()
    --                 --     require('luasnip.loaders.from_vscode').lazy_load()
    --                 --   end,
    --                 -- },
    --             },
    --         },
    --         'saadparwaiz1/cmp_luasnip',
    --
    --         -- Adds other completion capabilities.
    --         --  nvim-cmp does not ship with all sources by default. They are split
    --         --  into multiple repos for maintenance purposes.
    --         'hrsh7th/cmp-nvim-lsp',
    --         'hrsh7th/cmp-path',
    --         "R-nvim/cmp-r",
    --     },
    --     config = function()
    --         -- See `:help cmp`
    --         local cmp = require 'cmp'
    --         local luasnip = require 'luasnip'
    --         luasnip.config.setup {}
    --         cmp.setup {
    --             snippet = {
    --                 expand = function(args)
    --                     luasnip.lsp_expand(args.body)
    --                 end,
    --             },
    --             -- This should in theory:
    --             completion = { completeopt = 'menu,menuone,noselect' },
    --
    --             -- For an understanding of why these mappings were
    --             -- chosen, you will need to read `:help ins-completion`
    --             --
    --             -- No, but seriously. Please read `:help ins-completion`, it is really good!
    --             mapping = cmp.mapping.preset.insert {
    --                 ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
    --                 -- Select the [p]revious item
    --                 ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
    --
    --                 -- Scroll the documentation window [b]ack / [f]orward
    --                 ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    --                 ['<C-f>'] = cmp.mapping.scroll_docs(4),
    --
    --                 -- Accept ([y]es) the completion.
    --                 --  This will auto-import if your LSP supports it.
    --                 --  This will expand snippets if the LSP sent a snippet.
    --                 -- ['<C-y>'] = cmp.mapping.confirm { select = true },
    --                 ['<tab>'] = cmp.mapping.confirm { select = true },
    --                 ['<cr>'] = cmp.mapping.confirm { select = false },
    --
    --                 -- Manually trigger a completion from nvim-cmp.
    --                 --  Generally you don't need this, because nvim-cmp will display
    --                 --  completions whenever it has completion options available.
    --                 ['<C-Space>'] = cmp.mapping.complete {},
    --
    --                 -- Think of <c-l> as moving to the right of your snippet expansion.
    --                 --  So if you have a snippet that's like:
    --                 --  function $name($args)
    --                 --    $body
    --                 --  end
    --                 --
    --                 -- <c-l> will move you to the right of each of the expansion locations.
    --                 -- <c-h> is similar, except moving you backwards.
    --                 ['<C-l>'] = cmp.mapping(function()
    --                     if luasnip.expand_or_locally_jumpable() then
    --                         luasnip.expand_or_jump()
    --                     end
    --                 end, { 'i', 's' }),
    --                 ['<C-k>'] = cmp.mapping(function()
    --                     if luasnip.locally_jumpable(-1) then
    --                         luasnip.jump(-1)
    --                     end
    --                 end, { 'i', 's' }),
    --                 --
    --                 -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
    --                 --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
    --             },
    --             sources = {
    --                 { name = 'nvim_lsp' },
    --                 { name = 'luasnip' },
    --                 { name = 'path' },
    --                 { name = 'cmp_r' }
    --             },
    --         }
    --
    --         for _, ftpath in ipairs(vim.api.nvim_get_runtime_file("lua/custom/snippets/*.lua", true)) do
    --             loadfile(ftpath)()
    --         end
    --     end,
    -- }
}
