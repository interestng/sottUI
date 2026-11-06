--!strict
-- a touch device has no menu key, so with the menu closed this is the only way back to it

local make = require("../core/make")

local POSITION = UDim2.fromOffset(16, 72)
local SIZE = 44

return function(gui: any, theme: any, open: () -> ()): any
	local button = make("TextButton", {
		Name = "Open",
		Position = POSITION,
		Size = UDim2.fromOffset(SIZE, SIZE),
		BackgroundTransparency = 0,
		TextSize = 24,
		Text = "s",
		Visible = false,
		ZIndex = 50,
		Parent = gui,
	})
	theme:type(button, "display")
	theme:paint(button, "BackgroundColor3", "accent")
	theme:paint(button, "TextColor3", "onAccent")
	button.Activated:Connect(open)
	return button
end
