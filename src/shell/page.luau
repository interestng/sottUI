--!strict
-- pages hold models and lay them out by arithmetic on a 12 column grid: columns stay aligned so what is on can be
-- scanned, and placing 300 tiles is one pass with no layout objects. a tile's instances are built the first time it
-- scrolls near the viewport

local kinds = require("../view/kinds")
local make = require("../core/make")
local metrics = require("../core/metrics")
local motion = require("../core/motion")
local sectionModule = require("./section")
local tileModule = require("../view/tile")

local page = {}

local GRID = 12
local NARROW_AT = 600
local GAP = 3
local SIDE = 20
local TOP = 14
local BOTTOM = 28
local HEADER = 40
local SECTION_GAP = 26
local HERO = 148
local PRIMARY_HEIGHT = 76
local STAT_HEIGHT = 66
local NEAR = 360
local WHEEL_STEP = 110
local SCROLL_SPEED = 24
local SLIDE_SPEED = 28

-- in 12ths: a three column sheet, so a column of toggles is a column however a game orders them. a narrow window doubles
-- them to two columns. text entry needs the room, and a label with a key on it is a control like any other
local SPANS: { [string]: number } = {
	toggle = 4,
	button = 4,
	key = 4,
	color = 4,
	slider = 4,
	dropdown = 4,
	stat = 3,
	input = 8,
}

local function spanOf(el: any): number?
	if el.kind == "label" and el.addons then
		return 4
	end
	return SPANS[el.kind]
end

local Page = {}
Page.__index = Page

local function textHeight(el: any, width: number): number
	if el.kind == "divider" then
		return 28
	end
	if not el.spec.wrap then
		return 32
	end
	if el._measured then
		return el._measured
	end
	-- close enough to place it; the built tile reports its real height and the page corrects itself
	local perLine = math.max(math.floor(width / 7.6), 10)
	local plain = string.gsub(el.label, "<[^>]+>", "")
	return math.ceil(#plain / perLine) * 21 + 12
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
			self:layout()
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
			-- built before this tab existed; the next layout rebuilds it with the full row
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

-- the person, large, at the top of a page. userId shows their avatar; the text can change while it is up
function Page.hero(self: any, options: { userId: number?, title: string, text: string? }): any
	self._hero = options
	self:_invalidate()
	local view = self._heroView
	return {
		set = function(_: any, title: string?, text: string?)
			options.title = title or options.title
			options.text = text or options.text
			local built = self._heroView or view
			if built then
				built.refresh()
			end
		end,
	}
end

local function buildHero(self: any): any
	local ctx = self.window.ctx
	local theme = ctx.theme
	local options = self._hero
	local root = make("Frame", { Name = "Hero", Parent = self.canvas })
	local frame = make("Frame", {
		Size = UDim2.fromOffset(HERO - 16, HERO - 16),
		BackgroundTransparency = 0,
		ClipsDescendants = true,
		Parent = root,
	})
	theme:paint(frame, "BackgroundColor3", "accent")
	if options.userId then
		make("ImageLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = string.format("rbxthumb://type=AvatarBust&id=%d&w=420&h=420", options.userId),
			Parent = frame,
		})
	end
	local name = make("TextLabel", {
		Position = UDim2.fromOffset(HERO + 2, 16),
		Size = UDim2.new(1, -(HERO + 2), 0, 68),
		TextSize = 64,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = root,
	})
	theme:type(name, "display")
	theme:paint(name, "TextColor3", "text")
	local line = make("TextLabel", {
		Position = UDim2.fromOffset(HERO + 2, 88),
		Size = UDim2.new(1, -(HERO + 2), 0, 44),
		TextSize = 17,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = root,
	})
	theme:type(line, "text")
	theme:paint(line, "TextColor3", "muted")
	local view = {
		root = root,
		refresh = function()
			name.Text = options.title
			line.Text = options.text or ""
		end,
	}
	view.refresh()
	return view
end

local function buildHeader(self: any, section: any): any
	local ctx = self.window.ctx
	local theme = ctx.theme
	local holder = make("Frame", { Name = "Header", Parent = self.canvas })
	if section.tabNames then
		local labels = {}
		local x = 0
		for index, name in section.tabNames do
			local width = math.ceil(metrics.width("textMedium", name, 18)) + 20
			local button = make("TextButton", {
				Position = UDim2.fromOffset(x, 0),
				Size = UDim2.new(0, width, 1, -8),
				TextSize = 18,
				Text = name,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = holder,
			})
			theme:type(button, "text", true)
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
			Size = UDim2.new(1, 0, 1, -8),
			TextSize = 18,
			Text = section.title,
			Parent = holder,
		})
		theme:type(title, "text", true)
		theme:paint(title, "TextColor3", "text")
	end
	return holder
end

function Page.layout(self: any)
	local frame = self.frame
	if frame == nil then
		return
	end
	local scale = self.window.ctx.uiScale()
	local width = frame.AbsoluteSize.X / scale
	if width < 1 then
		return
	end
	local inner = width - 2 * SIDE
	local narrow = inner < NARROW_AT
	local column = (inner - (GRID - 1) * GAP) / GRID
	local y = TOP
	local placements: { any } = {}

	if self._hero then
		table.insert(placements, { hero = true, x = SIDE, y = y, width = inner, height = HERO })
		y += HERO
	end

	for _, section in self.sections do
		local shown: { any } = {}
		for _, el in section.rows do
			if el:shown() then
				table.insert(shown, el)
			end
		end
		if #shown > 0 or section.tabNames then
			if section.title ~= "" or section.tabNames then
				table.insert(placements, { section = section, x = SIDE, y = y, width = inner, height = HEADER })
				y += HEADER
			end
			local line: { any }, used = {}, 0
			local function flush(final: boolean)
				if #line == 0 then
					return
				end
				local x, tallest = SIDE, 0
				for index, entry in line do
					local span = entry.span
					-- only text entry can leave a hole mid section, and a wider field is no loss. a final row stays as it is
					if index == #line and not final and entry.el.kind == "input" then
						span += GRID - used
					end
					local w = span * column + (span - 1) * GAP
					local height = entry.height
					tallest = math.max(tallest, height)
					table.insert(placements, { el = entry.el, x = x, y = y, width = w, height = height })
					x += w + GAP
				end
				y += tallest + GAP
				line, used = {}, 0
			end
			for _, el in shown do
				local base = spanOf(el)
				if base == nil then
					flush(false)
					local height = textHeight(el, inner)
					table.insert(placements, { el = el, x = SIDE, y = y, width = inner, height = height })
					y += height + GAP
				elseif el.spec.primary then
					flush(false)
					table.insert(placements, { el = el, x = SIDE, y = y, width = inner, height = PRIMARY_HEIGHT })
					y += PRIMARY_HEIGHT + GAP
				else
					local span = math.min(if narrow then base * 2 else base, GRID)
					if used + span > GRID then
						flush(false)
					end
					table.insert(line, {
						el = el,
						span = span,
						height = if el.kind == "stat" then STAT_HEIGHT else tileModule.HEIGHT,
					})
					used += span
				end
			end
			flush(true)
			y += SECTION_GAP
		end
	end

	local contentHeight = y - SECTION_GAP + BOTTOM
	frame.CanvasSize = UDim2.fromOffset(0, contentHeight)
	self._contentHeight = contentHeight
	self._placements = placements
	self:_applyPlacements()
	self:_materialize(true)
	self:_refreshThumb()
end

function Page._applyPlacements(self: any)
	local placed = {}
	for _, item in self._placements do
		if item.hero then
			if self._heroView then
				self._heroView.root.Position = UDim2.fromOffset(item.x, item.y)
				self._heroView.root.Size = UDim2.fromOffset(item.width, item.height)
			end
		elseif item.section then
			placed[item.section] = true
			local header = self._headers[item.section]
			if header then
				header.Visible = true
				header.Position = UDim2.fromOffset(item.x, item.y)
				header.Size = UDim2.fromOffset(item.width, item.height)
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
		if not placed[key] then
			view.root.Visible = false
		end
	end
end

function Page._place(self: any, view: any, item: any)
	local root = view.root
	local target = UDim2.fromOffset(item.x, item.y)
	local slide = root.Visible and root.Position ~= target and self.active
	root.Visible = true
	root.Size = UDim2.fromOffset(item.width, item.height)
	if slide then
		-- tiles below a revealed dependency slide rather than jump, which is how the eye tracks what appeared
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
	local top = frame.CanvasPosition.Y
	if not force and self._lastSync and math.abs(top - self._lastSync) < NEAR / 3 then
		return
	end
	self._lastSync = top
	local scale = self.window.ctx.uiScale()
	local lo, hi = top - NEAR, top + frame.AbsoluteSize.Y / scale + NEAR
	for _, item in placements do
		local y = item.y
		if y + item.height >= lo and y <= hi then
			if item.hero then
				if self._heroView == nil then
					local view = buildHero(self)
					view.root.Position = UDim2.fromOffset(item.x, y)
					view.root.Size = UDim2.fromOffset(item.width, item.height)
					self._heroView = view
				end
			elseif item.section then
				if self._headers[item.section] == nil then
					local header = buildHeader(self, item.section)
					header.Position = UDim2.fromOffset(item.x, y)
					header.Size = UDim2.fromOffset(item.width, item.height)
					self._headers[item.section] = header
				end
			elseif self._views[item.el] == nil then
				local ok, view = xpcall(kinds.build, debug.traceback, self.window.ctx, item.el)
				if ok then
					view.root.Position = UDim2.fromOffset(item.x, y)
					view.root.Size = UDim2.fromOffset(item.width, item.height)
					view.root.Parent = self.canvas
					self._views[item.el] = view
				else
					warn("sottUI: tile " .. tostring(item.el.id) .. " failed: " .. tostring(view))
				end
			end
		end
	end
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
	thumb.Visible = true
	local height = math.max(viewport * viewport / content, 40)
	local travel = viewport - height
	local top = self.frame.CanvasPosition.Y / math.max(content - viewport, 1)
	thumb.Size = UDim2.new(0, 3, 0, height)
	thumb.Position = UDim2.new(1, -6, 0, top * travel)
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
	self:scrollTo((self._scrollTarget or self.frame.CanvasPosition.Y) - delta * WHEEL_STEP)
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
		frame.CanvasPosition = Vector2.new(0, y)
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
			self:_invalidate()
		else
			self:_materialize(true)
			self:_refreshThumb()
		end
	end)
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
		_views = {},
		_placements = nil,
	}, Page)
end

return page
