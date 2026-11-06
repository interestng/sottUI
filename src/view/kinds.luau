--!strict
-- builds the tile for each element kind. every builder only reads the model; state flows model -> refresh, never the
-- other way, so a config load, a keybind and a click all draw the same

local colorpicker = require("./colorpicker")
local droplist = require("./droplist")
local keychip = require("./keychip")
local make = require("../core/make")
local metrics = require("../core/metrics")
local motion = require("../core/motion")
local tileModule = require("./tile")

local kinds = {}

local PAD = tileModule.PAD
local NAME = tileModule.NAME
local FILL_SPEED = 42
local FILL_DRAG_SPEED = 90
local DRAG_START = 3
local READOUT_WIDTH = 104
local VALUE_SIZE = 19
local CHEVRON = 22

local builders: { [string]: (ctx: any, el: any) -> any } = {}

-- addons sit at the right edge and read in whichever ink the tile is in. returns the width they took
local function addons(view: any, ctx: any, el: any): number
	local used = 0
	for _, addon in el.addons or {} do
		if not addon.spec.chipless then
			local chip = if addon.kind == "key" then keychip.build(ctx, addon) else colorpicker.swatch(ctx, addon)
			chip.root.AnchorPoint = Vector2.new(1, 0.5)
			chip.root.Position = UDim2.new(1, -(PAD + used), 0.5, 0)
			chip.root.ZIndex = 4
			chip.root.Parent = view.root
			used += chip.width + 6
			addon._view = chip
			table.insert(view.chips, chip)
			view:onCleanup(function()
				addon._view = nil
				chip.destroy()
			end)
		end
	end
	return used
end

local function reserveRight(view: any, width: number)
	view.name.Size = UDim2.new(1, -(2 * PAD + width), 1, 0)
end

local function fitToWidth(view: any, ctx: any, reserved: number): () -> ()
	local function fit()
		local width = view.root.AbsoluteSize.X / ctx.uiScale() - 2 * PAD - reserved
		if width > 0 then
			tileModule.fitName(view.name, view.el.label, width)
		end
	end
	view.root:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	return fit
end

function builders.toggle(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el)
	local used = addons(view, ctx, el)
	reserveRight(view, used)
	local fit = fitToWidth(view, ctx, used)

	local function draw(instant: boolean)
		local on = el.value == true
		view:flood(on, instant)
		local ink = if el.disabled then "faint" elseif on then "onAccent" else "muted"
		view:ink(view.name, ink, instant)
		for _, chip in view.chips do
			chip.setInk(on)
		end
	end

	view.root.Activated:Connect(function()
		if not el.disabled then
			el:set(not el.value)
		end
	end)
	view.refresh = function()
		view:refreshName()
		fit()
		draw(false)
	end
	draw(true)
	task.defer(fit)
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

	reserveRight(view, READOUT_WIDTH)
	view.name.ZIndex = 4
	theme:paint(view.name, "TextColor3", "text")
	local fit = fitToWidth(view, ctx, READOUT_WIDTH)

	local readout = make("TextLabel", {
		Name = "Readout",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -PAD, 0, 0),
		Size = UDim2.new(0, READOUT_WIDTH, 1, 0),
		TextSize = NAME,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 4,
		Parent = root,
	})
	theme:type(readout, "display")
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
		Size = UDim2.new(0, 2, 1, 0),
		BackgroundTransparency = 0,
		ZIndex = 2,
		Parent = fill,
	})
	theme:paint(edge, "BackgroundColor3", "accent")

	local fillSize: any = view:own(motion.prop(fill, "Size", FILL_SPEED))

	local function typedEntry()
		if el.disabled or view._typing then
			return
		end
		view._typing = true
		readout.Visible = false
		local box = make("TextBox", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -PAD, 0, 0),
			Size = UDim2.new(0, READOUT_WIDTH, 1, 0),
			TextSize = NAME,
			TextXAlignment = Enum.TextXAlignment.Right,
			Text = tostring(el.value),
			ZIndex = 6,
			Parent = root,
		})
		theme:type(box, "display")
		theme:paint(box, "TextColor3", "accent")
		box:CaptureFocus()
		box.SelectionStart = 1
		box.CursorPosition = #box.Text + 1
		box.FocusLost:Connect(function()
			local number = tonumber(box.Text)
			view._typing = false
			readout.Visible = true
			box:Destroy()
			if number then
				el:set(number)
			end
		end)
	end

	-- relative to the current value and only past a small threshold: a stray click must never change a setting, and a
	-- click without a drag is the way to type an exact number
	local function beginDrag(from: Vector2, touch: boolean)
		if el.disabled then
			return
		end
		local startValue = el.value
		local width = math.max(root.AbsoluteSize.X, 1)
		local span = spec.max - spec.min
		local dragging = false
		ctx.input:capture(function(at: Vector2)
			local delta = at - from
			if not dragging then
				if math.abs(delta.X) < DRAG_START then
					if touch and math.abs(delta.Y) > 8 then
						ctx.input:release()
					end
					return
				end
				if touch and math.abs(delta.X) <= math.abs(delta.Y) then
					ctx.input:release()
					return
				end
				dragging = true
				fillSize.speed = FILL_DRAG_SPEED
				ctx.setScrollLocked(true)
			end
			el:set(startValue + span * delta.X / width)
		end, function(at: Vector2)
			fillSize.speed = FILL_SPEED
			ctx.setScrollLocked(false)
			if not dragging and (at - from).Magnitude < 8 then
				typedEntry()
			end
		end)
	end

	root.InputBegan:Connect(function(event: any)
		local kind = event.UserInputType
		if kind == Enum.UserInputType.MouseButton2 then
			typedEntry()
		elseif kind == Enum.UserInputType.MouseButton1 then
			beginDrag(ctx.input:pointer(), false)
		elseif kind == Enum.UserInputType.Touch then
			beginDrag(ctx.input:at(event), true)
		end
	end)

	view.refresh = function()
		view:refreshName()
		fit()
		readout.Text = formatted(el)
		local ink = if el.disabled then "faint" else "text"
		theme:paint(view.name, "TextColor3", ink)
		theme:paint(readout, "TextColor3", ink)
		fillSize:to(UDim2.new(ratio(), 0, 1, 0))
	end
	readout.Text = formatted(el)
	task.defer(fit)
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
		return string.format("%s, %s +%d", picks[1], picks[2], #picks - 2), true
	end
	if value == nil then
		return "None", false
	end
	return display(value), true
end

function builders.dropdown(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el)
	local theme = ctx.theme
	view.name.Size = UDim2.new(0.5, -PAD, 1, 0)
	theme:paint(view.name, "TextColor3", "muted")

	local text = make("TextLabel", {
		Name = "Value",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -(PAD + CHEVRON), 0, 0),
		Size = UDim2.new(0.5, -CHEVRON, 1, 0),
		TextSize = VALUE_SIZE,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 3,
		Parent = view.root,
	})
	theme:type(text, "text", true)
	local chevron = ctx.glyph.chevron(view.root, "muted")
	chevron.AnchorPoint = Vector2.new(1, 0.5)
	chevron.Position = UDim2.new(1, -PAD, 0.5, 0)
	chevron.ZIndex = 3

	-- the name gets the half the value does not need; long values rarely meet long names
	local function fit()
		local scale = ctx.uiScale()
		local width = view.root.AbsoluteSize.X / scale - 2 * PAD - CHEVRON
		if width <= 0 then
			return
		end
		local valueWidth = metrics.width("textMedium", (pickText(el)), VALUE_SIZE) + 12
		local nameWidth = math.max(width - valueWidth, width * 0.4)
		view.name.Size = UDim2.new(0, nameWidth, 1, 0)
		tileModule.fitName(view.name, el.label, nameWidth)
		text.Size = UDim2.new(0, width - nameWidth, 1, 0)
	end
	view.root:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)

	view.root.Activated:Connect(function()
		if not el.disabled then
			droplist.open(ctx, el, view.root)
		end
	end)
	view.refresh = function()
		view:refreshName()
		local shown, picked = pickText(el)
		text.Text = shown
		theme:paint(text, "TextColor3", if el.disabled or not picked then "faint" else "text")
		fit()
	end
	view.refresh()
	task.defer(fit)
	return view
end

function builders.input(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el)
	local theme = ctx.theme
	local spec = el.spec
	view.name.Size = UDim2.new(0.42, -PAD, 1, 0)
	theme:paint(view.name, "TextColor3", "muted")
	local box = make("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -PAD, 0.5, 0),
		Size = UDim2.new(0.58, -PAD, 0, 34),
		TextSize = 18,
		Text = el.value or "",
		PlaceholderText = spec.placeholder or "",
		ClipsDescendants = true,
		TextEditable = not el.disabled,
		ZIndex = 3,
		Parent = view.root,
	})
	theme:type(box, "text", true)
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
		view:refreshName()
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
	local view: any = tileModule.new(ctx, el, { face = "action" })
	local fit = fitToWidth(view, ctx, 0)
	local armed: thread? = nil

	local function draw()
		view:refreshName()
		fit()
		view:ink(view.name, if el.disabled then "faint" else "text")
	end
	view.refresh = draw
	draw()

	view.root.Activated:Connect(function()
		if el.disabled then
			return
		end
		if el.spec.confirm and armed == nil then
			view.name.Text = "Again to confirm"
			view:flood(true)
			view:ink(view.name, "onAccent")
			armed = task.delay(2.5, function()
				armed = nil
				view:flood(false)
				draw()
			end)
			return
		end
		if armed then
			task.cancel(armed)
			armed = nil
			view:flood(false)
			draw()
		end
		view:flash()
		view:ink(view.name, "onAccent")
		task.delay(0.28, function()
			if view.root.Parent then
				view:ink(view.name, "text")
			end
		end)
		el:fire()
	end)
	view:onCleanup(function()
		if armed then
			task.cancel(armed)
		end
	end)
	task.defer(fit)
	return view
end

-- no tile behind it: a tile means clickable, a figure is just printed on the page
function builders.stat(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el, { inert = true })
	local theme = ctx.theme
	view.name.Position = UDim2.new()
	view.name.Size = UDim2.new(1, 0, 0, 40)
	view.name.TextSize = 36
	view.name.TextYAlignment = Enum.TextYAlignment.Top
	theme:paint(view.name, "TextColor3", "text")
	local caption = make("TextLabel", {
		Position = UDim2.fromOffset(0, 38),
		Size = UDim2.new(1, 0, 0, 20),
		TextSize = 16,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 3,
		Parent = view.root,
	})
	theme:type(caption, "text")
	theme:paint(caption, "TextColor3", "muted")
	view.refresh = function()
		view.name.Text = tostring(el.value)
		caption.Text = el.label
	end
	view.refresh()
	return view
end

function builders.label(ctx: any, el: any): any
	local theme = ctx.theme
	-- a line that carries a key or a color is a control, and gets a tile like one
	if el.addons then
		local view: any = tileModule.new(ctx, el)
		theme:paint(view.name, "TextColor3", "muted")
		view.name.RichText = true
		local used = addons(view, ctx, el)
		reserveRight(view, used)
		local fit = fitToWidth(view, ctx, used)
		view.refresh = function()
			view.name.Text = el.label
			fit()
		end
		task.defer(fit)
		return view
	end
	local view: any = tileModule.new(ctx, el, { height = 32, inert = true })
	local name = view.name
	local wrap = el.spec.wrap == true
	name.RichText = true
	name.TextSize = 16
	name.TextWrapped = wrap
	theme:type(name, "text")
	theme:paint(name, "TextColor3", "muted")
	name.TextTruncate = if wrap then Enum.TextTruncate.None else Enum.TextTruncate.AtEnd
	name.TextYAlignment = if wrap then Enum.TextYAlignment.Top else Enum.TextYAlignment.Center
	name.LineHeight = if wrap then 1.15 else 1
	name.Position = UDim2.fromOffset(0, if wrap then 6 else 0)
	name.Size = if wrap then UDim2.new(1, 0, 1, -6) else UDim2.fromScale(1, 1)
	name.Text = el.label
	if wrap then
		name:GetPropertyChangedSignal("TextBounds"):Connect(function()
			local height = math.ceil(name.TextBounds.Y / ctx.uiScale()) + 12
			if el._measured ~= height then
				el._measured = height
				if el._relayout then
					el._relayout()
				end
			end
		end)
	end
	view.refresh = function()
		name.Text = el.label
	end
	return view
end

function builders.divider(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el, { height = 28, inert = true })
	local theme = ctx.theme
	view.name.Position = UDim2.new()
	view.name.Size = UDim2.fromScale(1, 1)
	view.name.TextSize = 16
	theme:type(view.name, "text", true)
	theme:paint(view.name, "TextColor3", "muted")
	view.refresh = function()
		view.name.Text = el.label
	end
	return view
end

-- a key or color with no host tile of its own: the name stays the control, the chip reports
function builders.key(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el)
	ctx.theme:paint(view.name, "TextColor3", "muted")
	local chip = keychip.build(ctx, el)
	chip.root.AnchorPoint = Vector2.new(1, 0.5)
	chip.root.Position = UDim2.new(1, -PAD, 0.5, 0)
	chip.root.ZIndex = 4
	chip.root.Parent = view.root
	reserveRight(view, 96)
	el._view = chip
	view:onCleanup(chip.destroy)
	view.refresh = function()
		view:refreshName()
		chip.refresh()
	end
	view.root.Activated:Connect(chip.start)
	return view
end

function builders.color(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el)
	ctx.theme:paint(view.name, "TextColor3", "muted")
	local chip = colorpicker.swatch(ctx, el)
	chip.root.AnchorPoint = Vector2.new(1, 0.5)
	chip.root.Position = UDim2.new(1, -PAD, 0.5, 0)
	chip.root.ZIndex = 4
	chip.root.Parent = view.root
	reserveRight(view, 44)
	view:onCleanup(chip.destroy)
	view.refresh = function()
		view:refreshName()
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
