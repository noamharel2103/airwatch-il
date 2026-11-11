--!strict
-- Turns the internal capability index (+ domain bonuses) into realistic public benchmark numbers.
-- Benchmarks appear and saturate on their real schedule (research 09 §6.5).
local Format = require(script.Parent:WaitForChild("Format"))
local B = {}

local function sig(x: number): number
	return 1 / (1 + math.exp(-x))
end

-- domain: which ability drives it. mid/width shape the S-curve on the capability axis.
B.list = {
	{ id = "mmlu", name = "MMLU", domain = "knowledge", floor = 25, top = 93, mid = 42, width = 9, from = "2020-01", to = "2025-06" },
	{ id = "gsm8k", name = "GSM8K", domain = "math", floor = 5, top = 97, mid = 45, width = 7, from = "2021-01", to = "2024-12" },
	{ id = "humaneval", name = "HumanEval", domain = "coding", floor = 0, top = 97, mid = 48, width = 8, from = "2021-01", to = "2025-03" },
	{ id = "gpqa", name = "GPQA Diamond", domain = "reasoning", floor = 25, top = 93, mid = 64, width = 8, from = "2023-11", to = "2027-06" },
	{ id = "math", name = "MATH", domain = "math", floor = 3, top = 98, mid = 56, width = 7, from = "2021-03", to = "2025-09" },
	{ id = "aime", name = "AIME", domain = "math", floor = 0, top = 100, mid = 66, width = 6, from = "2024-01", to = "2027-01" },
	{ id = "swe", name = "SWE-bench Verified", domain = "coding", floor = 0, top = 95, mid = 72, width = 7, from = "2024-08", to = "2027-12" },
	{ id = "hle", name = "Humanity's Last Exam", domain = "reasoning", floor = 2, top = 90, mid = 98, width = 9, from = "2025-01", to = "2030-01" },
	{ id = "arc2", name = "ARC-AGI-2", domain = "reasoning", floor = 0, top = 98, mid = 85, width = 4, from = "2025-03", to = "2027-06" },
	{ id = "arc3", name = "ARC-AGI-3", domain = "reasoning", floor = 0, top = 98, mid = 100, width = 5, from = "2026-03", to = "2030-01" },
	{ id = "osworld", name = "OSWorld", domain = "agents", floor = 5, top = 90, mid = 80, width = 8, from = "2024-04", to = "2028-06" },
	{ id = "mmmu", name = "MMMU (vision)", domain = "vision", floor = 25, top = 90, mid = 60, width = 10, from = "2023-11", to = "2027-01" },
	{ id = "frontier", name = "FrontierMath", domain = "math", floor = 0, top = 90, mid = 104, width = 7, from = "2024-11", to = "2032-01" },
	{ id = "remotelabor", name = "Remote Labor Index", domain = "agents", floor = 0, top = 95, mid = 110, width = 8, from = "2026-06", to = "2035-01" },
}

for _, b in ipairs(B.list) do
	b.fromDay = Format.dayFromString(b.from)
	b.toDay = Format.dayFromString(b.to)
end

-- abilities: { knowledge, math, coding, reasoning, agents, vision, ... } in capability points
function B.score(b: any, abilities: { [string]: number }, cap: number): number
	local eff = cap + (abilities[b.domain] or 0)
	if b.domain == "vision" and (abilities.vision or 0) <= 0 then
		return 0
	end
	return b.floor + (b.top - b.floor) * sig((eff - b.mid) / b.width)
end

function B.active(day: number): { any }
	local out = {}
	for _, b in ipairs(B.list) do
		if day >= b.fromDay and day <= b.toDay then
			table.insert(out, b)
		end
	end
	return out
end

-- Arena Elo on a contemporary-ish scale.
function B.elo(cap: number, writingBonus: number): number
	return math.floor(900 + 6.4 * cap + writingBonus * 0.8)
end

return B
