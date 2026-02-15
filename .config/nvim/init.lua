-- Set vim options required for lazy ------------------------------------------
vim.g.maplocalleader = "\\"
vim.g.mapleader = " "
vim.opt.termguicolors = true

-- Install lazy if not available ----------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Set up plugins -------------------------------------------------------------
require("lazy").setup({
	spec = { import = "plugins" },
	ui = { border = "rounded" },
	change_detection = { enabled = false },
	rocks = {
		enabled = false,
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"netrwPlugin",
				"rplugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})

-- Load snippets --------------------------------------------------------------
if not vim.g.vscode then
	for _, path in ipairs(vim.api.nvim_get_runtime_file("lua/snippets/*.lua", true)) do
		loadfile(path)()
	end
end

-- function Colorise()
--     local buf = vim.api.nvim_create_buf(false, true)
--     local win = vim.api.nvim_open_win(buf, true, { split = "right" })
--     vim.wo[win].number = false
--     vim.wo[win].relativenumber = false
--     vim.wo[win].statuscolumn = ""
--     vim.wo[win].signcolumn = "no"
--     vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
--     vim.api.nvim_chan_send(
--         vim.api.nvim_open_term(buf, {}),
--         [[[1;31;40mThis is highlighted[0m]]
--     )
-- end
-- Colorise()
