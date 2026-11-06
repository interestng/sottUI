--!strict
-- the shared body of every control: a soft pad whose colours ease between states and which gives under a press. springs
-- are built on first use, most tiles are never touched

local make = require("../core/make")
local motion = require("../core/motion")

local tile = {}

tile.PAD = 12
tile.HEIGHT = 36
tile.NAME = 14
tile.RADIUS = 8

local WASH_SPEED = 22
local PRESS_SPEED = 40
local PRESS_RELEASE_DAMPING = 0.7
local INK_SPEED = 26
local PRESS_SCALE = 0.97
local LONG_PRESS = 0.45
local FLASH = 0.28

export type Ctx = {
	theme: any,
	input: any,
	hover: any,
	popover: any,
	tooltip: any,
	keys: any,
	glyph: any,
	touch: boolean,
	uiScale: () -> number,
	notify: (notice: any) -> (),
	setScrollLocked: (locked: boolean) -> (),
	isShowing: (el: any) -> boolean,
}

export type Tile = {
	root: any,
	name: any,
	el: any,
	ctx: Ctx,
	chips: { any },
	onHover: (self: Tile, on: boolean) -> (),
	pressed: (self: Tile, on: boolean) -> (),
	flood: (self: Tile, on: boolean, instant: boolean?) -> (),
	ink: (self: Tile, instance: any, token: string, instant: boolean?) -> (),
	flash: (self: Tile) -> (),
	refreshName: (self: Tile) -> (),
	own: (self: Tile, spring: any) -> any,
	onCleanup: (self: Tile, fn: () -> ()) -> (),
	refresh: () -> (),
	destroy: () -> (),
}

local Tile = {}
Tile.__index = Tile

function Tile.own(self: any, spring: any): any
	table.insert(self._cleanups, function()
		spring:destroy()
	end)
	return spring
end

function Tile.onCleanup(self: any, fn: () -> ())
	table.insert(self._cleanups, fn)
end

local function baseColor(self: any): Color3
	local tokens = self.ctx.theme.tokens
	if self._lit then
		return if self._hover then tokens.accentHover else tokens.accent
	end
	if self._flat then
		return if self._hover then tokens.raised else tokens.surface
	end
	return if self._hover then tokens.lineStrong else tokens.raised
end

local function washTo(self: any)
	if self._wash == nil then
		self._wash = self:own(motion.prop(self.root, "BackgroundColor3", WASH_SPEED))
	end
	self._wash:to(baseColor(self))
end

local function snapBase(self: any)
	local color = baseColor(self)
	if self._wash then
		self._wash:snap(color)
	else
		self.root.BackgroundColor3 = color
	end
end

function Tile.onHover(self: any, on: boolean)
	local hovering = on and not self.el.disabled
	if self._hover == hovering then
		return
	end
	self._hover = hovering
	for _, chip in self.chips do
		if chip.setHover then
			chip.setHover(hovering)
		end
	end
	washTo(self)
end

function Tile.pressed(self: any, on: boolean)
	if self._press == nil then
		local scale = make("UIScale", { Parent = self.root })
		self._press = self:own(motion.prop(scale, "Scale", PRESS_SPEED, PRESS_RELEASE_DAMPING))
	end
	self._press:to(if on then PRESS_SCALE else 1)
end

-- a corner radius cannot clip a child, so the fill eases across the whole pad instead of spreading from the press
function Tile.flood(self: any, on: boolean, instant: boolean?)
	if self._lit == on then
		return
	end
	self._lit = on
	if instant or not self.root.Visible or not self.ctx.isShowing(self.el) then
		snapBase(self)
	else
		washTo(self)
	end
end

-- a brief wave for "this one ran"
function Tile.flash(self: any)
	self:flood(true)
	task.delay(FLASH, function()
		if self.root.Parent then
			self:flood(false)
		end
	end)
end

function Tile.ink(self: any, instance: any, token: string, instant: boolean?)
	local tokens = self.ctx.theme.tokens
	local spring = self._inks[instance]
	-- a config load flips tiles nobody can see; those must not each start a spring
	if instant or not self.ctx.isShowing(self.el) then
		if spring then
			spring:snap(tokens[token])
		else
			instance.TextColor3 = tokens[token]
		end
		return
	end
	if spring == nil then
		spring = self:own(motion.prop(instance, "TextColor3", INK_SPEED))
		self._inks[instance] = spring
	end
	spring:to(tokens[token])
end

function Tile.retint(self: any)
	if not self._inert then
		snapBase(self)
	end
end

-- strikethrough rather than just dimmer: off and unavailable must not look alike at a glance
function Tile.refreshName(self: any)
	local el = self.el
	if el.disabled then
		self.name.RichText = true
		self.name.Text = "<s>" .. el.label .. "</s>"
	else
		self.name.RichText = false
		self.name.Text = el.label
	end
end

function tile.new(ctx: Ctx, el: any, options: { height: number?, inert: boolean?, flat: boolean? }?): Tile
	local settings: any = options or {}
	local root = make("TextButton", {
		Name = el.kind,
		Size = UDim2.new(1, 0, 0, settings.height or tile.HEIGHT),
		BackgroundTransparency = if settings.inert then 1 else 0,
		ClipsDescendants = true,
		Active = not settings.inert,
	})
	if not settings.inert then
		make("UICorner", { CornerRadius = UDim.new(0, tile.RADIUS), Parent = root })
	end
	local name = make("TextLabel", {
		Name = "Name",
		Position = UDim2.fromOffset(tile.PAD, 0),
		Size = UDim2.new(1, -2 * tile.PAD, 1, 0),
		TextSize = tile.NAME,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = el.label,
		ZIndex = 3,
		Parent = root,
	})
	ctx.theme:type(name, "text", true)

	local self: any = setmetatable({
		root = root,
		name = name,
		el = el,
		ctx = ctx,
		chips = {},
		_cleanups = {},
		_inks = {},
		_hover = false,
		_lit = false,
		_inert = settings.inert == true,
		_flat = settings.flat == true,
	}, Tile)
	root.BackgroundColor3 = baseColor(self)
	self:refreshName()

	if settings.inert then
		self.onHover = function() end
		self.pressed = function() end
	else
		root.MouseEnter:Connect(function()
			ctx.hover:enter(self)
		end)
		local longPress: thread? = nil
		root.InputBegan:Connect(function(event: any)
			local kind = event.UserInputType
			if kind == Enum.UserInputType.MouseButton1 then
				if not el.disabled then
					self:pressed(true)
				end
			elseif kind == Enum.UserInputType.Touch then
				if not el.disabled then
					self:pressed(true)
				end
				-- touch has no hover, so holding is how a tooltip is reached
				longPress = task.delay(LONG_PRESS, function()
					longPress = nil
					local tip = if el.disabled and el.disabledTip then el.disabledTip else el.tip
					if tip and tip ~= "" then
						ctx.tooltip:showAt(root, tip)
					end
				end)
			end
		end)
		-- the release can land anywhere; InputEnded on the tile misses one dragged off it and leaves it squashed
		local disconnect = ctx.input.pointerUp:connect(function()
			if self._press and self._press.target ~= 1 then
				self:pressed(false)
			end
			if longPress then
				task.cancel(longPress)
				longPress = nil
			end
		end)
		self:onCleanup(function()
			disconnect()
			if longPress then
				task.cancel(longPress)
			end
		end)
	end

	self.destroy = function()
		ctx.hover:leave(self)
		for _, fn in self._cleanups do
			pcall(fn)
		end
		root:Destroy()
	end
	return self
end

return tile
