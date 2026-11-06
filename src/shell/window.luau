--!strict
-- the window: no sidebar and no card. page names set in display type are the navigation, the rest is the tiles. the
-- frame opens by rolling its height behind a signal edge (ClipsDescendants plus one spring, no transparency on hundreds
-- of children and no CanvasGroup softening the text), and a page change is a single wipe crossing the body

local dialogModule = require("./dialog")
local env = require("../core/env")
local fonts = require("../core/fonts")
local glyphModule = require("../view/glyph")
local inputModule = require("../core/input")
local keysModule = require("./keys")
local maidModule = require("../core/maid")
local make = require("../core/make")
local motion = require("../core/motion")
local notifyModule = require("./notify")
local overlay = require("./overlay")
local pageModule = require("./page")
local paletteModule = require("./palette")
local sectionModule = require("./section")
local signal = require("../core/signal")
local themeModule = require("../core/theme")
local tintModule = require("../core/tint")

local window = {}

local VERSION = "main"
local FONT_BASE = "https://raw.githubusercontent.com/interestng/sottUI/%s/fonts/"

local BAR = 64
local NAV_SIZE = 34
local NAV_SIZE_NARROW = 24
local NARROW_NAV_AT = 760
local LOGO_SIZE = 26
local NAV_GAP = 22
local DEFAULT_SIZE = Vector2.new(900, 640)
local MIN_SIZE = Vector2.new(560, 400)
local SHUTTER_OPEN_SPEED = 20
local SHUTTER_CLOSE_SPEED = 30
-- one duration for the three things a page change moves, or they read as separate events
local PAGE_SPEED = 22
local SLIDE_DISTANCE = 26
-- the marker travels as two edges: the leading one runs ahead and the trailing one catches up, so the bar stretches
-- between words and settles back. the shutter and wipe edges share that mint, this is what makes them one gesture
local EDGE_LEAD = 34
local EDGE_TRAIL = 17
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
end

-- the marker measures the word it sits under, so it survives the font swap and long page names
function Window._syncMarker(self: any, instant: boolean?)
	local item = self._navItems[self.current]
	if item == nil then
		return
	end
	local scale = self._scale.Scale
	local list = self._navList
	local left = (item.AbsolutePosition.X - list.AbsolutePosition.X) / scale
	local right = left + item.AbsoluteSize.X / scale
	-- pages past the right edge scroll into view, by only as much as it takes to show the active word whole
	local visible = self._navClip.AbsoluteSize.X / scale
	local offset = self._navScroll.target
	if right + offset > visible then
		offset = visible - right
	end
	if left + offset < 0 then
		offset = -left
	end
	offset = math.min(offset, 0)
	if instant then
		self._edgeLeft:snap(left)
		self._edgeRight:snap(right)
		self._navScroll:snap(offset)
		return
	end
	local forward = right > self._edgeRight.target
	self._edgeLeft.speed = if forward then EDGE_TRAIL else EDGE_LEAD
	self._edgeRight.speed = if forward then EDGE_LEAD else EDGE_TRAIL
	self._edgeLeft:to(left)
	self._edgeRight:to(right)
	self._navScroll:to(offset)
end

function Window.page(self: any, name: string): any
	local built = pageModule.new(self, name)
	table.insert(self.pages, built)
	local index = #self.pages
	local theme = self.ctx.theme
	local item = make("TextButton", {
		Name = name,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 1, 0),
		TextSize = NAV_SIZE,
		Text = name,
		LayoutOrder = index,
		Parent = self._navList,
	})
	theme:type(item, "display")
	theme:paint(item, "TextColor3", "faint")
	self._navItems[index] = item
	item.Activated:Connect(function()
		self:show(index)
	end)
	item.MouseEnter:Connect(function()
		if self.current ~= index then
			self.ctx.tint(item, "TextColor3", "muted")
		end
	end)
	item.MouseLeave:Connect(function()
		if self.current ~= index then
			self.ctx.tint(item, "TextColor3", "faint")
		end
	end)
	built:mount(self._pageHost)
	if self.current == nil then
		self:show(index, true)
	end
	return built
end

function Window.show(self: any, index: number, instant: boolean?)
	local target = self.pages[index]
	if target == nil or self.current == index then
		return
	end
	self.ctx.hover.clear()
	self.ctx.popover:close()
	self.keys:cancel()
	local tint = self.ctx.tint
	local previous = self.pages[self.current]
	if previous then
		previous:setActive(false)
		tint(self._navItems[self.current], "TextColor3", "faint")
	end
	local forward = self.current == nil or index > self.current
	self.current = index
	tint(self._navItems[index], "TextColor3", "text")
	target:setActive(true)
	self:_syncMarker(instant)
	self:_saveState()
	if instant then
		return
	end
	-- one opaque block crossing the body stands in for fading hundreds of tiles, and it is the transition's character
	local direction = if forward then 1 else -1
	self._pageSlide:snap(UDim2.fromOffset(SLIDE_DISTANCE * direction, 0))
	self._pageSlide:to(UDim2.new())
	self._wipe.Visible = true
	self._wipeEdge.AnchorPoint = Vector2.new(if forward then 1 else 0, 0)
	self._wipeEdge.Position = UDim2.fromScale(if forward then 1 else 0, 0)
	self._wipeAt:snap(UDim2.fromScale(0, 0))
	self._wipeAt:to(UDim2.fromScale(-1.02 * direction, 0), function()
		self._wipe.Visible = false
	end)
end

function Window.showPage(self: any, name: string)
	for index, item in self.pages do
		if item.name == name then
			self:show(index)
			return
		end
	end
end

function Window.reveal(self: any, el: any)
	local page = el._page
	if page == nil then
		return
	end
	if not self.isOpen then
		self:setOpen(true)
	end
	self:showPage(page.name)
	local host = el.host or el
	-- a setting folded under an off master has no place on the page until it is opened
	local owner = el.section and (el.section._root or el.section)
	if owner and owner.masterElement and owner.masterElement.value ~= true and host ~= owner.masterElement then
		owner.peeking = true
		local masterView = page:viewOf(owner.masterElement)
		if masterView then
			masterView.refresh()
		end
	end
	page:layout()
	local y = page:rowY(host)
	if y then
		page:scrollTo(y - 60)
		-- after the scroll lands, or the wave plays where the eye has not arrived yet
		task.delay(0.26, function()
			local view = page:viewOf(host)
			if view and view.root.Parent then
				view:flash()
			end
		end)
	end
end

function Window._targetSize(self: any): UDim2
	return if self.collapsed then UDim2.new(1, 0, 0, BAR) else UDim2.fromScale(1, 1)
end

function Window.setOpen(self: any, open: boolean)
	if self.isOpen == open or self.destroyed then
		return
	end
	self.isOpen = open
	self.ctx.hover.clear()
	self.ctx.popover:close()
	self._palette.close()
	self.ctx.tooltip:hide()
	self.keys:cancel()
	if not open and self._dialogClose then
		self._dialogClose()
	end
	self._shutterEdge.Visible = true
	if open then
		self._root.Visible = true
		self._modal.Visible = true
		self:_guardCursor(true)
		self._shutter.speed = SHUTTER_OPEN_SPEED
		self._shutter:to(self:_targetSize(), function()
			self._shutterEdge.Visible = false
		end)
	else
		self._modal.Visible = false
		self:_guardCursor(false)
		self._shutter.speed = SHUTTER_CLOSE_SPEED
		self._shutter:to(UDim2.new(1, 0, 0, 0), function()
			self._shutterEdge.Visible = false
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

function Window.collapse(self: any, collapsed: boolean)
	self.collapsed = collapsed
	self._shutter:to(self:_targetSize())
	self._grip.Visible = not collapsed
	self:_saveState()
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
	self:_clamp()
	self:_saveState()
end

function Window.setSubtitle(self: any, text: string)
	self._subtitleLabel.Text = text
end

function Window._clamp(self: any)
	local viewport = self._gui.AbsoluteSize
	local size = self.size * self._scale.Scale
	-- the header must stay grabbable; the rest may hang off the edge if the user wants it there
	local x = math.clamp(self.position.X, 0, math.max(viewport.X - size.X, 0))
	local y = math.clamp(self.position.Y, 0, math.max(viewport.Y - size.Y, 0))
	self.position = Vector2.new(x, y)
	self._root.Position = UDim2.fromOffset(x, y)
end

function Window._saveState(self: any)
	local store = self._files
	if store == nil or self._stateFile == nil or self._stateQueued then
		return
	end
	self._stateQueued = true
	-- a drag fires this per frame; only the last position matters
	task.delay(0.5, function()
		self._stateQueued = false
		if self.destroyed then
			return
		end
		local currentPage = self.pages[self.current]
		store.write(
			self._stateFile,
			encode({
				x = self.position.X,
				y = self.position.Y,
				w = self.size.X,
				h = self.size.Y,
				page = currentPage and currentPage.name,
				scale = self._scale.Scale,
				collapsed = self.collapsed,
			})
		)
	end)
end

function Window.restorePage(self: any)
	local saved = self._savedPage
	if saved then
		self._savedPage = nil
		for index, item in self.pages do
			if item.name == saved then
				self:show(index, true)
				return
			end
		end
	end
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

-- plain values for every saved element, page or no page. the caller picks the file and format
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
	self.ctx.input:destroy()
	self._maid:clean()
	self.visibilityChanged:clear()
	if self._registry and self._registry.current == self then
		self._registry.current = nil
	end
end

local function headerButton(ctx: any, parent: any, x: number, draw: (holder: any, token: string) -> any): any
	local button = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, x, 0.5, 0),
		Size = UDim2.fromOffset(44, BAR),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	ctx.theme:paint(button, "BackgroundColor3", "raised")
	local icon = draw(button, "muted")
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.Position = UDim2.fromScale(0.5, 0.5)
	local wash = motion.prop(button, "BackgroundTransparency", 28)
	button.MouseEnter:Connect(function()
		wash:to(0)
	end)
	button.MouseLeave:Connect(function()
		wash:to(1)
	end)
	return button
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
	local touch = uis.TouchEnabled and not uis.MouseEnabled

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
	local folder = options.folder or "sottui"
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

	local viewport = gui.AbsoluteSize
	local size = Vector2.new(
		math.clamp(tonumber(saved.w) or DEFAULT_SIZE.X, MIN_SIZE.X, math.max(viewport.X, MIN_SIZE.X)),
		math.clamp(tonumber(saved.h) or DEFAULT_SIZE.Y, MIN_SIZE.Y, math.max(viewport.Y, MIN_SIZE.Y))
	)
	local startScale = tonumber(saved.scale) or (if viewport.X < 800 then 0.8 else 1)
	local position = Vector2.new(
		tonumber(saved.x) or math.floor((viewport.X - size.X * startScale) / 2),
		tonumber(saved.y) or math.floor((viewport.Y - size.Y * startScale) / 2)
	)

	local root = make("Frame", {
		Name = "Root",
		Size = UDim2.fromOffset(size.X, size.Y),
		Position = UDim2.fromOffset(position.X, position.Y),
		Parent = gui,
	})
	local scale = make("UIScale", { Scale = startScale, Parent = root })
	local clip = make("Frame", {
		Name = "Clip",
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 0,
		ClipsDescendants = true,
		Active = true,
		Parent = root,
	})
	theme:paint(clip, "BackgroundColor3", "base")

	local layer = make("Frame", { Name = "Layer", Size = UDim2.fromScale(1, 1), ZIndex = 100, Parent = gui })
	-- releases the mouse in games that lock it; visible only while the menu is open
	local modal = make("TextButton", {
		Name = "Modal",
		Size = UDim2.fromOffset(0, 0),
		Modal = true,
		Visible = false,
		Parent = root,
	})

	local bar = make("TextButton", { Name = "Bar", Size = UDim2.new(1, 0, 0, BAR), Parent = clip })
	local title = make("TextLabel", {
		AutomaticSize = Enum.AutomaticSize.X,
		Position = UDim2.fromOffset(20, 0),
		Size = UDim2.fromOffset(0, BAR),
		TextSize = LOGO_SIZE,
		Text = options.title or "sottoro",
		Parent = bar,
	})
	theme:type(title, "display")
	theme:paint(title, "TextColor3", "accent")

	local navClip = make("Frame", {
		Name = "NavClip",
		Size = UDim2.new(1, 0, 0, BAR),
		ClipsDescendants = true,
		Parent = clip,
	})
	local navRail = make("Frame", { Name = "NavRail", Size = UDim2.fromScale(1, 1), Parent = navClip })
	local navList = make("Frame", {
		Name = "NavList",
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 1, 0),
		Parent = navRail,
	})
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, NAV_GAP),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = navList,
	})
	-- the sign that there are more pages than fit
	local navFade = make("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 36, 1, 0),
		BackgroundTransparency = 0,
		Visible = false,
		ZIndex = 3,
		Parent = navClip,
	})
	theme:paint(navFade, "BackgroundColor3", "base")
	make("UIGradient", { Transparency = NumberSequence.new(1, 0), Parent = navFade })
	local marker = make("Frame", {
		Name = "Marker",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(0, 0, 0, 4),
		BackgroundTransparency = 0,
		ZIndex = 2,
		Parent = navRail,
	})
	theme:paint(marker, "BackgroundColor3", "accent")

	local rule = make("Frame", {
		Position = UDim2.new(0, 0, 0, BAR - 1),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundTransparency = 0,
		Parent = clip,
	})
	theme:paint(rule, "BackgroundColor3", "line")

	local body = make("Frame", {
		Name = "Body",
		Position = UDim2.fromOffset(0, BAR),
		Size = UDim2.new(1, 0, 1, -BAR),
		ClipsDescendants = true,
		Parent = clip,
	})
	local pageHost = make("Frame", { Name = "Pages", Size = UDim2.fromScale(1, 1), Parent = body })
	local wipe = make("Frame", {
		Name = "Wipe",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 0,
		Visible = false,
		ZIndex = 8,
		Parent = body,
	})
	theme:paint(wipe, "BackgroundColor3", "base")
	local wipeEdge = make("Frame", {
		Size = UDim2.new(0, 8, 1, 0),
		BackgroundTransparency = 0,
		ZIndex = 9,
		Parent = wipe,
	})
	theme:paint(wipeEdge, "BackgroundColor3", "accent")

	local shutterEdge = make("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, 4),
		BackgroundTransparency = 0,
		Visible = false,
		ZIndex = 12,
		Parent = clip,
	})
	theme:paint(shutterEdge, "BackgroundColor3", "accent")

	local grip = make("TextButton", {
		Name = "Grip",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.fromScale(1, 1),
		Size = UDim2.fromOffset(20, 20),
		ZIndex = 6,
		Parent = clip,
	})
	for index, spec in
		{ { UDim2.new(1, -3, 1, -3), UDim2.fromOffset(10, 2) }, { UDim2.new(1, -3, 1, -3), UDim2.fromOffset(2, 10) } }
	do
		local tick = make("Frame", {
			AnchorPoint = Vector2.new(1, 1),
			Position = spec[1],
			Size = spec[2],
			BackgroundTransparency = 0,
			ZIndex = 7,
			Name = "Tick" .. index,
			Parent = grip,
		})
		theme:paint(tick, "BackgroundColor3", "lineStrong")
	end

	local self: any = setmetatable({
		ctx = nil,
		pages = {},
		elements = {},
		ordered = {},
		current = nil,
		isOpen = false,
		collapsed = saved.collapsed == true,
		destroyed = false,
		size = size,
		position = position,
		visibilityChanged = signal.new(),
		_maid = maid,
		_gui = gui,
		_root = root,
		_clip = clip,
		_layer = layer,
		_modal = modal,
		_scale = scale,
		_navClip = navClip,
		_navList = navList,
		_navItems = {},
		_pageHost = pageHost,
		_wipe = wipe,
		_wipeEdge = wipeEdge,
		_shutterEdge = shutterEdge,
		_grip = grip,
		_files = files,
		_stateFile = stateFile,
		_savedPage = saved.page,
		_dialogIds = 0,
		_registry = registry,
	}, Window)
	if registry then
		registry.current = self
	end

	local ctx: any = {
		theme = theme,
		input = router,
		touch = touch,
		glyph = glyphModule.new(theme),
		tint = tintModule.new(theme),
		uiScale = function(): number
			return scale.Scale
		end,
		popoverTop = function(): number
			return self.position.Y + BAR * scale.Scale
		end,
		isShowing = function(el: any): boolean
			if not self.isOpen then
				return false
			end
			local page = el._page or (el.host and el.host._page)
			-- no page means a dialog, which is only ever built open
			return page == nil or page == self.pages[self.current]
		end,
		setScrollLocked = function(locked: boolean)
			local page = self.pages[self.current]
			if page and page.frame and touch then
				page.frame.ScrollingEnabled = not locked
			end
		end,
	}
	self.ctx = ctx
	ctx.popover = overlay.popover(ctx, layer)
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

	local function drawMarker()
		local left, right = self._markerLeft, self._markerRight
		marker.Position = UDim2.new(0, left, 1, 0)
		marker.Size = UDim2.new(0, math.max(right - left, 0), 0, 4)
	end
	self._markerLeft, self._markerRight = 0, 0
	self._edgeLeft = maid:add(motion.new(0, EDGE_LEAD, function(x: number)
		self._markerLeft = x
		drawMarker()
	end))
	self._edgeRight = maid:add(motion.new(0, EDGE_LEAD, function(x: number)
		self._markerRight = x
		drawMarker()
	end))
	self._navScroll = maid:add(motion.new(0, EDGE_LEAD, function(x: number)
		navRail.Position = UDim2.fromOffset(x, 0)
	end))
	self._pageSlide = maid:add(motion.prop(pageHost, "Position", PAGE_SPEED))
	self._wipeAt = maid:add(motion.prop(wipe, "Position", PAGE_SPEED))
	self._shutter = maid:add(motion.prop(clip, "Size", SHUTTER_OPEN_SPEED))

	self._palette = paletteModule.new(ctx, layer, function(): { any }
		return self.ordered
	end, function(el: any)
		self:reveal(el)
	end)

	local closeButton = headerButton(ctx, bar, 0, function(holder: any, token: string)
		return ctx.glyph.cross(holder, token)
	end)
	closeButton.Activated:Connect(function()
		self:setOpen(false)
	end)
	local collapseButton = headerButton(ctx, bar, -44, function(holder: any, token: string)
		return ctx.glyph.dash(holder, token)
	end)
	collapseButton.Activated:Connect(function()
		self:collapse(not self.collapsed)
	end)
	local find = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -96, 0.5, 0),
		Size = UDim2.fromOffset(64, BAR),
		TextSize = 17,
		Text = "Search",
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = bar,
	})
	theme:type(find, "text", true)
	theme:paint(find, "TextColor3", "muted")
	find.MouseEnter:Connect(function()
		ctx.tint(find, "TextColor3", "text")
	end)
	find.MouseLeave:Connect(function()
		ctx.tint(find, "TextColor3", "muted")
	end)
	find.Activated:Connect(function()
		self._palette:toggle()
	end)
	local subtitle = make("TextLabel", {
		AutomaticSize = Enum.AutomaticSize.X,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -176, 0.5, 0),
		Size = UDim2.fromOffset(0, BAR),
		TextSize = 17,
		Text = options.subtitle or "",
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = bar,
	})
	theme:type(subtitle, "text")
	theme:paint(subtitle, "TextColor3", "faint")
	self._subtitleLabel = subtitle

	-- the words get what the logo and controls leave. the game name yields first, it is on the Home page anyway
	local function fitBar()
		local current = scale.Scale
		local width = root.AbsoluteSize.X / current
		local left = 20 + title.AbsoluteSize.X / current + 24
		local words = navList.AbsoluteSize.X / current
		local named = 176 + subtitle.AbsoluteSize.X / current + 20
		subtitle.Visible = options.subtitle ~= nil and left + words + named <= width
		local right = if subtitle.Visible then named else 176
		navClip.Position = UDim2.fromOffset(left, 0)
		navClip.Size = UDim2.new(1, -(left + right), 0, BAR)
		-- a narrow window shrinks the words before it starts hiding them
		local size = if width < NARROW_NAV_AT then NAV_SIZE_NARROW else NAV_SIZE
		for _, item in self._navItems do
			item.TextSize = size
		end
		navFade.Visible = navList.AbsoluteSize.X / current > width - left - right
		self:_syncMarker(true)
	end
	self._fitBar = fitBar
	title:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitBar)
	subtitle:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitBar)
	root:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitBar)
	navList:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitBar)
	task.defer(fitBar)

	bar.InputBegan:Connect(function(event: any)
		local kind = event.UserInputType
		if kind ~= Enum.UserInputType.MouseButton1 and kind ~= Enum.UserInputType.Touch then
			return
		end
		local from = if kind == Enum.UserInputType.Touch then router:at(event) else router:pointer()
		local origin = self.position
		router:capture(function(at: Vector2)
			self.position = origin + (at - from)
			self:_clamp()
			self:_saveState()
		end)
	end)

	grip.InputBegan:Connect(function(event: any)
		local kind = event.UserInputType
		if kind ~= Enum.UserInputType.MouseButton1 and kind ~= Enum.UserInputType.Touch then
			return
		end
		local from = if kind == Enum.UserInputType.Touch then router:at(event) else router:pointer()
		local origin = self.size
		router:capture(function(at: Vector2)
			local current = scale.Scale
			local grown = origin + (at - from) / current
			local limit = (gui.AbsoluteSize - self.position) / current
			self.size = Vector2.new(
				math.clamp(grown.X, MIN_SIZE.X, math.max(limit.X, MIN_SIZE.X)),
				math.clamp(grown.Y, MIN_SIZE.Y, math.max(limit.Y, MIN_SIZE.Y))
			)
			root.Size = UDim2.fromOffset(math.floor(self.size.X), math.floor(self.size.Y))
			self:_saveState()
		end)
	end)

	router.moved:connect(function(at: Vector2)
		ctx.hover:verify(at)
	end)
	router.wheel:connect(function(delta: number)
		if not self.isOpen or ctx.popover:isOpen() or self._palette:isOpen() then
			return
		end
		local page = self.pages[self.current]
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
		if self._palette:key(name) or ctx.popover:key(name) then
			return
		end
		if name == "Escape" and self._dialogClose then
			self._dialogClose()
			return
		end
		if processed or router:typing() then
			return
		end
		if self.isOpen and name == "K" then
			if uis:IsKeyDown(Enum.KeyCode.LeftControl) or uis:IsKeyDown(Enum.KeyCode.RightControl) then
				self._palette:toggle()
			end
		end
	end)

	maid:add(gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_clamp()
	end))
	maid:add(theme.changed:connect(function()
		for _, page in self.pages do
			for _, view in page._views do
				pcall(function()
					view:retint()
					view.refresh()
				end)
			end
		end
	end))

	-- a phone has no menu key: closing must leave something to tap
	if touch then
		local chip = make("TextButton", {
			Name = "Reopen",
			Position = UDim2.fromOffset(16, 80),
			Size = UDim2.fromOffset(112, 44),
			BackgroundTransparency = 0,
			TextSize = 22,
			Text = options.title or "sottoro",
			Visible = false,
			Parent = gui,
		})
		theme:type(chip, "display")
		theme:paint(chip, "BackgroundColor3", "accent")
		theme:paint(chip, "TextColor3", "onAccent")
		local moved = false
		chip.InputBegan:Connect(function(event: any)
			if event.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			moved = false
			local from = router:at(event)
			local origin = chip.AbsolutePosition - gui.AbsolutePosition
			router:capture(function(at: Vector2)
				local delta = at - from
				if delta.Magnitude > 8 then
					moved = true
					chip.Position = UDim2.fromOffset(origin.X + delta.X, origin.Y + delta.Y)
				end
			end)
		end)
		chip.Activated:Connect(function()
			if not moved then
				self:setOpen(true)
			end
		end)
		self.visibilityChanged:connect(function(open: boolean)
			chip.Visible = not open
		end)
	end

	-- the menu toggle lives in the same registry as every other bind
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

	self:_clamp()

	if options.fonts ~= false and files then
		maid:add(task.defer(function()
			local tag = options.fontTag or VERSION
			-- by tag: a new release may change a file under the same name, and a cached copy would otherwise win forever
			local loaded = fonts.load(folder .. "/fonts-" .. tag, string.format(FONT_BASE, tag), encode)
			if not self.destroyed and (loaded.text or loaded.display) then
				theme:setFonts(loaded.text, loaded.display)
			end
		end))
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
