return {
	"numToStr/Comment.nvim",
	opts = {
		padding = true, -- Add a space b/w comment and the line
		sticky = true, -- Whether the cursor should stay at its position
		ignore = nil, -- Lines to be ignored while (un)comment
		-- LHS of toggle mappings in NORMAL mode
		toggler = {
			line = "gc", -- Line-comment toggle keymap
			-- block = "gc", -- Block-comment toggle keymap
		},
		-- LHS of operator-pending mappings in NORMAL and VISUAL mode
		opleader = {
			line = nil, -- Line-comment keymap
			block = nil, -- Block-comment keymap
		},
		-- LHS of extra mappings
		-- extra = {
		--     above = 'gcO', -- Add comment on the line above
		--     below = 'gco', -- Add comment on the line below
		--     eol = 'gcA',   -- Add comment at the end of line
		-- },
		mappings = {
			basic = true,
			extra = false,
		},
		pre_hook = nil, -- Function to call before (un)comment
		post_hook = nil, -- Function to call after (un)comment
	},
	lazy = false,
}
