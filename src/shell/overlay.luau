--!strict
-- what floats above the window: one popover at a time, one tooltip, and the hover tracker. MouseLeave is unreliable on
-- fast moves and when a row is hidden under the pointer, so hover is verified against the row's bounds on every mouse
-- move rather than trusted from the event

local make = require("../core/make")
local motion = require("../core/motion")

local overlay = {}

local SHUTTER = 34
local TIP_DELAY = 0.55
local TIP_WIDTH = 340
local TIP_SPEED = 40
local MARGIN = 8

function overlay.popover(ctx: any, layer: any): any
	local theme = ctx.theme
	local api: any = {}
	local current: any = nil

	local function close()
		local live = current
		if live == nil then
			return
		end
		current = nil
		live.catcher:Destroy()
		live.open = false
		live.size:to(UDim2.fromOffset(live.width, 0), function()
			live.size:destroy()
			live.frame:Destroy()
		end)
		if live.disconnectEl then
			live.disconnectEl()
		end
	end

	function api.open(_: any, anchor: any, width: number, height: number, build: (content: any, handle: any) -> ())
		close()
		local viewport = layer.AbsoluteSize
		local anchorPos, anchorSize = anchor.AbsolutePosition, anchor.AbsoluteSize
		width = math.min(width, viewport.X - 2 * MARGIN)
		height = math.min(height, viewport.Y - 2 * MARGIN)
		local x = math.clamp(anchorPos.X, MARGIN, viewport.X - width - MARGIN)
		local below = anchorPos.Y + anchorSize.Y + 2
		local flip = below + height + MARGIN > viewport.Y and anchorPos.Y - height - 2 > MARGIN
		local y = if flip then anchorPos.Y - height - 2 else math.min(below, viewport.Y - height - MARGIN)

		local catcher = make("TextButton", {
			Name = "Catcher",
			Size = UDim2.fromScale(1, 1),
			ZIndex = 60,
			Parent = layer,
		})
		local frame = make("Frame", {
			Name = "Popover",
			Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(width, 0),
			BackgroundTransparency = 0,
			ClipsDescendants = true,
			ZIndex = 61,
			Active = true,
			Parent = layer,
		})
		theme:paint(frame, "BackgroundColor3", "raised")
		local outline = make("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = frame })
		theme:paint(outline, "Color", "lineStrong")
		local content = make("Frame", { Size = UDim2.fromScale(1, 1), Parent = frame })

		local live: any = {
			frame = frame,
			catcher = catcher,
			width = width,
			open = true,
			size = motion.prop(frame, "Size", SHUTTER),
		}
		current = live
		catcher.MouseButton1Down:Connect(close)
		catcher.MouseButton2Down:Connect(close)

		local handle = {
			close = close,
			resize = function(newHeight: number)
				if live.open then
					live.size:to(UDim2.fromOffset(width, newHeight))
				end
			end,
			onKey = function(fn: (string) -> ())
				live.onKey = fn
			end,
			onRefresh = function(fn: () -> ())
				live.onRefresh = fn
			end,
		}
		build(content, handle)
		live.size:to(UDim2.fromOffset(width, height))
	end

	function api.isOpen(_: any): boolean
		return current ~= nil
	end

	function api.close(_: any)
		close()
	end

	function api.key(_: any, name: string): boolean
		if current == nil then
			return false
		end
		if name == "Escape" then
			close()
			return true
		end
		if current.onKey then
			current.onKey(name)
			return true
		end
		return false
	end

	return api
end

function overlay.tooltip(ctx: any, layer: any): any
	local theme = ctx.theme
	local frame = make("Frame", {
		Name = "Tooltip",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 0,
		Visible = false,
		ZIndex = 70,
		Parent = layer,
	})
	theme:paint(frame, "BackgroundColor3", "raised")
	local outline = make("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = frame })
	theme:paint(outline, "Color", "lineStrong")
	make("UIPadding", {
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 7),
		PaddingBottom = UDim.new(0, 7),
		Parent = frame,
	})
	local text = make("TextLabel", {
		AutomaticSize = Enum.AutomaticSize.XY,
		TextSize = 16,
		TextWrapped = true,
		ZIndex = 71,
		Parent = frame,
	})
	make("UISizeConstraint", { MaxSize = Vector2.new(TIP_WIDTH, 400), Parent = text })
	theme:type(text, "text")
	theme:paint(text, "TextColor3", "text")

	local api: any = {}
	local pending: thread? = nil

	function api.hide(_: any)
		if pending then
			task.cancel(pending)
			pending = nil
		end
		frame.Visible = false
	end

	local place = motion.prop(frame, "Position", TIP_SPEED)

	function api.showAt(self: any, anchor: any, content: string)
		self:hide()
		text.Text = content
		frame.Visible = true
		-- AutomaticSize settles a frame later; placing before that would measure the previous tip
		task.defer(function()
			if not frame.Visible then
				return
			end
			local viewport = layer.AbsoluteSize
			local size = frame.AbsoluteSize
			local x = math.clamp(anchor.AbsolutePosition.X, MARGIN, viewport.X - size.X - MARGIN)
			local below = anchor.AbsolutePosition.Y + anchor.AbsoluteSize.Y + 3
			local above = below + size.Y + MARGIN > viewport.Y
			local y = if above then anchor.AbsolutePosition.Y - size.Y - 3 else below
			place:snap(UDim2.fromOffset(x, y + (if above then 8 else -8)))
			place:to(UDim2.fromOffset(x, y))
		end)
	end

	function api.schedule(self: any, anchor: any, content: string)
		self:hide()
		pending = task.delay(TIP_DELAY, function()
			pending = nil
			if anchor.Parent ~= nil then
				self:showAt(anchor, content)
			end
		end)
	end

	return api
end

function overlay.hover(ctx: any): any
	local api: any = {}
	local current: any = nil

	local function clear()
		local row = current
		if row then
			current = nil
			row:onHover(false)
			ctx.tooltip:hide()
		end
	end

	function api.current(_: any): any
		return current
	end

	function api.enter(_: any, row: any)
		if current == row then
			return
		end
		clear()
		current = row
		row:onHover(true)
		local el = row.el
		local tip = if el.disabled and el.disabledTip then el.disabledTip else el.tip
		if tip and tip ~= "" then
			ctx.tooltip:schedule(row.root, tip)
		end
	end

	function api.leave(_: any, row: any)
		if current == row then
			clear()
		end
	end

	api.clear = clear

	function api.verify(_: any, at: Vector2)
		local row = current
		if row == nil then
			return
		end
		local root = row.root
		local origin, size = root.AbsolutePosition, root.AbsoluteSize
		local inside = at.X >= origin.X and at.Y >= origin.Y and at.X <= origin.X + size.X and at.Y <= origin.Y + size.Y
		if not inside or not root.Visible or root.Parent == nil or ctx.popover:isOpen() then
			clear()
		end
	end

	return api
end

return overlay
