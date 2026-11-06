--!strict
-- instance creation with properties set before parenting: parenting last avoids a layout and signal pass per property

local DEFAULTS: { [string]: { [string]: any } } = {
	Frame = { BackgroundTransparency = 1, BorderSizePixel = 0 },
	TextLabel = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		TextXAlignment = Enum.TextXAlignment.Left,
	},
	TextButton = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
	},
	TextBox = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
	},
	ScrollingFrame = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(),
		ScrollingDirection = Enum.ScrollingDirection.Y,
	},
}

local function make(class: string, props: { [string]: any }?, children: { Instance }?): any
	local instance: any = Instance.new(class :: any)
	local base = DEFAULTS[class]
	if base then
		for key, value in base do
			instance[key] = value
		end
	end
	local parent = nil
	if props then
		for key, value in props do
			if key == "Parent" then
				parent = value
			else
				instance[key] = value
			end
		end
	end
	if children then
		for _, child in children do
			child.Parent = instance
		end
	end
	if parent then
		instance.Parent = parent
	end
	return instance
end

return make
