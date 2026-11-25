---@diagnostic disable: undefined-global

local shorten = function(path)
	-- Display form: "/Users/me/Repos/x" -> "~/Repos/x" (plain prefix compare, no patterns)
	local home = os.getenv("HOME") or ""
	if path:sub(1, #home + 1) == home .. "/" then
		return "~" .. path:sub(#home + 1)
	end
	return path
end

local split = function(text, sep)
	local parts, start = {}, 1
	while true do
		local i, j = text:find(sep, start, true) -- plain: sep is literal, not a pattern
		if not i then
			local part = text:sub(start)
			if part ~= "" then
				parts[#parts + 1] = part
			end
			return parts
		end
		local part = text:sub(start, i - 1)
		if part ~= "" then
			parts[#parts + 1] = part
		end
		start = j + 1
	end
end

local resolve_dirs = function()
	-- -L follows symlinked dirs; -type d keeps only directories (no files)
	local home = os.getenv("HOME") or ""
	local cmd = {
		"find",
		"-L",
		-- The shell expands $HOME; double quotes keep the spaces intact.
		string.format("%s/Repos", home),
		string.format("%s/CLPData", home),
		string.format("%s/OneDrive - Zurich Insurance/Documents - Integrated Benefits", home),
		"-mindepth",
		"1",
		"-maxdepth",
		"1",
		"-type",
		"d",
	}

	local out = {}
	local dirs = rex.exec(cmd).stdout
	for _, path in ipairs(split(dirs, "\n")) do
		table.insert(out, {
			id = path,
			title = path:match("[^/]+$"),
			subtitle = shorten(path),
			icon = "folder",
		})
	end

	table.sort(out, function(a, b)
		return a.id < b.id
	end)

	return out
end

local resolve_sessions = function()
	local result, err = rex.call("session.list")
	if err then
		error(err)
	end

	local out = {}
	for _, session in ipairs(result.sessions) do
		table.insert(out, {
			id = session.session_id,
			title = session.label,
			-- subtitle = ,
			icon = "terminal",
		})
	end

	local this_session = rex.session.view().session_id
	table.sort(out, function(a, b)
		return a.id == this_session or a.id < b.id
	end)

	return out
end

local pick_project = function()
	local items = {}
	local existing = {}
	for _, item in ipairs(resolve_sessions()) do
		existing[item.title] = true
		table.insert(items, item)
	end
	for _, item in ipairs(resolve_dirs()) do
		-- Only allow creating a new sessino in a dir if there isn't one already open
		if not existing[item.title] then
			table.insert(items, item)
		end
	end
	local id, _why = rex.ui.pick({
		title = "Open project",
		placeholder = "Filter projects",
		items = items,
	})

	local selected
	for _, item in ipairs(items) do
		if item.id == id then
			selected = item
		end
	end

	if not selected then
		return
	end

	local session_id

	if selected.icon == "terminal" then
		session_id = selected.id
	else
		-- A window in the API is a tab in the app.
		local session, failed = rex.call("session.create", {
			label = selected.title,
			initial_windows = {
				{
					window_label = "shell",
					layout = rex.layout.block({
						flavor = "com.superlogical.terminal.shell",
						options = { cwd = selected.id },
					}),
				},
			},
		})

		if session == nil then
			error(failed, 0)
		end

		session_id = session.session_id
	end

	-- Creating a session does not show it. Ask the app to switch to it.
	rex.client.queue("session.select", { session_id = session_id })
end

rex.action({
	name = "pick_project",
	title = "Open a project in a new session",
	run = function(_ctx, _args)
		return pick_project()
	end,
})

rex.unbind("alt+cmd+left", "pane.focus.left")
rex.unbind("alt+cmd+right", "pane.focus.right")
rex.unbind("alt+cmd+up", "pane.focus.up")
rex.unbind("alt+cmd+down", "pane.focus.down")
rex.unbind("shift+cmd+left", "pane.split.left")
rex.unbind("shift+cmd+right", "pane.split.right")
rex.unbind("shift+cmd+up", "pane.split.up")
rex.unbind("shift+cmd+down", "pane.split.down")

rex.bind("ctrl+alt+h", "pane.focus.left")
rex.bind("ctrl+alt+l", "pane.focus.right")
rex.bind("ctrl+alt+k", "pane.focus.up")
rex.bind("ctrl+alt+j", "pane.focus.down")
rex.bind("shift+cmd+h", "pane.split.left")
rex.bind("shift+cmd+l", "pane.split.right")
rex.bind("shift+cmd+k", "pane.split.up")
rex.bind("shift+cmd+j", "pane.split.down")

rex.bind("ctrl+f", "pick_project")
rex.bind("alt+f", "pane.insert_file")

rex.bind("cmd+o", "client.window.fullscreen.toggle")
rex.bind("cmd+l", "session.previous")

rex.unbind("alt+shift+cmd+t", "client.pane_header.reveal")
rex.bind("cmd+shift+/", "client.pane_header.reveal")
