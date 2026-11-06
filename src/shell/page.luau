--!strict
-- a page is a desk: every section is a channel strip, side by side, and the desk scrolls sideways. faders stand at the
-- strip's left, everything else runs down columns beside them, and a section's main switch sits along its foot. placing
-- is one pass of arithmetic with no layout objects; a control's instances are built the first time it comes near view

local kinds = require("../view/kinds")
local make = require("../core/make")
local metrics = require("../core/metrics")
local motion = require("../core/motion")
local sectionModule = require("./section")

local page = {}

local STRIP_PAD = 14
local GAP = 8
local ROW_GAP = 6
local HEADER = 26
local HEADER_GAP = 10
local TITLE = 15
local TAB_TEXT = 14
local TAB_GAP = 14
local SWITCH = 38
local SWITCH_GAP = 12
local STRIP_MIN = 112
local HERO_WIDTH = 260
local EMPTY_WIDTH = 240
local NEAR = 420
local WHEEL_STEP = 150
local SCROLL_SPEED = 20
local SLIDE_SPEED = 24
local LIVE_SPEED = 18
local ENTER_SPEED = 22
local ENTER_FROM = 12
local THUMB = 3
local THUMB_INSET = 3
local THUMB_SIDE = 16

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

-- several sections sharing one strip, the title being their switcher. tabs may be added one at a time
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

-- the person, large, as the desk's first strip. userId shows their avatar; the text can change while it is up
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
	local root = make("Frame", { Name = "Hero", ClipsDescendants = true, Parent = self.canvas })
	local glow = make("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0, 130),
		Size = UDim2.fromOffset(360, 360),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ImageTransparency = 0.72,
		Parent = root,
	})
	theme:paint(glow, "ImageColor3", "accent")
	ctx.art(glow, "glow.png")
	if options.userId then
		local bust = make("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 16),
			Size = UDim2.fromOffset(232, 232),
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
				NumberSequenceKeypoint.new(0.72, 0),
				NumberSequenceKeypoint.new(1, 1),
			}),
			Parent = bust,
		})
	end
	local name = make("TextLabel", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, STRIP_PAD + 4, 1, -42),
		Size = UDim2.new(1, -2 * (STRIP_PAD + 4), 0, 30),
		TextSize = 24,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 2,
		Parent = root,
	})
	theme:type(name, "display")
	theme:paint(name, "TextColor3", "text")
	local line = make("TextLabel", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, STRIP_PAD + 4, 1, -18),
		Size = UDim2.new(1, -2 * (STRIP_PAD + 4), 0, 22),
		TextSize = 14,
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
					ctx.tint(label, "TextColor3", if i == section.activeTab then "text" else "faint")
				end
				self:_invalidate()
			end)
			theme:paint(button, "TextColor3", if index == section.activeTab then "text" else "faint")
			x += width
		end
		return holder
	end
	local master = section.masterElement
	local title = make("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		TextSize = TITLE,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = if master then master.label else section.title,
		Parent = holder,
	})
	theme:type(title, "display")
	if master then
		local function ink(instant: boolean?)
			local token = if master.value == true then "text" else "muted"
			if instant then
				theme:paint(title, "TextColor3", token)
			else
				ctx.tint(title, "TextColor3", token)
			end
		end
		ink(true)
		master:on(function()
			ink()
		end)
	else
		theme:paint(title, "TextColor3", "text")
	end
	return holder
end

-- the hairline between strips and the wash that says this strip is running
local function buildStrip(self: any, section: any, last: boolean): any
	local ctx = self.window.ctx
	local theme = ctx.theme
	local root = make("Frame", { Name = "Strip", ZIndex = 0, Parent = self.canvas })
	local rule = make("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundTransparency = 0,
		Visible = not last,
		ZIndex = 0,
		Parent = root,
	})
	theme:paint(rule, "BackgroundColor3", "line")
	local strip: any = { root = root, rule = rule }
	local master = section.masterElement
	if master then
		local wash = make("Frame", {
			Size = UDim2.fromScale(1, 0.55),
			BackgroundTransparency = if master.value == true then 0 else 1,
			ZIndex = 0,
			Parent = root,
		})
		theme:paint(wash, "BackgroundColor3", "accentDim")
		make("UIGradient", {
			Rotation = 90,
			Transparency = NumberSequence.new(0.45, 1),
			Parent = wash,
		})
		local spring = motion.prop(wash, "BackgroundTransparency", LIVE_SPEED)
		strip.spring = spring
		local disconnect = master:on(function()
			if self.active then
				spring:to(if master.value == true then 0 else 1)
			else
				spring:snap(if master.value == true then 0 else 1)
			end
		end)
		strip.destroy = function()
			disconnect()
			spring:destroy()
		end
	end
	return strip
end

-- one strip's contents, measured but not yet placed
local function planStrip(section: any, available: number): any
	local master = if section.flat then nil else section.masterElement
	local faders, flow = {}, {}
	for _, el in section.rows do
		if el == master then
			continue
		end
		if section.flat or el:shown() then
			local size = kinds.measure(el)
			if size.fader then
				table.insert(faders, { el = el, width = size.width })
			else
				table.insert(flow, { el = el, width = size.width, height = size.height })
			end
		end
	end
	local titled = master ~= nil or section.title ~= "" or section.tabNames ~= nil
	if #faders == 0 and #flow == 0 and not titled then
		return nil
	end
	local top = STRIP_PAD + (if titled then HEADER + HEADER_GAP else 0)
	local bottom = available - STRIP_PAD - (if master then SWITCH + SWITCH_GAP else 0)

	-- switches together and picks after them; a section mixing in text keeps the order it was written in
	local plainControls = true
	for _, item in flow do
		local kind = item.el.kind
		plainControls = plainControls and kind ~= "label" and kind ~= "divider" and kind ~= "stat"
	end
	if plainControls then
		local sorted, rest = {}, {}
		for _, item in flow do
			table.insert(if item.el.kind == "toggle" then sorted else rest, item)
		end
		table.move(rest, 1, #rest, #sorted + 1, sorted)
		flow = sorted
	end

	-- down a column until it runs out of room, then the next; a free width line takes its column's
	local columns: { any } = {}
	local column: any = nil
	for _, item in flow do
		if column == nil or (column.y > top and column.y + item.height > bottom) then
			column = { items = {}, y = top, width = 0 }
			table.insert(columns, column)
		end
		table.insert(column.items, item)
		column.width = math.max(column.width, item.width)
		column.y += item.height + ROW_GAP
	end

	local content = 0
	for _, fader in faders do
		content += fader.width + GAP
	end
	for _, each in columns do
		content += each.width + GAP
	end
	content = math.max(content - GAP, 0)

	local head = 0
	if section.tabNames then
		for _, name in section.tabNames do
			head += metrics.width("textMedium", name, TAB_TEXT) + TAB_GAP
		end
	elseif master then
		head = metrics.width("display", master.label, TITLE)
	else
		head = metrics.width("display", section.title, TITLE)
	end
	local inner = math.max(content, head, if master then kinds.masterWidth(master) else 0)
	return {
		section = section,
		master = master,
		titled = titled,
		faders = faders,
		columns = columns,
		top = top,
		bottom = bottom,
		width = math.max(math.ceil(inner) + 2 * STRIP_PAD, if section.flat then 0 else STRIP_MIN),
	}
end

function Page.layout(self: any, live: boolean?)
	local frame = self.frame
	if frame == nil then
		return
	end
	-- the first layout builds the page, nothing has anywhere to animate from
	self._live = live == true and self._settled == true and self.active
	local scale = self.window.ctx.uiScale()
	local height = frame.AbsoluteSize.Y / scale
	if height < 1 then
		return
	end

	local plans: { any } = {}
	local total = 0
	if self._hero then
		total += HERO_WIDTH
	end
	for _, section in self.sections do
		local plan = planStrip(section, height)
		if plan then
			table.insert(plans, plan)
			total += plan.width
		end
	end
	if self._emptyVisible then
		total = math.max(total, EMPTY_WIDTH)
	end

	-- a short page shares the spare width out, so the strips still reach the window's edge
	local spare = math.max((self.window:minContentWidth() or 0) - total, 0)
	local extra = if #plans > 0 then spare / #plans else 0

	local placements: { any } = {}
	local x = 0
	if self._hero then
		table.insert(placements, { hero = true, x = 0, y = 0, width = HERO_WIDTH, height = height })
		x = HERO_WIDTH
	end
	for index, plan in plans do
		local section = plan.section
		local width = math.floor(plan.width + extra)
		if not section.flat then
			table.insert(placements, {
				strip = section,
				last = index == #plans,
				x = x,
				y = 0,
				width = width,
				height = height,
			})
		end
		if plan.titled then
			table.insert(placements, {
				section = section,
				x = x + STRIP_PAD,
				y = STRIP_PAD,
				width = width - 2 * STRIP_PAD,
				height = HEADER,
			})
		end
		local cx = x + STRIP_PAD
		for _, fader in plan.faders do
			table.insert(placements, {
				el = fader.el,
				x = cx,
				y = plan.top,
				width = fader.width,
				height = plan.bottom - plan.top,
			})
			cx += fader.width + GAP
		end
		for _, column in plan.columns do
			local cy = plan.top
			for _, item in column.items do
				table.insert(placements, { el = item.el, x = cx, y = cy, width = column.width, height = item.height })
				cy += item.height + ROW_GAP
			end
			cx += column.width + GAP
		end
		if plan.master then
			table.insert(placements, {
				el = plan.master,
				x = x + STRIP_PAD,
				y = height - STRIP_PAD - SWITCH,
				width = width - 2 * STRIP_PAD,
				height = SWITCH,
			})
		end
		x += width
	end

	local contentWidth = math.max(x, total)
	frame.CanvasSize = UDim2.fromOffset(contentWidth, 0)
	self._contentWidth = contentWidth
	-- a shorter page clamps the canvas at once; the scroll spring has to agree or the next wheel notch is swallowed
	local limit = math.max(contentWidth - frame.AbsoluteSize.X / scale, 0)
	if self._scrollTarget and self._scrollTarget > limit then
		self._scrollTarget = limit
	end
	self._placements = placements
	-- pages lay themselves out in the background too; only the one on show may size the window
	if self.active then
		self.window:_contentChanged(contentWidth, live)
	end
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

-- things slide to their new place and grow out of nothing, so a rule on a setting never makes the desk jump
local function growTo(view: any, width: number, height: number, done: (() -> ())?)
	if view._grow == nil then
		view._grow = view:own(motion.prop(view.root, "Size", SLIDE_SPEED))
	end
	view._grow:to(UDim2.fromOffset(width, height), done)
end

function Page._applyPlacements(self: any)
	local placed = {}
	local stripsPlaced = {}
	for _, item in self._placements do
		if item.hero then
			if self._heroView then
				self._heroView.root.Position = UDim2.fromOffset(item.x, item.y)
				self._heroView.root.Size = UDim2.fromOffset(item.width, item.height)
			end
		elseif item.strip then
			stripsPlaced[item.strip] = true
			local strip = self._strips[item.strip]
			if strip then
				strip.root.Visible = true
				strip.root.Position = UDim2.fromOffset(item.x, item.y)
				strip.root.Size = UDim2.fromOffset(item.width, item.height)
				strip.rule.Visible = not item.last
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
			-- a list that outgrew its inline form needs a different control
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
	for key, strip in self._strips do
		if not stripsPlaced[key] then
			strip.root.Visible = false
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
	-- CanvasPosition is in scaled screen pixels, everything here is in the controls' own units
	local scale = self.window.ctx.uiScale()
	local left = frame.CanvasPosition.X / scale
	if not force and self._lastSync and math.abs(left - self._lastSync) < NEAR / 3 then
		return
	end
	self._lastSync = left
	local lo, hi = left - NEAR, left + frame.AbsoluteSize.X / scale + NEAR
	for _, item in placements do
		local x = item.x
		if x + item.width >= lo and x <= hi then
			if item.hero then
				if self._heroView == nil then
					local view = buildHero(self)
					view.root.Position = UDim2.fromOffset(x, item.y)
					view.root.Size = UDim2.fromOffset(item.width, item.height)
					self._heroView = view
				end
			elseif item.strip then
				if self._strips[item.strip] == nil then
					local strip = buildStrip(self, item.strip, item.last)
					strip.root.Position = UDim2.fromOffset(x, item.y)
					strip.root.Size = UDim2.fromOffset(item.width, item.height)
					self._strips[item.strip] = strip
				end
			elseif item.section then
				if self._headers[item.section] == nil then
					local header = buildHeader(self, item.section)
					header.Position = UDim2.fromOffset(x, item.y)
					header.Size = UDim2.fromOffset(item.width, item.height)
					self._headers[item.section] = header
				end
			elseif self._views[item.el] == nil then
				item.el._shownOn = self
				local ok, view = xpcall(kinds.build, debug.traceback, self.window.ctx, item.el)
				if ok then
					view.root.Position = UDim2.fromOffset(x, item.y)
					view.root.Size = UDim2.fromOffset(item.width, if self._live then 0 else item.height)
					view.root.Parent = self.canvas
					self._views[item.el] = view
					if self._live then
						growTo(view, item.width, item.height)
					end
				else
					warn("sottUI: control " .. tostring(item.el.id) .. " failed: " .. tostring(view))
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
	local viewport = self.frame.AbsoluteSize.X / scale
	local content = self._contentWidth or 0
	if content <= viewport + 1 or not self.active then
		thumb.Visible = false
		return
	end
	-- always there on a desk that scrolls: it is the only sign there are more strips off to the right
	thumb.Visible = true
	local track = viewport - 2 * THUMB_SIDE
	local width = math.max(track * viewport / content, 48)
	local travel = track - width
	local at = self.frame.CanvasPosition.X / scale / math.max(content - viewport, 1)
	thumb.Size = UDim2.fromOffset(width, THUMB)
	thumb.Position = UDim2.new(0, THUMB_SIDE + at * travel, 1, -(THUMB + THUMB_INSET))
end

function Page.scrollTo(self: any, x: number, instant: boolean?)
	local frame = self.frame
	if frame == nil then
		return
	end
	local scale = self.window.ctx.uiScale()
	local limit = math.max((self._contentWidth or 0) - frame.AbsoluteSize.X / scale, 0)
	local target = math.clamp(x, 0, limit)
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
	local current = self._scrollTarget or self.frame.CanvasPosition.X / self.window.ctx.uiScale()
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
		ScrollingDirection = Enum.ScrollingDirection.X,
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
	self._scroll = motion.new(0, SCROLL_SPEED, function(x: number)
		frame.CanvasPosition = Vector2.new(x * ctx.uiScale(), 0)
	end)
	self._enter = motion.prop(canvas, "Position", ENTER_SPEED)
	frame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		self:_materialize()
		self:_refreshThumb()
	end)
	-- the window's width follows the page, so nothing here depends on it except what is near enough to build
	frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_materialize(true)
		self:_refreshThumb()
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
				Position = UDim2.fromOffset(STRIP_PAD, STRIP_PAD),
				Size = UDim2.new(1, -2 * STRIP_PAD, 0, 26),
				TextSize = 15,
				Parent = self.frame,
			})
			theme:type(self._empty, "text")
			theme:paint(self._empty, "TextColor3", "muted")
		end
		self._empty.Text = empty or ""
		self._empty.Visible = empty ~= nil
		self._emptyVisible = empty ~= nil
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
				self._enter:snap(UDim2.fromOffset(ENTER_FROM, 0))
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
	for _, strip in self._strips do
		if strip.destroy then
			strip.destroy()
		end
	end
	self._strips = {}
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
		_strips = {},
		_views = {},
		_placements = nil,
	}, Page)
end

return page
