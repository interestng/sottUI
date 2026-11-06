-- run in a client: what lune cannot exercise, the real instances and the compat contract. returns failures, empty is good
-- loadstring(readfile("live.luau"))(sottui)

local sottui = ...
local bundle = sottui.obsidian()
local library = bundle.Library
local failures = {}

local function expect(name: string, got: any, want: any)
	if got ~= want then
		table.insert(failures, string.format("%s: got %s, want %s", name, tostring(got), tostring(want)))
	end
end

local window = library:CreateWindow({ Title = "t", Footer = "f", Folder = "sottui_test", StateFile = "sottui_test/w.json" })
window:AddTab({ Name = "Home" })
local main = window:AddTab({ Name = "Main" })

local box = main:AddLeftGroupbox("Aimbot")
local fired = 0
local master = box:AddToggle("a", { Text = "Enabled", Callback = function()
	fired += 1
end })
expect("first Enabled becomes the master", master._el.spec.primary, true)
master:AddKeyPicker("aKey", { Default = "Y", Mode = "Toggle", SyncToggleState = true })
local slider = box:AddSlider("b", { Text = "FOV", Min = 0, Max = 500, Default = 120, Rounding = 0, Suffix = " px" })
local depbox = box:AddDependencyBox()
depbox:SetupDependencies({ { master, true } })
local inner = depbox:AddToggle("c", { Text = "Inside" })
local single = box:AddDropdown("d", { Text = "One", Values = { "x", "y" }, Default = "x" })
local multi = box:AddDropdown("e", { Text = "Many", Values = { "x", "y" }, Multi = true, Default = { "x" } })
local input = box:AddInput("f", { Text = "Name", Default = "n", Finished = true })

local plain = main:AddRightGroupbox("Plain")
plain:AddLabel("not first")
expect("a later Enabled stays a toggle", plain:AddToggle("g", { Text = "Enabled" })._el.spec.primary == true, false)

master:SetValue(false)
expect("toggle fires on an unchanged SetValue", fired, 1)
slider:SetValue("7")
expect("slider takes a string", slider.Value, 7)
local before = fired
slider:SetValue(7)
expect("slider does not fire unchanged", fired, before)
single:SetValue("nope")
expect("dropdown refuses an unknown pick", single.Value, "x")
multi:SetValue({ y = true })
expect("multi takes a dict", multi.Value.y == true and multi.Value.x == nil, true)

master:SetValue(true)
expect("a bound key follows its toggle", library.Options.aKey.Toggled, true)
task.wait(0.1)
expect("dependency opens with its rule", inner._el:shown(), true)

local save = bundle.SaveManager
save:SetFolder("sottui_test")
save:SetSubFolder("t")
expect("config saves", (save:Save("c")), true)
master:SetValue(false)
slider:SetValue(1)
input:SetValue("other")
expect("config loads", (save:Load("c")), true)
task.wait(0.2)
expect("toggle restored", master.Value, true)
expect("slider restored", slider.Value, 7)
expect("input restored", input.Value, "n")

local closed = false
expect(
	"dialog opens",
	window:OpenDialog({ title = "x", onClose = function()
		closed = true
	end }, function(group)
		group:AddToggle("h", { Text = "Inside" })
		expect("dialog element registered", library.Toggles.h ~= nil, true)
	end),
	true
)
task.wait(0.3)
library.window._dialogClose()
task.wait(0.3)
expect("dialog closed", closed, true)
expect("dialog element dropped", library.Toggles.h, nil)

library:Toggle(false)
expect("Toggled follows the window", library.Toggled, false)
library:Toggle(true)
library:Unload()
expect("unload clears the gui", library.ScreenGui, nil)

return failures
