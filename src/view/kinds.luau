--!strict
-- the desk's controls. every builder only reads the model; state flows model -> refresh, never the other way, so a config
-- load, a keybind and a click all draw the same. measure() answers a control's size before any instance exists

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
local PAD_HEIGHT = tileModule.HEIGHT
local NAME = tileModule.NAME
local PAD_WIDTH = 132
local MAX_PAD_WIDTH = 230
local LED_ROOM = 28
local LED = 7
local GLOW = 26
local GLOW_REST = 0.3
local GLOW_SPEED = 20
local CAPTION = 13
local CAPTION_ROW = 20
local OPTION_STEP = PAD_HEIGHT + 4
local MAX_INLINE_OPTIONS = 3
local KEY_ROOM = 8

local FADER_MIN = 60
local READOUT = 14
local READOUT_ROW = 22
local LABEL_ROW = 20
local RAIL = 4
local CAP_WIDTH = 34
local CAP_HEIGHT = 24
local CAP_HALF = CAP_HEIGHT / 2
local TICK_WIDTH = 30
local TICK_STEP = 12
local FILL_SPEED = 30
local FILL_DRAG_SPEED = 80
local DRAG_START = 3
local OFF_FILL = 0.72

local INPUT_WIDTH = 210
local STAT_WIDTH = 170
local STAT_HEIGHT = 30
local WRAP_WIDTH = 300
local LINE_HEIGHT = 22
local DIVIDER = 22
local MASTER_TEXT = 15

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

local function addonRoom(el: any): number
	local room = 0
	for _, addon in el.addons or {} do
		if not addon.spec.chipless then
			if addon.kind == "key" then
				local value = addon.value
				local shown = if value and value.key ~= "None" then value.key else "Unset"
				room += metrics.width("mono", shown, 12) + 16 + KEY_ROOM + 6
			else
				room += colorpicker.DOT_SPACE
			end
		end
	end
	return room
end

-- inline options read at a glance and take one click, but a list that can change or run long needs its popover
local function isInline(el: any): boolean
	local spec = el.spec
	local count = #spec.options
	if spec.multi or count > MAX_INLINE_OPTIONS or el._inline == false then
		el._inline = false
		return false
	end
	if el._inline == nil then
		el._inline = count >= 2 and el.value ~= nil
	end
	return el._inline
end

-- the form a dropdown is built in; a change means the page has to rebuild its view
function kinds.form(el: any): any
	return if el.kind == "dropdown" then isInline(el) else nil
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
		widest = math.max(widest, metrics.width("mono", formatted(el, value), READOUT))
	end
	return math.ceil(widest) + 2
end

-- { width, height, fader }: a fader takes the strip's full height, the rest flow down columns
function kinds.measure(el: any): any
	local kind = el.kind
	if kind == "slider" then
		local width = math.max(FADER_MIN, textWidth(shownLabel(el), CAPTION) + 8, readoutWidth(el) + 8)
		return { width = math.ceil(width), fader = true }
	elseif kind == "toggle" or kind == "key" or kind == "color" or (kind == "label" and el.addons) then
		local width = LED_ROOM + textWidth(shownLabel(el), NAME) + PAD + addonRoom(el)
		return { width = math.clamp(math.ceil(width), PAD_WIDTH, MAX_PAD_WIDTH), height = PAD_HEIGHT }
	elseif kind == "button" then
		return {
			width = math.clamp(math.ceil(textWidth(el.label, NAME) + 2 * PAD), PAD_WIDTH, MAX_PAD_WIDTH),
			height = PAD_HEIGHT,
		}
	elseif kind == "dropdown" then
		local display = el.spec.display or tostring
		local widest = textWidth(shownLabel(el), CAPTION)
		for _, option in el.spec.options do
			widest = math.max(widest, textWidth(display(option), NAME) + LED_ROOM + PAD)
		end
		if isInline(el) then
			return {
				width = math.clamp(math.ceil(widest), PAD_WIDTH, MAX_PAD_WIDTH),
				height = CAPTION_ROW + #el.spec.options * OPTION_STEP - 4,
			}
		end
		return { width = math.clamp(math.ceil(widest), 150, MAX_PAD_WIDTH), height = CAPTION_ROW + PAD_HEIGHT }
	elseif kind == "input" then
		return { width = INPUT_WIDTH, height = CAPTION_ROW + PAD_HEIGHT }
	elseif kind == "stat" then
		return { width = STAT_WIDTH, height = STAT_HEIGHT }
	elseif kind == "divider" then
		return if el.label == "" then { width = 0, height = 4 } else { width = 0, height = DIVIDER }
	elseif kind == "label" then
		if el.spec.wrap then
			if el._measured then
				return { width = WRAP_WIDTH, height = el._measured }
			end
			local plain = string.gsub(el.label, "<[^>]+>", "")
			local perLine = math.floor(WRAP_WIDTH / 7)
			return { width = WRAP_WIDTH, height = math.ceil(#plain / perLine) * LINE_HEIGHT + 6 }
		end
		return { width = math.min(math.ceil(textWidth(el.label, NAME)) + 4, WRAP_WIDTH), height = LINE_HEIGHT + 4 }
	end
	return { width = PAD_WIDTH, height = PAD_HEIGHT }
end

-- what a master's switch needs along the strip's foot
function kinds.masterWidth(el: any): number
	return math.ceil(96 + addonRoom(el))
end

-- colour dots then key chips, right to left from the pad's edge. returns the room taken
local function addons(view: any, ctx: any, el: any): number
	local used = 0
	local placed: { any } = {}
	-- a chip's width changes with what it shows ("Press a key"), which moves its neighbours and the name's limit
	local function reflow()
		local offset = 0
		for _, chip in placed do
			chip.root.Position = UDim2.new(1, -(PAD - 4 + offset), 0.5, 0)
			offset += chip.width + chip.gap
		end
		if view.onReserve then
			view.onReserve(offset)
		end
	end
	local function place(addon: any, chip: any)
		chip.root.AnchorPoint = Vector2.new(1, 0.5)
		chip.root.Position = UDim2.new(1, -(PAD - 4 + used), 0.5, 0)
		chip.root.ZIndex = 4
		chip.root.Parent = view.root
		chip.gap = if addon.kind == "key" then 6 else 0
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

-- a small light with a soft halo. the halo eases rather than popping, which is most of why a switch feels good here
local function lamp(ctx: any, parent: any, view: any): (boolean, boolean?) -> ()
	local theme = ctx.theme
	local glow = make("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, PAD + LED / 2, 0.5, 0),
		Size = UDim2.fromOffset(GLOW, GLOW),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ImageTransparency = 1,
		ZIndex = 2,
		Parent = parent,
	})
	theme:paint(glow, "ImageColor3", "accent")
	ctx.art(glow, "glow.png")
	local dot = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, PAD + LED / 2, 0.5, 0),
		Size = UDim2.fromOffset(LED, LED),
		BackgroundTransparency = 0,
		ZIndex = 3,
		Parent = parent,
	})
	make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = dot })
	theme:paint(dot, "BackgroundColor3", "lineStrong")
	local halo: any = nil
	return function(on: boolean, instant: boolean?)
		local target = if on then GLOW_REST else 1
		if instant then
			if halo then
				halo:snap(target)
			else
				glow.ImageTransparency = target
			end
			theme:paint(dot, "BackgroundColor3", if on then "accent" else "lineStrong")
			return
		end
		if halo == nil then
			halo = view:own(motion.prop(glow, "ImageTransparency", GLOW_SPEED))
		end
		halo:to(target)
		ctx.tint(dot, "BackgroundColor3", if on then "accent" else "lineStrong")
	end
end

local function padToggle(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el)
	view.name.Position = UDim2.fromOffset(LED_ROOM, 0)
	local function reserve(right: number)
		view.name.Size = UDim2.new(1, -(LED_ROOM + PAD + right), 1, 0)
	end
	view.onReserve = reserve
	reserve(addons(view, ctx, el))
	local light = lamp(ctx, view.root, view)
	local function draw(instant: boolean)
		local on = el.value == true
		light(on, instant)
		view:ink(view.name, if el.disabled then "faint" elseif on then "text" else "muted", instant)
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
	view.refresh()
	draw(true)
	return view
end

-- the strip's main switch, along its foot: the one place mint fills a surface
local function masterSwitch(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el)
	view.name.TextSize = MASTER_TEXT
	ctx.theme:type(view.name, "display")
	local function reserve(right: number)
		view.name.Size = UDim2.new(1, -(2 * PAD + right), 1, 0)
	end
	view.onReserve = reserve
	reserve(addons(view, ctx, el))
	view.refreshName = function(this: any)
		this.name.Text = if el.value == true then "On" else "Off"
	end
	local function draw(instant: boolean)
		local on = el.value == true
		view:refreshName()
		view:flood(on, instant)
		view:ink(view.name, if el.disabled then "faint" elseif on then "onAccent" else "muted", instant)
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
		draw(false)
	end
	draw(true)
	return view
end

function builders.toggle(ctx: any, el: any): any
	if el.spec.primary and not listed(el) then
		return masterSwitch(ctx, el)
	end
	return padToggle(ctx, el)
end

-- a vertical fader: value on top, cap on a ruled rail, name underneath. the cap rides the fill's top edge so one spring
-- moves both
function builders.slider(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el, { inert = true })
	local theme = ctx.theme
	local spec = el.spec
	local root = view.root
	root.Active = true
	root.ClipsDescendants = false
	local function ratio(): number
		local span = spec.max - spec.min
		return if span <= 0 then 0 else math.clamp((el.value - spec.min) / span, 0, 1)
	end

	local readout = make("TextLabel", {
		Name = "Readout",
		Size = UDim2.new(1, 0, 0, READOUT_ROW),
		TextSize = READOUT,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 3,
		Parent = root,
	})
	theme:type(readout, "mono")
	view.name.AnchorPoint = Vector2.new(0, 1)
	view.name.Position = UDim2.fromScale(0, 1)
	view.name.Size = UDim2.new(1, 0, 0, LABEL_ROW)
	view.name.TextSize = CAPTION
	view.name.TextXAlignment = Enum.TextXAlignment.Center
	view.name.TextTruncate = Enum.TextTruncate.None

	local top = READOUT_ROW + CAP_HALF
	local bottom = LABEL_ROW + CAP_HALF
	local rule = make("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, top),
		Size = UDim2.new(0, TICK_WIDTH, 1, -(top + bottom)),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.fromOffset(TICK_WIDTH, TICK_STEP),
		ZIndex = 1,
		Parent = root,
	})
	theme:paint(rule, "ImageColor3", "lineStrong")
	ctx.art(rule, "ticks.png")
	local rail = make("Frame", {
		Name = "Rail",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, top),
		Size = UDim2.new(0, RAIL, 1, -(top + bottom)),
		BackgroundTransparency = 0,
		ZIndex = 2,
		Parent = root,
	})
	make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = rail })
	theme:paint(rail, "BackgroundColor3", "line")
	local fill = make("Frame", {
		Name = "Fill",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.fromScale(1, ratio()),
		BackgroundTransparency = 0,
		ZIndex = 2,
		Parent = rail,
	})
	make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
	theme:paint(fill, "BackgroundColor3", "accent")
	local cap = make("Frame", {
		Name = "Cap",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.fromOffset(CAP_WIDTH, CAP_HEIGHT),
		BackgroundTransparency = 0,
		ZIndex = 3,
		Parent = fill,
	})
	make("UICorner", { CornerRadius = UDim.new(0, 7), Parent = cap })
	theme:paint(cap, "BackgroundColor3", "lineStrong")
	make("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(150, 150, 150)),
		Parent = cap,
	})
	local mark = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -12, 0, 2),
		BackgroundTransparency = 0,
		ZIndex = 4,
		Parent = cap,
	})
	make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = mark })
	theme:paint(mark, "BackgroundColor3", "text")
	local fillSize: any = view:own(motion.prop(fill, "Size", FILL_SPEED))
	local lit: any = view:own(motion.prop(fill, "BackgroundTransparency", FILL_SPEED))

	view.onHover = function(_: any, on: boolean)
		ctx.tint(cap, "BackgroundColor3", if on and not el.disabled then "muted" else "lineStrong")
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
			Size = UDim2.new(1, 0, 0, READOUT_ROW),
			TextSize = READOUT,
			TextXAlignment = Enum.TextXAlignment.Center,
			-- starts empty with the value behind it: select all does not take on a box focused this frame, and appending to the
			-- old number clamped "5572" to the maximum
			Text = "",
			PlaceholderText = tostring(el.value),
			ZIndex = 6,
			Parent = root,
		})
		theme:type(box, "mono")
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
		local travel = math.max(rail.AbsoluteSize.Y, 1)
		local span = spec.max - spec.min
		local dragging = false
		-- a swipe handed back to the scroller ends here too, and must not read as a tap that opens the keyboard
		local cancelled = false
		ctx.input:capture(function(at: Vector2)
			local delta = at - from
			if not dragging then
				if math.abs(delta.Y) < DRAG_START then
					if touch and math.abs(delta.X) > 8 then
						cancelled = true
						ctx.input:release()
					end
					return
				end
				if touch and math.abs(delta.Y) <= math.abs(delta.X) then
					cancelled = true
					ctx.input:release()
					return
				end
				dragging = true
				fillSize.speed = FILL_DRAG_SPEED
				ctx.setScrollLocked(true)
			end
			el:set(startValue - span * delta.Y / travel)
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
	local function dim(): number
		return if master and master.value ~= true then OFF_FILL else 0
	end
	local function paintText()
		theme:paint(view.name, "TextColor3", if el.disabled then "faint" else "muted")
		theme:paint(readout, "TextColor3", if el.disabled then "faint" else "text")
		readout.Text = formatted(el, el.value)
	end
	view.refresh = function()
		view:refreshName()
		if listed(el) then
			view.name.Text = shownLabel(el)
		end
		paintText()
		fillSize:to(UDim2.fromScale(1, ratio()))
		lit:to(dim())
	end
	if master then
		view:onCleanup(master:on(function()
			lit:to(dim())
		end))
	end
	lit:snap(dim())
	view:refreshName()
	if listed(el) then
		view.name.Text = shownLabel(el)
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

local function caption(ctx: any, view: any, el: any)
	view.name.Position = UDim2.new()
	view.name.Size = UDim2.new(1, 0, 0, CAPTION_ROW - 2)
	view.name.TextSize = CAPTION
	ctx.theme:paint(view.name, "TextColor3", "muted")
	if listed(el) then
		view.name.Text = shownLabel(el)
	end
end

local function well(ctx: any, parent: any, class: string): any
	local box = make(class, {
		Name = "Well",
		Position = UDim2.fromOffset(0, CAPTION_ROW),
		Size = UDim2.new(1, 0, 0, PAD_HEIGHT),
		BackgroundTransparency = 0,
		ZIndex = 2,
		Parent = parent,
	})
	make("UICorner", { CornerRadius = UDim.new(0, RADIUS), Parent = box })
	ctx.theme:paint(box, "BackgroundColor3", "raised")
	return box
end

local function inlineOptions(ctx: any, el: any): any
	local view: any = tileModule.new(ctx, el, { inert = true })
	view.root.Active = true
	caption(ctx, view, el)
	local display = el.spec.display or tostring
	local rows: { any } = {}
	local builtFor = ""

	local function build()
		for _, row in rows do
			row.button:Destroy()
		end
		table.clear(rows)
		for index, option in el.spec.options do
			local button = make("TextButton", {
				Name = "Option",
				Position = UDim2.fromOffset(0, CAPTION_ROW + (index - 1) * OPTION_STEP),
				Size = UDim2.new(1, 0, 0, PAD_HEIGHT),
				BackgroundTransparency = 0,
				ZIndex = 2,
				Parent = view.root,
			})
			make("UICorner", { CornerRadius = UDim.new(0, RADIUS), Parent = button })
			ctx.theme:paint(button, "BackgroundColor3", "raised")
			local label = make("TextLabel", {
				Position = UDim2.fromOffset(LED_ROOM, 0),
				Size = UDim2.new(1, -(LED_ROOM + PAD), 1, 0),
				TextSize = NAME,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Text = display(option),
				ZIndex = 3,
				Parent = button,
			})
			ctx.theme:type(label, "text", true)
			local row = { button = button, label = label, option = option, light = lamp(ctx, button, view) }
			button.Activated:Connect(function()
				if not el.disabled then
					el:set(option)
				end
			end)
			button.MouseEnter:Connect(function()
				ctx.tint(button, "BackgroundColor3", "lineStrong")
			end)
			button.MouseLeave:Connect(function()
				ctx.tint(button, "BackgroundColor3", "raised")
			end)
			table.insert(rows, row)
		end
	end

	local function draw(instant: boolean)
		for _, row in rows do
			local on = el.value == row.option
			row.light(on, instant)
			view:ink(row.label, if el.disabled then "faint" elseif on then "text" else "muted", instant)
		end
	end

	view.refresh = function()
		local key = table.concat(el.spec.options :: any, "\0")
		if key ~= builtFor then
			builtFor = key
			build()
			draw(true)
			if el._relayout then
				el._relayout()
			end
		else
			draw(false)
		end
	end
	builtFor = table.concat(el.spec.options :: any, "\0")
	build()
	draw(true)
	return view
end

function builders.dropdown(ctx: any, el: any): any
	if isInline(el) then
		return inlineOptions(ctx, el)
	end
	local view: any = tileModule.new(ctx, el, { inert = true })
	local theme = ctx.theme
	view.root.Active = true
	view.root.ClipsDescendants = false
	caption(ctx, view, el)
	local box = well(ctx, view.root, "TextButton")
	local text = make("TextLabel", {
		Name = "Value",
		Position = UDim2.fromOffset(PAD, 0),
		Size = UDim2.new(1, -(2 * PAD + 18), 1, 0),
		TextSize = NAME,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 3,
		Parent = box,
	})
	theme:type(text, "text", true)
	local chevron = ctx.glyph.chevron(box, "muted")
	chevron.AnchorPoint = Vector2.new(1, 0.5)
	chevron.Position = UDim2.new(1, -PAD, 0.5, 0)
	chevron.ZIndex = 3
	box.MouseEnter:Connect(function()
		ctx.tint(box, "BackgroundColor3", "lineStrong")
	end)
	box.MouseLeave:Connect(function()
		ctx.tint(box, "BackgroundColor3", "raised")
	end)
	box.Activated:Connect(function()
		if not el.disabled then
			droplist.open(ctx, el, box)
		end
	end)
	view.refresh = function()
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
	view.root.ClipsDescendants = false
	caption(ctx, view, el)
	local holder = well(ctx, view.root, "Frame")
	local outline = make("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Thickness = 1, Parent = holder })
	theme:paint(outline, "Color", "line")
	local box = make("TextBox", {
		Position = UDim2.fromOffset(PAD, 0),
		Size = UDim2.new(1, -2 * PAD, 1, 0),
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

	box.Focused:Connect(function()
		ctx.tint(outline, "Color", "accent")
	end)
	box.FocusLost:Connect(function(enter: boolean)
		ctx.tint(outline, "Color", "line")
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
		box.TextEditable = not el.disabled
		if box.Text ~= (el.value or "") then
			view._applying = true
			box.Text = el.value or ""
			view._applying = false
		end
	end
	return view
end

-- centred, with no light: a pad with nothing to report does something when pressed
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
	view.name.Position = UDim2.new()
	view.name.Size = UDim2.fromScale(0.6, 1)
	theme:paint(view.name, "TextColor3", "muted")
	local value = make("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.fromScale(0.4, 1),
		TextSize = NAME,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 3,
		Parent = view.root,
	})
	theme:type(value, "mono")
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
	-- a line that carries a key or a color is a control, and gets a pad like one
	if el.addons then
		local view: any = tileModule.new(ctx, el)
		theme:paint(view.name, "TextColor3", "muted")
		view.name.RichText = true
		local function reserve(right: number)
			view.name.Size = UDim2.new(1, -(2 * PAD + right), 1, 0)
		end
		view.onReserve = reserve
		reserve(addons(view, ctx, el))
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
	name.Position = UDim2.new()
	name.Size = UDim2.fromScale(1, 1)
	name.Text = el.label
	if wrap then
		name:GetPropertyChangedSignal("TextBounds"):Connect(function()
			local height = math.ceil(name.TextBounds.Y / ctx.uiScale()) + 6
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
	view.name.Position = UDim2.new()
	view.name.Size = UDim2.fromScale(1, 1)
	view.name.TextSize = CAPTION
	theme:paint(view.name, "TextColor3", "muted")
	view.refresh = function()
		view.name.Text = el.label
	end
	return view
end

-- a key or color with no host of its own: the name stays the control, the chip reports
local function chipTile(ctx: any, el: any, chip: any, right: number): any
	local view: any = tileModule.new(ctx, el)
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
