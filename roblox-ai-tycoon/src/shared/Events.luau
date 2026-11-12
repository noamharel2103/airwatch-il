--!strict
-- World events ("admin abuse"): the creator starts them from the F2 console. They run in every
-- server at once and boost everybody. Each has a multiplier table the game reads.
local Events = {}

Events.list = {
	{ id = "lucky", name = "LUCKY HOUR", desc = "Double luck: better training, launches and hires", color = Color3.fromRGB(0, 220, 120), fx = { luck = 2 } },
	{ id = "money", name = "MONEY RAIN", desc = "Every company earns 3x money", color = Color3.fromRGB(255, 200, 40), fx = { cash = 3 } },
	{ id = "hyper", name = "HYPER TRAINING", desc = "All training runs 3x faster", color = Color3.fromRGB(150, 80, 255), fx = { train = 3 } },
	{ id = "peace", name = "WORLD PEACE", desc = "Nothing breaks. No crises at all", color = Color3.fromRGB(0, 180, 255), fx = { noCrisis = true } },
	{ id = "viral", name = "VIRAL WAVE", desc = "Users grow 3x faster", color = Color3.fromRGB(255, 70, 160), fx = { users = 3 } },
	{ id = "gpusale", name = "GPU MEGA SALE", desc = "Every GPU costs half", color = Color3.fromRGB(255, 140, 20), fx = { gpuPrice = 0.5 } },
	{ id = "legends", name = "LEGEND WEEK", desc = "Recruiters only find RARE or better, and everyone says yes", color = Color3.fromRGB(255, 185, 0), fx = { legends = true } },
	{ id = "gifts", name = "GIFT STORM", desc = "Playtime gifts every minute", color = Color3.fromRGB(255, 70, 90), fx = { gifts = true } },
	{ id = "abuse", name = "ADMIN ABUSE", desc = "EVERYTHING AT ONCE", color = Color3.fromRGB(255, 40, 40), fx = { luck = 3, cash = 5, train = 4, noCrisis = true, users = 4, gpuPrice = 0.3, legends = true, gifts = true } },
}
Events.byId = {}
for _, e in ipairs(Events.list) do
	Events.byId[e.id] = e
end
Events.ids = {}
for _, e in ipairs(Events.list) do
	table.insert(Events.ids, e.id)
end

-- active = { [id] = endsAt (os.time) }. Returns the combined multipliers right now.
function Events.combined(active: { [string]: number }?, now: number)
	local out = { luck = 1, cash = 1, train = 1, users = 1, gpuPrice = 1, noCrisis = false, legends = false, gifts = false }
	for id, ends in pairs(active or {}) do
		local e = Events.byId[id]
		if e and ends > now then
			for k, v in pairs(e.fx) do
				if type(v) == "number" then
					if k == "gpuPrice" then
						out[k] = math.min(out[k], v)
					else
						out[k] = math.max(out[k], v)
					end
				else
					out[k] = out[k] or v
				end
			end
		end
	end
	return out
end

return Events
