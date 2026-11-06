--!strict
-- listeners are plain functions so an element nobody subscribed to costs one empty table. each runs protected: a game
-- callback that errors must not stop the listeners after it or the element's own view update

export type Signal = {
	connect: (self: Signal, fn: (...any) -> ()) -> () -> (),
	fire: (self: Signal, ...any) -> (),
	clear: (self: Signal) -> (),
}

local Signal = {}
Signal.__index = Signal

local reporter: (string) -> () = function(message: string)
	warn(message)
end

function Signal.connect(self: any, fn: (...any) -> ()): () -> ()
	-- copy on write so a listener disconnecting during fire cannot shift the iteration
	local list = table.clone(self._list)
	table.insert(list, fn)
	self._list = list
	return function()
		local remaining = table.clone(self._list)
		local at = table.find(remaining, fn)
		if at then
			table.remove(remaining, at)
			self._list = remaining
		end
	end
end

function Signal.fire(self: any, ...: any)
	for _, fn in self._list do
		local ok, err = xpcall(fn, debug.traceback, ...)
		if not ok then
			reporter("sottUI: listener failed: " .. tostring(err))
		end
	end
end

function Signal.clear(self: any)
	self._list = {}
end

return {
	new = function(): Signal
		return (setmetatable({ _list = {} }, Signal) :: any) :: Signal
	end,
	setReporter = function(fn: (string) -> ())
		reporter = fn
	end,
}
