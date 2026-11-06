--!strict
-- every bound key goes through one listener. key elements are models, so binds work on pages nobody has opened

local keys = {}

local MOUSE_NAMES: { [any]: string } = {
	[Enum.UserInputType.MouseButton1] = "MB1",
	[Enum.UserInputType.MouseButton2] = "MB2",
	[Enum.UserInputType.MouseButton3] = "MB3",
}

local MOUSE_BUTTONS: { [string]: any } = {
	MB1 = Enum.UserInputType.MouseButton1,
	MB2 = Enum.UserInputType.MouseButton2,
	MB3 = Enum.UserInputType.MouseButton3,
}

local MODIFIER_NAMES: { [any]: string } = {
	[Enum.KeyCode.LeftAlt] = "LAlt",
	[Enum.KeyCode.RightAlt] = "RAlt",
	[Enum.KeyCode.LeftControl] = "LCtrl",
	[Enum.KeyCode.RightControl] = "RCtrl",
	[Enum.KeyCode.LeftShift] = "LShift",
	[Enum.KeyCode.RightShift] = "RShift",
}

local function nameOf(event: any): string?
	local mouse = MOUSE_NAMES[event.UserInputType]
	if mouse then
		return mouse
	end
	if event.UserInputType == Enum.UserInputType.Keyboard and event.KeyCode.Name ~= "Unknown" then
		return event.KeyCode.Name
	end
	return nil
end

function keys.new(router: any, env: any, menuOpen: () -> boolean): any
	local uis = env.service("UserInputService")
	local api: any = {}
	local bound: { any } = {}
	local listener: ((string?, { string }?) -> ())? = nil
	local listenerNoMouse = false
	local pendingModifier: string? = nil
	-- the press that finished a rebind must not also activate the new bind on the same event
	local swallow: string? = nil

	local function modifiersHeld(required: { string }?): boolean
		for _, name in (required or {}) :: { string } do
			local found = false
			for code, label in MODIFIER_NAMES do
				if label == name and uis:IsKeyDown(code) then
					found = true
				end
			end
			if not found then
				return false
			end
		end
		return true
	end

	local function heldModifiers(except: string): { string }
		local out = {}
		for code, label in MODIFIER_NAMES do
			if code.Name ~= except and uis:IsKeyDown(code) then
				table.insert(out, label)
			end
		end
		table.sort(out)
		return out
	end

	function api.register(_: any, el: any)
		table.insert(bound, el)
	end

	function api.unregister(_: any, el: any)
		local at = table.find(bound, el)
		if at then
			table.remove(bound, at)
		end
	end

	function api.listen(_: any, fn: (string?, { string }?) -> (), noMouse: boolean?)
		api.cancel()
		listener = fn
		listenerNoMouse = noMouse == true
	end

	function api.cancel()
		local fn = listener
		listener = nil
		pendingModifier = nil
		if fn then
			fn(nil)
		end
	end

	function api.state(_: any, el: any): boolean
		local value = el.value
		if value == nil then
			return false
		end
		if value.mode == "Always" then
			return true
		end
		if value.mode == "Toggle" then
			return el.toggled == true
		end
		if value.key == "None" or listener ~= nil or router:typing() then
			return false
		end
		local mouse = MOUSE_BUTTONS[value.key]
		if mouse then
			-- a held mouse bind must not read as active while the player is clicking the menu
			return not menuOpen() and uis:IsMouseButtonPressed(mouse) and modifiersHeld(value.modifiers)
		end
		-- asked of the engine, not tracked: a focus change can swallow the key up and leave a tracked key held forever
		local ok, down = pcall(function()
			return uis:IsKeyDown((Enum.KeyCode :: any)[value.key])
		end)
		return ok and down and modifiersHeld(value.modifiers)
	end

	router.keyDown:connect(function(event: any)
		local name = nameOf(event)
		if name == nil then
			return
		end
		if listener then
			local mouse = MOUSE_NAMES[event.UserInputType] ~= nil
			if mouse and (listenerNoMouse or name == "MB1") then
				return
			end
			-- a modifier may be the start of a combination: it only becomes the bind if released alone
			if MODIFIER_NAMES[event.KeyCode] and not mouse then
				pendingModifier = name
				return
			end
			local fn = listener
			listener = nil
			pendingModifier = nil
			swallow = name
			if name == "Escape" then
				(fn :: any)("None", {})
			else
				(fn :: any)(name, heldModifiers(name))
			end
			return
		end
		if swallow == name then
			return
		end
		-- typing only: a key the game also handles still has to fire, gameProcessed would kill binds on any game that sinks it
		if router:typing() then
			return
		end
		for _, el in bound do
			local value = el.value
			if value.key == name and not el.disabled and modifiersHeld(value.modifiers) then
				if value.mode == "Toggle" then
					el.toggled = not el.toggled
				end
				local press = el.spec.onPress
				if press then
					press(el, el.toggled)
				end
			end
		end
	end)

	router.keyUp:connect(function(event: any)
		local name = nameOf(event)
		if name == nil then
			return
		end
		if pendingModifier == name and listener then
			local fn = listener
			listener = nil
			pendingModifier = nil
			fn(name, {})
			return
		end
		if swallow == name then
			swallow = nil
		end
		for _, el in bound do
			local value = el.value
			if value.key == name and value.mode == "Hold" and el.spec.onRelease then
				el.spec.onRelease(el)
			end
		end
	end)

	return api
end

return keys
