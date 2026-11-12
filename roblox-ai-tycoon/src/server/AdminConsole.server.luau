-- F2 admin console (Cmdr). Only the game creator can run commands; everyone else is blocked on the server.
-- Add commands in shared/AdminCommands.luau (name, args) + server/AdminCommandsServer.luau (what they do).
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local cmdrModule = SSS:FindFirstChild("Cmdr")
if not cmdrModule then
	warn("[AdminConsole] ServerScriptService.Cmdr is missing, the FrontierSync plugin installs it on the next sync")
	return
end
local Cmdr = require(cmdrModule)

local function isAdmin(player: Player?): boolean
	if not player then
		return true
	end
	if RunService:IsStudio() then
		return true
	end
	if game.CreatorType == Enum.CreatorType.Group then
		local ok, rank = pcall(player.GetRankInGroup, player, game.CreatorId)
		return ok and rank == 255
	end
	return player.UserId == game.CreatorId
end

Cmdr:RegisterDefaultCommands()

Cmdr.Registry:RegisterHook("BeforeRun", function(context)
	if not isAdmin(context.Executor) then
		return "Only the game creator can use this."
	end
	return nil
end)

local defs = require(RS:WaitForChild("Shared"):WaitForChild("AdminCommands"))
local runs = require(script.Parent:WaitForChild("Modules"):WaitForChild("AdminCommandsServer"))
for _, def in ipairs(defs) do
	local run = runs[def.Name]
	if run then
		local obj = table.clone(def)
		obj.Run = run
		Cmdr.Registry:RegisterCommandObject(obj)
	else
		warn("[AdminConsole] no server code for command " .. tostring(def.Name))
	end
end
