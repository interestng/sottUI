--!strict
-- Obsidian's shape over sottUI, so a host written against Library:CreateWindow and Toggles/Options runs unchanged. it is
-- here and not in the host so the host's own bundle stays small. behavior follows obs-fork v1.0.2 where callers depend
-- on it, including the odd parts: a toggle's SetValue fires when nothing changed, a slider's does not

local env = require("../core/env")
local saveManager = require("./savemanager")
local themeManager = require("./thememanager")

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

-- only what a dependency box can read marks the rules dirty: a slider tick must not lay out every page each frame
local function sync(proxy: any, read: (el: any) -> any, ruleSource: boolean?)
	proxy._el:on(function()
		proxy.Value = read(proxy._el)
		proxy:RunChanged()
		if ruleSource then
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
		picker.Toggled = self.Value
	end
end

function Slider.SetValue(self: any, value: any)
	self._el:set(value)
end

function Slider.SetMax(self: any, max: number)
	self.Max = max
	self._el.spec.max = max
	self._el:set(self._el.value)
	local view = self._el._view
	if view then
		view.refresh()
	end
end

function Slider.SetMin(self: any, min: number)
	self.Min = min
	self._el.spec.min = min
	self._el:set(self._el.value)
	local view = self._el._view
	if view then
		view.refresh()
	end
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
	local section = self._section
	local spec = tips(info, { label = info.Text or idx, default = info.Default == true })
	-- the hub's convention: a groupbox opening with "Enabled" is one feature with options, which is what a master is
	local first = #section.rows == 0 and section._root == nil and section.title ~= ""
	local el
	if first and (info.Text == "Enabled" or info.Text == section.title) then
		spec.label = section.title
		el = section:master(idx, spec)
	else
		el = section:toggle(idx, spec)
	end
	local proxy = setmetatable(common(self._lib, "Toggle", el, info), Toggle) :: any
	proxy.Value = el.value
	proxy._pickers = {}
	proxy._box = self
	sync(proxy, function(e: any)
		for _, picker in proxy._pickers do
			picker._el.toggled = e.value
			picker.Toggled = e.value
		end
		return e.value
	end, true)
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
	end, true)
	if special then
		local players = env.service("Players")
		local function refresh()
			proxy:SetValues(playerList(info.ExcludeLocalPlayer == true))
		end
		table.insert(self._lib._connections, players.PlayerAdded:Connect(refresh))
		table.insert(
			self._lib._connections,
			players.PlayerRemoving:Connect(function()
				task.defer(refresh)
			end)
		)
	end
	return register(self._lib, "Options", idx, proxy)
end

function Box.AddButton(self: any, info: any, func: any): any
	local options: any = if type(info) == "table" then info else { Text = info, Func = func }
	local el = self._section:button(
		options.Text or "",
		tips(options, { confirm = options.DoubleClick == true, danger = options.Risky == true })
	)
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

function Box.AddLabel(self: any, a: any, b: any): any
	if type(b) == "table" then
		local proxy = buildLabel(self, b)
		register(self._lib, "Options", a, proxy)
		return proxy
	end
	return buildLabel(self, a, b)
end

-- not an obsidian method: a host that knows it is on sottUI uses it for live figures
function Box.AddStat(self: any, label: string, value: any): any
	local el = self._section:stat(label, value)
	return {
		SetValue = function(_: any, next: any)
			el:set(next)
		end,
	}
end

function Box.AddDivider(self: any, info: any)
	local text = if type(info) == "table" then info.Text else info
	self._section:divider(text)
end

function Box.AddBlank() end

function Box.AddDependencyBox(self: any): any
	local rules: { any } = {}
	local lib = self._lib
	self._section._page._guarded = true
	local owner = self._section._root or self._section
	local child = self._section:when(function(): boolean
		for _, rule in rules do
			local element, expected = rule[1], rule[2]
			-- the master's own fold already decides this; a rule on it would keep a peek empty
			if element._el == owner.masterElement and expected == true then
				continue
			end
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
	local mouse = ({ MB1 = "MouseButton1", MB2 = "MouseButton2", MB3 = "MouseButton3" })[name]
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
		label = owner._el.label or info.Text or idx,
		default = info.Default or "None",
		mode = mode,
		modes = modes,
		modifiers = info.DefaultModifiers or {},
		chipless = info.NoUI == true,
		noMouse = false,
		onPress = function(element: any, toggled: boolean)
			if lib.ToggleKeybind == proxy then
				lib.window:toggle()
				return
			end
			if owner.Type == "Toggle" and owner.Disabled then
				-- obsidian ignores a bind whose parent is disabled, the state must not drift from what is shown
				element.toggled = owner.Value
				return
			end
			proxy.Toggled = toggled
			local mode = element.value.mode
			if sync_ and owner.Type == "Toggle" then
				if mode == "Toggle" then
					owner:SetValue(toggled)
				elseif mode == "Hold" then
					owner:SetValue(true)
				end
			end
			if mode == "Toggle" or mode == "Press" then
				protect(proxy.Clicked, toggled)
				protect(proxy.Callback, toggled)
			end
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
			self._lib.Hero = page:hero({ userId = player.UserId, title = player.DisplayName, text = self._footer })
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

	-- a change marks once and each page with rules lays out at most once a frame
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
				if page._guarded then
					page:_invalidate()
				end
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
		SaveManager = saveManager.new(Library),
		ThemeManager = themeManager.new(Library),
	}
end

return obsidian
