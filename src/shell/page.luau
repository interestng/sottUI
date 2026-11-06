--!strict
-- a page is sections in two columns, each section dropped into whichever column is shorter. placing is one pass of
-- arithmetic with no layout objects; a row's instances are built the first time it scrolls near view

local kinds = require("../view/kinds")
local make = require("../core/make")
local metrics = require("../core/metrics")
local motion = require("../core/motion")
local sectionModule = require("./section")

local page = {}

local SIDE = 14
local TOP = 14
local BOTTOM = 14
local GAP = 12
local ONE_COLUMN_BELOW = 560
local CARD_PAD = 6
local CARD_RADIUS = 14
local HEAD = 42
local ROW_GAP = 3
local TITLE = 16
local TAB_TEXT = 14
local TAB_GAP = 16
local HERO = 136
local NEAR = 360
local WHEEL_STEP = 110
local SCROLL_SPEED = 24
local SLIDE_SPEED = 26
local LIVE_SPEED = 18
local ENTER_SPEED = 24
local ENTER_FROM = 10
local WASH_HEIGHT = 84
local THUMB = 3
local THUMB_INSET = 4
local THUMB_MIN = 40

local Page = {}
Page.__index = Page

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

-- several sections sharing one card, the title being their switcher. tabs may be added one at a time
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

-- the person, large, across the top of a page. userId shows their avatar; the text can change while it is up
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

local function card(theme: any, parent: any, name: string): (any, any)
	local root = make("Frame", {
		Name = name,
		BackgroundTransparency = 0,
		ZIndex = 0,
		Parent = parent,
	})
	make("UICorner", { CornerRadius = UDim.new(0, CARD_RADIUS), Parent = root })
	theme:paint(root, "BackgroundColor3", "surface")
	local edge = make("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Thickness = 1, Parent = root })
	theme:paint(edge, "Color", "line")
	return root, edge
end

local function buildHero(self: any): any
	local ctx = self.window.ctx
	local theme = ctx.theme
	local options = self._hero
	local root = card(theme, self.canvas, "Hero")
	root.ClipsDescendants = true
	local glow = make("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 72, 0.5, 0),
		Size = UDim2.fromOffset(300, 300),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ImageTransparency = 0.68,
		Parent = root,
	})
	theme:paint(glow, "ImageColor3", "accent")
	ctx.art(glow, "glow.png")
	if options.userId then
		local bust = make("ImageLabel", {
			Position = UDim2.fromOffset(4, 4),
			Size = UDim2.fromOffset(136, 136),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = string.format("rbxthumb://type=AvatarBust&id=%d&w=420&h=420", options.userId),
			Parent = root,
		})
		-- a bust is cut flat at the chest; let it sink into the dark instead
		make("UIGradient", {
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.75, 0),
				NumberSequenceKeypoint.new(1, 1),
			}),
			Parent = bust,
		})
	end
	local name = make("TextLabel", {
		Position = UDim2.fromOffset(156, 44),
		Size = UDim2.new(1, -172, 0, 34),
		TextSize = 28,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 2,
		Parent = root,
	})
	theme:type(name, "display")
	theme:paint(name, "TextColor3", "text")
	local line = make("TextLabel", {
		Position = UDim2.fromOffset(156, 78),
		Size = UDim2.new(1, -172, 0, 22),
		TextSize = 15,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 2,
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
			local width = math.ceil(metrics.width("textMedium", name, TAB_TEXT)) + TAB_GAP
			local button = make("TextButton", {
				Position = UDim2.fromOffset(x, 0),
				Size = UDim2.new(0, width, 1, 0),
				TextSize = TAB_TEXT,
				Text = name,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = holder,
			})
			theme:type(button, "text", true)
			labels[index] = button
			button.Activated:Connect(function()
				section.activeTab = index
				for i, label in labels do
					ctx.tint(label, "TextColor3", if i == section.activeTab then "text" else "muted")
				end
				self:_invalidate()
			end)
			theme:paint(button, "TextColor3", if index == section.activeTab then "text" else "muted")
			x += width
		end
		return holder
	end
	local title = make("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		TextSize = TITLE,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = section.title,
		Parent = holder,
	})
	theme:type(title, "display")
	theme:paint(title, "TextColor3", "text")
	return holder
end

-- a section's card; one that is switched on carries a soft wash of mint under its title and a mint edge
local function buildCard(self: any, section: any): any
	local ctx = self.window.ctx
	local theme = ctx.theme
	local root, edge = card(theme, self.canvas, "Card")
	local built: any = { root = root }
	local master = section.masterElement
	if master then
		local on = master.value == true
		local wash = make("Frame", {
			Size = UDim2.new(1, 0, 0, WASH_HEIGHT),
			BackgroundTransparency = if on then 0 else 1,
			ZIndex = 0,
			Parent = root,
		})
		make("UICorner", { CornerRadius = UDim.new(0, CARD_RADIUS), Parent = wash })
		theme:paint(wash, "BackgroundColor3", "accentDim")
		make("UIGradient", {
			Rotation = 90,
			Transparency = NumberSequence.new(0.25, 1),
			Parent = wash,
		})
		theme:paint(edge, "Color", if on then "accentDim" else "line")
		local spring = motion.prop(wash, "BackgroundTransparency", LIVE_SPEED)
		local disconnect = master:on(function()
			local lit = master.value == true
			if self.active then
				spring:to(if lit then 0 else 1)
				ctx.tint(edge, "Color", if lit then "accentDim" else "line")
			else
				spring:snap(if lit then 0 else 1)
				theme:paint(edge, "Color", if lit then "accentDim" else "line")
			end
		end)
		built.destroy = function()
			disconnect()
			spring:destroy()
		end
	end
	return built
end

function Page.layout(self: any, live: boolean?)
	local frame = self.frame
	if frame == nil then
		return
	end
	-- the first layout builds the page, nothing has anywhere to animate from
	self._live = live == true and self._settled == true and self.active
	local scale = self.window.ctx.uiScale()
	local width = frame.AbsoluteSize.X / scale
	if width < 1 then
		return
	end
	local inner = width - 2 * SIDE
	local flat = self.sections[1] ~= nil and self.sections[1].flat == true
	local count = if inner < ONE_COLUMN_BELOW or flat then 1 else 2
	local cardWidth = (inner - GAP * (count - 1)) / count
	local placements: { any } = {}

	local top = TOP
	if self._hero then
		table.insert(placements, { hero = true, x = SIDE, y = top, width = inner, height = HERO })
		top += HERO + GAP
	end
	local heights = table.create(count, top)

	for _, section in self.sections do
		local master = if section.flat then nil else section.masterElement
		local titled = master ~= nil or (section.title ~= nil and section.title ~= "") or section.tabNames ~= nil
		local rowWidth = cardWidth - 2 * CARD_PAD
		local rows: { any } = {}
		local body = 0
		for _, el in section.rows do
			if el ~= master and (section.flat or el:shown()) then
				local height = kinds.measure(el, rowWidth)
				table.insert(rows, { el = el, height = height })
				body += height + ROW_GAP
			end
		end
		if #rows == 0 and not titled then
			continue
		end
		local column = 1
		for index = 2, count do
			if heights[index] < heights[column] - 0.5 then
				column = index
			end
		end
		local x = SIDE + (column - 1) * (cardWidth + GAP)
		local y = heights[column]
		local height = (if titled then HEAD else CARD_PAD) + body + (if #rows > 0 then CARD_PAD - ROW_GAP else 0)
		table.insert(placements, { card = section, x = x, y = y, width = cardWidth, height = height })
		if master then
			kinds.measure(master, rowWidth)
			-- on the rows' own edges, so a title and its switch line up with what is under them
			table.insert(placements, { el = master, x = x + CARD_PAD, y = y, width = rowWidth, height = HEAD })
		elseif titled then
			table.insert(placements, {
				section = section,
				x = x + CARD_PAD + 12,
				y = y,
				width = cardWidth - 2 * (CARD_PAD + 12),
				height = HEAD,
			})
		end
		local rowY = y + (if titled then HEAD else CARD_PAD)
		for _, row in rows do
			table.insert(placements, {
				el = row.el,
				x = x + CARD_PAD,
				y = rowY,
				width = rowWidth,
				height = row.height,
			})
			rowY += row.height + ROW_GAP
		end
		heights[column] = y + height + GAP
	end

	local contentHeight = top
	for _, height in heights do
		contentHeight = math.max(contentHeight, height)
	end
	contentHeight += BOTTOM - GAP
	frame.CanvasSize = UDim2.fromOffset(0, contentHeight)
	self._contentHeight = contentHeight
	-- a shorter page clamps the canvas at once; the scroll spring has to agree or the next wheel notch is swallowed
	local limit = math.max(contentHeight - frame.AbsoluteSize.Y / scale, 0)
	if self._scrollTarget and self._scrollTarget > limit then
		self._scrollTarget = limit
	end
	self._placements = placements
	self:_applyPlacements()
	self:_materialize(true)
	self:_refreshThumb()
	self._live = false
	self._settled = self._settled or self.active
end

local function setRect(view: any, width: number, height: number)
	local size = UDim2.fromOffset(width, height)
	if view._grow then
		view._grow:snap(size)
	else
		view.root.Size = size
	end
end

-- things slide to their new place and grow out of nothing, so a rule on a setting never makes the page jump
local function growTo(view: any, width: number, height: number, done: (() -> ())?)
	if view._grow == nil then
		view._grow = view:own(motion.prop(view.root, "Size", SLIDE_SPEED))
	end
	view._grow:to(UDim2.fromOffset(width, height), done)
end

function Page._applyPlacements(self: any)
	local placed = {}
	local cardsPlaced = {}
	for _, item in self._placements do
		if item.hero then
			if self._heroView then
				self._heroView.root.Position = UDim2.fromOffset(item.x, item.y)
				self._heroView.root.Size = UDim2.fromOffset(item.width, item.height)
			end
		elseif item.card then
			cardsPlaced[item.card] = true
			local built = self._cards[item.card]
			if built then
				built.root.Visible = true
				local position = UDim2.fromOffset(item.x, item.y)
				local size = UDim2.fromOffset(item.width, item.height)
				if self._live then
					if built.at == nil then
						built.at = motion.prop(built.root, "Position", SLIDE_SPEED)
						built.size = motion.prop(built.root, "Size", SLIDE_SPEED)
					end
					built.at:to(position)
					built.size:to(size)
				elseif built.at then
					built.at:snap(position)
					built.size:snap(size)
				else
					built.root.Position = position
					built.root.Size = size
				end
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
			-- a pick that outgrew its segments needs a different control
			if view and view.form ~= kinds.form(item.el) then
				view.destroy()
				self._views[item.el] = nil
			elseif view then
				self:_place(view, item)
			end
		end
	end
	for key, header in self._headers do
		if not placed[key] then
			header.Visible = false
		end
	end
	for key, built in self._cards do
		if not cardsPlaced[key] then
			built.root.Visible = false
		end
	end
	for key, view in self._views do
		if not placed[key] and view.root.Visible and not view._folding then
			if self._live then
				view._folding = true
				growTo(view, view.root.Size.X.Offset, 0, function()
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
	local target = UDim2.fromOffset(item.x, item.y)
	local live = self._live
	local revealing = live and not root.Visible
	local refolding = view._folding == true
	view._folding = false
	root.Visible = true

	if revealing then
		setRect(view, item.width, 0)
		growTo(view, item.width, item.height)
	elseif refolding or (live and root.Size ~= UDim2.fromOffset(item.width, item.height)) then
		growTo(view, item.width, item.height)
	else
		setRect(view, item.width, item.height)
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
	-- CanvasPosition is in scaled screen pixels, everything here is in the rows' own units
	local scale = self.window.ctx.uiScale()
	local at = frame.CanvasPosition.Y / scale
	if not force and self._lastSync and math.abs(at - self._lastSync) < NEAR / 3 then
		return
	end
	self._lastSync = at
	local lo, hi = at - NEAR, at + frame.AbsoluteSize.Y / scale + NEAR
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
			elseif item.card then
				if self._cards[item.card] == nil then
					local built = buildCard(self, item.card)
					built.root.Position = UDim2.fromOffset(item.x, y)
					built.root.Size = UDim2.fromOffset(item.width, item.height)
					self._cards[item.card] = built
				end
			elseif item.section then
				if self._headers[item.section] == nil then
					local header = buildHeader(self, item.section)
					header.Position = UDim2.fromOffset(item.x, y)
					header.Size = UDim2.fromOffset(item.width, item.height)
					self._headers[item.section] = header
				end
			elseif self._views[item.el] == nil then
				item.el._shownOn = self
				local ok, view = xpcall(kinds.build, debug.traceback, self.window.ctx, item.el)
				if ok then
					view.root.Position = UDim2.fromOffset(item.x, y)
					view.root.Size = UDim2.fromOffset(item.width, if self._live then 0 else item.height)
					view.root.Parent = self.canvas
					self._views[item.el] = view
					if self._live then
						growTo(view, item.width, item.height)
					end
				else
					warn("sottUI: row " .. tostring(item.el.id) .. " failed: " .. tostring(view))
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
	local track = viewport - 2 * TOP
	local height = math.max(track * viewport / content, THUMB_MIN)
	local travel = track - height
	local at = self.frame.CanvasPosition.Y / scale / math.max(content - viewport, 1)
	thumb.Size = UDim2.fromOffset(THUMB, height)
	thumb.Position = UDim2.new(1, -(THUMB + THUMB_INSET), 0, TOP + at * travel)
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
	make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = thumb })
	ctx.theme:paint(thumb, "BackgroundColor3", "lineStrong")
	self.frame = frame
	self.canvas = canvas
	self.thumb = thumb
	self._scroll = motion.new(0, SCROLL_SPEED, function(y: number)
		frame.CanvasPosition = Vector2.new(0, y * ctx.uiScale())
	end)
	self._enter = motion.prop(canvas, "Position", ENTER_SPEED)
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

-- a page whose rows are other pages' elements: what was searched
function Page.showList(self: any, list: { any }, empty: string?)
	self.sections = { { title = "", rows = list, flat = true } }
	for _, el in list do
		el._shownOn = self
	end
	if self.frame then
		if self._empty == nil then
			local theme = self.window.ctx.theme
			self._empty = make("TextLabel", {
				Position = UDim2.fromOffset(SIDE + 12, TOP + 6),
				Size = UDim2.new(1, -2 * (SIDE + 12), 0, 26),
				TextSize = 15,
				ZIndex = 2,
				Parent = self.frame,
			})
			theme:type(self._empty, "text")
			theme:paint(self._empty, "TextColor3", "muted")
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
		for addon, chip in view.addonChips or {} do
			addon._view = chip
			if chip.refresh then
				chip.refresh()
			end
		end
	end
end

function Page.setActive(self: any, active: boolean, instant: boolean?)
	self.active = active
	if self.frame then
		self.frame.Visible = active
		if not active then
			self.thumb.Visible = false
		end
	end
	if active then
		self:layout()
		if self._enter then
			if instant then
				self._enter:snap(UDim2.new())
			else
				self._enter:snap(UDim2.fromOffset(0, ENTER_FROM))
				self._enter:to(UDim2.new())
			end
		end
	end
end

function Page.destroy(self: any)
	self.destroyed = true
	for _, view in self._views do
		view.destroy()
	end
	self._views = {}
	for _, built in self._cards do
		if built.destroy then
			built.destroy()
		end
		if built.at then
			built.at:destroy()
			built.size:destroy()
		end
	end
	self._cards = {}
	if self._scroll then
		self._scroll:destroy()
		self._enter:destroy()
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
		_cards = {},
		_views = {},
		_placements = nil,
	}, Page)
end

return page
