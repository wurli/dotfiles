-- TODO: Might be possible to do this with treesitter
local get_comment_subsections = function()
    local commentstring = vim.bo.commentstring
    if commentstring == "" then
        return {}
    end

    local commentstring = vim.bo.commentstring
    local comment_start, comment_end = commentstring:match("^(.+)%%s(.*)$")

    if not comment_start or not comment_end then
        return {}
    end

    local trim       = function(x) return x:gsub("^%s*", ""):gsub("%s*$", "") end
    local has_prefix = function(x, y) return x:sub(1, #y) == y       end
    local has_suffix = function(x, y) return x:sub(#x - #y + 1) == y end
    local rm_prefix  = function(x, y) return x:sub(#y + 1)           end
    local rm_suffix  = function(x, y) return x:sub(1, #x - #y)       end

    comment_start, comment_end = trim(comment_start), trim(comment_end)
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local comments = {}

    for i, l in ipairs(lines) do
        l = trim(l)
        if has_prefix(l, comment_start) and has_suffix(l, comment_end) then
            table.insert(comments, {
                text = trim(rm_suffix(rm_prefix(l, comment_start), comment_end)),
                line = i
            })
        end
    end

    local headings = {}
    for _, c in ipairs(comments) do
        local last_char = c.text:sub(-1)
        local is_heading = #c.text > 0 and has_suffix(c.text, last_char:rep(4))
        if is_heading then
            local prefix_pat = "^" .. last_char .. "+%s*"
            local suffix_pat = "%s*" .. last_char .. "+$"
            local prefix_text = c.text:match("^(" .. last_char .. "*)") or ""
            table.insert(headings, {
                text = c.text:gsub(prefix_pat, ""):gsub(suffix_pat, ""),
                line = c.line,
                level = #prefix_text
            })
        end
    end

    local min_level = math.min(math.huge, unpack(vim.tbl_map(function(x) return x.level end, headings)))
    headings = vim.tbl_map(
        function(x)
            x.level = math.min(x.level - min_level, 5)
            return x
        end,
        headings
    )

    local items = vim.tbl_map(
        function(x)
            return {
                col = 1,
                end_col = 2,
                lnum = x.line,
                end_lnum = x.line + 1,
                kind = "String",
                name = x.text == "" and "<section>" or x.text,
                level = x.level,
                selection_range = {
                    col = 1,
                    end_col = 2,
                    lnum = x.line,
                    end_lnum = x.line + 1,
                }
            }
        end,
        headings
    )

    -- table.sort(items, function(x, y) return x.lnum < y.lnum end)
    --
    -- local out = {}
    --
    -- local function append(x, y)
    --     local prev = x[#x]
    --     if not prev or prev.level > y.level then
    --         table.insert(x, y)
    --         return true
    --     end
    --     prev.children = prev.children or {}
    --     local appended_to_child = false
    --     for _, child in ipairs(prev.children) do
    --         appended_to_child = append(child, y)
    --     end
    --     if not appended_to_child then
    --         table.insert(prev.children, y)
    --         return true
    --     end
    --     return false
    -- end
    --
    -- for _, x in ipairs(items) do append(out, x) end

    return items
end

return {
    'stevearc/aerial.nvim',
    cond = not vim.g.vscode,
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons"
    },
    config = function()
        require("aerial").setup({
            layout = {
                max_width = { 40, 0.2 },
                min_width = 30,
                default_direction = "right"
            },
            on_attach = function(bufnr)
                -- Jump forwards/backwards with '{' and '}'
                vim.keymap.set("n", "<leader>{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
                vim.keymap.set("n", "<leader>}", "<cmd>AerialNext<CR>", { buffer = bufnr })
            end,
            -- Add comment subsections --------------
            post_add_all_symbols = function(_, items, _)
                local comment_subsections = get_comment_subsections()
                for _, x in ipairs(comment_subsections) do table.insert(items, x) end
                table.sort(items, function(x, y) return x.lnum < y.lnum end)
                return items
            end,
            get_highlight = function(symbol, _, _)
                return symbol.kind == "String" and "Comment" or nil
            end
        })
        vim.keymap.set("n", "<leader>at", "<cmd>AerialToggle<CR>")
    end
}
