--!strict
-- custom typefaces pulled from the repo at the tag the library was built for, cached on disk. the window never waits on
-- this: it paints with a built-in face at once and swaps when the files are ready, usually the same frame after the
-- first run

local env = require("./env")

local fonts = {}

export type Result = { text: string?, display: string? }

local FAMILIES = {
	text = {
		name = "SottUIText",
		faces = {
			{ name = "Regular", weight = 400, file = "text-400.ttf" },
			{ name = "Medium", weight = 500, file = "text-500.ttf" },
		},
	},
	display = {
		name = "SottUIDisplay",
		faces = {
			{ name = "SemiBold", weight = 600, file = "display-600.ttf" },
		},
	},
}

-- a truncated download still writes a file; a real ttf of ours is never this small, and one that is would decode to
-- tofu with no error from getcustomasset
local MIN_FONT_BYTES = 10000

local function family(store: env.Files, folder: string, spec: any, base: string, encode: (any) -> string): string?
	local faces = {}
	for _, face in spec.faces do
		local path = folder .. "/" .. face.file
		local cached = store.read(path)
		if cached == nil or #cached < MIN_FONT_BYTES then
			local body = env.fetch(base .. face.file)
			if body == nil or #body < MIN_FONT_BYTES then
				return nil
			end
			if not store.write(path, body) then
				return nil
			end
		end
		local asset = store.asset(path)
		if asset == nil then
			return nil
		end
		table.insert(faces, { name = face.name, weight = face.weight, style = "normal", assetId = asset })
	end
	local manifest = folder .. "/" .. spec.name .. ".json"
	if not store.write(manifest, encode({ name = spec.name, faces = faces })) then
		return nil
	end
	return store.asset(manifest)
end

-- base is the raw url of the repo's fonts folder at a fixed tag; a nil result keeps the fallback face
function fonts.load(folder: string, base: string, encode: (any) -> string): Result
	local store = env.files()
	if store == nil or env.global("getcustomasset") == nil then
		return {}
	end
	store.folder(folder)
	local result: Result = {}
	local ok, err: any = pcall(function()
		result.text = family(store, folder, FAMILIES.text, base, encode)
		result.display = family(store, folder, FAMILIES.display, base, encode)
	end)
	if not ok then
		warn("sottUI: fonts unavailable: " .. tostring(err))
	end
	return result
end

-- a small image shipped with the fonts; nil leaves whatever works without it
function fonts.image(folder: string, base: string, file: string): string?
	local store = env.files()
	if store == nil or env.global("getcustomasset") == nil then
		return nil
	end
	store.folder(folder)
	local path = folder .. "/" .. file
	if store.read(path) == nil then
		local body = env.fetch(base .. file)
		if body == nil or not store.write(path, body) then
			return nil
		end
	end
	return store.asset(path)
end

return fonts
