--!strict
-- public entry. the bundle returns this table, so a host does: local sottui = loadstring(game:HttpGet(url))()

local env = require("./core/env")
local motion = require("./core/motion")
local obsidian = require("./compat/obsidian")
local windowModule = require("./shell/window")

local VERSION = "0.3.6-dock"

-- on the global table because each run of the script is a fresh chunk: a second run must find the first run's window
local function registry(): { current: any }
	local getgenv = env.global("getgenv")
	local shared_: any = if type(getgenv) == "function" then getgenv() else _G
	local found = shared_.__sottui
	if type(found) ~= "table" then
		found = { current = nil }
		shared_.__sottui = found
	end
	return found
end

local sottui = {
	version = VERSION,
	motion = motion,
}

windowModule.setVersion("v" .. VERSION)

function sottui.window(options: { [string]: any }?): any
	local settings: { [string]: any } = table.clone(options or {})
	settings._registry = registry()
	return windowModule.new(settings)
end

function sottui.current(): any
	return registry().current
end

-- Obsidian's api over this library, for a host not written against the native one
function sottui.obsidian(): { Library: any, SaveManager: any, ThemeManager: any }
	return obsidian.new(sottui)
end

return sottui
