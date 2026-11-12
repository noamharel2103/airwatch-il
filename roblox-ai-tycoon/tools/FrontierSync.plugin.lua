-- FrontierSync: local Studio plugin. Pulls src/ from the dev web server when tools/manifest.py runs.
-- Installed by the FRONTIER repo (tools/make_plugin.py). Edit mode only.
local RunService = game:GetService("RunService")
if not RunService:IsEdit() then
	return
end
-- Only the FRONTIER place: without this it synced the game code into every open Studio.
local FRONTIER_PLACE_ID = 77800822441354
if game.PlaceId == 0 then
	game:GetPropertyChangedSignal("PlaceId"):Wait()
end
if game.PlaceId ~= FRONTIER_PLACE_ID then
	return
end
local Http = game:GetService("HttpService")
local BASE = "http://127.0.0.1:34873/"

-- Vendored Cmdr (F2 admin console) -> ServerScriptService.Cmdr, installed once if missing.
local function installCmdr()
	if game.ServerScriptService:FindFirstChild("Cmdr") then
		return "Cmdr already installed"
	end
	local files = Http:JSONDecode(Http:GetAsync(BASE .. "_vendor/cmdr_files.json?" .. os.clock()))
	local initDirs = {}
	for _, f in ipairs(files) do
		local dir = f:match("^(.*)/init%.lua$")
		if dir then
			initDirs[dir] = true
		end
	end
	local root = Instance.new("Folder")
	local made = {}
	local function node(path)
		if path == "_vendor" then
			return root
		end
		if made[path] then
			return made[path]
		end
		local parentPath, name = path:match("^(.*)/([^/]+)$")
		local inst = Instance.new(initDirs[path] and "ModuleScript" or "Folder")
		inst.Name = name
		inst.Parent = node(parentPath)
		made[path] = inst
		return inst
	end
	for _, f in ipairs(files) do
		local src = Http:GetAsync(BASE .. f .. "?" .. os.clock()):gsub("^\239\187\191", "")
		local dir, file = f:match("^(.*)/([^/]+)%.lua$")
		if file == "init" then
			node(dir).Source = src
		else
			local m = Instance.new("ModuleScript")
			m.Name = file
			m.Source = src
			m.Parent = node(dir)
		end
	end
	root.Cmdr.Parent = game.ServerScriptService
	root:Destroy()
	return "Cmdr installed (" .. #files .. " files)"
end

local function doSync()

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

local function doBuild()
	local src = Http:GetAsync(BASE .. "_build_world.txt?" .. os.clock()):gsub("^98791", "")
	local m = Instance.new("ModuleScript")
	m.Source = src
	return require(m)()
end

local toolbar = plugin:CreateToolbar("FRONTIER")
local btn = toolbar:CreateButton("Sync", "Pull the game code from the repo now", "rbxassetid://0")
btn.Click:Connect(function()
	print("[FrontierSync]", pcall(doSync))
end)

local lastStamp, lastBuild = nil, nil
task.spawn(function()
	while true do
		local ok, stamp = pcall(function()
			return Http:GetAsync(BASE .. "_stamp.txt?" .. os.clock())
		end)
		if ok and stamp ~= lastStamp then
			if lastStamp ~= nil or true then
				local ok2, res = pcall(doSync)
				print("[FrontierSync]", ok2, res)
				print("[FrontierSync]", pcall(installCmdr))
			end
			lastStamp = stamp
		end
		local okb, b = pcall(function()
			return Http:GetAsync(BASE .. "_build_stamp.txt?" .. os.clock())
		end)
		if okb and b ~= lastBuild then
			if lastBuild ~= nil then
				print("[FrontierSync] rebuild", pcall(doBuild))
			end
			lastBuild = b
		end
		task.wait(2)
	end
end)
