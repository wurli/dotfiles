return {
    cond = not vim.g.vscode,
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    -- opts = {},
    build = function() vim.fn["mkdp#util#install"]() end,
}
