return {
    -- LSP Configuration & Plugins
    {
        -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
        -- used for completion, annotations and signatures of Neovim apis
        'folke/lazydev.nvim',
        cond = not vim.g.vscode,
        ft = 'lua',
        opts = {
            library = {
                -- Load luvit types when the `vim.uv` word is found
                { path = 'luvit-meta/library', words = { 'vim%.uv' } },
            },
        },
    },
    {
        'Bilal2453/luvit-meta',
        cond = not vim.g.vscode,
        lazy = true
    },
    {
        'neovim/nvim-lspconfig',
        cond = not vim.g.vscode,
        dependencies = {
            -- Automatically install LSPs and related tools to stdpath for Neovim
            { 'williamboman/mason.nvim' },
            { dir = "~/Repos/mason-lspconfig.nvim" },
            -- 'williamboman/mason-lspconfig.nvim',
            'WhoIsSethDaniel/mason-tool-installer.nvim',
            { 'j-hui/fidget.nvim', opts = {} },
            -- { "hrsh7th/cmp-nvim-lsp", "hrsh7th/nvim-cmp" },
        },
        config = function()
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
                callback = function(event)

                    local map = function(mode, keys, func, desc)
                        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                    end

                    local mapn = function(...) map("n", ...) end
                    local mapv = function(...) map({ "n", "v" }, ...) end

                    --  To jump back, press <C-t>.
                    mapn('gd',         require('telescope.builtin').lsp_definitions,                          'LSP: [G]oto [D]efinition')
                    mapn('gr',         require('telescope.builtin').lsp_references,                           'LSP: [G]oto [R]eferences')
                    mapn('gI',         require('telescope.builtin').lsp_implementations,                      'LSP: [G]oto [I]mplementation')
                    mapn('<leader>D',  require('telescope.builtin').lsp_type_definitions,                     'LSP: Type [D]efinition')
                    mapn('<leader>ds', require('telescope.builtin').lsp_document_symbols,                     'LSP: [D]ocument [S]ymbols')
                    mapn('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols,            'LSP: [W]orkspace [S]ymbols')
                    mapv("<leader>lf", vim.lsp.buf.format,                                                    'LSP: [L]sp [F]ormat')
                    mapn('<leader>rn', vim.lsp.buf.rename,                                                    'LSP: [R]e[n]ame')
                    mapn('<leader>ca', vim.lsp.buf.code_action,                                               'LSP: [C]ode [A]ction')
                    mapn('K',          vim.lsp.buf.hover,                                                     'LSP: Hover Documentation')
                    mapn('gD',         vim.lsp.buf.declaration,                                               'LSP: [G]oto [D]eclaration')
                    mapn('<leader>ld', vim.diagnostic.open_float,                                             'LSP: [L]sp [D]iagnostic')
                    mapn('<leader>td', function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end, 'LSP: [T]oggle [D]iagnostic')

                    -- 'On' settings for virual text and virtual lines
                    local virtual_text_on = { source = "if_many" }
                    local virtual_lines_on = {
                        format = function(d)
                            if d.source then
                                return ("[%s] %s"):format(d.source, d.message)
                            else
                                return d.message
                            end
                        end
                    }

                    -- Virtual text on and virtual lines off
                    mapn('<leader>tt', function()
                        vim.diagnostic.config({ virtual_text = not vim.diagnostic.config().virtual_text and virtual_text_on })
                        if vim.diagnostic.config().virtual_text then vim.diagnostic.config({ virtual_lines = false }) end
                    end, 'LSP: [T]oggle Virtual [T]ext')

                    -- Virtual lines on and virtual text off
                    mapn('<leader>tl', function()
                        vim.diagnostic.config({ virtual_lines = not vim.diagnostic.config().virtual_lines and virtual_lines_on })
                        if vim.diagnostic.config().virtual_lines then vim.diagnostic.config({ virtual_text = false }) end
                    end, 'LSP: [T]oggle Virtual [L]ines')

                    mapn(
                        '<leader>ts',
                        function() vim.diagnostic.config({ signs = not vim.diagnostic.config().signs }) end,
                        'LSP: [T]oggle [S]igns'
                    )

                    vim.diagnostic.config({
                        virtual_text = virtual_text_on,
                        virtual_lines = false,
                        signs = true,
                        update_in_insert = true
                    })

                    -- The following two autocommands are used to highlight references of the
                    -- word under your cursor when your cursor rests there for a little while.
                    --    See `:help CursorHold` for information about when this is executed
                    --
                    -- When you move your cursor, the highlights will be cleared (the second autocommand).
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, 0) then
                        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
                        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.document_highlight,
                        })

                        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.clear_references,
                        })

                        vim.api.nvim_create_autocmd('LspDetach', {
                            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                            callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
                            end,
                        })
                    end

                    -- The following code creates a keymap to toggle inlay hints in your
                    -- code, if the language server you are using supports them.
                    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                        mapn('<leader>th', function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                        end, '[T]oggle Inlay [H]ints')
                    end

                end,
            })

            -- LSP servers and clients are able to communicate to each other what features they support.
            --  By default, Neovim doesn't support everything that is in the LSP specification.
            --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
            --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            -- capabilities = require("blink.cmp").default_capabilities()
            -- require('blink.cmp').get_lsp_capabilities()

            local servers = {
                air = {},
                pyright = {
                    settings = {
                        pyright = {
                            disableOrganizeImports = true
                        },
                        python = {
                            analysis = {
                                -- -- For some reason these settings don't work here, only in pyrightconfig.json. This
                                -- -- seems to disagree with the docs here:
                                -- -- https://github.com/microsoft/pyright/blob/main/docs/import-resolution.md#configuring-your-python-environment
                                -- venvPath = ".",
                                -- venv = ".venv",
                                stubPath = vim.fn.stdpath("config") .. "/misc/python-typings",
                            }
                        }
                    }
                },
                ruff = {
                    capabilities = {
                        hoverProvider = false
                    }
                },
                rust_analyzer = {},
                lua_ls = {
                    settings = {
                        Lua = {
                            completion = {
                                callSnippet = 'Replace',
                            },
                        },
                    },
                },
                yamlls = {},

                -- r_language_server = {
                --     -- Turn off lintr because it's a bit slow and annoying for interactive use
                --     settings = {
                --         r = { lsp = { diagnostics = false, rich_documentation = false } }
                --     },
                --     on_attach = function(conf)
                --         -- Turn off lsp autcomplete (we're using cmp-r instead)
                --         conf.server_capabilities.completionProvider = false
                --         conf.server_capabilities.documentFormattingProvider = false
                --         conf.server_capabilities.documentRangeFormattingProvider = false
                --         return conf
                --     end,
                -- },
            }

            require('mason').setup()

            -- You can add other tools here that you want Mason to install for
            -- you, so that they are available from within Neovim.
            local ensure_installed = vim.tbl_keys(servers or {})
            vim.list_extend(ensure_installed, {
                'stylua',
            })
            require('mason-tool-installer').setup({
                ensure_installed = ensure_installed
            })

            require('mason-lspconfig').setup {
                handlers = {
                    function(server_name)
                        if server_name == "r_language_server" then
                            print("skipping r lsp setup")
                            return
                        end
                        local settings = servers[server_name] or {}
                        settings.capabilities = vim.tbl_deep_extend(
                            'force', {},
                            capabilities,
                            settings.capabilities or {}
                        )
                        require('lspconfig')[server_name].setup(settings)
                    end,
                },
            }

            -- -- Temporary VBA lsp setup
            -- local vba_server_path = "/Users/JACOB.SCOTT1/Repos/VBA-LanguageServer/dist/server/out/server.js"
            --
            -- vim.lsp.config.vbapro = {
            --     cmd = { 'node', vba_server_path, '--stdio' },
            --     filetypes = { 'vba', 'bas', 'cls', 'frm', 'freebasic' }, -- VBA file types
            --     -- root_dir = function(filename)
            --     --     return vim.fs.dirname(vim.fs.find(".git", { path = filename, upward = true })[1] or "")
            --     -- end,
            --     settings = {} -- Any specific settings the server might need
            -- }
            --
            -- vim.lsp.enable("vbapro")
        end,
    }
}

