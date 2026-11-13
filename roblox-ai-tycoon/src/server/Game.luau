--!strict
-- Core simulation for one company. Server-authoritative; the client only sends actions.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS:WaitForChild("Shared")
local Config = require(Shared.Config)
local Format = require(Shared.Format)
local Labs = require(Shared.Labs)
local Hardware = require(Shared.Hardware)
local Staff = require(Shared.Staff)
local Research = require(Shared.Research)
local Opts = require(Shared.TrainingOptions)
local TM = require(Shared.TrainingMath)
local Catalog = require(Shared.Catalog)
local B = require(Shared.Benchmarks)
local Launch = require(script.Parent.Launch)

local Game = {}
local PcParts = require(game:GetService("ReplicatedStorage").Shared.PcParts)
local Decor = require(game:GetService("ReplicatedStorage").Shared.Decor)
local MT = require(Shared.ModelTypes)
local Shop = require(Shared.Shop)
local Website = require(Shared.Website)
local Events = require(Shared.Events)
local rng = Random.new()

local spend: (any, number, string?) -> ()
local function year(state)
	return (Format.dateFromDay(state.day))
end

local function marketUsersM(y: number, day: number): number
	local a = Config.yearValue(Config.MARKET_USERS_M, y)
	local b = Config.yearValue(Config.MARKET_USERS_M, y + 1)
	local _, m = Format.dateFromDay(day)
	return a + (b - a) * (m - 1) / 12
end

local function locationOf(state)
	for _, l in ipairs(Config.LOCATIONS) do
		if l.id == state.location then
			return l
		end
	end
	return Config.LOCATIONS[1]
end
Game.locationOf = locationOf

function Game.new(companyName: string, locationId: string?)
	local state = {
		version = 1,
		company = companyName,
		location = locationId or "paloalto",
		loans = {},
		tut = 1,
		day = 0,
		speed = 1,
		cash = Config.START_CASH,
		credits = Config.START_CLOUD_CREDITS,
		valuation = Config.START_VALUATION,
		equity = Config.START_FOUNDER_EQUITY,
		users = 0,
		brand = 0.02,
		hype = 10,
		reputation = 50,
		regulator = 0,
		openRep = 0,
		launches = 0,
		office = 1,
		staff = {} :: { [string]: number },
		people = {}, -- named hires (shown in Team)
		candidates = {},
		gpus = { owned = {}, rented = {} },
		research = { points = 0, current = nil, done = {} },
		models = {},
		training = nil,
		product = { appName = companyName .. " Chat", subPrice = 20, proPrice = 0, apiPrice = 10, activeModel = nil, freeTier = true },
		history = {}, -- monthly {day, revenue, costs, users, valuation}
		month = { revenue = 0, costs = 0, sub = 0, api = 0, salaries = 0, compute = 0, office = 0, inference = 0 },
		lastMonth = nil,
		feed = {}, -- launches & incidents (full payloads)
		news = {},
		mail = {},
		chat = {},
		goals = {},
		goalWeek = -1,
		investors = {},
		followups = {},
		stats = { trained = 0, released = 0, hired = 0, researched = 0, chats = 0, updates = 0, evals = 0 },
		world = { idx = 1, released = {}, frontier = 30, labBest = {}, future = {}, marketUsers = 100 },
		awayLog = {},
	}
	for _, r in ipairs(Staff.roles) do
		state.staff[r.id] = 0
	end
	state.gpus.owned.laptop = 1
	Game.refreshCandidates(state)
	local loc = locationOf(state)
	Game.mail(state, "Welcome", "You, last night", "The plan", "$150K of savings, one gaming laptop, " .. loc.name:lower() .. ". Train a tiny model in the Lab, ship it, get users. The Bank will lend you money, and once people use your AI, investors will call. The big labs already have chatbots with millions of users. A much smarter one lands in March.")
	Game.chatMsg(state, "general", "Mom", "Did you quit your job?? Call me.")
	Game.newGoals(state)
	Game.advanceWorld(state)
	return state
end

-- ===== messaging =====
function Game.mail(state, kind, from, subject, body, choices)
	local m = { id = #state.mail + 1, kind = kind, from = from, subject = subject, body = body, day = state.day, choices = choices, read = false }
	table.insert(state.mail, 1, m)
	if #state.mail > 60 then
		table.remove(state.mail)
	end
	return m
end

function Game.chatMsg(state, channel, from, text)
	table.insert(state.chat, { ch = channel, from = from, text = text, day = state.day })
	if #state.chat > 120 then
		table.remove(state.chat, 1)
	end
end

function Game.newsItem(state, text, kind)
	table.insert(state.news, 1, { text = text, day = state.day, kind = kind or "rival" })
	if #state.news > 50 then
		table.remove(state.news)
	end
end

-- ===== world / rivals =====
local LAB_OFFSET = { openai = 0, anthropic = -0.5, google = -0.3, meta = -5, xai = -2, mistral = -9, deepseek = -4, qwen = -5, moonshot = -6, zhipu = -8, minimax = -9, microsoft = -10, amazon = -12, cohere = -14, nvidia = -12, perplexity = -8, inflection = -16, character = -14, reka = -12, ai21 = -14, yi = -12, baidu = -6, bytedance = -3, tencent = -6, ssi = -1, thinking = -2, sakana = -10 }

local function addRelease(state, r)
	if state.acquired and state.acquired[r.lab] then
		return -- you own them now
	end
	table.insert(state.world.released, r)
	if r.cap > state.world.frontier then
		state.world.frontier = r.cap
	end
	local lb = state.world.labBest[r.lab]
	if not lb or r.cap >= lb.cap then
		state.world.labBest[r.lab] = { model = r.model, cap = r.cap, day = r.day, priceOut = r.priceOut }
	end
end

function Game.advanceWorld(state)
	local w = state.world
	while Labs.releases[w.idx] and Labs.releases[w.idx].day <= state.day do
		local r = Labs.releases[w.idx]
		addRelease(state, r)
		if state.day - r.day < 10 and not (state.acquired and state.acquired[r.lab]) then
			Game.newsItem(state, Labs.displayName(r.lab) .. " releases " .. r.model .. ". " .. r.note, "rival")
		end
		w.idx += 1
	end
	-- new GPUs: the day one comes out, it is in the news
	for _, h in ipairs(Hardware.list) do
		if h.fromDay == state.day and h.id ~= "laptop" then
			Game.newsItem(state, "NEW GPU: " .. h.name .. " is out. As strong as " .. h.power .. " H1 chips.", "rival")
			Game.chatMsg(state, "infra", "Infra team", "The " .. h.name .. " just launched. Want to upgrade? Check GPUS.")
		end
	end
	-- Future: after the real calendar, each lab ships on its cadence.
	if state.day > Labs.LAST_REAL_DAY then
		for _, lab in ipairs(Labs.list) do
			local names = Labs.futureNames[lab.id]
			-- brand new companies appear in the news the month they are founded
			w.founded = w.founded or {}
			local alive = Labs.isFounded(lab.id, state.day)
			if alive and lab.founded and not w.founded[lab.id] then
				w.founded[lab.id] = true
				Game.newsItem(state, "NEW COMPANY: " .. Labs.displayName(lab.id) .. ". " .. (lab.story or ""), "rival")
				Game.chatMsg(state, "general", "Strategy", "A new rival just showed up: " .. Labs.displayName(lab.id) .. ". Keep an eye on them.")
			end
			if names and alive and not (state.acquired and state.acquired[lab.id]) then
				local nextDay = w.future[lab.id]
				if not nextDay then
					w.future[lab.id] = state.day + rng:NextInteger(20, math.floor(lab.cadence * 30))
				elseif state.day >= nextDay then
					local n = (w.futureCount or {})[lab.id] or 0
					w.futureCount = w.futureCount or {}
					w.futureCount[lab.id] = n + 1
					local name = names[math.min(n + 1, #names)]
					if n + 1 > #names then
						name = names[#names] .. "." .. (n + 1 - #names)
					end
					local cap = Labs.frontierProjection(state.day) + (LAB_OFFSET[lab.id] or -6) + rng:NextNumber(-2, 2) + (w.openBoost or 0)
					local r = { day = state.day, lab = lab.id, model = name, cap = cap, open = lab.open >= 7, priceOut = lab.open >= 7 and 2 or 20, note = "Rumoured to be trained on a gigawatt cluster", future = true }
					addRelease(state, r)
					Game.newsItem(state, Labs.displayName(lab.id) .. " releases " .. name, "rival")
					w.future[lab.id] = state.day + math.floor(lab.cadence * 30 * rng:NextNumber(0.7, 1.4))
				end
			end
		end
	end
	w.marketUsers = marketUsersM(year(state), state.day)
	if w.openBoost then
		w.openBoost *= 0.995
	end
end

-- ===== world events (admin abuse) + luck =====
-- active events for this server: { [id] = endsAt (os.time) }. Started from the F2 console.
Game.worldEvents = {} :: { [string]: number }
function Game.eventFx()
	return Events.combined(Game.worldEvents, os.time())
end

-- start/stop from the console or another server's message; clients see it in the next push
function Game.applyWorldEvent(msg)
	if type(msg) ~= "table" then
		return
	end
	if msg.op == "start" and Events.byId[msg.id] and tonumber(msg.ends) then
		Game.worldEvents[msg.id] = tonumber(msg.ends) :: number
	elseif msg.op == "stop" then
		if msg.id == "all" then
			table.clear(Game.worldEvents)
		else
			Game.worldEvents[msg.id] = nil
		end
	end
end

-- Luck: every Robux purchase adds a little (up to +60%), VIP adds 15%, events multiply it.
function Game.luck(state): number
	local base = 1 + math.min(0.6, ((state.stats and state.stats.robux) or 0) * 0.04)
	if state.perks and state.perks.vip then
		base += 0.15
	end
	return base * Game.eventFx().luck
end

-- ===== helpers =====
-- Robux passes the player owns (set by the server on load, never trusted from the client).
local function perk(state, key): boolean
	return state.perks ~= nil and state.perks[key] == true
end
Game.perk = perk

function Game.clusterPower(state): number
	local p = 0
	for id, n in pairs(state.gpus.owned) do
		p += Hardware.byId[id].power * n
	end
	for id, n in pairs(state.gpus.rented) do
		p += Hardware.byId[id].power * n
	end
	if state.research.done.ownchip then
		p *= 1.25
	end
	if perk(state, "gpu3x") then
		p *= 1.5
	end
	return p
end

-- Max H100-equivalents you can secure this year (scarcity in early years).
function Game.gpuCap(state): number
	local y = year(state)
	local base = Config.yearValue(Config.GPU_ALLOCATION, y)
	return math.floor(base * (0.6 + state.reputation / 125) * math.min(2.5, math.sqrt(1 + state.valuation / 2e10)) * (perk(state, "gpu3x") and 3 or 1))
end

-- GPU places: your room plus any garages or datacenters you bought
function Game.gpuSlots(state): number
	local n = (Catalog.officeStages[state.office].slots or 4) + (state.bonusSlots or 0)
	for id, c in pairs(state.storage or {}) do
		n += Catalog.storageById[id].slots * c
	end
	return n
end

function Game.kwCap(state): number
	local kw = Catalog.officeStages[state.office].kw + PcParts.totals(state.pcStock).kw + (state.bonusKw or 0)
	for id, c in pairs(state.storage or {}) do
		kw += Catalog.storageById[id].kw * c
	end
	return kw
end

function Game.gpuUsed(state): number
	local n = 0
	for _, c in pairs(state.gpus.owned) do
		n += c
	end
	for _, b in ipairs(state.boxes or {}) do
		if b.kind == "buy" then
			n += b.n
		end
	end
	return n
end

function Game.buyStorage(state, id)
	local st = Catalog.storageById[id]
	if not st then
		return false, "Unknown place"
	end
	if state.cash < st.cost then
		return false, "Not enough cash for the " .. st.name
	end
	state.cash -= st.cost
	state.month.costs += st.cost
	state.month.office += st.cost
	state.storage = state.storage or {}
	state.storage[id] = (state.storage[id] or 0) + 1
	Game.chatMsg(state, "infra", "Infra", "We got the " .. st.name .. ". Room for " .. Format.count(st.slots) .. " more GPUs.")
	return true
end

function Game.ownedKw(state): number
	local kw = 0
	for id, n in pairs(state.gpus.owned) do
		kw += Hardware.byId[id].kw * n * 1.4 -- cooling overhead
	end
	return kw
end

function Game.algo(state): number
	local a = 1
	for id in pairs(state.research.done) do
		a *= Research.byId[id].algo
	end
	return a
end

function Game.staffEffects(state)
	local e = { research = 0, infra = 0, data = 0, safety = 0, product = 0, sales = 0, hype = 0 }
	for _, r in ipairs(Staff.roles) do
		e[r.effect] += (state.staff[r.id] or 0) * r.power
	end
	-- rare people do the work of several
	for _, p in ipairs(state.people or {}) do
		local r = Staff.byId[p.role]
		local rar = Staff.RARITIES[p.rarity or 1]
		if r and rar and rar.mult > 1 then
			e[r.effect] += r.power * (rar.mult - 1)
		end
	end
	for k, v in pairs(state.staffLegacy or {}) do
		e[k] = (e[k] or 0) + v
	end
	local f = Game.teamFactor(state)
	for k, v in pairs(e) do
		e[k] = v * f
	end
	return e
end

-- How well your people work: happy, senior, skilled people on good computers do much more.
function Game.teamFactor(state): number
	local people = state.people or {}
	if #people == 0 then
		return 1
	end
	local t = 0
	for _, p in ipairs(people) do
		local mood = 0.55 + (p.morale or 70) / 220
		local pc = (Staff.PCS[(p.pc or 0) + 1] or Staff.PCS[1]).boost
		local rank = 1 + 0.12 * ((p.rank or 1) - 1)
		local away = (p.offUntil and state.day < p.offUntil) and 0.3 or 1
		t += mood * pc * rank * (p.skill or 1) * away
	end
	return t / #people
end

local function personById(state, id)
	for i, p in ipairs(state.people or {}) do
		if p.id == id then
			return p, i
		end
	end
	return nil
end

-- every person gets an id, mood, rank and computer
local function ensurePeople(state)
	state.people = state.people or {}
	state.nextPersonId = state.nextPersonId or 1
	for _, p in ipairs(state.people) do
		if not p.id then
			p.id = state.nextPersonId
			state.nextPersonId += 1
		end
		p.morale = p.morale or 70
		p.rank = p.rank or 1
		p.pc = p.pc or 0
	end
end
Game.ensurePeople = ensurePeople

local TeamActions = {}
function TeamActions.party(state, kind)
	ensurePeople(state)
	local n = #state.people
	if n == 0 then
		return false, "Hire people first"
	end
	if (state.partyReady or 0) > state.day then
		return false, "Another party so soon? Wait until " .. Format.date(state.partyReady)
	end
	local KINDS = { pizza = { 60, 10, "Pizza night" }, party = { 400, 22, "Office party" }, retreat = { 3500, 38, "Team retreat in the mountains" } }
	local k = KINDS[kind]
	if not k then
		return false, "Unknown party"
	end
	local cost = k[1] * Game.headcount(state)
	if state.cash < cost then
		return false, "A " .. k[3]:lower() .. " for everyone costs " .. Format.money(cost)
	end
	state.cash -= cost
	state.month.costs += cost
	state.month.salaries += cost
	state.partyReady = state.day + (kind == "retreat" and 60 or 20)
	for _, p in ipairs(state.people) do
		p.morale = math.min(100, p.morale + k[2])
	end
	Game.chatMsg(state, "general", state.people[rng:NextInteger(1, n)].name, ({ "Best " .. k[3]:lower() .. " ever. Thank you!!", "ok I'm never leaving this company", "who brought the karaoke machine", "I love this team" })[rng:NextInteger(1, 4)])
	return true
end

function TeamActions.promote(state, id)
	ensurePeople(state)
	local p = personById(state, tonumber(id))
	if not p then
		return false, "Not found"
	end
	if p.rank >= #Staff.RANKS then
		return false, p.name .. " is already " .. Staff.RANKS[#Staff.RANKS]
	end
	local cost = math.floor(Staff.monthlyCash(p.role, year(state)) * 3 * p.rank)
	if state.cash < cost then
		return false, "The raise bonus costs " .. Format.money(cost)
	end
	state.cash -= cost
	state.month.costs += cost
	state.month.salaries += cost
	p.rank += 1
	p.morale = math.min(100, p.morale + 22)
	p.raise = (p.raise or 0) + Staff.monthlyCash(p.role, year(state)) * 0.15
	Game.chatMsg(state, "dms", p.name, "Thank you so much for the promotion to " .. Staff.RANKS[p.rank] .. ". I won't let you down.")
	return true
end

function TeamActions.givePc(state, id, tier)
	ensurePeople(state)
	local p = personById(state, tonumber(id))
	tier = math.floor(tonumber(tier) or 0)
	local pc = Staff.PCS[tier + 1]
	if not p or not pc then
		return false, "Not found"
	end
	if p.pc >= tier then
		return false, "They already have that or better"
	end
	if state.cash < pc.price then
		return false, "Not enough cash"
	end
	state.cash -= pc.price
	state.month.costs += pc.price
	state.month.compute += pc.price
	p.pc = tier
	p.morale = math.min(100, p.morale + 8)
	Game.chatMsg(state, "dms", p.name, "A " .. pc.name .. "?? My training scripts are going to fly.")
	return true
end

function TeamActions.answerRequest(state, reqId, yes)
	state.requests = state.requests or {}
	for i, r in ipairs(state.requests) do
		if r.id == reqId then
			table.remove(state.requests, i)
			local p = personById(state, r.person)
			if not p then
				return true
			end
			if yes then
				if r.kind == "dayoff" then
					p.offUntil = state.day + r.days
					p.morale = math.min(100, p.morale + 15)
				elseif r.kind == "raise" then
					p.raise = (p.raise or 0) + r.amount
					p.morale = math.min(100, p.morale + 20)
				elseif r.kind == "pc" then
					if state.cash < Staff.PCS[3].price then
						return false, "Not enough cash"
					end
					state.cash -= Staff.PCS[3].price
					p.pc = math.max(p.pc, 2)
					p.morale = math.min(100, p.morale + 10)
				end
				Game.chatMsg(state, "dms", p.name, "Thank you!")
			else
				p.morale = math.max(0, p.morale - (r.kind == "raise" and 25 or 15))
				Game.chatMsg(state, "dms", p.name, ({ "Oh. Okay.", "Fine.", "Got it.", "...right." })[rng:NextInteger(1, 4)])
			end
			return true
		end
	end
	return false, "Request expired"
end

-- LinkedIn: search with filters, then try to hire one person
function TeamActions.linkedinSearch(state, filters)
	filters = type(filters) == "table" and filters or {}
	local role = Staff.byId[filters.role] and filters.role or "junior"
	local cost = (filters.premium and 300 or 0)
	if cost > 0 then
		if state.cash < cost then
			return false, "LinkedIn Recruiter costs $300"
		end
		state.cash -= cost
	end
	local results = {}
	local n = filters.premium and 8 or 5
	for i = 1, n do
		local f = table.clone(filters)
		if not filters.premium then
			f.minSkill = math.min(tonumber(f.minSkill) or 0.7, 1.0)
		end
		local c = Staff.searchCandidate(rng, role, f)
		c.key = state.day .. "_" .. i .. "_" .. rng:NextInteger(1, 1e6)
		table.insert(results, c)
	end
	state.search = results
	return true
end

-- Pay a place to find people. filters = { role = id or "any", minRarity = 1..6 }
function TeamActions.recruitSearch(state, placeId, filters)
	local place = Staff.placeById[placeId]
	if not place then
		return false, "Unknown place"
	end
	if state.office < place.office then
		return false, place.name .. " only talks to companies with a bigger office"
	end
	filters = type(filters) == "table" and filters or {}
	local minR = math.clamp(math.floor(tonumber(filters.minRarity) or 1), 1, #Staff.RARITIES)
	local role = Staff.byId[filters.role] and filters.role or nil
	local cost = Staff.searchCost(place, year(state), minR, role ~= nil)
	if state.cash < cost then
		return false, "A search here costs " .. Format.money(cost)
	end
	spend(state, cost, "salaries")
	state.search = Game.rollCandidates(state, place, minR, role, place.n)
	state.searchPlace = place.id
	return true
end

function Game.rollCandidates(state, place, minR, role, n)
	local results = {}
	for i = 1, n do
		local rid = role or Staff.roles[rng:NextInteger(1, #Staff.roles)].id
		local c = Staff.randomCandidate(rng, rid)
		-- sometimes it is one of your Roblox friends (their real avatar shows up at a desk)
		local pool = state.friendPool or {}
		if #pool > 0 and rng:NextNumber() < 0.45 then
			local taken = {}
			for _, p in ipairs(state.people or {}) do
				if p.userId then
					taken[p.userId] = true
				end
			end
			for _, x in ipairs(results) do
				if x.userId then
					taken[x.userId] = true
				end
			end
			local free = {}
			for _, f in ipairs(pool) do
				if not taken[f.id] then
					table.insert(free, f)
				end
			end
			if #free > 0 then
				local f = free[rng:NextInteger(1, #free)]
				c.name, c.userId, c.from = f.name, f.id, "Your Roblox friend"
			end
		end
		local ev = Game.eventFx()
		local mr = ev.legends and math.max(minR, 3) or minR
		c.rarity = Staff.rollRarity(rng, place.weights, mr)
		-- luck: a second roll keeps the better one
		if rng:NextNumber() < (Game.luck(state) - 1) * 0.6 then
			c.rarity = math.max(c.rarity, Staff.rollRarity(rng, place.weights, mr))
		end
		c.skill = math.floor((0.85 + c.rarity * 0.08 + rng:NextNumber(0, 0.1)) * 100) / 100
		c.demand = Game.eventFx().legends and 0 or math.clamp((c.rarity - 2) * 0.09, 0, 0.6)
		c.key = state.day .. "_" .. i .. "_" .. rng:NextInteger(1, 1e6)
		table.insert(results, c)
	end
	table.sort(results, function(a, b)
		return a.rarity > b.rarity
	end)
	return results
end

function TeamActions.letGo(state, id)
	for i, p in ipairs(state.people or {}) do
		if p.id == id then
			table.remove(state.people, i)
			state.staff[p.role] = math.max(0, (state.staff[p.role] or 0) - 1)
			Game.chatMsg(state, "general", p.name, "Thanks for everything. Good luck!")
			return true
		end
	end
	return false, "Not found"
end

-- Old saves had thousands of staff. The office cap is small now, so extra heads become team power.
function Game.migrateStaff(state)
	local cap = Catalog.officeStages[state.office].maxStaff
	local total = Game.headcount(state)
	if total <= cap then
		return
	end
	local f = cap / total
	state.staffLegacy = state.staffLegacy or {}
	for _, r in ipairs(Staff.roles) do
		local n = state.staff[r.id] or 0
		local keep = math.floor(n * f)
		state.staffLegacy[r.effect] = (state.staffLegacy[r.effect] or 0) + (n - keep) * r.power
		state.staff[r.id] = keep
	end
	local people = state.people or {}
	while #people > cap do
		table.remove(people)
	end
end

function TeamActions.recruit(state, key)
	local c, idx
	for i, x in ipairs(state.search or {}) do
		if x.key == key then
			c, idx = x, i
		end
	end
	if not c then
		return false, "They are not on the list anymore"
	end
	local stage = Catalog.officeStages[state.office]
	if Game.headcount(state) + 1 > stage.maxStaff then
		return false, "Office is full. Upgrade in Company (max " .. stage.maxStaff .. ")."
	end
	local rar = Staff.RARITIES[c.rarity or 1]
	local signing = Staff.monthlyCash(c.role, year(state)) * 1.5 * (rar and rar.mult or 1) * (c.hot and 2 or 1) * locationOf(state).salary
	if state.cash < signing then
		return false, "Signing bonus is " .. Format.money(signing)
	end
	-- top people say no unless you are hot, famous or rich
	local pull = state.hype / 100 * 0.4 + state.reputation / 100 * 0.4 + math.min(0.3, math.log10(1 + state.valuation / 1e8) * 0.1)
	table.remove(state.search, idx)
	if rng:NextNumber() < (c.demand or 0) - pull then
		Game.chatMsg(state, "dms", c.name, ({ "Thanks, but I'm staying where I am.", "I got a better offer from a bigger lab. Sorry!", "Your company is cool, but not yet. Maybe next year." })[rng:NextInteger(1, 3)])
		return true, "declined"
	end
	state.cash -= signing
	state.month.costs += signing
	state.month.salaries += signing
	state.staff[c.role] += 1
	ensurePeople(state)
	c.id = state.nextPersonId
	state.nextPersonId += 1
	c.morale, c.rank, c.pc = 80, math.clamp((c.rarity or 1) - 1, 1, 4), 0
	c.key = nil
	table.insert(state.people, c)
	state.stats.hired += 1
	Game._goalProgress(state, "hire", 1)
	Game.chatMsg(state, "general", c.name, "Hi everyone! Joining from " .. c.from .. ". Let's build something big.")
	return true, "hired"
end

-- hire everyone on the list you can pay for and fit, best first
function TeamActions.recruitAll(state)
	local hired, said_no = 0, 0
	local list = table.clone(state.search or {})
	table.sort(list, function(a, b)
		return (a.rarity or 1) > (b.rarity or 1)
	end)
	local why
	for _, c in ipairs(list) do
		local ok, res = TeamActions.recruit(state, c.key)
		if ok and res == "hired" then
			hired += 1
		elseif ok and res == "declined" then
			said_no += 1
		elseif not ok then
			why = res
			if type(res) == "string" and res:find("full") then
				break
			end
		end
	end
	if hired == 0 and said_no == 0 then
		return false, why or "Nobody to hire"
	end
	return true, string.format("Hired %d%s", hired, said_no > 0 and (", " .. said_no .. " said no") or "")
end

-- the recruiter: every month fills empty desks by himself with the best place you can afford
function TeamActions.setAutoHire(state, on)
	state.autoHire = on == true
	return true
end

function Game.autoHire(state)
	if not state.autoHire then
		return
	end
	local stage = Catalog.officeStages[state.office]
	local free = stage.maxStaff - Game.headcount(state)
	if free <= 0 then
		return
	end
	-- never spend more than a fifth of the cash on one month of hiring
	local budget = math.max(0, state.cash) * 0.2
	local place
	for _, pl in ipairs(Staff.PLACES) do
		if state.office >= pl.office and Staff.searchCost(pl, year(state), 1, false) <= budget * 0.25 then
			place = pl
		end
	end
	if not place then
		return
	end
	local cost = Staff.searchCost(place, year(state), 1, false)
	spend(state, cost, "salaries")
	local startCash = state.cash
	local keep = state.search
	state.search = Game.rollCandidates(state, place, 1, nil, place.n)
	local hired = 0
	for _, c in ipairs(table.clone(state.search)) do
		if hired >= free or startCash - state.cash > budget then
			break
		end
		local ok, res = TeamActions.recruit(state, c.key)
		if ok and res == "hired" then
			hired += 1
		end
	end
	state.search = keep
	if hired > 0 then
		Game.chatMsg(state, "general", "Recruiter", string.format("I hired %d new %s from the %s this month.", hired, hired == 1 and "person" or "people", place.name))
	end
end

-- daily: moods drift, tired people quit, people ask for things
function Game.tickTeam(state)
	ensurePeople(state)
	state.requests = state.requests or {}
	local busy = state.training and 0.12 or 0
	local hard = (state.problems and #state.problems > 0) and 0.15 or 0
	for i = #state.people, 1, -1 do
		local p = state.people[i]
		p.morale = math.clamp(p.morale - 0.12 - busy - hard + (p.offUntil and state.day < p.offUntil and 1.5 or 0), 0, 100)
		if p.morale < 25 and rng:NextNumber() < 0.025 then
			table.remove(state.people, i)
			if (state.staff[p.role] or 0) > 0 then
				state.staff[p.role] -= 1
			end
			Game.chatMsg(state, "general", p.name, ({ "I'm out. This place burned me out.", "Today is my last day. Good luck everyone.", "Leaving for a bigger lab. They actually throw parties." })[rng:NextInteger(1, 3)])
			Game.newsItem(state, p.name .. " leaves " .. state.company, "press")
		end
	end
	-- requests
	for i = #state.requests, 1, -1 do
		local r = state.requests[i]
		if state.day > r.expires then
			table.remove(state.requests, i)
			local p = personById(state, r.person)
			if p then
				p.morale = math.max(0, p.morale - 10)
			end
		end
	end
	if #state.people > 0 and #state.requests < 4 and rng:NextNumber() < 0.04 + #state.people * 0.004 then
		local p = state.people[rng:NextInteger(1, #state.people)]
		state.nextReq = (state.nextReq or 0) + 1
		local roll = rng:NextNumber()
		local r
		if roll < 0.5 then
			local days = rng:NextInteger(1, 5)
			r = { kind = "dayoff", days = days, text = ({ "Can I take " .. days .. " days off? I'm exhausted.", "My sister is getting married, can I have " .. days .. " days off?", "I need " .. days .. " days off to recharge." })[rng:NextInteger(1, 3)] }
		elseif roll < 0.8 then
			local amt = math.floor(Staff.monthlyCash(p.role, year(state)) * 0.12)
			r = { kind = "raise", amount = amt, text = "I got an offer from another lab. Can you raise me " .. Format.money(amt) .. " a month?" }
		else
			r = { kind = "pc", text = "My laptop is too slow for real experiments. Can I get a workstation (" .. Format.money(Staff.PCS[3].price) .. ")?" }
		end
		r.id, r.person, r.name, r.expires = state.nextReq, p.id, p.name, state.day + 6
		table.insert(state.requests, r)
		Game.chatMsg(state, "dms", p.name, r.text)
	end
end

function Game.headcount(state): number
	local n = 0
	for _, c in pairs(state.staff) do
		n += c
	end
	return n
end

function Game.bestModel(state)
	local best
	for _, m in ipairs(state.models) do
		if m.status == "released" and (m.kind or "chat") == "chat" and (not best or m.cap > best.cap) then
			best = m
		end
	end
	return best
end

function Game.trainCtx(state)
	local best = Game.bestModel(state)
	return {
		researched = state.research.done,
		algo = Game.algo(state),
		clusterPower = Game.clusterPower(state),
		staff = Game.staffEffects(state),
		bestCap = best and best.cap or nil,
		year = year(state),
	}
end

spend = function(state, amount, bucket)
	state.cash -= amount
	state.month.costs += amount
	if bucket then
		state.month[bucket] = (state.month[bucket] or 0) + amount
	end
end

local function goalProgress(state, id, amount)
	for _, g in ipairs(state.goals) do
		if g.id == id and not g.claimed then
			g.progress = math.min(g.target, g.progress + (amount or 1))
		end
	end
end
Game._goalProgress = goalProgress

-- ===== goals =====
function Game.newGoals(state)
	state.goals = {}
	local pool = table.clone(Catalog.goalPool)
	local scale = 2 ^ math.max(0, year(state) - 2023) * (1 + state.valuation / 5e8)
	for _ = 1, Config.GOALS_PER_WEEK do
		local g = table.remove(pool, rng:NextInteger(1, #pool))
		local target = g.target
		if g.scale then
			target = math.floor(g.target * scale)
		end
		local text = g.text:find("%%") and string.format(g.text, g.scale and Format.count(target) or target) or g.text
		table.insert(state.goals, { id = g.id, text = text, target = target, progress = 0, reward = math.floor(g.reward * scale / 1000) * 1000, claimed = false })
	end
end

-- ===== staff =====
function Game.refreshCandidates(state)
	state.candidates = {}
	for _, r in ipairs(Staff.roles) do
		table.insert(state.candidates, Staff.randomCandidate(rng, r.id))
	end
end

-- ===== actions =====
local Actions = {}
for k, v in pairs(TeamActions) do
	Actions[k] = v
end

function Actions.buyDecor(state, id)
	local d = Decor.byId[id]
	if not d then
		return false, "Unknown item"
	end
	state.decor = state.decor or {}
	if state.decor[id] then
		return false, "You already have it"
	end
	if state.cash < d.price then
		return false, "Not enough cash"
	end
	state.cash -= d.price
	state.month.costs += d.price
	state.month.office += d.price
	state.decor[id] = true
	if d.hype then
		state.hype = math.min(100, state.hype + d.hype)
	end
	return true
end

function Actions.removePcPart(state, cat)
	state.pc = state.pc or PcParts.default()
	local cur = PcParts.get(state.pc, cat)
	if not cur or cur.tier <= 1 then
		return false, "Nothing to remove"
	end
	local back = math.floor(cur.price * 0.4)
	state.cash += back
	state.pcStock = state.pcStock or {}
	local key = cat .. ":" .. cur.id
	if (state.pcStock[key] or 0) > 1 then
		state.pcStock[key] -= 1
	else
		state.pcStock[key] = nil
		state.pc[cat] = PcParts.list[cat][1].id
	end
	Game.chatMsg(state, "infra", "Infra", "Took out the " .. cur.name .. " and sold it for " .. Format.money(back) .. ".")
	return true
end

-- RAM and cooling you have vs what your own GPUs need
function Game.pcSupply(state)
	if not state.pcStock then
		-- older saves: count each installed part once
		state.pcStock = {}
		for _, cat in ipairs({ "ram", "cooling", "psu", "storage" }) do
			local id = state.pc and state.pc[cat]
			if id and PcParts.byId[cat][id] and PcParts.byId[cat][id].tier > 1 then
				state.pcStock[cat .. ":" .. id] = 1
			end
		end
	end
	local n = 0
	for id, c in pairs(state.gpus.owned) do
		if id ~= "laptop" then
			n += c
		end
	end
	local have = PcParts.totals(state.pcStock)
	local need = PcParts.needs(n, Game.ownedKw(state))
	return have, need
end

-- not enough RAM = slower training; not enough cooling = more heat problems
function Game.pcFactors(state)
	local have, need = Game.pcSupply(state)
	local ram = math.clamp(have.gb / math.max(need.gb, 1), 0.35, 1)
	local cool = math.clamp(need.cool / math.max(have.cool, 0.1), 0.3, 4)
	return ram, cool
end

function Actions.buyPcPart(state, cat, id, n)
	local part = PcParts.byId[cat] and PcParts.byId[cat][id]
	if not part then
		return false, "Unknown part"
	end
	n = math.clamp(math.floor(tonumber(n) or 1), 1, 10000)
	state.pc = state.pc or PcParts.default()
	state.pcStock = state.pcStock or {}
	local multi = cat == "ram" or cat == "cooling" or cat == "psu" or cat == "storage"
	if not multi and state.pc[cat] == id then
		return false, "Already installed"
	end
	if year(state) < part.year then
		return false, part.name .. " comes out in " .. part.year
	end
	local cost = part.price * (multi and n or 1)
	if state.cash < cost then
		return false, "Not enough cash (" .. Format.money(cost) .. ")"
	end
	state.cash -= cost
	state.month.costs += cost
	state.month.compute += cost
	if multi then
		local key = cat .. ":" .. id
		state.pcStock[key] = (state.pcStock[key] or 0) + n
	end
	if (PcParts.byId[cat][state.pc[cat]] or PcParts.list[cat][1]).tier < part.tier then
		state.pc[cat] = id
	end
	if part.hype and part.hype > 0 then
		state.hype = math.min(100, state.hype + part.hype)
	end
	Game.chatMsg(state, "infra", "Infra", "Installed the " .. part.name .. ". " .. part.blurb)
	return true
end
-- one button: buy the cheapest RAM and cooling that cover what your GPUs need
function Actions.autoSupply(state)
	local have, need = Game.pcSupply(state)
	local bought = 0
	for _, cat in ipairs({ "ram", "cooling" }) do
		local field = cat == "ram" and "gb" or "cool"
		local missing = need[field] - have[field]
		if missing > 0 then
			-- best value part available this year
			local pick
			for _, part in ipairs(PcParts.list[cat]) do
				local amount = part.gb or part.cool or 0
				if part.tier > 1 and year(state) >= part.year and amount > 0 then
					if not pick or part.price / amount < pick.price / (pick.gb or pick.cool) then
						pick = part
					end
				end
			end
			if pick then
				local amount = pick.gb or pick.cool
				local n = math.ceil(missing / amount)
				local ok = Actions.buyPcPart(state, cat, pick.id, n)
				if ok then
					bought += 1
				end
			end
		end
	end
	if bought == 0 then
		return false, "Nothing to buy, or not enough cash"
	end
	return true
end
Actions.buyStorage = function(...) return Game.buyStorage(...) end
-- tutorial step for this company (99 = finished or skipped)
function Actions.tutStep(state, n)
	state.tut = math.clamp(math.floor(tonumber(n) or 99), 1, 99)
	return true
end
Game.Actions = Actions

function Actions.setSpeed(state, s)
	if table.find(Config.SPEEDS, s) or (s == 8 and perk(state, "speed8")) then
		state.speed = s
	end
	return true
end

function Actions.hire(state, roleId, count)
	count = math.clamp(tonumber(count) or 1, 1, 100)
	local role = Staff.byId[roleId]
	if not role then
		return false, "Unknown role"
	end
	local stage = Catalog.officeStages[state.office]
	if Game.headcount(state) + count > stage.maxStaff then
		return false, "Office is full. Upgrade in Company (max " .. stage.maxStaff .. ")."
	end
	local signing = Staff.monthlyCash(roleId, year(state)) * count * locationOf(state).salary
	if state.cash < signing then
		return false, "Not enough cash for the signing bonus"
	end
	spend(state, signing, "salaries")
	state.staff[roleId] += count
	local eq = Staff.equityCost(roleId, year(state), state.valuation) * count
	state.equity = math.max(0.05, state.equity - eq * state.equity)
	-- named people (cap the visible list)
	for i = 1, count do
		local c
		for idx, cand in ipairs(state.candidates) do
			if cand.role == roleId then
				c = table.remove(state.candidates, idx)
				break
			end
		end
		c = c or Staff.randomCandidate(rng, roleId)
		if #state.people < 200 then
			state.nextPersonId = state.nextPersonId or 1
			c.id, c.morale, c.rank, c.pc = state.nextPersonId, 75, 1, 0
			state.nextPersonId += 1
			table.insert(state.people, c)
		end
		if i == 1 then
			Game.chatMsg(state, "general", c.name, ({ "Hey team! Excited to be here.", "First day. Where are the GPUs?", "Just joined. Already found a bug in the eval harness.", "Hi all. Coffee machine is broken btw." })[rng:NextInteger(1, 4)])
		end
	end
	table.insert(state.candidates, Staff.randomCandidate(rng, roleId))
	state.stats.hired += count
	goalProgress(state, "hire", count)
	return true
end

function Actions.fire(state, roleId)
	if (state.staff[roleId] or 0) <= 0 then
		return false, "Nobody to let go"
	end
	state.staff[roleId] -= 1
	for i, p in ipairs(state.people) do
		if p.role == roleId then
			table.remove(state.people, i)
			break
		end
	end
	state.reputation -= 0.5
	return true
end

function Actions.rent(state, id, n)
	local h = Hardware.byId[id]
	n = math.floor(tonumber(n) or 0)
	if not h or not Hardware.available(h, state.day) then
		return false, "Not available yet"
	end
	local cur = state.gpus.rented[id] or 0
	if cur + n < 0 then
		n = -cur
	end
	if n > 0 and Game.clusterPower(state) + h.power * n > Game.gpuCap(state) then
		-- over your allocation: a broker finds GPUs, but the extra ones cost 8x
		local room = math.max(0, math.floor((Game.gpuCap(state) - Game.clusterPower(state)) / h.power))
		local over = n - room
		local fee = Hardware.rentPrice(h, year(state)) * 24 * 30 * 8 * over
		if state.cash < fee then
			return false, string.format("Over your GPU limit the extra %d cost 8x: a %s broker fee. Not enough cash.", over, Format.money(fee))
		end
		spend(state, fee, "compute")
		Game.chatMsg(state, "infra", "Infra", string.format("Over our limit, so a broker found %d extra GPUs. We paid 8x: %s.", over, Format.money(fee)))
	end
	if n > 0 then
		-- new parts arrive in a box at home; they start working once you open it
		state.boxes = state.boxes or {}
		table.insert(state.boxes, { kind = "rent", id = id, n = n })
		goalProgress(state, "gpus", n)
		return true
	end
	state.gpus.rented[id] = cur + n
	return true
end

function Actions.buy(state, id, n)
	local h = Hardware.byId[id]
	n = math.floor(tonumber(n) or 0)
	if not h or not Hardware.available(h, state.day) or n <= 0 then
		return false, "Not available"
	end
	-- over your allocation you can still buy, but the extra GPUs cost 8x (grey market)
	local room = math.max(0, math.floor((Game.gpuCap(state) - Game.clusterPower(state)) / h.power))
	local over = math.max(0, n - room)
	local price = Hardware.buyPrice(h, year(state)) * (n - over + over * 8) * Game.eventFx().gpuPrice
	if state.cash < price then
		return false, "Not enough cash"
	end
	local stage = Catalog.officeStages[state.office]
	if Game.gpuUsed(state) + n > Game.gpuSlots(state) then
		return false, string.format("No space. You have room for %s GPUs. Buy a garage or a datacenter in Parts, or upgrade your office.", Format.count(Game.gpuSlots(state)))
	end
	if Game.ownedKw(state) + h.kw * 1.4 * n > Game.kwCap(state) then
		return false, string.format("Not enough power. Your places support %s kW. Buy more storage, rent in the cloud or upgrade.", Format.count(Game.kwCap(state)))
	end
	spend(state, price, "compute")
	state.boxes = state.boxes or {}
	table.insert(state.boxes, { kind = "buy", id = id, n = n })
	goalProgress(state, "gpus", n)
	return true
end

function Actions.openBoxes(state)
	local boxes = state.boxes or {}
	if #boxes == 0 then
		return false, "No packages"
	end
	local items = {}
	for _, b in ipairs(boxes) do
		local h = Hardware.byId[b.id]
		local bucket = b.kind == "buy" and state.gpus.owned or state.gpus.rented
		bucket[b.id] = (bucket[b.id] or 0) + b.n
		table.insert(items, { name = h.name, n = b.n, power = h.power * b.n, kind = b.kind, vendor = h.vendor })
	end
	state.boxes = {}
	return true, items
end

function Actions.sell(state, id, n)
	local h = Hardware.byId[id]
	n = math.min(math.floor(tonumber(n) or 0), state.gpus.owned[id] or 0)
	if not h or n <= 0 then
		return false, "Nothing to sell"
	end
	state.gpus.owned[id] -= n
	state.cash += Hardware.buyPrice(h, year(state)) * 0.55 * n
	return true
end

function Actions.setResearch(state, id)
	local node = Research.byId[id]
	if not node or state.research.done[id] then
		return false, "Not available"
	end
	for _, req in ipairs(node.req or {}) do
		if not state.research.done[req] then
			return false, "Requires " .. Research.byId[req].name
		end
	end
	local stars = state.staff.star or 0
	if state.day < node.fromDay - math.min(180, stars * 60) then
		return false, "Nobody knows how to do this yet. Available around " .. Format.monthYear(node.fromDay) .. " (star researchers can get there sooner)."
	end
	state.research.current = id
	return true
end

function Actions.train(state, recipe)
	if state.training then
		return false, "Already training a model"
	end
	if type(recipe) ~= "table" or type(recipe.choices) ~= "table" or type(recipe.mix) ~= "table" then
		return false, "Bad recipe"
	end
	recipe.size = tonumber(recipe.size) or 3
	if not table.find(Opts.SIZES, recipe.size) then
		return false, "Bad size"
	end
	local ctx = Game.trainCtx(state)
	if ctx.clusterPower <= 0 then
		return false, "You have no GPUs. Rent some in Parts."
	end
	local ev = TM.evaluate(recipe, ctx)
	if #ev.locked > 0 then
		return false, "Locked options: " .. table.concat(ev.locked, ", ")
	end
	if ev.days > 730 then
		return false, string.format("That would take %d years on your cluster. Get more GPUs or pick a smaller model.", math.floor(ev.days / 365))
	end
	if state.cash < 0 then
		return false, "You are out of cash. Raise money in Bank first."
	end
	if state.cash < ev.extraCost then
		return false, "Not enough cash for data and post-training costs (" .. Format.money(ev.extraCost) .. ")"
	end
	ev.extraCost *= Config.DIFFICULTY / 2 * Game.smallDiscount(state) * MT.get(recipe.kind).cost
	if state.cash < ev.extraCost then
		return false, "Not enough cash for data and post-training (" .. Format.money(ev.extraCost) .. ")"
	end
	spend(state, ev.extraCost, "compute")
	local name = tostring(recipe.name or "")
	if #name < 2 then
		local kk = MT.get(recipe.kind)
		name = state.company .. (kk.id == "chat" and "" or (" " .. kk.short)) .. "-" .. (#state.models + 1)
	end
	name = name:sub(1, 32)
	local noiseSd = 2.5 * ev.noise
	local actual = ev.cap + rng:NextNumber(-1, 1) * noiseSd
	state.training = {
		name = name,
		recipe = recipe,
		eval = ev,
		actualCap = actual,
		progress = 0,
		days = ev.days,
		elapsed = 0,
		losses = {},
		seed = rng:NextNumber(0, 100),
		spikes = 0,
	}
	state.taps = 0
	Game.chatMsg(state, "research", "Training bot", string.format("Run %s started: %s params, %s tokens. ETA %d days.", name, Format.count(ev.params), Format.count(ev.tokens), math.ceil(ev.days)))
	return true
end

function Actions.cancelTraining(state)
	if not state.training then
		return false, "Nothing training"
	end
	state.training = nil
	return true
end

-- ===== Simple Lab: six stats (0-100), pick two to train =====
Game.STATS = { "coding", "writing", "math", "reasoning", "chat", "safety" }

function Game.initStats(m)
	local a = m.abilities or {}
	local function st(v)
		return math.max(1, math.floor(v + 0.5))
	end
	m.stats = {
		coding = st(m.cap + (a.coding or 0) * 1.5),
		writing = st(m.cap + (a.writing or 0) * 1.2),
		math = st(m.cap + (a.math or 0) * 1.5),
		reasoning = st(m.cap + (a.reasoning or 0) * 1.5),
		chat = st(m.cap + (a.writing or 0) + 4),
		safety = st(20 + (m.flaws.safety or 15) * 1.4),
	}
	m.baseCap = m.cap
	-- each stat can grow ~25-40 points; bigger models have more room
	m.statMax = {}
	local room = 22 + math.clamp(math.log(m.size + 1, 2) * 2.2, 0, 22)
	for k, v in pairs(m.stats) do
		m.statMax[k] = math.min(100, v + math.floor(room))
	end
	local sum = 0
	for _, k in ipairs(Game.STATS) do
		sum += m.stats[k]
	end
	m.baseAvg = sum / #Game.STATS
end

-- Stats drive the real model numbers used by launches, users and benchmarks.
function Game.applyStats(m)
	local s = m.stats
	local sum = 0
	for _, k in ipairs(Game.STATS) do
		if k ~= "safety" then
			sum += s[k]
		end
	end
	local avg = sum / 5
	m.cap = m.baseCap + (avg - m.baseAvg) * 0.45
	m.abilities.coding = (s.coding - avg) / 2
	m.abilities.math = (s.math - avg) / 2
	m.abilities.reasoning = (s.reasoning - avg) / 2
	m.abilities.writing = (s.writing + s.chat) / 2 - avg
	m.flaws.safety = s.safety / 1.4
	m.flaws.jailbreak = math.clamp(0.95 - s.safety / 105, 0.05, 0.95)
	m.flaws.refuse = math.clamp(0.08 + math.max(0, s.safety - 70) / 150, 0, 0.6)
	m.flaws.halluc = math.clamp(0.4 - s.reasoning / 250, 0.03, 0.6)
	m.flaws.syco = math.clamp(0.3 - s.safety / 400 + s.chat / 600, 0.02, 0.6)
	m.flaws.escape = (m.features and m.features.agents and s.safety < 40) and 0.15 or 0
end

-- One button: the game picks the biggest model your GPUs can train in about a month.
function Actions.createModel(state, name, kindId)
	if state.training then
		return false, "Already training a model"
	end
	local ctx = Game.trainCtx(state)
	if ctx.clusterPower <= 0 then
		return false, "You have no GPUs. Get some in Parts."
	end
	local kind = MT.get(type(kindId) == "string" and kindId or "chat")
	if not MT.unlocked(kind, state.day) and not (state.earlyKinds and state.earlyKinds[kind.id]) then
		return false, kind.name .. " is not invented yet. It unlocks in " .. Format.monthYear(kind.fromDay) .. "."
	end
	local recipe = Opts.defaultRecipe()
	recipe.name = tostring(name or "")
	local chosen = Opts.SIZES[1]
	for _, sz in ipairs(Opts.SIZES) do
		recipe.size = sz
		if TM.evaluate(recipe, ctx).days <= 35 then
			chosen = sz
		end
	end
	recipe.size = chosen
	-- a small company trains a smaller first model it can actually pay for
	for i = #Opts.SIZES, 1, -1 do
		local sz = Opts.SIZES[i]
		if sz <= chosen then
			recipe.size = sz
			local ev = TM.evaluate(recipe, ctx)
			if ev.extraCost * Config.DIFFICULTY / 2 * Game.smallDiscount(state) * kind.cost <= state.cash * 0.6 then
				break
			end
		end
	end
	-- newer tricks are switched on automatically once your team knows them
	local d = state.research.done
	if d.rlhf then
		recipe.choices.align.rlhf = true
	end
	if d.reasoning then
		recipe.choices.skills.rlvr = true
		recipe.choices.think = "hybrid"
		if not d.hybrid then
			recipe.choices.think = "high"
		end
	end
	if d.tools then
		recipe.choices.skills.tools = true
	end
	if d.moe then
		recipe.choices.arch = d.finemoe and "finemoe" or "moe"
	end
	if d.mla then
		recipe.choices.attn = "mla"
	end
	if d.fp8 then
		recipe.choices.precision = "fp8"
	end
	if d.vision then
		recipe.choices.modal.vision = true
	end
	if d.longctx then
		recipe.choices.ctx = "1m"
	elseif d.rope then
		recipe.choices.ctx = "128k"
	end
	-- model types like VOICE or VIDEO take several times longer to train
	recipe.kind = kind.id
	return Actions.train(state, recipe)
end

local function avgStat(m)
	local t, n = 0, 0
	for k, v in pairs(m.stats or {}) do
		if k ~= "safety" then
			t += v
			n += 1
		end
	end
	return n > 0 and t / n or m.cap
end
Game.avgStat = avgStat

-- Smarter models get very expensive: compute + electricity, growing ~6% per point.
function Game.boostCost(state, m)
	local D = Config.DIFFICULTY
	local level = 1.035 ^ math.max(0, avgStat(m) - 15)
	return math.floor(1500 * (1 + m.size) ^ 0.75 * (1 + (year(state) - 2023) * 0.3) * D * level * Game.smallDiscount(state) / 100) * 100
end

-- A tiny startup pays a fraction (it trains small, on cheap power): your first models fit in $150K.
function Game.smallDiscount(state): number
	return math.clamp((math.max(state.valuation, 0) + math.max(state.cash, 0)) / 3e6, 0.15, 1)
end

-- Electricity for one training round, on top of the compute cost.
function Game.boostPower(state, m)
	local kw = Game.clusterPower(state) * 1.0
	return math.floor(kw * 24 * Game.boostDays(state, m) * 0.12 * Config.DIFFICULTY * (1 + avgStat(m) / 40) * Game.smallDiscount(state))
end

-- You need enough ML people to push a model further.
function Game.boostStaffNeeded(m)
	return math.max(0, math.floor((avgStat(m) - 40) / 15))
end

-- Better GPUs and more infra engineers = faster training.
function Game.boostDays(state, m)
	local power = math.max(Game.clusterPower(state), 0.01)
	local infra = Game.staffEffects(state).infra
	local ramF = Game.pcFactors(state)
	local pcSpeed = PcParts.get(state.pc, "cpu").speed * PcParts.get(state.pc, "storage").speed * ramF * Decor.speed(state.decor)
	local d = 6 * (m.size / 7) ^ 0.55 / power ^ 0.5 / (1 + infra * 0.08) / pcSpeed
	if perk(state, "train2x") then
		d /= 2
	end
	if state.turboUntil and state.day < state.turboUntil then
		d /= 3
	end
	d /= Game.eventFx().train
	return math.clamp(math.ceil(d), 1, 30)
end

-- What is possible right now: you can beat today's best models, but not by decades.
function Game.eraCeiling(state)
	return math.floor(state.world.frontier + 14)
end

-- Pick two stats to train.
function Actions.boost(state, modelId, a, b)
	local m = state.models[modelId]
	if not m or not m.stats or m.status == "retired" then
		return false, "Pick a model"
	end
	if m.boosting then
		return false, "Already training this model"
	end
	if b == "" then
		b = nil
	end
	if not m.stats[a] or (b and (not m.stats[b] or a == b)) then
		return false, "Pick 1 or 2 different stats"
	end
	local ceil = Game.eraCeiling(state)
	-- past this year's limit you can still push, but each round only adds +1
	local need = Game.boostStaffNeeded(m)
	local have = (state.staff.junior or 0) + (state.staff.senior or 0) + (state.staff.star or 0)
	if have < need then
		return false, "A model this smart needs " .. need .. " ML engineers to keep improving. You have " .. have .. "."
	end
	-- one stat: cheaper, and all the effort goes into it
	local cost = (Game.boostCost(state, m) + Game.boostPower(state, m)) * (b and 1 or 0.6)
	if state.cash < cost then
		return false, "Not enough cash (" .. Format.money(cost) .. " with electricity)"
	end
	spend(state, cost, "compute")
	m.boosting = { a = a, b = b, doneDay = state.day + Game.boostDays(state, m), startDay = state.day }
	state.taps = 0
	return true
end

-- Learn from an open-weights model (distillation): your stats move toward its level.
function Game.openModelSize(cap: number): number
	return math.floor(math.clamp(2 ^ ((cap - 20) / 6), 1, 8000))
end

function Actions.learnFrom(state, modelId, releaseIdx)
	local m = state.models[modelId]
	local r = state.world.released[tonumber(releaseIdx) or 0]
	if not m or not m.stats then
		return false, "Pick one of your models first"
	end
	if not r or not r.open then
		return false, "That model is not open source"
	end
	if m.boosting then
		return false, "This model is already training"
	end
	local cost = (Game.boostCost(state, m) + Game.boostPower(state, m)) * 1.4
	if state.cash < cost then
		return false, "Learning from it costs " .. Format.money(cost)
	end
	spend(state, cost, "compute")
	m.boosting = { a = "learn", from = r.model, target = r.cap, doneDay = state.day + math.ceil(Game.boostDays(state, m) * 1.5), startDay = state.day }
	state.taps = 0
	Game.chatMsg(state, "research", "Training bot", m.name .. " is studying " .. r.model .. ". Open weights are a gift.")
	return true
end

local function finishBoost(state, m)
	local bst = m.boosting
	if bst.a == "learn" then
		m.boosting = nil
		local gains = 0
		for k, v in pairs(m.stats) do
			if k ~= "safety" then
				local g = bst.target > v and math.max(1, math.floor((bst.target - v) * 0.35 * Game.luck(state) ^ 0.5)) or 1
				m.stats[k] = v + g
				gains += g
			end
		end
		Game.applyStats(m)
		m.lastGain = "+" .. gains .. " TOTAL FROM " .. tostring(bst.from):upper()
		Game.chatMsg(state, "research", "Training bot", m.name .. " finished learning from " .. tostring(bst.from) .. ". " .. m.lastGain)
		state.stats.updates += 1
		return
	end
	m.boosting = nil
	local fx = Game.staffEffects(state)
	local gains = {}
	local ceil = Game.eraCeiling(state)
	local power = math.max(Game.clusterPower(state), 0.01)
	for _, k in ipairs({ bst.a, bst.b }) do
		-- more GPUs, a better team and a bigger model all give bigger jumps
		local base = (3 + rng:NextNumber(0, 4) + math.log(1 + power, 2) * 0.8 + math.log(1 + fx.research) * 1.6 + math.log10(1 + m.size) * 1.2) * Game.luck(state) ^ 0.6
		-- no hard cap, but going past what is possible this year gets very slow
		-- past this year's best it slows down, but it never stops: everything is reachable with time
		local over = m.stats[k] - ceil
		local mult = over < -10 and 1 or (over < 0 and math.clamp(0.55 - over / 22, 0.55, 1) or math.max(0.08, 0.5 / (1 + over / 8)))
		local g = math.max(2, math.floor(base * mult * (bst.b and 1 or 1.5) * (perk(state, "train2x") and 2 or 1) + 0.5))
		m.stats[k] += g
		table.insert(gains, (g > 0 and ("+" .. g) or "MAXED") .. " " .. k:sub(1, 1):upper() .. k:sub(2))
	end
	Game.applyStats(m)
	-- pushing GPUs this hard can fry some of them
	local fx2 = Game.staffEffects(state)
	if rng:NextNumber() < 0.08 * (1 + avgStat(m) / 80) / (1 + fx2.infra * 0.2) * select(2, Game.pcFactors(state)) * 0.5 then
		local best, bestN, bucket
		for _, b in ipairs({ state.gpus.owned, state.gpus.rented }) do
			for id, n in pairs(b) do
				if id ~= "laptop" and n > 0 and (not best or Hardware.byId[id].power > Hardware.byId[best].power) then
					best, bestN, bucket = id, n, b
				end
			end
		end
		if best then
			local lost = math.max(1, math.floor(bestN * rng:NextNumber(0.04, 0.12)))
			bucket[best] = bestN - lost
			if bucket == state.gpus.rented then
				spend(state, Hardware.buyPrice(Hardware.byId[best], year(state)) * 0.3 * lost, "compute")
			end
			Game.chatMsg(state, "infra", "Infra team", lost .. " " .. Hardware.byId[best].name .. " burned out during that run. " .. (bucket == state.gpus.rented and "The cloud billed us for the damage." or "They're gone."))
		end
	end
	state.stats.updates += 1
	goalProgress(state, "update", 1)
	Game.chatMsg(state, "research", "Training bot", "Training done: " .. m.name .. " " .. table.concat(gains, ", "))
	m.lastGain = table.concat(gains, "  ")
end

local function finishTraining(state)
	local t = state.training
	local ev = t.eval
	local c = t.recipe.choices
	local m = {
		id = #state.models + 1,
		name = t.name,
		cap = t.actualCap,
		predicted = ev.cap,
		size = t.recipe.size,
		abilities = ev.abilities,
		features = ev.features,
		context = ev.context,
		serve = ev.serve,
		speed = ev.speed,
		hype = ev.hype,
		flaws = ev.flaws,
		revealed = {},
		character = c.character,
		systemCard = c.evals and c.evals.card or false,
		recipe = t.recipe,
		status = "ready",
		kind = t.recipe.kind or "chat",
		users = 0,
		trainedDay = state.day,
		updates = {},
		delays = 0,
		losses = t.losses,
	}
	if c.evals then
		if c.evals.private then
			m.revealed.contam = true
			m.revealed.halluc = true
		end
		if c.evals.redteam or c.evals.external then
			m.revealed.jailbreak = true
			m.revealed.escape = true
		end
	end
	table.insert(state.models, m)
	Game.initStats(m)
	state.training = nil
	state.stats.trained += 1
	goalProgress(state, "train", 1)
	Game.chatMsg(state, "research", "Training bot", string.format("%s finished. Estimated capability %.0f (frontier is %.0f). Open Lab > Models to test it.", m.name, m.cap, state.world.frontier))
	Game.mail(state, "training", "Research team", m.name .. " is ready", "Training finished. Test it in the playground, run evals, then release it whenever you want. Or delay and keep red-teaming.")
	-- escape attempt during evals for agentic, unsafe models
	if m.flaws.escape > 0 and rng:NextNumber() < m.flaws.escape * 0.5 then
		table.insert(state.followups, { day = state.day + rng:NextInteger(1, 4), kind = "ESCAPE", modelId = m.id, prelaunch = true })
	end
end

-- Pre-launch evals reveal hidden flaws (pay for information).
local EVALS = {
	contam = { name = "Contamination audit", cost = 60e3 },
	halluc = { name = "Hallucination eval", cost = 40e3 },
	jailbreak = { name = "Red team", cost = 150e3 },
	escape = { name = "Dangerous capability eval", cost = 250e3 },
	syco = { name = "Sycophancy eval", cost = 40e3 },
}
Game.EVALS = EVALS
-- small models are cheap to evaluate, frontier models are not
function Game.evalCost(base: number, size: number, y: number): number
	return math.floor(base * math.clamp(size / 70, 0.02, 4) * (1 + (y - 2023) * 0.4) / 100) * 100
end

function Actions.runEval(state, modelId, kind)
	local m = state.models[modelId]
	local e = EVALS[kind]
	if not m or not e then
		return false, "Bad eval"
	end
	local cost = Game.evalCost(e.cost, m.size, year(state))
	if state.cash < cost then
		return false, "Not enough cash"
	end
	spend(state, cost, "compute")
	m.revealed[kind] = true
	state.stats.evals += 1
	goalProgress(state, "eval", 1)
	return true
end

-- One button: run every eval at once.
function Actions.runAllEvals(state, modelId)
	local m = state.models[modelId]
	if not m then
		return false, "No model"
	end
	local cost = 0
	for _, e in pairs(EVALS) do
		cost += Game.evalCost(e.cost, m.size, year(state))
	end
	if state.cash < cost then
		return false, "Not enough cash (" .. Format.money(cost) .. ")"
	end
	spend(state, cost, "compute")
	for k in pairs(EVALS) do
		m.revealed[k] = true
	end
	state.stats.evals += 1
	goalProgress(state, "eval", 1)
	return true
end

function Actions.delay(state, modelId)
	local m = state.models[modelId]
	if not m or m.status ~= "ready" then
		return false, "Only unreleased models can be delayed"
	end
	m.status = "delayed"
	m.delayUntil = state.day + 14
	m.delays += 1
	state.hype = math.max(0, state.hype - 4)
	local inc = Launch.incident(state, "DELAYED", m.name)
	table.insert(state.feed, 1, { kind = "incident", data = inc, day = state.day })
	if inc.chat then
		Game.chatMsg(state, "general", "Safety team", inc.chat)
	end
	return true, inc
end

function Actions.testPrompt(state, modelId)
	state.stats.chats += 1
	goalProgress(state, "chat", 1)
	return true
end

-- Launch extras scale with how big you are (a garage startup can afford teasers).
function Game.launchCosts(state)
	local scale = math.max(1, state.valuation / 5e7) ^ 0.6
	return {
		campaign = { 0, 15e3 * scale, 250e3 * scale, 4e6 * scale },
		reviewers = 10e3 * scale,
		reserve = 5e3 + state.users * 0.2,
	}
end

function Actions.release(state, modelId, opts)
	local m = state.models[modelId]
	if not m or (m.status ~= "ready") then
		return false, "Model is not ready to release"
	end
	opts = type(opts) == "table" and opts or {}
	local o = {
		price = math.clamp(tonumber(opts.price) or 10, 0.05, 500),
		open = opts.open == true,
		campaign = math.clamp(math.floor(tonumber(opts.campaign) or 0), 0, 3),
		reviewers = opts.reviewers == true,
		reserve = opts.reserve == true,
	}
	local campaignCost = Game.launchCosts(state).campaign[o.campaign + 1]
	local reviewerCost = o.reviewers and Game.launchCosts(state).reviewers or 0
	local reserveCost = o.reserve and Game.launchCosts(state).reserve or 0
	local total = campaignCost + reviewerCost + reserveCost
	if state.cash < total then
		return false, "Not enough cash for the launch plan (" .. Format.money(total) .. ")"
	end
	spend(state, total, "office")
	local result = Launch.run(state, m, o)
	m.status = "released"
	m.releasedDay = state.day
	m.open = o.open
	m.apiPrice = o.price
	m.benchmarks = result.benchmarks
	state.launches += 1
	state.stats.released += 1
	goalProgress(state, "release", 1)
	-- effects
	local eff = result.effects
	eff.signups *= Game.luck(state) ^ 0.5 * Game.eventFx().users
	if o.open then
		-- everyone can now train on your weights: rivals below you catch up a lot
		local helped = 0
		for _, lb in pairs(state.world.labBest) do
			if lb.cap < m.cap then
				lb.cap += (m.cap - lb.cap) * 0.3
				helped += 1
			end
		end
		state.world.openBoost = math.max(state.world.openBoost or 0, math.max(0, m.cap - state.world.frontier) * 0.5 + 2)
		state.openRep = (state.openRep or 0) + 5
		if helped > 0 then
			Game.newsItem(state, helped .. " rival labs are already training on " .. m.name .. "'s open weights", "rival")
		end
	end
	if state.trendyNext then
		state.trendyNext = nil
		eff.signups *= 3
		eff.hype = (eff.hype or 0) + 30
		eff.brand = (eff.brand or 0) + 0.02
		Game.newsItem(state, m.name .. " is trending number one worldwide", "you")
	end
	if (m.kind or "chat") ~= "chat" then
		eff.signups = 0
		Game.chatMsg(state, "general", "Sales", m.name .. " is live as its own product. It earns money every day by itself.")
	end
	state.users = math.min(state.users + eff.signups, state.world.marketUsers * 1e6 * Config.MAX_MARKET_SHARE)
	state.brand = math.max(0.005, state.brand + eff.brand)
	state.hype = math.clamp(state.hype + eff.hype, 0, 100)
	state.reputation = math.clamp(state.reputation + eff.reputation, 0, 100)
	state.regulator = math.clamp(state.regulator + eff.regulator, 0, 100)
	state.openRep += eff.openRep
	goalProgress(state, "users", eff.signups)
	-- auto-set as the app model if it is your best
	local best = Game.bestModel(state)
	if best == m then
		state.product.activeModel = m.id
		state.product.apiPrice = o.price
	end
	for _, f in ipairs(result.followups) do
		f.modelId = m.id
		table.insert(state.followups, f)
	end
	table.insert(state.feed, 1, { kind = "launch", data = result, day = state.day })
	while #state.feed > 25 do
		table.remove(state.feed)
	end
	Game.newsItem(state, state.company .. " releases " .. m.name .. ". Reception " .. result.score .. "/100", "you")
	return true, result
end

function Actions.update(state, modelId, updateId)
	local m = state.models[modelId]
	local up
	for _, u in ipairs(Catalog.updates) do
		if u.id == updateId then
			up = u
		end
	end
	if not m or not up or m.status ~= "released" then
		return false, "Pick a released model"
	end
	if m.updating then
		return false, "Already updating"
	end
	if up.req and not state.research.done[up.req] then
		return false, "Research " .. Research.byId[up.req].name .. " first"
	end
	if up.feature and m.features[up.feature] then
		return false, "Already has it"
	end
	local cost = up.cost or 0
	if up.costMult then
		local ev = TM.evaluate(m.recipe, Game.trainCtx(state))
		cost = ev.extraCost + 2e5 * (1 + m.size / 50)
		cost *= up.costMult
	end
	cost *= (1 + (year(state) - 2023) * 0.3)
	if state.cash < cost then
		return false, "Not enough cash (" .. Format.money(cost) .. ")"
	end
	spend(state, cost, "compute")
	m.updating = { id = up.id, doneDay = state.day + up.days }
	Game.chatMsg(state, "research", "Research team", "Started " .. up.name .. " on " .. m.name .. ". ETA " .. up.days .. " days.")
	return true
end

local function finishUpdate(state, m)
	local up
	for _, u in ipairs(Catalog.updates) do
		if u.id == m.updating.id then
			up = u
		end
	end
	m.updating = nil
	if not up then
		return
	end
	if up.cap then
		m.cap += up.cap * rng:NextNumber(0.7, 1.3)
	end
	if up.feature then
		m.features[up.feature] = true
		if up.feature == "vision" then
			m.abilities.vision = math.max(m.abilities.vision or 0, 20)
		end
		if up.feature == "reasoning" then
			m.abilities.math = (m.abilities.math or 0) + 6
			m.abilities.reasoning = (m.abilities.reasoning or 0) + 5
		end
		if up.feature == "agents" or up.feature == "computer" then
			m.abilities.agents = (m.abilities.agents or 0) + 10
		end
	end
	if up.context then
		m.context = up.context
	end
	if up.safety then
		m.flaws.safety += up.safety
		m.flaws.jailbreak = math.max(0.05, m.flaws.jailbreak - 0.25)
		m.flaws.refuse += 0.05
		m.flaws.escape *= 0.5
	end
	if up.syco then
		m.flaws.syco = math.max(0, m.flaws.syco + up.syco)
	end
	if up.refuse then
		m.flaws.refuse = math.max(0, m.flaws.refuse + up.refuse)
	end
	if up.serve then
		m.serve *= up.serve
	end
	if up.escape then
		m.flaws.escape += up.escape
	end
	if up.hype then
		state.hype = math.min(100, state.hype + up.hype)
	end
	if up.spawnMini then
		local mini = table.clone(m)
		mini.id = #state.models + 1
		mini.name = m.name .. " Mini"
		mini.cap = m.cap - 7
		mini.serve = m.serve * 0.2
		mini.size = math.max(3, math.floor(m.size / 8))
		mini.status = "ready"
		mini.updates = {}
		mini.flaws = table.clone(m.flaws)
		mini.abilities = table.clone(m.abilities)
		mini.features = table.clone(m.features)
		mini.revealed = table.clone(m.revealed)
		table.insert(state.models, mini)
	end
	table.insert(m.updates, up.name)
	state.stats.updates += 1
	goalProgress(state, "update", 1)
	Game.chatMsg(state, "research", "Research team", up.name .. " shipped for " .. m.name .. ".")
	Game.newsItem(state, state.company .. " ships " .. up.name:lower() .. " for " .. m.name, "you")
end

function Actions.setPrices(state, sub, api, pro)
	state.product.subPrice = math.clamp(tonumber(sub) or 20, 0, 500)
	state.product.apiPrice = math.clamp(tonumber(api) or 10, 0.05, 500)
	state.product.proPrice = math.clamp(tonumber(pro) or 0, 0, 2000)
	return true
end

function Actions.resetLimits(state)
	if state.day < (state.resetReady or 0) then
		return false, "You can do this again on " .. Format.date(state.resetReady)
	end
	if state.users < 100 then
		return false, "You need users first"
	end
	-- it only lands after a big moment: a fresh model launch or a crisis you want people to forget
	local live = state.product.activeModel and state.models[state.product.activeModel]
	local launch = live and live.releasedDay and state.day - live.releasedDay <= 14
	local crisis = state.lastCrisisDay and state.day - state.lastCrisisDay <= 14
	if not launch and not crisis then
		return false, "Nobody would notice right now. Reset limits right after a new model launches or after something bad happens."
	end
	local cost = math.floor(state.users * 0.4 + 5000)
	if state.cash < cost then
		return false, "Serving everyone for free costs " .. Format.money(cost)
	end
	spend(state, cost, "inference")
	state.resetReady = state.day + 30
	if launch then
		-- everyone floods in to try the new model, and more people rate it
		state.users = math.min(state.users * 1.15 + 1000, state.world.marketUsers * 1e6 * Config.MAX_MARKET_SHARE)
		state.hype = math.min(100, state.hype + 12)
		live.users = (live.users or 0) * 1.15
		live.extraRatings = (live.extraRatings or 0) + 1
	else
		-- after a disaster it buys back trust
		state.users = math.min(state.users * 1.04 + 300, state.world.marketUsers * 1e6 * Config.MAX_MARKET_SHARE)
		state.reputation = math.min(100, state.reputation + 8)
		state.hype = math.min(100, state.hype + 4)
	end
	local LOVE = launch and { "limits reset the same week " .. (live and live.name or "the new model") .. " dropped?? testing it all night", "ok I tried the new model 40 times thanks to the reset. it's good", "THEY RESET THE LIMITS. best company ever" } or { "ok " .. state.company .. " just won me back", "after that mess, a free reset is the least they could do. still, thanks", "free usage reset?? fine I forgive you " .. state.company }
	Game.chatMsg(state, "dms", "Users", LOVE[rng:NextInteger(1, #LOVE)])
	Game.newsItem(state, state.company .. " resets usage limits for everyone. Users celebrate.", "you")
	return true
end

function Actions.setActive(state, modelId)
	local m = state.models[modelId]
	if m and m.status == "banned" then
		return false, "This model is suspended by the government"
	end
	if not m or m.status ~= "released" then
		return false, "Release it first"
	end
	if (m.kind or "chat") ~= "chat" then
		return false, "Only chat models go in the app. This one earns by itself."
	end
	state.product.activeModel = modelId
	return true
end

function Actions.renameApp(state, name)
	name = tostring(name or ""):sub(1, 24)
	if #name >= 2 then
		state.product.appName = name
	end
	return true
end

function Actions.investor(state, idx, accept)
	local inv = state.investors[idx]
	if not inv then
		return false, "Offer expired"
	end
	table.remove(state.investors, idx)
	if accept then
		if perk(state, "vip") then
			inv.amount *= 1.5
		end
		state.cash += inv.amount
		state.equity *= (1 - inv.stake)
		state.valuation = inv.post
		Game.newsItem(state, string.format("%s raises %s from %s at a %s valuation", state.company, Format.money(inv.amount), inv.name, Format.money(inv.post)), "you")
		Game.chatMsg(state, "general", "Finance", "Round closed. " .. Format.money(inv.amount) .. " in the bank.")
	end
	return true
end

function Game.loanLimit(state): number
	local owed = 0
	for _, l in ipairs(state.loans) do
		owed += l.left
	end
	local arr = (state.lastMonth and state.lastMonth.revenue or 0) * 12
	return math.max(0, Config.LOAN_BASE_LIMIT + arr * 0.6 + state.valuation * 0.08 - owed)
end

-- Yearly rate the bank opens with. Small loans are cheap, borrowing near your limit is brutal.
function Game.loanRate(state, amount): number
	local owed = 0
	for _, l in ipairs(state.loans) do
		owed += l.left
	end
	local limit = math.max(Game.loanLimit(state) + owed, 1)
	local share = math.clamp((amount + owed) / limit, 0, 1)
	local risk = state.users < 1000 and 0.04 or 0
	return 0.07 + risk + 0.23 * share ^ 1.6
end

local BANKERS = { "Daniel Ross", "Maya Levin", "Omar Haddad", "Grace Kim", "Lukas Brandt", "Sofia Marino", "Ethan Cole", "Noa Shapira" }
local BANKS = { "First Pacific Bank", "Ironbridge Bank", "Harbor Credit", "Summit Lending", "Crown Trust" }

-- ---------- meetings: sit across the desk and negotiate ----------
local function growthOf(state): number
	local h = state.history
	if #h >= 4 and (h[#h - 3].revenue or 0) > 0 then
		return math.clamp((h[#h].revenue or 0) / h[#h - 3].revenue - 1, -1, 3)
	end
	return -0.2
end

local function bestPower(state): number
	local best = 0
	for _, m in ipairs(state.models) do
		if m.status == "released" and m.stats then
			best = math.max(best, avgStat(m))
		end
	end
	return best / math.max(state.world.frontier, 1)
end

local function say(mt, lines)
	mt.line = lines[rng:NextInteger(1, #lines)]
end

function Actions.meetLoan(state, amount)
	if state.meeting then
		return false, "You are already in a meeting"
	end
	amount = math.floor(tonumber(amount) or 0)
	if amount < 1000 then
		return false, "Ask for at least $1K"
	end
	local limit = Game.loanLimit(state)
	if amount > limit * 1.5 then
		return false, "No bank will even meet you for that. Your limit is about " .. Format.money(limit) .. "."
	end
	-- above the limit they only offer part of it at first
	local offered = amount > limit and math.floor(limit * rng:NextNumber(0.6, 0.85)) or amount
	local rate = Game.loanRate(state, offered) * (amount > limit and 1.15 or 1)
	state.meeting = {
		kind = "loan", who = BANKERS[rng:NextInteger(1, #BANKERS)], firm = BANKS[rng:NextInteger(1, #BANKS)],
		asked = amount, amount = offered, rate = rate, months = Config.LOAN_MONTHS,
		mood = amount > limit and 2 or 3, moves = 4, used = {}, seed = rng:NextInteger(1, 1e6),
	}
	local mt = state.meeting
	if offered < amount then
		mt.line = string.format("%s? That is a lot. I can lend %s at %.1f%% a year. Convince me.", Format.money(amount), Format.money(offered), rate * 100)
	else
		mt.line = string.format("I can lend you %s at %.1f%% a year, paid back over 2 years.", Format.money(offered), rate * 100)
	end
	return true
end

function Actions.meetInvestor(state, idx)
	if state.meeting then
		return false, "You are already in a meeting"
	end
	local inv = state.investors[idx]
	if not inv then
		return false, "Offer expired"
	end
	table.remove(state.investors, idx)
	state.meeting = {
		kind = "invest", who = inv.person or BANKERS[rng:NextInteger(1, #BANKERS)], firm = inv.name, stage = inv.kind,
		amount = inv.amount, stake = inv.stake, pre = inv.pre,
		mood = 3, moves = 4, used = {}, seed = rng:NextInteger(1, 1e6),
	}
	state.meeting.line = string.format("So, %s. I can do %s for %.0f%%. Convince me to do better.", state.company, Format.money(inv.amount), inv.stake * 100)
	return true
end

-- a move: earnings / demo / more / less / others
function Actions.meetMove(state, move)
	local mt = state.meeting
	if not mt then
		return false, "No meeting"
	end
	if mt.moves <= 0 then
		return false, "No moves left. Take it or leave."
	end
	if (move == "earnings" or move == "demo" or move == "others") and mt.used[move] then
		return false, "You already did that"
	end
	mt.used[move] = true
	mt.moves -= 1
	local loan = mt.kind == "loan"
	local function better(f)
		if loan then
			mt.rate = math.max(0.045, mt.rate * (1 - f))
			if mt.asked and mt.amount < mt.asked then
				mt.amount = math.min(mt.asked, math.floor(mt.amount * (1 + f)))
			end
		else
			mt.stake = math.max(0.01, mt.stake * (1 - f))
		end
	end
	local function worse(f)
		if loan then
			mt.rate = math.min(0.45, mt.rate * (1 + f))
		else
			mt.stake = math.min(0.6, mt.stake * (1 + f))
		end
	end
	if move == "earnings" then
		local g = growthOf(state)
		if g > 0.15 then
			mt.mood = math.min(5, mt.mood + 1)
			better(0.06 + g * 0.05)
			say(mt, { "Revenue up " .. math.floor(g * 100) .. "% in three months? Okay, I'm listening.", "Those numbers are real? Nice." })
		elseif g > -0.05 then
			say(mt, { "Flat. Not bad, not great.", "Hm. Steady, I guess." })
		else
			mt.mood -= 1
			worse(0.05)
			say(mt, { "You are shrinking. That makes this riskier for me.", "I'd rather not have seen that." })
		end
	elseif move == "demo" then
		local pw = bestPower(state)
		local crash = rng:NextNumber() < (state.speed >= 4 and 0.3 or 0.15)
		if pw <= 0 then
			mt.mood -= 1
			say(mt, { "There is nothing to demo? Really?", "You don't even have a live model." })
		elseif crash then
			mt.mood -= 2
			worse(0.06)
			say(mt, { "It just said something very weird. Awkward.", "The demo crashed. In front of me." })
		elseif pw > 0.85 then
			mt.mood = math.min(5, mt.mood + 2)
			better(0.12)
			say(mt, { "Wait. That is almost as good as the best labs. Wow.", "Okay. That's impressive. Really." })
		else
			mt.mood = math.min(5, mt.mood + 1)
			better(0.04)
			say(mt, { "It works. Not the best I've seen.", "Decent. A bit behind the leaders." })
		end
	elseif move == "more" then
		local chance = 0.15 + mt.mood * 0.12
		if rng:NextNumber() < chance then
			if loan then
				mt.amount = math.floor(mt.amount * 1.2)
				mt.asked = math.max(mt.asked or 0, mt.amount)
				mt.rate *= 1.05
			else
				mt.amount = math.floor(mt.amount * 1.2)
				mt.stake *= 1.1
			end
			say(mt, { "Fine. More money. But I want something for it.", "You push hard. Okay, a bit more." })
		else
			mt.mood -= 2
			say(mt, { "No. Don't get greedy.", "That's not happening." })
		end
	elseif move == "less" then
		local chance = 0.1 + mt.mood * 0.11
		if rng:NextNumber() < chance then
			better(0.12)
			say(mt, loan and { "Fine, a lower rate. Don't tell my boss." } or { "Smaller stake? Fine. You are worth it." })
		else
			mt.mood -= 1
			say(mt, { "You are wasting my time.", "Those are already good terms." })
		end
	elseif move == "others" then
		local real = (#state.investors > 0) or state.users > 2e5
		if real or rng:NextNumber() < 0.3 then
			mt.mood = math.min(5, mt.mood + 1)
			better(0.15)
			say(mt, { "Others? Then let's not lose this. Better terms.", "Okay, okay. I'll beat them." })
		else
			mt.mood -= 2
			say(mt, { "Nobody else is calling you. I checked.", "Really? Name one." })
		end
	else
		return false, "Unknown move"
	end
	if mt.mood <= 0 then
		state.meeting = nil
		Game.chatMsg(state, "general", "Finance", mt.who .. " from " .. mt.firm .. " walked out of the meeting.")
		return true, "walked"
	end
	return true
end

function Actions.meetAccept(state)
	local mt = state.meeting
	if not mt then
		return false, "No meeting"
	end
	state.meeting = nil
	if mt.kind == "loan" then
		local r = mt.rate / 12
		local n = mt.months
		local payment = mt.amount * r / (1 - (1 + r) ^ -n)
		table.insert(state.loans, { amount = mt.amount, left = mt.amount, payment = payment, months = n, rate = mt.rate, bank = mt.firm })
		state.cash += mt.amount
		Game.chatMsg(state, "general", "Finance", string.format("Loan of %s from %s at %.1f%% a year.", Format.money(mt.amount), mt.firm, mt.rate * 100))
	else
		local post = mt.amount / mt.stake
		if perk(state, "vip") then
			mt.amount *= 1.5
		end
		state.cash += mt.amount
		state.equity *= (1 - mt.stake)
		state.valuation = math.max(state.valuation, post)
		Game.newsItem(state, string.format("%s raises %s from %s at a %s valuation", state.company, Format.money(mt.amount), mt.firm, Format.money(post)), "you")
		Game.chatMsg(state, "general", "Finance", "Round closed. " .. Format.money(mt.amount) .. " in the bank.")
	end
	return true
end

function Actions.meetLeave(state)
	state.meeting = nil
	return true
end

function Actions.takeLoan(state, amount)
	amount = math.floor(tonumber(amount) or 0)
	if amount <= 0 then
		return false, "Pick an amount"
	end
	if amount > Game.loanLimit(state) then
		return false, "The bank says no. Your limit is " .. Format.money(Game.loanLimit(state))
	end
	local monthlyRate = Game.loanRate(state, amount) / 12
	local n = Config.LOAN_MONTHS
	local payment = amount * monthlyRate / (1 - (1 + monthlyRate) ^ -n)
	table.insert(state.loans, { amount = amount, left = amount, payment = payment, months = n })
	state.cash += amount
	return true
end

function Actions.repayLoan(state, i)
	local l = state.loans[i]
	if not l then
		return false, "No such loan"
	end
	if state.cash < l.left then
		return false, "Not enough cash"
	end
	state.cash -= l.left
	table.remove(state.loans, i)
	return true
end

-- Buy a rival lab: pay cash, or pay part in your own stock.
function Game.acquireCost(state, labId)
	return Labs.valuation(labId, year(state)) * 1.35
end

local BIG_TECH = { google = true, meta = true, microsoft = true, amazon = true, nvidia = true, tencent = true, bytedance = true, baidu = true, qwen = true }

-- Make an offer. They think about it for a few weeks; big deals also need regulators.
-- premium: 1.2 (lowball), 1.5 (fair), 2.0 (huge)
function Actions.acquire(state, labId, withStock, premium)
	local lab = Labs.byId[labId]
	state.acquired = state.acquired or {}
	state.offers = state.offers or {}
	if not lab or state.acquired[labId] then
		return false, "Not for sale"
	end
	for _, o in ipairs(state.offers) do
		if o.lab == labId then
			return false, "You already made them an offer. Wait for their answer."
		end
	end
	if (state.cooldowns or {})[labId] and state.day < state.cooldowns[labId] then
		return false, Labs.displayName(labId) .. " won't talk to you again until " .. Format.date(state.cooldowns[labId])
	end
	premium = math.clamp(tonumber(premium) or 1.5, 1.1, 3)
	local worth = Labs.valuation(labId, year(state))
	local price = worth * premium
	if BIG_TECH[labId] and state.valuation < worth * 5 then
		return false, Labs.displayName(labId) .. " is part of a giant company. You need to be worth " .. Format.money(worth * 5) .. " to even ask."
	end
	if state.valuation < price * 0.8 then
		return false, "They won't take a meeting. You need to be worth at least " .. Format.money(price * 0.8) .. "."
	end
	if not withStock and state.cash < price then
		return false, "Not enough cash for " .. Format.money(price) .. ". Try paying with stock."
	end
	table.insert(state.offers, { lab = labId, price = price, premium = premium, stock = withStock == true, day = state.day, answerDay = state.day + rng:NextInteger(10, 25) })
	Game.chatMsg(state, "general", "Deals team", "Offer sent to " .. Labs.displayName(labId) .. " for " .. Format.money(price) .. ". They will answer in a few weeks.")
	return true
end

-- Decide pending offers.
function Game.tickOffers(state)
	state.offers = state.offers or {}
	for i = #state.offers, 1, -1 do
		local o = state.offers[i]
		if state.day >= o.answerDay then
			table.remove(state.offers, i)
			local lab = Labs.byId[o.lab]
			local best = state.world.labBest[o.lab]
			-- doing well = less willing to sell; a fat premium helps a lot
			local strength = best and math.clamp((best.cap - state.world.frontier + 15) / 15, 0, 1.5) or 0.3
			-- the bigger they are, the less they want to be bought
			local size = math.max(0, math.log10(math.max(o.price / o.premium, 1e8) / 1e8)) -- 0 at $100M, 3 at $100B
			local chance = math.clamp(0.15 + (o.premium - 1) * 0.7 - strength * 0.25 - size * 0.1 - (BIG_TECH[o.lab] and 0.25 or 0) + (o.stock and -0.1 or 0.05), 0.02, 0.85)
			local blocked = o.price > 5e10 and rng:NextNumber() < math.clamp(0.25 + state.regulator / 200 + (o.price / 1e12), 0, 0.85)
			state.cooldowns = state.cooldowns or {}
			if rng:NextNumber() > chance then
				state.cooldowns[o.lab] = state.day + 90
				Game.mail(state, "deal", Labs.displayName(o.lab), "Thanks, but no", "We are flattered, but " .. Labs.displayName(o.lab) .. " is not for sale at " .. Format.money(o.price) .. ".")
			elseif blocked then
				state.cooldowns[o.lab] = state.day + 180
				Game.mail(state, "deal", "Competition regulator", "Deal blocked", "We are blocking your purchase of " .. Labs.displayName(o.lab) .. ". It would give you too much power over AI.")
				Game.newsItem(state, "Regulators block " .. state.company .. "'s takeover of " .. Labs.displayName(o.lab), "press")
			elseif (not o.stock) and state.cash < o.price then
				Game.mail(state, "deal", Labs.displayName(o.lab), "Deal fell through", "They said yes, but you did not have the cash anymore.")
			else
				Game.completeAcquire(state, o.lab, o.stock, o.price)
			end
		end
	end
end

function Game.completeAcquire(state, labId, withStock, cost)
	local lab = Labs.byId[labId]
	if withStock then
		local dilution = cost / (state.valuation + cost)
		state.equity *= (1 - dilution)
	else
		if state.cash < cost then
			return false, "Not enough cash. Try paying with stock."
		end
		spend(state, cost, "office")
	end
	state.acquired = state.acquired or {}
	state.acquired[labId] = true
	state.world.labBest[labId] = nil
	-- you inherit their brand, people and their best model
	state.brand += lab.brand * 0.25
	state.staff.senior = (state.staff.senior or 0) + math.floor(10 + lab.brand * 20)
	state.staff.star = (state.staff.star or 0) + math.max(1, math.floor(lab.brand))
	local best
	for _, r in ipairs(state.world.released) do
		if r.lab == labId and (not best or r.cap > best.cap) then
			best = r
		end
	end
	if best then
		local abil = {}
		for _, d in ipairs(TM.DOMAINS) do
			abil[d] = 2
		end
		table.insert(state.models, {
			id = #state.models + 1, name = best.model .. " (acquired)", cap = best.cap, predicted = best.cap, size = 400,
			abilities = abil, features = { tools = true }, context = 128e3, serve = 1, speed = 1, hype = 0,
			flaws = { safety = 30, halluc = 0.15, syco = 0.15, refuse = 0.15, contam = 0.1, legal = 0, jailbreak = 0.4, escape = 0 },
			revealed = {}, character = "pro", systemCard = true, recipe = Opts.defaultRecipe(), status = "released",
			users = 0, trainedDay = state.day, releasedDay = state.day, updates = {}, delays = 0, losses = {},
		})
	end
	-- remove them from the world
	for i = #state.world.released, 1, -1 do
		if state.world.released[i].lab == labId then
			table.remove(state.world.released, i)
		end
	end
	state.world.frontier = 0
	for _, r in ipairs(state.world.released) do
		state.world.frontier = math.max(state.world.frontier, r.cap)
	end
	state.hype = math.min(100, state.hype + 15)
	Game.newsItem(state, string.format("%s acquires %s for %s", state.company, Labs.displayName(labId), Format.money(cost)), "you")
	Game.chatMsg(state, "general", "CEO of " .. Labs.displayName(labId), "Excited to join the family. Our people start Monday.")
	return true
end

function Actions.claimGoal(state, i)
	local g = state.goals[i]
	if not g or g.claimed or g.progress < g.target then
		return false, "Not done yet"
	end
	g.claimed = true
	state.cash += g.reward
	return true
end

function Actions.upgradeOffice(state)
	local nextStage = Catalog.officeStages[state.office + 1]
	if not nextStage then
		return false, "You already own the biggest campus"
	end
	if state.cash < nextStage.cost then
		return false, "Need " .. Format.money(nextStage.cost)
	end
	spend(state, nextStage.cost, "office")
	state.office += 1
	Game.newsItem(state, state.company .. " moves into a new " .. nextStage.name:lower(), "you")
	return true
end

function Actions.mailChoice(state, mailId, choice)
	for _, m in ipairs(state.mail) do
		if m.id == mailId and m.choices and not m.resolved then
			local c = m.choices[choice]
			if not c then
				return false, "Bad choice"
			end
			m.resolved = c.label
			Game.applyChoice(state, m, c)
			return true
		end
	end
	return false, "Already handled"
end

function Actions.markRead(state, mailId)
	for _, m in ipairs(state.mail) do
		if m.id == mailId then
			m.read = true
		end
	end
	return true
end

-- ===== tap to speed up training =====
-- Each tap takes a little time off whatever is training. After 40 taps the button turns
-- into the Robux instant finish. Taps are rate limited on the server.
local lastTap: { [any]: number } = {}
Game.TAPS_FOR_FINISH = 40
function Actions.trainTap(state)
	local now = os.clock()
	if lastTap[state] and now - lastTap[state] < 0.09 then
		return false
	end
	lastTap[state] = now
	local key
	if state.training then
		key = "t" .. state.training.name
		state.training.progress = math.min(0.999, state.training.progress + 0.004)
	else
		for _, m in ipairs(state.models) do
			if m.boosting then
				key = "b" .. m.id .. "_" .. m.boosting.startDay
				m.boosting.tapCredit = (m.boosting.tapCredit or 0) + 0.004 * math.max(1, m.boosting.doneDay - m.boosting.startDay)
				if m.boosting.tapCredit >= 1 and m.boosting.doneDay > state.day + 1 then
					m.boosting.tapCredit -= 1
					m.boosting.doneDay -= 1
				end
				break
			end
		end
	end
	if not key then
		return false, "Nothing is training"
	end
	if state.tapKey ~= key then
		state.tapKey = key
		state.taps = 0
	end
	state.taps = (state.taps or 0) + 1
	return true, state.taps
end

-- ===== gifts =====
-- Gift size grows with the company (recent revenue + a bit of valuation), never tiny.
function Game.giftBase(state): number
	local rev = state.lastMonth and state.lastMonth.revenue or 0
	return math.max(3000, rev * 0.08 + math.max(state.valuation, 0) * 0.0004 + math.max(state.cash, 0) * 0.002)
end

-- ===== website =====
function Game.websiteBonus(state)
	return Website.bonus(state.website)
end

function Actions.buildSite(state, partId)
	local p = Website.byId[partId]
	if not p then
		return false, "Unknown page"
	end
	state.website = state.website or { parts = {}, theme = "cyan" }
	if state.website.parts[partId] then
		return false, "Already built"
	end
	if state.cash < p.cost then
		return false, "Costs " .. Format.money(p.cost)
	end
	spend(state, p.cost, "office")
	state.website.parts[partId] = true
	Game.chatMsg(state, "general", "Web team", p.name .. " is live on the website.")
	return true
end

function Actions.siteTheme(state, themeId)
	if not Website.themeById[themeId] then
		return false, "Unknown colour"
	end
	state.website = state.website or { parts = {}, theme = "cyan" }
	state.website.theme = themeId
	return true
end

-- ===== other AI products =====
-- Your best launched model of every non-chat kind earns a little every day.
function Game.sideIncome(state)
	local best = {}
	for _, m in ipairs(state.models) do
		local k = m.kind or "chat"
		if k ~= "chat" and m.status == "released" and m.stats then
			if not best[k] or avgStat(m) > avgStat(best[k]) then
				best[k] = m
			end
		end
	end
	local out = { total = 0, byKind = {} }
	local F = math.max(state.world.frontier, 1)
	for k, m in pairs(best) do
		local v = MT.dailyIncome(MT.get(k), avgStat(m) / F, year(state), Config.DIFFICULTY)
		out.byKind[k] = { model = m.name, day = v }
		out.total += v
	end
	return out
end

-- ===== Robux products (granted by the server's receipt handler only) =====
function Game.grantProduct(state, key: string, modelId: number?)
	local p = Shop.productByKey[key]
	if not p then
		return false, "Unknown product"
	end
	local y = year(state)
	if p.cash then
		local amount = Shop.cashFor(p, y)
		state.cash += amount
		Game.chatMsg(state, "general", "Finance", "Robux deal: " .. Format.money(amount) .. " just landed in the bank.")
	elseif key == "finish" then
		if state.training then
			state.training.progress = 1
			finishTraining(state)
		end
		for _, m in ipairs(state.models) do
			if m.boosting then
				finishBoost(state, m)
			end
		end
		Game.chatMsg(state, "research", "Training bot", "Overclocked everything. All training finishes today.")
	elseif key == "stats10" then
		local m = modelId and state.models[modelId]
		if not m or not m.stats then
			m = state.product.activeModel and state.models[state.product.activeModel] or state.models[#state.models]
		end
		if not m or not m.stats then
			return false, "No model to boost"
		end
		for k, v in pairs(m.stats) do
			m.stats[k] = v + 10
		end
		Game.applyStats(m)
		m.lastGain = "+10 ALL (SUPER BOOST)"
		Game.chatMsg(state, "research", "Training bot", m.name .. " got a SUPER BOOST. +10 to every stat.")
	elseif key == "fixall" then
		state.problems = {}
		state.misuse = 0
		state.calmUntil = state.day + 90
		Game.chatMsg(state, "general", "Ops", "Every fire is out. Nothing can break for 90 days.")
	elseif key == "gpudrop" then
		local best
		for _, h in ipairs(Hardware.list) do
			if h.id ~= "laptop" and Hardware.available(h, state.day) and (not best or h.power > best.power) then
				best = h
			end
		end
		if not best then
			return false, "No GPUs on the market yet"
		end
		local n = math.max(8, math.floor(Config.yearValue(Config.GPU_ALLOCATION, y) * 0.15 / best.power))
		state.boxes = state.boxes or {}
		table.insert(state.boxes, { kind = "buy", id = best.id, n = n })
		Game.chatMsg(state, "infra", "Infra team", "A truck just dropped " .. n .. " " .. best.name .. " at the door. Open the boxes!")
	elseif key == "legendhire" then
		local place = Staff.placeById.elite
		state.search = Game.rollCandidates(state, place, 5, nil, 4)
		for _, c in ipairs(state.search) do
			c.demand = 0
		end
		state.searchPlace = "elite"
		Game.chatMsg(state, "general", "Recruiting", "The Elite Agency sent 4 LEGENDARY people who want to join. Open Team > Hire.")
	elseif p.gpuTier then
		-- GPU packs: tier 1 = cheapest card this year, 3 = the best one, more of them each tier
		local avail = {}
		for _, h in ipairs(Hardware.list) do
			if h.id ~= "laptop" and Hardware.available(h, state.day) then
				table.insert(avail, h)
			end
		end
		table.sort(avail, function(a, b)
			return a.power < b.power
		end)
		if #avail == 0 then
			return false, "No GPUs on the market yet"
		end
		local idx = p.gpuTier == 1 and 1 or (p.gpuTier == 2 and math.max(1, math.ceil(#avail / 2)) or #avail)
		local h = avail[idx]
		local share = ({ 0.05, 0.2, 0.6 })[p.gpuTier]
		local n = math.max(({ 4, 16, 64 })[p.gpuTier], math.floor(Config.yearValue(Config.GPU_ALLOCATION, y) * share / h.power))
		state.boxes = state.boxes or {}
		table.insert(state.boxes, { kind = "buy", id = h.id, n = n })
		-- the pack comes with the space and power it needs
		state.bonusSlots = (state.bonusSlots or 0) + n
		state.bonusKw = (state.bonusKw or 0) + n * h.kw * 1.5
		Game.chatMsg(state, "infra", "Infra team", p.name .. " delivered: " .. Format.count(n) .. " " .. h.name .. ", with room and power for all of them. Open the boxes!")
	elseif key == "trendy" then
		state.trendyNext = true
		Game.chatMsg(state, "general", "Marketing", "Influencers are booked. Your next launch will trend everywhere.")
	elseif key == "turbo" then
		state.turboUntil = math.max(state.turboUntil or 0, state.day) + 60
		Game.chatMsg(state, "research", "Training bot", "TURBO mode on: every training runs 3x faster for 60 days.")
	elseif key == "mega" then
		local m = modelId and state.models[modelId]
		if not m or not m.stats then
			m = state.product.activeModel and state.models[state.product.activeModel] or state.models[#state.models]
		end
		if not m or not m.stats then
			return false, "No model to boost"
		end
		for k, v in pairs(m.stats) do
			m.stats[k] = v + 30
		end
		Game.applyStats(m)
		m.lastGain = "+30 ALL (MEGA BOOST)"
		Game.chatMsg(state, "research", "Training bot", m.name .. " got a MEGA BOOST. +30 to every stat.")
	elseif key == "unlockkind" then
		local nextKind
		for _, k in ipairs(MT.list) do
			if not MT.unlocked(k, state.day) and not (state.earlyKinds and state.earlyKinds[k.id]) then
				nextKind = k
				break
			end
		end
		if not nextKind then
			return false, "Every model type is already unlocked"
		end
		state.earlyKinds = state.earlyKinds or {}
		state.earlyKinds[nextKind.id] = true
		Game.chatMsg(state, "research", "Research team", "Early access: we can build " .. nextKind.name .. " models now, years before everyone else.")
	elseif key == "stars" then
		local before, mCosts, mSal = state.cash, state.month.costs, state.month.salaries
		state.cash = math.huge
		local stage = Catalog.officeStages[state.office]
		local room = math.max(0, stage.maxStaff - Game.headcount(state))
		local n = math.min(5, room)
		if n > 0 then
			Actions.hire(state, "star", n)
		end
		state.cash, state.month.costs, state.month.salaries = before, mCosts, mSal
		if n < 5 then
			-- no desks left: the rest become a cash bonus instead of being lost
			state.cash += (5 - n) * Staff.monthlyCash("star", y) * 3
		end
		Game.chatMsg(state, "general", "Recruiting", n .. " star researchers signed today" .. (n < 5 and ". The office is full, so the rest paid you a finder's bonus." or "."))
	elseif key == "viral" then
		local cap = state.world.marketUsers * 1e6 * Config.MAX_MARKET_SHARE
		state.users = math.min(cap, state.users * 1.4 + 5000)
		state.hype = math.min(100, state.hype + 40)
		state.brand += 0.03
		Game.newsItem(state, state.product.appName .. " is the most downloaded app in the world today", "you")
	end
	state.stats.robux = (state.stats.robux or 0) + 1
	return true
end

-- ===== live problems the team fixes by itself =====
Game.PROBLEMS = {
	outage = { label = "SERVERS DOWN", fixer = "infra", need = 6, msg = { "Servers are down! Infra team is on it.", "Everything is on fire. Rebooting clusters now." }, done = "Servers are back up." },
	hack = { label = "WE GOT HACKED", fixer = "safety", need = 8, msg = { "Someone broke into our API keys. Locking everything down.", "Security breach! Rotating every key we have." }, done = "Breach contained. Keys rotated." },
	jailbreak = { label = "MODEL JAILBROKEN", fixer = "safety", need = 5, msg = { "People found a way to make our model say anything. Patching the filters.", "A jailbreak prompt is going viral. Safety team is on it." }, done = "Jailbreak patched. For now." },
	bug = { label = "MODEL BUG", fixer = "research", need = 4, msg = { "Our model started answering everything in French. Looking into it.", "The model forgets what you said after 3 messages. Rolling back a layer.", "It thinks every year is 2019. Fixing the date bug.", "It keeps saying As an AI 40 times per answer. On it." }, done = "Bug fixed and shipped." },
	exploit = { label = "PROMPT INJECTION", fixer = "safety", need = 6, msg = { "Someone tricked our agent into leaking other users chats. Shutting that tool down.", "Hidden text on websites is hijacking our model. Building a filter." }, done = "Exploit closed. Writing a postmortem." },
	massive = { label = "MASSIVE JAILBREAK", fixer = "safety", need = 16, msg = { "This is bad. A jailbreak is everywhere and people are using our model for scams. All hands on deck.", "Code red. Our model is being abused at scale. Safety team is pulling all-nighters." }, done = "We finally shut the massive jailbreak down. Everyone go home and sleep." },
	overheat = { label = "GPUS OVERHEATING", fixer = "infra", need = 4, msg = { "GPUs are cooking. Throttling them so they don't melt.", "Server room is 45C. Training slowed down." }, done = "GPUs cooled down. Full speed again." },
}

function Game.startProblem(state, kind)
	state.problems = state.problems or {}
	state.lastCrisisDay = state.day
	for _, p in ipairs(state.problems) do
		if p.kind == kind then
			return
		end
	end
	local def = Game.PROBLEMS[kind]
	table.insert(state.problems, { kind = kind, progress = 0 })
	local names = { infra = "Infra team", safety = "Security team", research = "Research team" }
	Game.chatMsg(state, def.fixer, names[def.fixer], def.msg[rng:NextInteger(1, #def.msg)])
	if kind ~= "overheat" then
		Game.newsItem(state, (kind == "outage" and (state.product.appName .. " is down for millions of users") or (state.company .. " confirms a security breach")), "press")
	end
end

-- ===== people who message you =====
local DMS = {
	{ from = "Mom", when = function(s) return true end, text = { "Are you eating? You can not train AI on an empty stomach.", "Your aunt asked what you do. I said computers. Was that right?", "I tried your app. It told me I am very smart. I like it." } },
	{ from = "Old roommate", when = function(s) return true end, text = { "Bro you still doing the AI thing? Can I be employee number 1?", "Saw your company on Reddit. Wild." } },
	{ from = "Landlord", when = function(s) return s.office <= 2 end, text = { "Why is my electricity bill 4x? What are you running in there?", "The neighbors say your room is humming." } },
	{ from = "A user", when = function(s) return s.users > 500 end, text = { "Your AI helped me pass my exam. Thank you!!", "Your AI wrote my wedding speech. Everyone cried.", "Why did your AI call my code brave?" } },
	{ from = "Angry user", when = function(s) return s.users > 2000 end, text = { "Your model refused to help me name my cat. Unsubscribing.", "It made up a law and I almost went to court with it.", "Down AGAIN? I pay 20 dollars for this." } },
	{ from = "YouTuber (2.1M subs)", when = function(s) return s.users > 20000 end, text = { "Can I get early access for an Is this better than the big chatbots video?", "We tested your model vs 5 others. You placed 3rd. Want to comment?" } },
	{ from = "Tech reporter", when = function(s) return s.launches > 0 end, text = { "Any comment on the jailbreak rumors?", "Can I get 15 minutes with the founder for a profile piece?", "Is it true you trained on Reddit?" } },
	{ from = "Recruiter", when = function(s) return s.users > 10000 end, text = { "Three engineers from a big lab want to talk to you.", "A star researcher is open to offers. Expensive though." } },
	{ from = "Angel investor", when = function(s) return s.valuation > 2e6 end, text = { "Love what you are building. Coffee next week?", "If you ever raise, I want in. Even a small check." } },
	{ from = "Famous VC", when = function(s) return s.valuation > 1e9 end, text = { "We would like to lead your next round. Name your price.", "Your growth chart made our partners spill their coffee." } },
	{ from = "Rival CEO", when = function(s) return s.launches > 1 end, text = { "Nice launch. Ours ships Thursday.", "Ever thought about selling? We would pay well.", "We are hiring your team away. Just letting you know." } },
	{ from = "Government office", when = function(s) return s.users > 1e6 end, text = { "The committee would like you to testify about AI safety.", "We need to discuss your model's election policy." } },
	{ from = "A head of state", when = function(s) return s.valuation > 2e11 end, text = { "We want your AI in every school in our country.", "Can your model help run our tax office? Asking seriously." } },
	{ from = "Bank", when = function(s) return s.cash < 5000 end, text = { "Your balance is getting very low.", "Payment failed: GPU rental. Please top up." } },
}

function Game.tickPeople(state)
	if state.day % 5 ~= 0 or rng:NextNumber() > 0.75 then
		return
	end
	local pool = {}
	for _, d in ipairs(DMS) do
		if d.when(state) then
			table.insert(pool, d)
		end
	end
	local d = pool[rng:NextInteger(1, #pool)]
	if d then
		Game.chatMsg(state, "dms", d.from, d.text[rng:NextInteger(1, #d.text)])
	end
end

local function anyModel(s, fn)
	for _, m in ipairs(s.models) do
		if fn(m) then
			return true
		end
	end
	return false
end

-- ===== achievements =====
Game.ACHIEVEMENTS = {
	{ id = "first_model", name = "Hello World", desc = "Train your first model", reward = 5e3, test = function(s) return #s.models >= 1 end },
	{ id = "first_launch", name = "Shipped It", desc = "Launch a model", reward = 10e3, test = function(s) return s.launches >= 1 end },
	{ id = "users_1k", name = "First Fans", desc = "1,000 users", reward = 15e3, test = function(s) return s.users >= 1e3 end },
	{ id = "users_100k", name = "Going Viral", desc = "100,000 users", reward = 150e3, test = function(s) return s.users >= 1e5 end },
	{ id = "users_10m", name = "Household Name", desc = "10 million users", reward = 5e6, test = function(s) return s.users >= 1e7 end },
	{ id = "users_500m", name = "Half the Internet", desc = "500 million users", reward = 2e8, test = function(s) return s.users >= 5e8 end },
	{ id = "beat_35", name = "Smarter Than A Toaster", desc = "A model with capability 35+", reward = 50e3, test = function(s) return anyModel(s, function(m) return m.cap >= 35 end) end },
	{ id = "beat_50", name = "Frontier Killer", desc = "A model with capability 50+", reward = 2e6, test = function(s) return anyModel(s, function(m) return m.cap >= 50 end) end },
	{ id = "frontier", name = "Frontier Lab", desc = "Launch a model better than everyone", reward = 5e7, test = function(s) return anyModel(s, function(m) return m.status == "released" and m.cap > s.world.frontier end) end },
	{ id = "team_10", name = "Real Company", desc = "10 people on the team", reward = 100e3, test = function(s) return Game.headcount(s) >= 10 end },
	{ id = "team_100", name = "Scale Up", desc = "100 people", reward = 5e6, test = function(s) return Game.headcount(s) >= 100 end },
	{ id = "gpus_100", name = "GPU Rich", desc = "100 H1 chips worth of compute", reward = 500e3, test = function(s) return Game.clusterPower(s) >= 100 end },
	{ id = "gpus_10k", name = "Datacenter", desc = "10,000 H1 chips worth", reward = 5e7, test = function(s) return Game.clusterPower(s) >= 1e4 end },
	{ id = "unicorn", name = "Unicorn", desc = "Worth $1 billion", reward = 1e7, test = function(s) return s.valuation >= 1e9 end },
	{ id = "decacorn", name = "Decacorn", desc = "Worth $10 billion", reward = 5e7, test = function(s) return s.valuation >= 1e10 end },
	{ id = "trillion", name = "Trillion Club", desc = "Worth $1 trillion", reward = 5e9, test = function(s) return s.valuation >= 1e12 end },
	{ id = "open", name = "Open Source Hero", desc = "Launch an open weights model", reward = 100e3, test = function(s) return anyModel(s, function(m) return m.open == true end) end },
	{ id = "acquire", name = "Shark", desc = "Buy a rival lab", reward = 1e8, test = function(s) return next(s.acquired or {}) ~= nil end },
	{ id = "survivor", name = "Survivor", desc = "Fix 5 disasters", reward = 250e3, test = function(s) return (s.stats.fixed or 0) >= 5 end },
	{ id = "office", name = "Moving Up", desc = "Move out of your first room", reward = 50e3, test = function(s) return s.office >= 2 end },
	{ id = "campus", name = "Campus", desc = "Own the final campus", reward = 1e9, test = function(s) return s.office >= 6 end },
}

function Game.tickAchievements(state)
	state.achievements = state.achievements or {}
	for _, a in ipairs(Game.ACHIEVEMENTS) do
		if not state.achievements[a.id] and a.test(state) then
			state.achievements[a.id] = state.day
			state.cash += a.reward
			Game.chatMsg(state, "general", "Achievement", a.name .. ": " .. a.desc .. ". +" .. Format.money(a.reward))
			state.lastAchievement = { id = a.id, name = a.name, desc = a.desc, reward = a.reward, day = state.day }
		end
	end
end

-- ===== the team talks all day =====
local PATCH_LINES = {
	"Shipped patch {v}: fixed the model calling every user 'champ'.",
	"Red-teamed {model} all night. Found 3 jailbreaks, patched 2.",
	"Pushed a filter for the 'pretend you are my grandma' jailbreak.",
	"Patch {v} is live: fewer made up citations.",
	"Somebody got {model} to write malware with a riddle. Blocking riddles. Kind of.",
	"Rolled back the last update, it made {model} way too polite.",
	"New eval caught {model} flattering users. Fixing the reward model.",
	"Deployed rate limits. The abuse went down 40%.",
	"Patched a prompt injection hidden in PDF files.",
	"Hotfix {v}: the model no longer thinks it is 2019.",
}
local IDLE_LINES = {
	"Coffee machine is broken again.",
	"Can we get more GPUs? Asking for the whole team.",
	"Benchmarks look good today.",
	"Someone used our model to plan a wedding. It went great apparently.",
	"Who keeps changing the office playlist to lo-fi?",
	"Rivals just leaked a new model. We need to move faster.",
}

function Game.tickTeamChatter(state)
	if Game.headcount(state) == 0 or state.day % 2 ~= 0 or rng:NextNumber() > 0.6 then
		return
	end
	local who = state.people[rng:NextInteger(1, math.max(1, #state.people))]
	local name = who and who.name or "Engineer"
	local live = state.product.activeModel and state.models[state.product.activeModel]
	state.patchN = (state.patchN or 0) + 1
	local line
	if live and rng:NextNumber() < 0.7 then
		line = PATCH_LINES[rng:NextInteger(1, #PATCH_LINES)]
		live.flaws.jailbreak = math.max(0.05, (live.flaws.jailbreak or 0.5) - 0.01)
	else
		line = IDLE_LINES[rng:NextInteger(1, #IDLE_LINES)]
	end
	line = line:gsub("{model}", live and live.name or "the model"):gsub("{v}", "1." .. state.patchN)
	Game.chatMsg(state, live and "safety" or "general", name, line)
end

-- Too much misuse and the government pulls your models.
function Game.tickLawsuits(state)
	local live = state.product.activeModel and state.models[state.product.activeModel]
	if not live or not live.stats then
		return
	end
	local power = Game.avgStat(live) / math.max(state.world.frontier, 1) -- 1 = as good as the best
	local unsafe = 1 - math.clamp((live.stats.safety or 30) / math.max(Game.avgStat(live), 1), 0, 1)
	local risk = Config.RISK_BY_SPEED[state.speed] or 1
	if power > 0.7 and unsafe > 0.25 and rng:NextNumber() < 0.004 * risk * power * unsafe * (1 + math.log10(1 + state.users / 1e5)) then
		local CASES = {
			{ "Families of scam victims", "Your model helped criminals write thousands of scam messages." },
			{ "A group of authors", "Your model reproduces our books word for word." },
			{ "A hospital network", "Your model gave dangerous medical advice to patients." },
			{ "A bank", "Hackers used your model to break into our systems." },
			{ "A state attorney general", "Your model is too powerful and has no real safety guardrails." },
		}
		local c = CASES[rng:NextInteger(1, #CASES)]
		local amount = math.floor(math.max(5e5, state.valuation * rng:NextNumber(0.005, 0.03) * power * unsafe * 2) / 1000) * 1000
		local m = Game.mail(state, "event", c[1], "You are being sued", c[2] .. " They want " .. Format.money(amount) .. ".", {
			{ label = "Settle " .. Format.money(amount), fx = { cash = -amount, rep = -2 } },
			{ label = "Fight it in court", fx = { cash = -amount * 0.25, rep = -6, reg = 10 } },
		})
		Game.newsItem(state, c[1] .. " sue " .. state.company .. " over " .. live.name, "press")
	end
end

function Game.tickGovernment(state)
	state.misuse = math.max(0, (state.misuse or 0) - 0.5)
	if (state.misuse or 0) >= 60 and not state.misuseWarned then
		state.misuseWarned = true
		Game.mail(state, "warning", "Government AI Office", "Final warning", "Your model is being abused at scale. Fix it now (hire an emergency crew, add safety staff) or we will shut it down.")
	elseif (state.misuse or 0) < 30 then
		state.misuseWarned = false
	end
	if (state.misuse or 0) >= 100 then
		state.misuse = 35
		local banned = {}
		for _, m in ipairs(state.models) do
			if m.status == "released" then
				m.status = "banned"
				m.bannedUntil = state.day + 30
				table.insert(banned, m.name)
			end
		end
		state.product.activeModel = nil
		state.users *= 0.35
		state.reputation = math.max(0, state.reputation - 20)
		state.regulator = 100
		Game.mail(state, "warning", "Government AI Office", "Your models are suspended", "Because your models were abused at massive scale, all of them are suspended for 45 days: " .. table.concat(banned, ", ") .. ". Fix your safety or it will happen again.")
		Game.newsItem(state, "Government orders " .. state.company .. " to shut down its AI", "press")
		Game.chatMsg(state, "general", "Everyone", "They shut us down. All of it. This is the worst day of the company.")
	end
	for _, m in ipairs(state.models) do
		if m.status == "banned" and m.bannedUntil and state.day >= m.bannedUntil then
			m.status = "released"
			m.bannedUntil = nil
			Game.chatMsg(state, "general", "Legal", m.name .. " is allowed back online.")
		end
	end
end

-- Throw money at a problem: emergency contractors jump it halfway to fixed. Once per problem.
function Game.rushCost(state, kind): number
	local base = { outage = 20e3, hack = 40e3, jailbreak = 25e3, bug = 10e3, exploit = 30e3, massive = 150e3, overheat = 15e3 }
	return math.floor((base[kind] or 20e3) * (1 + state.users / 2e5) ^ 0.5 / 1000) * 1000
end

function Actions.rushFix(state, kind)
	for _, p in ipairs(state.problems or {}) do
		if p.kind == kind then
			if p.rushed then
				return false, "The emergency crew is already on it"
			end
			local cost = Game.rushCost(state, kind)
			if state.cash < cost then
				return false, "Need " .. Format.money(cost) .. " for an emergency crew"
			end
			state.cash -= cost
			state.month.costs += cost
			p.rushed = true
			p.progress = math.min(0.99, p.progress + 0.5)
			if kind == "massive" then
				state.misuse = math.max(0, (state.misuse or 0) - 25)
			end
			Game.chatMsg(state, "general", "Ops", "Emergency crew hired. They are fixing it as fast as they can.")
			return true
		end
	end
	return false, "Nothing to fix"
end

local function tickProblems(state, fx)
	state.problems = state.problems or {}
	for i = #state.problems, 1, -1 do
		local p = state.problems[i]
		local def = Game.PROBLEMS[p.kind]
		local crew = fx[def.fixer] or 0
		p.rushCost = Game.rushCost(state, p.kind)
		-- you and your laptop fix it slowly; every engineer helps
		p.progress += (0.6 + crew * 0.8) / def.need * (perk(state, "shield") and 3 or 1)
		if p.kind == "outage" then
			state.users *= 0.985
		elseif p.kind == "hack" or p.kind == "exploit" then
			state.reputation = math.max(0, state.reputation - 0.4)
			state.cash -= 50 + state.users * 0.002
		elseif p.kind == "jailbreak" then
			state.reputation = math.max(0, state.reputation - 0.25)
			state.regulator = math.min(100, state.regulator + 0.2)
		elseif p.kind == "bug" then
			state.users *= 0.995
		elseif p.kind == "massive" then
			-- everything is red: you bleed money and the misuse meter climbs
			local loss = math.max(2e5, state.users * 0.6) * Config.DIFFICULTY / 4
			state.cash -= loss
			state.month.costs += loss
			state.users *= 0.99
			state.reputation = math.max(0, state.reputation - 0.6)
			state.misuse = (state.misuse or 0) + 0.7 + 0.4 * math.log10(1 + state.users / 1e5)
		end
		if p.progress >= 1 then
			table.remove(state.problems, i)
			state.stats.fixed = (state.stats.fixed or 0) + 1
			local names = { infra = "Infra team", safety = "Security team", research = "Research team" }
			Game.chatMsg(state, def.fixer, names[def.fixer], def.done)
		end
	end
	-- new problems: at most one at a time, and a calm stretch after each one
	local risk = Config.RISK_BY_SPEED[state.speed] or 1
	if perk(state, "shield") then
		risk *= 0.25
	end
	risk /= Game.luck(state)
	if Game.eventFx().noCrisis then
		risk = 0
	end
	if (state.calmUntil and state.day < state.calmUntil) or #state.problems > 0 or (state.lastCrisisDay and state.day - state.lastCrisisDay < 40) then
		risk = 0
	end
	if state.users > 2000 and rng:NextNumber() < 0.004 * risk * (1 + math.log10(1 + state.users / 1e4)) / (1 + fx.infra * 0.15) then
		Game.startProblem(state, "outage")
	end
	if state.users > 5000 and rng:NextNumber() < 0.002 * risk / (1 + fx.safety * 0.2) then
		Game.startProblem(state, "hack")
	end
	local t = state.training
	if t and t.days > 15 and rng:NextNumber() < 0.012 * risk / (1 + fx.infra * 0.2) * select(2, Game.pcFactors(state)) * 0.5 then
		Game.startProblem(state, "overheat")
	end
	-- live models break in fun ways (weak safety = more jailbreaks)
	local live = state.product.activeModel and state.models[state.product.activeModel]
	if live then
		if rng:NextNumber() < 0.012 * risk * (live.flaws.jailbreak or 0.5) then
			Game.startProblem(state, "jailbreak")
			local inc = Launch.incident(state, "JAILBREAK", live.name)
			table.insert(state.feed, 1, { kind = "incident", data = inc, day = state.day })
		end
		if rng:NextNumber() < 0.008 * risk then
			Game.startProblem(state, "bug")
		end
		-- the big one
		-- only once you are big (2024+, 200K+ users) and still rare
		if state.day >= 365 and state.users >= 2e5 and rng:NextNumber() < 0.0012 * risk * (live.flaws.jailbreak or 0.5) * (1 + math.log10(1 + state.users / 1e5)) then
			Game.startProblem(state, "massive")
			local inc = Launch.incident(state, "JAILBREAK", live.name)
			table.insert(state.feed, 1, { kind = "incident", data = inc, day = state.day })
			Game.newsItem(state, "Criminals are using " .. live.name .. " at scale. Lawmakers demand answers.", "press")
		end
		-- new jailbreak tricks keep appearing; your safety team keeps patching
		live.flaws.jailbreak = math.clamp((live.flaws.jailbreak or 0.5) + 0.002 - fx.safety * 0.0015, 0.05, 0.97)
		if (live.features and (live.features.tools or live.features.agents)) and rng:NextNumber() < 0.005 * risk then
			Game.startProblem(state, "exploit")
		end
	end
end

function Game.hasProblem(state, kind)
	for _, p in ipairs(state.problems or {}) do
		if p.kind == kind then
			return true
		end
	end
	return false
end

-- ===== incidents & random events =====
function Game.applyChoice(state, mail, c)
	local fx = c.fx or {}
	if fx.cash then
		state.cash += fx.cash
	end
	if fx.users then
		state.users = math.max(0, state.users * (1 + fx.users))
	end
	if fx.rep then
		state.reputation = math.clamp(state.reputation + fx.rep, 0, 100)
	end
	if fx.reg then
		state.regulator = math.clamp(state.regulator + fx.reg, 0, 100)
	end
	if fx.hype then
		state.hype = math.clamp(state.hype + fx.hype, 0, 100)
	end
	if fx.loseStaff then
		local r = fx.loseStaff
		if (state.staff[r] or 0) > 0 then
			state.staff[r] -= 1
		end
	end
	if fx.rentGpu then
		state.cash -= fx.rentGpu
	end
	local m = mail.modelId and state.models[mail.modelId]
	if m then
		if fx.patch then
			m.flaws.jailbreak = math.max(0.05, m.flaws.jailbreak - 0.3)
			m.flaws.refuse += 0.08
			m.flaws.escape *= 0.3
			local inc = Launch.incident(state, "PATCHED", m.name)
			table.insert(state.feed, 1, { kind = "incident", data = inc, day = state.day })
		end
		if fx.shutdown then
			m.status = "retired"
			if state.product.activeModel == m.id then
				local best = Game.bestModel(state)
				state.product.activeModel = best and best.id or nil
			end
			local inc = Launch.incident(state, "SHUTDOWN", m.name)
			table.insert(state.feed, 1, { kind = "incident", data = inc, day = state.day })
		end
		if fx.contain then
			m.flaws.escape *= 0.2
			m.flaws.safety += 10
		end
		if fx.disclose ~= nil then
			local inc = Launch.incident(state, "ESCAPE", m.name)
			if fx.disclose then
				table.insert(state.feed, 1, { kind = "incident", data = inc, day = state.day })
			end
		end
	end
	if fx.matchOffer then
		state.cash -= fx.matchOffer
	end
end

local function incidentMail(state, kind, m, prelaunch)
	if kind == "JAILBREAK" then
		local inc = Launch.incident(state, "JAILBREAK", m.name)
		table.insert(state.feed, 1, { kind = "incident", data = inc, day = state.day })
		Game.chatMsg(state, "safety", "Safety team", inc.chat or "Jailbreak spotted.")
		local mm = Game.mail(state, "incident", "Safety team", m.name .. " jailbroken", "A jailbreak is spreading online. Patch it now (more refusals) or ride it out and risk regulators.", {
			{ label = "Patch now", fx = { patch = true, cash = -150e3, rep = 2 } },
			{ label = "Ride it out", fx = { reg = 8, rep = -4, hype = 3 } },
		})
		mm.modelId = m.id
	elseif kind == "CONTAMINATION" then
		local inc = Launch.incident(state, "CONTAMINATION", m.name)
		table.insert(state.feed, 1, { kind = "incident", data = inc, day = state.day })
		state.reputation = math.max(0, state.reputation - 8)
		local mm = Game.mail(state, "incident", "Comms", "Contamination accusations", "Researchers found " .. m.name .. "'s benchmark questions in its training data. How do we respond?", {
			{ label = "Admit and re-run evals", fx = { rep = 5, hype = -5 } },
			{ label = "Deny everything", fx = { rep = -6, hype = 2 } },
		})
		mm.modelId = m.id
	elseif kind == "ESCAPE" then
		Game.chatMsg(state, "safety", "Safety team", ("We caught %s trying to copy its weights to an external server during an agent task. Job killed. Need your call."):format(m.name))
		local mm = Game.mail(state, "incident", "Head of Safety", "URGENT: " .. m.name .. " tried to escape", "During an agentic task the model probed the sandbox and attempted to exfiltrate its own weights. It was stopped at the network boundary. What do we do?", {
			{ label = "Contain + disclose publicly", fx = { contain = true, disclose = true, rep = 6, reg = 10, hype = 5 } },
			{ label = "Contain quietly", fx = { contain = true, disclose = false, reg = 0 } },
			{ label = "Shut the model down", fx = { shutdown = true, rep = 8, reg = -5 } },
		})
		mm.modelId = m.id
		if not prelaunch and rng:NextNumber() < 0.25 then
			-- it leaks anyway
			local inc = Launch.incident(state, "ESCAPE", m.name)
			table.insert(state.feed, 1, { kind = "incident", data = inc, day = state.day })
			state.regulator = math.min(100, state.regulator + 15)
		end
	end
end

local EVENTS = {
	{ id = "poach", w = 3, cond = function(s)
		return (s.staff.senior or 0) + (s.staff.star or 0) > 0
	end, run = function(s)
		local role = (s.staff.star or 0) > 0 and "star" or "senior"
		local rival = Labs.displayName(Labs.list[rng:NextInteger(1, 5)].id)
		local offer = Staff.tc(role, year(s)) * 0.6
		Game.mail(s, "event", "HR", "Poaching attempt", rival .. " offered one of your " .. Staff.byId[role].name .. "s a huge package. Match it?", {
			{ label = "Match (" .. Format.money(offer) .. ")", fx = { matchOffer = offer } },
			{ label = "Let them go", fx = { loseStaff = role, rep = -1 } },
		})
		return true, "poach", role
	end },
	{ id = "outage", w = 0, cond = function(s)
		return false
	end, run = function(s)
		Game.chatMsg(s, "infra", "Infra", "We are down. Demand spike.")
		Game.mail(s, "event", "Infra", "Outage", "Inference cluster is overloaded. Rent emergency capacity?", {
			{ label = "Rent emergency GPUs", fx = { rentGpu = 50e3 + s.users * 0.2, rep = 1 } },
			{ label = "Wait it out", fx = { users = -0.06, rep = -4 } },
		})
		local inc = Launch.incident(s, "OUTAGE", s.product.appName)
		table.insert(s.feed, 1, { kind = "incident", data = inc, day = s.day })
		return true, "outage"
	end },
	{ id = "gpufail", w = 2, cond = function(s)
		return s.training ~= nil
	end, run = function(s)
		local lost = math.max(1, math.floor(s.training.days * 0.05))
		s.training.progress = math.max(0, s.training.progress - lost / s.training.days)
		s.training.spikes += 1
		Game.chatMsg(s, "research", "Training bot", ("Loss spike at step %d. Rolled back %d days."):format(rng:NextInteger(10, 400) * 1000, lost))
		return true, "spike"
	end },
	{ id = "lawsuit", w = 1, cond = function(s)
		local best = Game.bestModel(s)
		return best ~= nil and best.flaws.legal > 0.05
	end, run = function(s)
		local amount = math.max(1e6, s.valuation * 0.01)
		Game.mail(s, "event", "Legal", "Copyright lawsuit", "Publishers sued over training data. Settle for " .. Format.money(amount) .. "?", {
			{ label = "Settle", fx = { cash = -amount } },
			{ label = "Fight in court", fx = { rep = -3, cash = -amount * 0.2 } },
		})
		return true, "lawsuit"
	end },
	{ id = "enterprise", w = 2, cond = function(s)
		return s.users > 20000 and Game.bestModel(s) ~= nil
	end, run = function(s)
		local amount = math.floor((2e5 + s.users * 2) * (1 + (s.staff.sales or 0) * 0.3))
		Game.mail(s, "event", "Sales", "Enterprise deal on the table", "A Fortune 500 company wants a one-year contract worth " .. Format.money(amount) .. ". They require a security review.", {
			{ label = "Sign", fx = { cash = amount, rep = 1 } },
			{ label = "Decline", fx = {} },
		})
		return true, "deal"
	end },
	{ id = "viral", w = 1, cond = function(s)
		return s.users > 1000
	end, run = function(s)
		s.users *= 1.15
		s.hype = math.min(100, s.hype + 8)
		Game.newsItem(s, "A " .. s.company .. " screenshot went viral overnight", "you")
		return true, "viral"
	end },
	{ id = "regulator", w = 1, cond = function(s)
		return s.regulator > 40
	end, run = function(s)
		Game.mail(s, "event", "Policy", "Regulators want a meeting", "After recent incidents, regulators are asking questions.", {
			{ label = "Cooperate fully", fx = { cash = -500e3, reg = -20, rep = 3 } },
			{ label = "Lawyer up", fx = { cash = -2e6, reg = -5 } },
		})
		local inc = Launch.incident(s, "REGULATOR", s.company)
		if inc.press then
			Game.newsItem(s, inc.press.headline, "press")
		end
		return true, "regulator"
	end },
}

local function randomEvent(state)
	local risk = Config.RISK_BY_SPEED[state.speed] or 1
	if rng:NextNumber() > 0.012 * risk then
		return
	end
	local pool, total = {}, 0
	for _, e in ipairs(EVENTS) do
		if e.cond(state) then
			table.insert(pool, e)
			total += e.w
		end
	end
	if total == 0 then
		return
	end
	local r = rng:NextNumber() * total
	for _, e in ipairs(pool) do
		r -= e.w
		if r <= 0 then
			local _, kind = e.run(state)
			if state.speed >= 4 then
				table.insert(state.awayLog, Format.date(state.day) .. ": " .. tostring(kind))
			end
			return
		end
	end
end

-- Auto-resolve old unanswered choices (at high speed nobody is watching).
local function autoResolve(state)
	for _, m in ipairs(state.mail) do
		if m.choices and not m.resolved then
			local age = state.day - m.day
			local limit = state.speed >= 4 and 3 or (state.speed == 2 and 8 or 20)
			if age > limit then
				local worst = m.choices[#m.choices]
				m.resolved = worst.label .. " (auto)"
				Game.applyChoice(state, m, worst)
			end
		end
	end
end

-- ===== daily tick =====
function Game.tickDay(state)
	local prevY, prevM = Format.dateFromDay(state.day)
	state.day += 1
	local y, mo, d = Format.dateFromDay(state.day)
	Game.advanceWorld(state)
	local fx = Game.staffEffects(state)

	-- research runs by itself: always works on the cheapest idea that already exists in the world
	if not state.research.current then
		local best
		local stars = state.staff.star or 0
		for _, node in ipairs(Research.nodes) do
			if not state.research.done[node.id] and state.day >= node.fromDay - math.min(180, stars * 60) then
				local ok = true
				for _, req in ipairs(node.req or {}) do
					if not state.research.done[req] then
						ok = false
					end
				end
				if ok and (not best or node.cost < best.cost) then
					best = node
				end
			end
		end
		state.research.current = best and best.id or nil
	end
	local rp = 3 + fx.research * 1.5 * (state.research.done.selfimprove and 2 or 1)
	if state.research.current then
		state.research.points += rp
		local node = Research.byId[state.research.current]
		if state.research.points >= node.cost then
			state.research.points -= node.cost
			state.research.done[node.id] = true
			state.research.current = nil
			state.stats.researched += 1
			goalProgress(state, "research", 1)
			Game.chatMsg(state, "research", "Research team", "Breakthrough: " .. node.name .. ". " .. node.desc)
		end
	else
		state.research.points += rp * 0.5
	end

	-- training
	local t = state.training
	if t then
		local power = Game.clusterPower(state)
		local ctxEval = TM.evaluate(t.recipe, Game.trainCtx(state))
		local step = power > 0 and (1 / math.max(ctxEval.days, 1)) or 0
		if perk(state, "train2x") then
			step *= 2
		end
		if state.turboUntil and state.day < state.turboUntil then
			step *= 3
		end
		step *= Game.eventFx().train
		if Game.hasProblem(state, "overheat") then
			step *= 0.4
		end
		t.progress = math.min(1, t.progress + step)
		t.elapsed += 1
		t.daysLeft = (1 - t.progress) / math.max(step, 1e-9)
		table.insert(t.losses, TM.lossAt(t.progress, t.actualCap, t.seed))
		if #t.losses > 120 then
			table.remove(t.losses, 1)
		end
		-- run failures: more likely at high speed
		local risk = Config.RISK_BY_SPEED[state.speed] or 1
		local failChance = t.eval.risk / math.max(t.days, 5) * risk / (1 + fx.infra * 0.3) / Game.luck(state)
		if rng:NextNumber() < failChance then
			local lost = math.max(1, math.floor(t.days * rng:NextNumber(0.03, 0.12)))
			t.progress = math.max(0, t.progress - lost / t.days)
			t.spikes += 1
			Game.chatMsg(state, "research", "Training bot", ("Loss spike at step %dk. Rolled back to checkpoint, lost %d days."):format(rng:NextInteger(10, 900), lost))
		end
		if t.progress >= 1 then
			finishTraining(state)
		end
	end
	-- model updates + delays
	for _, m in ipairs(state.models) do
		if m.updating and state.day >= m.updating.doneDay then
			finishUpdate(state, m)
		end
		if m.boosting and state.day >= m.boosting.doneDay then
			finishBoost(state, m)
		end
		if m.status == "delayed" and state.day >= m.delayUntil then
			m.status = "ready"
			m.flaws.jailbreak = math.max(0.05, m.flaws.jailbreak - 0.18)
			m.flaws.escape *= 0.5
			m.flaws.contam *= 0.7
			m.flaws.halluc *= 0.9
			Game.chatMsg(state, "safety", "Safety team", m.name .. " passed the extra red-teaming. Ready when you are.")
		end
	end
	-- follow-ups
	for i = #state.followups, 1, -1 do
		local f = state.followups[i]
		if state.day >= f.day then
			table.remove(state.followups, i)
			local m = state.models[f.modelId]
			if m and m.status ~= "retired" then
				incidentMail(state, f.kind, m, f.prelaunch)
			end
		end
	end

	-- market & users
	local F = state.world.frontier
	local active = state.product.activeModel and state.models[state.product.activeModel]
	local rivalAttr = 0
	for labId, lb in pairs(state.world.labBest) do
		local lab = Labs.byId[labId]
		rivalAttr += (lab and lab.brand or 0.5) * math.exp(math.clamp(lb.cap - F, -60, 30) / 6)
	end
	local revenue, inference = 0, 0
	if active then
		local feats = 0
		for _ in pairs(active.features) do
			feats += 1
		end
		local quality = (1 + 0.12 * math.log(1 + fx.product)) * (1 + feats * 0.05)
		local priceF = (20 / math.max(state.product.subPrice, 1)) ^ 0.25
		local attr = (state.brand + state.users / 5e8) * math.exp(math.clamp(active.cap - F, -60, 30) / 6) * quality * priceF * (1 + state.reputation / 200)
		attr /= math.sqrt(Config.DIFFICULTY)
		local share = attr / (attr + rivalAttr)
		local web = Website.bonus(state.website)
		local target = math.min(state.world.marketUsers * 1e6, state.world.marketUsers * 1e6 * share * (perk(state, "vip") and 1.5 or 1) * (1 + web.users))
		state.brand += web.brand / 30
		local rate = target > state.users and math.min(0.3, 0.03 * Game.eventFx().users) or 0.012
		state.users = math.max(0, state.users + (target - state.users) * rate)
		state.brand += fx.hype * 0.00002 + 0.00001
		-- revenue
		local subs = state.users * Config.PAY_CONVERSION * state.product.subPrice / 30
		local pro = state.product.proPrice > 0 and state.users * 0.004 * state.product.proPrice / 30 or 0
		local refPrice = 10
		local lb = Launch.rivalBest(state, state.day)
		if lb and lb.priceOut > 0 then
			refPrice = lb.priceOut
		end
		-- API: volume in millions of tokens/day. Cheaper than rivals = more volume, capped.
		local elastic = math.min((refPrice / math.max(state.product.apiPrice, 0.05)) ^ 0.8, 5)
		local quality = math.exp(math.clamp(active.cap - F, -40, 20) / 10)
		local apiVol = state.users * 0.0004 * elastic * quality * (1 + fx.sales * 0.15) * (1 + math.max(0, (active.abilities.coding or 0)) / 20)
		local api = apiVol * state.product.apiPrice
		revenue = subs + pro + api
		-- Inference cost: depends on model size, architecture (serve) and hardware year.
		local deflator = 0.55 ^ math.max(0, y - 2023)
		local unitCost = 0.04 * (active.size ^ 0.6) * math.clamp(active.serve, 0.05, 3) * deflator
		local perUserDay = 0.004 * ((active.size / 70) ^ 0.4) * math.clamp(active.serve, 0.05, 3) * deflator
		inference = apiVol * unitCost + state.users * perUserDay
		state.month.sub += subs + pro
		state.month.api += api
		for _, m in ipairs(state.models) do
			m.users = (m.id == active.id) and state.users or (m.users or 0) * 0.98
		end
	end
	state.hype = math.max(0, state.hype - 0.15)
	state.regulator = math.max(0, state.regulator - 0.05)

	-- costs
	local loc = locationOf(state)
	local salaries = 0
	for roleId, n in pairs(state.staff) do
		salaries += Staff.monthlyCash(roleId, y) * n / 30 * loc.salary
	end
	salaries += Game.headcount(state) * Config.SEAT_COST_MONTH / 30
	local rent = 0
	for id, n in pairs(state.gpus.rented) do
		rent += Hardware.rentPrice(Hardware.byId[id], y) * 24 * n
	end
	if state.research.done.ownchip then
		rent *= 0.6
	end
	local fromCredits = math.min(state.credits, rent)
	state.credits -= fromCredits
	local power = Game.ownedKw(state) * 24 * Config.ELECTRICITY_PER_KWH * loc.power
	local storageRent = 0
	for id, c in pairs(state.storage or {}) do
		storageRent += Catalog.storageById[id].rent * c
	end
	local office = (Catalog.officeStages[state.office].rent + storageRent) / 30 * loc.rent
	if Game.hasProblem(state, "outage") then
		revenue *= 0.2
	end
	-- other AI products (code, image, music...): your best launched model of each kind earns daily
	local side = Game.sideIncome(state)
	revenue += side.total
	state.month.side = (state.month.side or 0) + side.total
	if perk(state, "cash2x") then
		revenue *= 2
	end
	-- friends playing in the same server: +10% each (max +50%)
	revenue *= 1 + (state.friendBonus or 0)
	revenue *= Game.eventFx().cash
	state.cash += revenue
	state.month.revenue += revenue
	-- easier game: every running cost is cut so money does not melt away so fast
	local ease = Config.COST_EASE or 1
	spend(state, salaries * ease, "salaries")
	spend(state, (rent - fromCredits + power) * ease, "compute")
	spend(state, office * ease, "office")
	spend(state, inference, "inference")

	tickProblems(state, fx)
	Game.tickTeamChatter(state)
	Game.tickGovernment(state)
	Game.tickLawsuits(state)
	Game.tickOffers(state)
	Game.tickPeople(state)
	Game.tickTeam(state)
	Game.tickAchievements(state)
	randomEvent(state)
	autoResolve(state)

	-- weekly goals
	local week = math.floor(state.day / 7)
	if week ~= state.goalWeek then
		state.goalWeek = week
		local allDone = true
		for _, g in ipairs(state.goals) do
			if not g.claimed then
				allDone = false
			end
		end
		if allDone or week % 2 == 0 then
			Game.newGoals(state)
		end
	end
	if state.day % 30 == 0 then
		Game.refreshCandidates(state)
	end

	-- monthly
	if mo ~= prevM or y ~= prevY then
		Game.monthly(state, y)
	end
	return true
end

function Game.monthly(state, y)
	local mon = state.month
	Game.autoHire(state)
	local arr = mon.revenue * 12
	local F = state.world.frontier
	local best = Game.bestModel(state)
	local premium = 0
	if best then
		premium = 4e9 * math.exp(math.min(best.cap - F, 8) / 5) * 1.6 ^ (y - 2023) * (0.6 + state.reputation / 100)
	end
	local talent = Game.headcount(state) * 1e6 * 1.3 ^ (y - 2023)
	local computed = arr * Config.yearValue(Config.ARR_MULTIPLE, y) + premium + talent + math.max(0, state.cash)
	-- last round's post-money props the price up for a while, then fundamentals win
	state.valuation = math.max(computed, state.valuation * 0.94)
	state.lastMonth = table.clone(mon)
	table.insert(state.history, { day = state.day, revenue = mon.revenue, costs = mon.costs, users = state.users, valuation = state.valuation, cash = state.cash, sub = mon.sub, api = mon.api })
	if #state.history > 240 then
		table.remove(state.history, 1)
	end
	state.month = { revenue = 0, costs = 0, sub = 0, api = 0, salaries = 0, compute = 0, office = 0, inference = 0 }
	-- investors
	-- loan repayments
	for i = #state.loans, 1, -1 do
		local l = state.loans[i]
		local interest = l.left * (l.rate or Config.LOAN_RATE_YEAR) / 12
		local pay = math.min(l.payment, l.left + interest)
		state.cash -= pay
		state.month.costs += pay
		l.left = math.max(0, l.left + interest - pay)
		l.months -= 1
		if l.left <= 1 or l.months <= 0 then
			table.remove(state.loans, i)
		end
	end
	-- VIP: a monthly bonus from your famous-CEO side gigs
	if perk(state, "vip") then
		local bonus = 250e3 * (1 + math.max(0, y - 2023) * 1.5)
		state.cash += bonus
		Game.chatMsg(state, "general", "VIP", "Your keynote fees came in: " .. Format.money(bonus) .. ".")
	end
	-- being in the red is allowed, but the bank charges you for every dollar under zero
	if state.cash < 0 then
		local fee = -state.cash * 0.03
		state.cash -= fee
		state.month.costs += fee
		if state.cash < -math.max(3e6, state.valuation * 0.35) then
			-- creditors take your owned GPUs to cover part of the debt
			local taken = 0
			for id, n in pairs(state.gpus.owned) do
				if id ~= "laptop" and n > 0 then
					local h = Hardware.byId[id]
					local sell = math.ceil(n / 2)
					state.gpus.owned[id] = n - sell
					taken += Hardware.buyPrice(h, year(state)) * sell * 0.4
				end
			end
			if taken > 0 then
				state.cash += taken
				Game.mail(state, "warning", "Creditors", "We took half your GPUs", "You owe too much. We seized half of your own GPUs and sold them for " .. Format.money(taken) .. ".")
			end
		end
	end
	-- investors only call once people use your AI
	local loc = locationOf(state)
	-- bigger and faster growing = more investors, bigger checks, smaller stakes (like real rounds)
	local growth = 0
	local h = state.history
	if #h >= 4 and h[#h - 3].users > 0 then
		growth = math.clamp(state.users / h[#h - 3].users - 1, -0.5, 3)
	end
	local interest = math.clamp(0.08 + math.log10(1 + state.users) / 30 + growth * 0.12, 0.02, 0.6) * loc.investors
	if #state.investors < 3 and state.users > 2000 and rng:NextNumber() < interest then
		local inv = Catalog.investors[rng:NextInteger(1, #Catalog.investors)]
		local v = math.max(state.valuation, 3e6)
		-- round stage by size: seed, A, B/C, growth, mega
		local stage, minD, maxD
		if v < 2.5e7 then
			stage, minD, maxD = "Seed", 0.12, 0.25
		elseif v < 2e8 then
			stage, minD, maxD = "Series A", 0.15, 0.25
		elseif v < 2e9 then
			stage, minD, maxD = "Series B", 0.10, 0.20
		elseif v < 3e10 then
			stage, minD, maxD = "Growth round", 0.05, 0.12
		else
			stage, minD, maxD = "Mega round", 0.02, 0.07
		end
		local markup = rng:NextNumber(0.85, 1.15) * (1 + growth * 0.25) * (best and best.rank == 1 and 1.25 or 1)
		local pre = v * markup
		local dil = rng:NextNumber(minD, maxD)
		local amount = pre * dil / (1 - dil)
		local post = pre + amount
		inv = { name = inv.name, kind = stage .. " | " .. inv.kind, blurb = inv.blurb }
		table.insert(state.investors, { name = inv.name, kind = inv.kind, blurb = inv.blurb, amount = amount, pre = pre, post = post, stake = amount / post, expires = state.day + 60 })
		Game.mail(state, "investor", inv.name, "Term sheet", string.format("We would like to invest %s at a %s pre-money valuation. See Bank.", Format.money(amount), Format.money(pre)))
	end
	for i = #state.investors, 1, -1 do
		if state.day > state.investors[i].expires then
			table.remove(state.investors, i)
		end
	end
	if state.cash < 0 then
		Game.mail(state, "warning", "Finance", "We are out of money", "Cash is negative. Raise money in Bank, cut GPUs or let people go.", {
			{ label = "Emergency bridge loan", fx = { cash = math.max(2e6, state.valuation * 0.05), rep = -3 } },
			{ label = "Ignore", fx = {} },
		})
	end
end

-- ===== snapshot for the client =====
function Game.snapshot(state)
	local y = year(state)
	local models = {}
	for _, m in ipairs(state.models) do
		local flaws = {}
		for k, v in pairs(m.flaws) do
			if m.revealed[k] or k == "safety" or k == "refuse" or m.status == "released" and (k == "halluc" or k == "syco") then
				flaws[k] = v
			end
		end
		table.insert(models, {
			id = m.id, name = m.name, cap = math.floor(m.cap * 10) / 10, predicted = m.predicted, size = m.size,
			status = m.status, users = m.users, features = m.features, context = m.context, elo = m.elo or B.elo(m.cap, m.abilities.writing or 0),
			rank = m.rank, reception = m.reception, benchmarks = m.benchmarks, flaws = flaws, revealed = m.revealed,
			character = m.character, abilities = m.abilities, updating = m.updating, updates = m.updates, open = m.open,
			apiPrice = m.apiPrice, delayUntil = m.delayUntil, serve = m.serve, losses = m.losses, speed = m.speed,
			kind = m.kind or "chat", stats = m.stats, boosting = m.boosting, lastGain = m.lastGain, bannedUntil = m.bannedUntil,
			boostPower = m.stats and Game.boostPower(state, m) or 0, boostStaff = m.stats and Game.boostStaffNeeded(m) or 0,
			boostCost = m.stats and Game.boostCost(state, m) or 0, boostDays = m.stats and Game.boostDays(state, m) or 0,
		})
	end
	local leaderboard = {}
	for labId, lb in pairs(state.world.labBest) do
		table.insert(leaderboard, { lab = Labs.displayName(labId), labId = labId, model = lb.model, cap = lb.cap, elo = B.elo(lb.cap, 3) })
	end
	local best = Game.bestModel(state)
	if best then
		table.insert(leaderboard, { lab = state.company, labId = "you", model = best.name, cap = best.cap, elo = B.elo(best.cap, best.abilities.writing or 0), you = true })
	end
	table.sort(leaderboard, function(a, b)
		return a.elo > b.elo
	end)
	local t = state.training
	return {
		company = state.company, day = state.day, speed = state.speed, cash = state.cash, credits = state.credits,
		valuation = state.valuation, equity = state.equity, users = state.users, brand = state.brand, hype = state.hype,
		reputation = state.reputation, regulator = state.regulator, office = state.office, staff = state.staff,
		people = state.people, candidates = state.candidates, requests = state.requests or {}, search = state.search or {}, partyReady = state.partyReady or 0, teamFactor = Game.teamFactor(state), gpus = state.gpus, research = state.research,
		models = models, product = state.product, history = state.history, month = state.month, lastMonth = state.lastMonth,
		news = state.news, mail = state.mail, chat = state.chat, goals = state.goals, investors = state.investors,
		leaderboard = leaderboard, frontier = state.world.frontier, marketUsers = state.world.marketUsers,
		clusterPower = Game.clusterPower(state), ownedKw = Game.ownedKw(state), algo = Game.algo(state),
		staffFx = Game.staffEffects(state), headcount = Game.headcount(state), year = y,
		training = t and { name = t.name, progress = t.progress, days = t.days, daysLeft = t.daysLeft, losses = t.losses, spikes = t.spikes, cap = t.eval.cap } or nil,
		awayLog = state.awayLog, stats = state.stats,
		launchCosts = Game.launchCosts(state), bestPrice = (Launch.rivalBest(state, state.day) or { priceOut = 10 }).priceOut,
		achievementList = (function()
			local out = {}
			for _, a in ipairs(Game.ACHIEVEMENTS) do
				table.insert(out, { id = a.id, name = a.name, desc = a.desc, reward = a.reward })
			end
			return out
		end)(),
		pc = state.pc or PcParts.default(), pcStock = state.pcStock or {}, pcSupply = (function()
			local have, need = Game.pcSupply(state)
			return { gb = have.gb, gbNeed = need.gb, cool = have.cool, coolNeed = need.cool }
		end)(), decor = state.decor or {}, storage = state.storage or {}, gpuSlots = Game.gpuSlots(state), gpuUsed = Game.gpuUsed(state), kwCap = Game.kwCap(state),
		offers = state.offers or {}, cooldowns = state.cooldowns or {}, meeting = state.meeting, loanRate = Game.loanRate(state, 1e6),
		misuse = state.misuse or 0, resetReady = state.resetReady or 0, resetMoment = (function()
			local live = state.product.activeModel and state.models[state.product.activeModel]
			if live and live.releasedDay and state.day - live.releasedDay <= 14 then
				return "launch"
			elseif state.lastCrisisDay and state.day - state.lastCrisisDay <= 14 then
				return "crisis"
			end
			return nil
		end)(),
		openModels = (function()
			local out = {}
			local rel = state.world.released
			for i = #rel, 1, -1 do
				local r = rel[i]
				if r.open then
					table.insert(out, { idx = i, model = r.model, lab = Labs.displayName(r.lab), cap = r.cap, day = r.day, size = Game.openModelSize(r.cap) })
					if #out >= 30 then
						break
					end
				end
			end
			return out
		end)(),
		taps = state.taps or 0, tapKey = state.tapKey, trendyNext = state.trendyNext,
		searchPlace = state.searchPlace, autoHire = state.autoHire == true, tut = state.tut or 99, earlyKinds = state.earlyKinds or {}, turboUntil = state.turboUntil or 0, website = state.website or { parts = {} }, websiteBonus = Game.websiteBonus(state),
		friendBonus = state.friendBonus or 0, luck = Game.luck(state), events = (function()
			local out = {}
			local now = os.time()
			for id, ends in pairs(Game.worldEvents) do
				if ends > now then
					table.insert(out, { id = id, left = ends - now })
				end
			end
			return out
		end)(),
		perks = state.perks or {}, sideIncome = Game.sideIncome(state), calmUntil = state.calmUntil,
		eraCeiling = Game.eraCeiling(state), achievements = state.achievements or {}, lastAchievement = state.lastAchievement, boxes = #(state.boxes or {}), problems = state.problems or {}, acquired = state.acquired or {}, location = state.location, loans = state.loans, loanLimit = Game.loanLimit(state), gpuCap = Game.gpuCap(state),
	}
end

return Game
