--!strict
-- SaveManager over the compat elements. the file format is obs-fork v1.0.2's, so existing configs load and stay loadable

local env = require("../core/env")

local saveManager = {}

local function isEmpty(text: any): boolean
	return type(text) ~= "string" or string.gsub(text, "%s", "") == ""
end

function saveManager.new(lib: any): any
	local save: any = {
		Folder = "ObsidianLibSettings",
		SubFolder = "",
		Ignore = {},
		AutoloadConfig = nil,
		Library = lib,
	}

	local function http(): any
		return env.service("HttpService")
	end

	local function settings(): string
		local path = save.Folder .. "/settings"
		if save.SubFolder ~= "" then
			path ..= "/" .. save.SubFolder
		end
		return path
	end

	local function globalFn(name: string): any
		return env.global(name)
	end

	local function configPath(name: string): string
		return settings() .. "/" .. name .. ".json"
	end

	local function ensure()
		local store = env.files()
		if store then
			store.folder(settings())
			store.folder(save.Folder .. "/themes")
		end
	end

	local function configExists(name: string): boolean
		local store = env.files()
		return store ~= nil and store.exists(configPath(name))
	end

	function save.SetLibrary(_: any) end

	function save.SetFolder(_: any, folder: string)
		save.Folder = folder
		ensure()
	end

	function save.SetSubFolder(_: any, sub: string)
		save.SubFolder = sub
		ensure()
	end

	function save.SetIgnoreIndexes(_: any, list: { string })
		for _, index in list do
			save.Ignore[index] = true
		end
	end

	function save.IgnoreThemeSettings(_: any)
		save:SetIgnoreIndexes({ "ThemeManager_Preset", "ThemeManager_Scale", "ThemeManager_Motion" })
	end

	function save.RefreshConfigList(_: any): { string }
		local listfiles = globalFn("listfiles")
		if type(listfiles) ~= "function" then
			return {}
		end
		ensure()
		local ok, found = pcall(listfiles, settings())
		if not ok or type(found) ~= "table" then
			return {}
		end
		local names = {}
		for _, path in found do
			local clean = string.gsub(path, "\\", "/")
			local name = string.match(clean, "([^/]+)%.[^/.]+$")
			if name and name ~= "autoload" then
				table.insert(names, name)
			end
		end
		table.sort(names)
		return names
	end

	local saver: { [string]: (proxy: any) -> any } = {
		Toggle = function(proxy)
			return { value = proxy.Value }
		end,
		Slider = function(proxy)
			return { value = tostring(proxy.Value) }
		end,
		Dropdown = function(proxy)
			local value = proxy.Value
			if typeof(value) == "Instance" then
				value = value.Name
			end
			return { value = value, multi = proxy.Multi }
		end,
		ColorPicker = function(proxy)
			return { value = proxy.Value:ToHex(), transparency = proxy.Transparency }
		end,
		KeyPicker = function(proxy)
			return { mode = proxy.Mode, key = proxy.Value, modifiers = proxy.Modifiers, toggled = proxy.Toggled }
		end,
		Input = function(proxy)
			return { text = proxy.Value }
		end,
	}

	local loader: { [string]: (proxy: any, data: any) -> () } = {
		Toggle = function(proxy, data)
			if proxy.Value == data.value then
				proxy:RunChanged()
			else
				proxy:SetValue(data.value)
			end
		end,
		Slider = function(proxy, data)
			if proxy.Value == data.value then
				proxy:RunChanged()
			else
				proxy:SetValue(data.value)
			end
		end,
		Dropdown = function(proxy, data)
			if proxy.Value == data.value then
				proxy:RunChanged()
			else
				proxy:SetValue(data.value)
			end
		end,
		ColorPicker = function(proxy, data)
			proxy:SetValueRGB(Color3.fromHex(data.value), data.transparency)
		end,
		KeyPicker = function(proxy, data)
			proxy:SetValue({ data.key, data.mode, data.modifiers })
			if data.mode == "Toggle" and data.toggled ~= nil then
				proxy.Toggled = data.toggled
				proxy._el.toggled = data.toggled
				proxy:Update()
			end
		end,
		Input = function(proxy, data)
			if type(data.text) ~= "string" then
				return
			end
			if proxy.Value == data.text then
				proxy:RunChanged()
			else
				proxy:SetValue(data.text)
			end
		end,
	}

	function save.SaveJSON(_: any, name: string?): (string, boolean, string?)
		local objects = {}
		local function collect(shelf: { [string]: any })
			for index, proxy in shelf do
				local parse = saver[proxy.Type]
				if parse and not save.Ignore[index] then
					local data = parse(proxy)
					data.type = proxy.Type
					data.idx = index
					table.insert(objects, data)
				end
			end
		end
		collect(lib.Toggles)
		collect(lib.Options)
		local ok, encoded = pcall(function()
			return http():JSONEncode({ timestamp = os.date("%d.%m.%Y %H:%M:%S"), name = name or "", objects = objects })
		end)
		if not ok then
			return "", false, "Failed to encode data"
		end
		return encoded, true
	end

	function save.Save(_: any, name: string): (boolean, string?)
		if isEmpty(name) or string.lower(name) == "autoload" then
			return false, "Invalid config name provided"
		end
		ensure()
		local encoded, ok, err = save:SaveJSON(name)
		if not ok then
			return false, err
		end
		local store = env.files()
		if store == nil or not store.write(configPath(name), encoded) then
			return false, "Failed to write config file"
		end
		return true
	end

	function save.LoadJSON(_: any, content: string): (boolean, string?)
		if isEmpty(content) then
			return false, "No JSON provided"
		end
		local ok, decoded = pcall(function()
			return http():JSONDecode(content)
		end)
		if not ok or type(decoded) ~= "table" or type(decoded.objects) ~= "table" then
			return false, "Failed to decode config data"
		end
		for _, data in decoded.objects do
			local load = loader[data.type]
			if load and not save.Ignore[data.idx] then
				-- one thread each: a yielding callback must not hold up every setting after it
				task.defer(function()
					local proxy = lib.Toggles[data.idx] or lib.Options[data.idx]
					if proxy and proxy.Type == data.type then
						local done, err: any = pcall(load, proxy, data)
						if not done then
							warn("sottUI compat: config value " .. tostring(data.idx) .. " failed: " .. tostring(err))
						end
					end
				end)
			end
		end
		return true
	end

	function save.Load(_: any, name: string): (boolean, string?)
		if isEmpty(name) then
			return false, "No config is selected"
		end
		local store = env.files()
		local content = store and store.read(configPath(name))
		if content == nil then
			return false, "Config file does not exist"
		end
		return save:LoadJSON(content)
	end

	function save.Delete(_: any, name: string): (boolean, string?)
		if isEmpty(name) then
			return false, "No config is selected"
		end
		if not configExists(name) then
			return false, "Config file does not exist"
		end
		local delfile = globalFn("delfile")
		local ok, err = pcall(delfile, configPath(name))
		if not ok then
			return false, "Failed to delete config file: " .. tostring(err)
		end
		if name == save.AutoloadConfig then
			save:DeleteAutoLoadConfig()
		end
		return true
	end

	local function autoloadPath(): string
		return settings() .. "/autoload.txt"
	end

	function save.GetAutoloadConfig(_: any): (string, boolean, string?)
		ensure()
		local store = env.files()
		local name = store and store.read(autoloadPath())
		if name == nil then
			return "none", false, "Autoload config is not set"
		end
		if not configExists(name) then
			return "none", false, "Config file not found"
		end
		save.AutoloadConfig = name
		return name, true
	end

	function save.SaveAutoloadConfig(_: any, name: string): (boolean, string?)
		if isEmpty(name) then
			return false, "No config is selected"
		end
		if not configExists(name) then
			return false, "Config does not exist"
		end
		local store = env.files()
		if store == nil or not store.write(autoloadPath(), name) then
			return false, "Failed to write the autoload file"
		end
		save.AutoloadConfig = name
		return true
	end

	function save.DeleteAutoLoadConfig(_: any): (boolean, string?)
		local store = env.files()
		if store == nil or not store.exists(autoloadPath()) then
			return false, "Autoload config is not set"
		end
		local delfile = globalFn("delfile")
		local ok, err = pcall(delfile, autoloadPath())
		if not ok then
			return false, tostring(err)
		end
		save.AutoloadConfig = nil
		return true
	end

	function save.LoadAutoloadConfig(_: any)
		local name, ok, err = save:GetAutoloadConfig()
		if not ok or err then
			if err ~= "Autoload config is not set" then
				lib:Notify(string.format("Failed to load autoload config: %s", tostring(err)))
			end
			return
		end
		local loaded, problem = save:Load(name)
		if not loaded then
			lib:Notify(string.format("Failed to load autoload config: %s", tostring(problem)))
			return
		end
		lib:Notify(string.format("Loaded config %q", name))
	end

	function save.BuildConfigSection(_: any, tab: any)
		local box = tab:AddGroupbox({ Name = "Configs" })
		local nameInput: any = box:AddInput("SaveManager_ConfigName", { Text = "Name", Placeholder = "New config" })
		local list: any = box:AddDropdown("SaveManager_ConfigList", {
			Text = "Saved",
			Values = save:RefreshConfigList(),
			AllowNull = true,
			FormatDisplayValue = function(value: any): string
				return if value == save.AutoloadConfig then value .. " (autoload)" else tostring(value)
			end,
		})
		save.Ignore["SaveManager_ConfigName"] = true
		save.Ignore["SaveManager_ConfigList"] = true

		local function refresh()
			list:SetValues(save:RefreshConfigList())
		end
		local function selected(): string?
			local value = list.Value
			if isEmpty(value) then
				lib:Notify("Pick a config first")
				return nil
			end
			return value
		end
		local function report(ok: boolean, err: string?, success: string)
			lib:Notify(if ok then success else tostring(err))
		end

		box:AddButton("Create", function()
			local name = nameInput.Value
			if isEmpty(name) then
				lib:Notify("Give the config a name first")
				return
			end
			local ok, err = save:Save(name)
			report(ok, err, string.format("Created %q", name))
			refresh()
		end)
		box:AddButton({
			Text = "Load",
			Func = function()
				local name = selected()
				if name then
					local ok, err = save:Load(name)
					report(ok, err, string.format("Loaded %q", name))
				end
			end,
		})
		box:AddButton({
			Text = "Overwrite",
			DoubleClick = true,
			Func = function()
				local name = selected()
				if name then
					local ok, err = save:Save(name)
					report(ok, err, string.format("Saved over %q", name))
				end
			end,
		})
		box:AddButton({
			Text = "Load at start",
			Func = function()
				local name = selected()
				if name then
					local ok, err = save:SaveAutoloadConfig(name)
					report(ok, err, string.format("%q loads at start", name))
					refresh()
				end
			end,
		})
		box:AddButton({
			Text = "Load nothing at start",
			Func = function()
				local ok, err = save:DeleteAutoLoadConfig()
				report(ok, err, "No config loads at start")
				refresh()
			end,
		})
		box:AddButton("Refresh list", refresh)
		box:AddButton({
			Text = "Delete",
			DoubleClick = true,
			Risky = true,
			Func = function()
				local name = selected()
				if name then
					local ok, err = save:Delete(name)
					report(ok, err, string.format("Deleted %q", name))
					list:SetValue(nil)
					refresh()
				end
			end,
		})
		return box
	end

	return save
end

return saveManager
