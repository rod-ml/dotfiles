local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local battery = sbar.add("item", "widgets.battery", {
	position = "right",
	icon = {
		string = icons.battery._100,
		color = colors.sora.steel,
		padding_left = 8,
	},
	label = {
		string = "??%",
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Bold"],
			size = 15.0,
		},
		width = 55,
		color = colors.white,
	},
	padding_right = 0,
	padding_left = 5,
	background = { color = colors.bg1 },
	updates = true,
})

local function battery_update(env)
	local charge = tonumber(env.PERCENT) or tonumber(io.popen("pmset -g batt"):read("*a"):match("(%d+)%%"))
	if not charge then
		return
	end

	local icon = icons.battery._100
	if env.CHARGING == "true" or env.CHARGING == "1" then
		icon = icons.battery.charging
	elseif charge > 75 then
		icon = icons.battery._100
	elseif charge > 50 then
		icon = icons.battery._75
	elseif charge > 25 then
		icon = icons.battery._50
	elseif charge > 10 then
		icon = icons.battery._25
	else
		icon = icons.battery._0
	end

	local color = colors.white
	if charge <= 10 then
		color = colors.semantic.error
	elseif charge <= 25 then
		color = colors.semantic.warn
	end

	battery:set({
		icon = { string = icon, color = color },
		label = { string = charge .. "%", color = color },
	})
end

battery:subscribe({ "power_source_change", "system_woke", "routine", "battery_change" }, battery_update)
battery:subscribe("mouse.clicked", function(_)
	sbar.exec("open -x 'com.apple.settings.panel.battery' 2>/dev/null || open -b com.apple.systempreferences")
end)

battery_update({ PERCENT = nil, CHARGING = nil })
