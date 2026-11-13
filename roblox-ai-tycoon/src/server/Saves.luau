--!strict
-- Save slots: up to 3 companies per player. One key per slot + a small index key.
-- Studio writes go to a separate store so test data never mixes with the real game.
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local Saves = {}
Saves.MAX_SLOTS = 3
local STORE_NAME = RunService:IsStudio() and "Companies_Studio_v1" or "Companies_v1"

local store: DataStore? = nil
-- Fallback when DataStores are unavailable (unpublished place / API access off).
-- In Studio it talks to tools/save_server.py so playtests keep your companies; otherwise RAM only.
local Http = game:GetService("HttpService")
local LOCAL = "http://127.0.0.1:34874/"
local ram = {}
local function memGet(k)
	if RunService:IsStudio() then
		local ok, res = pcall(function()
			return Http:JSONDecode(Http:GetAsync(LOCAL .. "load/" .. k .. "?t=" .. os.clock(), true))
		end)
		if ok then
			return res
		end
		warn("[Saves] local load failed for " .. k .. ": " .. tostring(res))
	end
	return ram[k]
end
local function memSet(k, v)
	ram[k] = v
	if RunService:IsStudio() then
		pcall(function()
			if v == nil then
				Http:RequestAsync({ Url = LOCAL .. "save/" .. k, Method = "DELETE" })
			else
				Http:PostAsync(LOCAL .. "save/" .. k, Http:JSONEncode(v), Enum.HttpContentType.ApplicationJson)
			end
		end)
	end
end
local okStore = pcall(function()
	store = DataStoreService:GetDataStore(STORE_NAME)
end)
Saves.available = okStore and store ~= nil
-- an unpublished place has no DataStores; skip the slow retries and use the local fallback
-- in Studio, always save to tools/save_server.py (Studio API access is usually off and slow to fail)
if game.GameId == 0 or RunService:IsStudio() then
	Saves.available = false
end

-- Deep copy that drops anything a DataStore cannot hold (functions, Instances, NaN/inf).
local function clean(v, depth)
	depth = depth or 0
	local t = typeof(v)
	if t == "number" then
		if v ~= v or v == math.huge or v == -math.huge then
			return 0
		end
		return v
	elseif t == "string" or t == "boolean" then
		return v
	elseif t == "table" and depth < 20 then
		local out = {}
		for k, x in pairs(v) do
			if typeof(k) == "string" or typeof(k) == "number" then
				local c = clean(x, depth + 1)
				if c ~= nil then
					out[k] = c
				end
			end
		end
		return out
	end
	return nil
end
Saves.clean = clean

local function key(userId: number, slot: number?): string
	if slot then
		return "player_" .. userId .. "_slot" .. slot
	end
	return "player_" .. userId .. "_index"
end

local function retry(fn)
	local lastErr
	for attempt = 1, 4 do
		local ok, res = pcall(fn)
		if ok then
			return true, res
		end
		lastErr = res
		task.wait(attempt * 1.5)
	end
	warn("[Saves] failed: " .. tostring(lastErr))
	return false, lastErr
end

-- Index = { [slot] = { company, day, valuation, stage } }
function Saves.listSlots(userId: number)
	if not Saves.available then
		-- local saves: rebuild the list from the slot files so a lost index never hides a company
		local idx = memGet(key(userId)) or {}
		local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
		local Format = require(Shared.Format)
		local Catalog = require(Shared.Catalog)
		for slot = 1, Saves.MAX_SLOTS do
			local data = memGet(key(userId, slot))
			if type(data) == "table" and data.company then
				idx[tostring(slot)] = {
					company = data.company,
					day = data.day,
					date = Format.monthYear(data.day or 1),
					valuation = data.valuation or 0,
					stage = (Catalog.officeStages[data.office or 1] or Catalog.officeStages[1]).name,
					users = data.users or 0,
				}
			end
		end
		return idx
	end
	local ok, res = retry(function()
		return (store :: DataStore):GetAsync(key(userId))
	end)
	if ok and type(res) == "table" then
		return res
	end
	if not ok then
		Saves.available = false
	end
	return memGet(key(userId)) or {}
end

function Saves.load(userId: number, slot: number)
	if not Saves.available then
		return memGet(key(userId, slot))
	end
	local ok, res = retry(function()
		return (store :: DataStore):GetAsync(key(userId, slot))
	end)
	return ok and res or nil
end

function Saves.save(userId: number, slot: number, state, summary)
	local data = clean(state)
	if not Saves.available then
		memSet(key(userId, slot), data)
		local idx = memGet(key(userId)) or {}
		idx[tostring(slot)] = summary
		memSet(key(userId), idx)
		return true
	end
	local ok = retry(function()
		(store :: DataStore):UpdateAsync(key(userId, slot), function()
			return data
		end)
	end)
	if ok then
		retry(function()
			(store :: DataStore):UpdateAsync(key(userId), function(old)
				old = type(old) == "table" and old or {}
				old[tostring(slot)] = summary
				return old
			end)
		end)
	end
	return ok
end

-- Account-wide data that is not part of a company: settings, daily gift streak.
function Saves.loadMeta(userId: number)
	local k = "player_" .. userId .. "_meta"
	if not Saves.available then
		return memGet(k) or {}
	end
	local ok, res = retry(function()
		return (store :: DataStore):GetAsync(k)
	end)
	return (ok and type(res) == "table") and res or {}
end

function Saves.saveMeta(userId: number, meta)
	local k = "player_" .. userId .. "_meta"
	local data = clean(meta)
	if not Saves.available then
		memSet(k, data)
		return true
	end
	return (retry(function()
		(store :: DataStore):SetAsync(k, data)
	end))
end

-- Global leaderboard: valuation stored as log10 so even huge companies fit.
local board: OrderedDataStore? = nil
pcall(function()
	board = DataStoreService:GetOrderedDataStore(RunService:IsStudio() and "TopCompanies_Studio_v1" or "TopCompanies_v1")
end)
local boardNames = nil :: DataStore?
pcall(function()
	boardNames = DataStoreService:GetDataStore(RunService:IsStudio() and "TopNames_Studio_v1" or "TopNames_v1")
end)
local localBoard: { [string]: { score: number, name: string, company: string } } = {}

function Saves.postScore(userId: number, name: string, company: string, valuation: number)
	local score = math.floor(math.log10(math.max(valuation, 1) + 1) * 1e6)
	localBoard[tostring(userId)] = { score = score, name = name, company = company }
	if not Saves.available or not board then
		return
	end
	pcall(function()
		(board :: OrderedDataStore):UpdateAsync(tostring(userId), function(old)
			return math.max(tonumber(old) or 0, score)
		end)
	end)
	pcall(function()
		(boardNames :: DataStore):SetAsync(tostring(userId), { name = name, company = company })
	end)
end

-- second world board: the best AI model (score = model quality)
local modelBoard: OrderedDataStore? = nil
local modelNames = nil :: DataStore?
pcall(function()
	modelBoard = DataStoreService:GetOrderedDataStore(RunService:IsStudio() and "TopModels_Studio_v1" or "TopModels_v1")
	modelNames = DataStoreService:GetDataStore(RunService:IsStudio() and "TopModelNames_Studio_v1" or "TopModelNames_v1")
end)
local localModels: { [string]: { score: number, name: string, company: string, model: string } } = {}

function Saves.postModel(userId: number, name: string, company: string, model: string, quality: number)
	local score = math.floor(math.max(0, quality) * 100)
	local key = tostring(userId)
	if localModels[key] and localModels[key].score >= score then
		return
	end
	localModels[key] = { score = score, name = name, company = company, model = model }
	if not Saves.available or not modelBoard then
		return
	end
	pcall(function()
		(modelBoard :: OrderedDataStore):UpdateAsync(key, function(old)
			return math.max(tonumber(old) or 0, score)
		end)
	end)
	pcall(function()
		(modelNames :: DataStore):SetAsync(key, { name = name, company = company, model = model })
	end)
end

-- returns { { userId, name, company, model, quality } } best first
function Saves.topModels(n: number)
	local out = {}
	if Saves.available and modelBoard then
		local ok, pages = pcall(function()
			return (modelBoard :: OrderedDataStore):GetSortedAsync(false, n)
		end)
		if ok and pages then
			for _, e in ipairs(pages:GetCurrentPage()) do
				local info = nil
				pcall(function()
					info = (modelNames :: DataStore):GetAsync(e.key)
				end)
				table.insert(out, { userId = tonumber(e.key), name = info and info.name or "Player", company = info and info.company or "?", model = info and info.model or "?", quality = e.value / 100 })
			end
			return out
		end
	end
	for id, e in pairs(localModels) do
		table.insert(out, { userId = tonumber(id), name = e.name, company = e.company, model = e.model, quality = e.score / 100 })
	end
	table.sort(out, function(a, b)
		return a.quality > b.quality
	end)
	return out
end

-- returns { { userId, name, company, valuation } } best first
function Saves.topScores(n: number)
	local out = {}
	if Saves.available and board then
		local ok, pages = pcall(function()
			return (board :: OrderedDataStore):GetSortedAsync(false, n)
		end)
		if ok and pages then
			for _, e in ipairs(pages:GetCurrentPage()) do
				local info = nil
				pcall(function()
					info = (boardNames :: DataStore):GetAsync(e.key)
				end)
				table.insert(out, { userId = tonumber(e.key), name = info and info.name or "Player", company = info and info.company or "?", valuation = 10 ^ (e.value / 1e6) - 1 })
			end
			return out
		end
	end
	for id, e in pairs(localBoard) do
		table.insert(out, { userId = tonumber(id), name = e.name, company = e.company, valuation = 10 ^ (e.score / 1e6) - 1 })
	end
	table.sort(out, function(a, b)
		return a.valuation > b.valuation
	end)
	return out
end

function Saves.delete(userId: number, slot: number)
	if not Saves.available then
		memSet(key(userId, slot), nil)
		local idx = memGet(key(userId)) or {}
		idx[tostring(slot)] = nil
		memSet(key(userId), idx)
		return true
	end
	retry(function()
		(store :: DataStore):RemoveAsync(key(userId, slot))
	end)
	retry(function()
		(store :: DataStore):UpdateAsync(key(userId), function(old)
			old = type(old) == "table" and old or {}
			old[tostring(slot)] = nil
			return old
		end)
	end)
	return true
end

return Saves
