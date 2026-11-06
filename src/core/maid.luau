--!strict
-- owns everything disposable on one object; cleanup runs in reverse so children die before what they hang off

export type Maid = {
	add: <T>(self: Maid, item: T) -> T,
	clean: (self: Maid) -> (),
	destroy: (self: Maid) -> (),
}

local Maid = {}
Maid.__index = Maid

local function dispose(item: any)
	local kind = typeof(item)
	if kind == "RBXScriptConnection" then
		item:Disconnect()
	elseif kind == "Instance" then
		item:Destroy()
	elseif kind == "function" then
		item()
	elseif kind == "thread" then
		task.cancel(item)
	elseif kind == "table" then
		local fn = item.destroy or item.Destroy or item.Disconnect
		if fn then
			fn(item)
		end
	end
end

function Maid.add<T>(self: any, item: T): T
	table.insert(self._items, item)
	return item
end

function Maid.clean(self: any)
	local items = self._items
	self._items = {}
	for i = #items, 1, -1 do
		-- one bad cleanup must not leave the rest of the window alive
		local ok, err: any = pcall(dispose, items[i])
		if not ok then
			warn("sottUI: cleanup failed: " .. tostring(err))
		end
	end
end

Maid.destroy = Maid.clean

return {
	new = function(): Maid
		return (setmetatable({ _items = {} }, Maid) :: any) :: Maid
	end,
}
