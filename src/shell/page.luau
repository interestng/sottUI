--!strict
-- a page is one column laid out by arithmetic, no layout objects. a row's instances are built the first time it scrolls
-- near the viewport. a dropdown or colour opens inline under its row and pushes the rest down: on a single column there
-- is nothing to float over

local kinds = require("../view/kinds")
local make = require("../core/make")
local metrics = require("../core/metrics")
local motion = require("../core/motion")
local rowModule = require("../view/row")
local sectionModule = require("./section")

local page = {}

local TOP = 0
local BOTTOM = 34
local FLAT_BOTTOM = 6
local THUMB_LINGER = 0.9
local HEADER = 52
local SECTION_GAP = 18
local MASTER_GAP = 2
local NEAR = 360
local WHEEL_STEP = 100
local SCROLL_SPEED = 24
local SLIDE_SPEED = 28
local EXPAND_SPEED = 30

local Page = {}
Page.__index = Page

local function heightOf(el: any, width: number): number
	local kind = el.kind
	if kind == "slider" then
		return kinds.SLIDER_HEIGHT
	end
	if kind == "stat" then
		return 36
	end
	if kind == "divider" then
		return if el.label == "" then 8 else 28
	end
	if kind == "label" and not el.addons then
		if not el.spec.wrap then
			return 30
		end
		if el._measured then
			return el._measured
		end
		local plain = string.gsub(el.label, "<[^>]+>", "")
		local lines = math.ceil(metrics.width("text", plain, 16) / math.max(width - 2 * rowModule.PAD, 40))
		return lines * 21 + 12
	end
	if kind == "toggle" and el.spec.primary then
		return kinds.MASTER_HEIGHT
	end
	return rowModule.HEIGHT
end

function Page.nextId(self: any): number
	self._ids += 1
	return self._ids
end

function Page._register(self: any, el: any, public: boolean)
	el._relayout = function()
		self:_invalidate()
	end
	self.window:_registerElement(el, self, public)
end

function Page._invalidate(self: any)
	if self._dirty then
		return
	end
	self._dirty = true
	task.defer(function()
		self._dirty = false
		if not self.destroyed then
			-- a resize reflows instantly; only a change the user made should move things
			self:layout(not self._quiet)
			self._quiet = false
		end
	end)
end

function Page.section(self: any, title: string): any
	local built = sectionModule.new(self, title)
	table.insert(self.sections, built)
	self:_invalidate()
	return built
end

-- several sections sharing one slot, the title being their switcher. tabs may be added one at a time
function Page.tabset(self: any): any
	local holder = sectionModule.new(self, "")
	holder.tabNames = {}
	holder.activeTab = 1
	table.insert(self.sections, holder)
	local api = {}
	function api.tab(_: any, name: string): any
		table.insert(holder.tabNames, name)
		local index = #holder.tabNames
		local child = holder:when(function()
			return holder.activeTab == index
		end)
		child.title = name
		local header = self._headers[holder]
		if header then
			header:Destroy()
			self._headers[holder] = nil
		end
		self:_invalidate()
		return child
	end
	return api
end

function Page.tabs(self: any, names: { string }): { any }
	local set = self:tabset()
	local out = {}
	for _, name in names do
		table.insert(out, set:tab(name))
	end
	return out
end

-- this design's person lives in the spine, always; a page has no hero block. the text goes to the column's own header
function Page.hero(self: any, options: { userId: number?, title: string, text: string? }): any
	self.window:_setPerson(options)
	return {
		set = function(_: any, title: string?, text: string?)
			options.title = title or options.title
			options.text = text or options.text
			self.window:_setPerson(options)
		end,
	}
end

local function buildHeader(self: any, section: any): any
	local ctx = self.window.ctx
	local theme = ctx.theme
	local holder = make("Frame", { Name = "Header", Parent = self.canvas })
	if section.tabNames then
		local labels = {}
		local x = rowModule.PAD
		for index, name in section.tabNames do
			local width = math.ceil(metrics.width("display", name, 15)) + 18
			local button = make("TextButton", {
				Position = UDim2.fromOffset(x, 0),
				Size = UDim2.new(0, width, 1, -6),
				TextSize = 15,
				Text = name,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = holder,
			})
			theme:type(button, "display")
			labels[index] = button
			button.Activated:Connect(function()
				section.activeTab = index
				for i, label in labels do
					theme:paint(label, "TextColor3", if i == section.activeTab then "text" else "faint")
				end
				self:_invalidate()
			end)
			theme:paint(button, "TextColor3", if index == section.activeTab then "text" else "faint")
			x += width
		end
	else
		local title = make("TextLabel", {
			Position = UDim2.fromOffset(rowModule.PAD, 0),
			Size = UDim2.new(1, -2 * rowModule.PAD, 1, -6),
			TextSize = 23,
			TextYAlignment = Enum.TextYAlignment.Bottom,
			Text = section.title,
			Parent = holder,
		})
		theme:type(title, "display")
		theme:paint(title, "TextColor3", "text")
	end
	return holder
end

function Page.layout(self: any, live: boolean?)
	local frame = self.frame
	if frame == nil then
		return
	end
	self._live = live == true and self._settled == true and self.active
	local scale = self.window.ctx.uiScale()
	local width = frame.AbsoluteSize.X / scale
	if width < 1 then
		return
	end
	local y = TOP
	local placements: { any } = {}
	local expansion = self._expansion
	if expansion then
		expansion.y = nil
	end
	local lastFolded = false

	for _, section in self.sections do
		local rows: { any } = {}
		for _, el in section.rows do
			if section.flat or el:shown() then
				table.insert(rows, el)
			end
		end
		if #rows > 0 or section.tabNames then
			if (section.title ~= "" or section.tabNames) and not section.masterElement then
				if lastFolded then
					y += SECTION_GAP - MASTER_GAP
				end
				table.insert(placements, { section = section, y = y, height = HEADER })
				y += HEADER
			end
			for _, el in rows do
				local height = heightOf(el, width)
				table.insert(placements, { el = el, y = y, height = height })
				y += height
				if expansion and expansion.el == el then
					expansion.y = y
					y += expansion.height
				end
			end
			local folded = section.masterElement ~= nil and #rows == 1
			y += if folded then MASTER_GAP else SECTION_GAP
			lastFolded = folded
		end
	end

	-- its row is gone (a master folded, a tab switched): an open list has nothing left to hang from
	if expansion and expansion.y == nil then
		self._live = false
		self:collapse()
		return
	end

	-- a result list ends at its last row; only a page that can scroll needs room for the fade
	local contentHeight = y + (if self.sections[1] and self.sections[1].flat then FLAT_BOTTOM else BOTTOM)
	if self._emptyText then
		contentHeight = math.max(contentHeight, 54)
	end
	frame.CanvasSize = UDim2.fromOffset(0, contentHeight)
	-- a shorter page clamps the canvas at once; the scroll spring has to agree or the next wheel notch is swallowed
	local limit = math.max(contentHeight - frame.AbsoluteSize.Y / scale, 0)
	if self._scrollTarget and self._scrollTarget > limit then
		self._scrollTarget = limit
		self._scroll:snap(limit)
	end
	self._contentHeight = contentHeight
	self._placements = placements
	self._width = width
	if expansion then
		local target = UDim2.fromOffset(0, expansion.y or 0)
		if self._live then
			expansion.at:to(target)
		else
			expansion.at:snap(target)
		end
		expansion.frame.Size = UDim2.new(1, 0, 0, expansion.frame.Size.Y.Offset)
	end
	self:_applyPlacements()
	self:_materialize(true)
	self:_refreshThumb()
	if self.active then
		self.window:_contentChanged(contentHeight, self._live)
	end
	self._live = false
	self._settled = self._settled or self.active
end

-- options open and close by their height, in step with the rows below sliding: the column unfolds
local function growTo(view: any, height: number, done: (() -> ())?)
	if view._grow == nil then
		view._grow = view:own(motion.prop(view.root, "Size", SLIDE_SPEED))
	end
	view._grow:to(UDim2.new(1, 0, 0, height), done)
end

local function setHeight(view: any, height: number)
	local size = UDim2.new(1, 0, 0, height)
	if view._grow then
		view._grow:snap(size)
	else
		view.root.Size = size
	end
end

function Page._applyPlacements(self: any)
	local placed = {}
	for _, item in self._placements do
		if item.section then
			placed[item.section] = true
			local header = self._headers[item.section]
			if header then
				header.Visible = true
				header.Size = UDim2.new(1, 0, 0, item.height)
				local target = UDim2.fromOffset(0, item.y)
				local slide = self._headerSlides[item.section]
				if self._live and header.Position ~= target then
					if slide == nil then
						slide = motion.prop(header, "Position", SLIDE_SPEED)
						self._headerSlides[item.section] = slide
					end
					slide:to(target)
				elseif slide then
					slide:snap(target)
				else
					header.Position = target
				end
			end
		else
			placed[item.el] = true
			local view = self._views[item.el]
			if view then
				self:_place(view, item)
			end
		end
	end
	for key, header in self._headers do
		if not placed[key] then
			header.Visible = false
		end
	end
	for key, view in self._views do
		if not placed[key] and view.root.Visible and not view._folding then
			if self._live then
				view._folding = true
				growTo(view, 0, function()
					view._folding = false
					view.root.Visible = false
				end)
			else
				view.root.Visible = false
			end
		end
	end
end

function Page._place(self: any, view: any, item: any)
	local root = view.root
	local target = UDim2.fromOffset(0, item.y)
	local live = self._live
	local revealing = live and not root.Visible
	local refolding = view._folding == true
	view._folding = false
	root.Visible = true

	if revealing then
		setHeight(view, 0)
		growTo(view, item.height)
	elseif refolding then
		growTo(view, item.height)
	else
		setHeight(view, item.height)
	end

	if live and not revealing and root.Position ~= target then
		if view._slide == nil then
			view._slide = view:own(motion.prop(root, "Position", SLIDE_SPEED))
		end
		view._slide:to(target)
	elseif view._slide then
		view._slide:snap(target)
	else
		root.Position = target
	end
end

function Page._materialize(self: any, force: boolean?)
	local frame = self.frame
	local placements = self._placements
	if frame == nil or placements == nil or not self.active then
		return
	end
	local scale = self.window.ctx.uiScale()
	local top = frame.CanvasPosition.Y / scale
	if not force and self._lastSync and math.abs(top - self._lastSync) < NEAR / 3 then
		return
	end
	self._lastSync = top
	local lo, hi = top - NEAR, top + frame.AbsoluteSize.Y / scale + NEAR
	for _, item in placements do
		local y = item.y
		if y + item.height >= lo and y <= hi then
			if item.section then
				if self._headers[item.section] == nil then
					local header = buildHeader(self, item.section)
					header.Position = UDim2.fromOffset(0, y)
					header.Size = UDim2.new(1, 0, 0, item.height)
					self._headers[item.section] = header
				end
			elseif self._views[item.el] == nil then
				-- a search may have claimed it last, and the row is built differently on a flat list
				item.el._shownOn = self
				local ok, view = xpcall(kinds.build, debug.traceback, self.window.ctx, item.el)
				if ok then
					view.root.Position = UDim2.fromOffset(0, y)
					view.root.Size = UDim2.new(1, 0, 0, if self._live then 0 else item.height)
					view.root.Parent = self.canvas
					self._views[item.el] = view
					self._rows[view.root] = item.el
					if self._live then
						growTo(view, item.height)
					end
				else
					warn("sottUI: row " .. tostring(item.el.id) .. " failed: " .. tostring(view))
				end
			end
		end
	end
end

-- the inline counterpart of a popover: same handle, so the list and picker code does not know which it got
function Page.expand(self: any, anchor: any, height: number, build: (content: any, handle: any) -> ()): boolean
	local node = anchor
	local el = nil
	while node and node ~= self.canvas do
		if self._rows[node] then
			el = self._rows[node]
			break
		end
		node = node.Parent
	end
	if el == nil then
		return false
	end
	local previous = self._expansion
	self:collapse()
	if previous and previous.el == el then
		return true
	end
	local ctx = self.window.ctx
	local frame = make("Frame", {
		Name = "Expansion",
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 0,
		ClipsDescendants = true,
		ZIndex = 2,
		Parent = self.canvas,
	})
	ctx.theme:paint(frame, "BackgroundColor3", "base")
	local content = make("Frame", { Size = UDim2.new(1, 0, 0, height), Parent = frame })
	local expansion: any = {
		el = el,
		frame = frame,
		height = height,
		at = motion.prop(frame, "Position", SLIDE_SPEED),
		grow = motion.prop(frame, "Size", EXPAND_SPEED),
	}
	self._expansion = expansion
	local handle = {
		close = function()
			if self._expansion == expansion then
				self:collapse()
			end
		end,
		resize = function(newHeight: number)
			if self._expansion ~= expansion or expansion.height == newHeight then
				return
			end
			expansion.height = newHeight
			content.Size = UDim2.new(1, 0, 0, newHeight)
			expansion.grow:to(UDim2.new(1, 0, 0, newHeight))
			self:_invalidate()
		end,
		onKey = function(fn: (string) -> ())
			expansion.onKey = fn
		end,
		onRefresh = function(fn: () -> ())
			expansion.onRefresh = fn
		end,
	}
	self:layout(true)
	expansion.at:snap(UDim2.fromOffset(0, expansion.y or 0))
	build(content, handle)
	expansion.grow:to(UDim2.new(1, 0, 0, height))
	-- a list opened near the bottom scrolls itself into view rather than opening off screen
	local scale = ctx.uiScale()
	local viewport = self.frame.AbsoluteSize.Y / scale
	local top = self._scrollTarget or self.frame.CanvasPosition.Y / scale
	local bottom = (expansion.y or 0) + height
	if bottom > top + viewport then
		self:scrollTo(bottom - viewport + 12)
	end
	return true
end

function Page.collapse(self: any)
	local expansion = self._expansion
	if expansion == nil then
		return
	end
	self._expansion = nil
	expansion.grow:to(UDim2.new(1, 0, 0, 0), function()
		expansion.grow:destroy()
		expansion.at:destroy()
		expansion.frame:Destroy()
	end)
	self:layout(true)
end

function Page.expansionKey(self: any, name: string): boolean
	local expansion = self._expansion
	if expansion == nil then
		return false
	end
	if name == "Escape" then
		self:collapse()
		return true
	end
	-- only what a list answers to: anything else, Ctrl+K included, belongs to the window
	if expansion.onKey and (name == "Up" or name == "Down" or name == "Return") then
		expansion.onKey(name)
		return true
	end
	return false
end

function Page.pointerInExpansion(self: any, at: Vector2): boolean
	local expansion = self._expansion
	if expansion == nil then
		return false
	end
	local origin, extent = expansion.frame.AbsolutePosition, expansion.frame.AbsoluteSize
	return at.X >= origin.X and at.Y >= origin.Y and at.X <= origin.X + extent.X and at.Y <= origin.Y + extent.Y
end

function Page._refreshThumb(self: any)
	local thumb = self.thumb
	if thumb == nil then
		return
	end
	local scale = self.window.ctx.uiScale()
	local viewport = self.frame.AbsoluteSize.Y / scale
	local content = self._contentHeight or 0
	if content <= viewport + 1 or not self.active then
		thumb.Visible = false
		return
	end
	-- shows while something is moving, then gets out of the way: at rest it would sit across the mint bands
	thumb.Visible = true
	self._thumbStamp = (self._thumbStamp or 0) + 1
	local stamp = self._thumbStamp
	task.delay(THUMB_LINGER, function()
		if self._thumbStamp == stamp and not self.destroyed then
			thumb.Visible = false
		end
	end)
	local height = math.max(viewport * viewport / content, 40)
	local travel = viewport - height
	local top = self.frame.CanvasPosition.Y / scale / math.max(content - viewport, 1)
	thumb.Size = UDim2.new(0, 2, 0, height)
	thumb.Position = UDim2.new(1, -4, 0, top * travel)
end

function Page.scrollTo(self: any, y: number, instant: boolean?)
	local frame = self.frame
	if frame == nil then
		return
	end
	local scale = self.window.ctx.uiScale()
	local limit = math.max((self._contentHeight or 0) - frame.AbsoluteSize.Y / scale, 0)
	local target = math.clamp(y, 0, limit)
	self._scrollTarget = target
	if instant then
		self._scroll:snap(target)
	else
		self._scroll:to(target)
	end
end

function Page.wheel(self: any, delta: number)
	if self.frame == nil or self.frame.ScrollingEnabled then
		return
	end
	local current = self._scrollTarget or self.frame.CanvasPosition.Y / self.window.ctx.uiScale()
	self:scrollTo(current - delta * WHEEL_STEP)
end

function Page.rowY(self: any, el: any): number?
	if self._placements == nil then
		self:layout()
	end
	for _, item in self._placements or {} do
		if item.el == el then
			return item.y
		end
	end
	return nil
end

function Page.viewOf(self: any, el: any): any
	return self._views[el]
end

function Page.mount(self: any, host: any)
	if self.frame then
		return
	end
	local ctx = self.window.ctx
	local frame = make("ScrollingFrame", {
		Name = self.name,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		-- a mouse gets the spring below; native scrolling handles touch inertia far better than anything in Lua
		ScrollingEnabled = ctx.touch,
		Parent = host,
	})
	local canvas = make("Frame", { Name = "Canvas", Size = UDim2.fromScale(1, 1), Parent = frame })
	local thumb = make("Frame", {
		Name = "Thumb",
		BackgroundTransparency = 0,
		Visible = false,
		ZIndex = 5,
		Parent = host,
	})
	ctx.theme:paint(thumb, "BackgroundColor3", "lineStrong")
	self.frame = frame
	self.canvas = canvas
	self.thumb = thumb
	self._scroll = motion.new(0, SCROLL_SPEED, function(y: number)
		frame.CanvasPosition = Vector2.new(0, y * ctx.uiScale())
	end)
	frame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		self:_materialize()
		self:_refreshThumb()
	end)
	local lastWidth = 0
	frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		local width = frame.AbsoluteSize.X
		if width ~= lastWidth then
			lastWidth = width
			self._quiet = true
			self:_invalidate()
		else
			self:_materialize(true)
			self:_refreshThumb()
		end
	end)
end

-- this page's rows are whatever it is handed, wherever they live: search results, what is on. a row found here is the
-- same element as on its own page, with a view of its own
function Page.showList(self: any, list: { any }, empty: string?)
	self.sections = { { title = "", rows = list, flat = true } }
	for _, el in list do
		el._shownOn = self
	end
	self._emptyText = empty
	if self.frame then
		if self._empty == nil then
			local theme = self.window.ctx.theme
			self._empty = make("TextLabel", {
				Position = UDim2.fromOffset(rowModule.PAD, 8),
				Size = UDim2.new(1, -2 * rowModule.PAD, 0, 36),
				TextSize = 17,
				Parent = self.frame,
			})
			theme:type(self._empty, "text")
			theme:paint(self._empty, "TextColor3", "faint")
		end
		self._empty.Text = empty or ""
		self._empty.Visible = empty ~= nil
	end
	self:_invalidate()
end

-- a row's model redraws through one view; whichever page is showing owns it
function Page.adopt(self: any)
	for el, view in self._views do
		el._view = view
		el._shownOn = self
		-- flipped while another page's view owned it
		if view.refresh then
			view.refresh()
		end
	end
end

function Page.setActive(self: any, active: boolean)
	self.active = active
	if self.frame then
		self.frame.Visible = active
		if not active then
			self.thumb.Visible = false
		end
	end
	if active then
		self:layout()
	end
end

function Page.destroy(self: any)
	self.destroyed = true
	for _, view in self._views do
		view.destroy()
	end
	self._views = {}
	for _, slide in self._headerSlides do
		slide:destroy()
	end
	if self._expansion then
		self._expansion.grow:destroy()
		self._expansion.at:destroy()
	end
	if self._scroll then
		self._scroll:destroy()
	end
	if self.frame then
		self.frame:Destroy()
		self.thumb:Destroy()
	end
end

function page.new(window: any, name: string): any
	return setmetatable({
		name = name,
		window = window,
		sections = {},
		active = false,
		destroyed = false,
		_ids = 0,
		_dirty = false,
		_headers = {},
		_headerSlides = {},
		_views = {},
		_rows = {},
		_placements = nil,
	}, Page)
end

return page
