--!strict
-- one set of UserInputService connections per window. drags capture here rather than listening on the dragged instance:
-- a pointer leaving the row, the window or the game's viewport must not strand a drag, and only one can be live

local env = require("./env")
local maidModule = require("./maid")
local signal = require("./signal")

local input = {}

export type Router = {
	pointer: (self: Router) -> Vector2,
	at: (self: Router, event: any) -> Vector2,
	capture: (self: Router, move: (at: Vector2) -> (), finish: ((at: Vector2) -> ())?, finger: any?) -> (),
	release: (self: Router) -> (),
	typing: (self: Router) -> boolean,
	keyDown: signal.Signal,
	keyUp: signal.Signal,
	wheel: signal.Signal,
	moved: signal.Signal,
	pointerUp: signal.Signal,
	destroy: (self: Router) -> (),
}

local Router = {}
Router.__index = Router

function Router.pointer(self: any): Vector2
	return self._uis:GetMouseLocation()
end

-- event.Position excludes the topbar inset while GetMouseLocation includes it; the ScreenGui ignores the inset, so
-- every coordinate in this library is measured the GetMouseLocation way
function Router.at(self: any, event: any): Vector2
	local position = event.Position
	local inset = self._guiService:GetGuiInset()
	return Vector2.new(position.X + inset.X, position.Y + inset.Y)
end

-- finger is the touch that started it: a thumb resting on the joystick must not move or end a slider drag
function Router.capture(self: any, move: (at: Vector2) -> (), finish: ((at: Vector2) -> ())?, finger: any?)
	self:release()
	self._move = move
	self._finish = finish
	self._finger = finger
end

function Router.release(self: any)
	local finish = self._finish
	self._move = nil
	self._finish = nil
	self._finger = nil
	if finish then
		task.spawn(finish, self:pointer())
	end
end

function Router.typing(self: any): boolean
	return self._uis:GetFocusedTextBox() ~= nil
end

function Router.destroy(self: any)
	self._move = nil
	self._finish = nil
	self._maid:clean()
	self.keyDown:clear()
	self.keyUp:clear()
	self.wheel:clear()
	self.moved:clear()
	self.pointerUp:clear()
end

function input.new(): Router
	local uis = env.service("UserInputService")
	local maid = maidModule.new()
	local self: any = setmetatable({
		_uis = uis,
		_guiService = env.service("GuiService"),
		_maid = maid,
		_move = nil,
		_finish = nil,
		keyDown = signal.new(),
		keyUp = signal.new(),
		wheel = signal.new(),
		moved = signal.new(),
		pointerUp = signal.new(),
	}, Router)

	maid:add(uis.InputChanged:Connect(function(event: any)
		local kind = event.UserInputType
		if kind == Enum.UserInputType.MouseMovement then
			local at = self:pointer()
			if self._move then
				self._move(at)
			end
			self.moved:fire(at)
		elseif kind == Enum.UserInputType.Touch then
			if self._move and (self._finger == nil or self._finger == event) then
				self._move(self:at(event))
			end
		elseif kind == Enum.UserInputType.MouseWheel then
			self.wheel:fire(event.Position.Z)
		end
	end))
	maid:add(uis.InputEnded:Connect(function(event: any, processed: boolean)
		local kind = event.UserInputType
		if kind == Enum.UserInputType.MouseButton1 or kind == Enum.UserInputType.Touch then
			if self._move and (kind ~= Enum.UserInputType.Touch or self._finger == nil or self._finger == event) then
				local at = if kind == Enum.UserInputType.Touch then self:at(event) else self:pointer()
				local finish = self._finish
				self._move = nil
				self._finish = nil
				self._finger = nil
				if finish then
					finish(at)
				end
			end
			self.pointerUp:fire()
		end
		self.keyUp:fire(event, processed)
	end))
	maid:add(uis.InputBegan:Connect(function(event: any, processed: boolean)
		self.keyDown:fire(event, processed)
	end))
	return self
end

return input
