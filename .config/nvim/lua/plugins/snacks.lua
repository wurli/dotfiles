local pick = function(picker, opts)
    return function() Snacks.picker.pick(picker, opts or {}) end
end

local pick_files = function(opts)
    return function()
        Snacks.picker.files(vim.tbl_deep_extend("force", {
            actions = {
                ---@diagnostic disable-next-line: doc-field-no-class
                ---@field picker snacks.Picker
                toggle_sort = function(picker)
                    if picker.opts.sort.fields[1] == "score:desc" then
                        picker.opts.sort.fields = { "file:asc" }
                    else
                        picker.opts.sort.fields = { "score:desc", "#text", "idx" }
                    end
                    picker:close()
                    picker.new(vim.tbl_deep_extend('force', picker.opts, {
                        pattern = picker:filter().pattern,
                        search = picker:filter().search,
                    }))
                    -- picker:find({ refresh = true })
                end
            },
            win = {
                input = {
                    keys = {
                        ["<c-s>"] = { "toggle_sort", mode = { "i", "n" } }
                    }
                }
            },
            matcher = { sort_empty = true },
        }, opts or {}))
    end
end

-- Autocommands for Snacks-rename ---------------------------------------------
vim.api.nvim_create_autocmd("User", {
    pattern = "OilActionsPost",
    callback = function(event)
        if event.data.actions.type == "move" then
            Snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
        end
    end,
})

local prev = { new_name = "", old_name = "" } -- Prevents duplicate events
vim.api.nvim_create_autocmd("User", {
    pattern = "NvimTreeSetup",
    callback = function()
        local events = require("nvim-tree.api").events
        events.subscribe(events.Event.NodeRenamed, function(data)
            if prev.new_name ~= data.new_name or prev.old_name ~= data.old_name then
                data = data
                Snacks.rename.on_rename_file(data.old_name, data.new_name)
            end
        end)
    end,
})
-------------------------------------------------------------------------------

return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        dashboard = { enabled = false },
        input = { enabled = false },
        notifier = { enabled = false },
        quickfile = { enabled = false },
        scope = { enabled = false },
        scroll = { enabled = false },
        statuscolumn = { enabled = false },
        words = { enabled = false },
        bigfile = { enabled = false },
        explorer = { enabled = false },
        image = { enabled = not vim.g.vscode },
        rename = {
            enabled = not vim.g.vscode,
        },
        indent = {
            enabled = not vim.g.vscode,
            animate = { enabled = false },
            filter = function(buf)
                local disable_filetypes = {
                    "NvimTree",
                    "Trouble",
                    "help",
                    "lazy",
                    "mason",
                    "markdown",
                    "notify",
                    "oil",
                    "terminal",
                    "fidget"
                }
                for _, ft in ipairs(disable_filetypes) do
                    if vim.bo[buf].filetype == ft then return false end
                end
                return true
            end
        },
        picker = {
            enabled = not vim.g.vscode,
            actions = {
                open_in_app = function(_, item)
                    vim.system({ "open", item.file })
                end
            },
            win = {
                input = {
                    keys = {
                        ["<C-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
                        ["<C-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
                        ["<C-m>"] = { "toggle_maximise", mode = { "i", "n" } },
                        ["<C-a>"] = { "toggle_hidden", mode = { "i", "n" } },
                        ["<C-i>"] = { "toggle_ignored", mode = { "i", "n" } },
                        ["<C-o>"] = { "open_in_app", mode = { "i", "n" } },
                    }
                },
            }
        },
    },
    keys = {
        -- Top Pickers & Explorer
        -- { "<leader><space>", function() Snacks.picker.smart() end,                                                       desc = "Smart Find Files" },
        { "<leader>fb", pick("buffers"),                                                                                      desc = "Buffers" },
        -- { "<leader>/",       function() Snacks.picker.grep() end,                                                        desc = "Grep" },
        { "<leader>f:", pick("command_history"),                                                                              desc = "Command History" },
        -- { "<leader>n",       function() Snacks.picker.notifications() end,                                               desc = "Notification History" },
        -- { "<C-n>",      function() Snacks.explorer() end,                                                                     desc = "File Explorer" },
        -- -- find
        { "<leader>fb", pick("buffers"),                                                                                      desc = "Buffers" },
        { "<leader>fc", pick("files", { cwd = "~/Repos/dotfiles/", hidden = true }),                                          desc = "Find Config File" },
        { "<leader>fn", pick("files", { cwd = vim.fn.stdpath("config") }),                                                    desc = "Find Nvim Config File" },
        { "<leader>fp", pick("files", { cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy") }),                             desc = "Find Config File" },
        -- { "<leader>ff", pick("files"),                                                                                        desc = "Find Files" },
        { "<leader>ff", pick_files(),                                                                                         desc = "Find Files" },
        -- { "<leader>fg",      function() Snacks.picker.git_files() end,                                                   desc = "Find Git Files" },
        -- { "<leader>fp",      function() Snacks.picker.projects() end,                                                    desc = "Projects" },
        -- { "<leader>fr",      function() Snacks.picker.recent() end,                                                      desc = "Recent" },
        -- -- git
        { "<leader>ft", pick("git_branches"),                                                                                 desc = "Git Branches" },
        { "<leader>fl", pick("git_log"),                                                                                      desc = "Git Log" },
        -- { "<leader>gL",      function() Snacks.picker.git_log_line() end,                                                desc = "Git Log Line" },
        -- { "<leader>gs",      function() Snacks.picker.git_status() end,                                                  desc = "Git Status" },
        -- { "<leader>gS",      function() Snacks.picker.git_stash() end,                                                   desc = "Git Stash" },
        -- { "<leader>gd",      function() Snacks.picker.git_diff() end,                                                    desc = "Git Diff (Hunks)" },
        { "<leader>fL", pick("git_log_file"),                                                                                 desc = "Git Log File" },
        -- -- Grep
        -- { "<leader>sb",      function() Snacks.picker.lines() end,                                                       desc = "Buffer Lines" },
        -- { "<leader>sB",      function() Snacks.picker.grep_buffers() end,                                                desc = "Grep Open Buffers" },
        { "<leader>fg", pick("grep"),                                                                                         desc = "Grep" },
        -- { "<leader>sw",      function() Snacks.picker.grep_word() end,                                                   desc = "Visual selection or word", mode = { "n", "x" } },
        -- -- search
        { "<leader>fr", pick("registers"),                                                                                    desc = "Registers" },
        { "<leader>f/", pick("search_history"),                                                                               desc = "Search History" },
        -- { "<leader>sa",      function() Snacks.picker.autocmds() end,                                                    desc = "Autocmds" },
        -- { "<leader>sb",      function() Snacks.picker.lines() end,                                                       desc = "Buffer Lines" },
        -- { "<leader>sc",      function() Snacks.picker.command_history() end,                                             desc = "Command History" },
        -- { "<leader>sC",      function() Snacks.picker.commands() end,                                                    desc = "Commands" },
        -- { "<leader>sd",      function() Snacks.picker.diagnostics() end,                                                 desc = "Diagnostics" },
        -- { "<leader>sD",      function() Snacks.picker.diagnostics_buffer() end,                                          desc = "Buffer Diagnostics" },
        { "<leader>fh", pick("help", { win = { input = { keys = { ["<CR>"] = { "edit_vsplit", mode = { "i", "n" } } } } } }), desc = "Help Pages" },
        { "<leader>fH", function() Snacks.picker.highlights() end,                                                            desc = "Highlights" },
        -- { "<leader>si",      function() Snacks.picker.icons() end,                                                       desc = "Icons" },
        -- { "<leader>sj",      function() Snacks.picker.jumps() end,                                                       desc = "Jumps" },
        { "<leader>fk", pick("keymaps"),                                                                                      desc = "Keymaps" },
        -- { "<leader>sl",      function() Snacks.picker.loclist() end,                                                     desc = "Location List" },
        { "<leader>fm", pick("marks"),                                                                                        desc = "Marks" },
        { "<leader>fM", pick("man", { win = { input = { keys = { ["<CR>"] = { "edit_vsplit", mode = { "i", "n" } } } } } }),  desc = "Man Pages" },
        -- { "<leader>sp",      function() Snacks.picker.lazy() end,                                                        desc = "Search for Plugin Spec" },
        -- { "<leader>sq",      function() Snacks.picker.qflist() end,                                                      desc = "Quickfix List" },
        -- { "<leader>sR",      function() Snacks.picker.resume() end,                                                      desc = "Resume" },
        { "<leader>fu", pick("undo"),                                                                                         desc = "Undo History" },
        -- { "<leader>uC",      function() Snacks.picker.colorschemes() end,                                                desc = "Colorschemes" },
        -- -- LSP
        { "<leader>gd", pick("lsp_definitions"),                                                                              desc = "Goto Definition" },
        -- { "gD",              function() Snacks.picker.lsp_declarations() end,                                            desc = "Goto Declaration" },
        { "<leader>gr", pick("lsp_references"),                                                                               desc = "References" },
        { "<leader>gi", pick("lsp_implementations"),                                                                          desc = "Goto [I]mplementation" },
        { "<leader>gt", pick("lsp_type_definitions"),                                                                         desc = "Goto T[y]pe Definition" },
        { "<leader>fS", pick("lsp_symbols"),                                                                                  desc = "LSP Symbols" },
        { "<leader>fs", pick("lsp_workspace_symbols"),                                                                        desc = "LSP Workspace Symbols" },
    },
}
