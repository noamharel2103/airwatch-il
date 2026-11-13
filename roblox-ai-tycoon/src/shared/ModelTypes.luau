--!strict
-- Kinds of AI you can build. CHAT goes into your app (users). Every other kind is its own
-- product: once launched, your best model of that kind earns money every day by itself.
-- market = monthly revenue (2023 dollars) for a model as good as today's best AI.
local Format = require(script.Parent:WaitForChild("Format"))
local MT = {}

MT.list = {
	{ id = "chat", name = "CHAT AI", short = "CHAT", from = "2023-01", cost = 1, time = 1, market = 0, color = Color3.fromRGB(0, 190, 255), icon = "chat", desc = "Your main app. Brings users and subscriptions." },
	{ id = "image", name = "IMAGE AI", short = "IMAGE", from = "2023-01", cost = 0.8, time = 1.5, market = 2e6, color = Color3.fromRGB(255, 70, 160), icon = "image", desc = "Draws pictures from text." },
	{ id = "voice", name = "VOICE AI", short = "VOICE", from = "2023-06", cost = 0.9, time = 2.5, market = 1.6e6, color = Color3.fromRGB(255, 150, 0), icon = "voice", desc = "Talks with any voice, in any language." },
	{ id = "music", name = "MUSIC AI", short = "MUSIC", from = "2024-01", cost = 1.1, time = 3, market = 2.2e6, color = Color3.fromRGB(150, 80, 255), icon = "music", desc = "Makes full songs with singing." },
	{ id = "video", name = "VIDEO AI", short = "VIDEO", from = "2024-02", cost = 2, time = 4, market = 5e6, color = Color3.fromRGB(255, 60, 70), icon = "video", desc = "Films movie clips from one sentence. Very hungry for GPUs." },
	{ id = "world3d", name = "3D WORLD AI", short = "3D", from = "2025-01", cost = 1.8, time = 4, market = 6e6, color = Color3.fromRGB(0, 200, 190), icon = "cube", desc = "Builds 3D worlds and game assets." },
	{ id = "robot", name = "ROBOT BRAIN", short = "ROBOT", from = "2026-01", cost = 3, time = 6, market = 12e6, color = Color3.fromRGB(255, 200, 0), icon = "robot", desc = "Runs real robots in factories and homes." },
}

MT.byId = {}
for _, k in ipairs(MT.list) do
	k.fromDay = Format.dayFromString(k.from)
	MT.byId[k.id] = k
end

function MT.get(id: string?)
	return MT.byId[id or "chat"] or MT.byId.chat
end

function MT.unlocked(k, day: number): boolean
	return day >= k.fromDay
end

-- Daily income of one launched model of this kind. quality = avg stat / today's best (0..1.5).
function MT.dailyIncome(k, quality: number, year: number, difficulty: number): number
	if k.market <= 0 then
		return 0
	end
	local q = math.clamp(quality, 0, 1.5)
	return k.market / 30 * q ^ 2.5 * 1.6 ^ math.max(0, year - 2023) / math.sqrt(difficulty)
end

return MT
