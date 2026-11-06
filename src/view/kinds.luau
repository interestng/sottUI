--!strict
-- builds the tile for each element kind. every builder only reads the model; state flows model -> refresh, never the
-- other way, so a config load, a keybind and a click all draw the same

local colorpicker = require("./colorpicker")
local droplist = require("./droplist")
local keychip = require("./keychip")
local make = require("../core/make")
local motion = require("../core/motion")
local tileModule = require("./tile")

local kinds = {}

local PAD = tileModule.PAD
local FILL_SPEED = 40
local STATE_SIZE = 32
local NUMBER_SIZE = 38
local VALUE_SIZE = 26

local function bigText(ctx: any, parent: any, size: number, align: any?): any
	local label = make("TextLabel", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, PAD, 1, -7),
		Size = UDim2.new(1, -2 * PAD, 0, size + 4),
		TextSize = size,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = align or Enum.TextXAlignment.Left,
		ZIndex = 3,
		Parent = parent,
	})
	ctx.theme:type(label, "display")
	return label
end

-- addons sit bottom right, opposite the state word, and read in whichever ink the tile is in
local function addons(view: any, ctx: any, el: any)
	local list = el.addons
	if list == nil then
		return 0
	end
	local used = 0
	for _, addon in list do
		local chip = if addon.kind == "key" then keychip.build(ctx, addon) else colorpicker.swatch(ctx, addon)
		chip.root.AnchorPoint = Vector2.new(1, 1)
		chip.root.Position = UDim2.new(1, -(PAD + used), 1, -10)
		chip.root.ZIndex = 4
		chip.root.Parent = view.root
		used += chip.width + 6
		addon._view = chip
		view._chips = view._chips or {}
		table.insert(view._chips, chip)
		table.insert(view._cleanups, function()
			addon._view = nil
			chip.destroy()
		end)
	end
	return used
end

local builders: { [string]: (ctx: any, el: any) -> any } = {}

function builders.toggle(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el)
	local state = bigText(ctx, view.root, STATE_SIZE)
	state.Size = UDim2.new(0, 70, 0, STATE_SIZE + 4)
	addons(view, ctx, el)

	local function draw(instant: boolean)
		local on = el.value == true
		state.Text = if on then "ON" else "OFF"
		view:flood(on, instant)
		local labelInk = if el.disabled then "faint" elseif on then "onAccent" else "text"
		local stateInk = if el.disabled then "faint" elseif on then "onAccent" else "faint"
		view:ink(view.label, labelInk, instant)
		view:ink(state, stateInk, instant)
		if view._chips then
			for _, chip in view._chips do
				chip.setInk(on)
			end
		end
	end

	view.root.Activated:Connect(function()
		if not el.disabled then
			el:set(not el.value)
		end
	end)
	view.refresh = function()
		view:refreshLabel()
		draw(false)
	end
	draw(true)
	return view
end

local function formatted(el: any): string
	local spec = el.spec
	if spec.format then
		local ok, text = pcall(spec.format, el, el.value)
		if ok and text ~= nil then
			return tostring(text)
		end
	end
	return string.format("%." .. (spec.decimals or 0) .. "f", el.value) .. (spec.suffix or "")
end

function builders.slider(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el)
	local theme = ctx.theme
	local spec = el.spec
	local root = view.root
	local function ratio(): number
		local span = spec.max - spec.min
		return if span <= 0 then 0 else (el.value - spec.min) / span
	end

	view.label.Size = UDim2.new(1, -2 * PAD, 0, 22)
	view.label.TextWrapped = false
	theme:paint(view.label, "TextColor3", "text")
	local readout = bigText(ctx, root, NUMBER_SIZE, Enum.TextXAlignment.Right)
	theme:paint(readout, "TextColor3", "text")

	-- dim fill with one bright edge: full mint is reserved for "on", a slider at 80% is not a switch that is on
	local fill = make("Frame", {
		Name = "Fill",
		Size = UDim2.new(ratio(), 0, 1, 0),
		BackgroundTransparency = 0,
		ZIndex = 2,
		Parent = root,
	})
	theme:paint(fill, "BackgroundColor3", "accentDim")
	local edge = make("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 3, 1, 0),
		BackgroundTransparency = 0,
		ZIndex = 2,
		Parent = fill,
	})
	theme:paint(edge, "BackgroundColor3", "accent")

	local fillSize = tileModule.own(view, motion.prop(fill, "Size", FILL_SPEED))

	local function setText()
		readout.Text = formatted(el)
	end
	setText()

	local function fromPointer(at: Vector2)
		local left = root.AbsolutePosition.X
		local width = math.max(root.AbsoluteSize.X, 1)
		local t = math.clamp((at.X - left) / width, 0, 1)
		el:set(spec.min + (spec.max - spec.min) * t)
	end

	local function typedEntry()
		if el.disabled or view._typing then
			return
		end
		view._typing = true
		local box = make("TextBox", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, PAD, 1, -7),
			Size = UDim2.new(1, -2 * PAD, 0, NUMBER_SIZE + 4),
			TextSize = NUMBER_SIZE,
			TextXAlignment = Enum.TextXAlignment.Right,
			Text = tostring(el.value),
			BackgroundTransparency = 0,
			ZIndex = 6,
			Parent = root,
		})
		theme:paint(box, "BackgroundColor3", "base")
		theme:type(box, "display")
		theme:paint(box, "TextColor3", "accent")
		box:CaptureFocus()
		box.SelectionStart = 1
		box.CursorPosition = #box.Text + 1
		box.FocusLost:Connect(function()
			local number = tonumber(box.Text)
			view._typing = false
			box:Destroy()
			if number then
				el:set(number)
			end
		end)
	end

	root.InputBegan:Connect(function(event: any)
		if el.disabled then
			return
		end
		local kind = event.UserInputType
		if kind == Enum.UserInputType.MouseButton2 then
			typedEntry()
		elseif kind == Enum.UserInputType.MouseButton1 then
			local now = os.clock()
			if view._lastPress and now - view._lastPress < 0.3 then
				view._lastPress = nil
				ctx.input:release()
				typedEntry()
				return
			end
			view._lastPress = now
			local at = ctx.input:pointer()
			fromPointer(at)
			ctx.input:capture(fromPointer)
		elseif kind == Enum.UserInputType.Touch then
			-- touch must not steal a vertical swipe from the scroller, so the drag starts on horizontal intent
			local from = ctx.input:at(event)
			local dragging = false
			ctx.input:capture(function(at: Vector2)
				if not dragging then
					local delta = at - from
					if math.abs(delta.X) > 6 and math.abs(delta.X) > math.abs(delta.Y) then
						dragging = true
						ctx.setScrollLocked(true)
					elseif math.abs(delta.Y) > 8 then
						ctx.input:release()
						return
					else
						return
					end
				end
				fromPointer(at)
			end, function(at: Vector2)
				ctx.setScrollLocked(false)
				if not dragging and (at - from).Magnitude < 6 then
					fromPointer(at)
				end
			end)
		end
	end)

	view.refresh = function()
		view.label.Text = el.label
		setText()
		local ink = if el.disabled then "faint" else "text"
		theme:paint(view.label, "TextColor3", ink)
		theme:paint(readout, "TextColor3", ink)
		fillSize:to(UDim2.new(ratio(), 0, 1, 0))
	end
	return view
end

local function pickText(el: any): (string, boolean)
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
			return "None", false
		end
		if #picks <= 2 then
			return table.concat(picks, ", "), true
		end
		return #picks .. " picked", true
	end
	if value == nil then
		return "None", false
	end
	return display(value), true
end

function builders.dropdown(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el)
	local theme = ctx.theme
	view.label.Size = UDim2.new(1, -2 * PAD, 0, 22)
	view.label.TextWrapped = false
	theme:paint(view.label, "TextColor3", "muted")
	local text = bigText(ctx, view.root, VALUE_SIZE)
	text.Size = UDim2.new(1, -(2 * PAD + 22), 0, VALUE_SIZE + 6)
	local chevron = ctx.glyph.chevron(view.root, "muted")
	chevron.AnchorPoint = Vector2.new(1, 1)
	chevron.Position = UDim2.new(1, -PAD, 1, -16)
	chevron.ZIndex = 3

	view.root.Activated:Connect(function()
		if not el.disabled then
			droplist.open(ctx, el, view.root)
		end
	end)
	view.refresh = function()
		view:refreshLabel()
		local shown, picked = pickText(el)
		text.Text = shown
		theme:paint(text, "TextColor3", if el.disabled or not picked then "faint" else "text")
	end
	view.refresh()
	return view
end

function builders.input(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el)
	local theme = ctx.theme
	local spec = el.spec
	view.label.Size = UDim2.new(1, -2 * PAD, 0, 22)
	view.label.TextWrapped = false
	theme:paint(view.label, "TextColor3", "muted")
	local box = make("TextBox", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, PAD, 1, -9),
		Size = UDim2.new(1, -2 * PAD, 0, 30),
		TextSize = 20,
		Text = el.value or "",
		PlaceholderText = spec.placeholder or "",
		ClipsDescendants = true,
		TextEditable = not el.disabled,
		ZIndex = 3,
		Parent = view.root,
	})
	theme:type(box, "text")
	theme:paint(box, "TextColor3", "text")
	theme:paint(box, "PlaceholderColor3", "faint")
	local rule = make("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundTransparency = 0,
		Visible = false,
		ZIndex = 4,
		Parent = view.root,
	})
	theme:paint(rule, "BackgroundColor3", "accent")

	box.Focused:Connect(function()
		rule.Visible = true
	end)
	box.FocusLost:Connect(function()
		rule.Visible = false
		if spec.finished and not el:set(box.Text) then
			box.Text = el.value or ""
		end
	end)
	box:GetPropertyChangedSignal("Text"):Connect(function()
		if view._applying or spec.finished then
			return
		end
		if not el:set(box.Text) and box.Text ~= el.value then
			view._applying = true
			box.Text = el.value or ""
			view._applying = false
		end
	end)
	view.root.Activated:Connect(function()
		if not el.disabled then
			box:CaptureFocus()
		end
	end)
	view.refresh = function()
		view:refreshLabel()
		box.TextEditable = not el.disabled
		if box.Text ~= (el.value or "") then
			view._applying = true
			box.Text = el.value or ""
			view._applying = false
		end
	end
	return view
end

function builders.button(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el)
	local theme = ctx.theme
	view.label.Text = ""
	local text = bigText(ctx, view.root, VALUE_SIZE)
	text.TextWrapped = true
	text.TextTruncate = Enum.TextTruncate.None
	text.Size = UDim2.new(1, -2 * PAD, 1, -14)
	text.TextYAlignment = Enum.TextYAlignment.Bottom
	theme:paint(text, "TextColor3", "text")
	local arrow = make("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -PAD, 0, 8),
		Size = UDim2.fromOffset(20, 20),
		TextSize = 18,
		Text = utf8.char(0x2192),
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 3,
		Parent = view.root,
	})
	theme:type(arrow, "text", true)
	theme:paint(arrow, "TextColor3", "muted")

	local armed: thread? = nil
	local function draw()
		text.Text = el.label
		view:ink(text, if el.disabled then "faint" else "text")
		view:flood(false)
	end
	view.refresh = draw
	draw()
	view.label.Visible = false
	local function run()
		if armed then
			task.cancel(armed)
			armed = nil
		end
		draw()
		-- the wave doubles as the "it ran" acknowledgement, then drains
		view:flood(true)
		view:ink(text, "onAccent")
		task.delay(0.22, function()
			if view.root.Parent then
				view:flood(false)
				view:ink(text, "text")
			end
		end)
		el:fire()
	end
	view.root.Activated:Connect(function()
		if el.disabled then
			return
		end
		if el.spec.confirm and armed == nil then
			text.Text = "Again to confirm"
			view:ink(text, "onAccent")
			view:flood(true)
			armed = task.delay(2.5, function()
				armed = nil
				draw()
			end)
			return
		end
		run()
	end)
	table.insert(view._cleanups, function()
		if armed then
			task.cancel(armed)
		end
	end)
	return view
end

function builders.stat(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el)
	local theme = ctx.theme
	view.root.Active = false
	view.root.AutoButtonColor = false
	view.onHover = function() end
	view.pressed = function() end
	view.label.Size = UDim2.new(1, -2 * PAD, 0, 22)
	view.label.TextWrapped = false
	theme:paint(view.label, "TextColor3", "muted")
	local number = bigText(ctx, view.root, NUMBER_SIZE)
	theme:paint(number, "TextColor3", "text")
	view.refresh = function()
		view:refreshLabel()
		number.Text = tostring(el.value)
	end
	view.refresh()
	return view
end

function builders.label(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el, 34)
	local theme = ctx.theme
	local label = view.label
	local wrap = el.spec.wrap == true
	view.root.BackgroundTransparency = 1
	view.root.Active = false
	view.onHover = function() end
	view.pressed = function() end
	label.RichText = true
	label.TextWrapped = wrap
	label.TextSize = 16
	label.FontFace = theme:face("text")
	theme:type(label, "text")
	theme:paint(label, "TextColor3", "muted")
	label.TextTruncate = if wrap then Enum.TextTruncate.None else Enum.TextTruncate.AtEnd
	label.TextYAlignment = if wrap then Enum.TextYAlignment.Top else Enum.TextYAlignment.Center
	label.LineHeight = if wrap then 1.15 else 1
	label.Position = UDim2.fromOffset(2, if wrap then 6 else 0)
	label.Size = if wrap then UDim2.new(1, -4, 1, -6) else UDim2.new(1, -4, 1, 0)
	if el.addons then
		local used = addons(view, ctx, el)
		label.Size = UDim2.new(1, -(used + 8), 1, 0)
		if view._chips then
			for _, chip in view._chips do
				chip.root.AnchorPoint = Vector2.new(1, 0.5)
				chip.root.Position = UDim2.new(1, -2, 0.5, 0)
			end
		end
	end
	if wrap then
		label:GetPropertyChangedSignal("TextBounds"):Connect(function()
			local height = math.ceil(label.TextBounds.Y / ctx.uiScale()) + 12
			if el._measured ~= height then
				el._measured = height
				if el._relayout then
					el._relayout()
				end
			end
		end)
	end
	view.refresh = function()
		label.Text = el.label
	end
	return view
end

function builders.divider(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el, 34)
	local theme = ctx.theme
	view.root.BackgroundTransparency = 1
	view.root.Active = false
	view.onHover = function() end
	view.pressed = function() end
	view.label.Position = UDim2.fromOffset(2, 6)
	view.label.Size = UDim2.new(1, -4, 1, -6)
	view.label.TextYAlignment = Enum.TextYAlignment.Center
	theme:paint(view.label, "TextColor3", "muted")
	view.refresh = function()
		view:refreshLabel()
	end
	return view
end

-- a key or color with no host tile of its own
function builders.key(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el)
	local theme = ctx.theme
	view.label.Size = UDim2.new(1, -2 * PAD, 0, 22)
	theme:paint(view.label, "TextColor3", "muted")
	local chip = keychip.big(ctx, el, view.root)
	table.insert(view._cleanups, chip.destroy)
	view.refresh = function()
		view:refreshLabel()
		chip.refresh()
	end
	view.root.Activated:Connect(chip.start)
	return view
end

function builders.color(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el)
	local chip = colorpicker.band(ctx, el, view.root)
	table.insert(view._cleanups, chip.destroy)
	view.refresh = function()
		view:refreshLabel()
		chip.refresh()
	end
	view.root.Activated:Connect(chip.open)
	return view
end

function kinds.build(ctx: any, el: any): any
	local builder = builders[el.kind]
	assert(builder, "sottUI: no view for " .. tostring(el.kind))
	local view = builder(ctx, el)
	el._view = view
	return view
end

return kinds
