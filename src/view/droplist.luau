--!strict
-- dropdown popover. the list is a fixed pool of rows repositioned on scroll, so a dropdown of every item in a game costs
-- the same as one with ten. in a multi list what is picked is pinned to the top, so five picks out of a hundred stay in
-- view, and searching clears itself after each pick

local make = require("../core/make")
local search = require("../model/search")

local droplist = {}

local ITEM = 34
local MAX_VISIBLE = 8
local SEARCH_AT = 9
local SEARCH_HEIGHT = 40
local CLEAR_HEIGHT = 34
local MIN_WIDTH = 220
local TEXT_SIZE = 14

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
	local showClear = spec.multi == true
	local top = (if showSearch then SEARCH_HEIGHT else 0) + (if showClear then CLEAR_HEIGHT else 0)
	local filtered: { any } = spec.options
	local highlighted = 0
	local query = ""

	local function ordered(list: { any }): { any }
		if not spec.multi then
			return list
		end
		local picked, rest = {}, {}
		for _, option in list do
			table.insert(if el.value[option] then picked else rest, option)
		end
		table.move(rest, 1, #rest, #picked + 1, picked)
		return picked
	end
	filtered = ordered(filtered)

	local function bodyHeight(): number
		return math.clamp(#filtered, 1, MAX_VISIBLE) * ITEM + 8
	end

	local width = math.max(anchor.AbsoluteSize.X, MIN_WIDTH)
	ctx.popover:open(anchor, width, bodyHeight() + top, function(content: any, handle: any)
		local scroller = make("ScrollingFrame", {
			Position = UDim2.fromOffset(0, top),
			Size = UDim2.new(1, 0, 1, -top),
			ScrollBarThickness = 3,
			Parent = content,
		})
		theme:paint(scroller, "ScrollBarImageColor3", "lineStrong")
		local canvas = make("Frame", { Size = UDim2.fromScale(1, 1), Parent = scroller })

		local pool: { any } = {}
		local poolSize = MAX_VISIBLE + 2
		local empty = make("TextLabel", {
			Position = UDim2.fromOffset(14, top + 4),
			Size = UDim2.new(1, -28, 0, ITEM),
			TextSize = TEXT_SIZE,
			Text = "Nothing matches",
			Visible = false,
			Parent = content,
		})
		theme:type(empty, "text")
		theme:paint(empty, "TextColor3", "faint")

		local function draw()
			local first = math.floor(scroller.CanvasPosition.Y / ITEM) + 1
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
					theme:paint(item.text, "TextColor3", if picked then "accent" else "text")
					item.mark.Visible = picked
					theme:paint(item.root, "BackgroundColor3", "lineStrong")
					item.root.BackgroundTransparency = if index == highlighted then 0 else 1
				end
			end
		end

		local function refit()
			scroller.CanvasSize = UDim2.fromOffset(0, #filtered * ITEM + 8)
			empty.Visible = #filtered == 0
			handle.resize(bodyHeight() + top)
			draw()
		end

		local function refilter()
			local source = spec.options
			if query ~= "" then
				source = search.rank(query, source, display, 500)
			end
			filtered = ordered(source)
			refit()
		end

		local box: any = nil
		local function choose(option: any)
			if spec.multi then
				local picks = table.clone(el.value)
				picks[option] = if picks[option] then nil else true
				el:set(picks)
				if box and box.Text ~= "" then
					box.Text = ""
				else
					refilter()
				end
				if box and not ctx.touch then
					box:CaptureFocus()
				end
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
			make("UICorner", { CornerRadius = UDim.new(0, 7), Parent = root })
			local text = make("TextLabel", {
				Position = UDim2.fromOffset(10, 0),
				Size = UDim2.new(1, -36, 1, 0),
				TextSize = TEXT_SIZE,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = root,
			})
			theme:type(text, "text", true)
			-- a small light rather than a filled row: three picks in a row read as three buttons
			local mark = make("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -12, 0.5, 0),
				Size = UDim2.fromOffset(7, 7),
				BackgroundTransparency = 0,
				Visible = false,
				Parent = root,
			})
			make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = mark })
			theme:paint(mark, "BackgroundColor3", "accent")
			local item = { root = root, text = text, mark = mark, index = 0, option = nil }
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

		local y = 0
		if showSearch then
			box = make("TextBox", {
				Position = UDim2.fromOffset(14, 0),
				Size = UDim2.new(1, -28, 0, SEARCH_HEIGHT),
				TextSize = TEXT_SIZE + 1,
				Text = "",
				PlaceholderText = "Search",
				Parent = content,
			})
			theme:type(box, "text", true)
			theme:paint(box, "TextColor3", "text")
			theme:paint(box, "PlaceholderColor3", "faint")
			local rule = make("Frame", {
				Position = UDim2.fromOffset(0, SEARCH_HEIGHT - 1),
				Size = UDim2.new(1, 0, 0, 1),
				BackgroundTransparency = 0,
				Parent = content,
			})
			theme:paint(rule, "BackgroundColor3", "lineStrong")
			box:GetPropertyChangedSignal("Text"):Connect(function()
				query = box.Text
				highlighted = if query ~= "" then 1 else 0
				scroller.CanvasPosition = Vector2.zero
				refilter()
			end)
			y = SEARCH_HEIGHT
		end
		if showClear then
			local clear = make("TextButton", {
				Position = UDim2.fromOffset(4, y),
				Size = UDim2.new(1, -8, 0, CLEAR_HEIGHT),
				TextSize = TEXT_SIZE,
				Text = "Clear all",
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = content,
			})
			make("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = clear })
			theme:type(clear, "text", true)
			theme:paint(clear, "TextColor3", "muted")
			clear.MouseEnter:Connect(function()
				theme:paint(clear, "TextColor3", "text")
			end)
			clear.MouseLeave:Connect(function()
				theme:paint(clear, "TextColor3", "muted")
			end)
			clear.Activated:Connect(function()
				el:set({})
				refilter()
			end)
		end

		handle.onKey(function(name: string)
			if name == "Down" or name == "Up" then
				local step = if name == "Down" then 1 else -1
				highlighted = math.clamp(highlighted + step, 1, math.max(#filtered, 1))
				local itemY = (highlighted - 1) * ITEM
				local viewport = scroller.AbsoluteWindowSize.Y
				local current = scroller.CanvasPosition.Y
				if itemY < current then
					scroller.CanvasPosition = Vector2.new(0, itemY)
				elseif itemY + ITEM + 8 > current + viewport then
					scroller.CanvasPosition = Vector2.new(0, itemY + ITEM + 8 - viewport)
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
				local viewport = math.clamp(#filtered, 1, MAX_VISIBLE) * ITEM
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
