--!strict
-- Global tuning knobs. Everything time/economy related lives here.
local Config = {}

Config.GAME_TITLE = "FRONTIER" -- working title, not final
Config.START_YEAR = 2023
Config.START_MONTH = 1

-- Pacing: ~2 real minutes per in-game month at x1 (owner's target).
Config.SECONDS_PER_DAY = 4
Config.SPEEDS = { 0, 1, 2, 4 }

-- Risk multiplier per speed: faster = more can go wrong while you aren't watching.
Config.RISK_BY_SPEED = { [0] = 0, [1] = 1, [2] = 2.2, [4] = 5 }

-- Starting position: a laptop, $30K of savings, and a dream. Loans and investors come later.
Config.START_CASH = 30e3
Config.START_VALUATION = 0
Config.START_FOUNDER_EQUITY = 1
Config.START_CLOUD_CREDITS = 0

-- Bank loans: credit limit grows with revenue and valuation. Repaid monthly over LOAN_MONTHS.
Config.LOAN_RATE_YEAR = 0.11
Config.LOAN_MONTHS = 24
Config.LOAN_BASE_LIMIT = 60e3

-- Where you start. Perks make each city play a bit differently.
Config.LOCATIONS = {
	{ id = "paloalto", name = "Garage in Palo Alto", city = "Silicon Valley", salary = 1.0, investors = 1.4, power = 1.15, talent = 1.2, rent = 1.3, desc = "Where legends start. Investors drive past every day. Everything is expensive." },
	{ id = "telaviv", name = "Apartment in Tel Aviv", city = "Tel Aviv", salary = 0.65, investors = 1.0, power = 1.0, talent = 1.1, rent = 0.8, desc = "Cheap brilliant engineers, great hummus, investors fly in." },
	{ id = "london", name = "Flat in London", city = "London", salary = 0.75, investors = 1.1, power = 1.3, talent = 1.1, rent = 1.1, desc = "DeepMind's hometown. Research talent everywhere." },
	{ id = "paris", name = "Studio in Paris", city = "Paris", salary = 0.7, investors = 0.95, power = 0.8, talent = 1.0, rent = 0.9, desc = "Cheap nuclear power and a government that loves AI champions." },
	{ id = "nyc", name = "Loft in Brooklyn", city = "New York", salary = 0.95, investors = 1.2, power = 1.2, talent = 1.0, rent = 1.25, desc = "Enterprise customers are one subway ride away. +sales." },
	{ id = "bangalore", name = "Co-living in Bangalore", city = "Bangalore", salary = 0.35, investors = 0.75, power = 0.9, talent = 1.0, rent = 0.5, desc = "Huge talent pool at a fraction of the cost. Investors are harder to reach." },
}

-- Capability index -> world. 10 points per 10x effective compute.
Config.CAP_OFFSET = 192 -- tuned for fun: small teams can reach GPT-3.5 level in mid 2023
Config.ALGO_PROGRESS_PER_YEAR = 3 -- algorithmic efficiency gain, x per year (world baseline)

-- Total AI-assistant users in the world, by year (millions).
Config.MARKET_USERS_M = { [2023] = 180, [2024] = 400, [2025] = 900, [2026] = 1600, [2027] = 2400, [2028] = 3200, [2029] = 3900, [2030] = 4500 }
Config.PAY_CONVERSION = 0.05
Config.GROSS_MARGIN = { [2023] = 0.25, [2024] = 0.40, [2025] = 0.42, [2026] = 0.50, [2027] = 0.55 }
Config.ARR_MULTIPLE = { [2023] = 45, [2024] = 38, [2025] = 32, [2026] = 28, [2027] = 25, [2028] = 22 }

-- Seat cost per employee per month (office, laptops, benefits extras).
Config.SEAT_COST_MONTH = 1300
Config.ELECTRICITY_PER_KWH = 0.09

Config.GOALS_PER_WEEK = 3

-- GPU allocation: how much compute (H100-equivalents) a startup can get its hands on.
-- 2023 H100s were allocation-only with ~39-week lead times (research 05). Grows with reputation/valuation.
Config.GPU_ALLOCATION = { [2023] = 600, [2024] = 3500, [2025] = 25000, [2026] = 150000, [2027] = 600000, [2028] = 2e6, [2030] = 1e7 }

-- A launch can't capture more than this share of the whole market.
Config.MAX_MARKET_SHARE = 0.6

function Config.yearValue(tbl: { [number]: number }, year: number): number
	local best, bestYear = nil, -1
	for y, v in pairs(tbl) do
		if y <= year and y > bestYear then
			best, bestYear = v, y
		end
	end
	if best == nil then
		local minY = math.huge
		for y, v in pairs(tbl) do
			if y < minY then
				minY, best = y, v
			end
		end
	end
	return best :: number
end

return Config
