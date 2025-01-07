local gfind = function(x, pattern, plain)
    local matches = {}
    local init = 0

    while true do
        local x_collapsed = table.concat(x, "\n")
        local start, stop = x_collapsed:find(pattern, init, plain)
        if start == nil then break end
        table.insert(matches, { start = start, stop = stop })
        init = stop + 1
    end

    local match_line = 1
    local match_col = 0

    for _, m in pairs(matches) do
        for _, type in ipairs({ "start", "stop" }) do
            local line_end = match_col + #x[match_line]
            while m[type] > line_end do
                match_col  = match_col + #x[match_line] + 1
                match_line = match_line + 1
                line_end   = match_col + #x[match_line]
            end
            m[type] = { line = match_line, col = m[type] - match_col }
        end
    end

    return matches
end

local match_ns = vim.api.nvim_create_namespace("visual-matches")

vim.api.nvim_create_autocmd({ "CursorMoved", "ModeChanged" }, {
    callback = function()
        vim.api.nvim_buf_clear_namespace(0, match_ns, 0, -1)

        local mode = vim.fn.mode()
        if mode ~= "v" and mode ~= "V" then return end

        local selected_text = vim.fn.getregion(
            vim.fn.getpos("v"),
            vim.fn.getpos("."),
            { type = mode }
        )

        local max_lines = 30
        local min_chars = 6

        if #selected_text > max_lines then return end
        local selected_text_collapsed = table.concat(selected_text, "\n")

        selected_text_collapsed = vim.trim(selected_text_collapsed)

        if #selected_text_collapsed < min_chars or selected_text_collapsed:find("^%s*$") then
            return
        end

        selected_text_collapsed = selected_text_collapsed:gsub("(%p)", "%%%0")
        selected_text_collapsed = selected_text_collapsed:gsub("[ \t]+", "%%s+")

        local win = vim.api.nvim_get_current_win()
        local first_line = vim.fn.line("w0", win) - #selected_text
        local last_line  = vim.fn.line("w$", win) + #selected_text

        local visible_text = vim.api.nvim_buf_get_lines(0, first_line, last_line, false)

        local matches = gfind(visible_text, selected_text_collapsed, false)

        for _, m in pairs(matches) do
            for l = m.start.line, m.stop.line do
                vim.api.nvim_buf_add_highlight(
                    0, match_ns, "Search", l + first_line - 1,
                    l == m.start.line and m.start.col - 1 or 0,
                    l == m.stop.line and m.stop.col or -1
                )
            end
        end
    end
})


