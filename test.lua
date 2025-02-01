local term = require("toggleterm.terminal").Terminal
local py = term:new({ cmd = "echo hi && echo there", direction = "split", close_on_exit = false })
py:spawn()
py:toggle(vim.api.nvim_win_get_width(0) / 2, "vertical")
py:send("123")


require("toggleterm.terminal").get_all()
require("toggleterm").toggle(hhhh, size?, dir?, direction?, name?)(force)
require("toggleterm").toggle_command(hhhhh, count)
