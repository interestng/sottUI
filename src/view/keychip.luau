--!strict
-- keybind display: a small chip inside a host tile, or the whole readout of a tile of its own. the key goes through one
-- listener in shell/keys, so a rebind from either looks and behaves the same

local make = require("../core/make")

local keychip = {}

local PAD = 14
local CHAR_WIDTH = 8.6

local function display(el: any): string
	local value = el.value
	if value == nil or value.key == "None" or value.key == "Unknown" then
		return "Unset"
	end
	local parts = {}
	for _, modifier in value.modifiers or {} do
		table.insert(parts, modifier)
	end
	table.insert(parts, value.key)
	return table.concat(parts, "+")
end

local function cycleMode(ctx: any, el: any)
	local modes = el.spec.modes
	if el.disabled or modes == nil or #modes < 2 then
		return
	end
	local at = table.find(modes, el.value.mode) or 0
	local mode = modes[at % #modes + 1]
	el:set({ mode = mode })
	ctx.notify({ title = el.label, text = "Key mode: " .. mode, seconds = 2 })
end

local function listen(ctx: any, el: any, chip: any, setListening: (boolean) -> ())
	if el.disabled then
		return
	end
	setListening(true)
	ctx.keys:listen(function(name: string?, modifiers: { string }?)
		if name ~= nil then
			el:set({ key = name, modifiers = modifiers or {} })
		end
		setListening(false)
		chip.refresh()
	end, el.spec.noMouse == true)
end

function keychip.build(ctx: any, el: any): any
	local theme = ctx.theme
	local root = make("TextButton", {
		Name = "Key",
		Size = UDim2.fromOffset(52, 26),
		BackgroundTransparency = 1,
	})
	local outline = make("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = root })
	local text = make("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 5,
		Parent = root,
	})
	theme:type(text, "text", true)

	local chip: any = { root = root, width = 52 }
	local listening = false
	local inverted = false

	local function fit(shown: string)
		local width = math.max(#shown * CHAR_WIDTH + PAD, 34)
		root.Size = UDim2.fromOffset(width, 26)
		chip.width = width
	end

	local function ink()
		local token = if listening then "accent" elseif inverted then "onAccent" else "muted"
		theme:paint(text, "TextColor3", token)
		theme:paint(outline, "Color", if listening then "accent" elseif inverted then "onAccent" else "lineStrong")
	end

	chip.refresh = function()
		if listening then
			return
		end
		local shown = display(el)
		text.Text = shown
		fit(shown)
		ink()
	end
	chip.setInk = function(on: boolean)
		inverted = on
		ink()
	end
	chip.refresh()

	root.Activated:Connect(function()
		if listening then
			return
		end
		listen(ctx, el, chip, function(on: boolean)
			listening = on
			if on then
				text.Text = "Press a key"
				fit("Press a key")
			end
			ink()
		end)
	end)
	root.MouseButton2Click:Connect(function()
		cycleMode(ctx, el)
	end)
	chip.destroy = function()
		if listening then
			ctx.keys:cancel()
		end
		root:Destroy()
	end
	return chip
end

function keychip.big(ctx: any, el: any, parent: any): any
	local theme = ctx.theme
	local text = make("TextLabel", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 12, 1, -7),
		Size = UDim2.new(1, -24, 0, 36),
		TextSize = 32,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 3,
		Parent = parent,
	})
	theme:type(text, "display")
	local chip: any = {}
	local listening = false
	chip.refresh = function()
		if listening then
			return
		end
		local shown = display(el)
		text.Text = shown
		theme:paint(text, "TextColor3", if shown == "Unset" then "faint" else "text")
	end
	chip.refresh()
	chip.start = function()
		if listening then
			return
		end
		listen(ctx, el, chip, function(on: boolean)
			listening = on
			if on then
				text.Text = "Press a key"
				theme:paint(text, "TextColor3", "accent")
			end
		end)
	end
	parent.MouseButton2Click:Connect(function()
		cycleMode(ctx, el)
	end)
	chip.destroy = function()
		if listening then
			ctx.keys:cancel()
		end
	end
	return chip
end

return keychip
