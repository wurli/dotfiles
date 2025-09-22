local go_to_relative_file = function(n, relative_to)
    return function()
        local files = {}
        for file, type in vim.fs.dir(".") do
            if type == "file" then
                table.insert(files, file)
            end
        end

        local this_file = relative_to or vim.fn.bufname()
        local this_file_pos = -1

        for i, file in ipairs(files) do
            if file == this_file then
                this_file_pos = i
            end
        end

        if this_file_pos == -1 then
            error(("File `%s` not found in current directory"):format(this_file))
        end

        local new_file = files[((this_file_pos + n - 1) % #files) + 1]

        if not new_file then
            error(("Could not find file relative to `%s`"):format(this_file))
        end

        vim.cmd("edit " .. new_file)
    end
end

local open_day = function(create, now)
    local time = now or vim.fn.localtime()
    -- Date included in 2 formats for easier fuzzy finding
    local filename = vim.fn.strftime("%Y-%m-%d %a, %d %b.md", time or vim.fn.localtime())

    if vim.fn.findfile(filename) == "" and create then
        local file = io.open(filename, "w")

        if file then
            print(("Creating new file `%s`"):format(file))
            file:write(vim.fn.strftime("# Notes on %A, %d %B\n\n", time))
            file:close()
        end
    end

    if vim.fn.findfile(filename) ~= "" then
        vim.cmd("edit " .. filename)
    else
        print(("File `%s` does not exist."):format(filename))
    end
end

-- Git commit and push on Nvim exit
vim.api.nvim_create_autocmd("ExitPre", {
    callback = function()
        if #vim.fs.find(".git", {}) == 0 then
            return
        end

        local system = function(cmd) return vim.system(cmd, { text = true }):wait() end

        local changed_files = system({ "git", "diff", "--name-only" }).stdout
            :gsub("[^\n]+", '`%0`')
            :gsub("\n$", "")
            :gsub("\n", "; ")

        local code1 = system({ "git", "add", "." }).code
        local code2 = system({ "git", "diff", "--quiet" }).code
        local code3 = system({ "git", "diff", "--cached", "--quiet" }).code

        -- Nothing to commit
        if not (code1 == 0 and code2 == 0 and code3 == 1) then return end

        local msg = ('"Updates on %s. Changed files: %s"'):format(
            vim.fn.strftime("%a %Y-%m-%d at %H:%M", vim.fn.localtime()),
            changed_files
        )
        print(system({ "git", "commit", "-m", msg }).stdout)
        print(system({ "git", "push" }).stdout)
    end
})

vim.keymap.set("n", "<M-h>", go_to_relative_file(-1))
vim.keymap.set("n", "<M-l>", go_to_relative_file(1))
vim.keymap.set("n", "<leader>ot", function() open_day(true) end)
vim.keymap.set("n", "<leader>oy", function() open_day(false, vim.fn.localtime() - 24 * 60 * 60) end)

