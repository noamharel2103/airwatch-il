--!strict
-- Builds the launch reaction: benchmarks vs rivals, tags, a timed feed of posts, press, and effects.
-- Scale: the launch tier (gap to the world frontier, guarded by the score) decides how loud the world gets.
-- Chaos: from 1 billion users everyone piles in; from 5 billion it is the whole planet.
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
local chaosBank = {}
for persona, block in pairs(RT.chaos) do
	chaosBank[persona] = RT.parse(block)
end
local redditTitles = RT.parse(RT.reddit)
local hnTitles = RT.parse(RT.hnTitles)

-- Knobs per launch tier. Bad launches get almost nothing, great ones get a flood.
local TIER_VOLUME: { [string]: number } = { insane = 2.0, great = 1.5, ok = 1, meh = 0.4, flop = 0.15 }
local TIER_HOT: { [string]: number } = { insane = 4, great = 2, ok = 1, meh = 0.5, flop = 0.2 }
local TIER_PRESS: { [string]: number } = { insane = 9, great = 5, ok = 3, meh = 2, flop = 1 }
local TIER_REDDIT: { [string]: number } = { insane = 9, great = 6, ok = 4, meh = 2, flop = 1 }
local TIER_HN: { [string]: number } = { insane = 3, great = 2, ok = 1, meh = 1, flop = 0 }
local TIER_REVIEWS: { [string]: number } = { insane = 6, great = 4, ok = 3, meh = 2, flop = 1 }
local TIER_VIDEOS: { [string]: number } = { insane = 7, great = 4, ok = 2, meh = 1, flop = 0 }
local TIER_VIEWS: { [string]: number } = { insane = 30, great = 4, ok = 1, meh = 0.5, flop = 0.5 }
local TIER_SIGNUP: { [string]: number } = { insane = 1.8, great = 1.25, ok = 1, meh = 0.6, flop = 0.4 }
local TIER_WAITLIST: { [string]: number } = { insane = 6, great = 2, ok = 0.8, meh = 0.3, flop = 0.05 }

-- Personas and how many posts each gets, by reach of the launch
local MIX = {
	{ "hype", 4 }, { "researcher", 3 }, { "skeptic", 3 }, { "dev", 4 }, { "memer", 5 }, { "nerd", 2 }, { "tinkerer", 3 },
	{ "safety", 2 }, { "vc", 2 }, { "poweruser", 2 }, { "rivalemp", 1 }, { "fanboy", 2 }, { "student", 3 }, { "intl", 1 },
	{ "purist", 1 }, { "vibecoder", 2 }, { "doomer", 1 }, { "insider", 1 }, { "cto", 2 }, { "hn", 2 },
}

-- Extra voices that only show up once the company has billions of users.
local CHAOS_MIX = {
	{ "celeb", 3 }, { "leader", 3 }, { "hype", 3 }, { "memer", 4 }, { "vibecoder", 3 }, { "student", 3 },
	{ "dev", 3 }, { "intl", 3 }, { "insider", 2 }, { "doomer", 2 }, { "rivalemp", 2 }, { "poweruser", 2 },
}

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

-- Up to `count` different lines from a bank, weighted by the launch tags.
local function pickMany(lines, tags, count: number)
	local out = {}
	local pool = eligible(lines, tags)
	if #pool == 0 or count <= 0 then
		return out
	end
	local used = {}
	for _ = 1, count * 4 do
		if #out >= count then
			break
		end
		local l = weighted(pool)
		if l and not used[l] then
			used[l] = true
			table.insert(out, l)
		end
	end
	return out
end

-- 0 = normal, 1 = billions of users, 2 = five billion or more (the whole planet).
function Launch.chaosLevel(users: number): number
	if users >= 5e9 then
		return 2
	elseif users >= 1e9 then
		return 1
	end
	return 0
end

-- Launch tier: how far the model sits above the world frontier, guarded by the score.
function Launch.tierOf(gap: number, score: number): string
	if gap >= 7 and score >= 70 then
		return "insane"
	elseif score < 25 or gap < -12 then
		return "flop"
	elseif gap >= 1 then
		return "great"
	elseif gap >= -6 then
		return "ok"
	end
	return "meh"
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
	local chaos = Launch.chaosLevel(state.users)
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
		table.insert(why, "Number one on the leaderboard")
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
	-- demand > capacity. Billions of users multiply demand far past any server room.
	local demand = math.max(0, gap + 20) * (1 + hype / 40) * (1 + 1.5 * chaos)
	local capacity = 20 + 8 * (state.staff.infra or 0) + (opts.reserve and 25 or 0)
	local meltdown = demand > capacity and rng:NextNumber() < (chaos > 0 and 0.92 or 0.75)
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
	if chaos > 0 then
		tags.CHAOS = chaos
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
	local tier = Launch.tierOf(gap, score)
	tags["TIER_" .. tier:upper()] = 1
	if tier == "insane" then
		table.insert(why, string.format("Far ahead of the world frontier (+%d cap)", math.floor(gap)))
	end
	if #why == 0 then
		table.insert(why, gap > -5 and "Solid model at a fair price" or "Behind the frontier, so few people noticed")
	end

	-- Variables for templates
	local rival = rb and Labs.displayName(rb.lab) or "Vaultmind"
	local vars = {
		model = model.name,
		lab = state.company,
		bench = sotaBench and sotaBench.name or (bench[1] and bench[1].name or "the main test"),
		score = sotaBench and string.format("%.1f", sotaBench.score) or (bench[1] and string.format("%.1f", bench[1].score) or "0"),
		delta = string.format("%.1f", math.max(sotaDelta, rng:NextNumber(1, 4))),
		rival = rival,
		rivalModel = rb and rb.model or "Beacon 4",
		price = string.format("%.2f", opts.price),
		pricePct = tostring(math.max(5, math.floor((1 - math.min(priceRatio, 0.95)) * 100))),
		tps = tostring(math.floor(40 * (model.speed or 1) * (opts.open and 0.8 or 1.5))),
		ctx = model.context >= 1e6 and (math.floor(model.context / 1e6) .. "M") or (math.floor(model.context / 1e3) .. "K"),
		size = (model.size >= 1000 and string.format("%.1fT", model.size / 1000) or (model.size .. "B")),
		year = select(1, Format.dateFromDay(state.day)),
		nextYear = select(1, Format.dateFromDay(state.day)) + 1,
		elo = tostring(elo),
		rank = tostring(rank),
		users = Format.count(state.users),
		waitlist = Format.count(math.floor(2e6 * TIER_WAITLIST[tier] * rng:NextNumber(0.7, 1.3) * (chaos == 2 and 40 or (chaos == 1 and 12 or 1)))),
	}

	-- Feed: how many posts each persona writes scales with reach, tier and chaos
	local posts = {}
	local mood = 0.6 + score / 60
	local reach = math.clamp(0.4 + (score / 100) + hype / 100 + math.log10(1 + state.users) / 12, 0.4, 2.2)
	local volume = TIER_VOLUME[tier] * (1 + 0.6 * chaos)
	local hourByPersona = { hype = 0.2, memer = 1, researcher = 3, dev = 2, skeptic = 4, tinkerer = 5, nerd = 18, safety = 8, journalist = 6, vc = 2 }
	local function feedPosts(mix, mult: number)
		for _, mx in ipairs(mix) do
			local persona = mx[1]
			-- stochastic rounding so small tiers still get the odd post
			local n = math.floor(mx[2] * reach * mult + rng:NextNumber())
			local lines = parsed[persona]
			if lines and n > 0 then
				local personaMood = mood
				if persona == "skeptic" or persona == "fanboy" then
					personaMood = 1.6 - mood * 0.5
				end
				for _, l in ipairs(pickMany(lines, tags, n)) do
					local h = (hourByPersona[persona] or 6) * rng:NextNumber(0.3, 3)
					table.insert(posts, makePost(persona, fill(l.text, vars), h, personaMood))
				end
			end
		end
	end
	feedPosts(MIX, volume)
	if chaos > 0 then
		feedPosts(CHAOS_MIX, chaos == 2 and 2.2 or 1.2)
	end

	-- Press headlines
	local press = {}
	local pressN = TIER_PRESS[tier] + 3 * chaos
	for _, l in ipairs(pickMany(parsed.journalist, tags, pressN)) do
		table.insert(press, { outlet = pick(RT.personas.journalist.handles), headline = fill(l.text, vars), hour = rng:NextNumber(2, 30) })
	end

	-- Reddit + HN threads
	local threads = {}
	local hot = TIER_HOT[tier] * (1 + chaos)
	local subs = { "r/localmodels", "r/singularity", "r/chatbots", "r/researchnotes", "r/artificial", "r/technology", "r/worldnews" }
	for _, l in ipairs(pickMany(redditTitles, tags, TIER_REDDIT[tier] + 3 * chaos)) do
		table.insert(threads, { platform = "reddit", sub = pick(subs), title = fill(l.text, vars), upvotes = math.floor(rng:NextNumber(200, 6000) * mood * reach * hot), comments = math.floor(rng:NextInteger(40, 1400) * hot) })
	end
	for _, l in ipairs(pickMany(hnTitles, tags, TIER_HN[tier] + chaos)) do
		table.insert(threads, { platform = "hn", title = fill(l.text, vars), upvotes = math.floor(rng:NextNumber(80, 1500) * reach * hot), comments = math.floor(rng:NextInteger(30, 700) * hot) })
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

	-- Critic reviews with scores (out of 10). More outlets and better quotes as the launch gets bigger.
	local OUTLETS = { "TechWire", "Frontline Weekly", "AI Weekly", "Silicon Daily", "ModelWatch", "ByteReview", "The Daily Compute", "Global Tech Herald", "Neon Gazette" }
	local LEGEND = { "{model} is the reason people are buying new computers. Nothing else this year comes close.", "A once in a decade release. {lab} just moved the whole field.", "Every other model now looks like a preview of {model}.", "Stunning, fast and frighteningly good at everything we threw at it." }
	local GOOD = { "The best {model} moments feel like magic.", "Fast, smart and surprisingly funny.", "{lab} is now a serious player.", "A must-try for developers.", "Quietly excellent." }
	local MID = { "Good, not great. Wait for the next version.", "Solid basics, nothing new.", "Fine for homework, shaky for work.", "Promising, but {rivalModel} is still ahead." }
	local BAD = { "Confidently wrong too often.", "Feels a year behind.", "Hard to recommend at this price.", "Skip this one." }
	local reviews = {}
	local usedOutlet = {}
	local wantReviews = TIER_REVIEWS[tier] + chaos
	local tries = 0
	while #reviews < wantReviews and tries < 40 do
		tries += 1
		local o = pick(OUTLETS)
		if not usedOutlet[o] then
			usedOutlet[o] = true
			local sc = math.clamp(score / 10 + rng:NextNumber(-1.2, 1.2), 1, 10)
			local pool = sc >= 9 and LEGEND or (sc >= 7.5 and GOOD or (sc >= 5 and MID or BAD))
			table.insert(reviews, { outlet = o, score = math.floor(sc * 10) / 10, quote = fill(pick(pool), vars) })
		end
	end

	-- YouTube videos. Each title only fits certain tiers; views scale with tier and chaos.
	local YT = {
		{ "{model} is INSANE (I tested it for 24 hours)", 0.9, "insane,great" },
		{ "I let {model} run my life for a week", 0.8, "insane,great,ok" },
		{ "{model} vs {rivalModel}: the honest truth", 0.7, "great,ok,meh" },
		{ "Is {lab} the next big thing?", 0.6, "great,ok" },
		{ "{model} FAILED my test (watch till the end)", 0.4, "meh,flop" },
		{ "Why everyone is wrong about {model}", 0.5, "ok,meh,flop" },
		{ "I built a game with {model} in 10 minutes", 0.8, "great,ok" },
		{ "{model} ended my job in 4 minutes (I am not okay)", 1.0, "insane" },
		{ "The {model} launch is the biggest thing since the internet", 0.9, "insane" },
		{ "{model} made me cry. Honest review", 0.8, "insane,great" },
		{ "Every single thing {model} can do, ranked", 0.7, "insane,great" },
		{ "I gave {model} my whole channel. It made a better one", 0.8, "insane,great" },
		{ "{rivalModel} is finished. Here is why", 0.9, "insane,great" },
		{ "{model} broke the internet (a short documentary)", 0.9, "insane" },
		{ "We tested {model} with the entire office", 0.6, "great,ok" },
		{ "{lab} vs everyone: the {model} recap", 0.5, "great,ok" },
		{ "{model} in 60 seconds, no hype", 0.5, "ok,meh" },
		{ "Is {model} the last model we will ever need?", 0.8, "insane" },
		{ "Nobody is talking about {model}. Why?", 0.4, "meh,flop" },
		{ "{model} review: I expected nothing and got a lot", 0.5, "great,ok" },
		{ "{lab} just ruined my weekend ({model})", 0.7, "insane,great" },
		{ "My honest {model} review after 3 weeks of use", 0.6, "ok,meh,great" },
	}
	local CHANNELS = { "Channel Alpha", "Deep Dive Daily", "The Fast Code Show", "Big Chip Reviews", "Papers Explained Live", "a 14 year old with 3M subs" }
	local videos = {}
	local usedVideo = {}
	local viewMult = TIER_VIEWS[tier] * (chaos == 2 and 25 or (chaos == 1 and 8 or 1))
	for _ = 1, TIER_VIDEOS[tier] + 2 * chaos do
		local choices = {}
		for _, y in ipairs(YT) do
			if not usedVideo[y] and string.find(y[3], tier, 1, true) then
				table.insert(choices, y)
			end
		end
		if #choices == 0 then
			break
		end
		local t = pick(choices)
		usedVideo[t] = true
		table.insert(videos, { channel = pick(CHANNELS), title = fill(t[1], vars), views = math.floor(rng:NextNumber(2e4, 2e6) * reach * t[2] * (score / 60) * viewMult) })
	end

	-- Chaos: the company's own posts go wild once billions are on it
	if chaos > 0 then
		for _ = 1, chaos do
			table.insert(posts, makePost("hype", fill(pick(RT.officialChaos), vars), rng:NextNumber(0, 3), mood, { official = true, handle = state.company, personaName = state.company }))
		end
	end

	table.sort(posts, function(a, b)
		return a.hour < b.hour
	end)
	-- keep the feed readable: cap the total, dropping the latest posts first
	local postCap = 150 + 90 * chaos
	while #posts > postCap do
		table.remove(posts)
	end
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
		signups = math.floor((5e3 + math.min(state.users * 0.15, 2e7) + (state.world.marketUsers * 1e6) * 0.004 * math.exp(math.min(gap, 6) / 6)) * userBoost * (meltdown and 0.6 or 1) * TIER_SIGNUP[tier] * (1 + 0.5 * chaos)),
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
		tier = tier,
		chaos = chaos,
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
-- Once the company has billions of users, the incident also pulls in the chaos bank.
function Launch.incident(state, kind: string, modelName: string)
	local rb = Launch.rivalBest(state, state.day)
	local chaos = Launch.chaosLevel(state.users)
	local vars = {
		model = modelName,
		lab = state.company,
		rival = rb and Labs.displayName(rb.lab) or "Vaultmind",
		rivalModel = rb and rb.model or "Beacon 4",
		year = select(1, Format.dateFromDay(state.day)),
		bench = "the main test",
		delta = "6",
		users = Format.count(state.users),
		waitlist = Format.count(math.max(1e6, state.users * 0.2)),
	}
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
	-- chaos: billions of users, so the whole world piles in on the incident
	if chaos > 0 then
		local bank = {}
		for persona, lines in pairs(chaosBank) do
			for _, l in ipairs(lines) do
				if l.tags.ANY or l.tags[kind] or l.tags.CHAOS then
					table.insert(bank, { persona = persona, l = l })
				end
			end
		end
		local extra = chaos == 2 and 28 or 12
		for _ = 1, extra do
			if #bank == 0 then
				break
			end
			local b = table.remove(bank, rng:NextInteger(1, #bank))
			table.insert(posts, makePost(b.persona, fill(b.l.text, vars), rng:NextNumber(0, 18), 1 + 0.2 * chaos))
		end
	end
	table.sort(posts, function(a, b)
		return a.hour < b.hour
	end)
	local chat = IT.staffChat[kind] and fill(pick(IT.staffChat[kind]), vars) or nil
	return { kind = kind, posts = posts, press = press, chat = chat, model = modelName }
end

return Launch
