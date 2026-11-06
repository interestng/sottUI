--!strict
-- the shared body of every control: a hard edged tile. what makes it this design rather than a row is here: state floods
-- the tile from the point of the press, and a press compresses it. the flood is one circle clipped by the tile, the only
-- per tile cost is that frame and the springs, built on first use since most tiles are never touched

local make = require("../core/make")
local motion = require("../core/motion")

local tile = {}

tile.PAD = 12
tile.HEIGHT = 92

local WASH_SPEED = 26
local PRESS_SPEED = 44
local FLOOD_SPEED = 13
local PRESS_SCALE = 0.97

export type Tile = {
	root: any,
	label: any,
	el: any,
	ctx: any,
	onHover: (self: Tile, on: boolean) -> (),
	pressed: (self: Tile, on: boolean) -> (),
	flood: (self: Tile, on: boolean, instant: boolean?) -> (),
	setBase: (self: Tile, lit: boolean) -> (),
	ink: (self: Tile, instance: any, token: string, instant: boolean?) -> (),
	refreshLabel: (self: Tile) -> (),
	refresh: () -> (),
	destroy: () -> (),
}

local Tile = {}
Tile.__index = Tile

local function ownSpring(self: any, spring: any): any
	table.insert(self._cleanups, function()
		spring:destroy()
	end)
	return spring
end

tile.own = ownSpring

local function baseColor(self: any): Color3
	local tokens = self.ctx.theme.tokens
	if self._lit then
		return if self._hover then tokens.accentHover else tokens.accent
	end
	return if self._hover then tokens.raised else tokens.surface
end

local function paintBase(self: any)
	if self._wash == nil then
		self._wash = ownSpring(self, motion.prop(self.root, "BackgroundColor3", WASH_SPEED))
	end
	self._wash:to(baseColor(self))
end

function Tile.onHover(self: any, on: boolean)
	local hovering = on and not self.el.disabled
	if self._hover == hovering then
		return
	end
	self._hover = hovering
	paintBase(self)
end

function Tile.pressed(self: any, on: boolean)
	if self._press == nil then
		local scale = make("UIScale", { Parent = self.root })
		self._press = ownSpring(self, motion.prop(scale, "Scale", PRESS_SPEED))
	end
	self._press:to(if on then PRESS_SCALE else 1)
end

-- the base under the flood changes only when the flood has finished covering, so hover never shows through it
function Tile.setBase(self: any, lit: boolean)
	self._lit = lit
	paintBase(self)
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
		if self._wash then
			self._wash:snap(baseColor(self))
		else
			root.BackgroundColor3 = baseColor(self)
		end
		return
	end
	local circle = self._floodFrame
	if circle == nil then
		circle = make("Frame", {
			Name = "Flood",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 0,
			ZIndex = 1,
			Parent = root,
		})
		make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = circle })
		self.ctx.theme:paint(circle, "BackgroundColor3", "accent")
		self._floodFrame = circle
		self._floodSpring = ownSpring(self, motion.prop(circle, "Size", FLOOD_SPEED))
	end
	-- comfortably past the far corner from any start, and a critically damped spring spends most of its time near its
	-- goal, so this also sets how fast the wave crosses the tile
	local full = math.ceil(math.sqrt(size.X * size.X + size.Y * size.Y) * 2.6)
	local at = self._pressAt
	self._pressAt = nil
	local origin = if at then at - root.AbsolutePosition else size / 2
	circle.Position = UDim2.fromOffset(origin.X, origin.Y)
	circle.Visible = true
	if on then
		self._floodSpring:snap(UDim2.fromOffset(0, 0))
		self._floodSpring:to(UDim2.fromOffset(full, full), function()
			self:setBase(true)
			circle.Visible = false
		end)
	else
		self._lit = false
		if self._wash then
			self._wash:snap(baseColor(self))
		else
			root.BackgroundColor3 = baseColor(self)
		end
		self._floodSpring:snap(UDim2.fromOffset(full, full))
		self._floodSpring:to(UDim2.fromOffset(0, 0), function()
			circle.Visible = false
		end)
	end
end

function Tile.ink(self: any, instance: any, token: string, instant: boolean?)
	local tokens = self.ctx.theme.tokens
	local springs = self._inks
	local spring = springs[instance]
	if instant or spring == nil and instance.TextColor3 == tokens[token] then
		if spring then
			spring:snap(tokens[token])
		else
			instance.TextColor3 = tokens[token]
		end
		return
	end
	if spring == nil then
		spring = ownSpring(self, motion.prop(instance, "TextColor3", FLOOD_SPEED + 4))
		springs[instance] = spring
	end
	spring:to(tokens[token])
end

function Tile.refreshLabel(self: any)
	self.label.Text = self.el.label
end

function tile.new(ctx: any, el: any, height: number?): Tile
	local root = make("TextButton", {
		Name = el.kind,
		Size = UDim2.new(1, 0, 0, height or tile.HEIGHT),
		BackgroundTransparency = 0,
		ClipsDescendants = true,
	})
	ctx.theme:paint(root, "BackgroundColor3", "surface")

	local label = make("TextLabel", {
		Name = "Label",
		Position = UDim2.fromOffset(tile.PAD, 9),
		Size = UDim2.new(1, -2 * tile.PAD, 0, 42),
		TextSize = 16,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextTruncate = Enum.TextTruncate.AtEnd,
		LineHeight = 1.05,
		Text = el.label,
		ZIndex = 3,
		Parent = root,
	})
	ctx.theme:type(label, "text", true)

	local self: any = setmetatable({
		root = root,
		label = label,
		el = el,
		ctx = ctx,
		_cleanups = {},
		_inks = {},
		_hover = false,
		_lit = false,
		_floodOn = false,
	}, Tile)

	root.MouseEnter:Connect(function()
		ctx.hover:enter(self)
	end)
	root.InputBegan:Connect(function(event: any)
		local kind = event.UserInputType
		if el.disabled then
			return
		end
		if kind == Enum.UserInputType.MouseButton1 then
			self._pressAt = ctx.input:pointer()
			self:pressed(true)
		elseif kind == Enum.UserInputType.Touch then
			self._pressAt = ctx.input:at(event)
			self:pressed(true)
		end
	end)
	root.InputEnded:Connect(function(event: any)
		local kind = event.UserInputType
		if kind == Enum.UserInputType.MouseButton1 or kind == Enum.UserInputType.Touch then
			if self._press then
				self:pressed(false)
			end
		end
	end)

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
