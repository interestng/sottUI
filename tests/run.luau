--!strict
-- lune run tests/run. the pure layers only; views are exercised live

local process = require("@lune/process")

local element = require("../src/model/element")
local motion = require("../src/core/motion")
local search = require("../src/model/search")
local signal = require("../src/core/signal")

local failures = 0
local passed = 0

local function test(name: string, fn: () -> ())
	local ok, err = xpcall(fn, debug.traceback)
	if ok then
		passed += 1
	else
		failures += 1
		print("FAIL " .. name .. "\n" .. tostring(err))
	end
end

local function eq(a: any, b: any)
	if a ~= b then
		error(string.format("expected %s, got %s", tostring(b), tostring(a)), 2)
	end
end

test("motion: settles exactly on target and stops", function()
	motion.reset()
	local seen = 0
	local spring = motion.new(0, 20, function(v)
		seen = v
	end)
	spring:to(100)
	eq(spring:moving(), true)
	for _ = 1, 600 do
		motion.step(1 / 60)
	end
	eq(seen, 100)
	eq(spring:moving(), false)
	eq(motion.activeCount(), 0)
end)

test("motion: never overshoots (critically damped)", function()
	motion.reset()
	local peak = 0
	local spring = motion.new(0, 30, function(v)
		peak = math.max(peak, v)
	end)
	spring:to(10)
	for _ = 1, 300 do
		motion.step(1 / 144)
	end
	assert(peak <= 10 + 1e-6, "overshot " .. peak)
end)

test("motion: same curve at any frame rate", function()
	local function at(fps: number): number
		motion.reset()
		local value = 0
		local spring = motion.new(0, 18, function(v)
			value = v
		end)
		spring:to(1)
		for _ = 1, math.floor(fps * 0.1) do
			motion.step(1 / fps)
		end
		return value
	end
	assert(math.abs(at(30) - at(240)) < 0.01, "frame rate dependent")
end)

test("motion: retarget keeps velocity", function()
	motion.reset()
	local value = 0
	local spring = motion.new(0, 18, function(v)
		value = v
	end)
	spring:to(100)
	for _ = 1, 3 do
		motion.step(1 / 60)
	end
	local before = value
	spring:to(0)
	motion.step(1 / 60)
	-- still travelling forward for a moment: a tween restart would reverse at once
	assert(value > before, "lost velocity")
end)

test("motion: done runs once; destroy prevents it", function()
	motion.reset()
	local runs = 0
	local spring = motion.new(0, 40, function() end)
	spring:to(1, function()
		runs += 1
	end)
	for _ = 1, 200 do
		motion.step(1 / 60)
	end
	eq(runs, 1)
	local dead = motion.new(0, 40, function() end)
	dead:to(1, function()
		runs += 1
	end)
	dead:destroy()
	motion.step(1 / 60)
	eq(runs, 1)
	eq(motion.activeCount(), 0)
end)

test("motion: snap abandons a pending done", function()
	motion.reset()
	local runs = 0
	local spring = motion.new(0, 20, function() end)
	spring:to(1, function()
		runs += 1
	end)
	spring:snap(0)
	for _ = 1, 200 do
		motion.step(1 / 60)
	end
	eq(runs, 0)
end)

test("motion: underdamped overshoots a little and still settles", function()
	motion.reset()
	local peak, last = 0, 0
	local spring = motion.new(0, 30, function(v)
		peak = math.max(peak, v)
		last = v
	end, 0.6)
	spring:to(1)
	for _ = 1, 600 do
		motion.step(1 / 60)
	end
	assert(peak > 1 and peak < 1.2, "peak " .. peak)
	eq(last, 1)
	eq(motion.activeCount(), 0)
end)

test("motion: a throwing write kills only that spring", function()
	motion.reset()
	local good = 0
	local bad = motion.new(0, 20, function()
		error("instance gone")
	end)
	local fine = motion.new(0, 20, function(v)
		good = v
	end)
	bad:to(1)
	fine:to(1)
	for _ = 1, 400 do
		motion.step(1 / 60)
	end
	eq(good, 1)
	eq(motion.activeCount(), 0)
end)

test("signal: an erroring listener does not stop the next", function()
	local s = signal.new()
	signal.setReporter(function() end)
	local ran = false
	s:connect(function()
		error("boom")
	end)
	s:connect(function()
		ran = true
	end)
	s:fire()
	eq(ran, true)
end)

test("signal: disconnect during fire is safe", function()
	local s = signal.new()
	local count = 0
	local off: () -> () = function() end
	off = s:connect(function()
		count += 1
		off()
	end)
	s:connect(function()
		count += 1
	end)
	s:fire()
	s:fire()
	eq(count, 3)
end)

test("slider: clamps, rounds to step, refuses junk", function()
	local el = element.new("slider", "s", "S", { min = 0, max = 1, step = 0.1 }, 0.5)
	eq(el:set(0.34), true)
	eq(el.value, 0.3)
	el:set(5)
	eq(el.value, 1)
	eq(el:set("nope"), false)
	eq(el.value, 1)
	eq(el:set(0 / 0), false)
end)

test("slider: string config value parses", function()
	local el = element.new("slider", "s", "S", { min = 0, max = 100, step = 1 }, 10)
	el:set("42")
	eq(el.value, 42)
end)

test("toggle: fires once per real change, fire() forces", function()
	local el = element.new("toggle", "t", "T", {}, false)
	local n = 0
	el:on(function()
		n += 1
	end)
	el:set(false)
	eq(n, 0)
	el:set(true)
	eq(n, 1)
	el:fire()
	eq(n, 2)
end)

test("dropdown single: unknown pick refused unless keep", function()
	local el = element.new("dropdown", "d", "D", { options = { "a", "b" } }, "a")
	eq(el:set("zzz"), false)
	eq(el.value, "a")
	el:set(nil)
	eq(el.value, nil)
	local kept = element.new("dropdown", "d", "D", { options = { "a" }, keep = true }, "a")
	kept:set("later")
	eq(kept.value, "later")
end)

test("dropdown multi: dict and array both normalize", function()
	local el = element.new("dropdown", "d", "D", { options = { "a", "b", "c" }, multi = true }, {})
	el:set({ a = true })
	eq(el.value.a, true)
	el:set({ "b", "c" })
	eq(el.value.a, nil)
	eq(el.value.b, true)
	el:set({ b = true, zzz = true })
	eq(el.value.zzz, nil)
end)

test("dropdown setOptions: keep holds picks missing from a short list", function()
	local el = element.new("dropdown", "d", "D", { options = { "a", "b" }, multi = true, keep = true }, { "a" })
	el:setOptions({ "b" })
	eq(el.value.a, true)
	assert(table.find(el.spec.options, "a"), "kept pick not listed")
	local drop = element.new("dropdown", "d", "D", { options = { "a", "b" } }, "a")
	drop:setOptions({ "b" })
	eq(drop.value, nil)
end)

test("input: numeric refuses letters, keeps a partial number", function()
	local el = element.new("input", "i", "I", { numeric = true }, "1")
	eq(el:set("abc"), false)
	eq(el.value, "1")
	eq(el:set("-"), true)
	eq(el:set("-3.5"), true)
end)

test("key: partial set keeps the rest", function()
	local el = element.new("key", "k", "K", {}, { key = "F", mode = "Hold", modifiers = {} })
	el:set({ key = "G" })
	eq(el.value.key, "G")
	eq(el.value.mode, "Hold")
	el:set({ mode = "Toggle" })
	eq(el.value.key, "G")
end)

test("isModified tracks the default", function()
	local el = element.new("slider", "s", "S", { min = 0, max = 10, step = 1 }, 5)
	eq(el:isModified(), false)
	el:set(6)
	eq(el:isModified(), true)
	el:reset()
	eq(el:isModified(), false)
end)

test("guard and visible combine in shown()", function()
	local el = element.new("toggle", "t", "T", {}, false)
	eq(el:shown(), true)
	el.guard = function()
		return false
	end
	eq(el:shown(), false)
	el.guard = nil
	el:setVisible(false)
	eq(el:shown(), false)
end)

test("search: word starts beat scattered matches", function()
	local a = search.score("cr", "Cast range") :: number
	local b = search.score("cr", "Scarce") :: number
	assert(a > b, "word start lost")
	eq(search.score("zz", "Cast range"), nil)
	local ranked = search.rank("heal", { "Stealth", "Heal below", "Wheel" }, function(s: string)
		return s
	end, 2)
	eq(ranked[1], "Heal below")
end)

print(string.format("%d passed, %d failed", passed, failures))
if failures > 0 then
	process.exit(1)
end
