--!strict
-- Office stages, model updates, goals and investor names.
local C = {}

-- kw = power budget for GPUs you OWN (rented GPUs live in someone else's datacenter).
C.officeStages = {
	{ id = "bedroom", slots = 4, name = "Your bedroom", cost = 0, rent = 0, maxStaff = 3, kw = 2, desc = "A desk, a laptop and a dream." },
	{ id = "cowork", slots = 8, name = "Co-working desk", cost = 20e3, rent = 6e3, maxStaff = 8, kw = 10, desc = "Free coffee. Loud neighbours." },
	{ id = "office", slots = 48, name = "Office floor", cost = 400e3, rent = 90e3, maxStaff = 25, kw = 400, desc = "Glass walls, your logo on the door, a server room." },
	{ id = "hq", slots = 400, name = "Headquarters", cost = 8e6, rent = 900e3, maxStaff = 60, kw = 8e3, desc = "A whole building in Mission Bay." },
	{ id = "tower", slots = 3000, name = "AI Tower", cost = 120e6, rent = 9e6, maxStaff = 120, kw = 150e3, desc = "Your name on the skyline." },
	{ id = "campus", slots = 60000, name = "Campus + gigawatt datacenter", cost = 4e9, rent = 120e6, maxStaff = 200, kw = 1.2e6, desc = "A campus and your own power plant." },
}

-- Extra places to keep GPUs and servers. You can buy more than one of each.
C.storage = {
	{ id = "closet", name = "Storage closet", cost = 15e3, rent = 500, slots = 16, kw = 10, desc = "A locked closet down the hall." },
	{ id = "garage", name = "Rented garage", cost = 250e3, rent = 6e3, slots = 96, kw = 90, desc = "Fans, extension cords and a lot of noise." },
	{ id = "biggarage", name = "Huge garage", cost = 3e6, rent = 40e3, slots = 800, kw = 900, desc = "A giant garage with its own power line." },
	{ id = "cage", name = "Colocation cage", cost = 15e6, rent = 250e3, slots = 4000, kw = 5e3, desc = "Your racks inside someone else's datacenter." },
	{ id = "hall", name = "Data hall", cost = 180e6, rent = 2e6, slots = 40000, kw = 60e3, desc = "A whole hall, liquid cooling, 24/7 guards." },
	{ id = "basement", name = "Parents' basement", cost = 5e3, rent = 0, slots = 6, kw = 5, desc = "Free rent. Your mom asks what all the noise is." },
	{ id = "container", name = "Shipping container", cost = 60e3, rent = 1.5e3, slots = 40, kw = 40, desc = "A metal box in a parking lot, full of GPUs." },
	{ id = "barn", name = "Old barn in Iowa", cost = 400e3, rent = 3e3, slots = 160, kw = 150, desc = "Cheap land, cheap power, lots of cows." },
	{ id = "mall", name = "Empty shopping mall", cost = 1.5e6, rent = 15e3, slots = 400, kw = 450, desc = "The food court is now a server room." },
	{ id = "texas", name = "Warehouse in Texas", cost = 6e6, rent = 70e3, slots = 1600, kw = 1.8e3, desc = "Big, cheap and the grid mostly holds." },
	{ id = "bunker", name = "Underground bunker", cost = 9e6, rent = 60e3, slots = 1200, kw = 1.4e3, desc = "Old military bunker. Nobody is stealing these GPUs." },
	{ id = "iceland", name = "Datacenter in Iceland", cost = 25e6, rent = 200e3, slots = 6000, kw = 8e3, desc = "Free cooling from the cold and geothermal power." },
	{ id = "norway", name = "Fjord datacenter, Norway", cost = 60e6, rent = 500e3, slots = 14000, kw = 18e3, desc = "Cooled by sea water, powered by waterfalls." },
	{ id = "nevada", name = "Desert lot in Nevada", cost = 90e6, rent = 600e3, slots = 20000, kw = 30e3, desc = "Solar panels as far as you can see." },
	{ id = "virginia", name = "Data hall in Virginia", cost = 220e6, rent = 2.5e6, slots = 50000, kw = 70e3, desc = "Where the internet lives." },
	{ id = "uae", name = "Campus in Abu Dhabi", cost = 600e6, rent = 6e6, slots = 120000, kw = 180e3, desc = "Oil money meets AI money." },
	{ id = "nuclear", name = "Site next to a nuclear plant", cost = 1.2e9, rent = 12e6, slots = 220000, kw = 400e3, desc = "Your own reactor's worth of power." },
	{ id = "ocean", name = "Floating ocean datacenter", cost = 1.8e9, rent = 15e6, slots = 260000, kw = 450e3, desc = "A ship full of servers, cooled by the sea." },
	{ id = "gigawatt", name = "Gigawatt supercluster", cost = 8e9, rent = 70e6, slots = 1200000, kw = 2e6, desc = "The biggest computer ever built." },
	{ id = "moon", name = "Datacenter on the Moon", cost = 60e9, rent = 300e6, slots = 6000000, kw = 9e6, desc = "Cold, quiet and very far from regulators." },
	{ id = "datacenter", name = "Hyperscale datacenter", cost = 2.5e9, rent = 25e6, slots = 400000, kw = 700e3, desc = "Your own campus of servers in the desert." },
}
table.sort(C.storage, function(a, b)
	return a.cost < b.cost
end)
C.storageById = {}
for _, st in ipairs(C.storage) do
	C.storageById[st.id] = st
end

-- Model updates (Lab > Models > Update). req = research node. days = in-game days.
C.updates = {
	{ id = "smarter", name = "Continue training", desc = "More compute on the same model. +2 to +4 capability.", days = 20, costMult = 0.35, cap = 3 },
	{ id = "posttrain", name = "New post-training round", desc = "Fresh RLHF data. +1.5 capability, nicer answers.", days = 10, cost = 400e3, cap = 1.5, req = "rlhf" },
	{ id = "reasoning", name = "Add reasoning mode", desc = "Thinks before answering. Big jump on math and code.", days = 18, cost = 3e6, cap = 5, feature = "reasoning", req = "reasoning" },
	{ id = "vision", name = "Add vision", desc = "See images and screenshots.", days = 14, cost = 1.2e6, feature = "vision", req = "vision" },
	{ id = "voice", name = "Add voice mode", desc = "Talk to it out loud.", days = 16, cost = 2e6, feature = "voice", req = "voice" },
	{ id = "imagegen", name = "Add image generation", desc = "Draws pictures in chat. Viral potential.", days = 20, cost = 4e6, feature = "imagegen", req = "imagegen" },
	{ id = "tools", name = "Add tool use", desc = "Web search, code execution, function calling.", days = 10, cost = 600e3, feature = "tools", req = "tools" },
	{ id = "agents", name = "Agent mode", desc = "Long autonomous tasks. Watch the escape risk.", days = 25, cost = 8e6, feature = "agents", req = "agents", escape = 0.08 },
	{ id = "computer", name = "Computer use", desc = "Clicks and types on a real screen.", days = 18, cost = 3e6, feature = "computer", req = "computeruse" },
	{ id = "longctx", name = "1M context", desc = "Read whole codebases.", days = 12, cost = 1.5e6, context = 1e6, req = "longctx" },
	{ id = "mini", name = "Distill a mini version", desc = "A small, cheap sibling for the free tier. 1/5 serving cost.", days = 10, cost = 500e3, req = "distill", spawnMini = true },
	{ id = "safety", name = "Safety patch", desc = "Closes jailbreaks. Slightly more refusals.", days = 3, cost = 150e3, safety = 12 },
	{ id = "honest", name = "Anti-sycophancy fix", desc = "Stops it flattering users.", days = 6, cost = 300e3, syco = -0.2, req = "honesty" },
	{ id = "speed", name = "Inference optimisation", desc = "Speculative decoding + caching. 40% cheaper to serve.", days = 8, cost = 800e3, serve = 0.6 },
	{ id = "persona", name = "Personality refresh", desc = "Warmer, funnier, less corporate.", days = 6, cost = 250e3, refuse = -0.1, hype = 4 },
}

C.goalPool = {
	{ id = "train", text = "Train a model", target = 1, reward = 60e3 },
	{ id = "release", text = "Release a model", target = 1, reward = 90e3 },
	{ id = "hire", text = "Hire %d people", target = 2, reward = 50e3 },
	{ id = "research", text = "Finish a research project", target = 1, reward = 70e3 },
	{ id = "users", text = "Gain %s new users", target = 20e3, reward = 80e3, scale = true },
	{ id = "gpus", text = "Add %d GPUs", target = 8, reward = 60e3 },
	{ id = "eval", text = "Run a pre-launch eval", target = 1, reward = 40e3 },
	{ id = "chat", text = "Test a model in the playground %d times", target = 3, reward = 30e3 },
	{ id = "update", text = "Ship a model update", target = 1, reward = 70e3 },
}

C.investors = {
	{ name = "Sandhill Partners", kind = "VC", blurb = "Classic Silicon Valley money. Board seat included." },
	{ name = "Peregrine Capital", kind = "VC", blurb = "Fast decisions, founder-friendly terms." },
	{ name = "Northwind Ventures", kind = "VC", blurb = "Loves research-heavy teams." },
	{ name = "Halcyon Growth", kind = "Growth fund", blurb = "Writes huge checks at high valuations." },
	{ name = "Atlas Sovereign Fund", kind = "Sovereign fund", blurb = "Infinite patience, infinite money, some strings." },
	{ name = "Copperleaf Angels", kind = "Angels", blurb = "Ex-founders who have done this before." },
	{ name = "Meridian Strategic", kind = "Big Tech", blurb = "Cloud credits instead of cash, partly." },
	{ name = "Bluefin Crossover", kind = "Crossover fund", blurb = "Wants you to IPO eventually." },
}

return C
