local pick = function(picker, opts)
    return function() Snacks.picker.pick(picker, opts or {}) end
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
        explorer = { enabled = false },
        input = { enabled = false },
        notifier = { enabled = false },
        quickfile = { enabled = false },
        scope = { enabled = false },
        scroll = { enabled = false },
        statuscolumn = { enabled = false },
        words = { enabled = false },
        bigfile = { enabled = true },
        rename = {
            enabled = true,
        },
        indent = {
            enabled = not vim.g.vscode,
            animate = { enabled = false },
        },
        picker = {
            enabled = not vim.g.vscode,
            win = {
                input = {
                    keys = {
                        ["<C-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
                        ["<C-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
                        ["<C-m>"] = { "toggle_maximise", mode = { "i", "n" } },
                        ["<C-a>"] = { "toggle_hidden", mode = { "i", "n" } },
                        ["<C-i>"] = { "toggle_ignored", mode = { "i", "n" } },
                    }
                }
            }
        },
    },
    keys = {
        -- Top Pickers & Explorer
        -- { "<leader><space>", function() Snacks.picker.smart() end,                                                       desc = "Smart Find Files" },
        { "<leader>fb", pick("buffers"),                                                                                      desc = "Buffers" },
        -- { "<leader>/",       function() Snacks.picker.grep() end,                                                        desc = "Grep" },
        -- { "<leader>:",       function() Snacks.picker.command_history() end,                                             desc = "Command History" },
        -- { "<leader>n",       function() Snacks.picker.notifications() end,                                               desc = "Notification History" },
        -- { "<leader>e",       function() Snacks.explorer() end,                                                           desc = "File Explorer" },
        -- -- find
        { "<leader>fb", pick("buffers"),                                                                                      desc = "Buffers" },
        { "<leader>fc", pick("files", { cwd = vim.fn.stdpath("config") }),                                                    desc = "Find Config File" },
        { "<leader>fp", pick("files", { cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy") }),                             desc = "Find Config File" },
        { "<leader>ff", pick("files"),                                                                                        desc = "Find Files" },
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
        { "<leader>gL", pick("git_log_file"),                                                                                 desc = "Git Log File" },
        -- -- Grep
        -- { "<leader>sb",      function() Snacks.picker.lines() end,                                                       desc = "Buffer Lines" },
        -- { "<leader>sB",      function() Snacks.picker.grep_buffers() end,                                                desc = "Grep Open Buffers" },
        { "<leader>fg", pick("grep"),                                                                                         desc = "Grep" },
        -- { "<leader>sw",      function() Snacks.picker.grep_word() end,                                                   desc = "Visual selection or word", mode = { "n", "x" } },
        -- -- search
        { "<leader>fr", pick("registers"),                                                                                    desc = "Registers" },
        -- { '<leader>s/',      function() Snacks.picker.search_history() end,                                              desc = "Search History" },
        -- { "<leader>sa",      function() Snacks.picker.autocmds() end,                                                    desc = "Autocmds" },
        -- { "<leader>sb",      function() Snacks.picker.lines() end,                                                       desc = "Buffer Lines" },
        -- { "<leader>sc",      function() Snacks.picker.command_history() end,                                             desc = "Command History" },
        -- { "<leader>sC",      function() Snacks.picker.commands() end,                                                    desc = "Commands" },
        -- { "<leader>sd",      function() Snacks.picker.diagnostics() end,                                                 desc = "Diagnostics" },
        -- { "<leader>sD",      function() Snacks.picker.diagnostics_buffer() end,                                          desc = "Buffer Diagnostics" },
        { "<leader>fh", pick("help", { win = { input = { keys = { ["<CR>"] = { "edit_vsplit", mode = { "i", "n" } } } } } }), desc = "Help Pages" },
        -- { "<leader>sH",      function() Snacks.picker.highlights() end,                                                  desc = "Highlights" },
        -- { "<leader>si",      function() Snacks.picker.icons() end,                                                       desc = "Icons" },
        -- { "<leader>sj",      function() Snacks.picker.jumps() end,                                                       desc = "Jumps" },
        { "<leader>fk", pick("keymaps"),                                                                                      desc = "Keymaps" },
        -- { "<leader>sl",      function() Snacks.picker.loclist() end,                                                     desc = "Location List" },
        { "<leader>fm", pick("marks"),                                                                                        desc = "Marks" },
        { "<leader>fM", pick("man"),                                                                                          desc = "Man Pages" },
        -- { "<leader>sp",      function() Snacks.picker.lazy() end,                                                        desc = "Search for Plugin Spec" },
        -- { "<leader>sq",      function() Snacks.picker.qflist() end,                                                      desc = "Quickfix List" },
        -- { "<leader>sR",      function() Snacks.picker.resume() end,                                                      desc = "Resume" },
        -- { "<leader>su",      function() Snacks.picker.undo() end,                                                        desc = "Undo History" },
        -- { "<leader>uC",      function() Snacks.picker.colorschemes() end,                                                desc = "Colorschemes" },
        -- -- LSP
        { "gd",         pick("lsp_definitions"),                                                                              desc = "Goto Definition" },
        -- { "gD",              function() Snacks.picker.lsp_declarations() end,                                            desc = "Goto Declaration" },
        { "gr",         pick("lsp_references"),                                                                               desc = "References" },
        { "gI",         pick("lsp_implementations"),                                                                          desc = "Goto Implementation" },
        { "gT",         function() Snacks.picker.lsp_type_definitions() end,                                                  desc = "Goto T[y]pe Definition" },
        -- { "<leader>ss",      function() Snacks.picker.lsp_symbols() end,                                                 desc = "LSP Symbols" },
        { "<leader>fs", pick("lsp_workspace_symbols"),                                                                        desc = "LSP Workspace Symbols" },
    },
}
