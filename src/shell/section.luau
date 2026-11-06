--!strict
-- a titled run of settings. a section only appends models; the page decides when any of them become instances

local element = require("../model/element")

local section = {}

export type Spec = { [string]: any }

local Section = {}
Section.__index = Section

local function add(self: any, kind: element.Kind, id: string?, label: string, spec: Spec, default: any): any
	local el = element.new(kind, id or (kind .. "#" .. tostring(self._page:nextId())), label, spec, default)
	el.section = self
	el.guard = self._guard
	self._page:_register(el, id ~= nil)
	table.insert(self.rows, el)
	self._page:_invalidate()
	return el
end

function Section.toggle(self: any, id: string, spec: Spec): any
	local el = add(self, "toggle", id, spec.label or id, spec, spec.default == true)
	if spec.onChanged then
		el:on(spec.onChanged)
	end
	return el
end

function Section.slider(self: any, id: string, spec: Spec): any
	spec.min = spec.min or 0
	spec.max = spec.max or 100
	spec.step = spec.step or 1
	if spec.decimals == nil then
		local text = string.format("%.10f", spec.step)
		local fraction = string.match(text, "%.(%d-)0*$")
		spec.decimals = if fraction then #fraction else 0
	end
	local el = add(self, "slider", id, spec.label or id, spec, spec.default or spec.min)
	if spec.onChanged then
		el:on(spec.onChanged)
	end
	return el
end

function Section.dropdown(self: any, id: string, spec: Spec): any
	spec.options = spec.options or {}
	local default = spec.default
	if default == nil and spec.multi then
		default = {}
	end
	local el = add(self, "dropdown", id, spec.label or id, spec, default)
	if spec.onChanged then
		el:on(spec.onChanged)
	end
	return el
end

function Section.input(self: any, id: string, spec: Spec): any
	local el = add(self, "input", id, spec.label or "", spec, spec.default or "")
	if spec.onChanged then
		el:on(spec.onChanged)
	end
	return el
end

function Section.key(self: any, id: string, spec: Spec): any
	local el = add(self, "key", id, spec.label or id, spec, {
		key = spec.default or "None",
		mode = spec.mode or "Toggle",
		modifiers = spec.modifiers or {},
	})
	self._page.window.keys:register(el)
	return el
end

function Section.color(self: any, id: string, spec: Spec): any
	local el = add(self, "color", id, spec.label or id, spec, { color = spec.default or Color3.new(1, 1, 1), alpha = spec.alphaValue or 0 })
	if spec.onChanged then
		el:on(spec.onChanged)
	end
	return el
end

function Section.button(self: any, label: string, spec: Spec | (() -> ())): any
	local options: Spec = if type(spec) == "function" then { onPressed = spec } else spec
	options.saved = false
	local el = add(self, "button", nil, label, options, nil)
	if options.onPressed then
		el:on(options.onPressed)
	end
	return el
end

function Section.label(self: any, text: string, spec: Spec?): any
	local options: Spec = spec or {}
	options.saved = false
	return add(self, "label", nil, text, options, text)
end

-- a read only figure at tile scale: kills, gold an hour, time in run
function Section.stat(self: any, label: string, value: any): any
	return add(self, "stat", nil, label, { saved = false }, tostring(value))
end

function Section.divider(self: any, text: string?): any
	return add(self, "divider", nil, text or "", { saved = false }, nil)
end

-- an addon renders in its host's row and owes the page no slot of its own. it stays out of `rows` on purpose
function Section.addKey(self: any, host: any, id: string, spec: Spec): any
	local el = element.new("key", id, spec.label or host.label, spec, {
		key = spec.default or "None",
		mode = spec.mode or "Toggle",
		modifiers = spec.modifiers or {},
	})
	el.section = self
	local keyed: any = el
	keyed.toggled = spec.toggled == true
	self._page:_register(el, true)
	self._page.window.keys:register(el)
	host:attach(el)
	return el
end

function Section.addColor(self: any, host: any, id: string, spec: Spec): any
	local el = element.new("color", id, spec.label or host.label, spec, {
		color = spec.default or Color3.new(1, 1, 1),
		alpha = spec.alphaValue or 0,
	})
	el.section = self
	self._page:_register(el, true)
	host:attach(el)
	if spec.onChanged then
		el:on(spec.onChanged)
	end
	return el
end

-- rows added through the returned section show only while predicate holds. sources are the elements it reads: those
-- changing is what makes the page lay out again, nothing polls
function Section.when(self: any, predicate: () -> boolean, sources: { any }?): any
	local parent = self._guard
	local guard = predicate
	if parent then
		guard = function()
			return parent() and predicate()
		end
	end
	local child = setmetatable({
		rows = self.rows,
		title = self.title,
		_page = self._page,
		_guard = guard,
		_root = self._root or self,
	}, Section)
	for _, source in (sources or {}) :: { any } do
		source:on(function()
			self._page:_invalidate()
		end)
	end
	return child
end

function section.new(page: any, title: string): any
	return setmetatable({
		title = title,
		rows = {},
		_page = page,
		_guard = nil,
		_root = nil,
	}, Section)
end

return section
