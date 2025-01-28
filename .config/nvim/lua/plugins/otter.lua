if not vim.g.vscode then
    vim.api.nvim_create_autocmd("InsertEnter", {
        group = vim.api.nvim_create_augroup("otter-autostart", {}),
        pattern = { "*.md", "*.qmd" },
        callback = function()
            local ok, parser = pcall(vim.treesitter.get_parser)
            if not ok then return end

            local otter      = require("otter")
            local extensions = require("otter.tools.extensions")
            local attached   = {}

            local line = vim.fn.line(".") - 1
            local lang = parser:language_for_range({ line, 0, line, 1 }):lang()

            if extensions[lang] and not vim.tbl_contains(attached, lang) then
                table.insert(attached, lang)
                vim.schedule(function() otter.activate({ lang }, true, true) end)
            end
        end
    })
end


return {
    'jmbuhr/otter.nvim',
    cond = not vim.g.vscode,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {}
}
