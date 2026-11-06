--!strict
-- a page is a wheel: every setting in a line, one in the middle at full size, the rest shrinking and fading with distance.
-- one number, the focus position, drives all of it, so turning the wheel costs a few property writes on the dozen rows
-- that can be seen. a row is built the first time it comes near

local motion = require("../core/motion")
local sectionModule = require("./section")
local wheel = require("../view/wheel")

local page = {}

local REACH = 5
local STEP = 72
local SQUEEZE = 0.05
local SIZE_STEP = 0.13
local SIZE_MIN = 0.56
local FADE_START = 0.75
local FADE_STEP = 0.22
local FOCUS_SPEED = 20
local BLEND_SPEED = 24
local MAX_WIDTH = 820

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
			self:rebuild()
		end
	end)
end

function Page.section(self: any, title: string): any
	local built = sectionModule.new(self, title)
	table.insert(self.sections, built)
	self:_invalidate()
	return built
end

-- on a wheel a tab set is just its sections in a row, each under its own heading
function Page.tabset(self: any): any
	local api = {}
	function api.tab(_: any, name: string): any
		return self:section(name)
	end
	return api
end

function Page.tabs(self: any, names: { string }): { any }
	local out = {}
	for _, name in names do
		table.insert(out, self:section(name))
	end
	return out
end

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

-- the list a heading sits in is flat: a section title is one more line to pass, not a container
local function headingFor(self: any, section: any): any
	local heading = self._headings[section]
	if heading == nil then
		heading = {
			kind = "divider",
			label = section.title,
			spec = {},
			shown = function()
				return true
			end,
			addons = nil,
			disabled = false,
		}
		self._headings[section] = heading
	end
	return heading
end

function Page.rebuild(self: any)
	local previous = self._index or {}
	local list: { any } = {}
	for _, section in self.sections do
		local rows: { any } = {}
		for _, el in section.rows do
			if el:shown() then
				table.insert(rows, el)
			end
		end
		if #rows > 0 then
			if section.title ~= "" and not section.masterElement then
				table.insert(list, headingFor(self, section))
			end
			for _, el in rows do
				table.insert(list, el)
			end
		end
	end
	local index = {}
	for i, el in list do
		index[el] = i
	end
	self._list = list
	self._index = index
	self._from = previous

	-- the row in focus holds still when things open and close around it; everything else moves relative to it
	local keep = self._focusEl
	local at = if keep then index[keep] else nil
	if at == nil then
		at = self:_firstFocusable(self._target or 1)
	end
	if at then
		self._focusEl = list[at]
		local shift = at - (previous[keep] or at)
		if self.active and shift ~= 0 then
			self._focus:snap((self._focus.target or at) + shift)
		end
		self._target = at
		self._focus:to(at)
	end
	-- rows that kept their place glide to their new index through one blend
	if self.active and self._built then
		self._blendValue = 0
		self._blend:snap(0)
		self._blend:to(1)
	else
		self._blendValue = 1
	end
	self._built = true
	self.window:_reportCount(self)
	self:place()
end

function Page._firstFocusable(self: any, near: number): number?
	local list = self._list
	if list == nil or #list == 0 then
		return nil
	end
	for distance = 1, #list do
		for _, i in { near + distance - 1, near - distance + 1 } do
			local el = list[i]
			if el and wheel.focusable(el) then
				return i
			end
		end
	end
	return math.clamp(near, 1, #list)
end

function Page.step(self: any, direction: number)
	local list = self._list
	if list == nil then
		return
	end
	local i = self._target or 1
	repeat
		i += direction
	until i < 1 or i > #list or wheel.focusable(list[i])
	if i >= 1 and i <= #list then
		self._target = i
		self._focusEl = list[i]
		self._focus:to(i)
		self:place()
	end
end

function Page.focusOn(self: any, el: any)
	local i = self._index and self._index[el]
	if i then
		self._target = i
		self._focusEl = el
		self._focus:to(i)
		self:place()
	end
end

function Page.current(self: any): any
	return self._focusEl and self._views[self._focusEl]
end

-- every frame the wheel turns: position, size and fade for what is in reach, hidden for the rest
function Page.place(self: any)
	local list = self._list
	if list == nil or not self.active then
		return
	end
	local focus = self._focusValue
	local blend = self._blendValue or 1
	local window = self.window
	local viewport = window._stage.AbsoluteSize
	local scale = window._scale.Scale
	-- wide enough for the longest words, no wider: a value far from its name has to be hunted for
	local width = math.min(viewport.X * 0.72, MAX_WIDTH) * scale
	local x = math.floor((viewport.X - width) / 2)
	local middle = viewport.Y * 0.5
	local from = self._from or {}
	local seen = {}
	for i, el in list do
		local start = from[el] or i
		local at = start + (i - start) * blend
		local d = at - focus
		local distance = math.abs(d)
		if distance <= REACH then
			local view = self._views[el]
			if view == nil then
				view = wheel.build(window.ctx, el, self)
				view.root.Parent = self.host
				self._views[el] = view
			end
			seen[el] = true
			local y = d * STEP * (1 - SQUEEZE * math.min(distance, 5)) * scale
			local size = math.max(1 - SIZE_STEP * distance, SIZE_MIN) * scale
			local fade = math.clamp((distance - FADE_START) * FADE_STEP, 0, 1)
			view.root.Visible = true
			-- divided by its own scale so every row ends at the same right edge, whatever size it is drawn at
			view.root.Size = UDim2.fromOffset(width / size, wheel.HEIGHT)
			view.place(x, middle + y, size, fade)
			view.setFocused(el == self._focusEl and distance < 0.5)
		end
	end
	for el, view in self._views do
		if not seen[el] then
			view.root.Visible = false
		end
	end
end

function Page.rowY(self: any, el: any): number?
	return self._index and self._index[el]
end

function Page.viewOf(self: any, el: any): any
	return self._views[el]
end

function Page.scrollTo(self: any, y: number, instant: boolean?)
	local list = self._list
	if list == nil then
		return
	end
	local at = self:_firstFocusable(math.clamp(y, 1, #list))
	if at then
		self._target = at
		self._focusEl = list[at]
		if instant then
			self._focus:snap(at)
		else
			self._focus:to(at)
		end
	end
end

-- a page coming onto the stage arrives by the wheel turning into place
function Page.spinIn(self: any, from: number)
	local target = self._target or 1
	self._focus:snap(target + from)
	self._focus:to(target)
	self:place()
end

function Page.mount(self: any, host: any)
	self.host = host
	self._focusValue = 1
	self._focus = motion.new(1, FOCUS_SPEED, function(value: number)
		self._focusValue = value
		self:place()
	end)
	self._blend = motion.new(1, BLEND_SPEED, function(value: number)
		self._blendValue = value
		self:place()
	end)
end

function Page.setActive(self: any, active: boolean)
	self.active = active
	if active then
		self:rebuild()
	else
		for _, view in self._views do
			view.root.Visible = false
		end
	end
end

function Page.destroy(self: any)
	self.destroyed = true
	for _, view in self._views do
		view.destroy()
	end
	self._views = {}
	if self._focus then
		self._focus:destroy()
		self._blend:destroy()
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
		_views = {},
		_headings = {},
	}, Page)
end

return page
