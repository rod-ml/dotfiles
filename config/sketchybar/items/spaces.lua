local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

-- AeroSpace workspaces. Native `space=` items only track Mission Control
-- spaces (yabai-style), so these are plain items driven by
-- `aerospace_workspace_change` and `aerospace_windows_change` events.
-- Workspaces with no windows stay hidden unless they are focused.
local WORKSPACES = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" }

local spaces = {}
local brackets = {}

for _, ws in ipairs(WORKSPACES) do
	local workspace = sbar.add("item", "workspace." .. ws, {
		drawing = false,
		width = 0,
		icon = {
			font = { family = settings.font.text, style = settings.font.style_map["Heavy"] },
			string = ws,
			padding_left = 15,
			padding_right = 8,
			color = colors.white,
			highlight_color = colors.orange,
		},
		label = {
			drawing = true,
			padding_right = 20,
			color = colors.white,
			highlight_color = colors.sora.primary,
			font = "sketchybar-app-font:Regular:16.0",
			y_offset = -1,
		},
		padding_right = 5,
		padding_left = 1,
		background = {
			color = colors.bar.bg,
			border_width = 2,
			height = 28,
			border_color = colors.black,
		},
		click_script = "/Users/rody/.local/bin/aerospace workspace " .. ws,
	})

	local bracket = sbar.add("bracket", { workspace.name }, {
		drawing = false,
		background = {
			color = colors.transparent,
			border_color = colors.bg2,
			height = 30,
			border_width = 2,
		},
	})

	spaces[ws] = { item = workspace, bracket = bracket, windows = nil }
end

sbar.add("event", "aerospace_workspace_change")
sbar.add("event", "aerospace_windows_change")

local workspace_observer = sbar.add("item", "workspace.observer", { drawing = false, label = "never" })

local function set_app_icons(ws, focused_ws)
	sbar.exec(
		"/Users/rody/.local/bin/aerospace list-windows --workspace " .. ws .. " --format '%{app-name}'",
		function(windows)
			local icon_line = ""
			local seen = {}
			local count = 0
			for app in windows:gmatch("[^\r\n]+") do
				count = count + 1
				if app ~= "" and not seen[app] then
					seen[app] = true
					local icon = app_icons[app] or app_icons["default"]
					icon_line = icon_line .. " " .. icon
				end
			end
			if icon_line == "" then
				icon_line = " —"
			end
			spaces[ws].windows = count
			spaces[ws].item:set({ label = icon_line })

			-- Re-evaluate visibility now that this workspace's count is known.
			local selected = ws == focused_ws
			local visible = selected or count > 0
			spaces[ws].item:set({ drawing = visible, width = visible and "dynamic" or 0 })
			spaces[ws].bracket:set({ drawing = visible })
		end
	)
end

local function refresh()
	sbar.exec("/Users/rody/.local/bin/aerospace list-workspaces --focused", function(result)
		local focused_ws = result:gsub("%s+", "")
		for ws, space in pairs(spaces) do
			set_app_icons(ws, focused_ws)
			local selected = ws == focused_ws
			space.item:set({
				icon = { highlight = selected },
				label = { highlight = selected },
				background = { border_color = selected and colors.highlight or colors.bar.bg },
			})
			space.bracket:set({
				background = { border_color = selected and colors.grey or colors.bg2 },
			})
		end
	end)
end

workspace_observer:subscribe("aerospace_workspace_change", function(env)
	workspace_observer:set({ label = "wschange " .. os.time() })
	refresh()
end)

workspace_observer:subscribe("aerospace_windows_change", function(env)
	workspace_observer:set({ label = "winchange " .. os.time() })
	refresh()
end)

workspace_observer:subscribe("system_woke", function(_)
	refresh()
end)

-- AeroSpace has no "windows changed" callback, only focus callbacks. A move
-- that leaves focus unchanged would otherwise never refresh the bar.
local poller = sbar.add("item", "workspace.poller", {
	position = "left",
	drawing = true,
	width = 0,
	update_freq = 2,
	label = { drawing = false },
	icon = { drawing = false },
	background = { drawing = false },
})
poller:subscribe({ "routine", "forced" }, function(_)
	refresh()
end)

refresh()
