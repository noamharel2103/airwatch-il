--!strict
-- Entry point: remotes, save slots, and the time loop (Build a Phone Empire style).
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local Shared = RS:WaitForChild("Shared")
local Config = require(Shared.Config)
local Format = require(Shared.Format)
local Catalog = require(Shared.Catalog)
local Modules = script.Parent:WaitForChild("Modules")
local Game = require(Modules.Game)
local Saves = require(Modules.Saves)

-- No walking around: the player sees the office from a fixed camera and clicks things.
Players.CharacterAutoLoads = false

local remotes = RS:FindFirstChild("Remotes") or Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = RS
local function remote(class, name)
	local r = remotes:FindFirstChild(name) or Instance.new(class)
	r.Name = name
	r.Parent = remotes
	return r
end
local ActionRF = remote("RemoteFunction", "Action") :: RemoteFunction
local SlotsRF = remote("RemoteFunction", "Slots") :: RemoteFunction
local StateRE = remote("RemoteEvent", "State") :: RemoteEvent
local EventRE = remote("RemoteEvent", "Event") :: RemoteEvent

type Session = { state: any, slot: number, acc: number, lastPush: number, dirty: boolean, lastSaveMonth: number }
local sessions: { [Player]: Session } = {}

local function summary(state)
	return {
		company = state.company,
		day = state.day,
		date = Format.monthYear(state.day),
		valuation = state.valuation,
		stage = Catalog.officeStages[state.office].name,
		users = state.users,
	}
end

local function saveSession(player: Player)
	local s = sessions[player]
	if s then
		Saves.save(player.UserId, s.slot, s.state, summary(s.state))
	end
end

local function push(player: Player, s: Session)
	StateRE:FireClient(player, Game.snapshot(s.state))
	s.lastPush = os.clock()
	s.dirty = false
end

-- Upgrade old saves with any fields added later.
local function reconcile(state)
	local fresh = Game.new(state.company or "Company")
	for k, v in pairs(fresh) do
		if state[k] == nil then
			state[k] = v
		end
	end
	for k, v in pairs(fresh.stats) do
		if state.stats[k] == nil then
			state.stats[k] = v
		end
	end
	return state
end

SlotsRF.OnServerInvoke = function(player: Player, action: string, slot: number?, name: string?, location: string?)
	if action == "list" then
		return { slots = Saves.listSlots(player.UserId), persistent = Saves.available or RunService:IsStudio() }
	elseif action == "play" then
		slot = math.clamp(math.floor(tonumber(slot) or 1), 1, Saves.MAX_SLOTS)
		if sessions[player] then
			saveSession(player)
		end
		local data = Saves.load(player.UserId, slot :: number)
		local state
		if type(data) == "table" and data.company then
			state = reconcile(data)
			state.speed = 0
			if #(state.awayLog or {}) > 0 then
				state.awayLog = {}
			end
		else
			local n = tostring(name or ""):gsub("[^%w%s%-%._]", ""):sub(1, 20)
			if #n < 2 then
				n = "Nomad AI"
			end
			local loc = "paloalto"
			for _, l in ipairs(Config.LOCATIONS) do
				if l.id == location then
					loc = l.id
				end
			end
			state = Game.new(n, loc)
			Saves.save(player.UserId, slot :: number, state, summary(state))
		end
		sessions[player] = { state = state, slot = slot :: number, acc = 0, lastPush = 0, dirty = true, lastSaveMonth = -1 }
		push(player, sessions[player])
		return { ok = true, persistent = Saves.available or RunService:IsStudio() }
	elseif action == "delete" then
		slot = math.clamp(math.floor(tonumber(slot) or 1), 1, Saves.MAX_SLOTS)
		if sessions[player] and sessions[player].slot == slot then
			sessions[player] = nil
		end
		Saves.delete(player.UserId, slot :: number)
		return { ok = true }
	elseif action == "quit" then
		saveSession(player)
		sessions[player] = nil
		return { ok = true }
	end
	return nil
end

ActionRF.OnServerInvoke = function(player: Player, name: string, ...)
	local s = sessions[player]
	if not s then
		return { ok = false, err = "No company loaded" }
	end
	local fn = Game.Actions[name]
	if type(fn) ~= "function" then
		return { ok = false, err = "Unknown action" }
	end
	local ok, res, extra = pcall(fn, s.state, ...)
	if not ok then
		warn("[Action " .. name .. "] " .. tostring(res))
		return { ok = false, err = "Something broke: " .. tostring(res) }
	end
	s.dirty = true
	if res == false then
		return { ok = false, err = extra }
	end
	push(player, s)
	return { ok = true, data = extra }
end

-- Time loop
RunService.Heartbeat:Connect(function(dt)
	for player, s in pairs(sessions) do
		local speed = s.state.speed
		if speed > 0 then
			s.acc += dt * speed
			local steps = 0
			while s.acc >= Config.SECONDS_PER_DAY and steps < 4 do
				s.acc -= Config.SECONDS_PER_DAY
				steps += 1
				local beforeFeed = s.state.feed[1]
				local ok, err = pcall(Game.tickDay, s.state)
				if not ok then
					warn("[tick] " .. tostring(err))
					s.state.speed = 0
				end
				s.dirty = true
				-- incidents that happened this day
				if s.state.feed[1] ~= beforeFeed and s.state.feed[1] and s.state.feed[1].kind == "incident" then
					EventRE:FireClient(player, "incident", s.state.feed[1].data)
				end
				local _, m = Format.dateFromDay(s.state.day)
				if m ~= s.lastSaveMonth then
					s.lastSaveMonth = m
					task.spawn(saveSession, player)
				end
			end
		end
		if s.dirty and os.clock() - s.lastPush > 0.25 then
			push(player, s)
		end
		-- in Studio, save every 15 seconds so stopping a test never loses progress
		if RunService:IsStudio() and os.clock() - ((s :: any).lastAuto or 0) > 15 then
			(s :: any).lastAuto = os.clock()
			task.spawn(saveSession, player)
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	saveSession(player)
	sessions[player] = nil
end)

game:BindToClose(function()
	for player in pairs(sessions) do
		saveSession(player)
	end
end)
