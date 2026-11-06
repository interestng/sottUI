--!strict
-- find any setting by typing. it searches models, so settings on pages never opened are found too. enter flips a
-- toggle or runs a button in place; anything else is revealed where it lives

local make = require("../core/make")
local motion = require("../core/motion")
local search = require("../model/search")

local palette = {}

local WIDTH = 420
local ITEM = 46
local INPUT = 68
local MAX_ROWS = 7
local SPEED = 34
local CLOSE_SPEED = 48

local function describe(el: any): string
	local where = el._pageName or ""
	if el.kind == "toggle" then
		return (if el.value then "On, " else "Off, ") .. where
	end
	if el.kind == "slider" then
		return tostring(el.value) .. (el.spec.suffix or "") .. ", " .. where
	end
	if el.kind == "dropdown" and not el.spec.multi and el.value ~= nil then
		return tostring((el.spec.display or tostring)(el.value)) .. ", " .. where
	end
	return where
end

function palette.new(ctx: any, layer: any, elements: () -> { any }, reveal: (el: any) -> ()): any
	local theme = ctx.theme
	local api: any = {}
	local open = false
	local scrim: any, panel: any, sizeSpring: any, box: any
	local results: { any } = {}
	local pool: { any } = {}
	local selected = 1

	local function close()
		if not open then
			return
		end
		open = false
		scrim:Destroy()
		local dying, dyingSpring: any = panel, sizeSpring
		dyingSpring.speed = CLOSE_SPEED
		dyingSpring:to(UDim2.fromOffset(WIDTH, 0), function()
			dyingSpring:destroy()
			dying:Destroy()
		end)
		table.clear(pool)
	end

	local function draw()
		-- a row entered during the close animation must not retarget the shutter away from closing
		if not open then
			return
		end
		for i, item in pool do
			local el = results[i]
			if el then
				item.root.Visible = true
				item.name.Text = el.label
				item.where.Text = describe(el)
				item.root.BackgroundTransparency = if i == selected then 0 else 1
				theme:paint(item.name, "TextColor3", if i == selected then "text" else "muted")
				theme:paint(item.where, "TextColor3", "faint")
			else
				item.root.Visible = false
			end
		end
		local rows = math.min(#results, MAX_ROWS)
		local height = INPUT + (if rows > 0 then rows * ITEM + 10 else 0)
		sizeSpring:to(UDim2.fromOffset(WIDTH, height))
	end

	local function run(el: any)
		if el == nil then
			return
		end
		close()
		-- a toggle is one key from undoing; a button may teleport or leave, so it is only ever shown, never run blind
		if el.kind == "toggle" and not el.disabled then
			el:set(not el.value)
			ctx.notify({ title = el.label, text = if el.value then "On" else "Off", seconds = 2 })
		else
			reveal(el)
		end
	end

	local function query()
		local text = box.Text
		if text == "" then
			-- the empty palette answers "what is running right now" across every page
			results = {}
			for _, el in elements() do
				if el.kind == "toggle" and el.value == true then
					table.insert(results, el)
					if #results == MAX_ROWS then
						break
					end
				end
			end
		else
			results = search.rank(text, elements(), function(el: any): string
				local section = el.section and el.section.title or ""
				return el.label .. " " .. (el._pageName or "") .. " " .. section .. " " .. (el.tip or "")
			end, MAX_ROWS)
		end
		selected = 1
		draw()
	end

	function api.toggle(_: any)
		if open then
			close()
			return
		end
		open = true
		WIDTH = ctx.paletteWidth()
		scrim = make("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ZIndex = 40,
			Parent = layer,
		})
		scrim.MouseButton1Down:Connect(close)
		panel = make("Frame", {
			Name = "Palette",
			Position = ctx.paletteAt(),
			Size = UDim2.fromOffset(WIDTH, 0),
			BackgroundTransparency = 0,
			ClipsDescendants = true,
			Active = true,
			ZIndex = 41,
			Parent = layer,
		})
		theme:paint(panel, "BackgroundColor3", "surface")
		local outline = make("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = panel })
		theme:paint(outline, "Color", "lineStrong")
		sizeSpring = motion.prop(panel, "Size", SPEED)
		box = make("TextBox", {
			Position = UDim2.fromOffset(18, 0),
			Size = UDim2.new(1, -36, 0, INPUT),
			TextSize = 22,
			Text = "",
			PlaceholderText = "Find a setting",
			ZIndex = 42,
			Parent = panel,
		})
		theme:type(box, "display")
		theme:paint(box, "TextColor3", "text")
		theme:paint(box, "PlaceholderColor3", "faint")
		for i = 1, MAX_ROWS do
			local root = make("TextButton", {
				Position = UDim2.fromOffset(6, INPUT + (i - 1) * ITEM + 2),
				Size = UDim2.new(1, -12, 0, ITEM),
				Visible = false,
				ZIndex = 42,
				Parent = panel,
			})
			theme:paint(root, "BackgroundColor3", "raised")
			local name = make("TextLabel", {
				Position = UDim2.fromOffset(12, 0),
				Size = UDim2.new(0.6, -12, 1, 0),
				TextSize = 16,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 43,
				Parent = root,
			})
			theme:type(name, "text", true)
			theme:paint(name, "TextColor3", "text")
			local where = make("TextLabel", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -12, 0, 0),
				Size = UDim2.new(0.4, -12, 1, 0),
				TextSize = 16,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Right,
				ZIndex = 43,
				Parent = root,
			})
			theme:type(where, "text")
			theme:paint(where, "TextColor3", "faint")
			pool[i] = { root = root, name = name, where = where }
			root.MouseEnter:Connect(function()
				if selected ~= i then
					selected = i
					draw()
				end
			end)
			root.Activated:Connect(function()
				run(results[i])
			end)
		end
		box:GetPropertyChangedSignal("Text"):Connect(query)
		box.FocusLost:Connect(function(enter: boolean)
			if enter then
				run(results[selected])
			end
		end)
		query()
		box:CaptureFocus()
	end

	function api.isOpen(_: any): boolean
		return open
	end

	api.close = close

	function api.key(_: any, name: string): boolean
		if not open then
			return false
		end
		if name == "Escape" then
			close()
			return true
		end
		if name == "Down" or name == "Up" then
			if #results > 0 then
				selected = math.clamp(selected + (if name == "Down" then 1 else -1), 1, #results)
				draw()
			end
			return true
		end
		return false
	end

	return api
end

return palette
