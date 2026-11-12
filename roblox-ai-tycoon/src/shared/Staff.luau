--!strict
-- Roles with real total-comp by year (research 08 §5). Cash cost = TC x cashShare x startup multiplier x benefits.
local Staff = {}

Staff.roles = {
	{ id = "junior", name = "ML Engineer", key = "JuniorMLE", effect = "research", power = 1, blurb = "Runs experiments, babysits training runs." },
	{ id = "senior", name = "Senior ML Engineer", key = "SeniorMLE", effect = "research", power = 2.6, blurb = "Knows which ablations matter." },
	{ id = "star", name = "Star Researcher", key = "StarResearcher", effect = "research", power = 9, blurb = "Famous paper author. Everyone will try to poach them." },
	{ id = "infra", name = "Infra Engineer", key = "Infra", effect = "infra", power = 1, blurb = "Keeps GPUs busy and clusters alive. Fewer failed runs." },
	{ id = "data", name = "Data Engineer", key = "DataEng", effect = "data", power = 1, blurb = "Cleaner data, better mixes, more tokens." },
	{ id = "safety", name = "Safety Researcher", key = "PolicySafety", effect = "safety", power = 1, blurb = "Red-teaming and system cards. Fewer jailbreak scandals." },
	{ id = "product", name = "Product Engineer", key = "ProductEng", effect = "product", power = 1, blurb = "Ships app features. More users stick around." },
	{ id = "designer", name = "Designer", key = "Designer", effect = "product", power = 0.8, blurb = "Makes the app feel great." },
	{ id = "sales", name = "Enterprise Sales", key = "SalesAE", effect = "sales", power = 1, blurb = "Closes API and enterprise deals." },
	{ id = "marketing", name = "Marketing Lead", key = "Marketing", effect = "hype", power = 1, blurb = "Launch hype, teasers, community." },
}

Staff.byId = {} :: { [string]: any }
for _, r in ipairs(Staff.roles) do
	Staff.byId[r.id] = r
end

Staff.TC = {
	[2023] = { JuniorMLE = 275e3, SeniorMLE = 700e3, StarResearcher = 5e6, Infra = 450e3, DataEng = 350e3, ProductEng = 420e3, Designer = 400e3, SalesAE = 320e3, Marketing = 260e3, PolicySafety = 370e3 },
	[2024] = { JuniorMLE = 320e3, SeniorMLE = 780e3, StarResearcher = 1.2e7, Infra = 520e3, DataEng = 390e3, ProductEng = 460e3, Designer = 480e3, SalesAE = 360e3, Marketing = 300e3, PolicySafety = 440e3 },
	[2025] = { JuniorMLE = 390e3, SeniorMLE = 850e3, StarResearcher = 4e7, Infra = 670e3, DataEng = 500e3, ProductEng = 570e3, Designer = 670e3, SalesAE = 430e3, Marketing = 340e3, PolicySafety = 510e3 },
	[2026] = { JuniorMLE = 415e3, SeniorMLE = 920e3, StarResearcher = 2.5e7, Infra = 710e3, DataEng = 530e3, ProductEng = 610e3, Designer = 720e3, SalesAE = 470e3, Marketing = 370e3, PolicySafety = 550e3 },
}
Staff.CASH_SHARE = { JuniorMLE = 0.55, SeniorMLE = 0.35, StarResearcher = 0.05, Infra = 0.45, DataEng = 0.5, ProductEng = 0.45, Designer = 0.45, SalesAE = 0.6, Marketing = 0.6, PolicySafety = 0.5 }
Staff.STARTUP_MULT = 0.7
Staff.BENEFITS = 1.25

function Staff.tc(roleId: string, year: number): number
	local r = Staff.byId[roleId]
	local y = math.clamp(year, 2023, 2026)
	local base = Staff.TC[y][r.key]
	if year > 2026 then
		base *= 1.05 ^ (year - 2026)
	end
	return base
end

-- Monthly cash cost of one hire.
function Staff.monthlyCash(roleId: string, year: number): number
	local r = Staff.byId[roleId]
	return Staff.tc(roleId, year) * Staff.CASH_SHARE[r.key] * Staff.STARTUP_MULT * Staff.BENEFITS / 12
end

-- Equity a hire takes (fraction of company) at a given valuation; rest of TC is stock.
function Staff.equityCost(roleId: string, year: number, valuation: number): number
	local r = Staff.byId[roleId]
	local stock = Staff.tc(roleId, year) * (1 - Staff.CASH_SHARE[r.key]) * 4 -- 4-year grant
	return math.min(stock / math.max(valuation, 1e6), 0.08)
end

local FIRST = { "Maya", "Daniel", "Noa", "Arjun", "Lena", "Omar", "Priya", "Jonah", "Sofia", "Kenji", "Tal", "Elena", "Marcus", "Yuki", "Amir", "Chloe", "Ravi", "Ines", "Leo", "Hana", "Felix", "Zara", "Ethan", "Mei", "Dov", "Aisha", "Lucas", "Nadia", "Theo", "Ivy" }
local LAST = { "Chen", "Levi", "Okafor", "Patel", "Novak", "Haddad", "Silva", "Kim", "Rossi", "Weiss", "Tanaka", "Cohen", "Garcia", "Moreau", "Singh", "Berg", "Park", "Azoulay", "Kowalski", "Mendes" }
local FROM = { "ex-Google Brain", "ex-OpenAI", "ex-Meta FAIR", "PhD, Stanford", "PhD, Berkeley", "PhD, Technion", "ex-DeepMind", "Kaggle grandmaster", "ex-Nvidia", "PhD, CMU", "ex-Stripe", "ex-Apple", "bootcamp grad", "ex-Anthropic", "PhD, MIT", "ex-Microsoft Research" }

function Staff.randomCandidate(rng: Random, roleId: string)
	return {
		name = FIRST[rng:NextInteger(1, #FIRST)] .. " " .. LAST[rng:NextInteger(1, #LAST)],
		role = roleId,
		from = FROM[rng:NextInteger(1, #FROM)],
		skill = math.floor(rng:NextNumber(0.75, 1.3) * 100) / 100,
	}
end

-- Ranks: each step costs a raise but makes them better and happier.
Staff.RANKS = { "Junior", "Mid", "Senior", "Lead", "Principal" }

-- Computers you can give a person. Better machine = more work done.
Staff.PCS = {
	{ name = "Old laptop", price = 0, boost = 1.0 },
	{ name = "Gaming PC", price = 1500, boost = 1.1 },
	{ name = "Workstation", price = 6000, boost = 1.2 },
	{ name = "Dual GPU tower", price = 18000, boost = 1.32 },
}

-- LinkedIn search: filters change who shows up.
Staff.SCHOOLS = { "any", "ex-OpenAI", "ex-DeepMind", "ex-Anthropic", "ex-Meta FAIR", "PhD, Stanford", "PhD, MIT", "PhD, Technion", "Kaggle grandmaster", "bootcamp grad" }
Staff.SKILLS = { "any", "LLM training", "RL", "Inference", "Data", "Safety", "Product", "Sales" }

function Staff.searchCandidate(rng: Random, roleId: string, filters)
	local c = Staff.randomCandidate(rng, roleId)
	local minSkill = tonumber(filters.minSkill) or 0.7
	c.skill = math.floor(math.clamp(rng:NextNumber(minSkill, minSkill + 0.45), 0.6, 1.9) * 100) / 100
	if filters.school and filters.school ~= "any" then
		c.from = filters.school
		if filters.school:sub(1, 3) == "ex-" then
			c.skill = math.floor((c.skill + 0.15) * 100) / 100
		end
	end
	c.skillTag = (filters.skill and filters.skill ~= "any") and filters.skill or Staff.SKILLS[rng:NextInteger(2, #Staff.SKILLS)]
	c.hot = filters.hot == true or rng:NextNumber() < 0.12
	if c.hot then
		c.skill = math.floor((c.skill + 0.2) * 100) / 100
	end
	-- how hard they are to get (0..1): great and in-demand people say no a lot
	c.demand = math.clamp((c.skill - 0.7) / 1.1 + (c.hot and 0.25 or 0), 0.05, 0.95)
	return c
end

-- Rarity: every person rolls one. Better rarity = much more work done, but pricier and pickier.
Staff.RARITIES = {
	{ id = "common", name = "COMMON", mult = 1, color = Color3.fromRGB(150, 160, 180) },
	{ id = "uncommon", name = "UNCOMMON", mult = 1.6, color = Color3.fromRGB(40, 200, 90) },
	{ id = "rare", name = "RARE", mult = 2.6, color = Color3.fromRGB(30, 140, 255) },
	{ id = "epic", name = "EPIC", mult = 4.2, color = Color3.fromRGB(170, 80, 255) },
	{ id = "legend", name = "LEGENDARY", mult = 7, color = Color3.fromRGB(255, 185, 0) },
	{ id = "mythic", name = "MYTHIC", mult = 12, color = Color3.fromRGB(255, 50, 110) },
}

-- Places you pay to find people. weights = chance per rarity (common..mythic).
Staff.PLACES = {
	{ id = "board", name = "JOB BOARD", cost = 2e3, n = 6, office = 1, weights = { 62, 27, 9, 2, 0, 0 }, color = Color3.fromRGB(40, 160, 255), desc = "Cheap. Mostly regular people." },
	{ id = "uni", name = "UNIVERSITY FAIR", cost = 25e3, n = 6, office = 2, weights = { 28, 36, 26, 8, 2, 0 }, color = Color3.fromRGB(40, 200, 110), desc = "Fresh PhDs. Some hidden gems." },
	{ id = "hunter", name = "HEADHUNTER", cost = 400e3, n = 6, office = 3, weights = { 0, 22, 42, 26, 9, 1 }, color = Color3.fromRGB(170, 80, 255), desc = "Poaches good people from big labs." },
	{ id = "elite", name = "ELITE AGENCY", cost = 8e6, n = 5, office = 4, weights = { 0, 0, 18, 44, 30, 8 }, color = Color3.fromRGB(255, 175, 0), desc = "Only the best. Legends live here." },
}
Staff.placeById = {}
for _, pl in ipairs(Staff.PLACES) do
	Staff.placeById[pl.id] = pl
end

function Staff.searchCost(place, year: number, minRarity: number, roleFilter: boolean): number
	return place.cost * (1 + math.max(0, year - 2023) * 0.5) * (1 + 0.7 * math.max(0, minRarity - 1)) * (roleFilter and 1.3 or 1)
end

function Staff.rollRarity(rng: Random, weights: { number }, minRarity: number): number
	local total = 0
	for i, w in ipairs(weights) do
		if i >= minRarity then
			total += w
		end
	end
	if total <= 0 then
		return math.clamp(minRarity, 1, #Staff.RARITIES)
	end
	local r = rng:NextNumber() * total
	for i, w in ipairs(weights) do
		if i >= minRarity then
			r -= w
			if r <= 0 then
				return i
			end
		end
	end
	return minRarity
end

return Staff
