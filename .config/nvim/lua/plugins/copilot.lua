vim.keymap.set("n", "<leader><leader>c", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Code companion chat" })
vim.keymap.set("n", "<leader>fa", "<cmd>CodeCompanionActions<cr>", { desc = "Code completion actions" })
vim.cmd([[cnoreabbrev CC CodeCompanion]])
vim.cmd([[cnoreabbrev CB CodeCompanion #buffer]])
vim.cmd([[cnoreabbrev CE Copilot enable]])
vim.cmd([[cnoreabbrev CD Copilot disable]])

-- return {
--     {
--         "zbirenbaum/copilot.lua",
--         cmd = "Copilot",
--         event = "InsertEnter",
--         cond = not vim.g.vscode,
--         dependencies = { "copilotlsp-nvim/copilot-lsp" },
--         config = {
--             filetypes = {
--                 markdown = false,
--             },
--             suggestion = {
--                 enabled = true,
--                 -- Autotrigger off is nice... But the manual trigger just takes
--                 -- so long to execute :(
--                 auto_trigger = true,
--                 keymap = {
--                     accept = "<m-y>",
--                     accept_word = "<m-i>",
--                     accept_line = false,
--                     next = "<m-]>",
--                     prev = "<m-[>",
--                     dismiss = "<c-]>",
--                 }
--             },
--             nes = {
--                 enabled = false,
--                 auto_trigger = false,
--                 keymap = {
--                     accept_and_goto = "<m-y>",
--                     accept = false,
--                     dismiss = "<c-]>",
--                 }
--             },
--         },
--         keys = {
--             { "<leader>ct", "<cmd>Copilot toggle<cr>", desc = "Copilot toggle" }
--         }
--     },
--     {
--         "olimorris/codecompanion.nvim",
--         cond = not vim.g.vscode,
--         dependencies = {
--             "nvim-lua/plenary.nvim",
--             "nvim-treesitter/nvim-treesitter",
--             "j-hui/fidget.nvim",
--         },
--         init = function()
--             require("utils.codecompanion-fidget-spinner"):init()
--         end,
--         opts = {
--             strategies = {
--                 -- Change the default chat adapter
--                 chat = {
--                     adapter = "copilot",
--                     keymaps = {
--                         -- I don't think there's a way to remove the insert
--                         -- mode keymap altogether
--                         close = { modes = { i = "<m-q>", n = "<m-q>" } }
--                     }
--                 },
--                 inline = { adapter = "copilot" },
--             },
--             adapters = {
--                 copilot = function()
--                     return require("codecompanion.adapters").extend("copilot", {
--                         schema = {
--                             model = {
--                                 -- default = "claude-3.7-sonnet",
--                                 default = "claude-sonnet-4",
--                             },
--                         },
--                     })
--                 end
--             },
--             display = {
--                 chat = {
--                     window = {
--                         opts = {
--                             number = false,
--                             relativenumber = false
--                         }
--                     }
--                 },
--                 diff = {
--                     -- I really want to use this, but it just feels like it gets
--                     -- in the way :'(
--                     enabled = false,
--                     provider = "default",
--                     opts = { "algorithm:patience" }
--                 }
--             }
--         },
--     },
-- }

-- -- Hack to delete the autocommand which sidekick uses to automatically enter
-- -- insert mode when opening the CLI. Unfortunately folke doesn't (currently)
-- -- want to make this configurable:
-- -- https://github.com/folke/sidekick.nvim/issues/35
-- vim.api.nvim_create_autocmd("User", {
--     pattern = "LazyLoad",
--     callback = function(e)
--         if e.data == "sidekick.nvim" then
--             local all_augroups = vim.split(vim.fn.execute("augroup", "silent"), "  ")
--             local augroups = vim.iter(all_augroups)
--                 :filter(function(s) return s:find("sidekick") end)
--                 :totable()
--             vim.schedule(function()
--                 for _, g in ipairs(augroups) do
--                     local autocmds = vim.api.nvim_get_autocmds({
--                         event = { "BufEnter", "WinEnter" },
--                         group = g,
--                     })
--                     for _, cmd in ipairs(autocmds) do
--                         vim.api.nvim_del_autocmd(cmd.id)
--                     end
--                 end
--             end)
--         end
--     end
-- })

return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		cond = not vim.g.vscode or not vim.lsp.inline_completion,
		dependencies = { "copilotlsp-nvim/copilot-lsp" },
		config = {
			filetypes = {
				markdown = false,
			},
			suggestion = {
				enabled = true,
				-- Autotrigger off is nice... But the manual trigger just takes
				-- so long to execute :(
				auto_trigger = true,
				keymap = {
					accept = "<m-y>",
					accept_word = "<m-i>",
					accept_line = false,
					next = "<m-]>",
					prev = "<m-[>",
					dismiss = "<c-]>",
				},
			},
			nes = { enabled = false },
		},
		keys = {
			{ "<leader>ct", "<cmd>Copilot toggle<cr>", desc = "Copilot toggle" },
		},
	},
	-- {
	--     "folke/sidekick.nvim",
	--     cond = not vim.g.vscode,
	--     opts = {
	--         cli = {
	--             mux = {
	--                 -- backend = "tmux",
	--                 backend = nil,
	--                 enabled = false,
	--             },
	--         },
	--     },
	--     keys = {
	--         {
	--             "<tab>",
	--             function()
	--                 -- if there is a next edit, jump to it, otherwise apply it if any
	--                 if not require("sidekick").nes_jump_or_apply() then
	--                     return "<Tab>" -- fallback to normal tab
	--                 end
	--             end,
	--             expr = true,
	--             desc = "Goto/Apply Next Edit Suggestion",
	--         },
	--         {
	--             "<leader><leader>c",
	--             function()
	--                 require("sidekick.cli").toggle({
	--                     name = "copilot",
	--                     focus = false,
	--                 })
	--             end,
	--             desc = "Sidekick Toggle CLI",
	--             mode = { "n", "v" },
	--         },
	--         {
	--             "<leader>cp",
	--             function() require("sidekick.cli").prompt() end,
	--             desc = "Sidekick Ask Prompt",
	--             mode = { "n", "v" },
	--         },
	--     },
	-- }
}
