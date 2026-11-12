-- Lets the F2 admin commands reach live game sessions. Main.server.luau fills these in.
local AdminBridge = {}
AdminBridge.sessions = {} :: { [Player]: any }
AdminBridge.push = function(_player: Player, _session: any) end
AdminBridge.refreshPasses = function(_player: Player) end
return AdminBridge
