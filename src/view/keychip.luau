--!strict
-- the keybind chip. it sits inside a tile that toggles on click, so its hit zone is bigger than what it draws: a near
-- miss on a small chip would start the farm instead of rebinding it

local make = require("../core/make")
local metrics = require("../core/metrics")

local keychip = {}

local HEIGHT = 30
local HIT_MARGIN = 8
local TEXT_SIZE = 16
local LISTENING = "Press a key"

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
	local shown = table.concat(parts, "+")
	-- Toggle is what nearly every bind is, and only the exceptions need saying
	return if value.mode and value.mode ~= "Toggle" then shown .. " " .. string.lower(value.mode) else shown
end

function keychip.build(ctx: any, el: any): any
	local theme = ctx.theme
	local root = make("TextButton", {
		Name = "Key",
		Size = UDim2.fromOffset(52, 60),
		BackgroundTransparency = 1,
	})
	local face = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -HIT_MARGIN, 0, HEIGHT),
		ZIndex = 4,
		Parent = root,
	})
	local outline = make("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = face })
	local text = make("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		TextSize = TEXT_SIZE,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 5,
		Parent = face,
	})
	theme:type(text, "text", true)

	local chip: any = { root = root, width = 52 }
	local listening = false
	local inverted = false

	local function fit(shown: string)
		local width = math.ceil(metrics.width("textMedium", shown, TEXT_SIZE)) + 16 + HIT_MARGIN
		root.Size = UDim2.fromOffset(math.max(width, 44), 60)
		chip.width = root.Size.X.Offset
	end

	local hovering = false

	local function ink()
		theme:paint(text, "TextColor3", if listening then "accent" elseif inverted then "onAccent" else "muted")
		theme:paint(outline, "Color", if listening then "accent" elseif inverted then "onAccent" else "lineStrong")
		-- a wall of "Unset" reads as missing data, so an unbound chip only shows when the tile is under the pointer
		face.Visible = listening or hovering or display(el) ~= "Unset"
	end

	chip.setHover = function(on: boolean)
		hovering = on
		ink()
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

	chip.start = function()
		if el.disabled or listening then
			return
		end
		listening = true
		text.Text = LISTENING
		fit(LISTENING)
		ink()
		ctx.keys:listen(function(name: string?, modifiers: { string }?)
			listening = false
			if name ~= nil then
				el:set({ key = name, modifiers = modifiers or {} })
			end
			chip.refresh()
		end, el.spec.noMouse == true)
	end
	root.Activated:Connect(chip.start)

	root.MouseButton2Click:Connect(function()
		local modes = el.spec.modes
		if el.disabled or modes == nil or #modes < 2 then
			return
		end
		local at = table.find(modes, el.value.mode) or 0
		local mode = modes[at % #modes + 1]
		el:set({ mode = mode })
		ctx.notify({ title = el.label, text = "Key mode: " .. mode, seconds = 2 })
	end)
	chip.destroy = function()
		if listening then
			ctx.keys:cancel()
		end
		root:Destroy()
	end
	return chip
end

return keychip
