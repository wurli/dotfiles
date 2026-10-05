return {
	{
		dir = "~/Repos/jet.ark",
		config = function()
			require("jet.ark").setup({
				ark_binary_path = "~/Repos/ark/target/release/ark",
				ark_argv = {
					log = "~/Repos/jet.ark/ark-log.log",
				},
			})
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "r",
				group = vim.api.nvim_create_augroup("jet.ark.custom", { clear = true }),
				callback = function()
					vim.keymap.set("i", "<m-m>", require("jet.ark.actions").pipe, { buf = 0 })
					vim.keymap.set("i", "<m-->", require("jet.ark.actions").assign, { buf = 0 })
				end,
			})
		end,
	},
	{
		dir = "~/Repos/jet.ipy",
		config = function()
			require("jet.ipy").setup()
		end,
	},
	{
		dir = "~/Repos/jet.nvim",
		config = function()
			vim.env.PATH = vim.env.PATH .. ":/Users/JACOB.SCOTT1/Repos/jet/target/debug"

			require("jet").setup({
				binary_path = vim.fs.abspath("~/Repos/jet/target/debug/jet"),
				library_path = vim.fs.abspath("~/Repos/jet/target/debug/libjet_lua.dylib"),
				stop_on_buf_wipeout = true,
				stop_on_nvim_quit = true,
				send = {},
				ui = { stream_lines = 5 },
				image = {
					handler = function(data, mime, filepath)
						if mime.subtype == "svg" then
							local cmd = vim.system(
								{ "resvg", "-", filepath, "--dpi", "500", "-z", "4" },
								{ stdin = data }
							)
							return cmd:wait().code == 0 and filepath or false
						end
					end,
					format_priority = {
						function(m)
							return m.subtype == "svg"
						end,
						function(m)
							return m.subtype == "png"
						end,
					},
				},
				hooks = {
					on_send_pre = {
						---@param k jet.Kernel
						---@param code string[]
						function(k, code)
							if k.filetype == "python" and code[#code]:find("^%s+%S") then
								-- If the last line is indented, add a blank
								-- line so the code actually gets sent.
								table.insert(code, "")
							end
							-- if k.filetype == "kotlin" then
							-- 	table.insert(code, "")
							-- end
						end,
					},
					on_message_received = {
						---@param k jet.Kernel
						---@param msg jupyter.Msg
						function(k, msg)
							---@diagnostic disable-next-line: unnecessary-if
							if _G.jet_print then
								---@diagnostic disable-next-line: inject-field
								msg.kernel = k:friendly_name()
								vim.print(msg)
							end

							local file = msg.content and msg.content.data and msg.content.data["text/x.vd-file"]

							if file then
								vim.system({ "tmux", "split-window", "-h", "vd", file })
							end
						end,
					},
				},
			})

			-- vim.env.JET_LUA_LOG = "jet-nvim-lua.log"
			-- vim.env.JET_LOG = "jet-nvim.log"
			-- vim.env.RUST_LOG = "jet=debug"

			---@diagnostic disable-next-line: global-in-non-module
			_G.jet_print = false

			local api = require("jet.api")

			local toggle_repl = function(ft)
				return function()
					api.get_kernel({ filetype = ft }, function(k)
						k:term_toggle()
					end)
				end
			end

			vim.keymap.set("n", "<leader>jp", toggle_repl("python"), { desc = "Open Python (Jet)" })
			vim.keymap.set("n", "<leader>jr", toggle_repl("r"), { desc = "Open R (Jet)" })

			vim.api.nvim_create_autocmd("BufWinEnter", {
				callback = function()
					local session_id = vim.b.jet and vim.b.jet.session_id
					local kernel = session_id and api.get_kernel_by_id(session_id)
					if kernel then
						vim.keymap.set({ "n", "t" }, "<c-o>", function()
							kernel:img_toggle()
						end, { buffer = 0 })
					end
				end,
			})

			vim.api.nvim_create_autocmd("WinResized", {
				callback = function()
					local wins = vim.v.event.windows --[[@as integer[] ]]
					for _, win in ipairs(wins) do
						local buf = vim.api.nvim_win_get_buf(win)
						local session_id = vim.b[buf].jet and vim.b[buf].jet.session_id
						local kernel = session_id and api.get_kernel_by_id(session_id)
						if kernel and kernel.filetype == "python" then
							local code = string.format(
								"import sys\n"
									.. 'if "pandas" in sys.modules: sys.modules.get("pandas").set_option("display.width", %d)',
								vim.api.nvim_win_get_width(win)
							)
							kernel:send_lua(code, true)
						end
					end
				end,
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "jetimg",
				callback = function()
					vim.keymap.set("n", "<c-e>", function()
						-- Get the kernel which owns the current image buffer
						local kernel = vim.b.jet and require("jet.api").get_kernel_by_id(vim.b.jet.session_id)
						if not kernel then
							return
						end

						-- If the current window is floating, close it and reopen the normal view
						if vim.api.nvim_win_get_config(0).relative ~= "" then
							vim.api.nvim_win_close(0, true)
							vim.api.nvim_set_current_win(kernel:img_open())
							return
						end

						local buf = vim.api.nvim_get_current_buf()

						-- Close all windows which currently show the image buffer
						-- (otherwise the image won't resize when we open the float)
						for _, w in ipairs(vim.api.nvim_list_wins()) do
							if vim.api.nvim_win_get_buf(w) == buf then
								vim.api.nvim_win_close(w, true)
							end
						end

						-- Open the image in a floating window
						vim.api.nvim_open_win(buf, true, {
							style = "minimal",
							relative = "editor",
							row = math.floor(vim.o.lines * 0.05),
							col = math.floor(vim.o.columns * 0.05),
							height = math.floor(vim.o.lines * 0.90),
							width = math.floor(vim.o.columns * 0.90),
						})
					end, { buf = 0, desc = "Toggle image fullscreen" })
				end,
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "r", "python", "markdown" },
				callback = function()
					vim.keymap.set(
						{ "n", "v" },
						"go",
						api.handle_motion(function(range, filetype)
							api.get_kernel({
								filetype = filetype,
								current = true,
								status = { "connected", "connecting" },
							}, function(k)
								local code = range:code({ comments = false })
								if code then
									k:send_repl(code)
								end
							end)
						end),
						{ desc = "Execute code (Jet)", expr = true }
					)

					vim.keymap.set({ "x", "o" }, "ie", function()
						local expr = api.get_expr()
						if not expr then
							local pos = api.next_expr_boundary({
								current_ok = false,
								boundary = "start",
							})
							expr = pos and api.get_expr(pos)
						end
						if expr then
							expr:textobject()
						end
					end, {})

					vim.keymap.set("n", "]e", function()
						local pos = api.next_expr_boundary({ direction = 1, boundary = "start" })
						if pos then
							vim.fn.cursor(pos:to_cursor())
						end
					end)
					vim.keymap.set("n", "[e", function()
						local pos = api.next_expr_boundary({ direction = -1, boundary = "start" })
						if pos then
							vim.fn.cursor(pos:to_cursor())
						end
					end)

					vim.keymap.set("n", "<enter>", "goie]e", { remap = true })
					vim.keymap.set("x", "<enter>", "go", { remap = true })
				end,
			})
		end,
	},
}

-- vim.print(require("jet.filetype.r"))
