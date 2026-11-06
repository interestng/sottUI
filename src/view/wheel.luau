--!strict
-- one setting on the stage's wheel: a word and what it is set to. the page moves and fades these every frame while the
-- wheel turns, so a view holds only what it has to and the transform goes through one UIScale and two transparencies

local keychip = require("./keychip")
local colorpicker = require("./colorpicker")
local droplist = require("./droplist")
local make = require("../core/make")
local motion = require("../core/motion")

local wheel = {}

wheel.HEIGHT = 70
wheel.NAME = 46
wheel.VALUE = 26

local BAR_HEIGHT = 4
local BAR_SPEED = 42
local BAR_DRAG_SPEED = 90
local DRAG_START = 3
local INK_SPEED = 24

local function formatted(el: any, value: number): string
	local spec = el.spec
	if spec.format then
		local ok, text = pcall(spec.format, el, value)
		if ok and text ~= nil then
			return tostring(text)
		end
	end
	return string.format("%." .. (spec.decimals or 0) .. "f", value) .. (spec.suffix or "")
end

local function pickText(el: any): string
	local display = el.spec.display or tostring
	local value = el.value
	if el.spec.multi then
		local picks = {}
		for _, option in el.spec.options do
			if value[option] then
				table.insert(picks, display(option))
			end
		end
		for pick, on in value do
			if on and not table.find(el.spec.options, pick) then
				table.insert(picks, display(pick))
			end
		end
		if #picks == 0 then
			return "None"
		end
		if #picks <= 2 then
			return table.concat(picks, ", ")
		end
		return string.format("%s +%d", picks[1], #picks - 1)
	end
	return if value == nil then "None" else display(value)
end

-- what a row says on its right, by kind
local function valueOf(el: any): string
	local kind = el.kind
	if kind == "toggle" then
		return if el.value == true then "On" else "Off"
	elseif kind == "slider" then
		return formatted(el, el.value)
	elseif kind == "dropdown" then
		return pickText(el)
	elseif kind == "input" then
		return if el.value == "" then "Empty" else tostring(el.value)
	elseif kind == "stat" then
		return tostring(el.value)
	end
	return ""
end

function wheel.focusable(el: any): boolean
	local kind = el.kind
	if kind == "divider" or kind == "stat" then
		return false
	end
	return not (kind == "label" and not el.addons)
end

function wheel.build(ctx: any, el: any, page: any): any
	local theme = ctx.theme
	local kind = el.kind
	local root = make("TextButton", {
		Name = kind,
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.fromOffset(wheel.NAME * 18, wheel.HEIGHT),
		Active = true,
	})
	local scale = make("UIScale", { Parent = root })
	local name = make("TextLabel", {
		Name = "Name",
		Size = UDim2.new(0.62, 0, 1, 0),
		TextSize = wheel.NAME,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = el.label,
		Parent = root,
	})
	theme:type(name, "display")
	local value = make("TextLabel", {
		Name = "Value",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0.38, 0, 1, 0),
		TextSize = wheel.VALUE,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = root,
	})
	theme:type(value, "display")

	local view: any = { root = root, el = el, _scale = scale, _name = name, _value = value, _cleanups = {} }

	local bar: any = nil
	local fillSize: any = nil
	if kind == "slider" then
		bar = make("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 0, 1, -2),
			Size = UDim2.new(1, 0, 0, BAR_HEIGHT),
			BackgroundTransparency = 0,
			Visible = false,
			Parent = root,
		})
		theme:paint(bar, "BackgroundColor3", "lineStrong")
		local fill = make("Frame", {
			BackgroundTransparency = 0,
			Size = UDim2.fromScale((el.value - el.spec.min) / math.max(el.spec.max - el.spec.min, 1e-6), 1),
			Parent = bar,
		})
		theme:paint(fill, "BackgroundColor3", "accent")
		fillSize = motion.prop(fill, "Size", BAR_SPEED)
		table.insert(view._cleanups, function()
			fillSize:destroy()
		end)
		view._bar = bar
	end

	-- key and colour stay on the right, next to the value; only the focused row can reach them, or they would be targets
	-- on a word still small and far away
	local chips: { any } = {}
	local used = 0
	for _, addon in el.addons or {} do
		if not addon.spec.chipless then
			local chip = if addon.kind == "key" then keychip.build(ctx, addon) else colorpicker.swatch(ctx, addon)
			chip.root.AnchorPoint = Vector2.new(1, 0.5)
			chip.root.Position = UDim2.new(1, -(150 + used), 0.5, 0)
			chip.root.Visible = false
			chip.root.Parent = root
			used += chip.width + 8
			addon._view = chip
			table.insert(chips, chip)
			table.insert(view._cleanups, function()
				addon._view = nil
				chip.destroy()
			end)
		end
	end
	view._chips = chips

	local inks: { [any]: any } = {}
	local function ink(label: any, token: string)
		local spring = inks[label]
		if spring == nil then
			spring = motion.prop(label, "TextColor3", INK_SPEED)
			inks[label] = spring
			table.insert(view._cleanups, function()
				spring:destroy()
			end)
		end
		spring:to(theme.tokens[token])
	end

	view.focused = false
	local function paint()
		local on = kind == "toggle" and el.value == true
		local nameToken = if el.disabled then "faint" elseif on then "accent" elseif view.focused then "text" else "muted"
		local valueToken = if el.disabled
			then "faint"
			elseif on then "accent"
			elseif kind == "toggle" then "faint"
			else "text"
		ink(name, nameToken)
		ink(value, valueToken)
	end

	function view.setFocused(on: boolean)
		if view.focused == on then
			return
		end
		view.focused = on
		for _, chip in chips do
			chip.root.Visible = on
		end
		-- the bar belongs to the setting being worked on; a stack of them would turn the wheel into a form
		if view._bar then
			view._bar.Visible = on
		end
		paint()
	end

	-- placed by the page: scale and fade are the whole of the wheel's look
	function view.place(x: number, y: number, size: number, fade: number)
		root.Position = UDim2.fromOffset(x, y)
		scale.Scale = size
		name.TextTransparency = fade
		value.TextTransparency = fade
		if bar then
			bar.BackgroundTransparency = fade
			bar:FindFirstChildOfClass("Frame").BackgroundTransparency = fade
		end
	end

	view.refresh = function()
		if el.disabled then
			name.RichText = true
			name.Text = "<s>" .. el.label .. "</s>"
		else
			name.RichText = el.kind == "label"
			name.Text = el.label
		end
		value.Text = valueOf(el)
		paint()
		if fillSize then
			local span = el.spec.max - el.spec.min
			fillSize:to(UDim2.fromScale(if span <= 0 then 0 else (el.value - el.spec.min) / span, 1))
		end
		for _, chip in chips do
			chip.refresh()
		end
	end

	local function typedEntry()
		if el.disabled or view._typing then
			return
		end
		view._typing = true
		value.Visible = false
		local box = make("TextBox", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.new(0.38, 0, 1, 0),
			TextSize = wheel.VALUE,
			TextXAlignment = Enum.TextXAlignment.Right,
			Text = if kind == "input" then tostring(el.value or "") else "",
			PlaceholderText = if kind == "input" then (el.spec.placeholder or "") else tostring(el.value),
			Parent = root,
		})
		theme:type(box, "display")
		theme:paint(box, "TextColor3", "accent")
		theme:paint(box, "PlaceholderColor3", "faint")
		box:CaptureFocus()
		box.FocusLost:Connect(function(enter: boolean)
			view._typing = false
			value.Visible = true
			local text = box.Text
			box:Destroy()
			if kind == "input" then
				if not el.spec.finished or enter then
					el:set(text)
				end
			else
				local number = tonumber(text)
				if number then
					el:set(number)
				end
			end
		end)
	end

	-- what pressing means once this row is the one in focus
	function view.act()
		if el.disabled then
			return
		end
		if kind == "toggle" then
			el:set(not el.value)
		elseif kind == "button" then
			if el.spec.confirm and not view._armed then
				view._armed = true
				name.Text = "Again to confirm"
				task.delay(2.5, function()
					view._armed = false
					view.refresh()
				end)
				return
			end
			view._armed = false
			view.refresh()
			el:fire()
		elseif kind == "dropdown" then
			droplist.open(ctx, el, value)
		elseif kind == "input" or kind == "slider" then
			typedEntry()
		elseif kind == "color" then
			view._swatch.open()
		elseif kind == "key" then
			view._chip.start()
		end
	end

	-- left and right on the keyboard, the wheel's quiet companion
	function view.nudge(direction: number)
		if el.disabled then
			return
		end
		if kind == "slider" then
			el:set(el.value + direction * (el.spec.step or 1))
		elseif kind == "toggle" then
			el:set(direction > 0)
		elseif kind == "dropdown" and not el.spec.multi then
			local options = el.spec.options
			local at = table.find(options, el.value) or 0
			local next = options[math.clamp(at + direction, 1, math.max(#options, 1))]
			if next ~= nil then
				el:set(next)
			end
		end
	end

	root.InputBegan:Connect(function(event: any)
		local input = event.UserInputType
		if input ~= Enum.UserInputType.MouseButton1 and input ~= Enum.UserInputType.Touch then
			return
		end
		local from = if input == Enum.UserInputType.Touch then ctx.input:at(event) else ctx.input:pointer()
		-- a press on any word but the focused one only brings it to the middle
		if not view.focused then
			page:focusOn(el)
			return
		end
		if kind == "slider" and not el.disabled then
			local start = el.value
			local width = math.max(root.AbsoluteSize.X, 1)
			local span = el.spec.max - el.spec.min
			local dragging = false
			ctx.input:capture(function(at: Vector2)
				local delta = at - from
				if not dragging and math.abs(delta.X) < DRAG_START then
					return
				end
				if not dragging then
					dragging = true
					fillSize.speed = BAR_DRAG_SPEED
				end
				el:set(start + span * delta.X / width)
			end, function(at: Vector2)
				fillSize.speed = BAR_SPEED
				if not dragging and (at - from).Magnitude < 8 then
					typedEntry()
				end
			end, if input == Enum.UserInputType.Touch then event else nil)
			return
		end
		view.act()
	end)

	if kind == "key" then
		local chip = keychip.build(ctx, el)
		chip.root.AnchorPoint = Vector2.new(1, 0.5)
		chip.root.Position = UDim2.new(1, 0, 0.5, 0)
		chip.root.Parent = root
		view._chip = chip
		table.insert(view._cleanups, chip.destroy)
		local base = view.refresh
		view.refresh = function()
			base()
			chip.refresh()
		end
	elseif kind == "color" then
		local chip = colorpicker.swatch(ctx, el)
		chip.root.AnchorPoint = Vector2.new(1, 0.5)
		chip.root.Position = UDim2.new(1, 0, 0.5, 0)
		chip.root.Parent = root
		view._swatch = chip
		table.insert(view._cleanups, chip.destroy)
		local base = view.refresh
		view.refresh = function()
			base()
			chip.refresh()
		end
	end

	-- headings and read only lines stay a size quieter than settings, and are stepped over
	if kind == "divider" or (kind == "label" and not el.addons) then
		name.Size = UDim2.fromScale(1, 1)
		name.RichText = true
		name.TextSize = 26
		theme:type(name, "text")
		value.Visible = false
		root.Active = false
	end

	view.destroy = function()
		for _, fn in view._cleanups do
			pcall(fn)
		end
		root:Destroy()
	end
	view.refresh()
	return view
end

return wheel
