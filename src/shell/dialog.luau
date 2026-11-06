--!strict
-- a one off section in a modal, its tiles the same kinds as everywhere

local kinds = require("../view/kinds")
local make = require("../core/make")
local metrics = require("../core/metrics")
local motion = require("../core/motion")
local sectionModule = require("./section")

local dialog = {}

local SHUTTER_SPEED = 26
local CLOSE_SPEED = 36

function dialog.open(self: any, options: any, build: (section: any) -> ())
	-- one at a time: a second would orphan the first's scrim and the elements it owns
	if self._dialogClose then
		self._dialogClose()
	end
	local ctx = self.ctx
	local theme = ctx.theme
	local layer = self._layer
	local width = options.width or self.width
	local maxBody = options.maxHeight or 340
	local TILE = 60

	local scrim = make("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.new(0, 0, 0),
		ZIndex = 50,
		Parent = layer,
	})
	local scrimFade = motion.prop(scrim, "BackgroundTransparency", 22)
	local panel = make("Frame", {
		-- over the column, not over the game: it unfolds where the eye already is and the world stays visible
		Position = ctx.dialogAt(),
		Size = UDim2.fromOffset(width, 0),
		BackgroundTransparency = 0,
		ClipsDescendants = true,
		Active = true,
		ZIndex = 51,
		Parent = layer,
	})
	theme:paint(panel, "BackgroundColor3", "base")
	local outline = make("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = panel })
	theme:paint(outline, "Color", "line")

	local title = make("TextLabel", {
		Position = UDim2.fromOffset(20, 16),
		Size = UDim2.new(1, -40, 0, 40),
		TextSize = 24,
		Text = options.title or "",
		ZIndex = 52,
		Parent = panel,
	})
	theme:type(title, "display")
	theme:paint(title, "TextColor3", "text")
	local y = 60
	local body = options.text
	if body and body ~= "" then
		local text = make("TextLabel", {
			Position = UDim2.fromOffset(20, y),
			Size = UDim2.new(1, -40, 0, 22),
			AutomaticSize = Enum.AutomaticSize.Y,
			TextSize = 16,
			TextWrapped = true,
			Text = body,
			ZIndex = 52,
			Parent = panel,
		})
		theme:type(text, "text")
		theme:paint(text, "TextColor3", "muted")
		y += 22 + math.floor(#body / 52) * 22 + 12
	end

	local scroller = make("ScrollingFrame", {
		Position = UDim2.fromOffset(20, y),
		Size = UDim2.new(1, -40, 0, 0),
		ScrollBarThickness = 3,
		ZIndex = 52,
		Parent = panel,
	})
	theme:paint(scroller, "ScrollBarImageColor3", "lineStrong")

	local closed = false
	local fakePage: any = {
		window = self,
		name = "Dialog",
		nextId = function()
			self._dialogIds += 1
			return self._dialogIds
		end,
		_register = function(_: any, el: any, public: boolean)
			el._pageName = "Dialog"
			if public then
				self.elements[el.id] = el
			end
		end,
		_invalidate = function() end,
	}
	local section = sectionModule.new(fakePage, "")
	local ok, err: any = xpcall(build, debug.traceback, section)
	if not ok then
		warn("sottUI: dialog build failed: " .. tostring(err))
	end

	local views = {}
	local stack = 0
	for _, el in section.rows do
		if el:shown() then
			local view = kinds.build(ctx, el)
			local height = TILE
			if el.kind == "divider" then
				height = 28
			elseif el.kind == "label" then
				-- no page to correct it later, so wrapped text is measured here; a clipped explanation is no explanation
				local lines = math.ceil(metrics.width("text", el.label, 16) / (width - 48))
				height = if el.spec.wrap then lines * 21 + 12 else 32
			end
			view.root.Position = UDim2.fromOffset(0, stack)
			view.root.Size = UDim2.new(1, 0, 0, height)
			view.root.Parent = scroller
			stack += height + 3
			table.insert(views, view)
		end
	end
	scroller.CanvasSize = UDim2.fromOffset(0, stack)
	local bodyHeight = math.min(stack, maxBody)
	scroller.Size = UDim2.new(1, -40, 0, bodyHeight)
	local footerY = y + bodyHeight + 12
	local done = make("TextButton", {
		Position = UDim2.fromOffset(20, footerY),
		Size = UDim2.new(1, -40, 0, 46),
		BackgroundTransparency = 0,
		TextSize = 17,
		Text = options.done or "Done",
		ZIndex = 52,
		Parent = panel,
	})
	theme:type(done, "text", true)
	theme:paint(done, "BackgroundColor3", "raised")
	theme:paint(done, "TextColor3", "text")
	local total = footerY + 46 + 14
	local shutter: any = motion.prop(panel, "Size", SHUTTER_SPEED)
	shutter:to(UDim2.fromOffset(width, total))

	local function close()
		if closed then
			return
		end
		closed = true
		self._dialogClose = nil
		scrim.Active = false
		for _, el in section.rows do
			if self.elements[el.id] == el then
				self.elements[el.id] = nil
			end
			for _, addon in el.addons or {} do
				self.keys:unregister(addon)
				if self.elements[addon.id] == addon then
					self.elements[addon.id] = nil
				end
			end
		end
		if options.onClose then
			task.spawn(options.onClose)
		end
		scrimFade:to(1, function()
			scrimFade:destroy()
			scrim:Destroy()
		end)
		shutter.speed = CLOSE_SPEED
		shutter:to(UDim2.fromOffset(width, 0), function()
			for _, view in views do
				view.destroy()
			end
			shutter:destroy()
			panel:Destroy()
		end)
	end
	self._dialogClose = close
	scrim.MouseButton1Down:Connect(close)
	done.Activated:Connect(close)
end

return dialog
