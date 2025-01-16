local get_filetype = function()
    local buf_ft = vim.bo.filetype

    local ok, ts_parser = pcall(vim.treesitter.get_parser, 0, '')
    if not ok or not ts_parser then
        return buf_ft
    end

    -- Try to get 'commentstring' associated with local tree-sitter language.
    -- This is useful for injected languages ().
    local row, col = vim.fn.line(".") - 1, vim.fn.col(".")
    local ref_range = { row, col, row, col + 1 }

    -- get 'commentstring' from the deepest languagetree which both contains
    -- reference range and has valid 'commentstring' (meaning it has at least
    -- one associated 'filetype' with valid 'commentstring').
    -- in simple cases using `parser:language_for_range()` would be enough, but
    -- it fails for languages without valid 'commentstring' (like 'comment').
    local ts_ft, res_level = nil, 0

    local function traverse(lang_tree, level)
        if not lang_tree:contains(ref_range) then
            return
        end

        local regions = lang_tree:included_regions()

        -- unfortunately lang_tree:contains(range) is `true` if `range`
        -- falls within any of the children trees. we only want to set the
        -- filetype if the specified range is part of _this_ tree though.
        -- so we've gotta do this additional check. note: neovim's `gc`
        -- doesn't seem to have this check or the problems associated with
        -- not having it. no idea how it avoids them though.
        local includes_range = vim.iter(regions):flatten(1):find(function(r)
            local start_ok = r[1] < ref_range[1] or r[1] == ref_range[1] and r[2] <= ref_range[2]
            local end_ok   = ref_range[3] < r[4] or ref_range[3] == r[4] and ref_range[4] <= r[5]
            return start_ok and end_ok
        end)

        if includes_range then
            local lang = lang_tree:lang()
            for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
                if ft ~= '' and level > res_level then ts_ft = ft end
            end
        end

        for _, child_lang_tree in pairs(lang_tree:children()) do
            traverse(child_lang_tree, level + 1)
        end
    end
    traverse(ts_parser, 1)

    return (ts_ft or buf_ft):lower()
end

_G.markdown_indent = function()
    local ft         = get_filetype()
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


