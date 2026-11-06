--!strict
-- there is no window and no pages to walk through: a bar you type into. what you type finds real controls, right there,
-- ready to flip or drag. with nothing typed it shows what is on right now. pages survive only as words to browse by

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

local WIDTH = 640
local BAR = 76
local AVATAR = 76
local WORDS = 44
local WORD = 16
local WORD_GAP = 22
local MAX_PANEL = 560
local TOP = 0.14
local PANEL_SPEED = 30
local OPEN_SPEED = 28
local MARKER_SPEED = 30
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
	if page == self._resultsPage or page == self._onPage then
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
	if el.kind == "toggle" then
		el:on(function()
			if self._showing == self._onPage and self.isOpen then
				self:_fillOn()
			end
		end)
	end
end

function Window._setPerson(self: any, options: any)
	self._person = options
end

-- the panel is as long as what is in it: one result, one line
function Window._contentChanged(self: any, content: number, live: boolean?)
	local available = self._gui.AbsoluteSize.Y * (1 - TOP) / self._scale.Scale - BAR - WORDS - 24
	local height = math.min(content, MAX_PANEL, available)
	local size = UDim2.new(1, 0, 0, height)
	if live then
		self._panelSize:to(size)
	else
		self._panelSize:snap(size)
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
	page:setActive(true)
	page:adopt()
	self:_syncMarker(instant)
	self:_saveState()
end

function Window._syncMarker(self: any, instant: boolean?)
	local tint = self.ctx.tint
	local active = nil
	for page, item in self._words do
		local on = self._showing == page
		tint(item, "TextColor3", if on then "text" else "faint")
		if on then
			active = item
		end
	end
	if active == nil then
		self._markerSize:to(UDim2.fromOffset(0, 3))
		return
	end
	local scale = self._scale.Scale
	local x = (active.AbsolutePosition.X - self._wordList.AbsolutePosition.X) / scale
	local position = UDim2.fromOffset(x, WORDS - 4)
	local size = UDim2.fromOffset(active.AbsoluteSize.X / scale, 3)
	if instant then
		self._markerAt:snap(position)
		self._markerSize:snap(size)
	else
		self._markerAt:to(position)
		self._markerSize:to(size)
	end
end

local function addWord(self: any, page: any, name: string, order: number)
	local theme = self.ctx.theme
	local width = math.ceil(metrics.width("textMedium", name, WORD)) + 2
	local item = make("TextButton", {
		Name = name,
		Size = UDim2.fromOffset(width, WORDS),
		TextSize = WORD,
		Text = name,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = order,
		Parent = self._wordList,
	})
	theme:type(item, "text", true)
	theme:paint(item, "TextColor3", "faint")
	self._words[page] = item
	item.Activated:Connect(function()
		if self._box.Text ~= "" then
			self._box.Text = ""
		end
		self:_show(page)
	end)
	item.MouseEnter:Connect(function()
		if self._showing ~= page then
			self.ctx.tint(item, "TextColor3", "muted")
		end
	end)
	item.MouseLeave:Connect(function()
		if self._showing ~= page then
			self.ctx.tint(item, "TextColor3", "faint")
		end
	end)
end

function Window.page(self: any, name: string): any
	local built = pageModule.new(self, name)
	table.insert(self.pages, built)
	addWord(self, built, name, #self.pages + 1)
	built:mount(self._panel)
	return built
end

-- what is on across every page: the answer to the question you opened the menu to ask
function Window._fillOn(self: any)
	-- features first: a passive option being on says nothing, so they only show when no feature is running
	local list, options = {}, {}
	for _, el in self.ordered do
		if el.kind == "toggle" and el.value == true then
			table.insert(if el.spec.primary then list else options, el)
		end
	end
	if #list == 0 then
		list = options
	end
	self._onPage:showList(list, if #list == 0 then "Nothing is on" else nil)
end

function Window._query(self: any, text: string)
	if text == "" then
		self:_fillOn()
		self:_show(self._onPage)
		self._resultsPage:showList({})
		return
	end
	local hits = search.settings(text, self.ordered, MAX_RESULTS)
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
	local closed = UDim2.new(0.5, 0, TOP, -16)
	if open then
		self._root.Visible = true
		self._modal.Visible = true
		self:_guardCursor(true)
		self._at:to(UDim2.new(0.5, 0, TOP, 0))
		self:_fillOn()
		self:_show(self._onPage, true)
		self._reveal:to(UDim2.new(1, 0, 1, 0))
		if not self.ctx.touch then
			self._box:CaptureFocus()
		end
	else
		self._modal.Visible = false
		self:_guardCursor(false)
		self._box:ReleaseFocus()
		self._at:to(closed)
		self._reveal:to(UDim2.new(1, 0, 0, 0), function()
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
			store.write(self._stateFile, encode({ scale = self._scale.Scale }))
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
	self._onPage:destroy()
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
	local folder = options.folder or "sottui_command"
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
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, TOP, -16),
		Size = UDim2.fromOffset(WIDTH, BAR + WORDS),
		Visible = false,
		Parent = gui,
	})
	local scale = make("UIScale", { Scale = tonumber(saved.scale) or 1, Parent = root })
	local layer = make("Frame", { Name = "Layer", Size = UDim2.fromScale(1, 1), ZIndex = 100, Parent = gui })
	local modal = make("TextButton", {
		Name = "Modal",
		Size = UDim2.fromOffset(0, 0),
		Modal = true,
		Visible = false,
		Parent = root,
	})

	local bar = make("TextButton", {
		Name = "Bar",
		Size = UDim2.new(1, 0, 0, BAR),
		BackgroundTransparency = 0,
		ZIndex = 3,
		Parent = root,
	})
	theme:paint(bar, "BackgroundColor3", "surface")
	local avatar = make("Frame", {
		Size = UDim2.fromOffset(AVATAR, AVATAR),
		BackgroundTransparency = 0,
		ClipsDescendants = true,
		ZIndex = 3,
		Parent = bar,
	})
	theme:paint(avatar, "BackgroundColor3", "accent")
	local localPlayer = env.service("Players").LocalPlayer
	if localPlayer then
		make("ImageLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = string.format("rbxthumb://type=AvatarBust&id=%d&w=150&h=150", localPlayer.UserId),
			ZIndex = 3,
			Parent = avatar,
		})
	end
	local box = make("TextBox", {
		Position = UDim2.fromOffset(AVATAR + 20, 0),
		Size = UDim2.new(1, -(AVATAR + 20 + 56), 1, 0),
		TextSize = 26,
		Text = "",
		PlaceholderText = "Find a setting",
		ClipsDescendants = true,
		ZIndex = 3,
		Parent = bar,
	})
	theme:type(box, "display")
	theme:paint(box, "TextColor3", "text")
	theme:paint(box, "PlaceholderColor3", "faint")

	local words = make("Frame", {
		Name = "Words",
		Position = UDim2.fromOffset(0, BAR),
		Size = UDim2.new(1, 0, 0, WORDS),
		BackgroundTransparency = 0,
		ClipsDescendants = true,
		ZIndex = 2,
		Parent = root,
	})
	theme:paint(words, "BackgroundColor3", "base")
	local wordList = make("Frame", {
		Name = "List",
		Position = UDim2.fromOffset(18, 0),
		Size = UDim2.new(1, -18, 1, 0),
		ZIndex = 2,
		Parent = words,
	})
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, WORD_GAP),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = wordList,
	})
	local marker = make("Frame", {
		Position = UDim2.fromOffset(18, WORDS - 4),
		Size = UDim2.fromOffset(0, 3),
		BackgroundTransparency = 0,
		ZIndex = 3,
		Parent = words,
	})
	theme:paint(marker, "BackgroundColor3", "accent")
	local place = make("TextLabel", {
		Name = "Place",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -18, 0, 0),
		Size = UDim2.new(0, 200, 1, 0),
		TextSize = 15,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Right,
		Text = options.subtitle or "",
		ZIndex = 2,
		Parent = words,
	})
	theme:type(place, "text")
	theme:paint(place, "TextColor3", "faint")

	local panel = make("Frame", {
		Name = "Panel",
		Position = UDim2.fromOffset(0, BAR + WORDS),
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 0,
		ClipsDescendants = true,
		Active = true,
		Parent = root,
	})
	theme:paint(panel, "BackgroundColor3", "base")
	local self: any = setmetatable({
		ctx = nil,
		pages = {},
		elements = {},
		ordered = {},
		isOpen = false,
		destroyed = false,
		width = WIDTH,
		visibilityChanged = signal.new(),
		_maid = maid,
		_gui = gui,
		_root = root,
		_layer = layer,
		_modal = modal,
		_scale = scale,
		_box = box,
		_panel = panel,
		_words = {},
		_wordList = wordList,
		_subtitleText = options.subtitle,
		_files = files,
		_stateFile = stateFile,
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
		dialogAt = function(width: number): UDim2
			local viewport = layer.AbsoluteSize
			return UDim2.fromOffset(math.floor((viewport.X - width * scale.Scale) / 2), math.floor(viewport.Y * TOP))
		end,
		isShowing = function(el: any): boolean
			if not self.isOpen then
				return false
			end
			return self._showing == nil or el._shownOn == self._showing or el._page == self._showing
		end,
		setScrollLocked = function(locked: boolean)
			local page = self._showing
			if page and page.frame and touch then
				page.frame.ScrollingEnabled = not locked
			end
		end,
	}
	self.ctx = ctx
	local floating = overlay.popover(ctx, layer)
	ctx.popover = {
		open = function(_: any, anchor: any, w: number, h: number, build: (content: any, handle: any) -> ())
			local page = self._showing
			if page == nil or not page:expand(anchor, h, build) then
				floating:open(anchor, w, h, build)
			end
		end,
		close = function()
			floating:close()
			local page = self._showing
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
			local page = self._showing
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

	self._at = maid:add(motion.prop(root, "Position", OPEN_SPEED))
	self._panelSize = maid:add(motion.prop(panel, "Size", PANEL_SPEED))
	self._markerAt = maid:add(motion.prop(marker, "Position", MARKER_SPEED))
	self._markerSize = maid:add(motion.prop(marker, "Size", MARKER_SPEED))
	-- opening scales nothing and fades nothing: the words and the panel hold still and the height arrives
	self._reveal = maid:add(motion.new(UDim2.new(1, 0, 1, 0), OPEN_SPEED, function(value: UDim2)
		words.Visible = value.Y.Scale > 0.5
		panel.Visible = value.Y.Scale > 0.5
		bar.BackgroundTransparency = 1 - math.clamp(value.Y.Scale * 2, 0, 1)
	end))

	self._onPage = pageModule.new(self, "On")
	self._resultsPage = pageModule.new(self, "Results")
	self._onPage:mount(panel)
	self._resultsPage:mount(panel)
	addWord(self, self._onPage, "On now", 1)

	local close = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(44, 44),
		ZIndex = 4,
		Parent = bar,
	})
	local crossIcon = ctx.glyph.cross(close, "muted")
	crossIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	crossIcon.Position = UDim2.fromScale(0.5, 0.5)
	crossIcon.ZIndex = 4
	close.Activated:Connect(function()
		self:setOpen(false)
	end)

	box:GetPropertyChangedSignal("Text"):Connect(function()
		self:_query(box.Text)
	end)

	bar.InputBegan:Connect(function(event: any)
		local kind = event.UserInputType
		if kind ~= Enum.UserInputType.MouseButton1 and kind ~= Enum.UserInputType.Touch then
			return
		end
		local from = if kind == Enum.UserInputType.Touch then router:at(event) else router:pointer()
		local origin = root.AbsolutePosition - gui.AbsolutePosition + Vector2.new(root.AbsoluteSize.X / 2, 0)
		router:capture(function(at: Vector2)
			local delta = at - from
			self._at:snap(UDim2.fromOffset(origin.X + delta.X, origin.Y + delta.Y))
		end)
	end)

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
		if ctx.popover:key(name) then
			return
		end
		if name == "Escape" and self._dialogClose then
			self._dialogClose()
			return
		end
		if name == "Escape" and box.Text ~= "" then
			box.Text = ""
			return
		end
		if processed or router:typing() then
			return
		end
		if self.isOpen and name == "K" then
			if uis:IsKeyDown(Enum.KeyCode.LeftControl) or uis:IsKeyDown(Enum.KeyCode.RightControl) then
				box:CaptureFocus()
			end
		end
	end)

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
	end

	return self
end

function window.setVersion(version: string)
	VERSION = version
end

return window
