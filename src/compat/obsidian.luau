--!strict
-- Obsidian's shape over sottUI, so a host built on Library:CreateWindow, Toggles/Options and SaveManager runs unchanged.
-- it lives in this repo and not the host because it is pulled with the library: the host's own bundle stays small.
-- every behavior here is copied from obs-fork v1.0.2 where callers depend on it, including the odd ones (a toggle's
-- SetValue fires even when nothing changed, a slider's does not), and the config files stay byte compatible

local env = require("../core/env")

local obsidian = {}

local function warnf(message: string)
	warn("sottUI compat: " .. message)
end

local function protect(fn: any, ...: any)
	if type(fn) ~= "function" then
		return
	end
	local ok, err: any = xpcall(fn, debug.traceback, ...)
	if not ok then
		warnf("callback failed: " .. tostring(err))
	end
end

local function isEmpty(text: any): boolean
	return type(text) ~= "string" or string.gsub(text, "%s", "") == ""
end

local Base = {}
Base.__index = Base

function Base.RunChanged(self: any, ...: any)
	if self.Disabled then
		return
	end
	local value = self.Value
	if select("#", ...) > 0 then
		protect(self.Callback, ...)
		protect(self.Changed, ...)
	else
		protect(self.Callback, value)
		protect(self.Changed, value)
	end
end

function Base.OnChanged(self: any, fn: any)
	self.Changed = fn
end

function Base.SetVisible(self: any, visible: boolean)
	self.Visible = visible
	self._el:setVisible(visible)
end

function Base.SetDisabled(self: any, disabled: boolean)
	self.Disabled = disabled == true
	self._el:setDisabled(self.Disabled)
	if self._lib then
		self._lib:_rulesChanged()
	end
end

function Base.SetText(self: any, text: string)
	self.Text = text
	self._el:setLabel(text)
end

function Base.Update(_: any) end

local function class(): any
	local c = setmetatable({}, { __index = Base })
	c.__index = c
	return c
end

local Toggle = class()
local Slider = class()
local Input = class()
local Dropdown = class()
local ColorPicker = class()
local KeyPicker = class()
local Label = class()
local Button = class()

local function sync(proxy: any, read: (el: any) -> any)
	proxy._el:on(function()
		proxy.Value = read(proxy._el)
		proxy:RunChanged()
		if proxy._lib then
			proxy._lib:_rulesChanged()
		end
	end)
end

function Toggle.SetValue(self: any, value: any)
	-- obsidian fires on every SetValue, changed or not, and config loads count on it
	if not self._el:set(value == true) then
		self:RunChanged()
	end
	for _, picker in self._pickers do
		picker._el.toggled = self.Value
	end
end

function Slider.SetValue(self: any, value: any)
	self._el:set(value)
end

function Slider.SetMax(self: any, max: number)
	self.Max = max
	self._el.spec.max = max
	self._el:set(self._el.value)
	self._el:setLabel(self.Text)
end

function Slider.SetMin(self: any, min: number)
	self.Min = min
	self._el.spec.min = min
	self._el:set(self._el.value)
	self._el:setLabel(self.Text)
end

function Input.SetValue(self: any, value: any)
	if not self._el:set(value) then
		self:RunChanged()
	end
end

function Dropdown.SetValue(self: any, value: any)
	if type(value) == "string" and self.SpecialType == "Player" then
		local player = env.service("Players"):FindFirstChild(value)
		value = player
	end
	if not self._el:set(value) then
		self:RunChanged()
	end
end

function Dropdown.SetValues(self: any, values: { any })
	self._el:setOptions(values)
	self.Values = self._el.spec.options
end

function Dropdown.AddValues(self: any, more: any)
	local list = table.clone(self._el.spec.options)
	if type(more) == "table" then
		for _, value in more do
			table.insert(list, value)
		end
	else
		table.insert(list, more)
	end
	self:SetValues(list)
end

function Dropdown.GetActiveValues(self: any): any
	if self.Multi then
		local list = {}
		for pick, on in self.Value do
			if on then
				table.insert(list, pick)
			end
		end
		return list
	end
	return if self.Value then 1 else 0
end

function ColorPicker.SetValueRGB(self: any, color: Color3, transparency: number?)
	local alpha = if self._hasAlpha then transparency or 0 else 0
	if not self._el:set({ color = color, alpha = alpha }) then
		self:RunChanged(self.Value)
	end
end

function ColorPicker.SetValue(self: any, value: any, transparency: number?)
	if typeof(value) == "Color3" then
		self:SetValueRGB(value, transparency)
	elseif type(value) == "table" then
		self:SetValueRGB(Color3.fromHSV(value[1], value[2], value[3]), transparency)
	end
end

function KeyPicker.SetValue(self: any, value: any)
	if type(value) == "string" then
		value = { value }
	end
	self._el:set({ key = value[1], mode = value[2], modifiers = value[3] or {} })
end

function KeyPicker.GetState(self: any): boolean
	return self._lib.window.keys:state(self._el)
end

function KeyPicker.OnClick(self: any, fn: any)
	self.Clicked = fn
end

function Label.SetText(self: any, text: string)
	self.Text = text
	self._el:setLabel(text)
end

function Button.SetText(self: any, text: string)
	self.Text = text
	self._el:setLabel(text)
end

local Box = {}
Box.__index = Box

local function register(lib: any, shelf: string, idx: string, proxy: any): any
	lib[shelf][idx] = proxy
	proxy._idx = idx
	if lib._dialogIndexes then
		table.insert(lib._dialogIndexes, { shelf = shelf, idx = idx })
	end
	return proxy
end

local function common(lib: any, kind: string, el: any, info: any): any
	return {
		Type = kind,
		Text = info.Text,
		Disabled = info.Disabled == true,
		Visible = info.Visible ~= false,
		Tooltip = info.Tooltip,
		Callback = info.Callback,
		Changed = info.Changed,
		_el = el,
		_lib = lib,
	}
end

local function tips(info: any, spec: any): any
	spec.tip = info.Tooltip
	spec.disabled = info.Disabled == true
	spec.disabledTip = info.DisabledTooltip
	spec.visible = info.Visible ~= false
	return spec
end

function Box.AddToggle(self: any, idx: string, info: any): any
	local el = self._section:toggle(idx, tips(info, { label = info.Text or idx, default = info.Default == true }))
	local proxy = setmetatable(common(self._lib, "Toggle", el, info), Toggle) :: any
	proxy.Value = el.value
	proxy._pickers = {}
	proxy._box = self
	sync(proxy, function(e: any)
		for _, picker in proxy._pickers do
			picker._el.toggled = e.value
		end
		return e.value
	end)
	return register(self._lib, "Toggles", idx, proxy)
end

Box.AddCheckbox = Box.AddToggle

function Box.AddSlider(self: any, idx: string, info: any): any
	local rounding = tonumber(info.Rounding) or 0
	local format = info.FormatDisplayValue
	local proxy: any
	local spec = tips(info, {
		label = info.Text or idx,
		min = info.Min,
		max = info.Max,
		step = 10 ^ -rounding,
		decimals = rounding,
		suffix = info.Suffix,
		default = info.Default,
		format = if format
			then function(_: any, value: number)
				return format(proxy, value)
			end
			else nil,
	})
	local el = self._section:slider(idx, spec)
	proxy = setmetatable(common(self._lib, "Slider", el, info), Slider)
	proxy.Value = el.value
	proxy.Min, proxy.Max, proxy.Rounding = info.Min, info.Max, rounding
	sync(proxy, function(e: any)
		return e.value
	end)
	return register(self._lib, "Options", idx, proxy)
end

function Box.AddInput(self: any, idx: string, info: any): any
	local el = self._section:input(
		idx,
		tips(info, {
			label = info.Text or "",
			default = info.Default or "",
			placeholder = info.Placeholder,
			numeric = info.Numeric == true,
			finished = info.Finished == true or info.VerifyValue ~= nil,
			maxLength = info.MaxLength,
			verify = info.VerifyValue,
		})
	)
	local proxy = setmetatable(common(self._lib, "Input", el, info), Input) :: any
	proxy.Value = el.value
	proxy.Numeric = info.Numeric == true
	sync(proxy, function(e: any)
		return e.value
	end)
	return register(self._lib, "Options", idx, proxy)
end

local function playerList(exclude: boolean): { any }
	local players = env.service("Players")
	local list = {}
	for _, player in players:GetPlayers() do
		if not (exclude and player == players.LocalPlayer) then
			table.insert(list, player)
		end
	end
	return list
end

function Box.AddDropdown(self: any, idx: string, info: any): any
	local special = info.SpecialType == "Player"
	local values = if special then playerList(info.ExcludeLocalPlayer == true) else (info.Values or {})
	local multi = info.Multi == true
	local default = info.Default
	if type(default) == "number" then
		default = values[default]
	end
	if multi and type(default) == "string" then
		default = { default }
	end
	local format = info.FormatDisplayValue
	local el = self._section:dropdown(
		idx,
		tips(info, {
			label = info.Text or idx,
			options = values,
			multi = multi,
			default = default,
			searchable = info.Searchable == true,
			allowNull = info.AllowNull == true or special,
			display = function(value: any): string
				local shown = if special then value.Name else value
				if format then
					local ok, text = pcall(format, shown)
					if ok and text ~= nil then
						return tostring(text)
					end
				end
				return tostring(shown)
			end,
		})
	)
	local proxy = setmetatable(common(self._lib, "Dropdown", el, info), Dropdown) :: any
	proxy.Value = el.value
	proxy.Values = el.spec.options
	proxy.Multi = multi
	proxy.SpecialType = info.SpecialType
	sync(proxy, function(e: any)
		return e.value
	end)
	if special then
		local players = env.service("Players")
		local function refresh()
			proxy:SetValues(playerList(info.ExcludeLocalPlayer == true))
		end
		table.insert(self._lib._connections, players.PlayerAdded:Connect(refresh))
		table.insert(self._lib._connections, players.PlayerRemoving:Connect(function()
			task.defer(refresh)
		end))
	end
	return register(self._lib, "Options", idx, proxy)
end

function Box.AddButton(self: any, info: any, func: any): any
	local options: any = if type(info) == "table" then info else { Text = info, Func = func }
	local el = self._section:button(options.Text or "", tips(options, { confirm = options.DoubleClick == true }))
	local proxy = setmetatable(common(self._lib, "Button", el, options), Button) :: any
	proxy.Func = options.Func
	el:on(function()
		protect(proxy.Func)
	end)
	return proxy
end

local function buildLabel(self: any, text: any, wrap: any): any
	local options: any = if type(text) == "table" then text else { Text = text, DoesWrap = wrap }
	local el = self._section:label(tostring(options.Text or ""), { wrap = options.DoesWrap == true or wrap == true })
	local proxy = setmetatable(common(self._lib, "Label", el, options), Label) :: any
	proxy.TextLabel = {}
	proxy._box = self
	return proxy
end

function Box.AddLabel(self: any, a: any, b: any, c: any): any
	-- AddLabel(idx, info) exists too; the plain text form is what the hub calls
	if type(b) == "table" then
		local proxy = buildLabel(self, b)
		register(self._lib, "Options", a, proxy)
		return proxy
	end
	local _ = c
	return buildLabel(self, a, b)
end

function Box.AddDivider(self: any, info: any)
	local text = if type(info) == "table" then info.Text else info
	self._section:divider(text)
end

function Box.AddBlank() end

function Box.AddDependencyBox(self: any): any
	local rules: { any } = {}
	local lib = self._lib
	local child = self._section:when(function(): boolean
		for _, rule in rules do
			local element, expected = rule[1], rule[2]
			if element.Disabled then
				return false
			end
			local value = element.Value
			if element.Type == "Dropdown" and type(value) == "table" then
				if not value[expected] then
					return false
				end
			elseif value ~= expected then
				return false
			end
		end
		return true
	end)
	local depbox = setmetatable({ _section = child, _lib = lib }, Box) :: any
	function depbox.SetupDependencies(_: any, list: { any })
		rules = list
		self._section._page:_invalidate()
	end
	return depbox
end

function Box.SetCollapsed() end

local function attachColor(lib: any, owner: any, idx: string, info: any): any
	local hasAlpha = info.Transparency ~= nil
	local section = owner._box._section
	local el = section:addColor(owner._el, idx, {
		label = info.Title or owner.Text or idx,
		default = info.Default or Color3.new(1, 1, 1),
		alpha = hasAlpha,
		alphaValue = if hasAlpha then info.Transparency else 0,
	})
	local proxy = setmetatable(common(lib, "ColorPicker", el, info), ColorPicker) :: any
	proxy.Value = el.value.color
	proxy.Transparency = el.value.alpha
	proxy._hasAlpha = hasAlpha
	el:on(function()
		proxy.Value = el.value.color
		proxy.Transparency = el.value.alpha
		proxy:RunChanged(proxy.Value)
	end)
	return register(lib, "Options", idx, proxy)
end

local function keyArgument(name: string): any
	local mouse = ({ MB1 = "MouseButton1", MB2 = "MouseButton2", MB3 = "MouseButton3" }) [name]
	if mouse then
		return (Enum.UserInputType :: any)[mouse]
	end
	local ok, code = pcall(function()
		return (Enum.KeyCode :: any)[name]
	end)
	return if ok then code else nil
end

local function attachKey(lib: any, owner: any, idx: string, info: any): any
	local section = owner._box._section
	local sync_ = info.SyncToggleState == true
	local modes = if sync_ then { "Toggle", "Hold" } else info.Modes or { "Always", "Toggle", "Hold" }
	local mode = info.Mode or "Toggle"
	local proxy: any
	local el = section:addKey(owner._el, idx, {
		label = info.Text or owner.Text or idx,
		default = info.Default or "None",
		mode = mode,
		modes = modes,
		modifiers = info.DefaultModifiers or {},
		chipless = info.NoUI == true,
		noMouse = false,
		onPress = function(element: any, toggled: boolean)
			proxy.Toggled = toggled
			if lib.ToggleKeybind == proxy then
				lib.window:toggle()
				return
			end
			if sync_ and owner.Type == "Toggle" and not owner.Disabled then
				if element.value.mode == "Toggle" then
					owner:SetValue(toggled)
				elseif element.value.mode == "Hold" then
					owner:SetValue(true)
				end
			end
			protect(proxy.Clicked, toggled)
			protect(proxy.Callback, toggled)
		end,
		onRelease = function(element: any)
			if sync_ and owner.Type == "Toggle" and element.value.mode == "Hold" and not owner.Disabled then
				owner:SetValue(false)
			end
		end,
	})
	proxy = setmetatable(common(lib, "KeyPicker", el, info), KeyPicker)
	proxy.Value = el.value.key
	proxy.Mode = el.value.mode
	proxy.Modifiers = el.value.modifiers
	proxy.Modes = modes
	proxy.SyncToggleState = sync_
	proxy.NoUI = info.NoUI == true
	proxy.Toggled = false
	proxy.ChangedCallback = info.ChangedCallback
	el:on(function()
		local value = el.value
		proxy.Value = value.key
		proxy.Mode = value.mode
		proxy.Modifiers = value.modifiers
		proxy:Update()
		local argument = keyArgument(value.key)
		protect(proxy.ChangedCallback, argument, value.modifiers)
		protect(proxy.Changed, argument, value.modifiers)
	end)
	if owner.Type == "Toggle" and sync_ then
		table.insert(owner._pickers, proxy)
		el.toggled = owner.Value
	end
	return register(lib, "Options", idx, proxy)
end

-- obsidian returns the parent from both, for chaining, and the facade reads the element back from Options
function Toggle.AddColorPicker(self: any, idx: string, info: any): any
	attachColor(self._lib, self, idx, info)
	return self
end
function Toggle.AddKeyPicker(self: any, idx: string, info: any): any
	attachKey(self._lib, self, idx, info)
	return self
end
Label.AddColorPicker = Toggle.AddColorPicker
Label.AddKeyPicker = Toggle.AddKeyPicker

local Tab = {}
Tab.__index = Tab

local function makeBox(lib: any, section: any): any
	return setmetatable({ _section = section, _lib = lib }, Box)
end

local function sectionBox(self: any, title: string): any
	local section = self._page:section(title)
	local box = makeBox(self._lib, section)
	return box
end

function Tab.AddLeftGroupbox(self: any, title: string): any
	return sectionBox(self, title)
end
Tab.AddRightGroupbox = Tab.AddLeftGroupbox

function Tab.AddGroupbox(self: any, info: any): any
	return sectionBox(self, info.Name)
end

local function tabbox(self: any): any
	local holder = self._page:tabset()
	local lib = self._lib
	return {
		AddTab = function(_: any, name: string): any
			return makeBox(lib, holder:tab(name))
		end,
	}
end
Tab.AddLeftTabbox = tabbox
Tab.AddRightTabbox = tabbox

local Window = {}
Window.__index = Window

function Window.AddTab(self: any, info: any, _icon: any): any
	local name = if type(info) == "table" then info.Name else info
	local page = self._lib.window:page(name)
	if name == "Home" then
		local player = env.service("Players").LocalPlayer
		if player then
			page:hero({ userId = player.UserId, title = player.DisplayName, text = self._footer })
		end
	end
	local tab = setmetatable({ _page = page, _lib = self._lib }, Tab)
	self._lib.Tabs[name] = tab
	return tab
end

-- a config never owns a dialog's elements, and their ids may repeat next time it opens
function Window.OpenDialog(self: any, options: any, build: (box: any) -> ()): boolean
	local lib = self._lib
	local native = lib.window
	local previous = lib._dialogIndexes
	return native:dialog({
		title = options.title,
		text = options.description,
		done = options.done,
		maxHeight = options.maxHeight,
		onClose = function()
			local entries = lib._dialogOwned
			for _, entry in entries or {} do
				lib[entry.shelf][entry.idx] = nil
			end
			lib._dialogOwned = nil
			if options.onClose then
				options.onClose()
			end
		end,
	}, function(section: any)
		lib._dialogIndexes = {}
		build(makeBox(lib, section))
		lib._dialogOwned = lib._dialogIndexes
		lib._dialogIndexes = previous
	end)
end

local function newSaveManager(lib: any): any
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
							warnf("config value " .. tostring(data.idx) .. " failed: " .. tostring(err))
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
			Text = "Delete",
			DoubleClick = true,
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
		return box
	end

	return save
end

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

local function newThemeManager(lib: any): any
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

function obsidian.new(sottui: any): { Library: any, SaveManager: any, ThemeManager: any }
	local rulesDirty = false
	local Library: any = setmetatable({
		Toggles = {},
		Options = {},
		Tabs = {},
		Toggled = false,
		ScreenGui = nil,
		Scheme = {
			AccentColor = Color3.fromHex("7EE0C4"),
			BackgroundColor = Color3.fromHex("07100D"),
			MainColor = Color3.fromHex("141C18"),
			OutlineColor = Color3.fromHex("1A2D27"),
			FontColor = Color3.fromHex("EBE8DA"),
		},
		ShowToggleFrameInKeybinds = true,
		IsSottUI = true,
		_connections = {},
		_unloads = {},
	}, {})

	-- dependency sources are every element, so a change marks once and the page lays out at most once a frame
	function Library._rulesChanged(self: any)
		if rulesDirty or self.window == nil then
			return
		end
		rulesDirty = true
		task.defer(function()
			rulesDirty = false
			if self.window == nil or self.window.destroyed then
				return
			end
			for _, page in self.window.pages do
				page:_invalidate()
			end
		end)
	end

	function Library.CreateWindow(self: any, info: any): any
		local native = sottui.window({
			title = info.Title,
			subtitle = info.Footer,
			folder = info.Folder,
			stateFile = info.StateFile,
			autoShow = info.AutoShow ~= false,
		})
		self.window = native
		self.ScreenGui = native._gui
		self.Toggled = info.AutoShow ~= false
		native.visibilityChanged:connect(function(open: boolean)
			self.Toggled = open
		end)
		local proxy = setmetatable({ _lib = self, _footer = info.Footer }, Window)
		self.Window = proxy
		return proxy
	end

	function Library.Notify(self: any, info: any, seconds: number?)
		if self.window == nil then
			return
		end
		if type(info) == "table" then
			self.window:notify({ title = info.Title, text = info.Description, seconds = info.Time or seconds })
		else
			self.window:notify({ text = tostring(info), seconds = seconds })
		end
	end

	function Library.Toggle(self: any, value: boolean?)
		if self.window then
			if value == nil then
				self.window:toggle()
			else
				self.window:setOpen(value)
			end
		end
	end

	function Library.SafeCallback(_: any, fn: any, ...: any)
		protect(fn, ...)
	end

	function Library.OnUnload(self: any, fn: any)
		table.insert(self._unloads, fn)
	end

	function Library.Unload(self: any)
		for _, fn in self._unloads do
			protect(fn)
		end
		for _, connection in self._connections do
			connection:Disconnect()
		end
		self._connections = {}
		if self.window then
			self.window:destroy()
			self.window = nil
		end
		self.ScreenGui = nil
		self.Toggled = false
	end

	-- assigning ToggleKeybind hands the menu to that picker; the native default key must stop answering or both fire
	getmetatable(Library).__newindex = function(self: any, key: string, value: any)
		rawset(self, key, value)
		if key == "ToggleKeybind" and self.window and self.window.menuKey then
			self.window.keys:unregister(self.window.menuKey)
		end
	end

	return {
		Library = Library,
		SaveManager = newSaveManager(Library),
		ThemeManager = newThemeManager(Library),
	}
end

return obsidian
