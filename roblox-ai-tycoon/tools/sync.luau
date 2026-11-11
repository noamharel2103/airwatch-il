-- Dev-only ModuleScript installed at ServerStorage.DevSync (never shipped to clients).
-- Run `python tools/manifest.py` (it also copies this file to src/_devsync.txt) while
-- `python -m http.server 34873 --bind 127.0.0.1` runs inside src/, then in Studio:
--   require(game.ServerStorage.DevSync:Clone())()
return function()
local Http = game:GetService("HttpService")
local BASE = "http://127.0.0.1:34873/"
local list = Http:JSONDecode(Http:GetAsync(BASE .. "manifest.json?" .. os.clock()))

local function folder(parent, name)
	local f = parent:FindFirstChild(name)
	if not f then
		f = Instance.new("Folder")
		f.Name = name
		f.Parent = parent
	end
	return f
end

local spsc = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
local count = 0
for _, rel in ipairs(list) do
	local top, file = rel:match("^(%w+)/(.+)$")
	local name, kind = file:match("^(.-)%.(%w+)%.luau$")
	if not name then
		name = file:match("^(.-)%.luau$")
	end
	name = name:gsub("/", "_")
	local parent, class
	if top == "shared" then
		parent, class = folder(game.ReplicatedStorage, "Shared"), "ModuleScript"
	elseif top == "server" then
		if kind == "server" then
			parent, class = game.ServerScriptService, "Script"
		else
			parent, class = folder(game.ServerScriptService, "Modules"), "ModuleScript"
		end
	else
		if kind == "client" then
			parent, class = spsc, "LocalScript"
		else
			parent, class = folder(spsc, "ClientModules"), "ModuleScript"
		end
	end
	local src = Http:GetAsync(BASE .. rel .. "?" .. os.clock())
	src = src:gsub("^\239\187\191", "")
	local inst = parent:FindFirstChild(name)
	if inst and inst.ClassName ~= class then
		inst:Destroy()
		inst = nil
	end
	if not inst then
		inst = Instance.new(class)
		inst.Name = name
		inst.Parent = parent
	end
	inst.Source = src
	count += 1
end
return "synced " .. count .. " scripts"
end
