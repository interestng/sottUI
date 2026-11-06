--!strict
-- notices stack bottom right, outside the window: they must stay readable with the menu closed

local make = require("../core/make")
local motion = require("../core/motion")

local notify = {}

local WIDTH = 320
local GAP = 8
local EDGE = 20
local SPEED = 26
local MAX_SHOWN = 5

function notify.new(ctx: any, layer: any): any
	local theme = ctx.theme
	local stack: { any } = {}
	local api: any = {}

	local function layout()
		local viewport = layer.AbsoluteSize
		local y = viewport.Y - EDGE
		for i = #stack, 1, -1 do
			local item = stack[i]
			y -= item.height
			item.pos:to(UDim2.fromOffset(viewport.X - WIDTH - EDGE, y))
			y -= GAP
		end
	end

	local function dismiss(item: any)
		if item.gone then
			return
		end
		item.gone = true
		if item.timer then
			task.cancel(item.timer)
		end
		local at = table.find(stack, item)
		if at then
			table.remove(stack, at)
		end
		local viewport = layer.AbsoluteSize
		item.pos:to(UDim2.fromOffset(viewport.X + 8, item.frame.Position.Y.Offset), function()
			item.pos:destroy()
			item.frame:Destroy()
		end)
		layout()
	end

	function api.show(_: any, options: { title: string?, text: string?, seconds: number? })
		while #stack >= MAX_SHOWN do
			dismiss(stack[1])
		end
		local viewport = layer.AbsoluteSize
		local frame = make("TextButton", {
			Name = "Notice",
			Position = UDim2.fromOffset(viewport.X + 8, viewport.Y - EDGE - 60),
			Size = UDim2.fromOffset(WIDTH, 60),
			BackgroundTransparency = 0,
			ZIndex = 80,
			Parent = layer,
		})
		theme:paint(frame, "BackgroundColor3", "surface")
		local outline = make("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = frame })
		theme:paint(outline, "Color", "lineStrong")
		local edge =
			make("Frame", { Size = UDim2.new(0, 4, 1, 0), BackgroundTransparency = 0, ZIndex = 81, Parent = frame })
		theme:paint(edge, "BackgroundColor3", "accent")
		local y = 10
		if options.title and options.title ~= "" then
			local title = make("TextLabel", {
				Position = UDim2.fromOffset(18, y),
				Size = UDim2.new(1, -32, 0, 24),
				TextSize = 22,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Text = options.title,
				ZIndex = 81,
				Parent = frame,
			})
			theme:type(title, "display")
			theme:paint(title, "TextColor3", "text")
			y += 26
		end
		local body = nil
		if options.text and options.text ~= "" then
			body = make("TextLabel", {
				Position = UDim2.fromOffset(18, y),
				Size = UDim2.new(1, -32, 0, 20),
				TextSize = 16,
				TextWrapped = true,
				TextYAlignment = Enum.TextYAlignment.Top,
				RichText = true,
				Text = options.text,
				ZIndex = 81,
				Parent = frame,
			})
			theme:type(body, "text")
			theme:paint(body, "TextColor3", "muted")
		end
		local item: any = {
			frame = frame,
			height = y + 28,
			pos = motion.prop(frame, "Position", SPEED),
			gone = false,
		}
		frame.Size = UDim2.fromOffset(WIDTH, item.height)
		if body then
			-- TextBounds settles a frame after the text is set; a long message grows its notice then
			task.defer(function()
				if item.gone then
					return
				end
				local height = math.ceil(body.TextBounds.Y)
				if height > 20 then
					body.Size = UDim2.new(1, -32, 0, height)
					item.height = y + height + 10
					frame.Size = UDim2.fromOffset(WIDTH, item.height)
					layout()
				end
			end)
		end
		-- arrives along its own row: starting elsewhere would swoop diagonally
		item.pos:snap(UDim2.fromOffset(viewport.X + 8, viewport.Y - EDGE - item.height))
		table.insert(stack, item)
		frame.Activated:Connect(function()
			dismiss(item)
		end)
		item.timer = task.delay(options.seconds or 5, function()
			item.timer = nil
			dismiss(item)
		end)
		layout()
	end

	function api.destroy(_: any)
		for _, item in table.clone(stack) do
			if item.timer then
				task.cancel(item.timer)
			end
			item.pos:destroy()
			item.frame:Destroy()
		end
		table.clear(stack)
	end

	return api
end

return notify
