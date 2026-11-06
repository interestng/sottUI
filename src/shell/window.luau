--!strict
-- no window: a strip over the game that never moves, what is running hanging off its end, and a sheet that rises from it
-- only while you ask for one. the keyboard stays with the game until you click into search

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

local WIDTH = 420
local DOCK = 64
local AVATAR = 64
-- clears the standard hotbar (measured live: its top is 65 above the screen edge); anything else, the strip can be dragged
local BOTTOM = 76
local WORD = 19
local WORD_GAP = 24
local CHIP = 17
local CHIP_PAD = 16
local CHIP_GAP = 1
local MORE_ROOM = 64
local SEARCH = 124
local SEARCH_HEIGHT = 40
local CLOSE = 44
local RULE_HEIGHT = 28
local FADE = 34
local EDGE = 12
local MAX_PANEL = 600
local MAX_SHEET = 560
local PANEL_SPEED = 38
local OPEN_SPEED = 28
local MARKER_SPEED = 30
local DOCK_SPEED = 30
local MARKER = 4
local MAX_CHIPS = 6
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
			if el.spec.primary then
				self:_drawChips()
			end
		end)
		if el.spec.primary then
			el._onLabel = function()
				self:_drawChips()
			end
			if el.value == true then
				self:_drawChips()
			end
		end
	end
end

-- what is running lives on the dock itself: readable with every sheet closed, and one click turns it off
function Window._drawChips(self: any)
	if self._chipsQueued or self.destroyed then
		return
	end
	self._chipsQueued = true
	task.defer(function()
		self._chipsQueued = false
		if self.destroyed then
			return
		end
		local running = {}
		for _, el in self.ordered do
			if el.kind == "toggle" and el.spec.primary and el.value == true and not el.disabled and el:shown() then
				table.insert(running, el)
			end
		end
		for _, chip in self._chips do
			chip:Destroy()
		end
		table.clear(self._chips)
		local theme = self.ctx.theme
		local chipWidth = 0
		local function widthOf(text: string): number
			return math.ceil(metrics.width("display", text, CHIP)) + 2 * CHIP_PAD
		end
		local function add(text: string, order: number, onPress: () -> ())
			local width = widthOf(text)
			local chip = make("TextButton", {
				Name = "Chip",
				Size = UDim2.new(0, width, 1, 0),
				BackgroundTransparency = 0,
				TextSize = CHIP,
				Text = text,
				LayoutOrder = order,
				ZIndex = 3,
				Parent = self._chipRow,
			})
			chipWidth += width + CHIP_GAP
			theme:type(chip, "display")
			-- status at rest, a mint block only under the pointer: the blocks must not outshout the page you are on
			theme:paint(chip, "BackgroundColor3", "surface")
			theme:paint(chip, "TextColor3", "accent")
			chip.MouseEnter:Connect(function()
				self.ctx.tint(chip, "BackgroundColor3", "accent")
				self.ctx.tint(chip, "TextColor3", "onAccent")
			end)
			chip.MouseLeave:Connect(function()
				self.ctx.tint(chip, "BackgroundColor3", "surface")
				self.ctx.tint(chip, "TextColor3", "accent")
			end)
			chip.Activated:Connect(onPress)
			table.insert(self._chips, chip)
		end
		-- what fits beside the strip; the rest collapses into a count that opens the full list
		local scale = self._scale.Scale
		local center = self:_dockPoint()
		local right = center + (self._dockWidth or 0) * scale / 2
		local room = (self._gui.AbsoluteSize.X - right) / scale - CHIP_GAP - EDGE
		for index, el in running do
			local rest = #running - index
			local needed = widthOf(el.label) + (if rest > 0 then MORE_ROOM else 0)
			if index > MAX_CHIPS or chipWidth + needed > room then
				add("+" .. (rest + 1), 100 + index, function()
					self:_fillOn()
					self:_show(self._onPage)
				end)
				break
			end
			add(el.label, 100 + index, function()
				el:set(false)
			end)
		end
		self._chipRow.Size = UDim2.new(0, math.max(chipWidth - CHIP_GAP, 0), 1, 0)
	end)
end

function Window._setPerson(self: any, options: any)
	self._person = options
end

-- the sheet is as long as what is in it: one result, one line
function Window._contentChanged(self: any, content: number, live: boolean?)
	if self._showing == nil then
		return
	end
	local scale = self._scale.Scale
	local available = self._sheetRoom / scale - EDGE
	local height = math.min(content, MAX_PANEL, available)
	local size = UDim2.new(0, self._sheetWidth, 0, height)
	self._sheetFade.Visible = content > height
	if live or self._sheetRise then
		self._panelSize:to(size)
	else
		self._panelSize:snap(size)
	end
end

-- every sheet rises from the strip's left edge, one shape with it: a position that followed the word moved the targets
-- under the pointer on each switch
function Window._placeSheet(self: any)
	local scale = self._scale.Scale
	local center, bottom = self:_dockPoint()
	local x = center - (self._dockWidth or 0) * scale / 2
	local top = bottom - DOCK * scale
	local height = self._gui.AbsoluteSize.Y
	local above = top >= height / 2
	self._sheetAbove = above
	self._sheetRoom = if above then top else height - bottom
	self._panel.AnchorPoint = Vector2.new(0, if above then 1 else 0)
	self._panel.Position = UDim2.fromOffset(math.floor(x), math.floor(if above then top else bottom))
end

-- the strip's bottom centre, in the gui's own pixels
function Window._dockPoint(self: any): (number, number)
	local at = self._dockAt
	if at then
		return at.X, at.Y
	end
	local size = self._gui.AbsoluteSize
	return size.X / 2, size.Y - BOTTOM
end

function Window._home(self: any): UDim2
	local at = self._dockAt
	return if at then UDim2.fromOffset(at.X, at.Y) else UDim2.new(0.5, 0, 1, -BOTTOM)
end

function Window._away(self: any): UDim2
	-- past the edge by a margin, or the spring's slow tail leaves a sliver hanging there
	return self:_home() + UDim2.fromOffset(0, DOCK * self._scale.Scale + BOTTOM + EDGE)
end

-- a saved or dragged spot stays reachable when the screen changes
function Window._clampDock(self: any)
	local at = self._dockAt
	if at == nil then
		return
	end
	local scale = self._scale.Scale
	local size = self._gui.AbsoluteSize
	local half = (self._dockWidth or 0) * scale / 2
	self._dockAt = Vector2.new(
		math.clamp(at.X, math.min(half + EDGE, size.X / 2), math.max(size.X - half - EDGE, size.X / 2)),
		math.clamp(at.Y, DOCK * scale + EDGE, math.max(size.Y - EDGE, DOCK * scale + EDGE))
	)
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
	-- a word pressed mid close replaces the spring's done, so the page on its way out has to be let go here
	local leaving = self._leaving
	if leaving and leaving ~= page then
		leaving:setActive(false)
	end
	self._leaving = nil
	self._showing = page
	self:_placeSheet()
	self._sheetRise = not instant
	page:setActive(true)
	self._sheetRise = false
	page:adopt()
	self:_syncMarker(instant)
	self:_saveState()
end

function Window._hideSheet(self: any)
	local previous = self._showing
	if previous == nil then
		return
	end
	self.ctx.hover.clear()
	self.ctx.popover:close()
	self.keys:cancel()
	self._showing = nil
	self._leaving = previous
	self._panelSize:to(UDim2.new(0, self._sheetWidth, 0, 0), function()
		if self._leaving == previous then
			self._leaving = nil
			previous:setActive(false)
		end
	end)
	self:_syncMarker()
end

function Window._syncMarker(self: any, instant: boolean?)
	local tint = self.ctx.tint
	local active = nil
	for page, item in self._words do
		local on = self._showing == page
		if item:IsA("TextButton") and item.Text ~= "" then
			tint(item, "TextColor3", if on then "text" else "muted")
		end
		if on then
			active = item
		end
	end
	if active == nil then
		self._markerSize:to(UDim2.fromOffset(0, MARKER))
		return
	end
	self.ctx.theme:paint(self._marker, "BackgroundColor3", if active == self._homeAvatar then "onAccent" else "accent")
	local scale = self._scale.Scale
	local x = (active.AbsolutePosition.X - self._dock.AbsolutePosition.X) / scale
	-- the marker sits on the edge the sheet comes out of
	local position = UDim2.fromOffset(x, if self._sheetAbove == false then DOCK - MARKER else 0)
	local size = UDim2.fromOffset(active.AbsoluteSize.X / scale, MARKER)
	if instant or self._markerSize.target == nil or self._markerSize.target.X.Offset == 0 then
		self._markerAt:snap(position)
	else
		self._markerAt:to(position)
	end
	if instant then
		self._markerSize:snap(size)
	else
		self._markerSize:to(size)
	end
end

local function bindWord(self: any, page: any, item: any)
	self._words[page] = item
	item.Activated:Connect(function()
		if self._box.Text ~= "" then
			self._box.Text = ""
		end
		if self._showing == page then
			self:_hideSheet()
		else
			self:_show(page)
		end
	end)
end

local function addWord(self: any, page: any, name: string, order: number)
	local theme = self.ctx.theme
	local width = math.ceil(metrics.width("display", name, WORD)) + 2
	local item = make("TextButton", {
		Name = name,
		Size = UDim2.new(0, width, 1, 0),
		TextSize = WORD,
		Text = name,
		LayoutOrder = order,
		ZIndex = 3,
		Parent = self._row,
	})
	theme:type(item, "display")
	theme:paint(item, "TextColor3", "muted")
	bindWord(self, page, item)
	item.MouseEnter:Connect(function()
		if self._showing ~= page then
			self.ctx.tint(item, "TextColor3", "text")
		end
	end)
	item.MouseLeave:Connect(function()
		if self._showing ~= page then
			self.ctx.tint(item, "TextColor3", "muted")
		end
	end)
end

function Window.page(self: any, name: string): any
	local built = pageModule.new(self, name)
	table.insert(self.pages, built)
	-- your face is the way home: one less word on a strip that stays over the game
	if name == "Home" and self._homeAvatar then
		bindWord(self, built, self._homeAvatar)
	else
		addWord(self, built, name, 2 + #self.pages)
	end
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
		if self._showing == self._resultsPage then
			self:_hideSheet()
		end
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
	if open then
		self._root.Visible = true
		self._modal.Visible = true
		self:_guardCursor(true)
		self._at:to(self:_home())
		self:_drawChips()
		-- no focus and no sheet on open: the keyboard stays with the game until you ask for the menu's
	else
		self._modal.Visible = false
		self:_guardCursor(false)
		self._box:ReleaseFocus()
		-- a query left behind would show in the box with no results under it on the next open
		self._box.Text = ""
		self:_hideSheet()
		self._at:to(self:_away(), function()
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
	local value = math.clamp(scale, 0.7, 1.5)
	self._scale.Scale = value
	self._panelScale.Scale = value
	self:_placeSheet()
	self:_drawChips()
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
			local at = self._dockAt
			store.write(
				self._stateFile,
				encode({ scale = self._scale.Scale, dockX = at and at.X, dockY = at and at.Y })
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
	local folder = options.folder or "sottui_dock"
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

	-- the whole screen so the dock and sheet can be placed against its edges; it takes no input itself
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

	-- strip and running chips travel as one; the chips hang off its right end so nothing on the strip ever moves
	local assembly = make("Frame", {
		Name = "Assembly",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, DOCK),
		Size = UDim2.fromOffset(400, DOCK),
		ZIndex = 3,
		Parent = root,
	})
	local scale = make("UIScale", { Scale = startScale, Parent = assembly })
	local dock = make("Frame", {
		Name = "Dock",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 0,
		ClipsDescendants = true,
		Active = true,
		ZIndex = 3,
		Parent = assembly,
	})
	theme:paint(dock, "BackgroundColor3", "surface")
	local row = make("Frame", {
		Name = "Row",
		Size = UDim2.fromScale(1, 1),
		ZIndex = 3,
		Parent = dock,
	})
	local rowLayout = make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, WORD_GAP),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = row,
	})

	local avatar = make("TextButton", {
		Name = "Avatar",
		Size = UDim2.fromOffset(AVATAR, AVATAR),
		BackgroundTransparency = 0,
		ClipsDescendants = true,
		Text = "",
		LayoutOrder = 1,
		ZIndex = 3,
		Parent = row,
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

	local chipRow = make("Frame", {
		Name = "Running",
		Position = UDim2.new(1, CHIP_GAP, 0, 0),
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundTransparency = 0,
		ZIndex = 3,
		Parent = assembly,
	})
	theme:paint(chipRow, "BackgroundColor3", "lineStrong")
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, CHIP_GAP),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = chipRow,
	})

	local function tintFocus(target: any, token: string)
		theme:paint(target, "BackgroundColor3", token)
	end
	local box = make("TextBox", {
		Name = "Search",
		Size = UDim2.fromOffset(SEARCH, SEARCH_HEIGHT),
		BackgroundTransparency = 0,
		TextSize = WORD,
		Text = "",
		PlaceholderText = "Search",
		ClearTextOnFocus = false,
		ClipsDescendants = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 300,
		ZIndex = 3,
		Parent = row,
	})
	make("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 8), Parent = box })
	-- only a well while it has the keyboard, which is the one time that matters
	theme:paint(box, "BackgroundColor3", "surface")
	box.Focused:Connect(function()
		tintFocus(box, "base")
	end)
	box.FocusLost:Connect(function()
		tintFocus(box, "surface")
	end)
	theme:type(box, "display")
	theme:paint(box, "TextColor3", "text")
	theme:paint(box, "PlaceholderColor3", "muted")

	local marker = make("Frame", {
		Name = "Marker",
		Size = UDim2.fromOffset(0, MARKER),
		BackgroundTransparency = 0,
		ZIndex = 4,
		Parent = dock,
	})
	theme:paint(marker, "BackgroundColor3", "accent")

	local panel = make("Frame", {
		Name = "Sheet",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, -(BOTTOM + DOCK)),
		Size = UDim2.new(0, WIDTH, 0, 0),
		BackgroundTransparency = 0,
		ClipsDescendants = true,
		Active = true,
		ZIndex = 2,
		Parent = root,
	})
	theme:paint(panel, "BackgroundColor3", "surface")
	-- a long page dissolves into the strip instead of slicing a row in half
	local fade = make("Frame", {
		Name = "Fade",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, FADE),
		BackgroundTransparency = 0,
		Visible = false,
		ZIndex = 20,
		Parent = panel,
	})
	theme:paint(fade, "BackgroundColor3", "surface")
	make("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0),
		}),
		Parent = fade,
	})
	local panelScale = make("UIScale", { Scale = startScale, Parent = panel })
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
		_panelScale = panelScale,
		_box = box,
		_panel = panel,
		_dock = dock,
		_row = row,
		_marker = marker,
		_sheetFade = fade,
		_chipRow = chipRow,
		_homeAvatar = avatar,
		_chips = {},
		_sheetRoom = 600,
		_sheetWidth = WIDTH,
		_dockAt = if tonumber(saved.dockX) and tonumber(saved.dockY)
			then Vector2.new(saved.dockX, saved.dockY)
			else nil,
		_words = {},
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
			return UDim2.fromOffset(math.floor((viewport.X - width * scale.Scale) / 2), math.floor(viewport.Y * 0.2))
		end,
		isShowing = function(el: any): boolean
			if not self.isOpen or self._showing == nil then
				return false
			end
			return el._shownOn == self._showing or el._page == self._showing
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

	self._at = maid:add(motion.prop(assembly, "Position", OPEN_SPEED))
	self._at:snap(self:_away())
	self._panelSize = maid:add(motion.prop(panel, "Size", PANEL_SPEED))
	self._markerAt = maid:add(motion.prop(marker, "Position", MARKER_SPEED))
	self._markerSize = maid:add(motion.prop(marker, "Size", MARKER_SPEED))
	local dockSize = maid:add(motion.prop(assembly, "Size", DOCK_SPEED))

	self._onPage = pageModule.new(self, "On")
	self._resultsPage = pageModule.new(self, "Results")
	self._onPage:mount(panel)
	self._resultsPage:mount(panel)

	local close = make("TextButton", {
		Name = "Close",
		Size = UDim2.new(0, CLOSE, 1, 0),
		LayoutOrder = 400,
		ZIndex = 4,
		Parent = row,
	})
	local crossIcon = ctx.glyph.cross(close, "muted")
	crossIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	crossIcon.Position = UDim2.new(0.5, 4, 0.5, 0)
	crossIcon.ZIndex = 4
	-- set apart from search, or it reads as clearing the field rather than closing the menu
	local rule = make("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(1, RULE_HEIGHT),
		BackgroundTransparency = 0,
		ZIndex = 4,
		Parent = close,
	})
	theme:paint(rule, "BackgroundColor3", "lineStrong")
	avatar.MouseEnter:Connect(function()
		ctx.tint(avatar, "BackgroundColor3", "accentHover")
	end)
	avatar.MouseLeave:Connect(function()
		ctx.tint(avatar, "BackgroundColor3", "accent")
	end)

	dock.InputBegan:Connect(function(event: any)
		local kind = event.UserInputType
		if kind ~= Enum.UserInputType.MouseButton1 and kind ~= Enum.UserInputType.Touch then
			return
		end
		local from = if kind == Enum.UserInputType.Touch then router:at(event) else router:pointer()
		local originX, originY = self:_dockPoint()
		router:capture(function(at: Vector2)
			local delta = at - from
			self._dockAt = Vector2.new(originX + delta.X, originY + delta.Y)
			self:_clampDock()
			self._at:snap(self:_home())
			self:_placeSheet()
		end, function()
			self:_drawChips()
			self:_syncMarker(true)
			self:_saveState()
		end, if kind == Enum.UserInputType.Touch then event else nil)
	end)
	close.Activated:Connect(function()
		self:setOpen(false)
	end)

	box:GetPropertyChangedSignal("Text"):Connect(function()
		self:_query(box.Text)
	end)

	-- the strip is exactly as wide as its words, a fact that only changes while pages are being added
	local function fitDock()
		local width = math.ceil(rowLayout.AbsoluteContentSize.X / scale.Scale)
		self._dockWidth = width
		dockSize:snap(UDim2.fromOffset(width, DOCK))
		self:_clampDock()
		if self.isOpen then
			self._at:snap(self:_home())
		else
			self._at:snap(self:_away())
		end
		self:_placeSheet()
		self:_drawChips()
		task.defer(function()
			if not self.destroyed then
				-- the sheet ends where search begins, so its edge lines up with something on the strip
				local fit = (box.AbsolutePosition.X - dock.AbsolutePosition.X) / scale.Scale
				self._sheetWidth = math.clamp(math.floor(fit), WIDTH, MAX_SHEET)
				panel.Size = UDim2.new(0, self._sheetWidth, 0, panel.Size.Y.Offset)
				self:_syncMarker(true)
			end
		end)
	end
	rowLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(fitDock)
	task.defer(fitDock)
	maid:add(gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_clampDock()
		if self.isOpen then
			self._at:snap(self:_home())
		end
		self:_placeSheet()
		self:_drawChips()
		local page = self._showing
		if page then
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
