--!strict
-- the few icons the shell needs, drawn from rotated hairlines: crisp at any scale and no asset id that can fail to load

local make = require("../core/make")

local glyph = {}

local function stroke(parent: any, theme: any, token: string, length: number, angle: number, x: number, y: number): any
	local line = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(length, 2),
		Rotation = angle,
		BackgroundTransparency = 0,
		Parent = parent,
	})
	theme:paint(line, "BackgroundColor3", token)
	return line
end

function glyph.new(theme: any)
	local api = {}

	function api.chevron(parent: any, token: string): any
		local holder = make("Frame", { Size = UDim2.fromOffset(12, 12), Parent = parent })
		stroke(holder, theme, token, 7, 45, 3.6, 6)
		stroke(holder, theme, token, 7, -45, 8.4, 6)
		return holder
	end

	function api.cross(parent: any, token: string): any
		local holder = make("Frame", { Size = UDim2.fromOffset(12, 12), Parent = parent })
		stroke(holder, theme, token, 13, 45, 6, 6)
		stroke(holder, theme, token, 13, -45, 6, 6)
		return holder
	end

	function api.dash(parent: any, token: string): any
		local holder = make("Frame", { Size = UDim2.fromOffset(12, 12), Parent = parent })
		stroke(holder, theme, token, 12, 0, 6, 6)
		return holder
	end

	return api
end

return glyph
