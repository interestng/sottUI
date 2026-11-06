--!strict
-- ThemeManager's surface: presets of one signal color over the fixed forest ground, the choice kept per executor

local env = require("../core/env")

local themeManager = {}

local function derive(accent: Color3): { [string]: Color3 }
	local h, s, v = accent:ToHSV()
	return {
		accent = accent,
		accentHover = Color3.fromHSV(h, s * 0.8, math.min(v * 1.08, 1)),
		accentDim = Color3.fromHSV(h, math.min(s * 1.2, 1), 0.2),
	}
end

-- every preset keeps the forest ground; a preset is a different signal color, not a different product
local PRESETS: { [string]: Color3 } = {
	Mint = Color3.fromHex("7EE0C4"),
	Moss = Color3.fromHex("C5ECAE"),
	Lichen = Color3.fromHex("E9DEAA"),
	Ember = Color3.fromHex("F0A35A"),
	Sky = Color3.fromHex("7AB8E0"),
	Bone = Color3.fromHex("EBE8DA"),
}
local PRESET_ORDER = { "Mint", "Moss", "Lichen", "Ember", "Sky", "Bone" }

function themeManager.new(lib: any): any
	local manager: any = { Folder = "ObsidianLibSettings" }

	local function defaultPath(): string
		return manager.Folder .. "/themes/default.txt"
	end

	function manager.SetLibrary(_: any) end

	function manager.SetFolder(_: any, folder: string)
		manager.Folder = folder
		local store = env.files()
		if store then
			store.folder(folder .. "/themes")
		end
	end

	function manager.SaveDefault(_: any, name: string)
		local store = env.files()
		if store then
			store.write(defaultPath(), name)
		end
	end

	function manager.ApplyTheme(_: any, name: string)
		local accent = PRESETS[name]
		if accent then
			lib.window:setTheme(derive(accent))
			lib.Scheme.AccentColor = accent
		end
	end

	function manager.ApplyToTab(_: any, tab: any)
		local box = tab:AddGroupbox({ Name = "Look" })
		local store = env.files()
		local saved = store and store.read(defaultPath())
		local initial = if saved and PRESETS[saved] then saved else "Mint"
		box:AddDropdown("ThemeManager_Preset", {
			Text = "Color",
			Values = PRESET_ORDER,
			Default = initial,
			Callback = function(value: string?)
				if value then
					manager:ApplyTheme(value)
					manager:SaveDefault(value)
				end
			end,
		})
		box:AddSlider("ThemeManager_Scale", {
			Text = "Size",
			Min = 70,
			Max = 150,
			Default = math.round(lib.window._scale.Scale * 100),
			Suffix = "%",
			Rounding = 0,
			Callback = function(value: number)
				lib.window:setScale(value / 100)
			end,
		})
		manager:ApplyTheme(initial)
		return box
	end

	return manager
end

return themeManager
