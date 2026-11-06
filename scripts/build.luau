--!strict
-- dist/sottui.lua is the single file the hub pulls by tag

local fs = require("@lune/fs")
local process = require("@lune/process")

local OUT = "dist/sottui.lua"

if not fs.isDir("dist") then
	fs.writeDir("dist")
end

local result = process.exec("darklua", { "process", "--config", ".darklua.json5", "src/init.luau", OUT })
if not result.ok then
	print(result.stdout)
	print(result.stderr)
	process.exit(1)
end
print(OUT, #fs.readFile(OUT), "bytes")
