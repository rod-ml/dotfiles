local colors = require("colors")
local icons = require("icons")

-- Padding item required because of bracket
sbar.add("item", { width = 5 })

local apple = sbar.add("item", {
	icon = {
		font = { size = 22.0 },
		string = icons.apple,
		padding_right = 20,
		padding_left = 8,
		color = colors.bg1,
	},
	label = { drawing = false },
	padding_left = 1,
	padding_right = 1,
	click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 0",
})

-- Double border for apple using a single item bracket
sbar.add("bracket", { apple.name }, {
	background = {
		-- color = colors.transparent,
		height = 30,
		--		border_color = colors.bg1,
	},
})

-- Padding item required because of bracket
sbar.add("item", { width = 7 })
