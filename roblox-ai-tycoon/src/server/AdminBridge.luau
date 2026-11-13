-- Lets the F2 admin commands and the ADMIN PANEL reach live game sessions. Main.server.luau fills these in.
local RunService = game:GetService("RunService")

local AdminBridge = {}
AdminBridge.sessions = {} :: { [Player]: any }
AdminBridge.push = function(_player: Player, _session: any) end
AdminBridge.refreshPasses = function(_player: Player) end

-- The only check that matters: the game creator (or the owner of the group that owns the
-- game). Everyone in Studio, so testing works. nil = the server itself.
function AdminBridge.isAdmin(player: Player?): boolean
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

return AdminBridge
