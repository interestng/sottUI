--!strict
-- one line of the column. nothing here is a box: the row exists as a name, and state is carried by how lit that name is
-- and by a mint bar on the rail beside it. off rows recede so what is running is what the eye finds

local make = require("../core/make")
local motion = require("../core/motion")

local row = {}

row.PAD = 18
row.HEIGHT = 46
row.NAME = 17

local WASH = 0.45
local WASH_SPEED = 30
local LEAN = 5
local LEAN_SPEED = 34
local LEAN_DAMPING = 0.62
local INK_SPEED = 26
local BAR_SPEED = 30
-- every lit row paints the same x, so together they read as one line: the rail
local BAR_WIDTH = 3

export type Row = {
	root: any,
	name: any,
	el: any,
	ctx: any,
	chips: { any },
	own: (self: Row, spring: any) -> any,
	onCleanup: (self: Row, fn: () -> ()) -> (),
	onHover: (self: Row, on: boolean) -> (),
	pressed: (self: Row, on: boolean) -> (),
	lit: (self: Row, on: boolean, instant: boolean?) -> (),
	ink: (self: Row, instance: any, token: string, instant: boolean?) -> (),
	flash: (self: Row) -> (),
	retint: (self: Row) -> (),
	refreshName: (self: Row) -> (),
	refresh: () -> (),
	destroy: () -> (),
}

local Row = {}
Row.__index = Row

function Row.own(self: any, spring: any): any
	table.insert(self._cleanups, function()
		spring:destroy()
	end)
	return spring
end

function Row.onCleanup(self: any, fn: () -> ())
	table.insert(self._cleanups, fn)
end

function Row.onHover(self: any, on: boolean)
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
	if self._wash == nil then
		self._wash = self:own(motion.prop(self.root, "BackgroundTransparency", WASH_SPEED))
	end
	self._wash:to(if hovering then WASH else 1)
end

-- a press leans the name in along the rail, the row's only physical gesture
function Row.pressed(self: any, on: boolean)
	if self._lean == nil then
		self._lean = self:own(motion.prop(self.name, "Position", LEAN_SPEED, LEAN_DAMPING))
		self._rest = self.name.Position
	end
	local rest = self._rest
	self._lean:to(if on then rest + UDim2.fromOffset(LEAN, 0) else rest)
end

function Row.lit(self: any, on: boolean, instant: boolean?)
	local bar = self._bar
	if bar == nil then
		bar = make("Frame", {
			Name = "Bar",
			Size = UDim2.new(0, 0, 1, 0),
			BackgroundTransparency = 0,
			ZIndex = 2,
			Parent = self.root,
		})
		-- a master floods; a lit option tints the whole row with a bright edge, the same statement said more quietly, so a
		-- page reads as blocks of what is on rather than a list with small words at the end
		local primary = self.el.spec.primary == true
		self.ctx.theme:paint(bar, "BackgroundColor3", if primary then "accent" else "accentDim")
		if not primary then
			local edge = make("Frame", {
				Name = "Edge",
				Size = UDim2.new(0, BAR_WIDTH, 1, 0),
				BackgroundTransparency = 0,
				ZIndex = 2,
				Parent = bar,
			})
			self.ctx.theme:paint(edge, "BackgroundColor3", "accent")
		end
		bar.ClipsDescendants = true
		self._bar = bar
		self._barSize = self:own(motion.prop(bar, "Size", BAR_SPEED))
	end
	-- a master's stretch of rail widens into the whole row: the one loud moment in an otherwise quiet column
	local target = if on then UDim2.new(1, 0, 1, -2) else UDim2.new(0, 0, 1, -2)
	if instant or not self.ctx.isShowing(self.el) then
		self._barSize:snap(target)
	else
		self._barSize:to(target)
	end
end

function Row.ink(self: any, instance: any, token: string, instant: boolean?)
	local tokens = self.ctx.theme.tokens
	local spring = self._inks[instance]
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

-- "this one": the palette brought you here, or an action ran
function Row.flash(self: any)
	self:pressed(true)
	self:onHover(true)
	task.delay(0.22, function()
		if self.root.Parent then
			self:pressed(false)
			self:onHover(false)
		end
	end)
end

function Row.retint(_: any) end

-- struck through rather than just dimmer: off and unavailable must not look alike
function Row.refreshName(self: any)
	local el = self.el
	if el.disabled then
		self.name.RichText = true
		self.name.Text = "<s>" .. el.label .. "</s>"
	else
		self.name.RichText = false
		self.name.Text = el.label
	end
end

function row.new(ctx: any, el: any, options: { height: number?, inert: boolean?, indent: number? }?): Row
	local settings: any = options or {}
	local indent = settings.indent or 0
	local root = make("TextButton", {
		Name = el.kind,
		Size = UDim2.new(1, 0, 0, settings.height or row.HEIGHT),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Active = not settings.inert,
	})
	ctx.theme:paint(root, "BackgroundColor3", "raised")
	local name = make("TextLabel", {
		Name = "Name",
		Position = UDim2.fromOffset(row.PAD + indent, 0),
		Size = UDim2.new(1, -(2 * row.PAD + indent), 1, 0),
		TextSize = row.NAME,
		TextWrapped = true,
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
		indent = indent,
		_cleanups = {},
		_inks = {},
		_hover = false,
	}, Row)
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
				longPress = task.delay(0.45, function()
					longPress = nil
					local tip = if el.disabled and el.disabledTip then el.disabledTip else el.tip
					if tip and tip ~= "" then
						ctx.tooltip:showAt(root, tip)
					end
				end)
			end
		end)
		local disconnect = ctx.input.pointerUp:connect(function()
			if self._lean then
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

return row
