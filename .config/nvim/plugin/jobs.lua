vim.keymap.set(
    "n", "<leader><leader>j",
    function()
        require("utils.jobs"):toggle()
    end,
    { desc = "Open jobs pane" }
)

