--!strict
-- the one place executor globals and services are read. tests inject a fake; features never touch getfenv or
-- game:GetService directly

local env = {}

local globals: any = (getfenv :: any)()
local cloneref: (any) -> any = globals.cloneref or function(instance: any)
	return instance
end
local cache: { [string]: any } = {}

function env.service(name: string): any
	local found = cache[name]
	if found == nil then
		found = cloneref((game :: any):GetService(name))
		cache[name] = found
	end
	return found
end

function env.global(name: string): any
	return globals[name]
end

-- gethui hides the gui from game scripts walking CoreGui; CoreGui still beats PlayerGui because a game's own
-- ClearAllChildren on PlayerGui would delete the menu
function env.guiParent(): any
	local gethui = globals.gethui
	if type(gethui) == "function" then
		local ok, parent = pcall(gethui)
		if ok and parent then
			return parent
		end
	end
	local ok, core = pcall(env.service, "CoreGui")
	if ok and core then
		local probe = Instance.new("Folder")
		if pcall(function()
			probe.Parent = core
		end) then
			probe:Destroy()
			return core
		end
		probe:Destroy()
	end
	return env.service("Players").LocalPlayer:WaitForChild("PlayerGui")
end

function env.protect(gui: any)
	local protect = globals.protectgui or (globals.syn and globals.syn.protect_gui)
	if type(protect) == "function" then
		pcall(protect, gui)
	end
end

export type Files = {
	read: (path: string) -> string?,
	write: (path: string, data: string) -> boolean,
	exists: (path: string) -> boolean,
	folder: (path: string) -> (),
	asset: (path: string) -> string?,
}

-- nil when the executor has no filesystem; everything that persists must survive that
function env.files(): Files?
	local readfile, writefile, isfile = globals.readfile, globals.writefile, globals.isfile
	if type(readfile) ~= "function" or type(writefile) ~= "function" or type(isfile) ~= "function" then
		return nil
	end
	local isfolder, makefolder, getcustomasset = globals.isfolder, globals.makefolder, globals.getcustomasset
	return {
		read = function(path: string): string?
			local ok, data = pcall(function()
				return if isfile(path) then readfile(path) else nil
			end)
			return if ok then data else nil
		end,
		write = function(path: string, data: string): boolean
			return (pcall(writefile, path, data))
		end,
		exists = function(path: string): boolean
			local ok, found = pcall(isfile, path)
			return ok and found == true
		end,
		folder = function(path: string)
			if type(makefolder) ~= "function" or type(isfolder) ~= "function" then
				return
			end
			local built = ""
			for part in string.gmatch(path, "[^/]+") do
				built = if built == "" then part else built .. "/" .. part
				pcall(function()
					if not isfolder(built) then
						makefolder(built)
					end
				end)
			end
		end,
		asset = function(path: string): string?
			if type(getcustomasset) ~= "function" then
				return nil
			end
			local ok, id = pcall(getcustomasset, path)
			return if ok and type(id) == "string" then id else nil
		end,
	}
end

function env.fetch(url: string): string?
	local ok, body = pcall(function()
		return (game :: any):HttpGet(url)
	end)
	return if ok and type(body) == "string" and body ~= "" then body else nil
end

return env
