-- Opens the Cmdr admin console with F2 (or the ` key), only for the game creator.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")

local me = Players.LocalPlayer
local admin = RunService:IsStudio()
if not admin then
	if game.CreatorType == Enum.CreatorType.Group then
		local ok, rank = pcall(me.GetRankInGroup, me, game.CreatorId)
		admin = ok and rank == 255
	else
		admin = me.UserId == game.CreatorId
	end
end

local CmdrClient = require(RS:WaitForChild("CmdrClient"))
if not admin then
	CmdrClient:SetEnabled(false)
	return
end
CmdrClient:SetActivationKeys({ Enum.KeyCode.F2, Enum.KeyCode.Backquote })

local defs = require(RS:WaitForChild("Shared"):WaitForChild("AdminCommands"))
for typeName, values in pairs(defs.Enums) do
	CmdrClient.Registry:RegisterType(typeName, CmdrClient.Util.MakeEnumType(typeName, values))
end
for _, def in ipairs(defs.Commands) do
	CmdrClient.Registry:RegisterCommandObject(table.clone(def))
end
