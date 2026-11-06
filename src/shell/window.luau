--!strict
-- a rounded box you can drag: pages along the top, each one a desk of channel strips. the window is as wide as its page
-- needs, up to the screen, and opens like a lid from under its top bar. a light on a page's name says something there is
-- running. the keyboard stays with the game until you click into search

local dialogModule = require("./dialog")
local env = require("../core/env")
local fonts = require("../core/fonts")
local glyphModule = require("../view/glyph")
local inputModule = require("../core/input")
local keysModule = require("./keys")
local maidModule = require("../core/maid")
local make = require("../core/make")
local metrics = require("../core/metrics")
local motion = require("../core/motion")
local notifyModule = require("./notify")
local overlay = require("./overlay")
local pageModule = require("./page")
local search = require("../model/search")
local sectionModule = require("./section")
local openerModule = require("./opener")
local signal = require("../core/signal")
local themeModule = require("../core/theme")
local tintModule = require("../core/tint")

local window = {}

local VERSION = "main"
local FONT_BASE = "https://raw.githubusercontent.com/interestng/sottUI/%s/fonts/"
local ART = { "glow.png", "shadow.png", "ticks.png" }

local HEIGHT = 420
local TOP = 48
local RADIUS = 14
local MAX_WIDTH = 1120
local EDGE = 16
local SHADOW = 32
local SHADOW_REST = 0.35
local TAB_TEXT = 14
local TAB_PAD = 14
local TAB_LED = 7
local TAB_LED_ROOM = 15
local MARK_TEXT = 14
local MARK_PAD = 18
local SEARCH = 168
local SEARCH_HEIGHT = 30
local CLOSE = 30
local RIGHT_PAD = 9
local TOP_GAP = 18
local MARKER = 2
local SIZE_SPEED = 22
local OPEN_SPEED = 20
local MARKER_SPEED = 26
local LAMP_SPEED = 20
local MAX_RESULTS = 24
local NAME_LENGTH = 12

local Window = {}
Window.__index = Window

local function randomName(): string
	local out = table.create(NAME_LENGTH)
	for i = 1, NAME_LENGTH do
		out[i] = string.char(math.random(97, 122))
	end
	return table.concat(out)
end

local function encode(value: any): string
	return env.service("HttpService"):JSONEncode(value)
end

local function decode(text: string): any
	local ok, value = pcall(function()
		return env.service("HttpService"):JSONDecode(text)
	end)
	return if ok then value else nil
end

function Window._registerElement(self: any, el: any, page: any, public: boolean)
	if page == self._resultsPage then
		return
	end
	el._pageName = page.name
	el._page = page
	if public then
		if self.elements[el.id] then
			error("sottUI: element id used twice: " .. el.id, 3)
		end
		self.elements[el.id] = el
	end
	if el.kind ~= "divider" and el.kind ~= "label" and el.kind ~= "stat" then
		table.insert(self.ordered, el)
	end
	if el.kind == "toggle" and el.spec.primary then
		el:on(function()
			self:_drawLamps()
		end)
		self:_drawLamps()
	end
end

-- a page's light is on while any feature on it runs
function Window._drawLamps(self: any)
	if self._lampsQueued or self.destroyed then
		return
	end
	self._lampsQueued = true
	task.defer(function()
		self._lampsQueued = false
		if self.destroyed then
			return
		end
		local running = {}
		for _, el in self.ordered do
			if el.kind == "toggle" and el.spec.primary and el.value == true and not el.disabled then
				running[el._page] = true
			end
		end
		for page, tab in self._tabs do
			local on = running[page] == true
			if tab.on ~= on then
				tab.on = on
				tab.glow:to(if on then 0.3 else 1)
				self.ctx.tint(tab.dot, "BackgroundColor3", if on then "accent" else "lineStrong")
			end
		end
	end)
end

function Window._setPerson(self: any, options: any)
	self._person = options
end

function Window.minContentWidth(self: any): number
	return self._minWidth or 0
end

function Window._screenWidth(self: any): number
	return self._gui.AbsoluteSize.X / self._scale.Scale - 2 * EDGE
end

-- as wide as the page wants within what the screen has; the left edge stays put so the page names never move
function Window._contentChanged(self: any, content: number, live: boolean?)
	if self._showing == nil then
		return
	end
	local limit = math.min(MAX_WIDTH, self:_screenWidth())
	local width = math.clamp(content, math.min(self._minWidth or 0, limit), limit)
	self._width = width
	-- no saved spot: centred on the first page's real width, which is not known when the window first opens
	if self._autoCentre then
		self._autoCentre = false
		local screen = self._gui.AbsoluteSize
		local scale = self._scale.Scale
		self._at = Vector2.new((screen.X - width * scale) / 2, (screen.Y - HEIGHT * scale) / 2)
		self._position:snap(UDim2.fromOffset(self._at.X, self._at.Y))
	end
	self:_keepOnScreen(true)
	local size = UDim2.fromOffset(width, if self.isOpen then HEIGHT else 0)
	if live or self._rising or self._size:moving() then
		self._size:to(size)
	else
		self._size:snap(size)
	end
end

function Window._clamped(self: any, at: Vector2): Vector2
	local scale = self._scale.Scale
	local screen = self._gui.AbsoluteSize
	local width, height = (self._width or 0) * scale, HEIGHT * scale
	return Vector2.new(
		math.clamp(at.X, EDGE, math.max(screen.X - width - EDGE, EDGE)),
		math.clamp(at.Y, EDGE, math.max(screen.Y - height - EDGE, EDGE))
	)
end

-- a wider page or a smaller screen slides the window just far enough to keep it all in view
function Window._keepOnScreen(self: any, animate: boolean)
	local at = self._at
	if at == nil then
		return
	end
	local kept = self:_clamped(at)
	if kept ~= at then
		self._at = kept
		if animate then
			self._position:to(UDim2.fromOffset(kept.X, kept.Y))
		else
			self._position:snap(UDim2.fromOffset(kept.X, kept.Y))
		end
	end
end

function Window._show(self: any, page: any, instant: boolean?)
	if self._showing == page then
		return
	end
	self.ctx.hover.clear()
	self.ctx.popover:close()
	self.keys:cancel()
	local previous = self._showing
	if previous then
		previous:setActive(false)
	end
	self._showing = page
	if page ~= self._resultsPage then
		self._lastPage = page
	end
	self._rising = not instant
	page:setActive(true, instant)
	self._rising = false
	page:adopt()
	self:_syncMarker(instant)
	self:_saveState()
end

function Window._syncMarker(self: any, instant: boolean?)
	local tint = self.ctx.tint
	local active = nil
	for page, tab in self._tabs do
		local on = self._showing == page
		tint(tab.button, "TextColor3", if on then "text" else "muted")
		if on then
			active = tab.button
		end
	end
	if active == nil then
		self._markerSize:to(UDim2.fromOffset(0, MARKER))
		return
	end
	local scale = self._scale.Scale
	local x = (active.AbsolutePosition.X - self._top.AbsolutePosition.X) / scale
	local position = UDim2.new(0, x + TAB_PAD, 1, -MARKER)
	local size = UDim2.fromOffset(active.AbsoluteSize.X / scale - 2 * TAB_PAD, MARKER)
	if instant or self._markerSize.target == nil or self._markerSize.target.X.Offset == 0 then
		self._markerAt:snap(position)
		self._markerSize:snap(size)
	else
		self._markerAt:to(position)
		self._markerSize:to(size)
	end
end

local function addTab(self: any, page: any, name: string, order: number)
	local ctx = self.ctx
	local theme = ctx.theme
	local width = math.ceil(metrics.width("textMedium", name, TAB_TEXT)) + 2 * TAB_PAD + TAB_LED_ROOM
	local button = make("TextButton", {
		Name = name,
		Size = UDim2.new(0, width, 1, 0),
		TextSize = TAB_TEXT,
		Text = name,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = order,
		ZIndex = 3,
		Parent = self._row,
	})
	make("UIPadding", { PaddingLeft = UDim.new(0, TAB_PAD + TAB_LED_ROOM), Parent = button })
	theme:type(button, "text", true)
	theme:paint(button, "TextColor3", "muted")
	local halo = make("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, -TAB_LED_ROOM + TAB_LED / 2, 0.5, 0),
		Size = UDim2.fromOffset(24, 24),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ImageTransparency = 1,
		ZIndex = 2,
		Parent = button,
	})
	theme:paint(halo, "ImageColor3", "accent")
	ctx.art(halo, "glow.png")
	local dot = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, -TAB_LED_ROOM + TAB_LED / 2, 0.5, 0),
		Size = UDim2.fromOffset(TAB_LED, TAB_LED),
		BackgroundTransparency = 0,
		ZIndex = 3,
		Parent = button,
	})
	make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = dot })
	theme:paint(dot, "BackgroundColor3", "lineStrong")
	self._tabs[page] = {
		button = button,
		dot = dot,
		glow = self._maid:add(motion.prop(halo, "ImageTransparency", LAMP_SPEED)),
		on = false,
	}
	button.Activated:Connect(function()
		if self._box.Text ~= "" then
			self._box.Text = ""
		end
		self:_show(page)
	end)
	button.MouseEnter:Connect(function()
		if self._showing ~= page then
			ctx.tint(button, "TextColor3", "text")
		end
	end)
	button.MouseLeave:Connect(function()
		if self._showing ~= page then
			ctx.tint(button, "TextColor3", "muted")
		end
	end)
end

function Window.page(self: any, name: string): any
	local built = pageModule.new(self, name)
	table.insert(self.pages, built)
	addTab(self, built, name, 2 + #self.pages)
	built:mount(self._body)
	self:_drawLamps()
	-- nothing on show yet: the saved page if it is this one, else the first, once the host has added them all
	if not self._firstQueued then
		self._firstQueued = true
		task.defer(function()
			if self.destroyed or self._showing then
				return
			end
			local chosen = self.pages[1]
			for _, each in self.pages do
				if each.name == self._savedPage then
					chosen = each
				end
			end
			if chosen then
				self:_show(chosen, true)
			end
		end)
	end
	return built
end

function Window._query(self: any, text: string)
	if text == "" then
		if self._showing == self._resultsPage then
			self:_show(self._lastPage or self.pages[1])
		end
		self._resultsPage:showList({})
		return
	end
	-- something a script hid stays hidden
	local listed = {}
	for _, el in self.ordered do
		if el.visible ~= false then
			table.insert(listed, el)
		end
	end
	local hits = search.settings(text, listed, MAX_RESULTS)
	self._resultsPage:showList(hits, if #hits == 0 then "Nothing matches" else nil)
	self:_show(self._resultsPage)
end

function Window.showPage(self: any, name: string)
	for _, item in self.pages do
		if item.name == name then
			self._box.Text = ""
			self:_show(item)
			return
		end
	end
end

function Window.show(self: any, index: number, instant: boolean?)
	local page = self.pages[index]
	if page then
		self:_show(page, instant)
	end
end

function Window.reveal(self: any, el: any)
	local page = el._page
	if page then
		self:setOpen(true)
		self:showPage(page.name)
	end
end

function Window.setOpen(self: any, open: boolean)
	if self.isOpen == open or self.destroyed then
		return
	end
	self.isOpen = open
	if self._opener then
		self._opener.Visible = not open
	end
	self.ctx.hover.clear()
	self.ctx.popover:close()
	self.ctx.tooltip:hide()
	self.keys:cancel()
	if not open and self._dialogClose then
		self._dialogClose()
	end
	local width = self._width or self._minWidth or 0
	if open then
		self._root.Visible = true
		self._modal.Visible = true
		self:_guardCursor(true)
		if self._at == nil then
			local scale = self._scale.Scale
			local screen = self._gui.AbsoluteSize
			self._at = Vector2.new((screen.X - width * scale) / 2, (screen.Y - HEIGHT * scale) / 2)
		end
		self._position:snap(UDim2.fromOffset(self._at.X, self._at.Y))
		self._size:to(UDim2.fromOffset(width, HEIGHT))
		self._shadowFade:to(SHADOW_REST)
		-- no focus on open: the keyboard stays with the game until you ask for the menu's
	else
		self._modal.Visible = false
		self:_guardCursor(false)
		self._box:ReleaseFocus()
		-- a query left behind would show in the box with no results under it on the next open
		self._box.Text = ""
		self._shadowFade:to(1)
		self._size:to(UDim2.fromOffset(width, 0), function()
			if not self.isOpen then
				self._root.Visible = false
			end
		end)
	end
	self.visibilityChanged:fire(open)
end

function Window._guardCursor(self: any, on: boolean)
	local uis = env.service("UserInputService")
	if on then
		self._gameCursor = uis.MouseIconEnabled
		uis.MouseIconEnabled = true
		if self._cursorGuard == nil then
			self._cursorGuard = uis:GetPropertyChangedSignal("MouseIconEnabled"):Connect(function()
				if not uis.MouseIconEnabled then
					self._gameCursor = false
					uis.MouseIconEnabled = true
				end
			end)
		end
	else
		if self._cursorGuard then
			self._cursorGuard:Disconnect()
			self._cursorGuard = nil
		end
		if self._gameCursor ~= nil then
			uis.MouseIconEnabled = self._gameCursor
			self._gameCursor = nil
		end
	end
end

function Window.toggle(self: any)
	self:setOpen(not self.isOpen)
end

function Window.notify(self: any, options: any)
	if self.destroyed then
		return
	end
	self.ctx.notify(options)
end

function Window.setTheme(self: any, partial: { [string]: Color3 })
	self.ctx.theme:apply(partial)
end

function Window.setScale(self: any, scale: number)
	self._scale.Scale = math.clamp(scale, 0.7, 1.5)
	self:_keepOnScreen(false)
	self:_saveState()
end

function Window.setSubtitle(self: any, text: string)
	self._subtitleText = text
end

function Window._saveState(self: any)
	local store = self._files
	if store == nil or self._stateFile == nil or self._stateQueued then
		return
	end
	self._stateQueued = true
	task.delay(0.5, function()
		self._stateQueued = false
		if not self.destroyed then
			local at = self._at
			local page = self._lastPage
			store.write(
				self._stateFile,
				encode({ scale = self._scale.Scale, boxX = at and at.X, boxY = at and at.Y, page = page and page.name })
			)
		end
	end)
end

function Window.dialog(self: any, options: any, build: (section: any) -> ()): boolean
	if self.destroyed then
		return false
	end
	dialogModule.open(self, options, build)
	return true
end

function Window.find(self: any, id: string): any
	return self.elements[id]
end

function Window.snapshot(self: any): { [string]: any }
	local out = {}
	for id, el in self.elements do
		if el.saved then
			local value = el.value
			if el.kind == "color" then
				value = { hex = value.color:ToHex(), alpha = value.alpha }
			elseif el.kind == "key" then
				value =
					{ key = value.key, mode = value.mode, modifiers = value.modifiers, toggled = el.toggled == true }
			end
			out[id] = value
		end
	end
	return out
end

function Window.restore(self: any, values: { [string]: any })
	for id, value in values do
		local el = self.elements[id]
		if el and el.saved then
			if el.kind == "color" and type(value) == "table" then
				el:set({ color = Color3.fromHex(value.hex or "ffffff"), alpha = value.alpha })
			elseif el.kind == "key" and type(value) == "table" then
				el:set(value)
				el.toggled = value.toggled == true
			else
				el:set(value)
			end
		end
	end
end

function Window.destroy(self: any)
	if self.destroyed then
		return
	end
	self.destroyed = true
	self:_guardCursor(false)
	self.ctx.notifications:destroy()
	for _, item in self.pages do
		item:destroy()
	end
	self._resultsPage:destroy()
	self.ctx.input:destroy()
	self._maid:clean()
	self.visibilityChanged:clear()
	if self._registry and self._registry.current == self then
		self._registry.current = nil
	end
end

function window.new(options: { [string]: any }): any
	local registry = options._registry
	if registry and registry.current then
		-- running the script twice must replace the menu, never stack a second one fighting for the same keys
		registry.current:destroy()
	end

	local maid = maidModule.new()
	local theme = themeModule.new(options.theme)
	local router = inputModule.new()
	local uis = env.service("UserInputService")
	local touch = options.touch == true or (uis.TouchEnabled and not uis.MouseEnabled)

	local gui = make("ScreenGui", {
		Name = randomName(),
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = options.displayOrder or 10000,
	})
	env.protect(gui)
	gui.Parent = env.guiParent()
	maid:add(gui)

	local files = env.files()
	local folder = options.folder or "sottui_console"
	local stateFile = options.stateFile or (folder .. "/window.json")
	local saved: any = nil
	if files then
		files.folder(folder)
		local text = files.read(stateFile)
		saved = text and decode(text)
	end
	if type(saved) ~= "table" then
		saved = {}
	end

	local root = make("Frame", {
		Name = "Root",
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		Parent = gui,
	})
	local startScale = tonumber(saved.scale) or (if gui.AbsoluteSize.X < 800 then 0.8 else 1)
	local layer = make("Frame", { Name = "Layer", Size = UDim2.fromScale(1, 1), ZIndex = 100, Parent = gui })
	local modal = make("TextButton", {
		Name = "Modal",
		Size = UDim2.fromOffset(0, 0),
		Modal = true,
		Visible = false,
		Parent = root,
	})

	local assembly = make("Frame", {
		Name = "Assembly",
		Size = UDim2.fromOffset(0, 0),
		ZIndex = 3,
		Parent = root,
	})
	local scale = make("UIScale", { Scale = startScale, Parent = assembly })
	local shadow = make("ImageLabel", {
		Name = "Shadow",
		Position = UDim2.fromOffset(-SHADOW, -SHADOW),
		Size = UDim2.new(1, 2 * SHADOW, 1, 2 * SHADOW),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ImageColor3 = Color3.new(0, 0, 0),
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(48, 48, 80, 80),
		ZIndex = 1,
		Parent = assembly,
	})
	-- shuts by its height, so the panel clips what is inside; the panel's own size stays fixed underneath and nothing reflows
	local box = make("Frame", {
		Name = "Box",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 0,
		ClipsDescendants = true,
		Active = true,
		ZIndex = 2,
		Parent = assembly,
	})
	make("UICorner", { CornerRadius = UDim.new(0, RADIUS), Parent = box })
	theme:paint(box, "BackgroundColor3", "base")
	local edge = make("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = 1,
		Parent = box,
	})
	theme:paint(edge, "Color", "line")

	-- no fill of its own: a square bar would poke through the box's rounded corners
	local top = make("Frame", {
		Name = "Top",
		Size = UDim2.new(1, 0, 0, TOP),
		Active = true,
		ZIndex = 3,
		Parent = box,
	})
	local topRule = make("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundTransparency = 0,
		ZIndex = 3,
		Parent = top,
	})
	theme:paint(topRule, "BackgroundColor3", "line")
	local row = make("Frame", {
		Name = "Row",
		Size = UDim2.fromScale(1, 1),
		ZIndex = 3,
		Parent = top,
	})
	local rowLayout = make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = row,
	})
	local title = options.mark or "sottoro"
	local markWidth = math.ceil(metrics.width("mono", title, MARK_TEXT)) + 2 * MARK_PAD - 8
	local mark = make("TextLabel", {
		Name = "Mark",
		Size = UDim2.new(0, markWidth, 1, 0),
		TextSize = MARK_TEXT,
		Text = title,
		LayoutOrder = 1,
		ZIndex = 3,
		Parent = row,
	})
	make("UIPadding", { PaddingLeft = UDim.new(0, MARK_PAD), Parent = mark })
	theme:type(mark, "mono")
	theme:paint(mark, "TextColor3", "accent")

	local right = make("Frame", {
		Name = "Right",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -RIGHT_PAD, 0, 0),
		Size = UDim2.new(0, SEARCH + CLOSE + 6, 1, 0),
		ZIndex = 3,
		Parent = top,
	})
	local field = make("Frame", {
		Name = "Field",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(SEARCH, SEARCH_HEIGHT),
		BackgroundTransparency = 0,
		ZIndex = 3,
		Parent = right,
	})
	make("UICorner", { CornerRadius = UDim.new(0, 8), Parent = field })
	theme:paint(field, "BackgroundColor3", "raised")
	local fieldEdge = make("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = 1,
		Transparency = 1,
		Parent = field,
	})
	theme:paint(fieldEdge, "Color", "accent")
	local boxInput = make("TextBox", {
		Name = "Search",
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -24, 1, 0),
		TextSize = 14,
		Text = "",
		PlaceholderText = "Search",
		ClearTextOnFocus = false,
		ClipsDescendants = true,
		ZIndex = 4,
		Parent = field,
	})
	theme:type(boxInput, "text")
	theme:paint(boxInput, "TextColor3", "text")
	theme:paint(boxInput, "PlaceholderColor3", "muted")

	local marker = make("Frame", {
		Name = "Marker",
		Size = UDim2.fromOffset(0, MARKER),
		BackgroundTransparency = 0,
		ZIndex = 4,
		Parent = top,
	})
	make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = marker })
	theme:paint(marker, "BackgroundColor3", "accent")

	local body = make("Frame", {
		Name = "Body",
		Position = UDim2.fromOffset(0, TOP),
		-- fixed height: the lid clips this rather than squeezing it
		Size = UDim2.new(1, 0, 0, HEIGHT - TOP),
		ClipsDescendants = true,
		ZIndex = 2,
		Parent = box,
	})

	local self: any = setmetatable({
		ctx = nil,
		pages = {},
		elements = {},
		ordered = {},
		isOpen = false,
		destroyed = false,
		visibilityChanged = signal.new(),
		_maid = maid,
		_gui = gui,
		_root = root,
		_layer = layer,
		_modal = modal,
		_scale = scale,
		_box = boxInput,
		_body = body,
		_top = top,
		_row = row,
		_marker = marker,
		_tabs = {},
		_at = if tonumber(saved.boxX) and tonumber(saved.boxY) then Vector2.new(saved.boxX, saved.boxY) else nil,
		_autoCentre = not (tonumber(saved.boxX) and tonumber(saved.boxY)),
		_savedPage = saved.page,
		_subtitleText = options.subtitle,
		_files = files,
		_stateFile = stateFile,
		_dialogIds = 0,
		_registry = registry,
	}, Window)
	if registry then
		registry.current = self
	end

	-- art comes down with the fonts; anything asking before then is painted the moment it lands
	local art: { ready: { [string]: string }, waiting: { [string]: { any } } } = { ready = {}, waiting = {} }

	local ctx: any = {
		theme = theme,
		input = router,
		touch = touch,
		assets = {},
		glyph = glyphModule.new(theme),
		tint = tintModule.new(theme),
		art = function(instance: any, file: string)
			local ready = art.ready[file]
			if ready then
				instance.Image = ready
				return
			end
			art.waiting[file] = art.waiting[file] or {}
			table.insert(art.waiting[file], instance)
		end,
		uiScale = function(): number
			return scale.Scale
		end,
		popoverTop = function(): number
			return 8
		end,
		dialogAt = function(width: number): UDim2
			local viewport = layer.AbsoluteSize
			return UDim2.fromOffset(math.floor((viewport.X - width * scale.Scale) / 2), math.floor(viewport.Y * 0.2))
		end,
		isShowing = function(el: any): boolean
			if not self.isOpen then
				return false
			end
			-- a dialog's elements belong to no page and are always in view
			if el._page == nil and el._shownOn == nil then
				return true
			end
			return self._showing ~= nil and (el._shownOn == self._showing or el._page == self._showing)
		end,
		setScrollLocked = function(locked: boolean)
			local page = self._showing
			if page and page.frame and touch then
				page.frame.ScrollingEnabled = not locked
			end
		end,
	}
	self.ctx = ctx
	ctx.art(shadow, "shadow.png")
	local floating = overlay.popover(ctx, layer)
	ctx.popover = floating
	ctx.tooltip = overlay.tooltip(ctx, layer)
	ctx.hover = overlay.hover(ctx)
	ctx.notifications = notifyModule.new(ctx, layer)
	ctx.notify = function(notice: any)
		ctx.notifications:show(notice)
	end
	self.keys = keysModule.new(router, env, function(): boolean
		return self.isOpen
	end)
	ctx.keys = self.keys

	self._position = maid:add(motion.prop(assembly, "Position", OPEN_SPEED))
	self._size = maid:add(motion.prop(assembly, "Size", SIZE_SPEED))
	self._shadowFade = maid:add(motion.prop(shadow, "ImageTransparency", OPEN_SPEED))
	self._markerAt = maid:add(motion.prop(marker, "Position", MARKER_SPEED))
	self._markerSize = maid:add(motion.prop(marker, "Size", MARKER_SPEED))

	self._resultsPage = pageModule.new(self, "Results")
	self._resultsPage:mount(body)

	local close = make("TextButton", {
		Name = "Close",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(CLOSE, CLOSE),
		BackgroundTransparency = 1,
		ZIndex = 4,
		Parent = right,
	})
	make("UICorner", { CornerRadius = UDim.new(0, 8), Parent = close })
	theme:paint(close, "BackgroundColor3", "raised")
	local crossIcon = ctx.glyph.cross(close, "muted")
	crossIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	crossIcon.Position = UDim2.fromScale(0.5, 0.5)
	crossIcon.ZIndex = 5
	local closeFade = maid:add(motion.prop(close, "BackgroundTransparency", MARKER_SPEED))
	close.MouseEnter:Connect(function()
		closeFade:to(0)
		ctx.tooltip:schedule(close, "Close menu")
	end)
	close.MouseLeave:Connect(function()
		closeFade:to(1)
		ctx.tooltip:hide()
	end)
	close.Activated:Connect(function()
		self:setOpen(false)
	end)

	local focusFade = maid:add(motion.prop(fieldEdge, "Transparency", MARKER_SPEED))
	boxInput.Focused:Connect(function()
		focusFade:to(0.2)
	end)
	boxInput.FocusLost:Connect(function()
		focusFade:to(1)
	end)
	boxInput:GetPropertyChangedSignal("Text"):Connect(function()
		self:_query(boxInput.Text)
	end)

	-- the bar's empty space drags the window
	top.InputBegan:Connect(function(event: any)
		local kind = event.UserInputType
		if kind ~= Enum.UserInputType.MouseButton1 and kind ~= Enum.UserInputType.Touch then
			return
		end
		local from = if kind == Enum.UserInputType.Touch then router:at(event) else router:pointer()
		local origin = self._at
		if origin == nil then
			return
		end
		self._autoCentre = false
		router:capture(function(at: Vector2)
			self._at = self:_clamped(origin + (at - from))
			self._position:snap(UDim2.fromOffset(self._at.X, self._at.Y))
		end, function()
			self:_saveState()
		end, if kind == Enum.UserInputType.Touch then event else nil)
	end)

	-- the bar's contents are the narrowest a page may make the window
	local function fitBar()
		local needed = math.ceil(rowLayout.AbsoluteContentSize.X / scale.Scale)
			+ TOP_GAP
			+ SEARCH
			+ CLOSE
			+ 6
			+ RIGHT_PAD
		if needed == self._minWidth then
			return
		end
		self._minWidth = needed
		local page = self._showing
		if page then
			page:_invalidate()
		end
		task.defer(function()
			if not self.destroyed then
				self:_syncMarker(true)
			end
		end)
	end
	rowLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(fitBar)
	task.defer(fitBar)
	maid:add(gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_keepOnScreen(false)
		local page = self._showing
		if page then
			page._quiet = true
			page:_invalidate()
		end
	end))

	router.moved:connect(function(at: Vector2)
		ctx.hover:verify(at)
	end)
	router.wheel:connect(function(delta: number)
		if not self.isOpen or ctx.popover:isOpen() then
			return
		end
		local page = self._showing
		if page == nil or page.frame == nil then
			return
		end
		local at = router:pointer()
		local origin, extent = page.frame.AbsolutePosition, page.frame.AbsoluteSize
		if at.X >= origin.X and at.Y >= origin.Y and at.X <= origin.X + extent.X and at.Y <= origin.Y + extent.Y then
			page:wheel(delta)
		end
	end)
	router.keyDown:connect(function(event: any, processed: boolean)
		if event.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		local name = event.KeyCode.Name
		-- this press finished a rebind; it must not also close or clear anything
		if self.keys:swallowed(name) then
			return
		end
		if ctx.popover:key(name) then
			return
		end
		if name == "Escape" and self._dialogClose then
			self._dialogClose()
			return
		end
		if name == "Escape" and boxInput.Text ~= "" then
			boxInput.Text = ""
			return
		end
		if processed or router:typing() then
			return
		end
		if self.isOpen and name == "K" then
			if uis:IsKeyDown(Enum.KeyCode.LeftControl) or uis:IsKeyDown(Enum.KeyCode.RightControl) then
				boxInput:CaptureFocus()
			end
		end
	end)

	maid:add(theme.changed:connect(function()
		local all = table.clone(self.pages)
		table.insert(all, self._resultsPage)
		for _, page in all do
			for _, view in page._views do
				pcall(function()
					if view.retint then
						view:retint()
					end
					view.refresh()
				end)
			end
		end
	end))

	local hostSection = sectionModule.new({
		window = self,
		nextId = function()
			return 0
		end,
		_register = function(_: any, el: any, public: boolean)
			if public then
				self.elements[el.id] = el
			end
			el._pageName = ""
		end,
		_invalidate = function() end,
	}, "")
	self.menuKey = hostSection:key("__menu", {
		label = "Menu",
		default = options.key or "RightShift",
		mode = "Toggle",
		saved = false,
		onPress = function()
			self:toggle()
		end,
	})

	-- connected here rather than at require so a test can drive motion.step by hand
	local runService = env.service("RunService")
	motion.setAttach(function(step: (number) -> ()): any
		return runService.PreRender:Connect(step)
	end)

	if options.fonts ~= false and files then
		maid:add(task.defer(function()
			local tag = options.fontTag or VERSION
			local base = string.format(FONT_BASE, tag)
			-- by tag: a new release may change a file under the same name, and a cached copy would otherwise win forever
			local fontFolder = folder .. "/fonts-" .. tag
			local loaded = fonts.load(fontFolder, base, encode)
			if self.destroyed then
				return
			end
			if loaded.text or loaded.display or loaded.mono then
				theme:setFonts(loaded.text, loaded.display, loaded.mono)
			end
			for _, file in ART do
				local asset = fonts.image(fontFolder, base, file)
				if self.destroyed then
					return
				end
				if asset then
					art.ready[file] = asset
					local waiting: { any } = art.waiting[file] or {}
					for _, instance in waiting do
						instance.Image = asset
					end
				end
				art.waiting[file] = nil
			end
		end))
	end

	if touch then
		self._opener = openerModule(gui, theme, function()
			self:setOpen(true)
		end)
	end

	if options.autoShow ~= false then
		task.defer(function()
			self:setOpen(true)
		end)
	end

	return self
end

function window.setVersion(version: string)
	VERSION = version
end

return window
