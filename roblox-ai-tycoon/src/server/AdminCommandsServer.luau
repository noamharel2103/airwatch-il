-- Server code for the F2 admin commands in shared/AdminCommands.luau (key = command Name).
-- Every function gets (context, ...args) and returns the text shown in the console.
-- The ADMIN PANEL (server/AdminPanel.server.luau) runs the same functions with preset args.
local RS = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local MessagingService = game:GetService("MessagingService")

local Modules = script.Parent
local Game = require(Modules:WaitForChild("Game"))
local Bridge = require(Modules:WaitForChild("AdminBridge"))
local Shared = RS:WaitForChild("Shared")
local Shop = require(Shared:WaitForChild("Shop"))
local Staff = require(Shared:WaitForChild("Staff"))
local Catalog = require(Shared:WaitForChild("Catalog"))
local Config = require(Shared:WaitForChild("Config"))
local Format = require(Shared:WaitForChild("Format"))
local Events = require(Shared:WaitForChild("Events"))

local rng = Random.new()

-- ===== personal luck boost =====
-- Game.luck(state) is called through the Game table everywhere, so wrapping it here adds
-- the admin boost (state.adminLuck = { mult, ends }) to every luck roll and to the LUCK chip.
-- If Game.luck ever reads state.adminLuck itself, set Game.ADMIN_LUCK_NATIVE = true there.
if not (Game :: any)._adminLuckWrapped and not (Game :: any).ADMIN_LUCK_NATIVE then
	(Game :: any)._adminLuckWrapped = true
	local baseLuck = Game.luck
	Game.luck = function(state)
		local v = baseLuck(state)
		local b = state and state.adminLuck
		if type(b) == "table" and (tonumber(b.ends) or 0) > os.time() then
			v *= math.clamp(tonumber(b.mult) or 1, 1, 10)
		end
		return v
	end
end

local function fx(): RemoteEvent
	local r = RS:FindFirstChild("AdminFx")
	if not r then
		r = Instance.new("RemoteEvent")
		r.Name = "AdminFx"
		r.Parent = RS
	end
	return r :: RemoteEvent
end

local function gift(p: Player, name: string)
	fx():FireClient(p, "gift", { name = name })
end

-- a real, finite number inside [lo, hi], or nil
local function num(v: any, lo: number, hi: number): number?
	local n = tonumber(v)
	if not n or n ~= n or n == math.huge or n == -math.huge then
		return nil
	end
	if n < lo or n > hi then
		return nil
	end
	return n
end

local function clock(sec: number): string
	sec = math.max(0, math.floor(sec))
	if sec >= 3600 then
		return string.format("%d:%02d:%02d", sec // 3600, (sec % 3600) // 60, sec % 60)
	end
	return string.format("%d:%02d", sec // 60, sec % 60)
end

-- Roblox rules: text typed by a person must be filtered before others see it.
local function filtered(text: string, fromId: number, toId: number?): string?
	local ok, res = pcall(function()
		local r = TextService:FilterStringAsync(text, fromId)
		if toId then
			return r:GetNonChatStringForUserAsync(toId)
		end
		return r:GetNonChatStringForBroadcastAsync()
	end)
	return ok and res or nil
end

local function names(list: { Player }): string
	local out = {}
	for _, p in ipairs(list) do
		table.insert(out, p.Name)
	end
	return table.concat(out, ", ")
end

-- Runs fn on each player that has a company loaded; lists who was skipped.
local function onSessions(players: { Player }, fn: (Player, any) -> string?): string
	if type(players) ~= "table" or #players == 0 then
		return "Nobody picked"
	end
	local done, skipped, errs = {}, {}, {}
	for _, p in ipairs(players) do
		local s = Bridge.sessions[p]
		if not s then
			table.insert(skipped, p)
		else
			local ok, err = pcall(fn, p, s)
			if not ok then
				err = "error: " .. tostring(err)
			end
			if err then
				table.insert(errs, p.Name .. ": " .. tostring(err))
			else
				table.insert(done, p)
			end
			-- push even on a partial error: the state may already have changed
			s.dirty = true
			Bridge.push(p, s)
		end
	end
	local msg = #done > 0 and ("Done for " .. names(done)) or "Nobody changed"
	if #skipped > 0 then
		msg ..= " | no company loaded: " .. names(skipped)
	end
	if #errs > 0 then
		msg ..= " | " .. table.concat(errs, "; ")
	end
	return msg
end

-- Grants a Robux product through the game's own receipt code, without counting it as a
-- real purchase (real purchases raise luck forever).
local function grantFree(state, key: string, modelId: number?): string?
	local before = state.stats and state.stats.robux
	local ok, res, err = pcall(Game.grantProduct, state, key, modelId)
	if state.stats then
		state.stats.robux = before
	end
	if not ok then
		return tostring(res)
	elseif res == false then
		return tostring(err)
	end
	return nil
end

local function rarityIndex(id: string): number?
	for i, r in ipairs(Staff.RARITIES) do
		if r.id == id then
			return i
		end
	end
	return nil
end

-- Adds free workers the same way the worker store does, but with no price and no office lock.
local function addWorkers(state, r: number, roleId: string?, n: number): (number, string?)
	local rar = Staff.RARITIES[r]
	if not rar then
		return 0, "Unknown rarity"
	end
	if roleId and not Staff.byId[roleId] then
		return 0, "Unknown job"
	end
	Game.ensurePeople(state)
	local stage = Catalog.officeStages[state.office] or Catalog.officeStages[1]
	local free = stage.maxStaff - Game.headcount(state)
	if free <= 0 then
		return 0, "office is full, give an office upgrade first"
	end
	n = math.min(n, free)
	state.nextPersonId = state.nextPersonId or 1
	local first
	for _ = 1, n do
		local rid = roleId or Staff.roles[rng:NextInteger(1, #Staff.roles)].id
		local c = Staff.randomCandidate(rng, rid)
		c.rarity = r
		c.skill = math.floor((0.85 + r * 0.08 + rng:NextNumber(0, 0.1)) * 100) / 100
		c.id = state.nextPersonId
		state.nextPersonId += 1
		c.morale, c.rank, c.pc = 90, math.clamp(r - 1, 1, 4), 0
		c.from = "Gift from an admin"
		table.insert(state.people, c)
		state.staff[rid] = (state.staff[rid] or 0) + 1
		first = first or c
	end
	state.stats.hired = (state.stats.hired or 0) + n
	if first then
		Game.chatMsg(state, "general", first.name, "Hi everyone! An admin sent me over. Let's build something big.")
	end
	return n, nil
end

-- Personal boosts a player has right now (for the console and the bottom right icons).
local function boostsOf(state): { any }
	local out = {}
	local now = os.time()
	local b = state.adminLuck
	if type(b) == "table" and (tonumber(b.ends) or 0) > now then
		table.insert(out, {
			id = "luck",
			name = string.format("LUCK X%s", tostring(math.floor(b.mult * 10 + 0.5) / 10)),
			desc = "Your luck is multiplied: rarer hires, better training and bigger launches. Gift from an admin.",
			icon = "trophy",
			color = Color3.fromRGB(0, 220, 120),
			left = b.ends - now,
		})
	end
	for key, ends in pairs(state.giftPerkEnds or {}) do
		local p = Shop.passByKey[key]
		if p and ends > now then
			local desc = tostring(p.desc or ""):gsub("%s*Forever%.?", "")
			table.insert(out, {
				id = "pass_" .. key,
				name = p.name,
				desc = desc .. " Gift from an admin.",
				icon = p.icon or "gift",
				color = p.color,
				left = ends - now,
			})
		end
	end
	table.sort(out, function(a, c)
		return a.id < c.id
	end)
	return out
end

local Commands = {}
Commands._boostsOf = boostsOf

Commands.announce = function(context, text: string)
	local from = context.Executor
	if type(text) ~= "string" or #text == 0 then
		return "Write something to announce"
	end
	local clean = filtered(text:sub(1, 200), from and from.UserId or 0)
	if not clean then
		return "Roblox text filter failed, try again"
	end
	fx():FireAllClients("announce", { text = clean, from = from and from.DisplayName or "Server" })
	return "Announced"
end

Commands.pm = function(context, players: { Player }, text: string)
	local from = context.Executor
	if type(text) ~= "string" or #text == 0 then
		return "Write a message"
	end
	for _, p in ipairs(players) do
		local clean = filtered(text:sub(1, 200), from and from.UserId or 0, p.UserId)
		if clean then
			fx():FireClient(p, "announce", { text = clean, from = from and from.DisplayName or "Server", private = true })
		end
	end
	return "Sent to " .. names(players)
end

Commands.give = function(_context, players: { Player }, item: string)
	-- give all: every pass forever + every product once
	if item == "all" then
		return onSessions(players, function(p, s)
			s.state.giftPerks = s.state.giftPerks or {}
			for _, pass in ipairs(Shop.passes) do
				s.state.giftPerks[pass.key] = true
				if s.state.giftPerkEnds then
					s.state.giftPerkEnds[pass.key] = nil
				end
			end
			Bridge.refreshPasses(p)
			for _, product in ipairs(Shop.products) do
				pcall(grantFree, s.state, product.key, nil)
			end
			gift(p, "EVERYTHING IN THE SHOP")
			return nil
		end)
	end
	if Shop.passByKey[item] then
		return onSessions(players, function(p, s)
			s.state.giftPerks = s.state.giftPerks or {}
			s.state.giftPerks[item] = true
			if s.state.giftPerkEnds then
				s.state.giftPerkEnds[item] = nil
			end
			Bridge.refreshPasses(p)
			gift(p, Shop.passByKey[item].name)
			return nil
		end)
	end
	local product = Shop.productByKey[item]
	if not product then
		return "Unknown item " .. tostring(item)
	end
	return onSessions(players, function(p, s)
		local err = grantFree(s.state, item, nil)
		if err then
			return err
		end
		gift(p, product.name)
		return nil
	end)
end

Commands.take = function(_context, players: { Player }, item: string)
	if item == "all" then
		return onSessions(players, function(p, s)
			s.state.giftPerks = {}
			s.state.giftPerkEnds = nil
			Bridge.refreshPasses(p)
			return nil
		end)
	end
	if not Shop.passByKey[item] then
		return tostring(item) .. " is a one time product, only passes can be taken back"
	end
	return onSessions(players, function(p, s)
		if s.state.giftPerks then
			s.state.giftPerks[item] = nil
		end
		if s.state.giftPerkEnds then
			s.state.giftPerkEnds[item] = nil
		end
		Bridge.refreshPasses(p)
		return nil
	end)
end

Commands.givecash = function(_context, players: { Player }, amount: number)
	local a = num(amount, -1e15, 1e15)
	if not a then
		return "Amount must be a number no bigger than 1e15 either way"
	end
	return onSessions(players, function(p, s)
		s.state.cash = (s.state.cash or 0) + a
		if a > 0 then
			gift(p, "+" .. Format.money(a) .. " CASH")
		end
		return nil
	end)
end

Commands.cashx = function(_context, players: { Player }, mult: number)
	local m = num(mult, 2, 1000)
	if not m then
		return "Multiplier must be between 2 and 1000"
	end
	return onSessions(players, function(p, s)
		local st = s.state
		local cash = st.cash or 0
		-- broke companies get the multiplier on a normal gift instead (x2 of a debt is not a gift)
		local add = cash > 0 and cash * (m - 1) or Game.giftBase(st) * m
		add = math.min(add, 1e15)
		st.cash = cash + add
		Game.chatMsg(st, "general", "Finance", "An admin just multiplied our money: +" .. Format.money(add) .. ".")
		gift(p, "CASH X" .. m)
		return nil
	end)
end

Commands.luck = function(_context, players: { Player }, mult: number, minutes: number?)
	local m = num(mult, 1.1, 10)
	if not m then
		return "Luck multiplier must be between 1.1 and 10"
	end
	local mins = num(minutes or 15, 1, 1440)
	if not mins then
		return "Minutes must be between 1 and 1440"
	end
	m = math.floor(m * 10 + 0.5) / 10
	return onSessions(players, function(p, s)
		local st = s.state
		local now = os.time()
		local b = st.adminLuck
		if type(b) == "table" and b.ends > now and b.mult == m then
			b.ends += math.floor(mins * 60)
		else
			st.adminLuck = { mult = m, ends = now + math.floor(mins * 60) }
		end
		gift(p, "LUCK X" .. m .. " FOR " .. math.floor(mins) .. " MIN")
		return nil
	end)
end

Commands.worker = function(_context, players: { Player }, rarity: string, role: string?, count: number?)
	local r = rarityIndex(rarity)
	if not r then
		return "Unknown rarity " .. tostring(rarity)
	end
	local roleId = (role == nil or role == "any") and nil or role
	if roleId and not Staff.byId[roleId] then
		return "Unknown job " .. tostring(role)
	end
	local n = num(count or 1, 1, 20)
	if not n then
		return "Count must be between 1 and 20"
	end
	n = math.floor(n)
	return onSessions(players, function(p, s)
		local got, err = addWorkers(s.state, r, roleId, n)
		if err then
			return err
		end
		gift(p, got .. " " .. Staff.RARITIES[r].name .. (got == 1 and " WORKER" or " WORKERS"))
		if got < n then
			return "only " .. got .. " fit, the office is full"
		end
		return nil
	end)
end

local PACKS = { small = "gpuS", medium = "gpuM", large = "gpuL" }
Commands.gpupack = function(_context, players: { Player }, size: string)
	local key = PACKS[size]
	if not key then
		return "Size must be small, medium or large"
	end
	return onSessions(players, function(p, s)
		local err = grantFree(s.state, key, nil)
		if err then
			return err
		end
		gift(p, Shop.productByKey[key].name)
		return nil
	end)
end

Commands.finish = function(_context, players: { Player })
	return onSessions(players, function(p, s)
		local st = s.state
		local busy = st.training ~= nil
		for _, m in ipairs(st.models or {}) do
			if m.boosting then
				busy = true
			end
		end
		if not busy then
			return "nothing is training"
		end
		local err = grantFree(st, "finish", nil)
		if err then
			return err
		end
		gift(p, "TRAINING DONE")
		return nil
	end)
end

Commands.givepass = function(_context, players: { Player }, key: string, minutes: number?)
	local pass = Shop.passByKey[key]
	if not pass then
		return "Unknown pass " .. tostring(key)
	end
	local mins = num(minutes or 0, 0, 60 * 24 * 30)
	if not mins then
		return "Minutes must be between 0 (forever) and 43200"
	end
	mins = math.floor(mins)
	return onSessions(players, function(p, s)
		local st = s.state
		st.giftPerks = st.giftPerks or {}
		st.giftPerkEnds = st.giftPerkEnds or {}
		if mins <= 0 then
			st.giftPerks[key] = true
			st.giftPerkEnds[key] = nil
			gift(p, pass.name .. " FOREVER")
		else
			if st.giftPerks[key] and not st.giftPerkEnds[key] then
				return "already has " .. pass.name .. " forever"
			end
			local now = os.time()
			st.giftPerks[key] = true
			st.giftPerkEnds[key] = math.max(st.giftPerkEnds[key] or now, now) + mins * 60
			gift(p, pass.name .. " FOR " .. mins .. " MIN")
		end
		Bridge.refreshPasses(p)
		return nil
	end)
end

Commands.takeall = function(_context, players: { Player })
	return onSessions(players, function(p, s)
		s.state.giftPerks = {}
		s.state.giftPerkEnds = {}
		Bridge.refreshPasses(p)
		return nil
	end)
end

Commands.users = function(_context, players: { Player }, amount: number)
	local a = num(amount, 1, 1e10)
	if not a then
		return "Amount must be between 1 and 10 billion"
	end
	return onSessions(players, function(p, s)
		local st = s.state
		local cap = (st.world and st.world.marketUsers or 100) * 1e6 * Config.MAX_MARKET_SHARE
		local before = st.users or 0
		st.users = math.min(math.max(cap, before), before + a)
		gift(p, "+" .. Format.count(math.floor(st.users - before)) .. " USERS")
		if st.users - before < a then
			return "capped at the market size (" .. Format.count(math.floor(st.users)) .. " users)"
		end
		return nil
	end)
end

Commands.hype = function(_context, players: { Player }, amount: number)
	local a = num(amount, -100, 100)
	if not a then
		return "Hype must be a number from minus 100 to 100"
	end
	return onSessions(players, function(p, s)
		s.state.hype = math.clamp((s.state.hype or 0) + a, 0, 100)
		if a > 0 then
			gift(p, "HYPE " .. math.floor(s.state.hype) .. " OF 100")
		end
		return nil
	end)
end

Commands.skipdays = function(_context, players: { Player }, days: number)
	local d = num(days, 1, 60)
	if not d then
		return "Days must be between 1 and 60"
	end
	d = math.floor(d)
	return onSessions(players, function(p, s)
		for i = 1, d do
			local ok, err = pcall(Game.tickDay, s.state)
			if not ok then
				return "stopped after " .. (i - 1) .. " days: " .. tostring(err)
			end
		end
		gift(p, d .. " DAYS LATER")
		return nil
	end)
end

Commands.heal = function(_context, players: { Player })
	return onSessions(players, function(p, s)
		local st = s.state
		st.problems = {}
		st.misuse = 0
		st.calmUntil = math.max(st.calmUntil or 0, st.day + 30)
		Game.chatMsg(st, "general", "Ops", "Every fire is out. An admin bought us 30 calm days.")
		gift(p, "ALL PROBLEMS FIXED")
		return nil
	end)
end

Commands.office = function(_context, players: { Player }, steps: number?)
	local n = num(steps or 1, 1, #Catalog.officeStages)
	if not n then
		return "Steps must be between 1 and " .. #Catalog.officeStages
	end
	n = math.floor(n)
	return onSessions(players, function(p, s)
		local st = s.state
		local moved = 0
		for _ = 1, n do
			if not Catalog.officeStages[st.office + 1] then
				break
			end
			st.office += 1
			moved += 1
		end
		if moved == 0 then
			return "already has the biggest campus"
		end
		local stage = Catalog.officeStages[st.office]
		Game.newsItem(st, st.company .. " moves into a new " .. stage.name:lower(), "you")
		gift(p, string.upper(stage.name))
		return nil
	end)
end

Commands.resetcd = function(_context, players: { Player })
	return onSessions(players, function(p, s)
		local st = s.state
		st.partyReady = 0
		st.resetReady = 0
		st.cooldowns = {}
		gift(p, "COOLDOWNS RESET")
		return nil
	end)
end

Commands.modelboost = function(_context, players: { Player }, kind: string)
	local key = kind == "super" and "stats10" or (kind == "mega" and "mega" or nil)
	if not key then
		return "Kind must be super or mega"
	end
	return onSessions(players, function(p, s)
		local err = grantFree(s.state, key, nil)
		if err then
			return err
		end
		gift(p, Shop.productByKey[key].name)
		return nil
	end)
end

Commands.jackpot = function(_context, players: { Player })
	return onSessions(players, function(p, s)
		local st = s.state
		local cash = st.cash or 0
		st.cash = cash + math.min(1e15, cash > 0 and cash * 9 or Game.giftBase(st) * 10)
		local now = os.time()
		local b = st.adminLuck
		if not (type(b) == "table" and b.ends > now and b.mult > 2) then
			st.adminLuck = { mult = 2, ends = now + 30 * 60 }
		end
		local r = rarityIndex("legend") or #Staff.RARITIES
		addWorkers(st, r, nil, 1)
		grantFree(st, "gpuM", nil)
		st.problems = {}
		st.misuse = 0
		st.hype = math.min(100, (st.hype or 0) + 30)
		gift(p, "JACKPOT")
		return nil
	end)
end

Commands.clearboosts = function(_context, players: { Player })
	return onSessions(players, function(p, s)
		local st = s.state
		st.adminLuck = nil
		for key in pairs(st.giftPerkEnds or {}) do
			if st.giftPerks then
				st.giftPerks[key] = nil
			end
		end
		st.giftPerkEnds = {}
		Bridge.refreshPasses(p)
		return nil
	end)
end

Commands.boosts = function(_context, players: { Player })
	local lines = {}
	for _, p in ipairs(players) do
		local s = Bridge.sessions[p]
		if not s then
			table.insert(lines, p.Name .. ": no company loaded")
		else
			local list = boostsOf(s.state)
			local parts = {}
			for _, b in ipairs(list) do
				table.insert(parts, b.name .. " (" .. clock(b.left) .. ")")
			end
			local forever = {}
			for key, on in pairs(s.state.giftPerks or {}) do
				if on and not (s.state.giftPerkEnds or {})[key] then
					table.insert(forever, key)
				end
			end
			if #forever > 0 then
				table.insert(parts, "forever: " .. table.concat(forever, ", "))
			end
			table.insert(lines, p.Name .. ": " .. (#parts > 0 and table.concat(parts, ", ") or "nothing"))
		end
	end
	return table.concat(lines, "\n")
end

Commands.troll = function(_context, players: { Player }, kind: string, seconds: number?)
	local t = num(seconds or 5, 1, 60)
	if not t then
		return "Seconds must be between 1 and 60"
	end
	for _, p in ipairs(players) do
		fx():FireClient(p, "troll", { kind = kind, seconds = t })
	end
	return "Trolled " .. names(players) .. " with " .. tostring(kind) .. " for " .. t .. "s"
end

Commands.untroll = function(_context, players: { Player })
	for _, p in ipairs(players) do
		fx():FireClient(p, "untroll", {})
	end
	return "Stopped pranks on " .. names(players)
end

-- World events: tell every server (MessagingService); each server applies it in Main.server
local function markAllDirty()
	for _, s in pairs(Bridge.sessions) do
		s.dirty = true
	end
end

local function broadcast(msg)
	Game.applyWorldEvent(msg)
	markAllDirty()
	pcall(function()
		MessagingService:PublishAsync("FrontierWorldEvents", msg)
	end)
end

Commands.event = function(_context, id: string, minutes: number?)
	local e = Events.byId[id]
	if not e then
		return "Unknown event " .. tostring(id)
	end
	local m = num(minutes or 15, 1, 24 * 60)
	if not m then
		return "Minutes must be between 1 and 1440"
	end
	broadcast({ op = "start", id = id, ends = os.time() + math.floor(m * 60) })
	return e.name .. " started for " .. m .. " minutes in every server"
end

Commands.serverevent = function(_context, id: string, minutes: number?)
	local e = Events.byId[id]
	if not e then
		return "Unknown event " .. tostring(id)
	end
	local m = num(minutes or 15, 1, 24 * 60)
	if not m then
		return "Minutes must be between 1 and 1440"
	end
	Game.applyWorldEvent({ op = "start", id = id, ends = os.time() + math.floor(m * 60) })
	markAllDirty()
	return e.name .. " started for " .. m .. " minutes in this server"
end

Commands.endevent = function(_context, id: string)
	if id ~= "all" and not Events.byId[id] then
		return "Unknown event " .. tostring(id)
	end
	broadcast({ op = "stop", id = id })
	return "Stopped " .. id
end

return Commands
