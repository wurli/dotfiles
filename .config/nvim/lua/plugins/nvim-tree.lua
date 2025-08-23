return {
    "nvim-tree/nvim-tree.lua",
    cond = not vim.g.vscode,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local api = require("nvim-tree.api")
        require("nvim-tree").setup {
            on_attach = function(bufnr)
                api.config.mappings.default_on_attach(bufnr)
                vim.keymap.del("n", "<c-k>", { buffer = bufnr })

                for key, cmd in pairs({
                    ["<c-j>"] = "normal! j",
                    ["<c-k>"] = "normal! k"
                }) do
                    vim.keymap.set("n", key, function()
                        vim.cmd(cmd)
                        if api.tree.get_node_under_cursor().type == "file" then
                            api.node.open.preview()
                        end
                    end, { buffer = bufnr })
                end

                vim.keymap.set("n", "<c-p>", function()
                    local node = api.tree.get_node_under_cursor()
                    if node.type == "file" then
                        local ok, line = pcall(function()
                            return vim.api.nvim_win_get_cursor(vim.fn.bufwinid(vim.fn.bufnr(node.absolute_path)))[1]
                        end)

                        local path = ok and (node.absolute_path .. ":" .. line) or node.absolute_path
                        vim.system({ "positron", "--goto", path, vim.fn.getcwd() })
                    end
                end, { buffer = bufnr })
            end,
            modified = { enable = true },
            renderer = {
                icons = {
                    modified_placement = "before",
                    git_placement = "after"
                },
            },
            update_focused_file = { enable = true },
            filters = {
                git_ignored = false,
                custom = {
                    ".DS_Store$",
                }
            },
            actions = {
                open_file = {
                    resize_window = false
                }
            }
        }
        vim.keymap.set({ "n", "i" }, "<C-n>", api.tree.toggle)
    end
}


