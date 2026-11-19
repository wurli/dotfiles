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
	return out
end

local pick_project = function()
	local items = {}
	for _, item in ipairs(resolve_sessions()) do
		table.insert(items, item)
	end
	for _, item in ipairs(resolve_dirs()) do
		table.insert(items, item)
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

rex.bind("ctrl+f", "pick_project")
