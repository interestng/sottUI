--!strict
-- the whole screen is the menu while it is open: the game dims, and one column of huge words turns like a wheel. one
-- thing at a time, in the middle, large. nothing else needs to be on screen, so nothing else is

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

local DIM = 0.3
local SHADE_SPEED = 18
local NAV_SIZE = 22
local NAV_GAP = 28
local CONTROLS_BOTTOM = 48
local MARGIN = 48
local AVATAR = 76
local SPIN_PAGE = 5
local SPIN_OPEN = 7
local NAME_LENGTH = 12
local MARKER_SPEED = 28
local WIDTH_FOR_PALETTE = 560

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
	el:on(function()
		local view = page:viewOf(el)
		if view then
			view.refresh()
		end
	end)
end

function Window._setPerson(self: any, options: any)
	self._personName.Text = options.title or ""
	self._personLine.RichText = true
	self._personLine.Text = options.text or ""
end

-- how far along the wheel, in the one place the page's position is ever spelled out
function Window._reportCount(self: any, _page: any) end

function Window._syncMarker(self: any, instant: boolean?)
	local item = self._navItems[self.current]
	if item == nil then
		return
	end
	local list = self._navList
	local x = item.AbsolutePosition.X - list.AbsolutePosition.X
	local position = UDim2.fromOffset(x, NAV_SIZE + 12)
	local size = UDim2.fromOffset(item.AbsoluteSize.X, 3)
	if instant then
		self._markerAt:snap(position)
		self._markerSize:snap(size)
	else
		self._markerAt:to(position)
		self._markerSize:to(size)
	end
end

function Window.page(self: any, name: string): any
	local built = pageModule.new(self, name)
	table.insert(self.pages, built)
	local index = #self.pages
	local theme = self.ctx.theme
	local width = math.ceil(metrics.width("display", name, NAV_SIZE)) + 4
	local item = make("TextButton", {
		Name = name,
		Size = UDim2.fromOffset(width, NAV_SIZE + 10),
		TextSize = NAV_SIZE,
		Text = name,
		TextXAlignment = Enum.TextXAlignment.Left,
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
	built:mount(self._stage)
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
	if not instant then
		target:spinIn(if forward then -SPIN_PAGE else SPIN_PAGE)
	end
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
	local owner = el.section and (el.section._root or el.section)
	if owner and owner.masterElement and owner.masterElement.value ~= true and host ~= owner.masterElement then
		owner.peeking = true
		page:rebuild()
	end
	page:focusOn(host)
end

function Window.setOpen(self: any, open: boolean)
	if self.isOpen == open or self.destroyed then
		return
	end
	self.isOpen = open
	if self._opener then
		self._opener.Visible = not open
	end
	self.ctx.popover:close()
	self._palette.close()
	self.ctx.tooltip:hide()
	self.keys:cancel()
	if not open and self._dialogClose then
		self._dialogClose()
	end
	local page = self.pages[self.current]
	if open then
		self._root.Visible = true
		self._modal.Visible = true
		self:_guardCursor(true)
		self._shade:to(DIM)
		self._lift:to(UDim2.fromScale(0, 0))
		if page then
			page:rebuild()
			page:spinIn(SPIN_OPEN)
		end
	else
		self._modal.Visible = false
		self:_guardCursor(false)
		self._lift:to(UDim2.new(0, 0, 0, 40))
		self._shade:to(1, function()
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
	local page = self.pages[self.current]
	if page then
		page:place()
	end
	self:_saveState()
end

function Window.setSubtitle(self: any, text: string)
	self._subtitleText = text
	self._personLine.Text = text
end

function Window._saveState(self: any)
	local store = self._files
	if store == nil or self._stateFile == nil or self._stateQueued then
		return
	end
	self._stateQueued = true
	task.delay(0.5, function()
		self._stateQueued = false
		if self.destroyed then
			return
		end
		local currentPage = self.pages[self.current]
		store.write(
			self._stateFile,
			encode({
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
	local folder = options.folder or "sottui_stage"
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

	-- the stage dims the game with the brand's own ground, so the world behind reads as night, not as a grey film
	local root = make("TextButton", {
		Name = "Root",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = gui,
	})
	theme:paint(root, "BackgroundColor3", "base")
	local modal = make("TextButton", {
		Name = "Modal",
		Size = UDim2.fromOffset(0, 0),
		Modal = true,
		Visible = false,
		Parent = root,
	})
	-- deepest behind the words and feathered at the sides: the column stays legible over a bright sky, the world still shows
	local backdrop = make("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 0,
		Parent = root,
	})
	theme:paint(backdrop, "BackgroundColor3", "base")
	make("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.1, 0.94),
			NumberSequenceKeypoint.new(0.2, 0.74),
			NumberSequenceKeypoint.new(0.3, 0.42),
			NumberSequenceKeypoint.new(0.4, 0.18),
			NumberSequenceKeypoint.new(0.5, 0.12),
			NumberSequenceKeypoint.new(0.6, 0.18),
			NumberSequenceKeypoint.new(0.7, 0.42),
			NumberSequenceKeypoint.new(0.8, 0.74),
			NumberSequenceKeypoint.new(0.9, 0.94),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Parent = backdrop,
	})
	local stage = make("Frame", {
		Name = "Stage",
		Size = UDim2.fromScale(1, 1),
		ClipsDescendants = true,
		Parent = root,
	})

	local layer = make("Frame", { Name = "Layer", Size = UDim2.fromScale(1, 1), ZIndex = 100, Parent = gui })

	local logo = make("TextLabel", {
		AutomaticSize = Enum.AutomaticSize.X,
		Position = UDim2.fromOffset(MARGIN, 60),
		Size = UDim2.fromOffset(0, NAV_SIZE + 10),
		TextSize = NAV_SIZE,
		Text = options.title or "sottoro",
		ZIndex = 5,
		Parent = root,
	})
	theme:type(logo, "display")
	theme:paint(logo, "TextColor3", "accent")
	local nav = make("Frame", {
		Name = "Nav",
		Position = UDim2.fromOffset(MARGIN + 130, 60),
		Size = UDim2.new(1, -(MARGIN * 2 + 130 + 140), 0, NAV_SIZE + 18),
		ZIndex = 5,
		Parent = root,
	})
	local navList = make("Frame", {
		Name = "List",
		Size = UDim2.fromScale(1, 1),
		ZIndex = 5,
		Parent = nav,
	})
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, NAV_GAP),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = navList,
	})
	local marker = make("Frame", {
		Name = "Marker",
		Position = UDim2.fromOffset(0, NAV_SIZE + 12),
		Size = UDim2.fromOffset(0, 3),
		BackgroundTransparency = 0,
		ZIndex = 6,
		Parent = nav,
	})
	theme:paint(marker, "BackgroundColor3", "accent")

	-- the person, bottom left, large enough to be them
	local avatar = make("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, MARGIN, 1, -36),
		Size = UDim2.fromOffset(AVATAR, AVATAR),
		BackgroundTransparency = 0,
		ClipsDescendants = true,
		ZIndex = 5,
		Parent = root,
	})
	theme:paint(avatar, "BackgroundColor3", "accent")
	local localPlayer = env.service("Players").LocalPlayer
	if localPlayer then
		make("ImageLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = string.format("rbxthumb://type=AvatarBust&id=%d&w=150&h=150", localPlayer.UserId),
			ZIndex = 5,
			Parent = avatar,
		})
	end
	local personName = make("TextLabel", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, MARGIN + AVATAR + 14, 1, -62),
		Size = UDim2.fromOffset(480, 36),
		TextSize = 30,
		Text = if localPlayer then localPlayer.DisplayName else "",
		ZIndex = 5,
		Parent = root,
	})
	theme:type(personName, "display")
	theme:paint(personName, "TextColor3", "text")
	local personLine = make("TextLabel", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, MARGIN + AVATAR + 14, 1, -38),
		Size = UDim2.fromOffset(480, 22),
		TextSize = 17,
		Text = options.subtitle or "",
		ZIndex = 5,
		Parent = root,
	})
	theme:type(personLine, "text")
	theme:paint(personLine, "TextColor3", "muted")

	local self: any = setmetatable({
		ctx = nil,
		pages = {},
		elements = {},
		ordered = {},
		current = nil,
		isOpen = false,
		destroyed = false,
		visibilityChanged = signal.new(),
		_maid = maid,
		_gui = gui,
		_root = root,
		_stage = stage,
		_layer = layer,
		_modal = modal,
		-- the same shape as a UIScale for whoever reads it; the page multiplies it into every row's own scale
		_scale = { Scale = tonumber(saved.scale) or 1 },
		_navList = navList,
		_navItems = {},
		_personName = personName,
		_personLine = personLine,
		_subtitleText = options.subtitle,
		_files = files,
		_stateFile = stateFile,
		_savedPage = saved.page,
		_dialogIds = 0,
		_registry = registry,
		width = 460,
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
			return 1
		end,
		popoverTop = function(): number
			return 8
		end,
		paletteAt = function(): UDim2
			local viewport = layer.AbsoluteSize
			return UDim2.fromOffset(math.floor((viewport.X - WIDTH_FOR_PALETTE) / 2), math.floor(viewport.Y * 0.2))
		end,
		paletteWidth = function(): number
			return WIDTH_FOR_PALETTE
		end,
		dialogAt = function(width: number): UDim2
			local viewport = layer.AbsoluteSize
			return UDim2.fromOffset(
				math.floor((viewport.X - width * self.ctx.uiScale()) / 2),
				math.floor(viewport.Y * 0.18)
			)
		end,
		isShowing = function(): boolean
			return self.isOpen
		end,
		setScrollLocked = function() end,
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

	self._markerAt = maid:add(motion.prop(marker, "Position", MARKER_SPEED))
	self._markerSize = maid:add(motion.prop(marker, "Size", MARKER_SPEED))
	self._shade = maid:add(motion.new(1, SHADE_SPEED, function(value: number)
		root.BackgroundTransparency = value
		backdrop.BackgroundTransparency = if value >= 1 then 1 else 0
	end))
	self._lift = maid:add(motion.prop(stage, "Position", SHADE_SPEED))

	self._palette = paletteModule.new(ctx, layer, function(): { any }
		return self.ordered
	end, function(el: any)
		self:reveal(el)
	end)

	local close = make("TextButton", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -MARGIN + 8, 1, -CONTROLS_BOTTOM),
		Size = UDim2.fromOffset(34, 34),
		ZIndex = 5,
		Parent = root,
	})
	local crossIcon = ctx.glyph.cross(close, "muted")
	crossIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	crossIcon.Position = UDim2.fromScale(0.5, 0.5)
	crossIcon.ZIndex = 5
	close.Activated:Connect(function()
		self:setOpen(false)
	end)
	local find = make("TextButton", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -(MARGIN + 34), 1, -CONTROLS_BOTTOM),
		Size = UDim2.fromOffset(70, 34),
		TextSize = 18,
		Text = "Search",
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 5,
		Parent = root,
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

	router.wheel:connect(function(delta: number)
		if not self.isOpen or ctx.popover:isOpen() or self._palette:isOpen() then
			return
		end
		local page = self.pages[self.current]
		if page then
			page:step(if delta > 0 then -1 else 1)
		end
	end)
	-- a finger drags the wheel; a settled finger is a tap, which the row itself handled
	if touch then
		root.InputBegan:Connect(function(event: any)
			if event.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			local page = self.pages[self.current]
			if page == nil then
				return
			end
			local from = router:at(event)
			local base = page._target or 1
			router:capture(function(at: Vector2)
				local rows = math.round((from.Y - at.Y) / 64)
				page:scrollTo(base + rows)
				page:place()
			end, nil, event)
		end)
	end
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
		if processed or router:typing() or not self.isOpen then
			return
		end
		local page = self.pages[self.current]
		if name == "K" and (uis:IsKeyDown(Enum.KeyCode.LeftControl) or uis:IsKeyDown(Enum.KeyCode.RightControl)) then
			self._palette:toggle()
		elseif page and name == "Up" then
			page:step(-1)
		elseif page and name == "Down" then
			page:step(1)
		elseif page and (name == "Left" or name == "Right") then
			local view = page:current()
			if view then
				view.nudge(if name == "Left" then -1 else 1)
			end
		elseif page and name == "Return" then
			local view = page:current()
			if view then
				view.act()
			end
		elseif name == "Tab" then
			self:show((self.current % #self.pages) + 1)
		end
	end)

	maid:add(gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		local page = self.pages[self.current]
		if page then
			page:place()
		end
	end))
	maid:add(theme.changed:connect(function()
		for _, page in self.pages do
			for _, view in page._views do
				pcall(view.refresh)
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
			-- by tag: a new release may change a file under the same name, and a cached copy would otherwise win forever
			local loaded = fonts.load(folder .. "/fonts-" .. tag, string.format(FONT_BASE, tag), encode)
			if not self.destroyed and (loaded.text or loaded.display) then
				theme:setFonts(loaded.text, loaded.display)
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
