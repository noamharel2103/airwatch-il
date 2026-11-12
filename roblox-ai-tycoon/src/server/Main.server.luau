--!strict
-- Entry point: remotes, save slots, and the time loop (Build a Phone Empire style).
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local Shared = RS:WaitForChild("Shared")
local Config = require(Shared.Config)
local Format = require(Shared.Format)
local Catalog = require(Shared.Catalog)
local Shop = require(Shared.Shop)
local MarketplaceService = game:GetService("MarketplaceService")
local Modules = script.Parent:WaitForChild("Modules")
local Game = require(Modules.Game)
local Saves = require(Modules.Saves)
local Avatars = require(Modules.Avatars)

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
	-- seat avatars when the team or the office changes
	local st = s.state
	local key = tostring(st.office)
	for _, n in pairs(st.staff or {}) do
		key ..= "," .. n
	end
	for i, p in ipairs(st.people or {}) do
		if i > 40 then
			break
		end
		key ..= ":" .. tostring(p.id)
	end
	if (s :: any).avatarKey ~= key then
		(s :: any).avatarKey = key
		task.spawn(Avatars.sync, st)
	end
	s.lastPush = os.clock()
	s.dirty = false
end

-- ===== Robux: passes are per account, products go into the company you are playing =====
local ownedPasses: { [Player]: { [string]: boolean } } = {}
local IS_STUDIO = RunService:IsStudio()

local function refreshPasses(player: Player)
	local owned = ownedPasses[player] or {}
	for _, p in ipairs(Shop.passes) do
		if p.id ~= 0 and not owned[p.key] then
			local ok, has = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, p.id)
			if ok and has then
				owned[p.key] = true
			end
		end
	end
	ownedPasses[player] = owned
	local s = sessions[player]
	if s then
		local perks = table.clone(owned)
		-- Studio test purchases are remembered on the save so testing survives a restart
		for k, v in pairs(s.state.testPerks or {}) do
			if IS_STUDIO and v then
				perks[k] = true
			end
		end
		s.state.perks = perks
		if not perks.speed8 and s.state.speed == 8 then
			s.state.speed = 4
		end
		s.dirty = true
	end
end

-- Your Roblox friends can show up as job candidates (with their real avatar).
local friendCache: { [number]: { any } } = {}
local function loadFriends(player: Player)
	if friendCache[player.UserId] then
		return friendCache[player.UserId]
	end
	local list = {}
	local ok, pages = pcall(Players.GetFriendsAsync, Players, player.UserId)
	if ok and pages then
		while #list < 80 do
			for _, f in ipairs(pages:GetCurrentPage()) do
				table.insert(list, { id = f.Id, name = f.DisplayName or f.Username })
			end
			if pages.IsFinished then
				break
			end
			local ok2 = pcall(function()
				pages:AdvanceToNextPageAsync()
			end)
			if not ok2 then
				break
			end
		end
	end
	friendCache[player.UserId] = list
	return list
end

Players.PlayerAdded:Connect(function(player)
	refreshPasses(player)
	task.spawn(loadFriends, player)
end)
for _, pl in ipairs(Players:GetPlayers()) do
	task.spawn(refreshPasses, pl)
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, bought)
	if bought then
		for _, p in ipairs(Shop.passes) do
			if p.id == passId then
				ownedPasses[player] = ownedPasses[player] or {}
				ownedPasses[player][p.key] = true
			end
		end
		refreshPasses(player)
	end
end)

-- Developer products: grant once per receipt, save, then confirm. Unknown/absent = retry later.
MarketplaceService.ProcessReceipt = function(info)
	local player = Players:GetPlayerByUserId(info.PlayerId)
	local p = Shop.productById[info.ProductId]
	local s = player and sessions[player]
	if not p or not s then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local st = s.state
	st.receipts = st.receipts or {}
	if not st.receipts[info.PurchaseId] then
		local ok, res = pcall(Game.grantProduct, st, p.key, (s :: any).shopTarget)
		if not ok or res == false then
			warn("[shop] grant failed " .. p.key .. " " .. tostring(res))
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		st.receipts[info.PurchaseId] = st.day
	end
	-- keep the receipt list small (only recent ids matter for retries)
	local n = 0
	for _ in pairs(st.receipts) do
		n += 1
	end
	if n > 60 then
		local oldest, oldDay
		for id, d in pairs(st.receipts) do
			if not oldDay or d < oldDay then
				oldest, oldDay = id, d
			end
		end
		st.receipts[oldest] = nil
	end
	local saved = Saves.save(player.UserId, s.slot, st, summary(st))
	if not saved then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	s.dirty = true
	EventRE:FireClient(player, "purchase", p.key)
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- Client asks to buy. Real ids open the Roblox prompt; id 0 in Studio = free test grant.
local ShopRF = remote("RemoteFunction", "Shop") :: RemoteFunction
ShopRF.OnServerInvoke = function(player: Player, kind: string, key: string, target: any)
	local s = sessions[player]
	if not s then
		return { ok = false, err = "Load a company first" }
	end
	if kind == "pass" then
		local p = Shop.passByKey[key]
		if not p then
			return { ok = false, err = "Unknown pass" }
		end
		if s.state.perks and s.state.perks[key] then
			return { ok = false, err = "You already own this" }
		end
		if p.id ~= 0 then
			MarketplaceService:PromptGamePassPurchase(player, p.id)
			return { ok = true, prompted = true }
		elseif IS_STUDIO then
			s.state.testPerks = s.state.testPerks or {}
			s.state.testPerks[key] = true
			refreshPasses(player)
			push(player, s)
			return { ok = true, test = true }
		end
		return { ok = false, err = "Coming soon" }
	elseif kind == "product" then
		local p = Shop.productByKey[key]
		if not p then
			return { ok = false, err = "Unknown item" }
		end
		(s :: any).shopTarget = tonumber(target)
		if p.id ~= 0 then
			MarketplaceService:PromptProductPurchase(player, p.id)
			return { ok = true, prompted = true }
		elseif IS_STUDIO then
			local ok, res, err = pcall(Game.grantProduct, s.state, key, tonumber(target))
			if not ok then
				return { ok = false, err = tostring(res) }
			elseif res == false then
				return { ok = false, err = err }
			end
			s.dirty = true
			push(player, s)
			return { ok = true, test = true }
		end
		return { ok = false, err = "Coming soon" }
	elseif kind == "resetTest" and IS_STUDIO then
		s.state.testPerks = {}
		refreshPasses(player)
		push(player, s)
		return { ok = true }
	end
	return { ok = false, err = "Bad request" }
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
	Game.migrateStaff(state)
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
		refreshPasses(player)
		task.spawn(function()
			state.friendPool = loadFriends(player)
		end)
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
	ownedPasses[player] = nil
end)

game:BindToClose(function()
	for player in pairs(sessions) do
		saveSession(player)
	end
end)
