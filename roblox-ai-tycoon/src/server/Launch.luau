--!strict
-- Builds the launch reaction: benchmarks vs rivals, tags, a timed feed of posts, press, and effects.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS:WaitForChild("Shared")
local Labs = require(Shared.Labs)
local B = require(Shared.Benchmarks)
local RT = require(Shared.ReactionTemplates)
local IT = require(Shared.IncidentTemplates)
local Format = require(Shared.Format)

local Launch = {}
local rng = Random.new()

local parsed = {}
for persona, block in pairs(RT.lines) do
	parsed[persona] = RT.parse(block)
end
local incident = {}
for persona, block in pairs(IT.lines) do
	incident[persona] = RT.parse(block)
end
local redditTitles = RT.parse(RT.reddit)
local hnTitles = RT.parse(RT.hnTitles)

local function fill(text: string, v: { [string]: any }): string
	return (text:gsub("{(%w+)}", function(k)
		local x = v[k]
		if x == nil then
			return "{" .. k .. "}"
		end
		return tostring(x)
	end))
end

local function pick(list)
	return list[rng:NextInteger(1, #list)]
end

local function eligible(lines, tags)
	local out = {}
	for _, l in ipairs(lines) do
		if l.tags.ANY then
			table.insert(out, { l = l, w = 1 })
		else
			local w = 0
			for t in pairs(l.tags) do
				if tags[t] then
					w += 3 * tags[t]
				end
			end
			if w > 0 then
				table.insert(out, { l = l, w = w })
			end
		end
	end
	return out
end

local function weighted(items)
	local total = 0
	for _, it in ipairs(items) do
		total += it.w
	end
	if total <= 0 then
		return nil
	end
	local r = rng:NextNumber() * total
	for _, it in ipairs(items) do
		r -= it.w
		if r <= 0 then
			return it.l
		end
	end
	return items[#items].l
end

-- Best rival model (by cap) released before `day`, excluding none.
function Launch.rivalBest(state, day)
	local best
	for _, r in ipairs(state.world.released) do
		if not best or r.cap > best.cap then
			best = r
		end
	end
	return best
end

-- Compute benchmark table for a model.
function Launch.benchmarks(model, state)
	local out = {}
	local rb = Launch.rivalBest(state, state.day)
	for _, b in ipairs(B.active(state.day)) do
		local mine = B.score(b, model.abilities, model.cap)
		if b.domain == "vision" and not model.features.vision then
			mine = 0
		end
		local theirs = rb and B.score(b, { [b.domain] = 3 }, rb.cap) or 0
		table.insert(out, { id = b.id, name = b.name, score = math.floor(mine * 10) / 10, sota = math.floor(theirs * 10) / 10, sotaModel = rb and rb.model or "-" })
	end
	return out
end

-- personas and how many posts each gets, by reach of the launch
local MIX = {
	{ "hype", 4 }, { "researcher", 3 }, { "skeptic", 3 }, { "dev", 4 }, { "memer", 5 }, { "nerd", 2 }, { "tinkerer", 3 },
	{ "safety", 2 }, { "vc", 2 }, { "poweruser", 2 }, { "rivalemp", 1 }, { "fanboy", 2 }, { "student", 3 }, { "intl", 1 },
	{ "purist", 1 }, { "vibecoder", 2 }, { "doomer", 1 }, { "insider", 1 }, { "cto", 2 }, { "hn", 2 },
}

local function likesFor(followers, mood)
	local rate = rng:NextNumber(0.005, 0.03) * (followers > 2e5 and 0.5 or 1)
	local v = followers * rate * mood
	if rng:NextNumber() < 0.025 then
		v *= rng:NextNumber(10, 50) -- viral
	end
	return math.floor(v)
end

local function makePost(persona, text, hour, mood, extra)
	local p = RT.personas[persona]
	local followers = math.floor(rng:NextNumber(p.followers[1], p.followers[2]))
	local likes = likesFor(followers, mood)
	local post = {
		persona = persona,
		personaName = p.name,
		platform = p.platform,
		handle = pick(p.handles),
		followers = followers,
		text = text,
		hour = hour,
		likes = likes,
		replies = math.floor(likes * rng:NextNumber(0.05, 0.15)),
		reposts = math.floor(likes * rng:NextNumber(0.1, 0.3)),
	}
	if extra then
		for k, v in pairs(extra) do
			post[k] = v
		end
	end
	return post
end

-- Main entry. opts = { price=, open=bool, campaign=0..3, reviewers=bool }
function Launch.run(state, model, opts)
	local frontier = state.world.frontier
	local rb = Launch.rivalBest(state, state.day)
	local bench = Launch.benchmarks(model, state)
	local gap = model.cap - frontier
	local tags = {} :: { [string]: number }
	local why = {}

	local sotaBench, sotaDelta = nil, 0
	for _, b in ipairs(bench) do
		local d = b.score - b.sota
		if d > sotaDelta then
			sotaBench, sotaDelta = b, d
		end
	end
	if sotaBench then
		tags.SOTA = 1
		table.insert(why, string.format("New state of the art on %s (+%.1f)", sotaBench.name, sotaDelta))
		if sotaDelta > 5 then
			tags.BIG_JUMP = 1
		end
	end
	local elo = B.elo(model.cap, model.abilities.writing or 0)
	model.elo = elo
	-- arena rank
	local rank = 1
	for _, r in ipairs(state.world.released) do
		if B.elo(r.cap, 3) > elo then
			rank += 1
		end
	end
	if rank > 30 then
		rank = 30 + rng:NextInteger(0, 40)
	end
	model.rank = rank
	if rank == 1 then
		tags.ARENA_KING = 1
		table.insert(why, "Number one on the Arena")
	end

	local refPrice = rb and rb.priceOut or 10
	if refPrice <= 0 then
		refPrice = 10
	end
	local priceRatio = opts.price / refPrice
	if priceRatio < 0.35 and gap > -12 then
		tags.VALUE_KING = 1
		table.insert(why, string.format("Developers loved the price (%d%% below %s)", math.floor((1 - priceRatio) * 100), rb and rb.model or "rivals"))
	elseif priceRatio > 2 and gap < 1 then
		tags.OVERPRICED = 1
		table.insert(why, "Priced above the frontier without beating it")
	end
	if opts.open then
		if gap > -15 then
			tags.OPEN_HERO = 1
			table.insert(why, "Open weights near the frontier: the community celebrated")
		end
		if model.size <= 34 then
			tags.RUNS_LOCAL = 1
		end
	else
		tags.CLOSED = 0.3
	end
	local hype = state.hype + (model.hype or 0) + opts.campaign * 12
	if hype > 45 and gap < -8 then
		tags.OVERHYPED = 1
		tags.FLOP = 0.8
		table.insert(why, "Big hype, average model: people felt let down")
	elseif hype < 20 and gap > -3 then
		tags.SLEEPER_HIT = 1
		table.insert(why, "Quiet launch, strong scores: a sleeper hit")
	elseif gap < -15 then
		tags.FLOP = 0.6
	end
	local fl = model.flaws
	if fl.refuse > 0.3 then
		tags.PREACHY = 1
		table.insert(why, "Refuses too much: power users complained")
	end
	if fl.halluc > 0.35 then
		tags.HALLUCINATES = 1
		table.insert(why, "Makes things up too often")
	end
	if fl.syco > 0.3 then
		tags.GLAZING = 1
		table.insert(why, "Too eager to please")
	end
	if (model.abilities.coding or 0) > 6 and gap > -6 then
		tags.CODER = 1
	end
	if model.features.reasoning then
		tags.REASONING = 0.7
	end
	if model.features.vision then
		tags.VISION = 0.5
	end
	if model.features.voice then
		tags.VOICE = 0.7
	end
	if model.features.imagegen then
		tags.IMAGEGEN = 1
	end
	if model.features.agents or model.features.computer then
		tags.AGENTS = 0.8
	end
	if model.context >= 1e6 then
		tags.LONG_CONTEXT = 0.8
	end
	if (model.abilities.multilingual or 0) > 5 then
		tags.MULTILINGUAL = 0.6
	elseif (model.abilities.multilingual or 0) < -2 then
		tags.NOT_MULTILINGUAL = 0.4
	end
	if model.character == "edgy" then
		tags.UNSAFE_EDGY = 1
	end
	if model.systemCard then
		tags.SAFE_CARD = 0.8
	else
		tags.NO_CARD = 0.5
	end
	if #state.models <= 1 or state.launches == 0 then
		tags.NEWCOMER = 1
	end
	if #model.name > 22 or model.name:find("%-.*%-.*%-") then
		tags.NAMING = 1
	end
	-- timing vs rivals
	local lastRival = state.world.released[#state.world.released]
	if lastRival then
		local dd = state.day - lastRival.day
		if dd <= 0 then
			tags.COLLISION = 1
			table.insert(why, lastRival.model .. " launched the same day and split attention")
		elseif dd <= 3 then
			tags.CLAPBACK = 1
		end
	end
	-- previous own model regression
	local prev = state.models[#state.models - 1]
	if prev and prev.status == "released" and prev.cap > model.cap + 3 then
		tags.NERFED = 1
	end
	-- demand > capacity
	local demand = math.max(0, gap + 20) * (1 + hype / 40)
	local capacity = 20 + 8 * (state.staff.infra or 0) + (opts.reserve and 25 or 0)
	local meltdown = demand > capacity and rng:NextNumber() < 0.75
	if meltdown then
		tags.MELTDOWN = 1
		table.insert(why, "Servers melted under demand: some signups lost")
	end
	-- jailbreak (day 0-1)
	local jailbroken = rng:NextNumber() < fl.jailbreak
	if jailbroken then
		tags.JAILBROKEN = 1
	end
	if fl.syco < 0.15 and fl.halluc < 0.2 and not tags.PREACHY then
		tags.GOOD_VIBES = 0.7
	end
	if model.character == "witty" or model.character == "warm" then
		tags.GOOD_VIBES = (tags.GOOD_VIBES or 0) + 0.4
	end

	-- Sentiment
	local s = 50 + gap * 2.2
	s += (tags.SOTA and 8 or 0) + (tags.BIG_JUMP and 6 or 0) + (tags.ARENA_KING and 8 or 0) + (tags.VALUE_KING and 10 or 0)
	s += (tags.OPEN_HERO and 9 or 0) + (tags.SLEEPER_HIT and 5 or 0) + (tags.GOOD_VIBES and 4 or 0)
	s -= (tags.OVERPRICED and 10 or 0) + (tags.OVERHYPED and 14 or 0) + (tags.PREACHY and 6 or 0) + (tags.HALLUCINATES and 6 or 0)
	s -= (tags.MELTDOWN and 4 or 0) + (tags.JAILBROKEN and 5 or 0) + (tags.GLAZING and 4 or 0) + (tags.NERFED and 8 or 0)
	s += opts.reviewers and 5 or 0
	-- nobody cares about a model that is not better than the one you shipped last month
	local yourBest = 0
	for _, m2 in ipairs(state.models) do
		if m2 ~= model and m2.status == "released" and m2.cap > yourBest then
			yourBest = m2.cap
		end
	end
	if yourBest > 0 and model.cap < yourBest + 1 then
		s -= 18
		table.insert(why, "Not better than your previous model: people shrugged")
	end
	s += rng:NextNumber(-4, 4)
	local score = math.clamp(math.floor(s), 3, 99)
	model.reception = score
	if #why == 0 then
		table.insert(why, gap > -5 and "Solid model at a fair price" or "Behind the frontier, so few people noticed")
	end

	-- Variables for templates
	local rival = rb and Labs.displayName(rb.lab) or "OpenAI"
	local vars = {
		model = model.name,
		lab = state.company,
		bench = sotaBench and sotaBench.name or (bench[1] and bench[1].name or "MMLU"),
		score = sotaBench and string.format("%.1f", sotaBench.score) or (bench[1] and string.format("%.1f", bench[1].score) or "0"),
		delta = string.format("%.1f", math.max(sotaDelta, rng:NextNumber(1, 4))),
		rival = rival,
		rivalModel = rb and rb.model or "GPT-4",
		price = string.format("%.2f", opts.price),
		pricePct = tostring(math.max(5, math.floor((1 - math.min(priceRatio, 0.95)) * 100))),
		tps = tostring(math.floor(40 * (model.speed or 1) * (opts.open and 0.8 or 1.5))),
		ctx = model.context >= 1e6 and (math.floor(model.context / 1e6) .. "M") or (math.floor(model.context / 1e3) .. "K"),
		size = (model.size >= 1000 and string.format("%.1fT", model.size / 1000) or (model.size .. "B")),
		year = select(1, Format.dateFromDay(state.day)),
		nextYear = select(1, Format.dateFromDay(state.day)) + 1,
		elo = tostring(elo),
		rank = tostring(rank),
	}

	-- Build feed
	local posts = {}
	local mood = 0.6 + score / 60
	local reach = math.clamp(0.4 + (score / 100) + hype / 100 + math.log10(1 + state.users) / 12, 0.4, 2.2)
	local hourByPersona = { hype = 0.2, memer = 1, researcher = 3, dev = 2, skeptic = 4, tinkerer = 5, nerd = 18, safety = 8, journalist = 6, vc = 2 }
	for _, mx in ipairs(MIX) do
		local persona, n = mx[1], math.max(1, math.floor(mx[2] * reach + 0.5))
		local lines = parsed[persona]
		if lines then
			local used = {}
			for _ = 1, n do
				local cands = eligible(lines, tags)
				local l = weighted(cands)
				if l and not used[l] then
					used[l] = true
					local h = (hourByPersona[persona] or 6) * rng:NextNumber(0.3, 3)
					local personaMood = mood
					if persona == "skeptic" or persona == "fanboy" then
						personaMood = 1.6 - mood * 0.5
					end
					table.insert(posts, makePost(persona, fill(l.text, vars), h, personaMood))
				end
			end
		end
	end
	-- Press headlines
	local press = {}
	local pl = eligible(parsed.journalist, tags)
	local usedHead = {}
	for _ = 1, math.clamp(math.floor(2 + reach * 2), 2, 5) do
		local l = weighted(pl)
		if l and not usedHead[l] then
			usedHead[l] = true
			local outlet = pick(RT.personas.journalist.handles)
			table.insert(press, { outlet = outlet, headline = fill(l.text, vars), hour = rng:NextNumber(2, 30) })
		end
	end
	-- Reddit + HN threads
	local threads = {}
	local usedThread = {}
	for _ = 1, 4 do
		local l = weighted(eligible(redditTitles, tags))
		if l and not usedThread[l] then
			usedThread[l] = true
			table.insert(threads, { platform = "reddit", sub = pick({ "r/LocalLLaMA", "r/singularity", "r/ChatGPT", "r/MachineLearning", "r/artificial" }), title = fill(l.text, vars), upvotes = math.floor(rng:NextNumber(200, 6000) * mood * reach), comments = rng:NextInteger(40, 1400) })
		end
	end
	local hl = weighted(eligible(hnTitles, tags))
	if hl then
		table.insert(threads, { platform = "hn", title = fill(hl.text, vars), upvotes = math.floor(rng:NextNumber(80, 1500) * reach), comments = rng:NextInteger(30, 700) })
	end
	-- Community note on the most-liked hype post if contamination or overhype
	if tags.OVERHYPED or (tags.BIG_JUMP and fl.contam > 0.3) then
		for _, p in ipairs(posts) do
			if p.persona == "hype" then
				p.note = fill(pick(RT.communityNotes), vars)
				break
			end
		end
	end
	-- Ratio: a hype post getting dunked on
	if score < 45 then
		for _, p in ipairs(posts) do
			if p.persona == "hype" then
				p.ratioed = true
				p.replies = p.likes * 2
				break
			end
		end
	end
	-- Critic reviews with scores (out of 10)
	local OUTLETS = { "TechWire", "The Verge-ish", "AI Weekly", "Silicon Daily", "ModelWatch", "ByteReview" }
	local GOOD = { "The best {model} moments feel like magic.", "Fast, smart and surprisingly funny.", "{lab} is now a serious player.", "A must-try for developers.", "Quietly excellent." }
	local MID = { "Good, not great. Wait for the next version.", "Solid basics, nothing new.", "Fine for homework, shaky for work.", "Promising, but {rivalModel} is still ahead." }
	local BAD = { "Confidently wrong too often.", "Feels a year behind.", "Hard to recommend at this price.", "Skip this one." }
	local reviews = {}
	local usedOutlet = {}
	for _ = 1, 4 do
		local o = pick(OUTLETS)
		if not usedOutlet[o] then
			usedOutlet[o] = true
			local sc = math.clamp(score / 10 + rng:NextNumber(-1.2, 1.2), 1, 10)
			local pool = sc >= 7.5 and GOOD or (sc >= 5 and MID or BAD)
			table.insert(reviews, { outlet = o, score = math.floor(sc * 10) / 10, quote = fill(pick(pool), vars) })
		end
	end
	-- YouTube videos
	local YT = {
		{ "{model} is INSANE (I tested it for 24 hours)", 0.9 },
		{ "I let {model} run my life for a week", 0.8 },
		{ "{model} vs {rivalModel}: the honest truth", 0.7 },
		{ "Is {lab} the next OpenAI?", 0.6 },
		{ "{model} FAILED my test (watch till the end)", 0.4 },
		{ "Why everyone is wrong about {model}", 0.5 },
		{ "I built a game with {model} in 10 minutes", 0.8 },
	}
	local CHANNELS = { "TechWithTim-ish", "AI Explained-ish", "Fireship-ish", "MKBHD-ish", "Two Minute Papers-ish", "a 14 year old with 3M subs" }
	local videos = {}
	for i = 1, math.clamp(math.floor(1 + reach * 2), 1, 4) do
		local t = YT[rng:NextInteger(1, #YT)]
		table.insert(videos, { channel = CHANNELS[rng:NextInteger(1, #CHANNELS)], title = fill(t[1], vars), views = math.floor(rng:NextNumber(2e4, 2e6) * reach * t[2] * (score / 60)) })
	end

	table.sort(posts, function(a, b)
		return a.hour < b.hour
	end)
	local official = makePost("hype", fill(pick(RT.official), vars), 0, mood)
	official.handle = state.company
	official.personaName = state.company
	official.official = true
	official.followers = math.floor(2000 + state.users * 0.02 + state.brand * 1e5)
	table.insert(posts, 1, official)

	-- Scheduled follow-ups (days after launch)
	local followups = {}
	if jailbroken then
		table.insert(followups, { day = state.day + rng:NextInteger(0, 1), kind = "JAILBREAK" })
	end
	if (tags.SOTA or tags.BIG_JUMP) and rng:NextNumber() < fl.contam then
		table.insert(followups, { day = state.day + rng:NextInteger(2, 6), kind = "CONTAMINATION" })
	end
	if fl.escape > 0 and rng:NextNumber() < fl.escape then
		table.insert(followups, { day = state.day + rng:NextInteger(3, 20), kind = "ESCAPE" })
	end

	-- Effects
	-- even a weak first model gets some curious hobbyists
	local userBoost = math.max(0.08, (score - 30) / 70) * reach
	local eff = {
		signups = math.floor((5e3 + math.min(state.users * 0.15, 2e7) + (state.world.marketUsers * 1e6) * 0.004 * math.exp(math.min(gap, 6) / 6)) * userBoost * (meltdown and 0.6 or 1)),
		brand = (score - 50) / 600 + 0.01 * reach,
		hype = (tags.IMAGEGEN or tags.VOICE) and 10 or (score > 70 and 6 or -4),
		reputation = (score - 50) / 5,
		regulator = (jailbroken and 6 or 0) + (tags.UNSAFE_EDGY and 8 or 0) + (tags.NO_CARD and 2 or 0),
		openRep = tags.OPEN_HERO and 10 or 0,
	}
	return {
		modelName = model.name,
		modelId = model.id,
		benchmarks = bench,
		elo = elo,
		rank = rank,
		score = score,
		why = why,
		tags = tags,
		posts = posts,
		press = press,
		threads = threads,
		reviews = reviews,
		videos = videos,
		followups = followups,
		effects = eff,
		vars = vars,
		meltdown = meltdown,
		jailbroken = jailbroken,
	}
end

-- Small burst of posts for an incident (delay, jailbreak, escape, outage, patch, rollback, leak...)
function Launch.incident(state, kind: string, modelName: string)
	local rb = Launch.rivalBest(state, state.day)
	local vars = {
		model = modelName,
		lab = state.company,
		rival = rb and Labs.displayName(rb.lab) or "OpenAI",
		rivalModel = rb and rb.model or "GPT-4",
		year = select(1, Format.dateFromDay(state.day)),
		bench = "the benchmark",
		delta = "6",
	}
	local tags = { [kind] = 1 }
	local posts, press = {}, nil
	for persona, lines in pairs(incident) do
		local cands = {}
		for _, l in ipairs(lines) do
			if l.tags[kind] then
				table.insert(cands, l)
			end
		end
		if #cands > 0 then
			local l = pick(cands)
			if persona == "journalist" then
				press = { outlet = pick(RT.personas.journalist.handles), headline = fill(l.text, vars) }
			else
				table.insert(posts, makePost(persona, fill(l.text, vars), rng:NextNumber(0, 12), 1))
			end
		end
	end
	-- also launch-bank lines tagged with this kind (e.g. CONTAMINATION, JAILBROKEN)
	local alias = { JAILBREAK = "JAILBROKEN", CONTAMINATION = "CONTAMINATION" }
	if alias[kind] then
		for persona, lines in pairs(parsed) do
			for _, l in ipairs(lines) do
				if l.tags[alias[kind]] and rng:NextNumber() < 0.5 then
					table.insert(posts, makePost(persona, fill(l.text, vars), rng:NextNumber(0, 24), 1))
					break
				end
			end
		end
	end
	table.sort(posts, function(a, b)
		return a.hour < b.hour
	end)
	local chat = IT.staffChat[kind] and fill(pick(IT.staffChat[kind]), vars) or nil
	return { kind = kind, posts = posts, press = press, chat = chat, model = modelName }
end

return Launch
