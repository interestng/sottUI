--!strict
-- builds the row for each element kind. every builder only reads the model; state flows model -> refresh, never the
-- other way, so a config load, a keybind and a click all draw the same

local colorpicker = require("./colorpicker")
local droplist = require("./droplist")
local keychip = require("./keychip")
local make = require("../core/make")
local metrics = require("../core/metrics")
local motion = require("../core/motion")
local rowModule = require("./row")

local kinds = {}

local PAD = rowModule.PAD
local INDENT = 16
local MASTER_HEIGHT = 62
local MASTER_NAME = 25
local SLIDER_HEIGHT = 62
local RULER = 18
local RULER_TICKS = 12
local RULER_TILE = 40
local NEEDLE = 3
local READOUT = 17
local FILL_SPEED = 42
local FILL_DRAG_SPEED = 90
local DRAG_START = 3
local STATE_WIDTH = 24
local CHEVRON = 22
local INPUT_HEIGHT = 30
local TEXT_ROW = 16

kinds.MASTER_HEIGHT = MASTER_HEIGHT
kinds.SLIDER_HEIGHT = SLIDER_HEIGHT

local builders: { [string]: (ctx: any, el: any) -> any } = {}

-- a row under a master hangs off it: indented, on a rail that lights with the master
local function indentOf(el: any): number
	-- out of its section, in a list of results, it hangs off nothing
	local shownOn = el._shownOn
	if shownOn and shownOn.sections[1] and shownOn.sections[1].flat then
		return 0
	end
	local section = el.section
	local owner = section and (section._root or section)
	if owner and owner.masterElement and owner.masterElement ~= el then
		return INDENT
	end
	return 0
end

local function newRow(ctx: any, el: any, options: any?): any
	local settings = options or {}
	settings.indent = settings.indent or indentOf(el)
	local view: any = rowModule.new(ctx, el, settings)
	-- out of its section a bare "FOV" could be anything: in a result list the row says whose it is
	local shownOn = el._shownOn
	if shownOn and shownOn.sections[1] and shownOn.sections[1].flat then
		local owner = el.section and (el.section._root or el.section)
		local master = owner and owner.masterElement
		if master and master ~= el then
			local refreshName = view.refreshName
			view.refreshName = function(this: any)
				refreshName(this)
				this.name.Text = master.label .. " " .. el.label
			end
			view:refreshName()
		end
	end
	if settings.indent > 0 then
		-- a dim stretch of the rail under an open master, so its block reads as one line with the lit rows brighter on it
		local stretch = make("Frame", {
			Name = "Stretch",
			Size = UDim2.new(0, 3, 1, 0),
			BackgroundTransparency = 0,
			ZIndex = 1,
			Parent = view.root,
		})
		ctx.theme:paint(stretch, "BackgroundColor3", "accentDim")
	end
	return view
end

local function addons(view: any, ctx: any, el: any, inner: number): number
	local placed: { any } = {}
	local function reflow()
		local offset = inner
		for _, chip in placed do
			chip.root.Position = UDim2.new(1, -(PAD + offset), 0.5, 0)
			offset += chip.width + chip.gap
		end
		view.name.Size = UDim2.new(1, -(2 * PAD + view.indent + offset), 1, 0)
	end
	local function place(addon: any, chip: any)
		chip.root.AnchorPoint = Vector2.new(1, 0.5)
		chip.root.ZIndex = 4
		chip.root.Parent = view.root
		chip.gap = if addon.kind == "key" then 6 else 0
		chip.onFit = reflow
		table.insert(placed, chip)
		addon._view = chip
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
	reflow()
	return inner
end

function builders.toggle(ctx: any, el: any): any
	local master = el.spec.primary == true
	local view: any = newRow(ctx, el, { height = if master then MASTER_HEIGHT else nil })
	local theme = ctx.theme
	if master then
		theme:type(view.name, "display")
		view.name.TextSize = MASTER_NAME
		view.name.TextWrapped = false
	end

	local state = make("TextLabel", {
		Name = "State",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -PAD, 0, 0),
		Size = UDim2.new(0, STATE_WIDTH, 1, 0),
		TextSize = rowModule.NAME,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 3,
		Parent = view.root,
	})
	theme:type(state, "text", true)

	local peek: any = nil
	local chevronDown: any = nil
	local chevronUp: any = nil
	local inner = STATE_WIDTH + 42
	if master then
		peek = make("TextButton", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -(PAD + STATE_WIDTH + 4), 0, 0),
			Size = UDim2.new(0, 34, 1, 0),
			ZIndex = 4,
			Parent = view.root,
		})
		chevronDown = ctx.glyph.chevron(peek, "faint", "down")
		chevronUp = ctx.glyph.chevron(peek, "muted", "up")
		for _, chevron in { chevronDown, chevronUp } do
			chevron.AnchorPoint = Vector2.new(0.5, 0.5)
			chevron.Position = UDim2.fromScale(0.5, 0.5)
		end
		peek.Activated:Connect(function()
			el.section:togglePeek()
			view.refresh()
		end)
	end
	addons(view, ctx, el, inner)

	local function draw(instant: boolean)
		local on = el.value == true
		view:lit(on, instant)
		local flooded = master and on
		view:ink(
			view.name,
			if el.disabled then "faint" elseif flooded then "onAccent" elseif on then "text" else "muted",
			instant
		)
		state.Text = if on then "on" else "off"
		view:ink(
			state,
			if el.disabled then "line" elseif flooded then "onAccent" elseif on then "accent" else "muted",
			instant
		)
		for _, chip in view.chips do
			chip.setInk(flooded)
		end
		if peek then
			peek.Visible = not on and el.section.hasOptions == true
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

-- ticks, an instrument's scale rather than a generic bar: two tiled images, the lit one clipped to the value. plain lines
-- until the tile has loaded, or for good on an executor with no custom assets
function builders.slider(ctx: any, el: any): any
	local view: any = newRow(ctx, el, { height = SLIDER_HEIGHT })
	local theme = ctx.theme
	local spec = el.spec
	local root = view.root
	local indent = view.indent
	local function ratio(): number
		local span = spec.max - spec.min
		return if span <= 0 then 0 else (el.value - spec.min) / span
	end

	view.name.Position = UDim2.fromOffset(PAD + indent, 8)
	view.name.Size = UDim2.new(1, -(2 * PAD + indent + 96), 0, 24)
	view.name.TextWrapped = false
	view._rest = nil

	local readout = make("TextLabel", {
		Name = "Readout",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -PAD, 0, 8),
		Size = UDim2.new(0, 96, 0, 24),
		TextSize = READOUT,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 4,
		Parent = root,
	})
	theme:type(readout, "text", true)

	local bed = make("Frame", {
		Name = "Ruler",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, PAD + indent, 1, -6),
		Size = UDim2.new(1, -(2 * PAD + indent), 0, RULER),
		ClipsDescendants = true,
		ZIndex = 2,
		Parent = root,
	})
	local function ticks(parent: any, token: string): any
		local image = make("ImageLabel", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(0, 400, 0, RULER_TICKS),
			ScaleType = Enum.ScaleType.Tile,
			TileSize = UDim2.fromOffset(RULER_TILE, RULER_TICKS),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 2,
			Parent = parent,
		})
		theme:paint(image, "ImageColor3", token)
		return image
	end
	local dim = ticks(bed, "lineStrong")
	local fill = make("Frame", {
		Name = "Fill",
		Size = UDim2.new(ratio(), 0, 1, 0),
		ClipsDescendants = true,
		ZIndex = 2,
		Parent = bed,
	})
	local lit = ticks(fill, "accent")
	local head = make("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, NEEDLE, 1, 0),
		BackgroundTransparency = 0,
		ZIndex = 3,
		Parent = fill,
	})
	theme:paint(head, "BackgroundColor3", "text")

	local function applyTicks()
		local image = ctx.assets.ticks
		dim.Image = image or ""
		lit.Image = image or ""
		local solid = if image then 1 else 0
		dim.BackgroundTransparency = solid
		lit.BackgroundTransparency = solid
		dim.BackgroundColor3 = theme.tokens.lineStrong
		lit.BackgroundColor3 = theme.tokens.accent
		local width = bed.AbsoluteSize.X / ctx.uiScale()
		dim.Size = UDim2.new(0, width, 0, RULER_TICKS)
		lit.Size = UDim2.new(0, width, 0, RULER_TICKS)
	end
	root:GetPropertyChangedSignal("AbsoluteSize"):Connect(applyTicks)
	task.defer(applyTicks)

	local fillSize: any = view:own(motion.prop(fill, "Size", FILL_SPEED))

	local function typedEntry()
		if el.disabled or view._typing then
			return
		end
		view._typing = true
		readout.Visible = false
		local box = make("TextBox", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -PAD, 0, 8),
			Size = UDim2.new(0, 96, 0, 24),
			TextSize = READOUT,
			TextXAlignment = Enum.TextXAlignment.Right,
			-- starts empty with the value behind it: select all does not take on a box focused this frame
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
		local width = math.max(bed.AbsoluteSize.X, 1)
		local span = spec.max - spec.min
		local dragging = false
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
			el:set(startValue + span * delta.X / width)
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
		local ink = if el.disabled then "faint" else "muted"
		theme:paint(view.name, "TextColor3", ink)
		theme:paint(readout, "TextColor3", if el.disabled then "faint" else "text")
		readout.Text = formatted(el, el.value)
	end
	view.refresh = function()
		view:refreshName()
		paintText()
		applyTicks()
		fillSize:to(UDim2.new(ratio(), 0, 1, 0))
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
	local view: any = newRow(ctx, el)
	local theme = ctx.theme
	local root = view.root
	theme:paint(view.name, "TextColor3", "muted")

	local text = make("TextLabel", {
		Name = "Value",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -(PAD + CHEVRON), 0, 0),
		Size = UDim2.new(0.55, -CHEVRON, 1, 0),
		TextSize = rowModule.NAME,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 3,
		Parent = root,
	})
	theme:type(text, "text", true)
	local chevron = ctx.glyph.chevron(root, "faint")
	chevron.AnchorPoint = Vector2.new(1, 0.5)
	chevron.Position = UDim2.new(1, -PAD, 0.5, 0)
	chevron.ZIndex = 3
	view.name.Size = UDim2.new(0.45, -(PAD + view.indent), 1, 0)

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
	end
	view.refresh()
	return view
end

function builders.input(ctx: any, el: any): any
	local view: any = newRow(ctx, el)
	local theme = ctx.theme
	local spec = el.spec
	view.name.Size = UDim2.new(0.35, -(PAD + view.indent), 1, 0)
	theme:paint(view.name, "TextColor3", "muted")
	local box = make("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -PAD, 0.5, 0),
		Size = UDim2.new(0.65, -PAD, 0, INPUT_HEIGHT),
		TextSize = rowModule.NAME,
		Text = el.value or "",
		PlaceholderText = spec.placeholder or "",
		ClipsDescendants = true,
		TextXAlignment = Enum.TextXAlignment.Right,
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
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundTransparency = 0,
		ZIndex = 4,
		Parent = box,
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

function builders.button(ctx: any, el: any): any
	local view: any = newRow(ctx, el)
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
			view:ink(view.name, "accent")
			armed = task.delay(2.5, function()
				armed = nil
				draw()
			end)
			return
		end
		if armed then
			task.cancel(armed)
			armed = nil
			draw()
		end
		view:flash()
		el:fire()
	end)
	view:onCleanup(function()
		if armed then
			task.cancel(armed)
		end
	end)
	return view
end

-- a ledger line: what it is on the left, the figure on the right
function builders.stat(ctx: any, el: any): any
	local view: any = newRow(ctx, el, { height = 36, inert = true })
	local theme = ctx.theme
	theme:paint(view.name, "TextColor3", "muted")
	local figure = make("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -PAD, 0, 0),
		Size = UDim2.new(0.6, 0, 1, 0),
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 3,
		Parent = view.root,
	})
	theme:type(figure, "display")
	theme:paint(figure, "TextColor3", "text")
	view.refresh = function()
		view.name.Text = el.label
		figure.Text = tostring(el.value)
	end
	view.refresh()
	return view
end

function builders.label(ctx: any, el: any): any
	local theme = ctx.theme
	if el.addons then
		local view: any = newRow(ctx, el)
		theme:paint(view.name, "TextColor3", "muted")
		view.name.RichText = true
		addons(view, ctx, el, 0)
		view.refresh = function()
			view.name.Text = el.label
		end
		return view
	end
	local view: any = newRow(ctx, el, { height = 30, inert = true })
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
	name.Position = UDim2.fromOffset(PAD + view.indent, if wrap then 6 else 0)
	name.Size = if wrap
		then UDim2.new(1, -(2 * PAD + view.indent), 1, -6)
		else UDim2.new(1, -(2 * PAD + view.indent), 1, 0)
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
	local view: any = newRow(ctx, el, { height = 28, inert = true })
	ctx.theme:paint(view.name, "TextColor3", "faint")
	view.name.TextSize = TEXT_ROW
	view.refresh = function()
		view.name.Text = el.label
	end
	return view
end

local function chipRow(ctx: any, el: any, chip: any, reserve: number): any
	local view: any = newRow(ctx, el)
	ctx.theme:paint(view.name, "TextColor3", "muted")
	chip.root.AnchorPoint = Vector2.new(1, 0.5)
	chip.root.Position = UDim2.new(1, -(PAD - 8), 0.5, 0)
	chip.root.ZIndex = 4
	chip.root.Parent = view.root
	view.name.Size = UDim2.new(1, -(2 * PAD + view.indent + reserve), 1, 0)
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
	local view = chipRow(ctx, el, chip, 96)
	view.root.Activated:Connect(chip.start)
	return view
end

function builders.color(ctx: any, el: any): any
	local chip = colorpicker.swatch(ctx, el)
	local view = chipRow(ctx, el, chip, colorpicker.DOT_SPACE)
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

kinds.metrics = metrics

return kinds
