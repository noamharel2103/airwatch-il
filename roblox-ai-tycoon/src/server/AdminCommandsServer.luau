-- Server code for the F2 admin commands in shared/AdminCommands.luau (key = command Name).
-- Every function gets (context, ...args) and returns the text shown in the console.
local RS = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local Modules = script.Parent
local Game = require(Modules:WaitForChild("Game"))
local Bridge = require(Modules:WaitForChild("AdminBridge"))
local Shop = require(RS:WaitForChild("Shared"):WaitForChild("Shop"))

local function fx(): RemoteEvent
	return RS:WaitForChild("AdminFx") :: RemoteEvent
end

-- Roblox rules: text typed by a person must be filtered before others see it.
local function filtered(text: string, fromId: number, toId: number?): string?
	local ok, res = pcall(function()
		local r = TextService:FilterStringAsync(text, fromId)
		if toId then
			return r:GetNonChatStringForUserAsync(toId)
		end
		return r:GetNonChatStringForBroadcastAsync()
	end)
	return ok and res or nil
end

local function names(list: { Player }): string
	local out = {}
	for _, p in ipairs(list) do
		table.insert(out, p.Name)
	end
	return table.concat(out, ", ")
end

-- Runs fn on each player that has a company loaded; lists who was skipped.
local function onSessions(players: { Player }, fn: (Player, any) -> string?): string
	local done, skipped, errs = {}, {}, {}
	for _, p in ipairs(players) do
		local s = Bridge.sessions[p]
		if not s then
			table.insert(skipped, p)
		else
			local err = fn(p, s)
			if err then
				table.insert(errs, p.Name .. ": " .. err)
			else
				table.insert(done, p)
				s.dirty = true
				Bridge.push(p, s)
			end
		end
	end
	local msg = #done > 0 and ("Done for " .. names(done)) or "Nobody changed"
	if #skipped > 0 then
		msg ..= " | no company loaded: " .. names(skipped)
	end
	if #errs > 0 then
		msg ..= " | " .. table.concat(errs, "; ")
	end
	return msg
end

local Commands = {}

Commands.announce = function(context, text: string)
	local from = context.Executor
	local clean = filtered(text, from and from.UserId or 0)
	if not clean then
		return "Roblox text filter failed, try again"
	end
	fx():FireAllClients("announce", { text = clean, from = from and from.DisplayName or "Server" })
	return "Announced"
end

Commands.pm = function(context, players: { Player }, text: string)
	local from = context.Executor
	for _, p in ipairs(players) do
		local clean = filtered(text, from and from.UserId or 0, p.UserId)
		if clean then
			fx():FireClient(p, "announce", { text = clean, from = from and from.DisplayName or "Server", private = true })
		end
	end
	return "Sent to " .. names(players)
end

Commands.give = function(_context, players: { Player }, item: string)
	if Shop.passByKey[item] then
		return onSessions(players, function(p, s)
			s.state.giftPerks = s.state.giftPerks or {}
			s.state.giftPerks[item] = true
			Bridge.refreshPasses(p)
			fx():FireClient(p, "gift", { name = Shop.passByKey[item].name })
			return nil
		end)
	end
	local product = Shop.productByKey[item]
	if not product then
		return "Unknown item " .. item
	end
	return onSessions(players, function(p, s)
		local ok, res, err = pcall(Game.grantProduct, s.state, item, nil)
		if not ok then
			return tostring(res)
		elseif res == false then
			return tostring(err)
		end
		fx():FireClient(p, "gift", { name = product.name })
		return nil
	end)
end

Commands.take = function(_context, players: { Player }, item: string)
	if not Shop.passByKey[item] then
		return item .. " is a one-time product, only passes can be taken back"
	end
	return onSessions(players, function(p, s)
		if s.state.giftPerks then
			s.state.giftPerks[item] = nil
		end
		Bridge.refreshPasses(p)
		return nil
	end)
end

Commands.givecash = function(_context, players: { Player }, amount: number)
	return onSessions(players, function(_p, s)
		s.state.cash = (s.state.cash or 0) + amount
		return nil
	end)
end

Commands.troll = function(_context, players: { Player }, kind: string, seconds: number?)
	local t = math.clamp(seconds or 5, 1, 60)
	for _, p in ipairs(players) do
		fx():FireClient(p, "troll", { kind = kind, seconds = t })
	end
	return "Trolled " .. names(players) .. " with " .. kind .. " for " .. t .. "s"
end

-- World events: tell every server (MessagingService); each server applies it in Main.server
local MessagingService = game:GetService("MessagingService")
local Events = require(RS.Shared.Events)
local function broadcast(msg)
	Game.applyWorldEvent(msg)
	pcall(function()
		MessagingService:PublishAsync("FrontierWorldEvents", msg)
	end)
end

Commands.event = function(_context, id: string, minutes: number?)
	local e = Events.byId[id]
	if not e then
		return "Unknown event " .. tostring(id)
	end
	local m = math.clamp(minutes or 15, 1, 24 * 60)
	broadcast({ op = "start", id = id, ends = os.time() + math.floor(m * 60) })
	return e.name .. " started for " .. m .. " minutes in every server"
end

Commands.endevent = function(_context, id: string)
	broadcast({ op = "stop", id = id })
	return "Stopped " .. id
end

Commands.untroll = function(_context, players: { Player })
	for _, p in ipairs(players) do
		fx():FireClient(p, "untroll", {})
	end
	return "Stopped pranks on " .. names(players)
end

return Commands
