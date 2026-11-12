--!strict
-- Real accelerators with year-correct prices (research 09 §4.1–4.2).
-- power = training throughput relative to one H100 (effective, incl. typical MFU).
-- buy[year] = unit price USD, rent[year] = $/GPU-hour on-demand. nil = not available that year.
local Hardware = {}

Hardware.H100_FLOP_PER_DAY = 3.4e19 -- 989 TF bf16 at ~40% MFU

Hardware.list = {
	{ id = "laptop", name = "Your gaming laptop", vendor = "Volta", from = "2023-01", power = 0.03, mem = 16, kw = 0.2, buy = { [2023] = 2500 }, rent = { [2023] = 0.3 }, blurb = "It gets hot. Very hot." },
	{ id = "rtx4090", name = "Volta G90 gamer card", vendor = "Volta", from = "2023-01", power = 0.12, mem = 24, kw = 0.45, buy = { [2023] = 1800, [2024] = 1900, [2025] = 2200, [2026] = 2600 }, rent = { [2023] = 0.7, [2024] = 0.5, [2025] = 0.4, [2026] = 0.4 }, blurb = "A gaming card. Your bedroom starter rig." },
	{ id = "a100", name = "Volta A1", vendor = "Volta", from = "2023-01", power = 0.33, mem = 80, kw = 0.4, buy = { [2023] = 15000, [2024] = 12000, [2025] = 9000, [2026] = 8000 }, rent = { [2023] = 2.8, [2024] = 1.8, [2025] = 1.3, [2026] = 1.0 }, blurb = "The workhorse that trained the first big chatbots." },
	{ id = "h100", name = "Volta H1", vendor = "Volta", from = "2023-03", power = 1, mem = 80, kw = 0.7, buy = { [2023] = 38000, [2024] = 30000, [2025] = 25000, [2026] = 22000 }, rent = { [2023] = 6.0, [2024] = 3.2, [2025] = 2.3, [2026] = 3.4 }, blurb = "Allocation-only in 2023. Everyone wants one." },
	{ id = "mi300x", name = "Redline R3", vendor = "Redline", from = "2024-01", power = 0.9, mem = 192, kw = 0.75, buy = { [2024] = 15000, [2025] = 12000, [2026] = 10000 }, rent = { [2024] = 3.5, [2025] = 2.0, [2026] = 1.8 }, blurb = "Huge memory, cheaper than Volta, software is rougher." },
	{ id = "h200", name = "Volta H2", vendor = "Volta", from = "2024-07", power = 1.25, mem = 141, kw = 0.7, buy = { [2024] = 35000, [2025] = 32000, [2026] = 28000 }, rent = { [2024] = 5.0, [2025] = 3.7, [2026] = 3.6 }, blurb = "An H1 with much more memory." },
	{ id = "b200", name = "Volta B2", vendor = "Volta", from = "2025-01", power = 2.3, mem = 192, kw = 1.0, buy = { [2025] = 38000, [2026] = 34000, [2027] = 28000 }, rent = { [2025] = 6.5, [2026] = 6.2, [2027] = 4.5 }, blurb = "A new generation. FP4 changes the math." },
	{ id = "gb200", name = "Volta Rack72 (per chip)", vendor = "Volta", from = "2025-04", power = 2.7, mem = 186, kw = 1.7, buy = { [2025] = 52000, [2026] = 48000, [2027] = 40000 }, rent = { [2025] = 13, [2026] = 11, [2027] = 8 }, blurb = "Sold by the rack: 72 GPUs, ~$3.5M." },
	{ id = "b300", name = "Volta B3 Ultra", vendor = "Volta", from = "2025-09", power = 3.4, mem = 288, kw = 1.3, buy = { [2025] = 50000, [2026] = 46000, [2027] = 38000 }, rent = { [2025] = 14, [2026] = 12, [2027] = 9 }, blurb = "15 PF of FP4 per GPU." },
	{ id = "mi355x", name = "Redline R5", vendor = "Redline", from = "2025-08", power = 2.4, mem = 288, kw = 1.4, buy = { [2025] = 25000, [2026] = 22000 }, rent = { [2025] = 4.5, [2026] = 3.8 }, blurb = "Best value per FLOP in 2026." },
	{ id = "rubin", name = "Volta V2", vendor = "Volta", from = "2026-10", power = 7, mem = 288, kw = 2.1, buy = { [2026] = 60000, [2027] = 55000, [2028] = 45000 }, rent = { [2026] = 22, [2027] = 18, [2028] = 12 }, blurb = "HBM4, brand new. Contracts only at first." },
	{ id = "mi455x", name = "Redline R7", vendor = "Redline", from = "2026-10", power = 5.5, mem = 432, kw = 2.0, buy = { [2026] = 42000, [2027] = 38000 }, rent = { [2026] = 12, [2027] = 10 }, blurb = "432GB HBM4 per GPU." },
	{ id = "rubinultra", name = "Volta V2 Ultra", vendor = "Volta", from = "2027-08", power = 14, mem = 1024, kw = 3.5, buy = { [2027] = 110000, [2028] = 95000, [2029] = 70000 }, rent = { [2027] = 35, [2028] = 26, [2029] = 18 }, blurb = "Giant racks, 600 kW each." },
	{ id = "feynman", name = "Volta Quantum F", vendor = "Volta", from = "2028-06", power = 32, mem = 1500, kw = 4.5, buy = { [2028] = 160000, [2029] = 130000, [2030] = 100000 }, rent = { [2028] = 55, [2029] = 40, [2030] = 28 }, blurb = "Die-stacked memory. Science fiction in 2023." },
	{ id = "postfeynman", name = "Next-gen accelerator", vendor = "Volta", from = "2030-06", power = 75, mem = 3000, kw = 6, buy = { [2030] = 220000, [2032] = 170000 }, rent = { [2030] = 80, [2032] = 55 }, blurb = "Whatever comes next." },
}

local Config = require(script.Parent:WaitForChild("Config"))
local Format = require(script.Parent:WaitForChild("Format"))

-- After the real roadmap: a new chip every 4 to 7 months, forever, two makers taking turns.
do
	local LETTERS = { "X", "Z", "Q", "N", "S", "T", "K", "M" }
	local power, price, mem, kw = 75, 220000, 3000, 6
	local y, mo = 2030, 11
	for i = 1, 60 do
		mo += 4 + (i * 7) % 4
		while mo > 12 do
			mo -= 12
			y += 1
		end
		local volta = i % 2 == 1
		power *= volta and 1.45 or 1.3
		price *= volta and 1.12 or 0.95
		mem *= 1.25
		kw *= 1.06
		local gen = math.floor((i + 1) / 2)
		local name = volta and ("Volta " .. LETTERS[(gen - 1) % #LETTERS + 1] .. gen) or ("Redline R" .. (8 + gen))
		local blurbs = { "Faster than anything last year.", "The new king of the datacenter.", "Cheaper per chip, almost as fast.", "Liquid cooled from the factory.", "Built for giant models.", "Everyone is on the waitlist." }
		table.insert(Hardware.list, {
			id = "gen" .. i, name = name, vendor = volta and "Volta" or "Redline", from = string.format("%d-%02d", y, mo),
			power = math.floor(power), mem = math.floor(mem), kw = math.floor(kw * 10) / 10,
			buy = { [y] = math.floor(price), [y + 1] = math.floor(price * 0.85) }, rent = { [y] = math.floor(price / 3000), [y + 1] = math.floor(price / 3600) },
			blurb = blurbs[(i - 1) % #blurbs + 1], future = true,
		})
	end
end

Hardware.byId = {} :: { [string]: any }
for _, h in ipairs(Hardware.list) do
	h.fromDay = Format.dayFromString(h.from)
	Hardware.byId[h.id] = h
end

function Hardware.available(h: any, day: number): boolean
	return day >= h.fromDay
end

local function priceFor(tbl: { [number]: number }, year: number): number
	-- after the last listed year, keep falling ~25%/yr
	local lastY = -1
	for y in pairs(tbl) do
		if y > lastY then
			lastY = y
		end
	end
	local v = Config.yearValue(tbl, year)
	if year > lastY then
		v *= 0.75 ^ (year - lastY)
	end
	return v
end

function Hardware.buyPrice(h: any, year: number): number
	return priceFor(h.buy, year)
end

function Hardware.rentPrice(h: any, year: number): number
	return priceFor(h.rent, year)
end

return Hardware
