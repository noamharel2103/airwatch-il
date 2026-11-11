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
local rng = Random.new()

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
	Game.mail(state, "Welcome", "You, last night", "The plan", "$30K of savings, one gaming laptop, " .. loc.name:lower() .. ". Train a tiny model in the Lab, ship it, get users. The Bank will lend you money, and once people use your AI, investors will call. ChatGPT already exists. GPT-4 lands in March.")
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
local LAB_OFFSET = { openai = 0, anthropic = -0.5, google = -0.3, meta = -5, xai = -2, mistral = -9, deepseek = -4, qwen = -5, moonshot = -6, zhipu = -8, minimax = -9, microsoft = -10, amazon = -12, cohere = -14, nvidia = -12 }

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
	-- Future: after the real calendar, each lab ships on its cadence.
	if state.day > Labs.LAST_REAL_DAY then
		for _, lab in ipairs(Labs.list) do
			local names = Labs.futureNames[lab.id]
			if names and not (state.acquired and state.acquired[lab.id]) then
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
					local cap = Labs.frontierProjection(state.day) + (LAB_OFFSET[lab.id] or -6) + rng:NextNumber(-2, 2)
					local r = { day = state.day, lab = lab.id, model = name, cap = cap, open = lab.open >= 7, priceOut = lab.open >= 7 and 2 or 20, note = "Rumoured to be trained on a gigawatt cluster", future = true }
					addRelease(state, r)
					Game.newsItem(state, Labs.displayName(lab.id) .. " releases " .. name, "rival")
					w.future[lab.id] = state.day + math.floor(lab.cadence * 30 * rng:NextNumber(0.7, 1.4))
				end
			end
		end
	end
	w.marketUsers = marketUsersM(year(state), state.day)
end

-- ===== helpers =====
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
	return p
end

-- Max H100-equivalents you can secure this year (scarcity in early years).
function Game.gpuCap(state): number
	local y = year(state)
	local base = Config.yearValue(Config.GPU_ALLOCATION, y)
	return math.floor(base * (0.6 + state.reputation / 125) * math.min(2.5, math.sqrt(1 + state.valuation / 2e10)))
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
	return e
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
		if m.status == "released" and (not best or m.cap > best.cap) then
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

local function spend(state, amount, bucket)
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
Game.Actions = Actions

function Actions.setSpeed(state, s)
	if table.find(Config.SPEEDS, s) then
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
		if #state.people < 40 then
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
		local room = math.floor((Game.gpuCap(state) - Game.clusterPower(state)) / h.power)
		if room <= 0 then
			return false, "No cloud provider has more capacity for you this year. Build reputation, raise money or wait for next year's supply."
		end
		n = room
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
	if Game.clusterPower(state) + h.power * n > Game.gpuCap(state) then
		return false, "Nvidia's allocation for you is sold out this year (" .. Format.count(Game.gpuCap(state)) .. " H100-equivalents)."
	end
	local price = Hardware.buyPrice(h, year(state)) * n
	if state.cash < price then
		return false, "Not enough cash"
	end
	local stage = Catalog.officeStages[state.office]
	if Game.ownedKw(state) + h.kw * 1.4 * n > stage.kw then
		return false, string.format("Not enough power. Your %s supports %s kW. Rent in the cloud or upgrade.", stage.name, Format.count(stage.kw))
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
	local got = {}
	for _, b in ipairs(boxes) do
		local bucket = b.kind == "buy" and state.gpus.owned or state.gpus.rented
		bucket[b.id] = (bucket[b.id] or 0) + b.n
		table.insert(got, b.n .. "x " .. Hardware.byId[b.id].name)
	end
	state.boxes = {}
	return true, table.concat(got, ", ")
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
	spend(state, ev.extraCost, "compute")
	local name = tostring(recipe.name or "")
	if #name < 2 then
		name = state.company .. "-" .. (#state.models + 1)
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
		return math.clamp(math.floor(v + 0.5), 1, 100)
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
function Actions.createModel(state, name)
	if state.training then
		return false, "Already training a model"
	end
	local ctx = Game.trainCtx(state)
	if ctx.clusterPower <= 0 then
		return false, "You have no GPUs. Get some in Parts."
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
	return Actions.train(state, recipe)
end

function Game.boostCost(state, m)
	return math.floor(1500 * (1 + m.size) ^ 0.75 * (1 + (year(state) - 2023) * 0.3) / 100) * 100
end

function Game.boostDays(state, m)
	local power = math.max(Game.clusterPower(state), 0.01)
	return math.clamp(math.ceil(4 * (m.size / 7) ^ 0.6 / power ^ 0.35), 3, 30)
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
	if not (m.stats[a] and m.stats[b]) or a == b then
		return false, "Pick 2 different stats"
	end
	local cost = Game.boostCost(state, m)
	if state.cash < cost then
		return false, "Not enough cash (" .. Format.money(cost) .. ")"
	end
	spend(state, cost, "compute")
	m.boosting = { a = a, b = b, doneDay = state.day + Game.boostDays(state, m), startDay = state.day }
	return true
end

local function finishBoost(state, m)
	local bst = m.boosting
	m.boosting = nil
	local fx = Game.staffEffects(state)
	local gains = {}
	for _, k in ipairs({ bst.a, bst.b }) do
		local room = 1 - m.stats[k] / 110
		local g = math.max(1, math.floor((5 + rng:NextNumber(0, 6) + math.log(1 + fx.research) * 1.5) * room + 0.5))
		m.stats[k] = math.min(100, m.stats[k] + g)
		table.insert(gains, "+" .. g .. " " .. k:sub(1, 1):upper() .. k:sub(2))
	end
	Game.applyStats(m)
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

function Actions.setActive(state, modelId)
	local m = state.models[modelId]
	if not m or m.status ~= "released" then
		return false, "Release it first"
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
	return math.max(0, Config.LOAN_BASE_LIMIT + arr * 0.5 + state.valuation * 0.05 - owed)
end

function Actions.takeLoan(state, amount)
	amount = math.floor(tonumber(amount) or 0)
	if amount <= 0 then
		return false, "Pick an amount"
	end
	if amount > Game.loanLimit(state) then
		return false, "The bank says no. Your limit is " .. Format.money(Game.loanLimit(state))
	end
	local monthlyRate = Config.LOAN_RATE_YEAR / 12
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

function Actions.acquire(state, labId, withStock)
	local lab = Labs.byId[labId]
	state.acquired = state.acquired or {}
	if not lab or state.acquired[labId] then
		return false, "Not for sale"
	end
	local cost = Game.acquireCost(state, labId)
	if state.valuation < cost * 1.5 then
		return false, "They laugh at your offer. You need to be worth at least " .. Format.money(cost * 1.5) .. "."
	end
	if withStock then
		local dilution = cost / (state.valuation + cost)
		state.equity *= (1 - dilution)
	else
		if state.cash < cost then
			return false, "Not enough cash. Try paying with stock."
		end
		spend(state, cost, "office")
	end
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
	{ id = "outage", w = 2, cond = function(s)
		return s.users > 5000
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
		t.progress = math.min(1, t.progress + step)
		t.elapsed += 1
		t.daysLeft = (1 - t.progress) / math.max(step, 1e-9)
		table.insert(t.losses, TM.lossAt(t.progress, t.actualCap, t.seed))
		if #t.losses > 120 then
			table.remove(t.losses, 1)
		end
		-- run failures: more likely at high speed
		local risk = Config.RISK_BY_SPEED[state.speed] or 1
		local failChance = t.eval.risk / math.max(t.days, 5) * risk / (1 + fx.infra * 0.3)
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
		rivalAttr += (lab and lab.brand or 0.5) * math.exp((lb.cap - F) / 6)
	end
	local revenue, inference = 0, 0
	if active then
		local feats = 0
		for _ in pairs(active.features) do
			feats += 1
		end
		local quality = (1 + 0.12 * math.log(1 + fx.product)) * (1 + feats * 0.05)
		local priceF = (20 / math.max(state.product.subPrice, 1)) ^ 0.25
		local attr = (state.brand + state.users / 5e8) * math.exp((active.cap - F) / 6) * quality * priceF * (1 + state.reputation / 200)
		local share = attr / (attr + rivalAttr)
		local target = state.world.marketUsers * 1e6 * share
		local rate = target > state.users and 0.03 or 0.012
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
		local quality = math.exp((active.cap - F) / 10)
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
	local office = Catalog.officeStages[state.office].rent / 30 * loc.rent
	state.cash += revenue
	state.month.revenue += revenue
	spend(state, salaries, "salaries")
	spend(state, rent - fromCredits + power, "compute")
	spend(state, office, "office")
	spend(state, inference, "inference")

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
		local interest = l.left * Config.LOAN_RATE_YEAR / 12
		local pay = math.min(l.payment, l.left + interest)
		state.cash -= pay
		state.month.costs += pay
		l.left = math.max(0, l.left + interest - pay)
		l.months -= 1
		if l.left <= 1 or l.months <= 0 then
			table.remove(state.loans, i)
		end
	end
	-- investors only call once people use your AI
	local loc = locationOf(state)
	if #state.investors < 2 and state.users > 2000 and rng:NextNumber() < 0.3 * loc.investors then
		local inv = Catalog.investors[rng:NextInteger(1, #Catalog.investors)]
		local markup = rng:NextNumber(0.9, 1.25) * (best and best.rank == 1 and 1.3 or 1)
		local pre = state.valuation * markup
		local amount = pre * rng:NextNumber(0.08, 0.22)
		local post = pre + amount
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
			stats = m.stats, boosting = m.boosting, lastGain = m.lastGain,
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
		people = state.people, candidates = state.candidates, gpus = state.gpus, research = state.research,
		models = models, product = state.product, history = state.history, month = state.month, lastMonth = state.lastMonth,
		news = state.news, mail = state.mail, chat = state.chat, goals = state.goals, investors = state.investors,
		leaderboard = leaderboard, frontier = state.world.frontier, marketUsers = state.world.marketUsers,
		clusterPower = Game.clusterPower(state), ownedKw = Game.ownedKw(state), algo = Game.algo(state),
		staffFx = Game.staffEffects(state), headcount = Game.headcount(state), year = y,
		training = t and { name = t.name, progress = t.progress, days = t.days, daysLeft = t.daysLeft, losses = t.losses, spikes = t.spikes, cap = t.eval.cap } or nil,
		awayLog = state.awayLog, stats = state.stats,
		launchCosts = Game.launchCosts(state), bestPrice = (Launch.rivalBest(state, state.day) or { priceOut = 10 }).priceOut,
		boxes = #(state.boxes or {}), acquired = state.acquired or {}, location = state.location, loans = state.loans, loanLimit = Game.loanLimit(state), gpuCap = Game.gpuCap(state),
	}
end

return Game
