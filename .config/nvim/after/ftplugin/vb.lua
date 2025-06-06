-- Indentation doesn't really work in VB, so turn off my special paste keymaps
pcall(function()
    vim.keymap.del({ "n", "v" }, "p", { buffer = 0 })
    vim.keymap.del({ "n", "v" }, "P", { buffer = 0 })
end)

-- Disable auto-pairing `'` since this is the comment character in VB
-- and auto-pairing is very annoying
vim.keymap.set("i", "'", "'", { buffer = 0 })

