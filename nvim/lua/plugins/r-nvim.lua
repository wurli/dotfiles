return {
	"R-nvim/R.nvim",
	config = function()
		-- Create a table with the options to be passed to setup()
		local opts = {
			R_args = { "--quiet", "--no-save" },
			hook = {
				after_config = function()
					-- This function will be called at the FileType event
					-- of files supported by R.nvim. This is an
					-- opportunity to create mappings local to buffers

					local r_term = require("r.term")
					local r_console_buf_nr = function() return r_term.get_buf_nr() end

					local r_console_winid = function()
						local bufno = r_console_buf_nr()
						if bufno == nil then
							return -1
						else
							return vim.fn.bufwinid(bufno)
						end
					end

					local r_console_open = function() require("r.run").start_R("R") end
					local r_console_close = function(winid) vim.fn.win_execute(winid, "q") end

					local toggle_r_console = function()
						local winid = r_console_winid()
						if winid == -1 then
							r_console_open()
						else
							r_console_close(winid)
						end
					end

					local send_line = function()

                        -- If R is running, open the console if closed and send 
                        -- the line
						if vim.g.R_Nvim_status > 6 then
							if r_console_winid() == -1 then r_console_open() end
							require("r.send").line(true)
							return
						end

                        -- If R not running, start and open console
						r_console_open()

                        -- Should happen very rarely, e.g. if you try to send 
                        -- a line less than a second after opening a script
                        if vim.g.R_Nvim_status < 4 then return end

                        -- Repeatedly check to see if R has started - once yes,
                        -- send the line
						local timer = vim.loop.new_timer()
						local i = 0
						timer:start(
							200,
							200,
							vim.schedule_wrap(function()
                                -- Give up trying to start R after about 10 seconds
								if vim.g.R_Nvim_status > 6 or i > 50 then
									timer:close()
									require("r.send").line(true)
								end
								i = i + 1
							end)
						)
					end

					if vim.o.syntax ~= "rbrowser" then
						vim.keymap.set("n", "<Enter>", send_line, { buffer = 0 })
						vim.api.nvim_buf_set_keymap(0, "v", "<Enter>", "<Plug>RSendSelection", {})
					end

					vim.keymap.set("n", "<localleader>rt", toggle_r_console, { buffer = 0 })
					vim.keymap.set("n", "<localleader>rq", "<Plug>RClose", { buffer = 0 })

					-- vim.keymap.set("n", "<leader>sp", search_for_r_script, { buffer = 0 })

					-- Use <C-L> for devtools::load_all() like RStudio
					vim.api.nvim_buf_set_keymap(
						0,
						"n",
						"<C-S-l>",
						"<Cmd>lua require('r.send').cmd('devtools::load_all()')<CR>",
						{}
					)
					vim.api.nvim_buf_set_keymap(
						0,
						"i",
						"<C-S-l>",
						"<Cmd>lua require('r.send').cmd('devtools::load_all()')<CR>",
						{}
					)

					-- Pipe operator
					vim.api.nvim_buf_set_keymap(0, "i", "<C-S-m>", " |>", {})
				end,
			},

			-- Note that on macOS, you need to set the option key as the 'meta'
			-- key, e.g. in your iterm2 profile, for this to work
			assign_map = "<M-->",

			-- For some reason gets set to 'Rterm' on windows
			R_cmd = "R",
			R_app = "R",

			-- Windows testing
			-- R_path = "C:\\Program Files\\R\\R-4.3.2\\bin",

            -- Always open console below current script, a'la RStudio
			min_editor_width = 72,
			rconsole_width = 0,
			rconsole_height = 18,
            hl_term = false,

            -- Disable all R.nvim default keymaps
            user_maps_only = true,
		}

		if vim.env.R_AUTO_START == "true" then
			opts.auto_start = 1
			opts.objbr_auto_start = true
		end

		require("r").setup(opts)

		-- Use tidyverse-style indentation (instead of weird stackoverflow style)
		-- NB, only applies if indent = { enabled = false } in treesitter config
		vim.g.r_indent_align_args = 0

		-- Highlight R output using normal colourscheme
		vim.g.rout_follow_colorscheme = true
	end,
	lazy = false,

}
