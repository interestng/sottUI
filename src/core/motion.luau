--!strict
-- every animation runs here, on one connection that exists only while something moves: an idle window costs zero per
-- frame. springs instead of tweens because a retarget mid flight keeps its velocity, which is what makes fast hovering
-- and dragging read as smooth rather than as a chain of restarts

local motion = {}

export type Spring = {
	to: (self: Spring, target: any, done: (() -> ())?) -> (),
	snap: (self: Spring, target: any) -> (),
	destroy: (self: Spring) -> (),
	moving: (self: Spring) -> boolean,
	target: any,
}

type Impl = {
	x: { number },
	v: { number },
	g: { number },
	rest: { number },
	n: number,
	speed: number,
	zeta: number,
	write: (values: { number }) -> (),
	encode: (value: any) -> { number },
	live: boolean,
	dead: boolean,
	target: any,
	done: (() -> ())?,
}

-- what counts as visually still differs by unit: a tenth of a pixel, a quarter of a 1/255 color step, a thousandth of a
-- scale or a transparency. a single threshold made pixel springs run on for several times their visible duration
local PIXEL = 0.1
local FINE = 0.001
local COLOR = 0.001

-- a hitch must not teleport anything past its goal region on the next frame
local MAX_DT = 1 / 20

local active: { Impl } = {}
local count = 0
local connection: any = nil
local attach: (((dt: number) -> ()) -> any)? = nil
local speedScale = 1

local codecs: { [string]: { encode: (any) -> { number }, decode: ({ number }) -> any, rest: { number } } } = {
	number = {
		encode = function(v)
			return { v }
		end,
		decode = function(x)
			return x[1]
		end,
		rest = { FINE },
	},
	Color3 = {
		encode = function(c)
			return { c.R, c.G, c.B }
		end,
		decode = function(x)
			return Color3.new(math.clamp(x[1], 0, 1), math.clamp(x[2], 0, 1), math.clamp(x[3], 0, 1))
		end,
		rest = { COLOR, COLOR, COLOR },
	},
	UDim2 = {
		encode = function(u)
			return { u.X.Scale, u.X.Offset, u.Y.Scale, u.Y.Offset }
		end,
		decode = function(x)
			return UDim2.new(x[1], x[2], x[3], x[4])
		end,
		rest = { FINE, PIXEL, FINE, PIXEL },
	},
	Vector2 = {
		encode = function(p)
			return { p.X, p.Y }
		end,
		decode = function(x)
			return Vector2.new(x[1], x[2])
		end,
		rest = { PIXEL, PIXEL },
	},
}

local function stopLoop()
	if connection then
		connection:Disconnect()
		connection = nil
	end
end

-- exact integration so the curve is the same at 30 and 240 fps. critically damped is the default for anything that
-- travels; a touch of underdamping is for the few things that should feel physical
local function advance(s: Impl, dt: number): boolean
	local w = s.speed * speedScale
	local zeta = s.zeta
	local x, v, g, rest = s.x, s.v, s.g, s.rest
	local resting = true
	if zeta >= 1 then
		local e = math.exp(-w * dt)
		for c = 1, s.n do
			local d = x[c] - g[c]
			local t = (v[c] + w * d) * dt
			x[c] = g[c] + (d + t) * e
			v[c] = (v[c] - w * t) * e
			local tolerance = rest[c]
			if math.abs(x[c] - g[c]) > tolerance or math.abs(v[c]) > tolerance * w then
				resting = false
			end
		end
	else
		local wd = w * math.sqrt(1 - zeta * zeta)
		local e = math.exp(-zeta * w * dt)
		local cosine, sine = math.cos(wd * dt), math.sin(wd * dt)
		for c = 1, s.n do
			local d = x[c] - g[c]
			local b = (v[c] + zeta * w * d) / wd
			local nd = e * (d * cosine + b * sine)
			v[c] = e * ((b * wd - zeta * w * d) * cosine - (d * wd + zeta * w * b) * sine)
			x[c] = g[c] + nd
			local tolerance = rest[c]
			if math.abs(nd) > tolerance or math.abs(v[c]) > tolerance * w then
				resting = false
			end
		end
	end
	if resting then
		for c = 1, s.n do
			x[c] = g[c]
			v[c] = 0
		end
	end
	return resting
end

function motion.step(dt: number)
	dt = math.min(dt, MAX_DT)
	local i = 1
	while i <= count do
		local s = active[i]
		local resting = true
		if not s.dead then
			resting = advance(s, dt)
			local ok, err: any = pcall(s.write, s.x)
			if not ok then
				-- the instance is gone or refused the value: this spring can never succeed again
				warn("sottUI: motion write failed: " .. tostring(err))
				s.dead = true
			end
		end
		if resting or s.dead then
			s.live = false
			active[i] = active[count]
			active[count] = nil :: any
			count -= 1
			local done = s.done
			s.done = nil
			if done and not s.dead then
				local ok, err: any = pcall(done)
				if not ok then
					warn("sottUI: motion callback failed: " .. tostring(err))
				end
			end
		else
			i += 1
		end
	end
	if count == 0 then
		stopLoop()
	end
end

local function wake(s: Impl)
	if s.live or s.dead then
		return
	end
	s.live = true
	count += 1
	active[count] = s
	if connection == nil and attach then
		connection = attach(motion.step)
	end
end

local Spring = {}
Spring.__index = Spring

-- abandons any pending done: whoever snaps has decided the outcome, and a stale callback from the journey it replaced
-- would undo that decision. the loop removes a live spring on its next pass, at rest
function Spring.snap(self: any, target: any)
	if self.dead then
		return
	end
	self.target = target
	self.done = nil
	local goal = self.encode(target)
	for c = 1, self.n do
		self.g[c] = goal[c]
		self.x[c] = goal[c]
		self.v[c] = 0
	end
	self.write(self.x)
end

function Spring.to(self: any, target: any, done: (() -> ())?)
	if self.dead then
		return
	end
	if speedScale <= 0 then
		self:snap(target)
		if done then
			done()
		end
		return
	end
	self.target = target
	self.done = done
	local goal = self.encode(target)
	local same = not self.live
	for c = 1, self.n do
		if goal[c] ~= self.x[c] then
			same = false
		end
		self.g[c] = goal[c]
	end
	if same then
		self.done = nil
		if done then
			done()
		end
		return
	end
	wake(self)
end

function Spring.moving(self: any): boolean
	return self.live
end

-- the step loop removes it on its next pass; removing here would disturb an iteration when a done callback destroys
function Spring.destroy(self: any)
	self.dead = true
	self.done = nil
end

function motion.new(initial: any, speed: number, write: (value: any) -> (), zeta: number?): Spring
	local codec = codecs[typeof(initial)]
	assert(codec, "motion: cannot animate " .. typeof(initial))
	local x = codec.encode(initial)
	local v = {}
	for c = 1, #x do
		v[c] = 0
	end
	local decode = codec.decode
	local self = {
		x = x,
		v = v,
		g = table.clone(x),
		rest = codec.rest,
		n = #x,
		speed = speed,
		zeta = zeta or 1,
		encode = codec.encode,
		write = function(values: { number })
			write(decode(values))
		end,
		live = false,
		dead = false,
		target = initial,
	}
	return (setmetatable(self, Spring) :: any) :: Spring
end

function motion.prop(instance: any, property: string, speed: number, zeta: number?): Spring
	return motion.new(instance[property], speed, function(value: any)
		instance[property] = value
	end, zeta)
end

function motion.setAttach(fn: ((dt: number) -> ()) -> any)
	attach = fn
end

-- 0 turns animation off (weak devices, user setting): springs snap
function motion.setSpeedScale(scale: number)
	speedScale = scale
end

function motion.activeCount(): number
	return count
end

function motion.running(): boolean
	return connection ~= nil
end

function motion.reset()
	table.clear(active)
	count = 0
	stopLoop()
end

return motion
