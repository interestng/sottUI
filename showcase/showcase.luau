-- development showcase; every kind of control on realistic content, for screenshots and input tests

local sottui = ...
assert(sottui, "pass the library in")

local ui = sottui.window({ title = "sottoro", subtitle = "Dungeon Quest", folder = "sottui_lab_state" })

local home = ui:page("Home")
local main = ui:page("Main")
local player = ui:page("Player")
local visuals = ui:page("Visuals")
local config = ui:page("Config")

local me = game:GetService("Players").LocalPlayer
home:hero({ userId = me.UserId, title = me.DisplayName, text = "Dungeon Quest" })
local stats = home:section("This session")
stats:stat("Kills", "412")
stats:stat("Gold an hour", "2,104")
stats:stat("Run time", "2:14:07")
stats:stat("Deaths", "0")
local server = home:section("Server")
server:button("Hop server", function()
	ui:notify({ title = "Server hop", text = "Looking for a server with room." })
end)
server:button("Rejoin", function() end)
server:button("Copy join link", function() end)

local farm = main:section("Auto farm")
local enabled = farm:master("farm.enabled", { label = "Auto farm", default = true, tip = "Runs the dungeon loop until you turn it off" })
farm:addKey(enabled, "farm.key", { default = "F" })
local stay = farm:toggle("farm.stay", { label = "Stay at cast range", default = true })
farm:toggle("farm.dodge", { label = "Dodge telegraphed hits", default = true })
farm:toggle("farm.skipelite", { label = "Skip elites" })
farm:toggle("farm.bossfirst", { label = "Bosses first" })
farm:dropdown("farm.dungeon", {
	label = "Dungeon",
	options = { "Desert Temple", "Winter Outpost", "Pirate Cove", "Gilded Skies", "Northern Lands" },
	default = "Gilded Skies",
})
farm:dropdown("farm.difficulty", { label = "Difficulty", options = { "Normal", "Hard", "Insane", "Nightmare" }, default = "Insane" })
farm:slider("farm.range", { label = "Cast range", min = 10, max = 60, default = 42, suffix = " st" })
farm:slider("farm.heal", { label = "Heal below", min = 0, max = 100, default = 55, suffix = "%" })
local stayOn = farm:when(function()
	return stay.value
end, { stay })
stayOn:slider("farm.margin", { label = "Extra margin", min = 0, max = 4, step = 0.1, default = 1.5, suffix = " st" })

local aura = main:section("Kill aura")
aura:master("aura.enabled", { label = "Kill aura" })
aura:slider("aura.range", { label = "Range", min = 5, max = 40, default = 18, suffix = " st" })
aura:toggle("aura.bosses", { label = "Bosses only" })
local bring = main:section("Bring mobs")
bring:master("bring.enabled", { label = "Bring mobs" })
bring:slider("bring.distance", { label = "Hold at", min = 2, max = 20, default = 6, suffix = " st" })

local loot = main:section("Loot")
loot:toggle("loot.collect", { label = "Collect chests", default = true })
loot:toggle("loot.sell", { label = "Sell commons after each run", tip = "Long names fall to two lines at a smaller size" })
loot:toggle("loot.long", { label = "Give up on the pick after a while and farm with what you have" })
local rarities = {}
for i = 1, 40 do
	rarities[i] = "Item tier " .. i
end
loot:dropdown("loot.keep", { label = "Always keep", options = rarities, multi = true, default = { "Item tier 3" } })
loot:input("loot.webhook", { label = "Webhook", placeholder = "Discord url", finished = true })
loot:label("Last boss down in 2 minutes 14 seconds. The next dungeon starts by itself when the party is ready.", { wrap = true })
loot:button("Leave dungeon", { confirm = true, tip = "Teleports back to the lobby" })

local movement = player:section("Movement")
movement:toggle("player.speed", { label = "Walk speed" })
movement:toggle("player.fly", { label = "Fly", disabled = true, disabledTip = "Not available in this dungeon" })
movement:toggle("player.noclip", { label = "Noclip" })
movement:slider("player.speedValue", { label = "Speed", min = 16, max = 120, default = 40 })

local session = player:section("Session")
session:toggle("session.afk", { label = "Anti AFK", default = true })
session:toggle("session.rejoin", { label = "Rejoin on disconnect" })
local tabs = player:tabs({ "Server", "Party" })
tabs[1]:button("Hop to a new server", function()
	ui:notify({ title = "Server hop", text = "Looking for a server with room." })
end)
tabs[2]:toggle("party.accept", { label = "Accept invites" })
tabs[2]:input("party.leader", { label = "Leader", placeholder = "Username" })

local esp = visuals:section("Players")
local names = esp:toggle("esp.names", { label = "Names", default = true })
esp:addColor(names, "esp.namesColor", { default = Color3.fromRGB(240, 235, 224) })
local boxes = esp:toggle("esp.boxes", { label = "Boxes" })
esp:addColor(boxes, "esp.boxColor", { default = Color3.fromRGB(255, 84, 32), alpha = true })
esp:color("esp.team", { label = "Team color", default = Color3.fromRGB(64, 160, 255) })
esp:slider("esp.distance", { label = "Max distance", min = 100, max = 5000, step = 50, default = 1500, suffix = " st" })

local bulk = visuals:section("Stress")
for i = 1, 200 do
	if i % 7 == 0 then
		bulk:slider("bulk.s" .. i, { label = "Stress slider " .. i, default = i % 100 })
	else
		bulk:toggle("bulk.t" .. i, { label = "Stress toggle " .. i, default = i % 5 == 0 })
	end
end

local menu = config:section("Menu")
menu:key("menu.key", { label = "Open menu", default = "RightShift" })
menu:slider("menu.scale", {
	label = "Scale",
	min = 0.8,
	max = 1.3,
	step = 0.05,
	default = 1,
	onChanged = function(value: number)
		ui:setScale(value)
	end,
})
local saved = config:section("Configs")
saved:input("config.name", { label = "Name", placeholder = "New config", finished = true })
saved:dropdown("config.list", { label = "Saved", options = { "farm", "boss only", "afk" }, default = "farm" })
saved:button("Save", function()
	ui:notify({ title = "Saved", text = "farm" })
end)
saved:button("Open a dialog", function()
	ui:dialog({ title = "Targets", text = "Picks apply right away." }, function(section: any)
		section:toggle("dialog.a", { label = "Bosses first", default = true })
		section:toggle("dialog.b", { label = "Skip elites" })
		section:slider("dialog.c", { label = "Priority", default = 40 })
	end)
end)

return ui
