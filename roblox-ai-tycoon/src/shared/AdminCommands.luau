-- F2 admin console commands (Cmdr definitions WITHOUT Run) + the touch ADMIN PANEL buttons.
-- The code for each command lives in server/AdminCommandsServer.luau under the same Name.
-- Enums become Cmdr argument types (autocomplete in the console).
-- Panel buttons only name a command (op) and its preset args: the server reads them from its
-- own copy of this module, so a client can only pick a button id, never send its own values.
local Shop = require(script.Parent:WaitForChild("Shop"))
local Staff = require(script.Parent:WaitForChild("Staff"))

-- "all" = every pass and every product at once (give all / take all)
local shopItems = { "all" }
local passKeys = {}
for _, p in ipairs(Shop.passes) do
	table.insert(shopItems, p.key)
	table.insert(passKeys, p.key)
end
for _, p in ipairs(Shop.products) do
	table.insert(shopItems, p.key)
end

local Events = require(script.Parent:WaitForChild("Events"))
local eventNames = table.clone(Events.ids)
local endNames = table.clone(Events.ids)
table.insert(endNames, "all")

local rarities = {}
for _, r in ipairs(Staff.RARITIES) do
	table.insert(rarities, r.id)
end
local roles = { "any" }
for _, r in ipairs(Staff.roles) do
	table.insert(roles, r.id)
end

local TROLLS = { "shake", "spin", "upsidedown", "jumpscare", "fakeban", "blind", "rainbow", "fakemoney", "popups", "tiny" }

local function players(desc)
	return { Type = "players", Name = "players", Description = desc or "Who (name, me, all, others)" }
end

local function cmd(name, desc, args, aliases)
	return { Name = name, Aliases = aliases, Description = desc, Group = "Admin", Args = args or {} }
end

-- ===== touch ADMIN PANEL (client/AdminPanel.client.luau) =====
-- global = runs for the whole server and ignores the picked target.
local passItems = {}
for _, p in ipairs(Shop.passes) do
	table.insert(passItems, { id = "pass30_" .. p.key, label = p.name .. " 30 MIN", icon = p.icon, color = p.color, op = "givepass", args = { p.key, 30 } })
	table.insert(passItems, { id = "passF_" .. p.key, label = p.name .. " FOREVER", icon = p.icon, color = p.color, op = "givepass", args = { p.key, 0 } })
end
table.insert(passItems, { id = "takeall", label = "TAKE GIFTED PASSES", icon = "shield", color = Color3.fromRGB(255, 70, 85), op = "takeall", args = {} })

local eventItems = {}
for _, e in ipairs(Events.list) do
	table.insert(eventItems, { id = "ev15_" .. e.id, label = e.name .. " 15 MIN", icon = "bolt", color = e.color, op = "serverevent", args = { e.id, 15 } })
	table.insert(eventItems, { id = "ev60_" .. e.id, label = e.name .. " 1 HOUR", icon = "clock", color = e.color, op = "serverevent", args = { e.id, 60 } })
end
table.insert(eventItems, { id = "evstop", label = "STOP ALL EVENTS", icon = "shield", color = Color3.fromRGB(255, 70, 85), op = "endevent", args = { "all" } })

local GOLD = Color3.fromRGB(255, 185, 0)
local GREEN = Color3.fromRGB(0, 205, 95)
local PURPLE = Color3.fromRGB(150, 80, 255)
local BLUE = Color3.fromRGB(0, 170, 255)
local ORANGE = Color3.fromRGB(255, 130, 20)
local PINK = Color3.fromRGB(255, 60, 130)

local Panel = {
	{
		title = "CASH",
		items = {
			{ id = "cashx2", label = "CASH X2", icon = "cash", color = GREEN, op = "cashx", args = { 2 } },
			{ id = "cashx10", label = "CASH X10", icon = "cash", color = GREEN, op = "cashx", args = { 10 } },
			{ id = "cashx100", label = "CASH X100", icon = "vault", color = GOLD, op = "cashx", args = { 100 } },
			{ id = "cash1m", label = "+$1M", icon = "cash", color = GREEN, op = "givecash", args = { 1e6 } },
			{ id = "cash100m", label = "+$100M", icon = "vault", color = GREEN, op = "givecash", args = { 100e6 } },
			{ id = "cash10b", label = "+$10B", icon = "crown", color = GOLD, op = "givecash", args = { 10e9 } },
			{ id = "giveall", label = "GIVE EVERYTHING", icon = "crown", color = PINK, op = "give", args = { "all" } },
		},
	},
	{
		title = "LUCK",
		items = {
			{ id = "luck2x15", label = "LUCK X2 15 MIN", icon = "trophy", color = GREEN, op = "luck", args = { 2, 15 } },
			{ id = "luck2x60", label = "LUCK X2 1 HOUR", icon = "trophy", color = GREEN, op = "luck", args = { 2, 60 } },
			{ id = "luck5x15", label = "LUCK X5 15 MIN", icon = "trophy", color = GOLD, op = "luck", args = { 5, 15 } },
			{ id = "luck10x10", label = "LUCK X10 10 MIN", icon = "crown", color = PINK, op = "luck", args = { 10, 10 } },
			{ id = "clearboosts", label = "REMOVE BOOSTS", icon = "shield", color = Color3.fromRGB(255, 70, 85), op = "clearboosts", args = {} },
		},
	},
	{
		title = "WORKERS",
		items = {
			{ id = "wrare", label = "RARE WORKER", icon = "team", color = BLUE, op = "worker", args = { "rare", "any", 1 } },
			{ id = "wepic", label = "EPIC WORKER", icon = "team", color = PURPLE, op = "worker", args = { "epic", "any", 1 } },
			{ id = "wlegend", label = "LEGENDARY WORKER", icon = "team", color = GOLD, op = "worker", args = { "legend", "any", 1 } },
			{ id = "wmythic", label = "MYTHIC WORKER", icon = "team", color = PINK, op = "worker", args = { "mythic", "any", 1 } },
			{ id = "wmythic5", label = "5 MYTHIC WORKERS", icon = "crown", color = PINK, op = "worker", args = { "mythic", "any", 5 } },
			{ id = "wstar3", label = "3 LEGENDARY STARS", icon = "brain", color = GOLD, op = "worker", args = { "legend", "star", 3 } },
		},
	},
	{
		title = "GPUS",
		items = {
			{ id = "gpusmall", label = "SMALL GPU PACK", icon = "gpu", color = BLUE, op = "gpupack", args = { "small" } },
			{ id = "gpumedium", label = "BIG GPU PACK", icon = "gpu", color = PURPLE, op = "gpupack", args = { "medium" } },
			{ id = "gpularge", label = "MEGA DATACENTER", icon = "gpu", color = GOLD, op = "gpupack", args = { "large" } },
			{ id = "office1", label = "OFFICE UPGRADE", icon = "company", color = ORANGE, op = "office", args = { 1 } },
		},
	},
	{
		title = "COMPANY",
		items = {
			{ id = "finish", label = "FINISH TRAINING", icon = "bolt", color = PURPLE, op = "finish", args = {} },
			{ id = "heal", label = "FIX ALL PROBLEMS", icon = "shield", color = BLUE, op = "heal", args = {} },
			{ id = "resetcd", label = "RESET COOLDOWNS", icon = "clock", color = ORANGE, op = "resetcd", args = {} },
			{ id = "users100k", label = "+100K USERS", icon = "chat", color = PINK, op = "users", args = { 100e3 } },
			{ id = "users10m", label = "+10M USERS", icon = "fire", color = PINK, op = "users", args = { 10e6 } },
			{ id = "hype", label = "MAX HYPE", icon = "fire", color = ORANGE, op = "hype", args = { 100 } },
			{ id = "msuper", label = "MODEL +10 STATS", icon = "brain", color = PINK, op = "modelboost", args = { "super" } },
			{ id = "mmega", label = "MODEL +30 STATS", icon = "brain", color = GOLD, op = "modelboost", args = { "mega" } },
			{ id = "skip7", label = "SKIP 7 DAYS", icon = "clock", color = BLUE, op = "skipdays", args = { 7 } },
			{ id = "skip30", label = "SKIP 30 DAYS", icon = "clock", color = PURPLE, op = "skipdays", args = { 30 } },
		},
	},
	{ title = "PASSES", items = passItems },
	{ title = "EVENTS", global = true, note = "Events run for the whole server. The target is ignored.", items = eventItems },
	{
		title = "FUN",
		items = {
			{ id = "jackpot", label = "JACKPOT", icon = "gift", color = GOLD, op = "jackpot", args = {} },
			{ id = "tshake", label = "SHAKE SCREEN", icon = "bolt", color = ORANGE, op = "troll", args = { "shake", 5 } },
			{ id = "tfakeban", label = "FAKE BAN", icon = "shield", color = Color3.fromRGB(255, 70, 85), op = "troll", args = { "fakeban", 6 } },
			{ id = "tscare", label = "JUMPSCARE", icon = "fire", color = Color3.fromRGB(255, 70, 85), op = "troll", args = { "jumpscare", 3 } },
			{ id = "trainbow", label = "RAINBOW", icon = "image", color = PINK, op = "troll", args = { "rainbow", 8 } },
			{ id = "tmoney", label = "FAKE MONEY", icon = "cash", color = GREEN, op = "troll", args = { "fakemoney", 5 } },
			{ id = "untroll", label = "STOP PRANKS", icon = "gear", color = BLUE, op = "untroll", args = {} },
		},
	},
}

return {
	Enums = {
		shopItem = shopItems,
		passKey = passKeys,
		troll = TROLLS,
		worldEvent = eventNames,
		worldEventOrAll = endNames,
		workerRarity = rarities,
		workerRole = roles,
		gpuPack = { "small", "medium", "large" },
		modelBoost = { "super", "mega" },
	},
	Panel = Panel,
	Commands = {
		cmd("announce", "Big announcement on everyone's screen", {
			{ Type = "string", Name = "text", Description = "What to announce" },
		}, { "ann" }),
		cmd("pm", "Big private message on the screen of the players you pick", {
			players(),
			{ Type = "string", Name = "text", Description = "The message" },
		}),
		cmd("give", "Give a shop item for free (pass forever, or product). Use all to give EVERYTHING in the shop", {
			players(),
			{ Type = "shopItem", Name = "item", Description = "Shop item" },
		}),
		cmd("take", "Take back a gifted pass", {
			players(),
			{ Type = "shopItem", Name = "item", Description = "Pass to remove" },
		}),
		cmd("givecash", "Add (or remove with a minus) company cash", {
			players(),
			{ Type = "number", Name = "amount", Description = "How much" },
		}, { "cash" }),
		cmd("cashx", "Multiply company cash (2 to 1000). Broke companies get a gift instead", {
			players(),
			{ Type = "number", Name = "multiplier", Description = "Times how much (2 to 1000)" },
		}),
		cmd("luck", "Personal luck boost for some minutes (better hires, training, launches)", {
			players(),
			{ Type = "number", Name = "multiplier", Description = "Luck times (1.1 to 10)" },
			{ Type = "number", Name = "minutes", Description = "How long (default 15, max 1440)", Optional = true },
		}),
		cmd("worker", "Give free workers of a rarity (needs free desks)", {
			players(),
			{ Type = "workerRarity", Name = "rarity", Description = "Rarity" },
			{ Type = "workerRole", Name = "role", Description = "Job, or any (default any)", Optional = true },
			{ Type = "number", Name = "count", Description = "How many (default 1, max 20)", Optional = true },
		}),
		cmd("gpupack", "Give a free GPU pack with room and power for it", {
			players(),
			{ Type = "gpuPack", Name = "size", Description = "small, medium or large" },
		}),
		cmd("finish", "Instantly finish the training and stat training running now", {
			players(),
		}),
		cmd("givepass", "Gift a Robux pass for some minutes, or forever with 0", {
			players(),
			{ Type = "passKey", Name = "pass", Description = "Which pass" },
			{ Type = "number", Name = "minutes", Description = "Minutes, 0 or empty = forever", Optional = true },
		}),
		cmd("takeall", "Take back every gifted pass (timed and forever)", {
			players(),
		}),
		cmd("users", "Add app users", {
			players(),
			{ Type = "number", Name = "amount", Description = "How many users" },
		}),
		cmd("hype", "Add hype (0 to 100 total)", {
			players(),
			{ Type = "number", Name = "amount", Description = "How much hype" },
		}),
		cmd("skipdays", "Run the game forward some days right now", {
			players(),
			{ Type = "number", Name = "days", Description = "Days (1 to 60)" },
		}),
		cmd("heal", "Fix every live problem and keep it calm for 30 days", {
			players(),
		}),
		cmd("office", "Free office upgrade", {
			players(),
			{ Type = "number", Name = "steps", Description = "How many levels (default 1)", Optional = true },
		}),
		cmd("resetcd", "Reset cooldowns: parties, limit reset, lab talks", {
			players(),
		}),
		cmd("modelboost", "Boost every stat of the open model (super = +10, mega = +30)", {
			players(),
			{ Type = "modelBoost", Name = "kind", Description = "super or mega" },
		}),
		cmd("jackpot", "Cash x10, luck x2 for 30 min, a legendary worker, GPUs and no problems", {
			players(),
		}),
		cmd("clearboosts", "Remove personal luck boosts and timed passes", {
			players(),
		}),
		cmd("boosts", "Show the personal boosts these players have", {
			players(),
		}),
		cmd("troll", "Prank players: " .. table.concat(TROLLS, ", "), {
			players(),
			{ Type = "troll", Name = "kind", Description = "Which prank" },
			{ Type = "number", Name = "seconds", Description = "How long (default 5)", Optional = true },
		}),
		cmd("untroll", "Stop every prank on these players right now", {
			players(),
		}),
		cmd("event", "Start a world event in EVERY server: " .. table.concat(eventNames, ", "), {
			{ Type = "worldEvent", Name = "event", Description = "Which event" },
			{ Type = "number", Name = "minutes", Description = "How long (default 15)", Optional = true },
		}, { "abuse" }),
		cmd("serverevent", "Start a world event in THIS server only", {
			{ Type = "worldEvent", Name = "event", Description = "Which event" },
			{ Type = "number", Name = "minutes", Description = "How long (default 15)", Optional = true },
		}),
		cmd("endevent", "Stop a world event (or all) in every server", {
			{ Type = "worldEventOrAll", Name = "event", Description = "Which event, or all" },
		}),
	},
}
