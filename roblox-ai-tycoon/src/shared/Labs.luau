--!strict
-- Real labs and their releases (research 09 §1, §3.2), re-skinned with original names.
-- Every company and model name here is an original parody or invented name (no real trademarks).
-- Lab ids (the `id` field and the second column of RAW) are internal keys: do not rename them.
-- cap = internal capability index (the top original model = 50). Benchmarks are derived from it in Benchmarks.luau.
local Labs = {}

-- Always show the original parody names in the game.
Labs.PARODY_MODE = true

Labs.list = {
	--   id          display name          parody (same, shown in game)  color                       brand  cadence(mo) openness hype
	{ id = "openai", name = "Vaultmind", parody = "Vaultmind", color = Color3.fromRGB(16, 163, 127), brand = 9, cadence = 3, open = 2, hype = 10, cash = 11e9 },
	{ id = "anthropic", name = "Kindred Systems", parody = "Kindred Systems", color = Color3.fromRGB(217, 119, 87), brand = 2.2, cadence = 2.5, open = 0, hype = 5, cash = 1.5e9 },
	{ id = "google", name = "Giggle Minds", parody = "Giggle Minds", color = Color3.fromRGB(66, 133, 244), brand = 5, cadence = 4, open = 4, hype = 6, cash = 100e9 },
	{ id = "meta", name = "Meshworks", parody = "Meshworks", color = Color3.fromRGB(0, 129, 251), brand = 3, cadence = 6, open = 8, hype = 7, cash = 60e9 },
	{ id = "xai", name = "Yonder Labs", parody = "Yonder Labs", color = Color3.fromRGB(230, 230, 230), brand = 1.5, cadence = 4, open = 3, hype = 9, cash = 6e9 },
	{ id = "mistral", name = "Maestrale", parody = "Maestrale", color = Color3.fromRGB(255, 112, 0), brand = 0.8, cadence = 6, open = 7, hype = 4, cash = 0.5e9 },
	{ id = "deepseek", name = "Deepdrift", parody = "Deepdrift", color = Color3.fromRGB(77, 107, 254), brand = 0.6, cadence = 5, open = 10, hype = 1, cash = 1e9 },
	{ id = "qwen", name = "Cwenta", parody = "Cwenta", color = Color3.fromRGB(97, 92, 237), brand = 0.8, cadence = 4, open = 9, hype = 4, cash = 20e9 },
	{ id = "moonshot", name = "Lunaris", parody = "Lunaris", color = Color3.fromRGB(40, 40, 40), brand = 0.5, cadence = 6, open = 9, hype = 5, cash = 1e9 },
	{ id = "zhipu", name = "Zettabit", parody = "Zettabit", color = Color3.fromRGB(50, 90, 200), brand = 0.4, cadence = 4, open = 8, hype = 4, cash = 1e9 },
	{ id = "minimax", name = "Maximini", parody = "Maximini", color = Color3.fromRGB(240, 60, 90), brand = 0.4, cadence = 5, open = 8, hype = 4, cash = 0.8e9 },
	{ id = "microsoft", name = "Maxwell Software", parody = "Maxwell Software", color = Color3.fromRGB(0, 164, 239), brand = 1.2, cadence = 8, open = 5, hype = 4, cash = 80e9 },
	{ id = "amazon", name = "Bazaarly", parody = "Bazaarly", color = Color3.fromRGB(255, 153, 0), brand = 0.8, cadence = 12, open = 1, hype = 3, cash = 80e9 },
	{ id = "cohere", name = "Coheer", parody = "Coheer", color = Color3.fromRGB(57, 89, 76), brand = 0.3, cadence = 12, open = 5, hype = 2, cash = 0.4e9 },
	{ id = "nvidia", name = "Vividia", parody = "Vividia", color = Color3.fromRGB(118, 185, 0), brand = 0.3, cadence = 12, open = 9, hype = 6, cash = 30e9 },
	{ id = "perplexity", name = "Perplexed", parody = "Perplexed", color = Color3.fromRGB(32, 128, 141), brand = 0.6, cadence = 6, open = 2, hype = 7, cash = 1e9 },
	{ id = "inflection", name = "Influx Labs", parody = "Influx Labs", color = Color3.fromRGB(255, 120, 60), brand = 0.4, cadence = 9, open = 1, hype = 6, cash = 1.5e9 },
	{ id = "character", name = "Persona Chat", parody = "Persona Chat", color = Color3.fromRGB(80, 80, 200), brand = 0.6, cadence = 8, open = 1, hype = 5, cash = 0.2e9 },
	{ id = "reka", name = "Rekka", parody = "Rekka", color = Color3.fromRGB(230, 90, 160), brand = 0.15, cadence = 10, open = 3, hype = 3, cash = 0.1e9 },
	{ id = "ai21", name = "Tuwenty", parody = "Tuwenty", color = Color3.fromRGB(240, 90, 120), brand = 0.15, cadence = 10, open = 5, hype = 2, cash = 0.3e9 },
	{ id = "yi", name = "Zero Two Labs", parody = "Zero Two Labs", color = Color3.fromRGB(30, 200, 120), brand = 0.2, cadence = 8, open = 8, hype = 3, cash = 0.3e9 },
	{ id = "baidu", name = "Bidoo Labs", parody = "Bidoo Labs", color = Color3.fromRGB(45, 50, 230), brand = 0.6, cadence = 7, open = 4, hype = 4, cash = 20e9 },
	{ id = "bytedance", name = "Nibbledance", parody = "Nibbledance", color = Color3.fromRGB(20, 20, 30), brand = 0.9, cadence = 5, open = 3, hype = 5, cash = 50e9 },
	{ id = "tencent", name = "Tenpercent", parody = "Tenpercent", color = Color3.fromRGB(0, 150, 255), brand = 0.5, cadence = 7, open = 6, hype = 3, cash = 50e9 },
	{ id = "ssi", name = "Very Safe Inc", parody = "Very Safe Inc", color = Color3.fromRGB(240, 240, 240), brand = 0.3, cadence = 18, open = 0, hype = 8, cash = 3e9 },
	{ id = "thinking", name = "Ponder Machines", parody = "Ponder Machines", color = Color3.fromRGB(250, 200, 80), brand = 0.3, cadence = 12, open = 4, hype = 7, cash = 2e9 },
	{ id = "sakana", name = "Fishana Labs", parody = "Fishana Labs", color = Color3.fromRGB(240, 70, 70), brand = 0.15, cadence = 10, open = 7, hype = 4, cash = 0.3e9 },
	-- Fictional companies that only appear after the real calendar ends (no real releases).
	{ id = "vorlane", founded = "2026-11", name = "Vorlane", parody = "Vorlane", color = Color3.fromRGB(120, 230, 255), brand = 0.3, cadence = 5, open = 6, hype = 6, cash = 3e9, story = "A chip maker from a port city that started its own lab after its biggest customers kept asking for a brain to go with the silicon." },
	{ id = "oruna", founded = "2027-04", name = "Oruna", parody = "Oruna", color = Color3.fromRGB(230, 120, 255), brand = 0.2, cadence = 4, open = 9, hype = 5, cash = 2e9, story = "A game studio whose tavern NPC brain went too far. Its characters now refuse to leave the server and negotiate their own patches." },
	{ id = "drevan", founded = "2027-09", name = "Drevan", parody = "Drevan", color = Color3.fromRGB(180, 200, 70), brand = 0.2, cadence = 7, open = 3, hype = 4, cash = 1e9, story = "A privacy-first lab from a small northern country, funded by a cooperative of hospitals and the national postal bank. Models run on your own machine or not at all." },
	{ id = "solenne", founded = "2028-02", name = "Solenne", parody = "Solenne", color = Color3.fromRGB(250, 205, 220), brand = 0.5, cadence = 9, open = 0, hype = 8, cash = 8e9, story = "A hedge fund quant team that turned its trading models into a general lab. Secretive, very rich, and always hiring from the same three universities." },
	{ id = "quorvi", founded = "2028-08", name = "Quorvi", parody = "Quorvi", color = Color3.fromRGB(70, 70, 84), brand = 0.15, cadence = 3, open = 10, hype = 3, cash = 0.6e9, story = "An open-source collective run out of a volunteer chat server by about 300 contributors who vote on every release. Ships fast, argues longer." },
	{ id = "kestrel", founded = "2029-03", name = "Kestrel Robotics", parody = "Kestrel Robotics", color = Color3.fromRGB(190, 40, 60), brand = 0.4, cadence = 6, open = 1, hype = 7, cash = 4e9, story = "A warehouse robotics company that added a language model so its arms could take instructions. Now it sells the minds as well as the arms." },
}

Labs.byId = {} :: { [string]: any }
for _, l in ipairs(Labs.list) do
	Labs.byId[l.id] = l
end

-- Approximate valuations in $B by year (research 08 §6; big tech = parent company, very hard to buy).
Labs.valuationB = {
	openai = { [2023] = 86, [2024] = 157, [2025] = 500, [2026] = 852 },
	anthropic = { [2023] = 18, [2024] = 40, [2025] = 183, [2026] = 965 },
	google = { [2023] = 1500, [2024] = 2100, [2025] = 2800, [2026] = 3600 },
	meta = { [2023] = 700, [2024] = 1300, [2025] = 1700, [2026] = 1900 },
	xai = { [2023] = 1, [2024] = 50, [2025] = 200, [2026] = 250 },
	mistral = { [2023] = 2.1, [2024] = 6.2, [2025] = 13.7, [2026] = 24 },
	deepseek = { [2023] = 1, [2024] = 3, [2025] = 12, [2026] = 30 },
	qwen = { [2023] = 8, [2024] = 15, [2025] = 35, [2026] = 70 },
	moonshot = { [2023] = 0.5, [2024] = 3.3, [2025] = 4.3, [2026] = 35 },
	zhipu = { [2023] = 1.5, [2024] = 2.8, [2025] = 6.5, [2026] = 7.1 },
	minimax = { [2023] = 1.2, [2024] = 2.5, [2025] = 4, [2026] = 9.2 },
	microsoft = { [2023] = 2500, [2024] = 3100, [2025] = 3700, [2026] = 4000 },
	amazon = { [2023] = 1500, [2024] = 2100, [2025] = 2400, [2026] = 2600 },
	cohere = { [2023] = 2.2, [2024] = 5.5, [2025] = 7, [2026] = 25 },
	perplexity = { [2023] = 0.5, [2024] = 9, [2025] = 20, [2026] = 24 },
	inflection = { [2023] = 4, [2024] = 4, [2025] = 2, [2026] = 2 },
	character = { [2023] = 1, [2024] = 2.5, [2025] = 1, [2026] = 1 },
	reka = { [2023] = 0.3, [2024] = 0.5, [2025] = 1, [2026] = 1 },
	ai21 = { [2023] = 1.4, [2024] = 1.4, [2025] = 2, [2026] = 2 },
	yi = { [2023] = 1, [2024] = 1, [2025] = 1, [2026] = 1 },
	baidu = { [2023] = 40, [2024] = 35, [2025] = 30, [2026] = 35 },
	bytedance = { [2023] = 220, [2024] = 300, [2025] = 330, [2026] = 400 },
	tencent = { [2023] = 400, [2024] = 450, [2025] = 550, [2026] = 600 },
	ssi = { [2023] = 0.5, [2024] = 5, [2025] = 32, [2026] = 40 },
	thinking = { [2023] = 0.5, [2024] = 1, [2025] = 12, [2026] = 40 },
	sakana = { [2023] = 0.2, [2024] = 1, [2025] = 2.6, [2026] = 3 },
	nvidia = { [2023] = 1100, [2024] = 3200, [2025] = 4300, [2026] = 4800 },
	-- fictional future labs (valuations must cover 2023 to 2026, valuation() indexes every year)
	vorlane = { [2023] = 0.1, [2024] = 0.4, [2025] = 2, [2026] = 6 },
	oruna = { [2023] = 0.1, [2024] = 0.6, [2025] = 2.5, [2026] = 7 },
	drevan = { [2023] = 0.3, [2024] = 0.8, [2025] = 1.5, [2026] = 2.2 },
	solenne = { [2023] = 0.2, [2024] = 1.5, [2025] = 12, [2026] = 30 },
	quorvi = { [2023] = 0.05, [2024] = 0.2, [2025] = 0.6, [2026] = 1.2 },
	kestrel = { [2023] = 0.2, [2024] = 0.9, [2025] = 6, [2026] = 15 },
}

function Labs.valuation(id: string, year: number): number
	local t = Labs.valuationB[id]
	if not t then
		return 1e9
	end
	local y = math.clamp(year, 2023, 2026)
	local v = t[y] * 1e9
	if year > 2026 then
		v *= 1.3 ^ (year - 2026)
	end
	return v
end

-- Companies founded in the future only exist from their founding month.
function Labs.isFounded(id: string, day: number): boolean
	local l = Labs.byId[id]
	if not l or not l.founded then
		return true
	end
	if not l.foundedDay then
		l.foundedDay = require(script.Parent:WaitForChild("Format")).dayFromString(l.founded)
	end
	return day >= l.foundedDay
end

function Labs.displayName(id: string): string
	local l = Labs.byId[id]
	if not l then
		return id
	end
	return Labs.PARODY_MODE and l.parody or l.name
end

-- date | lab id | model | cap | O=open C=closed | $ out per 1M | short note (used in news + reactions)
local RAW = [[
2020-06-11|openai|Beacon 1|30|C|20|The model that started it all
2022-04-04|google|Quartz 540|36|C|0|Giggle Minds' giant research model
2022-05-02|meta|Loom 175B|24|O|0|Meshworks opens a big model to everyone
2022-11-28|openai|Beacon 2 Instruct|38|C|20|The model behind early chatbots
2022-11-30|openai|Chatterbox 3.5|40|C|2|100 million users in two months
2023-02-24|meta|Loom 65|30|O|0|Weights leak sparks the open-source boom
2023-03-01|openai|Chatterbox Turbo API|40|C|2|Chat API, 10x cheaper than the old model
2023-03-14|openai|Beacon 4|50|C|60|The step change of the era
2023-03-14|anthropic|Ember 1|42|C|33|Safety-first entrant
2023-03-21|google|Glimmer|35|C|0|Rushed launch after a costly demo error
2023-05-10|google|Quartz 2|40|C|2|Powers the Glimmer chatbot
2023-07-11|anthropic|Ember 2|44|C|33|100K context reads whole books
2023-05-02|inflection|Hum|33|C|0|A kind and chatty personal assistant
2023-10-17|baidu|Pagoda 4|42|C|0|China's answer to the leading model
2023-11-05|yi|Dragon 34B|39|O|0|Tops the open leaderboard for a week
2023-11-22|inflection|Hum 2|46|C|0|Claims second place in the world
2024-03-07|inflection|Hum 2.5|51|C|0|Then most of the team leaves for a bigger giant
2024-03-28|ai21|Cascade|40|O|0|State-space and attention hybrid
2024-04-15|reka|Anvil Core|48|C|10|Small team, multimodal frontier model
2024-11-05|tencent|Gongfu Large|52|O|0|Biggest open mixture-of-experts of its time
2025-01-22|bytedance|Pebble 1.5 Pro|62|C|1|Cheap and good, huge local user base
2025-02-11|perplexity|Ferret 1|60|C|1|Search answers, built on open models
2025-03-21|sakana|Scholar 2|50|O|0|Its paper passes peer review
2025-10-15|bytedance|Pebble 2|78|C|2|Number one app in its home market
2026-03-20|thinking|Rook 1|84|O|0|The former lab team's first model
2026-08-30|ssi|Quiet Preview|90|C|0|Silent for two years, then this
2023-07-18|meta|Loom 2 70B|38|O|0|Open weights go commercial
2023-08-03|qwen|Lattice 7B|28|O|0|Start of the open-weights machine
2023-09-27|mistral|Scirocco 7B|32|O|0|Dropped as a magnet link
2023-11-04|xai|Comet 1|38|C|0|The rebellious chatbot inside a social app
2023-11-06|openai|Beacon 4 Turbo|52|C|30|3x cheaper than Beacon 4, 128K context
2023-11-21|anthropic|Ember 2.1|45|C|24|200K context, fewer hallucinations
2023-11-29|deepseek|Trench 67B|37|O|0|A quant fund's lab debuts
2023-12-06|google|Prism 1 Ultra|50|C|0|Edited demo video controversy
2023-12-11|mistral|Scirocco Mix 8x7|40|O|0.7|Popularised open mixture-of-experts
2024-02-15|google|Prism 1.5 Pro|53|C|10.5|1M context leap
2024-02-26|mistral|Tramontana Large|46|C|24|The flagship goes closed
2024-03-04|anthropic|Ember Grand 3|55|C|75|First to beat the old flagship on the leaderboard
2024-04-18|meta|Loom 3 70B|47|O|0|Best open model at launch
2024-05-06|deepseek|Trench V2|48|O|0.28|Triggers the regional price war
2024-05-13|openai|Beacon 4 Omni|57|C|15|Native voice and vision demo
2024-06-07|qwen|Lattice 2 72B|49|O|0|Tops the open leaderboard
2024-06-20|anthropic|Ember Swift 3.5|59|C|15|The coding favourite
2024-07-18|openai|Beacon 4 Mini|46|C|0.6|Kills the old cheap model on price
2024-07-23|meta|Loom 3.1 405B|54|O|0|First open model near the top tier
2024-08-13|xai|Comet 2|54|C|10|Few guardrails, fast catch-up
2024-09-12|openai|Thinker 1 Preview|63|C|60|Birth of reasoning models
2024-10-22|anthropic|Ember Swift 3.6|61|C|15|Computer use agents arrive
2024-12-05|openai|Thinker 1|65|C|60|Plus a $200/month Pro plan
2024-12-11|google|Prism 2 Flash|57|C|0.4|The agentic era pitch
2024-12-26|deepseek|Trench V3|58|O|1.1|Trained for a reported $5.6M
2025-01-20|deepseek|Trench R1|65|O|2.19|Number one on the app charts, a chip maker drops 17%
2025-01-31|openai|Thinker 2 Mini|64|C|4.4|Answer to a rival's reasoning model
2025-02-17|xai|Comet 3|68|C|15|Biggest training cluster flex
2025-02-24|anthropic|Ember Swift 3.7|67|C|15|Hybrid reasoning plus a coding agent
2025-02-27|openai|Beacon 4.5|64|C|150|Huge, pricey, short-lived
2025-03-25|google|Prism 2.5 Pro|72|C|10|Back on top of the leaderboard by 40 points
2025-04-05|meta|Loom 4 Maverick|58|O|0|Leaderboard variant controversy
2025-04-16|openai|Thinker 3|72|C|40|Tool-using reasoning
2025-04-29|qwen|Lattice 3 235B|66|O|0|Most downloaded open family
2025-05-22|anthropic|Ember Grand 4|73|C|75|Long agentic coding runs
2025-07-09|xai|Comet 4|75|C|15|Top benchmarks after a rough week
2025-07-11|moonshot|Orbit K2|68|O|2.5|Best open agentic coder
2025-08-05|openai|Open Beacon 120|64|O|0|The first open weights from this lab in years
2025-08-07|openai|Beacon 5|77|C|10|Hype beat reality, chart crimes
2025-09-29|anthropic|Ember Swift 4.5|78|C|15|Best coding model
2025-11-06|moonshot|Orbit K2 Thinking|74|O|2.5|A second cheap and open shock
2025-11-18|google|Prism 3 Pro|82|C|12|New number one, rivals declare code red
2025-11-24|anthropic|Ember Grand 4.5|83|C|25|First past 80 on the coding benchmark
2025-12-01|deepseek|Trench V3.2|74|O|0.42|Olympiad gold, open weights
2025-12-02|mistral|Tramontana Large 3|66|O|0|Europe's open frontier attempt
2025-12-11|openai|Beacon 5.2|83|C|14|Fast code-red response
2026-02-05|anthropic|Ember Grand 4.6|85|C|25|Agent teams, vibe working
2026-02-11|zhipu|Glyph 5|76|O|2|Trained on domestic chips
2026-02-16|qwen|Lattice 3.5|78|O|0|Lunar New Year drop
2026-02-19|google|Prism 3.1 Pro|86|C|12|Doubled reasoning in 3 months
2026-03-05|openai|Beacon 5.4|86|C|15|Native computer use
2026-04-08|meta|Muse Spark|80|C|0|End of the Loom era
2026-04-16|anthropic|Ember Grand 4.7|88|C|25|Coding benchmark score of 87.6
2026-04-23|openai|Beacon 5.5|89|C|30|A new class of intelligence, price doubled
2026-04-24|deepseek|Trench V4|83|O|3.48|A sixth of the price of the leaders
2026-05-28|anthropic|Ember Grand 4.8|89|C|25|41 days after 4.7
2026-06-01|minimax|Spindle M3|80|O|1.2|Native multimodal, dirt cheap
2026-06-09|anthropic|Fable 5|92|C|50|Frontier power with safeguards
2026-07-09|openai|Beacon Sol 5.6|91|C|30|Celestial naming arrives
2026-07-16|moonshot|Orbit K3|87|O|15|Largest open model ever
2026-07-24|anthropic|Ember Grand 5|91|C|25|Near the top at mid-tier prices
2026-08-03|qwen|Lattice 3.8 Max|86|O|0|Claims global number two
2026-08-12|xai|Comet 4.6|85|C|6|Comet 5 still training
2026-09-03|openai|Beacon 6 Astra|94|C|50|The Beacon 6 era begins
2026-09-22|anthropic|Ember Grand 5.5|93|C|20|Web development leaderboard number one
2026-10-06|mistral|Tramontana Large 4|80|O|0|A trillion-parameter open model from the continent
2026-10-12|meta|Muse Wonder|91|C|20|1.8M downloads in 12 days
2026-10-13|google|Prism 4 Argon|94|C|10|Beats Beacon 6 Astra at 40% of the cost
2026-10-28|google|Prism 4 Carbon|96|C|10|Number one on the leaderboard, gated release
]]

export type Release = {
	day: number,
	lab: string,
	model: string,
	cap: number,
	open: boolean,
	priceOut: number,
	note: string,
	future: boolean?,
}

local Format = require(script.Parent:WaitForChild("Format"))

Labs.releases = {} :: { Release }
for line in RAW:gmatch("[^\n]+") do
	local date, lab, model, cap, oc, price, note = line:match("^(.-)|(.-)|(.-)|(.-)|(.-)|(.-)|(.*)$")
	if date then
		table.insert(Labs.releases, {
			day = Format.dayFromString(date),
			lab = lab,
			model = model,
			cap = tonumber(cap) :: number,
			open = oc == "O",
			priceOut = tonumber(price) :: number,
			note = note,
		})
	end
end
table.sort(Labs.releases, function(a, b)
	return a.day < b.day
end)

Labs.LAST_REAL_DAY = Labs.releases[#Labs.releases].day

-- Projected frontier after the real calendar ends (research 09 §6.2, medium scenario):
-- +6 cap/yr in 2027, slowing gently.
function Labs.frontierProjection(day: number): number
	local years = (day - Labs.LAST_REAL_DAY) / 365
	if years <= 0 then
		return 96
	end
	return 96 + 6 * years - 0.35 * years * years
end

-- Future model names per lab. Each lab has its own product-line style (never company name + number).
Labs.futureNames = {
	openai = { "Beacon 6.5", "Beacon 7", "Beacon 7 Mini", "Thinker 4", "Beacon 7.5", "Beacon Sol 8", "Beacon 8", "Thinker 5", "Beacon 9" },
	anthropic = { "Ember Grand 6", "Ember Swift 6", "Ember Grand 6.5", "Ember Swift 6.5", "Ember Grand 7", "Ember Swift 7", "Ember Grand 7.5", "Ember Grand 8" },
	google = { "Prism 5", "Prism 5 Flash", "Prism 5.5 Pro", "Prism 6 Argon", "Prism 6 Carbon", "Prism 6.5 Pro", "Prism 7 Ultra", "Prism 7 Flash", "Prism 8 Pro" },
	meta = { "Muse Wonder 2", "Muse 2", "Muse Spark 2", "Muse Wonder 3", "Muse 3", "Muse Spark 3", "Muse Wonder 4", "Muse 4", "Muse Spark 4" },
	xai = { "Comet 5", "Comet 5 Heavy", "Comet 6", "Comet 6 Heavy", "Comet 7", "Comet 7 Heavy", "Comet 8", "Comet 9" },
	mistral = { "Scirocco 8", "Tramontana Large 5", "Scirocco Mix 9", "Tramontana Large 6", "Scirocco 9", "Tramontana Large 7", "Scirocco 10", "Tramontana Large 8" },
	deepseek = { "Trench V5", "Trench R3", "Trench V6", "Trench R4", "Trench V7", "Trench R5", "Trench V8", "Trench R6" },
	qwen = { "Lattice 4", "Lattice 4.5", "Lattice 5", "Lattice 5.5", "Lattice 6", "Lattice 6.5", "Lattice 7", "Lattice 8" },
	moonshot = { "Orbit K4", "Orbit K4.5", "Orbit K5", "Orbit K6", "Orbit K7", "Orbit K8", "Orbit K9", "Orbit K10" },
	zhipu = { "Glyph 6", "Glyph 6.5", "Glyph 7", "Glyph 7.5", "Glyph 8", "Glyph 9", "Glyph 9.5", "Glyph 10" },
	minimax = { "Spindle M4", "Spindle M5", "Spindle M6", "Spindle M7", "Spindle M8", "Spindle M9", "Spindle M10", "Spindle M11" },
	microsoft = { "Harbor 2", "Harbor 2 Mini", "Harbor 3", "Harbor 3.5", "Harbor 4", "Harbor 4 Mini", "Harbor 5", "Harbor 6", "Harbor 7" },
	amazon = { "Forge 3", "Forge 3.5", "Forge 4", "Forge 4.5", "Forge 5", "Forge 6", "Forge 7", "Forge 8" },
	cohere = { "Ledger 5", "Ledger 6", "Ledger 6.5", "Ledger 7", "Ledger 8", "Ledger 8.5", "Ledger 9", "Ledger 10" },
	nvidia = { "Thrust 4", "Thrust 4 Edge", "Thrust 5", "Thrust 6", "Thrust 6.5", "Thrust 7", "Thrust 8", "Thrust 9" },
	perplexity = { "Ferret 2", "Ferret 3", "Ferret 3 Search", "Ferret 4", "Ferret 5", "Ferret 6", "Ferret 7", "Ferret 8" },
	inflection = { "Hum 3", "Hum 3 Lite", "Hum 4", "Hum 4.5", "Hum 5", "Hum 6", "Hum 7", "Hum 8" },
	character = { "Mirage 3", "Mirage 4", "Mirage 5", "Mirage 6", "Mirage 7", "Mirage 8", "Mirage 9", "Mirage 10" },
	reka = { "Anvil 3", "Anvil Core 3", "Anvil 4", "Anvil Core 4", "Anvil 5", "Anvil Core 5", "Anvil 6", "Anvil Core 6" },
	ai21 = { "Cascade 3", "Cascade 4", "Cascade Hybrid 4", "Cascade 5", "Cascade 6", "Cascade 7", "Cascade 8", "Cascade 9" },
	yi = { "Dragon 4", "Dragon 5", "Dragon 6", "Dragon 7", "Dragon 8", "Dragon 9", "Dragon 10", "Dragon 11" },
	baidu = { "Pagoda 6", "Pagoda 7", "Pagoda 7.5", "Pagoda 8", "Pagoda 8.5", "Pagoda 9", "Pagoda 9.5", "Pagoda 10" },
	bytedance = { "Pebble 3", "Pebble 3 Pro", "Pebble 4", "Pebble 4.5", "Pebble 5", "Pebble 5.5", "Pebble 6", "Pebble 7" },
	tencent = { "Gongfu 3", "Gongfu 4", "Gongfu Large 4", "Gongfu 5", "Gongfu Large 5", "Gongfu 6", "Gongfu 6.5", "Gongfu 7" },
	ssi = { "Quiet 2", "Quiet 3", "Quiet 4", "Quiet 5", "Quiet 6", "Quiet 7", "Quiet 8", "Quiet 9" },
	thinking = { "Rook 2", "Rook 3", "Rook 4", "Rook 5", "Rook 6", "Rook 7", "Rook 8", "Rook 9" },
	sakana = { "Scholar 3", "Scholar 4", "Scholar 5", "Scholar 6", "Scholar 7", "Scholar 8", "Scholar 9", "Scholar 10" },
	vorlane = { "Ironwood 2", "Ironwood 2 Pro", "Ironwood 3", "Ironwood 3 Pro", "Ironwood 4", "Ironwood 4 Ultra", "Ironwood 5", "Ironwood 6" },
	oruna = { "Bardic 2", "Bardic 2 Tavern", "Bardic 3", "Bardic 3 Tavern", "Bardic 4", "Bardic 5", "Bardic 6", "Bardic 7" },
	drevan = { "Kiln 2", "Kiln 2 Local", "Kiln 3", "Kiln 3 Local", "Kiln 4", "Kiln 4 Local", "Kiln 5", "Kiln 6" },
	solenne = { "Basis 2", "Basis 2 Alpha", "Basis 3", "Basis 3 Alpha", "Basis 4", "Basis 5", "Basis 6", "Basis 7" },
	quorvi = { "Hatch 2", "Hatch 2 Open", "Hatch 3", "Hatch 3 Open", "Hatch 4", "Hatch 5", "Hatch 6", "Hatch 7" },
	kestrel = { "Talon 2", "Talon 2 Reflex", "Talon 3", "Talon 3 Reflex", "Talon 4", "Talon 5", "Talon 6", "Talon 7" },
}

return Labs
