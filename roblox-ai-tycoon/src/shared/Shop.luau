--!strict
-- Robux shop: Game Passes (forever, per account) and Developer Products (one-time boosts).
-- Put the real ids from Creator Hub (Monetization) into `id`. While an id is 0:
--   in Studio the BUY button grants it for free (test mode), in a live server it shows SOON.
local Shop = {}

Shop.passes = {
	{ key = "cash2x", id = 0, robux = 199, name = "2X CASH", desc = "Every dollar your app earns is doubled. Forever.", color = Color3.fromRGB(0, 205, 95), icon = "cash" },
	{ key = "train2x", id = 0, robux = 249, name = "2X TRAINING", desc = "Stat training gives double points and models train twice as fast.", color = Color3.fromRGB(150, 80, 255), icon = "brain" },
	{ key = "shield", id = 0, robux = 149, name = "CRISIS SHIELD", desc = "Outages and hacks are 75% rarer and get fixed 3x faster.", color = Color3.fromRGB(0, 170, 255), icon = "shield" },
	{ key = "gpu3x", id = 0, robux = 179, name = "GPU CONNECT", desc = "Triple GPU allocation and +50% power from every GPU.", color = Color3.fromRGB(255, 130, 20), icon = "gpu" },
	{ key = "speed8", id = 0, robux = 99, name = "TIME WARP x8", desc = "Unlocks x8 game speed. Crises do not get worse at x8.", color = Color3.fromRGB(255, 60, 130), icon = "clock" },
	{ key = "vip", id = 0, robux = 399, name = "VIP CEO", desc = "+50% users, investors pay 50% more, gold name, daily VIP cash.", color = Color3.fromRGB(255, 190, 0), icon = "crown" },
}

Shop.products = {
	{ key = "cash1", id = 0, robux = 25, name = "BAG OF CASH", cash = 2e6, color = Color3.fromRGB(0, 205, 95), icon = "cash" },
	{ key = "cash2", id = 0, robux = 99, name = "CASH STACK", cash = 15e6, color = Color3.fromRGB(0, 185, 80), icon = "cash" },
	{ key = "cash3", id = 0, robux = 299, name = "CASH VAULT", cash = 80e6, color = Color3.fromRGB(0, 160, 70), icon = "vault" },
	{ key = "cash4", id = 0, robux = 799, name = "BILLIONAIRE", cash = 400e6, color = Color3.fromRGB(255, 190, 0), icon = "crown" },
	{ key = "finish", id = 0, robux = 39, name = "INSTANT FINISH", desc = "Finish every training run right now.", color = Color3.fromRGB(150, 80, 255), icon = "bolt" },
	{ key = "stats10", id = 0, robux = 79, name = "SUPER BOOST", desc = "+10 to every stat of the model you have open. Ignores the yearly limit.", color = Color3.fromRGB(255, 60, 130), icon = "brain" },
	{ key = "fixall", id = 0, robux = 35, name = "FIX EVERYTHING", desc = "Every crisis fixed now, and no new crisis for 90 days.", color = Color3.fromRGB(0, 170, 255), icon = "shield" },
	{ key = "gpudrop", id = 0, robux = 149, name = "GPU DROP", desc = "A pallet of the best GPUs of the year, delivered free.", color = Color3.fromRGB(255, 130, 20), icon = "gpu" },
	{ key = "stars", id = 0, robux = 99, name = "STAR TEAM", desc = "5 star researchers join today, free signing.", color = Color3.fromRGB(0, 190, 200), icon = "team" },
	{ key = "viral", id = 0, robux = 59, name = "GO VIRAL", desc = "Your app trends worldwide: +40% users and big hype.", color = Color3.fromRGB(255, 70, 85), icon = "fire" },
}

Shop.passByKey = {}
for _, p in ipairs(Shop.passes) do
	Shop.passByKey[p.key] = p
end
Shop.productByKey = {}
Shop.productById = {}
for _, p in ipairs(Shop.products) do
	Shop.productByKey[p.key] = p
	if p.id ~= 0 then
		Shop.productById[p.id] = p
	end
end

-- Cash packs grow with the era so they stay useful late game.
function Shop.cashFor(p, year: number): number
	return (p.cash or 0) * (1 + math.max(0, year - 2023) * 1.5)
end

return Shop
