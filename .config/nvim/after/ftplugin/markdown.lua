_G.markdown_indent = function()
    local ok, parser = pcall(vim.treesitter.get_parser, 0, '')

    -- Fall back to autoindent
    if not ok then return -1 end

    local row, col = vim.fn.line(".") - 1, vim.fn.col(".")
    local ft = parser:language_for_range({ row, col, row, col + 1 }):lang()

    -- Fall back to autoindent
    if ft == "" then return -1 end

    local indentexpr = vim.filetype.get_option(ft, "indentexpr"):gsub("%(%)$", "")

    -- Fall back to autoindent
    if ft == "markdown" or ft == "markdown_inline" or indentexpr == "" then return -1 end

    -- If we're in a code chunk for another language, use the indent settings
    -- for that language please
    local shiftwidth   = vim.opt.shiftwidth
    vim.opt.shiftwidth = vim.filetype.get_option(ft, "shiftwidth")
    local indent       = vim.fn[indentexpr]()
    vim.opt.shiftwidth = shiftwidth

    return indent
end

vim.opt.indentexpr = "v:lua._G.markdown_indent()"
