--!strict
-- the shared body of every control: a hard edged tile whose text is the control. what makes it this design rather than
-- a row is here: state floods the tile from the point of the press and a press compresses it. the flood is one circle
-- clipped by the tile; it and the springs are built on first use, most tiles are never touched

local make = require("../core/make")
local metrics = require("../core/metrics")
local motion = require("../core/motion")

local tile = {}

tile.PAD = 14
tile.HEIGHT = 60
tile.NAME = 24
tile.NAME_SMALL = 19
tile.NAME_SMALLEST = 16
tile.VALUE = 15

local WASH_SPEED = 30
local PRESS_SPEED = 40
local PRESS_RELEASE_DAMPING = 0.62
local FLOOD_SPEED = 20
local INK_SPEED = 34
local PRESS_SCALE = 0.965
-- past the far corner from any start point, and a critically damped spring spends its last stretch creeping, so the
-- overshoot also sets how quickly the wave clears the tile
local FLOOD_REACH = 2.6
local LONG_PRESS = 0.45

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
	local face = self._face
	if self._lit then
		return if self._hover then tokens.accentHover else tokens.accent
	end
	if face == "action" then
		return if self._hover then tokens.lineStrong else tokens.raised
	end
	return if self._hover then tokens.raised else tokens.surface
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
	-- mid flood the circle owns the look; the base catches up when it lands
	if not (self._floodFrame and self._floodFrame.Visible) then
		washTo(self)
	end
end

function Tile.pressed(self: any, on: boolean)
	if self._press == nil then
		local scale = make("UIScale", { Parent = self.root })
		self._press = self:own(motion.prop(scale, "Scale", PRESS_SPEED, PRESS_RELEASE_DAMPING))
	end
	self._press:to(if on then PRESS_SCALE else 1)
end

function Tile.flood(self: any, on: boolean, instant: boolean?)
	if self._floodOn == on then
		return
	end
	self._floodOn = on
	local root = self.root
	local size = root.AbsoluteSize
	if instant or size.X < 1 or not root.Visible then
		self._lit = on
		if self._floodFrame then
			self._floodFrame.Visible = false
			self._floodSpring:snap(UDim2.fromOffset(0, 0))
		end
		snapBase(self)
		return
	end
	local circle = self._floodFrame
	if circle == nil then
		circle = make("Frame", {
			Name = "Flood",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(0, 0),
			BackgroundTransparency = 0,
			ZIndex = 1,
			Parent = root,
		})
		make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = circle })
		self.ctx.theme:paint(circle, "BackgroundColor3", "accent")
		self._floodFrame = circle
		self._floodSpring = self:own(motion.prop(circle, "Size", FLOOD_SPEED))
	end
	local scale = self.ctx.uiScale()
	local logical = size / scale
	local full = math.ceil(math.sqrt(logical.X * logical.X + logical.Y * logical.Y) * FLOOD_REACH)
	local at = self._pressAt
	self._pressAt = nil
	local origin = if at then (at - root.AbsolutePosition) / scale else logical / 2
	circle.Position = UDim2.fromOffset(origin.X, origin.Y)
	circle.Visible = true
	if on then
		self._floodSpring:snap(UDim2.fromOffset(0, 0))
		self._floodSpring:to(UDim2.fromOffset(full, full), function()
			self._lit = true
			snapBase(self)
			circle.Visible = false
		end)
	else
		self._lit = false
		snapBase(self)
		self._floodSpring:snap(UDim2.fromOffset(full, full))
		self._floodSpring:to(UDim2.fromOffset(0, 0), function()
			circle.Visible = false
		end)
	end
end

-- a brief wave for "this one": a config action ran, the palette brought you here
function Tile.flash(self: any)
	if self._floodOn then
		self:pressed(true)
		task.delay(0.16, function()
			if self.root.Parent then
				self:pressed(false)
			end
		end)
		return
	end
	self:flood(true)
	task.delay(0.28, function()
		if self.root.Parent and not (self.el.kind == "toggle" and self.el.value == true) then
			self:flood(false)
		end
	end)
end

function Tile.ink(self: any, instance: any, token: string, instant: boolean?)
	local tokens = self.ctx.theme.tokens
	local spring = self._inks[instance]
	if instant then
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

-- one line at full size when it fits, else two smaller, else two smaller still; the row height never changes, so a long
-- label costs nothing around it. the fit is arithmetic on real glyph widths
function tile.fitName(name: any, text: string, width: number)
	local full = metrics.width("display", text, tile.NAME)
	if full <= width then
		name.TextSize = tile.NAME
		name.TextWrapped = false
		name.LineHeight = 1
		return
	end
	name.TextWrapped = true
	name.LineHeight = 0.95
	-- word wrap leaves the end of each line short, so two lines hold a little under twice the width
	local twoLines = width * 1.8
	name.TextSize = if metrics.width("display", text, tile.NAME_SMALL) <= twoLines
		then tile.NAME_SMALL
		else tile.NAME_SMALLEST
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

function tile.new(ctx: Ctx, el: any, options: { height: number?, face: string?, inert: boolean? }?): Tile
	local settings: any = options or {}
	local root = make("TextButton", {
		Name = el.kind,
		Size = UDim2.new(1, 0, 0, settings.height or tile.HEIGHT),
		BackgroundTransparency = if settings.inert then 1 else 0,
		ClipsDescendants = true,
		Active = not settings.inert,
	})
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
	ctx.theme:type(name, "display")

	local self: any = setmetatable({
		root = root,
		name = name,
		el = el,
		ctx = ctx,
		chips = {},
		_face = settings.face,
		_cleanups = {},
		_inks = {},
		_hover = false,
		_lit = false,
		_floodOn = false,
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
					self._pressAt = ctx.input:pointer()
					self:pressed(true)
				end
			elseif kind == Enum.UserInputType.Touch then
				if not el.disabled then
					self._pressAt = ctx.input:at(event)
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
		root.InputEnded:Connect(function(event: any)
			local kind = event.UserInputType
			if kind == Enum.UserInputType.MouseButton1 or kind == Enum.UserInputType.Touch then
				if self._press then
					self:pressed(false)
				end
				if longPress then
					task.cancel(longPress)
					longPress = nil
				end
			end
		end)
		self:onCleanup(function()
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
