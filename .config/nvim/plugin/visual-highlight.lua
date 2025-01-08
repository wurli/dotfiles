local gfind = function(x, pattern, plain)
    local matches, init = {}, 0

    while true do
        local x_collapsed = table.concat(x, "\n")
        local start, stop = x_collapsed:find(pattern, init, plain)
        if start == nil then break end
        table.insert(matches, { start = start, stop = stop })
        init = stop + 1
    end

    local match_line, match_col = 1, 0

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

        local start_pos, end_pos = vim.fn.getpos("v"), vim.fn.getpos(".")
        local selection = vim.fn.getregion(start_pos, end_pos, { type = mode })

        local max_lines, min_chars = 30, 6

        if #selection > max_lines then return end
        local selection_collapsed = table.concat(selection, "\n")

        selection_collapsed = vim.trim(selection_collapsed)

        if #selection_collapsed < min_chars or selection_collapsed:find("^%s*$") then return end

        selection_collapsed = selection_collapsed:gsub("(%p)", "%%%0"):gsub("[ \t]+", "%%s+")

        local first_line   = math.max(0, vim.fn.line("w0", vim.api.nvim_get_current_win()) - #selection)
        local last_line    = vim.fn.line("w$", vim.api.nvim_get_current_win()) + #selection
        local visible_text = vim.api.nvim_buf_get_lines(0, first_line, last_line, false)
        local matches      = gfind(visible_text, selection_collapsed, false)

        for _, m in pairs(matches) do
            m.start.line = m.start.line + first_line - 1
            m.stop.line = m.stop.line + first_line - 1
        end

        for _, m in pairs(matches) do
            -- Don't want to re-highlight the selected region
            local start_ok = m.start.line > end_pos[2] - 1 or (m.start.line == end_pos[2] - 1 and m.start.col > end_pos[3])
            local stop_ok = m.stop.line < start_pos[2] - 1 or (m.stop.line == start_pos[2] - 1 and m.stop.col < start_pos[3])

            if stop_ok or start_ok then
                for l = m.start.line, m.stop.line do
                    vim.api.nvim_buf_add_highlight(
                        0, match_ns, "Search", l,
                        l == m.start.line and m.start.col - 1 or 0,
                        l == m.stop.line and m.stop.col or -1
                    )
                end
            end
        end
    end
})

