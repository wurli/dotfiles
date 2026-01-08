local map = vim.keymap.set

return {
	dir = "~/Repos/jet",
	cmd = "Jet",
	dependencies = {
		dir = "~/Repos/jet.ark/",
		config = function()
			require("jet.ark").setup()
		end,
	},
	config = function()
		local jet = require("jet")
		jet.setup({})

		map({ "n", "v" }, "<leader>s", function()
			jet.send_from_cursor()
		end)
		map({ "n", "v" }, "gj", jet.send_from_motion(), { expr = true })
		map("n", "<leader><cr>", function()
			jet.send_chunk()
		end)
	end,
}

-- vim.print(require("jet.filetype.r"))
