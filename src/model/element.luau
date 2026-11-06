--!strict
-- an element's state, with no instances. the whole menu exists as these from the first frame and rows are built only
-- when scrolled near, so a config can load into a page nobody opened and building 300 settings costs table inserts

local signal = require("../core/signal")

local element = {}

export type Kind =
	"toggle"
	| "slider"
	| "dropdown"
	| "input"
	| "key"
	| "color"
	| "button"
	| "label"
	| "divider"
	| "stat"

export type Element = {
	kind: Kind,
	id: string,
	label: string,
	tip: string?,
	value: any,
	default: any,
	disabled: boolean,
	disabledTip: string?,
	visible: boolean,
	saved: boolean,
	changed: signal.Signal,
	spec: { [string]: any },
	addons: { Element }?,
	host: Element?,
	guard: (() -> boolean)?,
	section: any,
	_view: any,
	_relayout: (() -> ())?,

	set: (self: Element, value: any) -> boolean,
	reset: (self: Element) -> (),
	notify: (self: Element) -> (),
	on: (self: Element, fn: (...any) -> ()) -> () -> (),
	setLabel: (self: Element, text: string) -> (),
	setTip: (self: Element, text: string?) -> (),
	setDisabled: (self: Element, disabled: boolean, reason: string?) -> (),
	setVisible: (self: Element, visible: boolean) -> (),
	setOptions: (self: Element, options: { any }) -> (),
	isModified: (self: Element) -> boolean,
	attach: (self: Element, addon: Element) -> (),
	fire: (self: Element) -> (),
	shown: (self: Element) -> boolean,
}

local Element = {}
Element.__index = Element

local function decimals(step: number): number
	local text = string.format("%.10f", step)
	local fraction = string.match(text, "%.(%d-)0*$")
	return if fraction then #fraction else 0
end

local function roundTo(value: number, step: number): number
	if step <= 0 then
		return value
	end
	local snapped = math.round(value / step) * step
	-- format then parse so 0.1 * 3 stores as 0.3, which is what a saved config and the readout show
	return tonumber(string.format("%." .. decimals(step) .. "f", snapped)) or snapped
end

element.roundTo = roundTo

local function sameList(a: { any }, b: { any }): boolean
	if #a ~= #b then
		return false
	end
	for i = 1, #a do
		if a[i] ~= b[i] then
			return false
		end
	end
	return true
end

local function sameSet(a: { [any]: any }, b: { [any]: any }): boolean
	for key, on in a do
		if on and not b[key] then
			return false
		end
	end
	for key, on in b do
		if on and not a[key] then
			return false
		end
	end
	return true
end

-- each returns the value to store, or nil to refuse. a refused set leaves the element as it was, never half applied
local normalize: { [string]: (self: any, value: any) -> any } = {
	toggle = function(_, value)
		return value == true
	end,
	slider = function(self, value)
		local number = tonumber(value)
		if number == nil or number ~= number then
			return nil
		end
		local spec = self.spec
		return math.clamp(roundTo(number, spec.step or 1), spec.min, spec.max)
	end,
	dropdown = function(self, value)
		local spec = self.spec
		if spec.multi then
			local picks = {}
			if type(value) == "table" then
				for key, on in value do
					if type(key) == "number" then
						picks[on] = true
					elseif on then
						picks[key] = true
					end
				end
			elseif value ~= nil and value ~= "" then
				picks[value] = true
			end
			if not spec.keep then
				for pick in picks do
					if not table.find(spec.options, pick) then
						picks[pick] = nil
					end
				end
			end
			return picks
		end
		if value == nil or value == "" then
			return false
		end
		if not table.find(spec.options, value) and not spec.keep then
			return nil
		end
		return value
	end,
	input = function(self, value)
		local text = if value == nil then "" else tostring(value)
		local spec = self.spec
		if spec.maxLength and #text > spec.maxLength then
			text = string.sub(text, 1, spec.maxLength)
		end
		if spec.numeric and text ~= "" and text ~= "-" and text ~= "." and tonumber(text) == nil then
			return nil
		end
		if spec.verify and not spec.verify(text) then
			return nil
		end
		return text
	end,
	key = function(self, value)
		if type(value) == "string" then
			return { key = value, mode = self.value and self.value.mode or "Toggle", modifiers = {} }
		end
		if type(value) ~= "table" then
			return nil
		end
		local current = self.value or {}
		return {
			key = value.key or value[1] or current.key or "None",
			mode = value.mode or value[2] or current.mode or "Toggle",
			modifiers = value.modifiers or value[3] or current.modifiers or {},
		}
	end,
	color = function(self, value)
		if typeof(value) == "Color3" then
			return { color = value, alpha = self.value and self.value.alpha or 0 }
		end
		if type(value) == "table" and typeof(value.color) == "Color3" then
			return { color = value.color, alpha = math.clamp(tonumber(value.alpha) or 0, 0, 1) }
		end
		return nil
	end,
	label = function(_, value)
		return tostring(value)
	end,
	stat = function(_, value)
		return tostring(value)
	end,
}

local function equal(self: any, a: any, b: any): boolean
	local kind = self.kind
	if kind == "dropdown" and self.spec.multi then
		return sameSet(a, b)
	end
	if kind == "key" then
		return a.key == b.key and a.mode == b.mode and sameList(a.modifiers, b.modifiers)
	end
	if kind == "color" then
		return a.color == b.color and a.alpha == b.alpha
	end
	return a == b
end

local function unwrap(self: any, value: any): any
	-- a single dropdown stores false for "nothing picked" so the normalizer's nil can mean refused
	if self.kind == "dropdown" and not self.spec.multi and value == false then
		return nil
	end
	return value
end

function element.new(kind: Kind, id: string, label: string, spec: { [string]: any }, default: any): Element
	local self: any = setmetatable({
		kind = kind,
		id = id,
		label = label,
		spec = spec,
		tip = spec.tip,
		disabled = spec.disabled == true,
		disabledTip = spec.disabledTip,
		visible = spec.visible ~= false,
		saved = spec.saved ~= false,
		changed = signal.new(),
	}, Element)
	local normal = normalize[kind]
	local value = default
	if normal then
		value = normal(self, default)
		if value == nil and kind == "slider" then
			value = spec.min
		end
		if value == nil and kind == "dropdown" then
			value = false
		end
	end
	self.value = unwrap(self, value)
	self.default = self.value
	return self
end

function Element.set(self: any, value: any): boolean
	local normal = normalize[self.kind]
	local next = value
	if normal then
		next = normal(self, value)
		if next == nil then
			return false
		end
		next = unwrap(self, next)
	end
	local previous = self.value
	if previous ~= nil and next ~= nil and equal(self, previous, next) then
		return false
	end
	if previous == nil and next == nil then
		return false
	end
	self.value = next
	self:notify()
	return true
end

function Element.reset(self: any)
	local default = self.default
	if self.kind == "dropdown" and self.spec.multi then
		default = table.clone(default)
	end
	self:set(default)
end

-- a host's addons redraw with it: a keybind chip lives inside its toggle's row
local function redraw(self: any)
	local view = self._view
	if view then
		view.refresh()
	end
	local host = self.host
	if host and host._view then
		host._view.refresh()
	end
end

function Element.notify(self: any)
	redraw(self)
	self.changed:fire(self.value)
end

-- the same value again, for the callers that need a listener to run on a config load with no change
function Element.fire(self: any)
	self.changed:fire(self.value)
end

function Element.on(self: any, fn: (...any) -> ()): () -> ()
	return self.changed:connect(fn)
end

function Element.setLabel(self: any, text: string)
	if self.label == text then
		return
	end
	self.label = text
	if self.kind == "label" then
		self.value = text
		local relayout = self._relayout
		if relayout then
			relayout()
		end
	end
	redraw(self)
end

function Element.setTip(self: any, text: string?)
	self.tip = text
end

function Element.setDisabled(self: any, disabled: boolean, reason: string?)
	self.disabled = disabled == true
	self.disabledTip = reason or self.disabledTip
	redraw(self)
end

function Element.setVisible(self: any, visible: boolean)
	if self.visible == visible then
		return
	end
	self.visible = visible
	local relayout = self._relayout
	if relayout then
		relayout()
	end
end

function Element.setOptions(self: any, options: { any })
	local spec = self.spec
	spec.options = table.clone(options)
	if spec.multi then
		if spec.keep then
			for pick, on in self.value do
				if on and not table.find(spec.options, pick) then
					table.insert(spec.options, pick)
				end
			end
		else
			local dropped = false
			for pick in self.value do
				if not table.find(spec.options, pick) then
					self.value[pick] = nil
					dropped = true
				end
			end
			if dropped then
				self:notify()
				return
			end
		end
	elseif self.value ~= nil and not table.find(spec.options, self.value) then
		if spec.keep then
			table.insert(spec.options, self.value)
		else
			self.value = nil
			self:notify()
			return
		end
	end
	redraw(self)
end

function Element.isModified(self: any): boolean
	if self.kind == "button" or self.kind == "label" or self.kind == "divider" or self.kind == "stat" then
		return false
	end
	local a, b = self.value, self.default
	if a == nil or b == nil then
		return a ~= b
	end
	return not equal(self, a, b)
end

function Element.attach(self: any, addon: any)
	local addons = self.addons
	if addons == nil then
		addons = {}
		self.addons = addons
	end
	table.insert(addons, addon)
	addon.host = self
	redraw(self)
end

function Element.shown(self: any): boolean
	-- a status line with nothing to say yet would still hold a blank row open
	if not self.visible or (self.kind == "label" and self.label == "") then
		return false
	end
	local guard = self.guard
	return guard == nil or guard()
end

return element
