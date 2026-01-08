-- -- Workaround for https://github.com/NeogitOrg/neogit/issues/1696
-- vim.api.nvim_create_autocmd("User", {
-- 	pattern = "NeogitCommitComplete",
-- 	callback = function()
-- 		vim.schedule(vim.cmd.tabprevious)
-- 	end,
-- })
--
-- local action = function(x)
-- 	return function()
-- 		require("diffview.actions")[x]()
-- 	end
-- end

-- A new tab with `q` to close is nicest in most cases
vim.keymap.set("n", "<leader>lg", "<cmd>Git<cr><c-w>T<cr>", { desc = "Fugitive open" })

-- Git diff against HEAD with Snacks/CodeDiff
vim.keymap.set("n", "<leader>fd", function()
	Snacks.picker.git_branches({
		all = false,
		title = "Diff Against Branch",
		layout = { hidden = { "preview" } },
		actions = {
			---@type snacks.picker.Action.spec
			diff = function(_, item)
				vim.cmd.CodeDiff(item.branch)
			end,
			toggle_filter = function(picker)
				---@diagnostic disable-next-line: inject-field
				picker.opts.all = not picker.opts.all
				picker:refresh()
			end,
		},
		win = {
			input = {
				keys = {
					["<CR>"] = { "diff", mode = { "i", "n" } },
					["<C-a>"] = { "toggle_filter", mode = { "i", "n" } },
				},
			},
		},
	})
end)

return {
	{
		"tpope/vim-fugitive",
		cond = not vim.g.vscode,
	},
	{
		"esmuellert/codediff.nvim",
		dependencies = { "MunifTanjim/nui.nvim" },
		cmd = "CodeDiff",
		config = function()
			require("codediff").setup({
				diff = {
					hide_merge_artifacts = true,
				},
				keymaps = {
					view = {
						quit = "q", -- Close diff tab
						toggle_explorer = "<c-n>", -- Toggle explorer visibility (explorer mode only)
						next_hunk = "]c", -- Jump to next change
						prev_hunk = "[c", -- Jump to previous change
						next_file = "]f", -- Next file in explorer mode
						prev_file = "[f", -- Previous file in explorer mode
						diff_get = "do", -- Get change from other buffer (like vimdiff)
						diff_put = "dp", -- Put change to other buffer (like vimdiff)
					},
					explorer = {
						select = "<CR>", -- Open diff for selected file
						hover = "K", -- Show file diff preview
						refresh = "R", -- Refresh git status
						toggle_view_mode = "i", -- Toggle between 'list' and 'tree' views
					},
					conflict = {
						accept_incoming = "<leader>ct", -- Accept incoming (theirs/left) change
						accept_current = "<leader>co", -- Accept current (ours/right) change
						accept_both = "<leader>cb", -- Accept both changes (incoming first)
						discard = "<leader>cx", -- Discard both, keep base
						next_conflict = "]x", -- Jump to next conflict
						prev_conflict = "[x", -- Jump to previous conflict
						diffget_incoming = "2do", -- Get hunk from incoming (left/theirs) buffer
						diffget_current = "3do", -- Get hunk from current (right/ours) buffer
					},
				},
			})
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		cond = not vim.g.vscode,
		config = function()
			require("gitsigns").setup({
				diff_opts = {
					algorithm = "patience",
				},
				signs = {
					add = { text = "┃" },
					change = { text = "┇" },
					delete = { text = "║" },
					topdelete = { text = "║" },
					changedelete = { text = "║" },
					untracked = { text = "·" },
				},
				signs_staged = {
					add = { text = "┃" },
					change = { text = "┇" },
					delete = { text = "║" },
					topdelete = { text = "║" },
					changedelete = { text = "║" },
					untracked = { text = "·" },
				},
				on_attach = function(bufnr)
					local gitsigns = require("gitsigns")

					local function map(mode, l, r, desc)
						vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
					end

					-- Actions
					-- map("v", "<leader>hs", function() gitsigns.stage_hunk {vim.fn.line("."), vim.fn.line("v")} end)
					-- map("v", "<leader>hr", function() gitsigns.reset_hunk {vim.fn.line("."), vim.fn.line("v")} end)
					-- map("n", "<leader>hu", gitsigns.undo_stage_hunk)
					map("n", "<leader>hp", gitsigns.preview_hunk, "Git Preview Hunk")
					map("n", "<leader>hb", function()
						gitsigns.blame_line({ full = true })
					end, "Git Blame Line")
					map("n", "<leader>hB", gitsigns.blame, "Git Blame")
					map("n", "<leader>tb", gitsigns.toggle_current_line_blame, "Git Toggle Blame")
					map("n", "<leader>hd", gitsigns.diffthis, "Git Diff Against Index")
					map("n", "<leader>hD", function()
						gitsigns.diffthis("~")
					end, "Git Diff Against HEAD")
					map("n", "<leader>td", gitsigns.preview_hunk_inline, "Git Preview Hunk")
					map("n", "<leader>hr", gitsigns.reset_hunk, "Git Reset Hunk")
					map("n", "<leader>hs", gitsigns.stage_hunk, "Git Stage Hunk")
					map("n", "<leader>hr", gitsigns.reset_hunk, "Git Reset Hunk")
					map("n", "<leader>hS", gitsigns.stage_buffer, "Git Stage Buffer")
					map("n", "<leader>hR", gitsigns.reset_buffer, "Git Reset Buffer")

					-- Text object
					map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
				end,
			})
		end,
	},
	-- {
	--     "NeogitOrg/neogit",
	--     -- "wurli/neogit",
	--     -- branch = "float-highlights",
	--     cond = not vim.g.vscode,
	--     dependencies = {
	--         "nvim-lua/plenary.nvim", -- required
	--         "nvim-telescope/telescope.nvim",
	--         {
	--             "sindrets/diffview.nvim", -- optional - Diff integration
	--             opts = {
	--                 enhanced_diff_hl = true,
	--                 keymaps = {
	--                     view = {
	--                         { "n", "<c-n>", action("toggle_files"),      { desc = "Toggle the file panel." } },
	--                         { "n", "<c-j>", action("select_next_entry"), { desc = "Open the diff for the next file" } },
	--                         { "n", "<c-k>", action("select_prev_entry"), { desc = "Open the diff for the previous file" } },
	--                         { "n", "q",     "<cmd>tabclose<cr>",         { desc = "Close the diff view" } },
	--                     },
	--                     file_panel = {
	--                         { "n", "<c-n>", action("toggle_files"),      { desc = "Toggle the file panel." } },
	--                         { "n", "<c-j>", action("select_next_entry"), { desc = "Open the diff for the next file" } },
	--                         { "n", "<c-k>", action("select_prev_entry"), { desc = "Open the diff for the previous file" } },
	--                         { "n", "q",     "<cmd>tabclose<cr>",         { desc = "Close the diff view" } },
	--                     }
	--                 }
	--             },
	--         },
	--     },
	--     opts = {
	--         kind = "floating",
	--         floating = {
	--             width = 0.85,
	--             height = 0.85
	--         },
	--         integrations = {
	--             snacks = true,
	--             telescope = false,
	--         },
	--         telescope_sorter = function()
	--             return require("telescope.sorters").get_fzy_sorter()
	--         end
	--     },
	--     keys = {
	--         { "<leader>lg", "<cmd>Neogit<cr>", desc = "Neogit" },
	--     },
	-- },
	-- {
	--     -- Not strictly necessary but does make things nicer overall
	--     "echasnovski/mini.diff",
	--     opts = {
	--         view = {
	--             style = "sign",
	--             signs = { add = "┃", change = "┇", delete = "║" }
	--         },
	--         mappings = {
	--             -- Apply hunks inside a visual/operator region
	--             apply = "gh",
	--
	--             -- Reset hunks inside a visual/operator region
	--             reset = "gH",
	--
	--             -- Hunk range textobject to be used inside operator
	--             -- Works also in Visual mode if mapping differs from apply and reset
	--             textobject = "gh",
	--
	--             -- Go to hunk range in corresponding direction
	--             goto_first = "[H",
	--             goto_prev = "[h",
	--             goto_next = "]h",
	--             goto_last = "]H",
	--         },
	--         options = {
	--             algorithm = "patience",
	--         }
	--     },
	-- },
}
