vim.keymap.set(
    "n",
    "<leader><leader>r",
    function()
        require("ark").toggle()
    end,
    {}
)

return {
    -- "wurli/ark.nvim",
    dependencies = { "blink.cmp" },
    dir = "~/Repos/ark.nvim",
    config = function()
        require("ark").setup({
            lsp_capabilities = require("blink.cmp").get_lsp_capabilities(),
        })

        vim.api.nvim_create_autocmd("BufEnter", {
            pattern = "*.R",
            callback = function()
                vim.keymap.set(
                    { "n", "v" }, "<Enter>",
                    require("ark").execute_current,
                    { buffer = 0, desc = "Send code to the R console" }
                )
            end
        })
    end
}
