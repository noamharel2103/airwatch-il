-- F2 admin console commands (Cmdr definitions WITHOUT Run).
-- The code for each command lives in server/AdminCommandsServer.luau under the same Name.
-- Enums become Cmdr argument types (autocomplete in the console).
local Shop = require(script.Parent:WaitForChild("Shop"))

local shopItems = {}
for _, p in ipairs(Shop.passes) do
	table.insert(shopItems, p.key)
end
for _, p in ipairs(Shop.products) do
	table.insert(shopItems, p.key)
end

local TROLLS = { "shake", "spin", "upsidedown", "jumpscare", "fakeban", "blind", "rainbow", "fakemoney", "popups", "tiny" }

local function players(desc)
	return { Type = "players", Name = "players", Description = desc or "Who (name, me, all, others)" }
end

return {
	Enums = {
		shopItem = shopItems,
		troll = TROLLS,
	},
	Commands = {
		{
			Name = "announce",
			Aliases = { "ann" },
			Description = "Big announcement on everyone's screen",
			Group = "Admin",
			Args = {
				{ Type = "string", Name = "text", Description = "What to announce" },
			},
		},
		{
			Name = "pm",
			Description = "Big private message on the screen of the players you pick",
			Group = "Admin",
			Args = {
				players(),
				{ Type = "string", Name = "text", Description = "The message" },
			},
		},
		{
			Name = "give",
			Description = "Give a shop item (pass or product) for free",
			Group = "Admin",
			Args = {
				players(),
				{ Type = "shopItem", Name = "item", Description = "Shop item" },
			},
		},
		{
			Name = "take",
			Description = "Take back a gifted pass",
			Group = "Admin",
			Args = {
				players(),
				{ Type = "shopItem", Name = "item", Description = "Pass to remove" },
			},
		},
		{
			Name = "givecash",
			Aliases = { "cash" },
			Description = "Add (or remove with a minus) company cash",
			Group = "Admin",
			Args = {
				players(),
				{ Type = "number", Name = "amount", Description = "How much" },
			},
		},
		{
			Name = "troll",
			Description = "Prank players: " .. table.concat(TROLLS, ", "),
			Group = "Admin",
			Args = {
				players(),
				{ Type = "troll", Name = "kind", Description = "Which prank" },
				{ Type = "number", Name = "seconds", Description = "How long (default 5)", Optional = true },
			},
		},
		{
			Name = "untroll",
			Description = "Stop every prank on these players right now",
			Group = "Admin",
			Args = {
				players(),
			},
		},
	},
}
