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
				-- binary_path = vim.fs.abspath("~/Repos/jet/target/debug/jet"),
				-- library_path = vim.fs.abspath("~/Repos/jet/target/debug/libjet_lua.dylib"),
				stop_on_buf_wipeout = true,
				stop_on_nvim_quit = true,
				send = {},
				ui = { stream_lines = 5 },
				image = {
					handlers = {
						svg = function(data, _mime, filepath)
							local res = vim.system(
								{ "resvg", "-", filepath, "--dpi", "500", "-z", "4" },
								{ stdin = data }
							)
								:wait()
							return res.code == 0 and filepath or false
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
					on_kernel_init = {
						function(k)
							if k.spec.display_name:lower():match("python") then
								k.filetype = "python"
							end
						end,
					},
					on_message_received = {
						---@param k jet.Kernel
						---@param msg jupyter.Msg
						function(k, msg)
							---@diagnostic disable-next-line: unnecessary-if
							if _G.jet_print then
								---@diagnostic disable-next-line: inject-field
								msg.kernel = k.spec.display_name
								vim.print(msg)
							end
						end,
					},
				},
			})

			local hooks = require("jet").hooks

			local execute_inputs = {}
			local execute_results = {}
			hooks.on_message_received.notify = function(k, msg)
				if msg.header.msg_type == "execute_input" and msg.parent_header then
					execute_inputs[msg.parent_header.msg_id] = msg.content
				elseif msg.header.msg_type == "execute_result" and msg.parent_header then
					execute_results[msg.parent_header.msg_id] = msg.content
				elseif
					msg.header.msg_type == "status"
					and msg.parent_header
					and msg.parent_header.msg_type == "execute_request"
				then
					local input = execute_inputs[msg.parent_header.msg_id]
					local result = execute_results[msg.parent_header.msg_id]
					execute_inputs[msg.parent_header.msg_id] = nil
					execute_results[msg.parent_header.msg_id] = nil

					local code = input and input.code
					local text = result and result.data and result.data["text/plain"]

					if code and text and not (k.term and k.term:win()) then
						vim.notify(string.format("Ran `%s`:\nResult: %s", code, text))
					end
				end
			end

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
				pattern = { "r", "python", "markdown" },
				callback = function()
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
