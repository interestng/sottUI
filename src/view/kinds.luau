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
local READOUT = 17
local MASTER_NAME_OFF = 28
local MASTER_NAME_ON = 28
local MASTER_TYPE_SPEED = 28
local FILL_SPEED = 42
local FILL_DRAG_SPEED = 90
local DRAG_START = 3
local READOUT_GAP = 12
local VALUE_SIZE = 17
local CHEVRON = 22
local TRACK = 1
local BAR = 3
local SLIDER_BAR = 2
local HEAD_WIDTH = 4
local HEAD_HEIGHT = 12
local INPUT_HEIGHT = 34
local INPUT_TEXT = 17
local TEXT_ROW = 16
local PEEK_WIDTH = 50
-- a key chip's box starts inside its hit area; this lines the box up with the name above it
local CHIP_INSET = 3
local POSTER_TOP = 8
local POSTER_NAME = 36

local builders: { [string]: (ctx: any, el: any) -> any } = {}

-- colour dots then key chips, right to left from inner. returns the room taken
local function addons(view: any, ctx: any, el: any, inner: number, poster: boolean?): number
	local used = inner
	local placed: { any } = {}
	-- a chip's width changes with what it shows ("Press a key"), which moves its neighbours and the name's limit
	local function reflow()
		local offset = inner
		for _, chip in placed do
			if poster then
				chip.root.Position = UDim2.new(0, PAD - CHIP_INSET + offset, 1, 0)
			else
				chip.root.Position = UDim2.new(1, -(PAD + offset), 0.5, 0)
			end
			offset += chip.width + chip.gap
		end
		if not poster then
			view.name.Size = UDim2.new(1, -(2 * PAD + offset), 1, 0)
		end
	end
	local function place(addon: any, chip: any)
		chip.root.AnchorPoint = if poster then Vector2.new(0, 1) else Vector2.new(1, 0.5)
		chip.root.Position = if poster
			then UDim2.new(0, PAD - CHIP_INSET + used, 1, 0)
			else UDim2.new(1, -(PAD + used), 0.5, 0)
		chip.root.ZIndex = 4
		chip.root.Parent = view.root
		chip.gap = if addon.kind == "key" then 6 else 0
		chip.onFit = reflow
		used += chip.width
		table.insert(placed, chip)
		addon._view = chip
		view.addonChips = view.addonChips or {}
		view.addonChips[addon] = chip
		table.insert(view.chips, chip)
		view:onCleanup(function()
			addon._view = nil
			chip.destroy()
		end)
	end
	for _, addon in el.addons or {} do
		if addon.kind == "color" and not addon.spec.chipless then
			place(addon, colorpicker.swatch(ctx, addon))
		end
	end
	for _, addon in el.addons or {} do
		if addon.kind == "key" and not addon.spec.chipless then
			place(addon, keychip.build(ctx, addon))
			used += 6
		end
	end
	return used
end

local function reserveRight(view: any, width: number)
	view.name.Size = UDim2.new(1, -(2 * PAD + width), 1, 0)
end

-- every setting is a name over one line: a slider's line fills to its value, a toggle's is empty or full, a list's only
-- marks the cell. the line is at the very bottom and thin, so nothing ever runs through the words
local function baseline(view: any, ctx: any, ratio: number, weight: number?): any
	local track = make("Frame", {
		Name = "Track",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, TRACK),
		BackgroundTransparency = 0,
		ZIndex = 2,
		Parent = view.root,
	})
	ctx.theme:paint(track, "BackgroundColor3", "lineStrong")
	local fill = make("Frame", {
		Name = "Fill",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(ratio, 0, 0, weight or BAR),
		BackgroundTransparency = 0,
		ZIndex = 2,
		Parent = view.root,
	})
	ctx.theme:paint(fill, "BackgroundColor3", "accent")
	return fill
end

function builders.toggle(ctx: any, el: any): any
	local master = el.spec.primary == true
	local view: any = tileModule.new(ctx, el)
	local theme = ctx.theme
	if not master then
		-- a switch is its fill: the same flood at every size, so on reads one way across the whole menu
		reserveRight(view, addons(view, ctx, el, 0))
		local function draw(instant: boolean)
			local on = el.value == true
			view:flood(on, instant)
			view:ink(view.name, if el.disabled then "faint" elseif on then "onAccent" else "text", instant)
			for _, chip in view.chips do
				chip.setInk(on)
				if chip.setMuted then
					chip.setMuted(not on)
				end
			end
		end
		view.root.Activated:Connect(function()
			if not el.disabled then
				el:set(not el.value)
			end
		end)
		view.refresh = function()
			view:refreshName()
			draw(false)
		end
		draw(true)
		return view
	end
	if master then
		theme:type(view.name, "display")
		view.name.TextSize = if el.value == true then MASTER_NAME_ON else MASTER_NAME_OFF
		view.name.TextWrapped = false
		view._nameSize = view:own(motion.prop(view.name, "TextSize", MASTER_TYPE_SPEED))
	end

	-- colour alone is not enough on a dim tile: off must read as off, not as unavailable or as a button
	-- a key takes the line under the name; without one the tile is only as tall as the name needs
	local keyed = false
	for _, addon in el.addons or {} do
		-- an unbound key only shows on hover, so it earns no line of its own
		keyed = keyed or (addon.kind == "key" and not addon.spec.chipless and addon.value.key ~= "None")
	end
	view.name.Position = UDim2.fromOffset(PAD, if keyed then POSTER_TOP else 0)
	view.name.Size = UDim2.new(1, -(2 * PAD + PEEK_WIDTH), if keyed then 0 else 1, if keyed then POSTER_NAME else 0)
	local peek: any = nil
	local chevronDown: any = nil
	local chevronUp: any = nil
	local inner = 0
	if master then
		peek = make("TextButton", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.new(0, PEEK_WIDTH, 1, 0),
			ZIndex = 4,
			Parent = view.root,
		})
		chevronDown = ctx.glyph.chevron(peek, "muted", "down")
		chevronUp = ctx.glyph.chevron(peek, "muted", "up")
		for _, chevron in { chevronDown, chevronUp } do
			chevron.AnchorPoint = Vector2.new(0.5, 0.5)
			chevron.Position = UDim2.fromScale(0.5, 0.5)
		end
		inner += PEEK_WIDTH
		peek.Activated:Connect(function()
			el.section:togglePeek()
			view.refresh()
		end)
	end
	addons(view, ctx, el, if keyed then 0 else PEEK_WIDTH, keyed)

	local function draw(instant: boolean)
		local on = el.value == true
		-- the flood and the display type belong to masters alone, or every lit child competes with what it hangs off and
		-- the page has no focal point. a child says on with its mark and brighter ink
		local flooded = master and on
		if master then
			view:flood(on, instant)
			local size = if on then MASTER_NAME_ON else MASTER_NAME_OFF
			if instant or not ctx.isShowing(el) then
				view._nameSize:snap(size)
			else
				view._nameSize:to(size)
			end
		end
		view:ink(view.name, if el.disabled then "faint" elseif flooded then "onAccent" else "text", instant)
		for _, chip in view.chips do
			chip.setInk(flooded)
		end
		if peek then
			-- on means the options are out anyway; the chevron is only for looking before enabling
			local listed = el._shownOn and el._shownOn.sections[1] and el._shownOn.sections[1].flat
			peek.Visible = el.section.hasOptions == true and not listed
			for _, chevron in { chevronDown, chevronUp } do
				for _, line in chevron:GetChildren() do
					theme:paint(line, "BackgroundColor3", if flooded then "onAccent" else "muted")
				end
			end
			chevronDown.Visible = not el.section.peeking
			chevronUp.Visible = el.section.peeking == true
		end
	end

	view.root.Activated:Connect(function()
		if not el.disabled then
			el:set(not el.value)
		end
	end)
	view.refresh = function()
		view:refreshName()
		draw(false)
	end
	draw(true)
	return view
end

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

-- the widest the readout gets, so the name's column is fixed and a value never pushes into it
function kinds.readoutWidth(el: any): number
	local spec = el.spec
	local widest = 0
	for _, value in { spec.min, spec.max, el.value } do
		widest = math.max(widest, metrics.width("textMedium", formatted(el, value), READOUT))
	end
	return math.ceil(widest * 1.05) + 2
end

function builders.slider(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el, { quiet = true })
	local theme = ctx.theme
	local spec = el.spec
	local root = view.root
	local function ratio(): number
		local span = spec.max - spec.min
		return if span <= 0 then 0 else (el.value - spec.min) / span
	end

	local width = kinds.readoutWidth(el)
	reserveRight(view, width + READOUT_GAP)
	view.name.ZIndex = 4
	local readout = make("TextLabel", {
		Name = "Readout",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -PAD, 0, 0),
		Size = UDim2.new(0, width, 1, 0),
		TextSize = READOUT,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 4,
		Parent = root,
	})
	theme:type(readout, "text", true)

	local fill = baseline(view, ctx, ratio(), SLIDER_BAR)
	local head = make("Frame", {
		Name = "Head",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.fromScale(1, 1),
		Size = UDim2.fromOffset(HEAD_WIDTH, HEAD_HEIGHT),
		BackgroundTransparency = 0,
		ZIndex = 3,
		Parent = fill,
	})
	theme:paint(head, "BackgroundColor3", "text")
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
			Size = UDim2.new(0, math.max(width, 64), 1, 0),
			TextSize = READOUT,
			TextXAlignment = Enum.TextXAlignment.Right,
			-- starts empty with the value behind it: select all does not take on a box focused this frame, and appending to the
			-- old number clamped "5572" to the maximum
			Text = "",
			PlaceholderText = tostring(el.value),
			ZIndex = 6,
			Parent = root,
		})
		theme:type(box, "display")
		theme:paint(box, "TextColor3", "accent")
		theme:paint(box, "PlaceholderColor3", "faint")
		box:CaptureFocus()
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
	local function beginDrag(from: Vector2, touch: boolean, finger: any?)
		if el.disabled then
			return
		end
		local startValue = el.value
		local rootWidth = math.max(root.AbsoluteSize.X, 1)
		local span = spec.max - spec.min
		local dragging = false
		-- a swipe handed back to the scroller ends here too, and must not read as a tap that opens the keyboard
		local cancelled = false
		ctx.input:capture(function(at: Vector2)
			local delta = at - from
			if not dragging then
				if math.abs(delta.X) < DRAG_START then
					if touch and math.abs(delta.Y) > 8 then
						cancelled = true
						ctx.input:release()
					end
					return
				end
				if touch and math.abs(delta.X) <= math.abs(delta.Y) then
					cancelled = true
					ctx.input:release()
					return
				end
				dragging = true
				fillSize.speed = FILL_DRAG_SPEED
				ctx.setScrollLocked(true)
			end
			el:set(startValue + span * delta.X / rootWidth)
		end, function(at: Vector2)
			fillSize.speed = FILL_SPEED
			ctx.setScrollLocked(false)
			if not dragging and not cancelled and (at - from).Magnitude < 8 then
				typedEntry()
			end
		end, finger)
	end

	root.InputBegan:Connect(function(event: any)
		local kind = event.UserInputType
		if kind == Enum.UserInputType.MouseButton2 then
			typedEntry()
		elseif kind == Enum.UserInputType.MouseButton1 then
			beginDrag(ctx.input:pointer(), false)
		elseif kind == Enum.UserInputType.Touch then
			beginDrag(ctx.input:at(event), true, event)
		end
	end)

	local function paintText()
		local ink = if el.disabled then "faint" else "text"
		theme:paint(view.name, "TextColor3", ink)
		theme:paint(readout, "TextColor3", ink)
		readout.Text = formatted(el, el.value)
	end
	view.refresh = function()
		view:refreshName()
		paintText()
		fillSize:to(UDim2.new(ratio(), 0, 0, SLIDER_BAR))
	end
	paintText()
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
	local view: any = tileModule.new(ctx, el, { quiet = true })
	local theme = ctx.theme
	local root = view.root
	baseline(view, ctx, 0)
	theme:paint(view.name, "TextColor3", "muted")

	local text = make("TextLabel", {
		Name = "Value",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -(PAD + CHEVRON), 0, 0),
		TextSize = VALUE_SIZE,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 3,
		Parent = root,
	})
	theme:type(text, "text", true)
	local chevron = ctx.glyph.chevron(root, "muted")
	chevron.AnchorPoint = Vector2.new(1, 0.5)
	chevron.Position = UDim2.new(1, -PAD, 0.5, 0)
	chevron.ZIndex = 3

	-- the name gets the room the value does not need; long values rarely meet long names
	local function fit()
		local width = root.AbsoluteSize.X / ctx.uiScale() - 2 * PAD - CHEVRON
		if width <= 0 then
			return
		end
		local valueWidth = metrics.width("textMedium", (pickText(el)), VALUE_SIZE) + READOUT_GAP
		local nameWidth = math.max(width - valueWidth, width * 0.45)
		view.name.Size = UDim2.new(0, nameWidth, 1, 0)
		text.Size = UDim2.new(0, width - nameWidth, 1, 0)
	end
	root:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)

	root.Activated:Connect(function()
		if not el.disabled then
			droplist.open(ctx, el, root)
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
	local view: any = tileModule.new(ctx, el, { quiet = true })
	local theme = ctx.theme
	local spec = el.spec
	view.name.Size = UDim2.new(0.35, -PAD, 1, 0)
	theme:paint(view.name, "TextColor3", "muted")
	local box = make("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -PAD, 0.5, 0),
		Size = UDim2.new(0.65, -PAD, 0, INPUT_HEIGHT),
		TextSize = INPUT_TEXT,
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
		Size = UDim2.new(1, 0, 0, TRACK),
		BackgroundTransparency = 0,
		ZIndex = 4,
		Parent = view.root,
	})
	theme:paint(rule, "BackgroundColor3", "lineStrong")

	box.Focused:Connect(function()
		theme:paint(rule, "BackgroundColor3", "accent")
	end)
	box.FocusLost:Connect(function(enter: boolean)
		theme:paint(rule, "BackgroundColor3", "lineStrong")
		if not spec.finished then
			return
		end
		-- enter commits and clicking away discards, the same as obsidian; a half typed value must not fire a callback
		if not enter or not el:set(box.Text) then
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

-- no mark and bright ink: a tile with nothing to report is one that does something when pressed
function builders.button(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el, { quiet = true })
	-- on an inset frame: a stroke draws outside its parent and would overrun the grid by a pixel each side
	local box = make("Frame", {
		Name = "Outline",
		Position = UDim2.fromOffset(1, 1),
		Size = UDim2.new(1, -2, 1, -2),
		ZIndex = 2,
		Parent = view.root,
	})
	local outline = make("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = 1,
		Parent = box,
	})
	ctx.theme:paint(outline, "Color", "lineStrong")
	local armed: thread? = nil

	local function draw()
		view:refreshName()
		view:ink(view.name, if el.disabled then "faint" elseif el.spec.danger then "danger" else "text")
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
				draw()
			end
		end)
		el:fire()
	end)
	view:onCleanup(function()
		if armed then
			task.cancel(armed)
		end
	end)
	return view
end

-- no tile behind it: a tile means clickable, a figure is just printed on the page
function builders.stat(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el, { inert = true })
	local theme = ctx.theme
	view.name.Position = UDim2.fromOffset(PAD, 0)
	view.name.Size = UDim2.new(0.5, -PAD, 1, 0)
	view.name.TextWrapped = false
	theme:paint(view.name, "TextColor3", "muted")
	local value = make("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -PAD, 0, 0),
		Size = UDim2.new(0.5, -PAD, 1, 0),
		TextSize = tileModule.NAME,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 3,
		Parent = view.root,
	})
	theme:type(value, "text", true)
	theme:paint(value, "TextColor3", "text")
	view.refresh = function()
		view.name.Text = el.label
		value.Text = tostring(el.value)
	end
	view.refresh()
	return view
end

function builders.label(ctx: any, el: any): any
	local theme = ctx.theme
	-- a line that carries a key or a color is a control, and gets a tile like one
	if el.addons then
		local view: any = tileModule.new(ctx, el, { quiet = true })
		baseline(view, ctx, 0)
		theme:paint(view.name, "TextColor3", "muted")
		view.name.RichText = true
		reserveRight(view, addons(view, ctx, el, 0))
		view.refresh = function()
			view.name.Text = el.label
		end
		return view
	end
	local view: any = tileModule.new(ctx, el, { height = 32, inert = true })
	local name = view.name
	local wrap = el.spec.wrap == true
	name.RichText = true
	name.TextSize = TEXT_ROW
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
	view.name.TextSize = TEXT_ROW
	theme:type(view.name, "text", true)
	theme:paint(view.name, "TextColor3", "muted")
	view.refresh = function()
		view.name.Text = el.label
	end
	return view
end

-- a key or color with no host tile of its own: the name stays the control, the chip reports
local function chipTile(ctx: any, el: any, chip: any, reserve: number, right: number): any
	local view: any = tileModule.new(ctx, el)
	ctx.theme:paint(view.name, "TextColor3", "muted")
	chip.root.AnchorPoint = Vector2.new(1, 0.5)
	chip.root.Position = UDim2.new(1, -right, 0.5, 0)
	chip.root.ZIndex = 4
	chip.root.Parent = view.root
	reserveRight(view, reserve)
	table.insert(view.chips, chip)
	view:onCleanup(chip.destroy)
	view.refresh = function()
		view:refreshName()
		chip.refresh()
	end
	return view
end

function builders.key(ctx: any, el: any): any
	local chip = keychip.build(ctx, el)
	local view = chipTile(ctx, el, chip, 96, PAD)
	view.root.Activated:Connect(chip.start)
	return view
end

function builders.color(ctx: any, el: any): any
	local chip = colorpicker.swatch(ctx, el)
	local view = chipTile(ctx, el, chip, colorpicker.DOT_SPACE, PAD - 8)
	view.root.Activated:Connect(chip.open)
	return view
end

function kinds.build(ctx: any, el: any): any
	local builder = builders[el.kind]
	assert(builder, "sottUI: no view for " .. tostring(el.kind))
	local view = builder(ctx, el)
	local shownOn = el._shownOn
	local flat = shownOn and shownOn.sections[1] and shownOn.sections[1].flat
	local owner = el.section and (el.section._root or el.section)
	local master = owner and owner.masterElement
	if flat and master and master ~= el then
		local refreshName = view.refreshName
		view.refreshName = function(this: any)
			refreshName(this)
			this.name.Text = master.label .. " " .. el.label
		end
		view:refreshName()
	end
	el._view = view
	return view
end

return kinds
