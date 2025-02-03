local term = require("utils.term").terminals.Python
local fn = vim.fn

local function get_statement_range(pos)
    local row, col =  fn.line(".") - 1, fn.col(".") - 1
    local ok, node = pcall(vim.treesitter.get_node, { pos = { row, col } })
    if not ok or not node then return end

    local is_skipping_blanks = false
    while node:type() == "comment" or node:type() == "module" do
        is_skipping_blanks = true
        row = row + 1
        ok, node = pcall(vim.treesitter.get_node, { pos = { row, 0 } })
        if not ok or not node then return end
    end

    if is_skipping_blanks then
        fn.cursor(row, 0)
        return
    end

    local top_level_nodes = {
        "assert_statement",
        "decorated_definition",
        "expression_statement",
        "for_statement",
        "function_definition",
        "if_statement",
        "import_from_statement",
        "import_statement",
        "while_statement"
    }

    local id = node:id()

    while true do
        if vim.list_contains(top_level_nodes, node:type()) then
            break
        end
        node = node:parent()
        if not node then return end
        local parent_id = node:id()
        if id == parent_id then return end
        id = parent_id
    end

    return { node:range() }
end

local send_to_python = function(x)
    x = vim.tbl_filter(function(l) return not l:match("^%s*$") end, x)
    -- If the last line has indent, then we need to append *2* trailing lines
    -- in order to send the statement to IPython
    if x[#x]:match("^%s") then table.insert(x, "") end
    term:send(x)
end

vim.keymap.set(
    "n", "<Enter>",
    function()
        if not term:exists() then return end
        local rng = get_statement_range()

        if not rng then
            fn.cursor(fn.nextnonblank(fn.line(".") + 1), 0)
            return
        end

        send_to_python(vim.api.nvim_buf_get_text(0, rng[1], rng[2], rng[3], rng[4], {}))
        fn.cursor(fn.nextnonblank(math.min(rng[3] + 2, fn.line("$"))), 0)
    end,
    { buffer = 0, desc = "Send python code to terminal" }
)

vim.keymap.set(
    "v", "<Enter>",
    function()
        if not term:exists() then return end
        local start, stop = fn.getpos("v"), fn.getpos(".")

        send_to_python(fn.getregion(start, stop, { type = fn.mode() }))
        local escape_keycode = "\27"
        fn.feedkeys(escape_keycode, "L")
        fn.cursor(math.min(fn.nextnonblank(stop[2] + 1), stop[2]), 0)
    end

)

vim.keymap.set(
    { "n", "v", "i" }, "<c-Enter>",
    function()
        if not term:exists() then return end
        send_to_python(fn.getline("^", "$"))
    end
)

-- local make_python_run_command = function(script)
--     -- Get the current script's name as a python module
--     script         = script or vim.api.nvim_buf_get_name(0)
--     local wd       = vim.fn.getcwd(0, 0) .. "/"
--     local pattern  = "^" .. wd:gsub("%p", "%%%1")
--     local rel_path = script:gsub(pattern, "")
--     local mod      = rel_path:gsub("/", "."):gsub("%.py$", "")
--
--     -- Use the virtual enfironment if applicable
--     local venv = vim.fs.find("activate", { path = ".venv/bin" })[1]
--     local python = venv and venv or "python"
--
--     return python .. " -m " .. mod
-- end
--
-- vim.keymap.set(
--     { "n", "v", "i" }, "<c-Enter>",
--     function()
--         vim.system(
--             { make_python_run_command() },
--             {
--                 stdout = function(err, data)
--                     vim.print(data)
--                 end
--             }
--         )
--     end
-- )
--
