--!strict
-- dropdown popover. the list is a fixed pool of rows repositioned on scroll, so a dropdown of every item in a game costs
-- the same as one with ten

local make = require("../core/make")
local search = require("../model/search")

local droplist = {}

local ITEM = 38
local MAX_VISIBLE = 8
local SEARCH_AT = 9
local SEARCH_HEIGHT = 48
local MIN_WIDTH = 230

local function isPicked(el: any, option: any): boolean
	if el.spec.multi then
		return el.value[option] == true
	end
	return el.value == option
end

function droplist.open(ctx: any, el: any, anchor: any)
	local spec = el.spec
	local theme = ctx.theme
	local display = spec.display or tostring
	local showSearch = spec.searchable == true or #spec.options >= SEARCH_AT
	local filtered: { any } = spec.options
	local highlighted = 0

	local width = math.max(anchor.AbsoluteSize.X, MIN_WIDTH)
	local function bodyHeight(): number
		local rows = math.clamp(#filtered, 1, MAX_VISIBLE)
		return rows * ITEM + 8
	end
	local height = bodyHeight() + (if showSearch then SEARCH_HEIGHT else 0)

	ctx.popover:open(anchor, width, height, function(content: any, handle: any)
		local scroller = make("ScrollingFrame", {
			Position = UDim2.fromOffset(0, if showSearch then SEARCH_HEIGHT else 0),
			Size = UDim2.new(1, 0, 1, if showSearch then -SEARCH_HEIGHT else 0),
			ScrollBarThickness = 2,
			Parent = content,
		})
		theme:paint(scroller, "ScrollBarImageColor3", "lineStrong")
		local canvas = make("Frame", { Size = UDim2.fromScale(1, 1), Parent = scroller })

		local pool: { any } = {}
		local poolSize = MAX_VISIBLE + 2
		local empty = make("TextLabel", {
			Position = UDim2.fromOffset(14, 4),
			Size = UDim2.new(1, -28, 0, ITEM),
			TextSize = 16,
			Text = "Nothing matches",
			Visible = false,
			Parent = content,
		})
		theme:type(empty, "text")
		theme:paint(empty, "TextColor3", "faint")
		if showSearch then
			empty.Position = UDim2.fromOffset(14, SEARCH_HEIGHT + 4)
		end

		local function draw()
			local top = scroller.CanvasPosition.Y
			local first = math.floor(top / ITEM) + 1
			for i = 1, poolSize do
				local item = pool[i]
				local index = first + i - 1
				local option = filtered[index]
				if option == nil then
					item.root.Visible = false
				else
					item.index = index
					item.option = option
					item.root.Visible = true
					item.root.Position = UDim2.new(0, 4, 0, (index - 1) * ITEM + 4)
					item.text.Text = display(option)
					local picked = isPicked(el, option)
					theme:paint(item.text, "TextColor3", if picked then "onAccent" else "text")
					theme:paint(item.root, "BackgroundColor3", if picked then "accent" else "raised")
					item.root.BackgroundTransparency = if picked or index == highlighted then 0 else 1
				end
			end
		end

		local function refit()
			scroller.CanvasSize = UDim2.fromOffset(0, #filtered * ITEM + 8)
			empty.Visible = #filtered == 0
			handle.resize(bodyHeight() + (if showSearch then SEARCH_HEIGHT else 0))
			draw()
		end

		local function choose(option: any)
			if spec.multi then
				local picks = table.clone(el.value)
				picks[option] = if picks[option] then nil else true
				el:set(picks)
				draw()
				return
			end
			if el.value == option then
				if spec.allowNull then
					el:set(nil)
				end
			else
				el:set(option)
			end
			handle.close()
		end

		for i = 1, poolSize do
			local root = make("TextButton", {
				Size = UDim2.new(1, -8, 0, ITEM - 2),
				BackgroundTransparency = 1,
				Visible = false,
				Parent = canvas,
			})
			theme:paint(root, "BackgroundColor3", "raised")
			local text = make("TextLabel", {
				Position = UDim2.fromOffset(10, 0),
				Size = UDim2.new(1, -20, 1, 0),
				TextSize = 16,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = root,
			})
			theme:type(text, "text", true)
			local item = { root = root, text = text, index = 0, option = nil }
			pool[i] = item
			root.MouseEnter:Connect(function()
				highlighted = item.index
				draw()
			end)
			root.MouseLeave:Connect(function()
				if highlighted == item.index then
					highlighted = 0
					draw()
				end
			end)
			root.Activated:Connect(function()
				if item.option ~= nil then
					choose(item.option)
				end
			end)
		end

		scroller:GetPropertyChangedSignal("CanvasPosition"):Connect(draw)

		local box: any = nil
		if showSearch then
			box = make("TextBox", {
				Position = UDim2.fromOffset(14, 0),
				Size = UDim2.new(1, -28, 0, SEARCH_HEIGHT),
				TextSize = 24,
				Text = "",
				PlaceholderText = "Search",
				Parent = content,
			})
			theme:type(box, "display")
			theme:paint(box, "TextColor3", "text")
			theme:paint(box, "PlaceholderColor3", "faint")
			local rule = make("Frame", {
				Position = UDim2.fromOffset(0, SEARCH_HEIGHT - 1),
				Size = UDim2.new(1, 0, 0, 1),
				BackgroundTransparency = 0,
				Parent = content,
			})
			theme:paint(rule, "BackgroundColor3", "line")
			box:GetPropertyChangedSignal("Text"):Connect(function()
				local query = box.Text
				if query == "" then
					filtered = spec.options
				else
					filtered = search.rank(query, spec.options, display, 500)
				end
				highlighted = if #filtered > 0 and query ~= "" then 1 else 0
				scroller.CanvasPosition = Vector2.zero
				refit()
			end)
		end

		handle.onKey(function(name: string)
			if name == "Down" or name == "Up" then
				local step = if name == "Down" then 1 else -1
				highlighted = math.clamp(highlighted + step, 1, math.max(#filtered, 1))
				local y = (highlighted - 1) * ITEM
				local viewport = scroller.AbsoluteSize.Y
				local top = scroller.CanvasPosition.Y
				if y < top then
					scroller.CanvasPosition = Vector2.new(0, y)
				elseif y + ITEM + 8 > top + viewport then
					scroller.CanvasPosition = Vector2.new(0, y + ITEM + 8 - viewport)
				end
				draw()
			elseif name == "Return" then
				local option = filtered[highlighted]
				if option ~= nil then
					choose(option)
				end
			end
		end)

		refit()
		if not spec.multi and el.value ~= nil then
			local at = table.find(filtered, el.value)
			if at then
				local viewport = (math.clamp(#filtered, 1, MAX_VISIBLE)) * ITEM
				scroller.CanvasPosition = Vector2.new(0, math.max((at - 1) * ITEM - viewport / 2 + ITEM / 2, 0))
				draw()
			end
		end
		if box and not ctx.touch then
			box:CaptureFocus()
		end
	end)
end

return droplist
