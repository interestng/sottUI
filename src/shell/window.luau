--!strict
-- no floating window. the menu is a full height panel flush to the screen's edge, so the game stays visible beside it and
-- nothing covers the middle of the screen. navigation is the spine: words turned on their side, the person at its foot

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
local paletteModule = require("./palette")
local sectionModule = require("./section")
local openerModule = require("./opener")
local signal = require("../core/signal")
local themeModule = require("../core/theme")
local tintModule = require("../core/tint")

local window = {}

local VERSION = "main"
local FONT_BASE = "https://raw.githubusercontent.com/interestng/sottUI/%s/fonts/"

local SPINE = 62
local HEAD = 46
local HEAD_HOME = 92
local COLUMN_SPEED = 28
local COLUMN_FOOT = 8
local RAIL = 3
local TICK = 12
local TICK_GAP = 4
local MAX_TICKS = 30
local WORD = 18
local WORD_PAD = 30
local TITLE = 30
local DEFAULT_WIDTH = 420
local MIN_WIDTH = 340
local MAX_WIDTH = 640
local SLIDE_OPEN_SPEED = 22
local SLIDE_CLOSE_SPEED = 32
local PAGE_SPEED = 22
local PAGE_SLIDE = 22
local EDGE_LEAD = 34
local EDGE_TRAIL = 17
local NAME_LENGTH = 12
local HANDLE_WIDTH = 5
local HANDLE_HEIGHT = 72

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
	if el.kind == "toggle" then
		el:on(function()
			self:_markRail()
		end)
		self:_markRail()
	end
end

-- with the panel away the rail stays: a tick for each thing that is on. what is running can be read at a glance, without
-- opening anything, and it is what to reach for to bring the panel back
function Window._markRail(self: any)
	if self._railQueued then
		return
	end
	self._railQueued = true
	task.defer(function()
		self._railQueued = false
		if self.destroyed then
			return
		end
		local on = 0
		for _, el in self.ordered do
			if el.kind == "toggle" and el.value == true then
				on += 1
			end
		end
		on = math.min(on, MAX_TICKS)
		local ticks = self._railTicks
		for i = 1, math.max(on, #ticks) do
			local tick = ticks[i]
			if tick == nil then
				tick = make("Frame", {
					Size = UDim2.fromOffset(HANDLE_WIDTH, TICK),
					BackgroundTransparency = 0,
					Parent = self._handleBar,
				})
				self.ctx.theme:paint(tick, "BackgroundColor3", "accent")
				ticks[i] = tick
			end
			tick.Visible = i <= on
			tick.Position = UDim2.fromOffset(0, (i - 1) * (TICK + TICK_GAP))
		end
		local height = math.max(on * (TICK + TICK_GAP) - TICK_GAP, TICK)
		self._handleBar.Size = UDim2.fromOffset(HANDLE_WIDTH, height)
		self._handleBar.BackgroundTransparency = if on == 0 then 0 else 1
		self._handle.Size = UDim2.fromOffset(self._handle.Size.X.Offset, height + 24)
	end)
end

-- the panel is only as long as what it holds: the game shows below a short page, and the spine alone runs full height
function Window._contentChanged(self: any, content: number, live: boolean?)
	local head = self._headHeight or HEAD
	local available = self._gui.AbsoluteSize.Y / self._scale.Scale
	local height = math.min(head + content + COLUMN_FOOT, available)
	local size = UDim2.new(1, -SPINE, 0, height)
	if live then
		self._columnSize:to(size)
	else
		self._columnSize:snap(size)
	end
end

function Window._syncMarker(self: any, instant: boolean?)
	local item = self._navItems[self.current]
	if item == nil then
		return
	end
	local top = item.Position.Y.Offset
	local bottom = top + item.Size.Y.Offset
	if instant then
		self._edgeTop:snap(top)
		self._edgeBottom:snap(bottom)
		return
	end
	local down = bottom > self._edgeBottom.target
	self._edgeTop.speed = if down then EDGE_TRAIL else EDGE_LEAD
	self._edgeBottom.speed = if down then EDGE_LEAD else EDGE_TRAIL
	self._edgeTop:to(top)
	self._edgeBottom:to(bottom)
end

-- this design's person lives in the spine; what a hero says becomes the page's own heading
function Window._setPerson(self: any, options: any)
	self._person = options
	self:_syncHead()
end

function Window._syncHead(self: any)
	local page = self.pages[self.current]
	if page == nil then
		return
	end
	local person = self._person
	local home = page.name == "Home" and person ~= nil
	self._headTitle.Visible = home
	if home then
		self._headTitle.Text = person.title
		self._headLine.RichText = true
		self._headLine.Text = person.text or ""
		self._headLine.Position = UDim2.fromOffset(18, HEAD_HOME - 34)
	else
		self._headLine.RichText = false
		self._headLine.Text = self._subtitleText or ""
		self._headLine.Position = UDim2.fromOffset(18, 12)
	end
	local height = if home then HEAD_HOME else HEAD
	self._headHeight = height
	self._head.Size = UDim2.new(1, 0, 0, height)
	self._headRule.Position = UDim2.fromOffset(0, height - 1)
	self._body.Position = UDim2.fromOffset(0, height)
	self._body.Size = UDim2.new(1, 0, 1, -height)
end

function Window.page(self: any, name: string): any
	local built = pageModule.new(self, name)
	table.insert(self.pages, built)
	local index = #self.pages
	local theme = self.ctx.theme
	local length = math.ceil(metrics.width("display", name, WORD)) + WORD_PAD
	local item = make("TextButton", {
		Name = name,
		Position = UDim2.fromOffset(0, self._navUsed),
		Size = UDim2.fromOffset(SPINE, length),
		Parent = self._navList,
	})
	self._navUsed += length
	self._navList.CanvasSize = UDim2.fromOffset(0, self._navUsed)
	-- the button stays upright and only the text turns: hit testing on a rotated object uses its unrotated box
	local word = make("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(length, SPINE),
		Rotation = -90,
		TextSize = WORD,
		Text = name,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = item,
	})
	theme:type(word, "display")
	theme:paint(word, "TextColor3", "faint")
	self._navItems[index] = item
	self._navWords[index] = word
	item.Activated:Connect(function()
		self:show(index)
	end)
	item.MouseEnter:Connect(function()
		if self.current ~= index then
			self.ctx.tint(word, "TextColor3", "muted")
		end
	end)
	item.MouseLeave:Connect(function()
		if self.current ~= index then
			self.ctx.tint(word, "TextColor3", "faint")
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
		tint(self._navWords[self.current], "TextColor3", "faint")
	end
	local forward = self.current == nil or index > self.current
	self.current = index
	tint(self._navWords[index], "TextColor3", "text")
	target:setActive(true)
	self:_syncHead()
	self:_syncMarker(instant)
	self:_saveState()
	target:layout()
	if instant then
		return
	end
	-- the column travels the way the spine does, one blind crossing the body stands in for fading hundreds of rows
	local direction = if forward then 1 else -1
	self._pageSlide:snap(UDim2.fromOffset(0, PAGE_SLIDE * direction))
	self._pageSlide:to(UDim2.new())
	self._wipe.Visible = true
	self._wipeEdge.AnchorPoint = Vector2.new(0, if forward then 1 else 0)
	self._wipeEdge.Position = UDim2.fromScale(0, if forward then 1 else 0)
	self._wipeAt:snap(UDim2.fromScale(0, 0))
	self._wipeAt:to(UDim2.fromScale(0, -1.02 * direction), function()
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
	self.ctx.popover:close()
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
		task.delay(0.26, function()
			local view = page:viewOf(host)
			if view and view.root.Parent then
				view:flash()
			end
		end)
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
	self._palette.close()
	self.ctx.tooltip:hide()
	self.keys:cancel()
	if not open and self._dialogClose then
		self._dialogClose()
	end
	local width = self:_panelWidth()
	if open then
		self._root.Visible = true
		self._modal.Visible = true
		self._handle.Visible = false
		self:_guardCursor(true)
		self._slide.speed = SLIDE_OPEN_SPEED
		self._slide:to(UDim2.fromOffset(0, self._rootY))
	else
		self._modal.Visible = false
		self:_guardCursor(false)
		self._slide.speed = SLIDE_CLOSE_SPEED
		self._slide:to(UDim2.fromOffset(-width, self._rootY), function()
			if not self.isOpen then
				self._root.Visible = false
				self._handle.Visible = true
			end
		end)
	end
	self.visibilityChanged:fire(open)
end

function Window._panelWidth(self: any): number
	return (SPINE + self.width) * self._scale.Scale + 2
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
	self:_fit()
	if not self.isOpen then
		self._slide:snap(UDim2.fromOffset(-self:_panelWidth(), self._rootY))
	end
	-- canvas position is in scaled pixels; the springs hold the page's own units, written back at the new scale
	local page = self.pages[self.current]
	if page and page._scrollTarget then
		page:scrollTo(page._scrollTarget, true)
	end
	self:_saveState()
end

function Window.setSubtitle(self: any, text: string)
	self._subtitleText = text
	self:_syncHead()
end

function Window._fit(self: any)
	local height = self._gui.AbsoluteSize.Y / self._scale.Scale
	self._root.Size = UDim2.fromOffset(SPINE + self.width, height)
end

function Window._saveState(self: any)
	local store = self._files
	if store == nil or self._stateFile == nil or self._stateQueued then
		return
	end
	self._stateQueued = true
	-- a drag fires this per frame; only the last value matters
	task.delay(0.5, function()
		self._stateQueued = false
		if self.destroyed then
			return
		end
		local currentPage = self.pages[self.current]
		store.write(
			self._stateFile,
			encode({
				w = self.width,
				page = currentPage and currentPage.name,
				scale = self._scale.Scale,
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
	local folder = options.folder or "sottui_edge"
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
	local startScale = tonumber(saved.scale) or (if viewport.Y < 620 then 0.85 else 1)
	local width = math.clamp(tonumber(saved.w) or DEFAULT_WIDTH, MIN_WIDTH, MAX_WIDTH)
	local closedX = -(SPINE + width) * startScale - 2

	local root = make("Frame", {
		Name = "Root",
		Position = UDim2.fromOffset(closedX, 0),
		Size = UDim2.fromOffset(SPINE + width, viewport.Y / startScale),
		Parent = gui,
	})
	local scale = make("UIScale", { Scale = startScale, Parent = root })

	local layer = make("Frame", { Name = "Layer", Size = UDim2.fromScale(1, 1), ZIndex = 100, Parent = gui })
	-- releases the mouse in games that lock it; visible only while the menu is open
	local modal = make("TextButton", {
		Name = "Modal",
		Size = UDim2.fromOffset(0, 0),
		Modal = true,
		Visible = false,
		Parent = root,
	})

	-- the spine
	local spine = make("Frame", {
		Name = "Spine",
		Size = UDim2.new(0, SPINE, 1, 0),
		BackgroundTransparency = 0,
		ClipsDescendants = true,
		Parent = root,
	})
	theme:paint(spine, "BackgroundColor3", "surface")
	local logoLength = math.ceil(metrics.width("display", options.title or "sottoro", WORD)) + WORD_PAD
	local logoHolder = make("Frame", { Size = UDim2.fromOffset(SPINE, logoLength), Parent = spine })
	local logo = make("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(logoLength, SPINE),
		Rotation = -90,
		TextSize = WORD,
		Text = options.title or "sottoro",
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = logoHolder,
	})
	theme:type(logo, "display")
	theme:paint(logo, "TextColor3", "accent")

	local navList = make("ScrollingFrame", {
		Name = "Nav",
		Position = UDim2.fromOffset(0, logoLength),
		Size = UDim2.new(1, 0, 1, -(logoLength + SPINE)),
		ScrollingEnabled = true,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Parent = spine,
	})
	local marker = make("Frame", {
		Name = "Marker",
		-- on the screen side of the spine; the column side belongs to the rail
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0, 4, 0, 0),
		BackgroundTransparency = 0,
		ZIndex = 3,
		Parent = navList,
	})
	theme:paint(marker, "BackgroundColor3", "accent")

	-- the person: at the spine's foot on every page
	local avatar = make("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.fromOffset(SPINE, SPINE),
		BackgroundTransparency = 0,
		ClipsDescendants = true,
		Parent = spine,
	})
	theme:paint(avatar, "BackgroundColor3", "accent")
	local localPlayer = env.service("Players").LocalPlayer
	if localPlayer then
		make("ImageLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = string.format("rbxthumb://type=AvatarBust&id=%d&w=150&h=150", localPlayer.UserId),
			Parent = avatar,
		})
	end

	-- the column
	local column = make("Frame", {
		Name = "Column",
		Position = UDim2.fromOffset(SPINE, 0),
		Size = UDim2.new(1, -SPINE, 1, 0),
		BackgroundTransparency = 0,
		ClipsDescendants = true,
		Active = true,
		Parent = root,
	})
	theme:paint(column, "BackgroundColor3", "base")
	local rail = make("Frame", {
		Name = "Rail",
		Size = UDim2.new(0, RAIL, 1, 0),
		BackgroundTransparency = 0,
		Parent = column,
	})
	theme:paint(rail, "BackgroundColor3", "line")
	local head = make("Frame", { Name = "Head", Size = UDim2.new(1, 0, 0, HEAD), Parent = column })
	local headTitle = make("TextLabel", {
		Position = UDim2.fromOffset(18, 12),
		Size = UDim2.new(1, -60, 0, TITLE + 8),
		TextSize = TITLE,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = head,
	})
	theme:type(headTitle, "display")
	theme:paint(headTitle, "TextColor3", "text")
	local headLine = make("TextLabel", {
		Position = UDim2.fromOffset(18, 12),
		Size = UDim2.new(1, -36, 0, 22),
		TextSize = 16,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = head,
	})
	theme:type(headLine, "text")
	theme:paint(headLine, "TextColor3", "muted")

	local rule = make("Frame", {
		Position = UDim2.fromOffset(RAIL, HEAD - 1),
		Size = UDim2.new(1, -RAIL, 0, 1),
		BackgroundTransparency = 0,
		Parent = column,
	})
	theme:paint(rule, "BackgroundColor3", "line")

	local body = make("Frame", {
		Name = "Body",
		Position = UDim2.fromOffset(0, HEAD),
		Size = UDim2.new(1, 0, 1, -HEAD),
		ClipsDescendants = true,
		ZIndex = 2,
		Parent = column,
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
		Size = UDim2.new(1, 0, 0, 3),
		BackgroundTransparency = 0,
		ZIndex = 9,
		Parent = wipe,
	})
	theme:paint(wipeEdge, "BackgroundColor3", "accent")

	-- what stays on screen with the panel away: a sliver to reach for
	local handle = make("TextButton", {
		Name = "Handle",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(if touch then 28 else 16, HANDLE_HEIGHT + 24),
		Visible = false,
		Parent = gui,
	})
	local handleBar = make("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(HANDLE_WIDTH, HANDLE_HEIGHT),
		BackgroundTransparency = 0,
		Parent = handle,
	})
	theme:paint(handleBar, "BackgroundColor3", "accent")

	local grip = make("TextButton", {
		Name = "Grip",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 8, 1, 0),
		ZIndex = 6,
		Parent = column,
	})

	local self: any = setmetatable({
		ctx = nil,
		pages = {},
		elements = {},
		ordered = {},
		current = nil,
		isOpen = false,
		destroyed = false,
		width = width,
		visibilityChanged = signal.new(),
		_maid = maid,
		_gui = gui,
		_root = root,
		_rootY = 0,
		_layer = layer,
		_modal = modal,
		_scale = scale,
		_navList = navList,
		_navItems = {},
		_navWords = {},
		_navUsed = 0,
		_pageHost = pageHost,
		_wipe = wipe,
		_wipeEdge = wipeEdge,
		_handle = handle,
		_headTitle = headTitle,
		_head = head,
		_headRule = rule,
		_body = body,
		_handleBar = handleBar,
		_railTicks = {},
		_headLine = headLine,
		_subtitleText = options.subtitle,
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
		assets = {},
		glyph = glyphModule.new(theme),
		tint = tintModule.new(theme),
		uiScale = function(): number
			return scale.Scale
		end,
		popoverTop = function(): number
			return 8
		end,
		paletteAt = function(): UDim2
			return UDim2.fromOffset(SPINE * scale.Scale + 8, 8)
		end,
		paletteWidth = function(): number
			return self.width * scale.Scale - 16
		end,
		dialogAt = function(): UDim2
			return UDim2.fromOffset(SPINE * scale.Scale, 0)
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
	local floating = overlay.popover(ctx, layer)
	-- lists and pickers open in place when they come from the column, and float only where there is no column (a dialog)
	ctx.popover = {
		open = function(_: any, anchor: any, w: number, h: number, build: (content: any, handle: any) -> ())
			local page = self.pages[self.current]
			if page == nil or not page:expand(anchor, h, build) then
				floating:open(anchor, w, h, build)
			end
		end,
		close = function()
			floating:close()
			local page = self.pages[self.current]
			if page then
				page:collapse()
			end
		end,
		isOpen = function(): boolean
			return floating:isOpen()
		end,
		key = function(_: any, name: string): boolean
			if floating:key(name) then
				return true
			end
			local page = self.pages[self.current]
			return page ~= nil and page:expansionKey(name)
		end,
	}
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
		local top, bottom = self._markerTop or 0, self._markerBottom or 0
		marker.Position = UDim2.new(0, 0, 0, top)
		marker.Size = UDim2.new(0, 4, 0, math.max(bottom - top, 0))
	end
	self._edgeTop = maid:add(motion.new(0, EDGE_LEAD, function(y: number)
		self._markerTop = y
		drawMarker()
	end))
	self._edgeBottom = maid:add(motion.new(0, EDGE_LEAD, function(y: number)
		self._markerBottom = y
		drawMarker()
	end))
	self._pageSlide = maid:add(motion.prop(pageHost, "Position", PAGE_SPEED))
	self._wipeAt = maid:add(motion.prop(wipe, "Position", PAGE_SPEED))
	self._slide = maid:add(motion.prop(root, "Position", SLIDE_OPEN_SPEED))
	self._columnSize = maid:add(motion.prop(column, "Size", COLUMN_SPEED))

	self._palette = paletteModule.new(ctx, layer, function(): { any }
		return self.ordered
	end, function(el: any)
		self:reveal(el)
	end)

	local close = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -6, 0, 6),
		Size = UDim2.fromOffset(34, 34),
		Parent = head,
	})
	local crossIcon = ctx.glyph.cross(close, "muted")
	crossIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	crossIcon.Position = UDim2.fromScale(0.5, 0.5)
	close.Activated:Connect(function()
		self:setOpen(false)
	end)
	local find = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -46, 0, 11),
		Size = UDim2.fromOffset(60, 24),
		TextSize = 16,
		Text = "Search",
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = head,
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
	headLine.Size = UDim2.new(1, -(36 + 110), 0, 22)

	handle.Activated:Connect(function()
		self:setOpen(true)
	end)

	grip.InputBegan:Connect(function(event: any)
		local kind = event.UserInputType
		if kind ~= Enum.UserInputType.MouseButton1 and kind ~= Enum.UserInputType.Touch then
			return
		end
		local from = if kind == Enum.UserInputType.Touch then router:at(event) else router:pointer()
		local origin = self.width
		router:capture(function(at: Vector2)
			self.width = math.clamp(origin + (at.X - from.X) / scale.Scale, MIN_WIDTH, MAX_WIDTH)
			self:_fit()
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
			-- an open list scrolls itself; moving the page under it as well loses your place in both
			if not page:pointerInExpansion(at) then
				page:wheel(delta)
			end
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
		self:_fit()
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

	if options.fonts ~= false and files then
		maid:add(task.defer(function()
			local tag = options.fontTag or VERSION
			local base = string.format(FONT_BASE, tag)
			-- by tag: a new release may change a file under the same name, and a cached copy would otherwise win forever
			local fontFolder = folder .. "/fonts-" .. tag
			local loaded = fonts.load(fontFolder, base, encode)
			if not self.destroyed and (loaded.text or loaded.display) then
				theme:setFonts(loaded.text, loaded.display)
			end
			local ticks = fonts.image(fontFolder, base, "ticks.png")
			if ticks and not self.destroyed then
				ctx.assets.ticks = ticks
				theme.changed:fire()
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
	else
		handle.Visible = true
	end

	return self
end

function window.setVersion(version: string)
	VERSION = version
end

return window
