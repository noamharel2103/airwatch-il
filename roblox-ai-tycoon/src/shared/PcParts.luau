--!strict
-- Upgrades for your own computer / server. Real parts, rough real prices.
-- speed: training rounds go faster. heat: lower = less overheating and fewer burned GPUs.
-- kw: extra power you can run. hype: looks cool on stream.
local PcParts = {}

PcParts.categories = {
	{ id = "cpu", name = "CPU" },
	{ id = "ram", name = "RAM" },
	{ id = "cooling", name = "Cooling" },
	{ id = "psu", name = "Power supply" },
	{ id = "storage", name = "Storage" },
	{ id = "rgb", name = "Lights" },
}

PcParts.list = {
	cpu = {
		{ id = "stock", name = "Laptop CPU", price = 0, year = 2020, speed = 1.0, blurb = "The one your laptop came with." },
		{ id = "r5", name = "Ryzen 5 7600", price = 230, year = 2023, speed = 1.04, blurb = "Cheap and fine for a start." },
		{ id = "r9", name = "Ryzen 9 7950X", price = 550, year = 2023, speed = 1.08, blurb = "16 cores. Data prep flies." },
		{ id = "tr", name = "Threadripper 7980X", price = 5000, year = 2024, speed = 1.14, blurb = "64 cores of pure workstation." },
		{ id = "epyc", name = "EPYC 9654", price = 11000, year = 2023, speed = 1.18, blurb = "96 cores. Real server silicon." },
		{ id = "epyc5", name = "EPYC 9965", price = 14800, year = 2025, speed = 1.24, blurb = "192 cores. Feeds a whole rack of GPUs." },
	},
	ram = {
		{ id = "r16", gb = 16, name = "16GB DDR4", price = 0, year = 2020, speed = 1.0, sticks = 1, blurb = "Chrome already uses all of it." },
		{ id = "r32", gb = 32, name = "32GB DDR5", price = 110, year = 2023, speed = 1.03, sticks = 2, blurb = "Room to breathe." },
		{ id = "r64", gb = 64, name = "64GB DDR5", price = 220, year = 2023, speed = 1.06, sticks = 2, blurb = "Load bigger datasets." },
		{ id = "r128", gb = 128, name = "128GB DDR5", price = 450, year = 2023, speed = 1.09, sticks = 4, blurb = "Never swap to disk again." },
		{ id = "r256", gb = 256, name = "256GB ECC", price = 1600, year = 2023, speed = 1.12, sticks = 4, blurb = "Server memory. Fixes its own errors." },
		{ id = "r1t", gb = 1024, name = "1TB ECC", price = 7000, year = 2024, speed = 1.16, sticks = 8, blurb = "A terabyte of RAM. Why not." },
	},
	cooling = {
		{ id = "stock", name = "Stock cooler", cool = 0.3, price = 0, year = 2020, heat = 1.0, kind = "stock", blurb = "Sounds like a jet engine." },
		{ id = "air", cool = 0.6, name = "Tower air cooler", price = 90, year = 2023, heat = 0.8, kind = "air", blurb = "Big metal fins and two fans." },
		{ id = "aio", cool = 1.0, name = "360mm liquid AIO", price = 180, year = 2023, heat = 0.6, kind = "aio", blurb = "Liquid cooling with a 3 fan radiator." },
		{ id = "loop", cool = 2.5, name = "Custom liquid loop", price = 900, year = 2023, heat = 0.42, kind = "loop", blurb = "Hard tubes, glowing coolant, a reservoir." },
		{ id = "chiller", cool = 40, name = "Rack liquid cooling", price = 12000, year = 2024, heat = 0.3, kind = "loop", blurb = "Direct to chip liquid cooling for the whole rack." },
		{ id = "immersion", cool = 120, name = "Immersion tank", price = 25000, year = 2024, heat = 0.18, kind = "immersion", blurb = "The whole server sinks into cooling liquid." },
	},
	psu = {
		{ id = "stock", name = "Laptop charger", price = 0, year = 2020, kw = 0, blurb = "Gets very warm." },
		{ id = "p850", name = "850W Gold PSU", price = 130, year = 2023, kw = 1, blurb = "Enough for one or two GPUs." },
		{ id = "p1600", name = "1600W Titanium PSU", price = 450, year = 2023, kw = 2, blurb = "Feeds four big GPUs." },
		{ id = "dual", name = "Dual PSU server", price = 2500, year = 2023, kw = 5, blurb = "Two supplies, if one dies the other keeps going." },
		{ id = "ups", name = "Battery backup (UPS)", price = 9000, year = 2023, kw = 10, blurb = "Power cuts can't kill a training run anymore." },
	},
	storage = {
		{ id = "stock", name = "512GB SSD", price = 0, year = 2020, speed = 1.0, blurb = "Full of memes." },
		{ id = "s2", name = "2TB NVMe", price = 150, year = 2023, speed = 1.02, blurb = "Fast enough for small datasets." },
		{ id = "s8", name = "8TB NVMe RAID", price = 900, year = 2023, speed = 1.05, blurb = "Four drives working together." },
		{ id = "nas", name = "100TB NAS", price = 6000, year = 2023, speed = 1.08, blurb = "A whole box of hard drives for your data." },
		{ id = "flash", name = "1PB flash array", price = 90000, year = 2024, speed = 1.12, blurb = "A petabyte. The whole internet, almost." },
	},
	rgb = {
		{ id = "none", name = "No lights", price = 0, year = 2020, hype = 0, blurb = "Boring." },
		{ id = "strip", name = "RGB strip", price = 40, year = 2023, hype = 1, blurb = "Gamer mode on." },
		{ id = "full", name = "Full RGB kit", price = 160, year = 2023, hype = 2, blurb = "Fans, RAM, tubes, everything glows." },
	},
}

PcParts.byId = {}
for cat, list in pairs(PcParts.list) do
	PcParts.byId[cat] = {}
	for i, p in ipairs(list) do
		p.tier = i
		PcParts.byId[cat][p.id] = p
	end
end

function PcParts.default()
	return { cpu = "stock", ram = "r16", cooling = "stock", psu = "stock", storage = "stock", rgb = "none" }
end

function PcParts.get(pc, cat)
	pc = pc or PcParts.default()
	return PcParts.byId[cat][pc[cat]] or PcParts.list[cat][1]
end

-- You can own many of each part. stock = { ["ram:r128"] = 12, ["cooling:loop"] = 3, ... }
function PcParts.count(stock, cat, id): number
	return (stock or {})[cat .. ":" .. id] or 0
end

-- Totals of everything you own (the free laptop parts always count once)
function PcParts.totals(stock)
	local t = { gb = 16, cool = 0.6, kw = 0 }
	for key, n in pairs(stock or {}) do
		local cat, id = key:match("^(%w+):(%w+)$")
		local p = cat and PcParts.byId[cat] and PcParts.byId[cat][id]
		if p and n > 0 then
			t.gb += (p.gb or 0) * n
			t.cool += (p.cool or 0) * n
			t.kw += (p.kw or 0) * n
		end
	end
	return t
end

-- Every GPU you own needs RAM next to it and cooling for its heat.
function PcParts.needs(ownedGpus: number, ownedKw: number)
	return { gb = 16 + ownedGpus * 48, cool = 0.3 + ownedKw }
end

function PcParts.speed(pc): number
	return PcParts.get(pc, "cpu").speed * PcParts.get(pc, "ram").speed * PcParts.get(pc, "storage").speed
end

function PcParts.heat(pc): number
	return PcParts.get(pc, "cooling").heat
end

function PcParts.kw(pc): number
	return PcParts.get(pc, "psu").kw
end

return PcParts
