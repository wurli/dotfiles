---@param pos jet.send.Pos
---@return jet.send.Range?
local function get_python_expr(pos)
	local ok, node = pcall(vim.treesitter.get_node, {
		bufnr = pos.buf,
		pos = { pos.row, pos.col },
		ignore_injections = false,
	})
	if not ok or not node then
		return
	end

	local top_level_nodes = {
		"assert_statement",
		"class_definition",
		"decorated_definition",
		"delete_statement",
		"expression_statement",
		"for_statement",
		"function_definition",
		"global_statement",
		"if_statement",
		"import_from_statement",
		"import_statement",
		"nonlocal_statement",
		"try_statement",
		"while_statement",
		"with_statement",
	}

	local id = node:id()

	local n_iterations = 0
	while true do
		if n_iterations > 100 then
			print("Quitting: exceeded 100 iterations when ascending treesitter tree")
			return
		end
		if vim.list_contains(top_level_nodes, node:type()) then
			break
		end
		node = node:parent()
		if not node then
			return
		end
		local parent_id = node:id()
		n_iterations = n_iterations + 1
		if id == parent_id then
			return
		end
		id = parent_id
	end

	local start_row, start_col, end_row, end_col = node:range(false)

	return {
		buf = pos.buf,
		start_row = start_row,
		start_col = start_col,
		end_row = end_row,
		end_col = end_col,
	}
end

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
		dir = "~/Repos/jet.nvim",
		config = function()
			vim.env.PATH = vim.env.PATH .. ":/Users/JACOB.SCOTT1/Repos/jet/target/debug"

			require("jet").setup({
				binary_path = vim.fs.abspath("~/Repos/jet/target/debug/jet"),
				library_path = vim.fs.abspath("~/Repos/jet/target/debug/libjet_lua.dylib"),
				stop_on_buf_wipeout = true,
				stop_on_nvim_quit = true,
				send = {},
				ui = { stream_lines = 10 },
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
				default_kernels = {
					python = function()
						return vim.fs.find("kernel.json", { path = ".venv/share/jupyter/kernels/python3" })[1]
					end,
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

			vim.env.JET_LUA_LOG = "jet-nvim-lua.log"
			vim.env.JET_LOG = "jet-nvim.log"
			vim.env.RUST_LOG = "jet=debug"

			---@diagnostic disable-next-line: global-in-non-module
			_G.jet_print = false

			require("jet.core.send.get_code").filetype.python = { get_expr = get_python_expr }
			vim.keymap.set({ "n", "v" }, "<enter>", function()
				require("jet.core.send").send_auto()
				return "<enter>"
			end, {
				desc = "Execute code (Jet)",
				expr = true,
			})

			local open_ft = function(ft)
				return function()
					require("jet.core.manager").get({ filetype = ft }, function(k)
						k:term_toggle()
					end)
				end
			end

			vim.keymap.set("n", "<leader>jp", open_ft("python"), { desc = "Open Python (Jet)" })
			vim.keymap.set("n", "<leader>jr", open_ft("r"), { desc = "Open R (Jet)" })

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "jetrepl",
				callback = function()
					vim.keymap.set({ "n", "t" }, "<c-i>", function()
						local session = vim.b.jet and vim.b.jet.session_id
						if not session then
							return
						end
						local k = require("jet.core.manager").kernels[session]
						if k then
							k:img_toggle()
						end
					end, { buffer = vim.api.nvim_get_current_buf() })
				end,
			})
		end,
	},
}

-- vim.print(require("jet.filetype.r"))
