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
local memory = setmetatable({}, {
	__index = function(_, k)
		if RunService:IsStudio() then
			local ok, res = pcall(function()
				return Http:JSONDecode(Http:GetAsync(LOCAL .. "load/" .. k))
			end)
			if ok then
				return res
			end
		end
		return ram[k]
	end,
	__newindex = function(_, k, v)
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
	end,
})
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
		local idx = memory[key(userId)] or {}
		local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
		local Format = require(Shared.Format)
		local Catalog = require(Shared.Catalog)
		for slot = 1, Saves.MAX_SLOTS do
			local data = memory[key(userId, slot)]
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
	return memory[key(userId)] or {}
end

function Saves.load(userId: number, slot: number)
	if not Saves.available then
		return memory[key(userId, slot)]
	end
	local ok, res = retry(function()
		return (store :: DataStore):GetAsync(key(userId, slot))
	end)
	return ok and res or nil
end

function Saves.save(userId: number, slot: number, state, summary)
	local data = clean(state)
	if not Saves.available then
		memory[key(userId, slot)] = data
		local idx = memory[key(userId)] or {}
		idx[tostring(slot)] = summary
		memory[key(userId)] = idx
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

function Saves.delete(userId: number, slot: number)
	if not Saves.available then
		memory[key(userId, slot)] = nil
		local idx = memory[key(userId)] or {}
		idx[tostring(slot)] = nil
		memory[key(userId)] = idx
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
