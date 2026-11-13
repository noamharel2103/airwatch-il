-- Touch ADMIN PANEL (client/AdminPanel.client.luau) + timed admin gifts.
-- The client only sends a button id and a target. The button's command and amounts come from
-- the server's own copy of shared/AdminCommands.luau, and every call checks the creator again.
-- Also: expires timed gifted passes and luck boosts, and tells each player which personal
-- boosts they have (the round icons at the bottom right, drawn by client/Extras.luau).
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local Modules = script.Parent:WaitForChild("Modules")
local Bridge = require(Modules:WaitForChild("AdminBridge"))
local Commands = require(Modules:WaitForChild("AdminCommandsServer"))
local Defs = require(RS:WaitForChild("Shared"):WaitForChild("AdminCommands"))

local fxRemote = RS:FindFirstChild("AdminFx") or Instance.new("RemoteEvent")
fxRemote.Name = "AdminFx"
fxRemote.Parent = RS

local panelRF = RS:FindFirstChild("AdminPanel") or Instance.new("RemoteFunction")
panelRF.Name = "AdminPanel"
panelRF.Parent = RS

-- button id -> { item, global }
local byId: { [string]: { item: any, global: boolean } } = {}
for _, section in ipairs(Defs.Panel) do
	for _, item in ipairs(section.items) do
		if type(Commands[item.op]) ~= "function" then
			warn("[AdminPanel] button " .. tostring(item.id) .. " has no server command " .. tostring(item.op))
		else
			byId[item.id] = { item = item, global = section.global == true }
		end
	end
end

local lastCall: { [Player]: number } = {}

panelRF.OnServerInvoke = function(player: Player, buttonId: any, target: any)
	-- anyone may read their OWN boosts (the bottom right icons ask once when they start)
	if buttonId == "__myBoosts" then
		local s = Bridge.sessions[player]
		return s and Commands._boostsOf(s.state) or {}
	end
	if not Bridge.isAdmin(player) then
		return { ok = false, msg = "Only the game creator can use this." }
	end
	local now = os.clock()
	if lastCall[player] and now - lastCall[player] < 0.25 then
		return { ok = false, msg = "Slow down a little" }
	end
	lastCall[player] = now
	if type(buttonId) ~= "string" or #buttonId > 60 then
		return { ok = false, msg = "Bad button" }
	end
	local entry = byId[buttonId]
	if not entry then
		return { ok = false, msg = "Unknown button" }
	end
	local item = entry.item
	local run = Commands[item.op]
	local context = { Executor = player }
	local args = table.clone(item.args or {})
	local ok, res
	if entry.global then
		ok, res = pcall(run, context, table.unpack(args))
	else
		local list: { Player }
		if target == "me" then
			list = { player }
		elseif target == "all" then
			list = Players:GetPlayers()
		elseif type(target) == "number" and target == target then
			local p = Players:GetPlayerByUserId(target)
			if not p then
				return { ok = false, msg = "That player left the server" }
			end
			list = { p }
		else
			return { ok = false, msg = "Pick who gets it first" }
		end
		ok, res = pcall(run, context, list, table.unpack(args))
	end
	if not ok then
		warn("[AdminPanel] " .. tostring(res))
		return { ok = false, msg = "Error: " .. tostring(res) }
	end
	local msg = tostring(res or "Done")
	local bad = msg:find("Nobody changed", 1, true) ~= nil or msg:find("Unknown", 1, true) ~= nil or msg:find("must be", 1, true) ~= nil
	return { ok = not bad, msg = item.label .. ": " .. msg }
end

-- ===== timed gifts expire + personal boost icons =====
local lastSig: { [Player]: string } = {}

Players.PlayerRemoving:Connect(function(p)
	lastSig[p] = nil
	lastCall[p] = nil
end)

local function tick()
	local now = os.time()
	for p, s in pairs(Bridge.sessions) do
		local st = s and s.state
		if st and p.Parent then
			-- timed passes run out
			local ends = st.giftPerkEnds
			if type(ends) == "table" then
				local changed = false
				for key, t in pairs(ends) do
					if type(t) ~= "number" or t <= now then
						ends[key] = nil
						if st.giftPerks then
							st.giftPerks[key] = nil
						end
						changed = true
					end
				end
				if changed then
					task.spawn(Bridge.refreshPasses, p)
					s.dirty = true
				end
			end
			if type(st.adminLuck) == "table" and (tonumber(st.adminLuck.ends) or 0) <= now then
				st.adminLuck = nil
				s.dirty = true
			end
			-- tell the player when their boost list changes
			local list = Commands._boostsOf(st)
			local parts = {}
			for _, b in ipairs(list) do
				-- the end time (not the seconds left) so the signature only changes on real changes
				table.insert(parts, b.id .. "@" .. tostring(now + b.left))
			end
			local sig = table.concat(parts, ",")
			if sig ~= (lastSig[p] or "") then
				lastSig[p] = sig
				fxRemote:FireClient(p, "boosts", list)
			end
		end
	end
end

task.spawn(function()
	while true do
		task.wait(1)
		local ok, err = pcall(tick)
		if not ok then
			warn("[AdminPanel] " .. tostring(err))
		end
	end
end)
