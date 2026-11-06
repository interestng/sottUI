--!strict
-- the rows inside a section. every builder only reads the model; state flows model -> refresh, never the other way, so a
-- config load, a keybind and a click all draw the same. measure() answers a row's height before any instance exists

local colorpicker = require("./colorpicker")
local droplist = require("./droplist")
local keychip = require("./keychip")
local make = require("../core/make")
local metrics = require("../core/metrics")
local motion = require("../core/motion")
local tileModule = require("./tile")

local kinds = {}

local PAD = tileModule.PAD
local RADIUS = tileModule.RADIUS
local ROW = tileModule.HEIGHT
local NAME = tileModule.NAME

local SWITCH_WIDTH = 36
local SWITCH_HEIGHT = 20
local KNOB = 14
local KNOB_INSET = 3
local KNOB_SPEED = 30
local KNOB_DAMPING = 0.72
local HALO_WIDTH = 72
local HALO_HEIGHT = 52
local HALO_ON = 0.55
local HALO_SPEED = 20
local CHIP_GAP = 8

local FILL_SPEED = 30
local FILL_DRAG_SPEED = 80
local DRAG_START = 3
local FILL_ON = 0.82
local FILL_OFF = 0.93
local EDGE_ON = 0
local EDGE_OFF = 0.6
local EDGE_WIDTH = 2

local SEGMENT_HEIGHT = 28
local SEGMENT_PAD = 12
local SEGMENT_SPEED = 30
local SEGMENT_TEXT = 13
local MAX_SEGMENTS = 3
local NAME_ROOM = 16
local CHEVRON_ROOM = 22

local WRAP_LINE = 21
local LINE = 28
local DIVIDER = 26
local DIVIDER_BARE = 8
local MASTER_TEXT = 16

local builders: { [string]: (ctx: any, el: any) -> any } = {}

local function listed(el: any): boolean
	local shownOn = el._shownOn
	local first = shownOn and shownOn.sections[1]
	return first ~= nil and first.flat == true
end

local function ownerOf(el: any): any
	local section = el.section
	return section and (section._root or section).masterElement
end

local function shownLabel(el: any): string
	local master = ownerOf(el)
	if listed(el) and master and master ~= el then
		return master.label .. " " .. el.label
	end
	return el.label
end

local function textWidth(text: string, size: number): number
	return metrics.width("textMedium", (string.gsub(text, "<[^>]+>", "")), size)
end

-- a short pick of two or three shows them all and takes one click; anything that can run long or change needs its popover
local function segmentsFit(el: any, width: number): boolean
	local spec = el.spec
	local count = #spec.options
	-- a pick that can be cleared has no way to say so here
	if spec.multi or spec.allowNull or el.value == nil or count < 2 or count > MAX_SEGMENTS then
		return false
	end
	local display = spec.display or tostring
	local needed = textWidth(el.label, NAME) + NAME_ROOM + 2 * PAD
	for _, option in spec.options do
		needed += textWidth(display(option), SEGMENT_TEXT) + 2 * SEGMENT_PAD
	end
	return needed <= width
end

-- the form a dropdown is built in; a change means the page has to rebuild its view
function kinds.form(el: any): any
	if el.kind ~= "dropdown" then
		return nil
	end
	if not segmentsFit(el, el._rowWidth or 0) then
		return false
	end
	local names = {}
	for _, option in el.spec.options do
		table.insert(names, tostring(option))
	end
	return table.concat(names, "\0")
end

-- a row's height at a given width. the width is kept for the builder, which runs later
function kinds.measure(el: any, width: number): number
	el._rowWidth = width
	local kind = el.kind
	if kind == "divider" then
		return if el.label == "" then DIVIDER_BARE else DIVIDER
	elseif kind == "label" and not el.addons then
		if not el.spec.wrap then
			return LINE
		end
		if el._measured then
			return el._measured
		end
		local plain = string.gsub(el.label, "<[^>]+>", "")
		local perLine = math.max(math.floor(width / 7), 10)
		return math.ceil(#plain / perLine) * WRAP_LINE + 8
	end
	return ROW
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

local function readoutWidth(el: any): number
	local spec = el.spec
	local widest = 0
	for _, value in { spec.min, spec.max, el.value } do
		widest = math.max(widest, metrics.width("textMedium", formatted(el, value), NAME))
	end
	return math.ceil(widest) + 4
end

-- colour swatches then key chips, right to left from `start`. returns the room taken
local function addons(view: any, ctx: any, el: any, start: number): number
	local used = start
	local placed: { any } = {}
	-- a chip's width changes with what it shows ("Press a key"), which moves its neighbours and the name's limit
	local function reflow()
		local offset = start
		for _, chip in placed do
			chip.root.Position = UDim2.new(1, -(PAD + offset), 0.5, 0)
			offset += chip.width + chip.gap
		end
		if view.onReserve then
			view.onReserve(offset)
		end
	end
	local function place(addon: any, chip: any)
		chip.root.AnchorPoint = Vector2.new(1, 0.5)
		chip.root.Position = UDim2.new(1, -(PAD + used), 0.5, 0)
		chip.root.ZIndex = 4
		chip.root.Parent = view.root
		chip.gap = CHIP_GAP
		chip.onFit = reflow
		used += chip.width + chip.gap
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
		end
	end
	return used
end

-- the glow that lifts a lit switch off the black is most of what makes this menu look like itself
local function switch(ctx: any, view: any): (boolean, boolean?) -> ()
	local theme = ctx.theme
	local parent = view.root
	local halo = make("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, -(PAD + SWITCH_WIDTH / 2), 0.5, 0),
		Size = UDim2.fromOffset(HALO_WIDTH, HALO_HEIGHT),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ImageTransparency = 1,
		ZIndex = 2,
		Parent = parent,
	})
	theme:paint(halo, "ImageColor3", "accent")
	ctx.art(halo, "glow.png")
	local track = make("Frame", {
		Name = "Switch",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -PAD, 0.5, 0),
		Size = UDim2.fromOffset(SWITCH_WIDTH, SWITCH_HEIGHT),
		BackgroundTransparency = 0,
		ZIndex = 3,
		Parent = parent,
	})
	make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
	theme:paint(track, "BackgroundColor3", "lineStrong")
	local knob = make("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, KNOB_INSET, 0.5, 0),
		Size = UDim2.fromOffset(KNOB, KNOB),
		BackgroundTransparency = 0,
		ZIndex = 4,
		Parent = track,
	})
	make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
	theme:paint(knob, "BackgroundColor3", "muted")
	local slide: any, glow: any = nil, nil
	return function(on: boolean, instant: boolean?)
		local spot = UDim2.new(0, if on then SWITCH_WIDTH - KNOB - KNOB_INSET else KNOB_INSET, 0.5, 0)
		local alpha = if on then HALO_ON else 1
		local trackToken = if on then "accent" else "lineStrong"
		local knobToken = if on then "onAccent" else "muted"
		if instant then
			if slide then
				slide:snap(spot)
				glow:snap(alpha)
			else
				knob.Position = spot
				halo.ImageTransparency = alpha
			end
			theme:paint(track, "BackgroundColor3", trackToken)
			theme:paint(knob, "BackgroundColor3", knobToken)
			return
		end
		if slide == nil then
			slide = view:own(motion.prop(knob, "Position", KNOB_SPEED, KNOB_DAMPING))
			glow = view:own(motion.prop(halo, "ImageTransparency", HALO_SPEED))
		end
		slide:to(spot)
		glow:to(alpha)
		ctx.tint(track, "BackgroundColor3", trackToken)
		ctx.tint(knob, "BackgroundColor3", knobToken)
	end
end

function builders.toggle(ctx: any, el: any): any
	local head = el.spec.primary == true and not listed(el)
	local view: any = tileModule.new(ctx, el, { flat = true })
	view.isHead = head
	if head then
		-- the section's own title, and its switch
		view.name.TextSize = MASTER_TEXT
		ctx.theme:type(view.name, "display")
		view.root.BackgroundTransparency = 1
	end
	local function reserve(right: number)
		view.name.Size = UDim2.new(1, -(2 * PAD + right), 1, 0)
	end
	view.onReserve = reserve
	reserve(addons(view, ctx, el, SWITCH_WIDTH + CHIP_GAP))
	local setSwitch = switch(ctx, view)
	local function draw(instant: boolean)
		local on = el.value == true
		setSwitch(on, instant)
		view:ink(view.name, if el.disabled then "faint" elseif on or head then "text" else "muted", instant)
		for _, chip in view.chips do
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
		if listed(el) then
			view.name.Text = shownLabel(el)
		end
		draw(false)
	end
	view:refreshName()
	if listed(el) then
		view.name.Text = shownLabel(el)
	end
	draw(true)
	return view
end

-- the whole row is the slider: it fills behind its own name and value, with one bright edge at the value
function builders.slider(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el, { inert = true })
	local theme = ctx.theme
	local spec = el.spec
	local root = view.root
	root.Active = true
	root.BackgroundTransparency = 0
	make("UICorner", { CornerRadius = UDim.new(0, RADIUS), Parent = root })
	theme:paint(root, "BackgroundColor3", "raised")
	local function ratio(): number
		local span = spec.max - spec.min
		return if span <= 0 then 0 else math.clamp((el.value - spec.min) / span, 0, 1)
	end

	local width = readoutWidth(el)
	view.name.Size = UDim2.new(1, -(2 * PAD + width + 8), 1, 0)
	local readout = make("TextLabel", {
		Name = "Readout",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -PAD, 0, 0),
		Size = UDim2.new(0, width, 1, 0),
		TextSize = NAME,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 3,
		Parent = root,
	})
	theme:type(readout, "text", true)

	local fill = make("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(ratio(), 1),
		BackgroundTransparency = FILL_ON,
		ZIndex = 1,
		Parent = root,
	})
	make("UICorner", { CornerRadius = UDim.new(0, RADIUS), Parent = fill })
	theme:paint(fill, "BackgroundColor3", "accent")
	local edge = make("Frame", {
		Name = "Edge",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.new(0, EDGE_WIDTH, 1, -12),
		BackgroundTransparency = EDGE_ON,
		ZIndex = 2,
		Parent = fill,
	})
	make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = edge })
	theme:paint(edge, "BackgroundColor3", "accent")
	local fillSize: any = view:own(motion.prop(fill, "Size", FILL_SPEED))
	local fillLit: any = view:own(motion.prop(fill, "BackgroundTransparency", FILL_SPEED))
	local edgeLit: any = view:own(motion.prop(edge, "BackgroundTransparency", FILL_SPEED))

	view.onHover = function(_: any, on: boolean)
		ctx.tint(root, "BackgroundColor3", if on and not el.disabled then "lineStrong" else "raised")
	end
	root.MouseEnter:Connect(function()
		ctx.hover:enter(view)
	end)

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
			TextSize = NAME,
			TextXAlignment = Enum.TextXAlignment.Right,
			-- starts empty with the value behind it: select all does not take on a box focused this frame, and appending to the
			-- old number clamped "5572" to the maximum
			Text = "",
			PlaceholderText = tostring(el.value),
			ZIndex = 6,
			Parent = root,
		})
		theme:type(box, "text", true)
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
		local travel = math.max(root.AbsoluteSize.X, 1)
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
			el:set(startValue + span * delta.X / travel)
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

	local master = ownerOf(el)
	local function resting(): boolean
		return master ~= nil and master.value ~= true
	end
	-- the bright edge fades while it crosses the name or the value, or it reads as a stray stroke through the letters
	local function overText(): boolean
		local rowWidth = el._rowWidth or 0
		local at = ratio() * rowWidth
		local nameEnd = PAD + textWidth(view.name.Text, NAME) + 6
		local valueStart = rowWidth - PAD - width - 6
		return (at > PAD - 6 and at < nameEnd) or (at > valueStart and at < rowWidth - PAD + 4)
	end
	local function light(instant: boolean?)
		local off = resting()
		local fillAlpha = if off then FILL_OFF else FILL_ON
		local edgeAlpha = if overText() then 1 elseif off then EDGE_OFF else EDGE_ON
		if instant then
			fillLit:snap(fillAlpha)
			edgeLit:snap(edgeAlpha)
		else
			fillLit:to(fillAlpha)
			edgeLit:to(edgeAlpha)
		end
	end
	local function paintText()
		theme:paint(view.name, "TextColor3", if el.disabled then "faint" else "text")
		theme:paint(readout, "TextColor3", if el.disabled then "faint" else "text")
		readout.Text = formatted(el, el.value)
		if listed(el) then
			view.name.Text = shownLabel(el)
		end
	end
	view.refresh = function()
		view:refreshName()
		paintText()
		fillSize:to(UDim2.fromScale(ratio(), 1))
		light()
	end
	if master then
		view:onCleanup(master:on(function()
			light()
		end))
	end
	light(true)
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

local function refreshCaption(view: any, el: any)
	view:refreshName()
	if listed(el) then
		view.name.Text = shownLabel(el)
	end
end

-- two or three picks side by side, with one thumb that slides to the chosen one
local function segments(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el, { inert = true })
	local theme = ctx.theme
	view.root.Active = true
	view.root.MouseEnter:Connect(function()
		ctx.hover:enter(view)
	end)
	theme:paint(view.name, "TextColor3", "muted")
	refreshCaption(view, el)
	local display = el.spec.display or tostring
	local total = 0
	local spots: { any } = {}
	for _, option in el.spec.options do
		local width = math.ceil(textWidth(display(option), SEGMENT_TEXT)) + 2 * SEGMENT_PAD
		table.insert(spots, { option = option, x = total, width = width })
		total += width
	end
	local rail = make("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -4, 0.5, 0),
		Size = UDim2.fromOffset(total, SEGMENT_HEIGHT),
		BackgroundTransparency = 0,
		ZIndex = 2,
		Parent = view.root,
	})
	make("UICorner", { CornerRadius = UDim.new(0, RADIUS), Parent = rail })
	theme:paint(rail, "BackgroundColor3", "raised")
	local thumb = make("Frame", {
		BackgroundTransparency = 0,
		ZIndex = 2,
		Parent = rail,
	})
	make("UICorner", { CornerRadius = UDim.new(0, RADIUS), Parent = thumb })
	theme:paint(thumb, "BackgroundColor3", "accentDim")
	view.name.Size = UDim2.new(1, -(PAD + total + NAME_ROOM), 1, 0)
	local thumbAt: any = view:own(motion.prop(thumb, "Position", SEGMENT_SPEED))
	local thumbSize: any = view:own(motion.prop(thumb, "Size", SEGMENT_SPEED))
	for _, spot in spots do
		local button = make("TextButton", {
			Position = UDim2.fromOffset(spot.x, 0),
			Size = UDim2.new(0, spot.width, 1, 0),
			TextSize = SEGMENT_TEXT,
			Text = display(spot.option),
			ZIndex = 3,
			TextXAlignment = Enum.TextXAlignment.Center,
			Parent = rail,
		})
		theme:type(button, "text", true)
		spot.button = button
		button.Activated:Connect(function()
			if not el.disabled then
				el:set(spot.option)
			end
		end)
	end
	local function draw(instant: boolean)
		for _, spot in spots do
			local on = el.value == spot.option
			view:ink(spot.button, if el.disabled then "faint" elseif on then "accent" else "muted", instant)
			if on then
				local position = UDim2.fromOffset(spot.x, 0)
				local size = UDim2.new(0, spot.width, 1, 0)
				if instant then
					thumbAt:snap(position)
					thumbSize:snap(size)
				else
					thumbAt:to(position)
					thumbSize:to(size)
				end
			end
		end
	end
	view.refresh = function()
		refreshCaption(view, el)
		draw(false)
	end
	draw(true)
	return view
end

function builders.dropdown(ctx: any, el: any): any
	if kinds.form(el) then
		return segments(ctx, el)
	end
	local view: any = tileModule.new(ctx, el, { flat = true })
	local theme = ctx.theme
	local root = view.root
	root.ClipsDescendants = true
	theme:paint(view.name, "TextColor3", "muted")
	if listed(el) then
		view.name.Text = shownLabel(el)
	end
	view.name.Size = UDim2.new(0.45, -PAD, 1, 0)
	local text = make("TextLabel", {
		Name = "Value",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -(PAD + CHEVRON_ROOM), 0, 0),
		Size = UDim2.new(0.55, -(PAD + CHEVRON_ROOM), 1, 0),
		TextSize = NAME,
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
	root.Activated:Connect(function()
		if not el.disabled then
			droplist.open(ctx, el, root)
		end
	end)
	view.refresh = function()
		refreshCaption(view, el)
		local shown, picked = pickText(el)
		text.Text = shown
		theme:paint(text, "TextColor3", if el.disabled or not picked then "faint" else "text")
	end
	view.refresh()
	return view
end

function builders.input(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el, { inert = true })
	local theme = ctx.theme
	local spec = el.spec
	view.root.Active = true
	view.root.MouseEnter:Connect(function()
		ctx.hover:enter(view)
	end)
	view.name.Size = UDim2.new(0.38, -PAD, 1, 0)
	theme:paint(view.name, "TextColor3", "muted")
	local holder = make("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -4, 0.5, 0),
		Size = UDim2.new(0.62, -4, 0, SEGMENT_HEIGHT),
		BackgroundTransparency = 0,
		ZIndex = 2,
		Parent = view.root,
	})
	make("UICorner", { CornerRadius = UDim.new(0, RADIUS), Parent = holder })
	theme:paint(holder, "BackgroundColor3", "raised")
	local outline = make("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = 1,
		Transparency = 1,
		Parent = holder,
	})
	theme:paint(outline, "Color", "accent")
	local box = make("TextBox", {
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -20, 1, 0),
		TextSize = NAME,
		Text = el.value or "",
		PlaceholderText = spec.placeholder or "",
		ClipsDescendants = true,
		TextEditable = not el.disabled,
		ZIndex = 3,
		Parent = holder,
	})
	theme:type(box, "text", true)
	theme:paint(box, "TextColor3", "text")
	theme:paint(box, "PlaceholderColor3", "faint")
	local focus: any = view:own(motion.prop(outline, "Transparency", SEGMENT_SPEED))
	box.Focused:Connect(function()
		focus:to(0.2)
	end)
	box.FocusLost:Connect(function(enter: boolean)
		focus:to(1)
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
	view.refresh = function()
		refreshCaption(view, el)
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
	view.name.TextXAlignment = Enum.TextXAlignment.Center
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

function builders.stat(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el, { inert = true })
	local theme = ctx.theme
	view.name.Size = UDim2.new(0.6, -PAD, 1, 0)
	theme:paint(view.name, "TextColor3", "muted")
	local value = make("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -PAD, 0, 0),
		Size = UDim2.new(0.4, -PAD, 1, 0),
		TextSize = NAME,
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
	-- a line that carries a key or a color is a control, and gets a row like one
	if el.addons then
		local view: any = tileModule.new(ctx, el, { flat = true })
		theme:paint(view.name, "TextColor3", "muted")
		view.name.RichText = true
		local function reserve(right: number)
			view.name.Size = UDim2.new(1, -(2 * PAD + right), 1, 0)
		end
		view.onReserve = reserve
		reserve(addons(view, ctx, el, 0))
		view.refresh = function()
			view.name.Text = el.label
		end
		return view
	end
	local view: any = tileModule.new(ctx, el, { inert = true })
	local name = view.name
	local wrap = el.spec.wrap == true
	name.RichText = true
	name.TextWrapped = wrap
	theme:type(name, "text")
	theme:paint(name, "TextColor3", "muted")
	name.TextTruncate = if wrap then Enum.TextTruncate.None else Enum.TextTruncate.AtEnd
	name.TextYAlignment = if wrap then Enum.TextYAlignment.Top else Enum.TextYAlignment.Center
	name.LineHeight = if wrap then 1.15 else 1
	name.Position = UDim2.fromOffset(PAD, if wrap then 4 else 0)
	name.Size = UDim2.new(1, -2 * PAD, 1, if wrap then -4 else 0)
	name.Text = el.label
	if wrap then
		name:GetPropertyChangedSignal("TextBounds"):Connect(function()
			local height = math.ceil(name.TextBounds.Y / ctx.uiScale()) + 8
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
	local view: any = tileModule.new(ctx, el, { inert = true })
	local theme = ctx.theme
	theme:paint(view.name, "TextColor3", "muted")
	view.refresh = function()
		view.name.Text = el.label
	end
	return view
end

-- a key or color with no host of its own: the name stays the control, the chip reports
local function chipTile(ctx: any, el: any, chip: any, right: number): any
	local view: any = tileModule.new(ctx, el, { flat = true })
	ctx.theme:paint(view.name, "TextColor3", "muted")
	chip.root.AnchorPoint = Vector2.new(1, 0.5)
	chip.root.Position = UDim2.new(1, -right, 0.5, 0)
	chip.root.ZIndex = 4
	chip.root.Parent = view.root
	view.name.Size = UDim2.new(1, -(2 * PAD + chip.width), 1, 0)
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
	local view = chipTile(ctx, el, chip, PAD - 4)
	view.root.Activated:Connect(chip.start)
	return view
end

function builders.color(ctx: any, el: any): any
	local chip = colorpicker.swatch(ctx, el)
	local view = chipTile(ctx, el, chip, PAD - 8)
	view.root.Activated:Connect(chip.open)
	return view
end

function kinds.build(ctx: any, el: any): any
	local builder = builders[el.kind]
	assert(builder, "sottUI: no view for " .. tostring(el.kind))
	local view = builder(ctx, el)
	view.form = kinds.form(el)
	el._view = view
	return view
end

return kinds
