local term_info = require("utils.term").info

local get_statement_range = function()
    local ok, node = pcall(vim.treesitter.get_node)
    if not ok or not node then return end

    local top_level = {
        "function_definition",
        "if_statement",
        "import_from_statement",
        "import_statement",
        "expression_statement",
        "assert_statement",
        "decorated_definition"
    }

    local id = node:id()

    while true do
        if vim.list_contains(top_level, node:type()) then
            break
        else
            node = node:parent()
            if not node then return end
            local parent_id = node:id()
            if id == parent_id then return end
            id = parent_id
        end
    end

    return { node:range() }
end

local preformat_code = function(x)
    x = vim.tbl_filter(function(l) return not l:match("^%s*$") end, x)
    -- If the last line ends with an indented statment, then we need to
    -- append 2 trailing lines in order to *actually* send the statement
    if x[#x]:match("^%s") then table.insert(x, "") end
    table.insert(x, "")
    return x
end

vim.keymap.set(
    "n", "<Enter>",
    function()
        if not term_info.Python then return end
        local rng = get_statement_range()

        if not rng then
            vim.fn.cursor(vim.fn.nextnonblank(vim.fn.line(".") + 1), 0)
            return
        end

        local code = preformat_code(vim.api.nvim_buf_get_text(
            0, rng[1], rng[2], rng[3], rng[4], {}
        ))

        vim.fn.chansend(term_info.Python.channel, code)
        vim.fn.cursor(vim.fn.nextnonblank(math.min(rng[3] + 2, vim.fn.line("$"))), 0)
    end,
    { buffer = 0, desc = "Send python code to terminal" }
)

vim.keymap.set(
    "v", "<Enter>",
    function()
        if not term_info.Python then return end
        local start, stop = vim.fn.getpos("v"), vim.fn.getpos(".")

        local code = preformat_code(vim.fn.getregion(
            start, stop, { type = vim.fn.mode() }
        ))

        vim.fn.chansend(term_info.Python.channel, code)
        local escape_keycode = "\27"
        vim.fn.feedkeys(escape_keycode, "L")
        vim.fn.cursor(math.min(vim.fn.nextnonblank(stop[2] + 1), stop[2]), 0)
    end

)

vim.keymap.set(
    { "n", "v", "i" }, "<c-Enter>",
    function()
        if not term_info.Python then return end
        local code = preformat_code(vim.fn.getline("^", "$"))
        vim.fn.chansend(term_info.Python.channel, code)
    end
)

