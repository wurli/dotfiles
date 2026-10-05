return {
	dir = "~/Repos/servery.nvim",
	config = function()
		require("servery").setup({
			ui = {
				provider = "snacks",
			},
			dirs = function()
				return vim.iter({ "~/Repos/*", "~/CLPData/*" })
					:map(function(dir)
						return vim.fn.glob(dir, true, true)
					end)
					:fold({}, vim.list_extend)
			end,
		})
		vim.keymap.set("n", "<c-f>", "<cmd>Sv<cr>", {})
		vim.keymap.set("n", "ZV", "<cmd>1Sv<cr>", {})
	end,
}
