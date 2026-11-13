--!strict
-- Client side of the remotes + a tiny state store with change listeners.
local RS = game:GetService("ReplicatedStorage")
local Remotes = RS:WaitForChild("Remotes", 30) :: Folder
local ActionRF = Remotes:WaitForChild("Action") :: RemoteFunction
local SlotsRF = Remotes:WaitForChild("Slots") :: RemoteFunction
local StateRE = Remotes:WaitForChild("State") :: RemoteEvent
local EventRE = Remotes:WaitForChild("Event") :: RemoteEvent

local Net = {}
Net.actListeners = {} :: { (string, any) -> () }
Net.state = nil :: any
local listeners: { (any) -> () } = {}
local eventListeners: { (string, any) -> () } = {}
local toastFn: ((string, string?) -> ())? = nil

function Net.onState(fn: (any) -> ())
	table.insert(listeners, fn)
	if Net.state then
		task.spawn(fn, Net.state)
	end
end
function Net.onEvent(fn: (string, any) -> ())
	table.insert(eventListeners, fn)
end
function Net.setToast(fn)
	toastFn = fn
end
function Net.toast(text: string, kind: string?)
	if toastFn then
		toastFn(text, kind)
	end
end

-- the server sends only what changed: merge it into a fresh copy of the last state
StateRE.OnClientEvent:Connect(function(diff, full, gone)
	local s
	if full or not Net.state then
		s = diff
	else
		s = table.clone(Net.state)
		for k, v in pairs(diff) do
			s[k] = v
		end
		for _, k in ipairs(gone or {}) do
			s[k] = nil
		end
	end
	Net.state = s
	for _, fn in ipairs(listeners) do
		task.spawn(fn, s)
	end
end)
EventRE.OnClientEvent:Connect(function(kind, data)
	for _, fn in ipairs(eventListeners) do
		task.spawn(fn, kind, data)
	end
end)

-- Returns ok, data. Shows a toast on failure.
function Net.act(name: string, ...): (boolean, any)
	local ok, res = pcall(function(...)
		return ActionRF:InvokeServer(name, ...)
	end, ...)
	if not ok or type(res) ~= "table" then
		Net.toast("Connection problem", "error")
		return false, nil
	end
	if not res.ok then
		Net.toast(tostring(res.err or "Failed"), "error")
		return false, nil
	end
	for _, fn in ipairs(Net.actListeners) do
		task.spawn(fn, name, res.data)
	end
	return true, res.data
end

-- Robux shop. kind = "pass" | "product". Returns the server reply table.
function Net.shop(kind: string, key: string, target: any?): any
	local rf = Remotes:FindFirstChild("Shop") :: RemoteFunction?
	if not rf then
		Net.toast("Shop is loading", "error")
		return nil
	end
	local ok, res = pcall(function()
		return (rf :: RemoteFunction):InvokeServer(kind, key, target)
	end)
	if not ok or type(res) ~= "table" then
		Net.toast("Connection problem", "error")
		return nil
	end
	if not res.ok then
		Net.toast(tostring(res.err or "Failed"), "error")
	end
	return res
end

-- same as act, but never shows an error toast (for fast repeated taps)
function Net.quiet(name: string, ...): (boolean, any)
	local ok, res = pcall(function(...)
		return ActionRF:InvokeServer(name, ...)
	end, ...)
	if not ok or type(res) ~= "table" or not res.ok then
		return false, nil
	end
	return true, res.data
end

function Net.slots(action: string, ...)
	local ok, res = pcall(function(...)
		return SlotsRF:InvokeServer(action, ...)
	end, ...)
	return ok and res or nil
end

return Net
