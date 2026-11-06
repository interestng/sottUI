--!strict
-- color and type tokens, and the bindings that retint a live window. one registry per window instead of a listener per
-- instance: a theme change walks a table once, and an element that was never built costs nothing

local signal = require("./signal")

local theme = {}

export type Tokens = {
	base: Color3,
	surface: Color3,
	raised: Color3,
	line: Color3,
	lineStrong: Color3,
	text: Color3,
	muted: Color3,
	faint: Color3,
	accent: Color3,
	accentHover: Color3,
	accentDim: Color3,
	onAccent: Color3,
	danger: Color3,
}

export type Family = "text" | "display" | "mono"

export type Theme = {
	tokens: Tokens,
	fonts: { text: any, display: any, mono: any },
	changed: signal.Signal,
	paint: (self: Theme, instance: any, property: string, token: string) -> (),
	type: (self: Theme, instance: any, family: Family, medium: boolean?) -> (),
	apply: (self: Theme, partial: { [string]: Color3 }) -> (),
	setFonts: (self: Theme, text: string?, display: string?, mono: string?) -> (),
	face: (self: Theme, family: Family, medium: boolean?) -> any,
	forget: (self: Theme, instance: any) -> (),
}

local function rgb(hex: number): Color3
	return Color3.fromRGB(
		bit32.band(bit32.rshift(hex, 16), 255),
		bit32.band(bit32.rshift(hex, 8), 255),
		bit32.band(hex, 255)
	)
end

-- near black with sottoro's mint and ink (site/src/styles/globals.css); mint only ever means "on"
local DEFAULT: Tokens = {
	base = rgb(0x050706),
	surface = rgb(0x0C0F0D),
	raised = rgb(0x151A17),
	line = rgb(0x191F1C),
	lineStrong = rgb(0x2A342F),
	text = rgb(0xEBE8DA),
	muted = rgb(0x97A39C),
	faint = rgb(0x56615B),
	accent = rgb(0x7EE0C4),
	accentHover = rgb(0x9BEBD4),
	accentDim = rgb(0x16362D),
	onAccent = rgb(0x06231B),
	danger = rgb(0xE5604D),
}

local FALLBACK_TEXT = "rbxasset://fonts/families/BuilderSans.json"
local FALLBACK_DISPLAY = "rbxasset://fonts/families/BuilderSans.json"
local FALLBACK_MONO = "rbxasset://fonts/families/RobotoMono.json"

local Theme = {}
Theme.__index = Theme

function theme.defaults(): Tokens
	return table.clone(DEFAULT)
end

function theme.new(overrides: { [string]: Color3 }?): Theme
	local tokens = theme.defaults() :: any
	for key, value in (overrides or {}) :: { [string]: Color3 } do
		tokens[key] = value
	end
	local self = {
		tokens = tokens,
		fonts = { text = FALLBACK_TEXT, display = FALLBACK_DISPLAY, mono = FALLBACK_MONO },
		changed = signal.new(),
		-- strong keys: a weak key can drop while the instance lives on once its Lua wrapper is collected, and the hairline
		-- would miss every later theme change. dead instances are swept when the table has grown
		_paints = {},
		_types = {},
		_count = 0,
	}
	return (setmetatable(self, Theme) :: any) :: Theme
end

local SWEEP_EVERY = 2000

local function sweep(self: any)
	for instance in self._paints do
		if instance.Parent == nil then
			self._paints[instance] = nil
			self._types[instance] = nil
		end
	end
	for instance in self._types do
		if instance.Parent == nil then
			self._types[instance] = nil
		end
	end
end

function Theme.paint(self: any, instance: any, property: string, token: string)
	local list = self._paints[instance]
	if list == nil then
		list = {}
		self._paints[instance] = list
		self._count += 1
		if self._count % SWEEP_EVERY == 0 then
			-- a tile not yet parented is still being built by the caller; the deferred sweep sees it placed
			task.defer(sweep, self)
		end
	end
	list[property] = token
	instance[property] = self.tokens[token]
end

function Theme.face(self: any, family: Family, medium: boolean?): any
	if family == "display" then
		return Font.new(self.fonts.display, Enum.FontWeight.SemiBold)
	end
	if family == "mono" then
		return Font.new(self.fonts.mono, Enum.FontWeight.Medium)
	end
	return Font.new(self.fonts.text, if medium then Enum.FontWeight.Medium else Enum.FontWeight.Regular)
end

function Theme.type(self: any, instance: any, family: Family, medium: boolean?)
	self._types[instance] = { family = family, medium = medium == true }
	instance.FontFace = self:face(family, medium)
end

function Theme.forget(self: any, instance: any)
	self._paints[instance] = nil
	self._types[instance] = nil
end

function Theme.apply(self: any, partial: { [string]: Color3 })
	for key, value in partial do
		self.tokens[key] = value
	end
	for instance, list in self._paints do
		for property, token in list do
			pcall(function()
				instance[property] = self.tokens[token]
			end)
		end
	end
	self.changed:fire()
end

function Theme.setFonts(self: any, text: string?, display: string?, mono: string?)
	self.fonts.mono = mono or self.fonts.mono
	self.fonts.text = text or self.fonts.text
	self.fonts.display = display or self.fonts.display
	for instance, spec in self._types do
		pcall(function()
			instance.FontFace = self:face(spec.family, spec.medium)
		end)
	end
end

return theme
