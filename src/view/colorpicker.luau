--!strict
-- color swatch and its popover. the field and hue strip are gradients on plain frames, no image assets to fail to load

local make = require("../core/make")

local colorpicker = {}

local WIDTH = 256
local FIELD = 148
local STRIP = 14
local GAP = 10
local PAD = 12

local HUES = (function()
	local keys = {}
	for i = 0, 6 do
		table.insert(keys, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV((i / 6) % 1, 1, 1)))
	end
	return ColorSequence.new(keys)
end)()

local function hex(color: Color3): string
	return string.format(
		"%02X%02X%02X",
		math.round(color.R * 255),
		math.round(color.G * 255),
		math.round(color.B * 255)
	)
end

local function parseHex(text: string): Color3?
	local clean = string.gsub(text, "#", "")
	if not string.match(clean, "^%x%x%x%x%x%x$") then
		return nil
	end
	return Color3.fromRGB(
		tonumber(string.sub(clean, 1, 2), 16) :: number,
		tonumber(string.sub(clean, 3, 4), 16) :: number,
		tonumber(string.sub(clean, 5, 6), 16) :: number
	)
end

colorpicker.hex = hex
colorpicker.parseHex = parseHex

local function open(ctx: any, el: any, anchor: any)
	local theme = ctx.theme
	local hasAlpha = el.spec.alpha == true
	local height = PAD + FIELD + GAP + STRIP + (if hasAlpha then GAP + STRIP else 0) + GAP + 28 + PAD
	ctx.popover:open(anchor, WIDTH, height, function(content: any, handle: any)
		local value = el.value
		local h, s, v = value.color:ToHSV()
		local alpha = value.alpha

		local field = make("TextButton", {
			Position = UDim2.fromOffset(PAD, PAD),
			Size = UDim2.new(1, -2 * PAD, 0, FIELD),
			BackgroundTransparency = 0,
			Parent = content,
		})
		make("UIGradient", {
			Transparency = NumberSequence.new(0, 1),
			Color = ColorSequence.new(Color3.new(1, 1, 1)),
			Parent = make("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 0,
				BackgroundColor3 = Color3.new(1, 1, 1),
				Parent = field,
				ZIndex = 1,
			}),
		})
		local shade = make("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 0,
			BackgroundColor3 = Color3.new(0, 0, 0),
			ZIndex = 2,
			Parent = field,
		})
		make("UIGradient", {
			Rotation = 90,
			Transparency = NumberSequence.new(1, 0),
			Parent = shade,
		})
		local cursor = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(10, 10),
			BackgroundTransparency = 1,
			ZIndex = 3,
			Parent = field,
		})
		make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = cursor })
		make("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 1.5, Parent = cursor })

		local y = PAD + FIELD + GAP
		local strip = make("TextButton", {
			Position = UDim2.fromOffset(PAD, y),
			Size = UDim2.new(1, -2 * PAD, 0, STRIP),
			BackgroundTransparency = 0,
			BackgroundColor3 = Color3.new(1, 1, 1),
			Parent = content,
		})
		make("UIGradient", { Color = HUES, Parent = strip })
		local hueMark = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Size = UDim2.new(0, 3, 1, 0),
			BackgroundTransparency = 0,
			BackgroundColor3 = Color3.new(1, 1, 1),
			ZIndex = 2,
			Parent = strip,
		})
		y += STRIP

		local alphaBar, alphaMark = nil, nil
		if hasAlpha then
			y += GAP
			alphaBar = make("TextButton", {
				Position = UDim2.fromOffset(PAD, y),
				Size = UDim2.new(1, -2 * PAD, 0, STRIP),
				BackgroundTransparency = 0,
				Parent = content,
			})
			alphaMark = make("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				Size = UDim2.new(0, 3, 1, 0),
				BackgroundTransparency = 0,
				BackgroundColor3 = Color3.new(1, 1, 1),
				ZIndex = 2,
				Parent = alphaBar,
			})
			make("UIGradient", { Transparency = NumberSequence.new(0, 1), Parent = alphaBar })
			y += STRIP
		end
		y += GAP

		local swatch = make("Frame", {
			Position = UDim2.fromOffset(PAD, y),
			Size = UDim2.fromOffset(44, 28),
			BackgroundTransparency = 0,
			Parent = content,
		})
		local entry = make("TextBox", {
			Position = UDim2.fromOffset(PAD + 54, y),
			Size = UDim2.new(1, -(2 * PAD + 54), 0, 28),
			TextSize = 18,
			Parent = content,
		})
		theme:type(entry, "text", true)
		theme:paint(entry, "TextColor3", "text")

		local function draw()
			local current = Color3.fromHSV(h, s, v)
			field.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
			cursor.Position = UDim2.fromScale(s, 1 - v)
			hueMark.Position = UDim2.fromScale(h, 0)
			swatch.BackgroundColor3 = current
			if not entry:IsFocused() then
				entry.Text = "#" .. hex(current)
			end
			if alphaBar then
				alphaBar.BackgroundColor3 = current
				alphaMark.Position = UDim2.fromScale(alpha, 0)
			end
		end

		local function commit()
			draw()
			el:set({ color = Color3.fromHSV(h, s, v), alpha = alpha })
		end

		local function bind(button: any, apply: (x: number, y: number) -> ())
			local function update(at: Vector2)
				local origin, size = button.AbsolutePosition, button.AbsoluteSize
				apply(
					math.clamp((at.X - origin.X) / math.max(size.X, 1), 0, 1),
					math.clamp((at.Y - origin.Y) / math.max(size.Y, 1), 0, 1)
				)
				commit()
			end
			button.InputBegan:Connect(function(event: any)
				local kind = event.UserInputType
				if kind == Enum.UserInputType.MouseButton1 then
					update(ctx.input:pointer())
					ctx.input:capture(update)
				elseif kind == Enum.UserInputType.Touch then
					ctx.setScrollLocked(true)
					update(ctx.input:at(event))
					ctx.input:capture(update, function()
						ctx.setScrollLocked(false)
					end, event)
				end
			end)
		end

		bind(field, function(x: number, yy: number)
			s, v = x, 1 - yy
		end)
		bind(strip, function(x: number)
			h = math.clamp(x, 0, 0.999)
		end)
		if alphaBar then
			bind(alphaBar, function(x: number)
				alpha = x
			end)
		end
		entry.FocusLost:Connect(function()
			local parsed = parseHex(entry.Text)
			if parsed then
				h, s, v = parsed:ToHSV()
				commit()
			else
				draw()
			end
		end)
		handle.onRefresh(function()
			local fresh = el.value
			if fresh.color ~= Color3.fromHSV(h, s, v) then
				h, s, v = fresh.color:ToHSV()
			end
			alpha = fresh.alpha
			draw()
		end)
		draw()
	end)
end

-- a round dot, the one round thing in the design: a square would read as another state mark, and a tile edge bar as a
-- glitch. the button is wider than what it draws, twelve pixels is not something to aim at
colorpicker.DOT_SPACE = 30

-- wider than tall: a colour bar, where a small square would read as a checkbox
local DOT = 10
local SWATCH_WIDTH = 18
local MUTED_SWATCH = 0.72

function colorpicker.swatch(ctx: any, el: any): any
	local root = make("TextButton", {
		Name = "Swatch",
		Size = UDim2.new(0, colorpicker.DOT_SPACE, 1, 0),
		ZIndex = 4,
	})
	local band = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(SWATCH_WIDTH, DOT),
		BackgroundTransparency = 0,
		ZIndex = 4,
		Parent = root,
	})
	local chip: any = { root = root, width = colorpicker.DOT_SPACE }
	local muted = false
	chip.refresh = function()
		band.BackgroundColor3 = el.value.color
		local transparency = el.value.alpha * 0.8
		band.BackgroundTransparency = if muted then math.max(transparency, MUTED_SWATCH) else transparency
	end
	-- a colour for something that is off is hidden until the row is under the pointer: a column of dim bars read as
	-- dead controls. no hover on touch, so there it stays
	local hovered = false
	local function reach()
		root.Visible = not muted or hovered or ctx.touch
	end
	chip.setMuted = function(on: boolean)
		muted = on
		chip.refresh()
		reach()
	end
	chip.setHover = function(on: boolean)
		hovered = on
		reach()
	end
	chip.refresh()
	chip.open = function()
		if not el.disabled then
			open(ctx, el, root)
		end
	end
	root.Activated:Connect(chip.open)
	chip.setInk = function() end
	chip.destroy = function()
		root:Destroy()
	end
	return chip
end

return colorpicker
