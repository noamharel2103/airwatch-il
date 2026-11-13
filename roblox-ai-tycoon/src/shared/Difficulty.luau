--!strict
-- Difficulty levels for a company. Picked once per company (state.difficulty, state.diffChosen).
-- Every multiplier is 1 on MEDIUM, which is the normal game.
--   cost:       running costs (salaries, GPUs, power, office, servers)
--   income:     all income
--   popularity: how fast people pick your AI
--   rival:      how fast rival labs ship new models (higher = rivals faster)
--   events:     how often crises hit
--   startCash:  money you start with
local Difficulty = {}

export type Level = {
	id: string,
	name: string,
	color: Color3,
	desc: string,
	cost: number,
	income: number,
	popularity: number,
	rival: number,
	events: number,
	startCash: number,
}

Difficulty.DEFAULT = "medium"

Difficulty.list = {
	{ id = "easy", name = "EASY", color = Color3.fromRGB(0, 215, 105), desc = "Cheap running costs, good income and users find you fast. A calm start.", cost = 0.6, income = 1.3, popularity = 1.35, rival = 0.7, events = 0.5, startCash = 2 },
	{ id = "medium", name = "MEDIUM", color = Color3.fromRGB(0, 200, 255), desc = "The normal game. Balanced costs, rivals and crises.", cost = 1, income = 1, popularity = 1, rival = 1, events = 1, startCash = 1 },
	{ id = "hard", name = "HARD", color = Color3.fromRGB(255, 196, 30), desc = "Costs and rivals push harder. Users come slower and crises are more common.", cost = 1.25, income = 0.85, popularity = 0.75, rival = 1.3, events = 1.5, startCash = 0.7 },
	{ id = "ultra", name = "ULTRA HARD", color = Color3.fromRGB(255, 140, 40), desc = "Rivals move fast, money is tight and crises hit often.", cost = 1.5, income = 0.72, popularity = 0.6, rival = 1.6, events = 2, startCash = 0.5 },
	{ id = "impossible", name = "IMPOSSIBLE", color = Color3.fromRGB(255, 70, 85), desc = "Brutal. Costs almost double, rivals race ahead and crises never stop. Only for experts.", cost = 1.8, income = 0.6, popularity = 0.45, rival = 1.8, events = 2.5, startCash = 0.35 },
} :: { Level }

Difficulty.byId = {} :: { [string]: Level }
for _, lvl in ipairs(Difficulty.list) do
	Difficulty.byId[lvl.id] = lvl
end

-- true when id is one of the 5 levels
function Difficulty.isValid(id: any): boolean
	return type(id) == "string" and Difficulty.byId[id] ~= nil
end

-- a valid id, or MEDIUM
function Difficulty.normalize(id: any): string
	if Difficulty.isValid(id) then
		return id :: string
	end
	return Difficulty.DEFAULT
end

-- the multipliers for a company (MEDIUM when the id is missing or unknown)
function Difficulty.get(id: any): Level
	return Difficulty.byId[Difficulty.normalize(id)]
end

return Difficulty
