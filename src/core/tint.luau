--!strict
-- color changes that should ease rather than switch (nav words, hover on text). one spring per instance and property,
-- made on first use and kept for the life of the window: these are the few chrome labels, never per tile

local motion = require("./motion")

local tint = {}

local DEFAULT_SPEED = 26

function tint.new(theme: any): (instance: any, property: string, token: string, speed: number?) -> ()
	local springs: { [any]: { [string]: any } } = {}
	return function(instance: any, property: string, token: string, speed: number?)
		-- a later theme change repaints from this registry, so it has to know the token this eased to
		local paints = theme._paints[instance]
		if paints == nil then
			paints = {}
			theme._paints[instance] = paints
		end
		paints[property] = token
		local list = springs[instance]
		if list == nil then
			list = {}
			springs[instance] = list
		end
		local spring = list[property]
		if spring == nil then
			spring = motion.prop(instance, property, speed or DEFAULT_SPEED)
			list[property] = spring
		end
		spring:to(theme.tokens[token])
	end
end

return tint
