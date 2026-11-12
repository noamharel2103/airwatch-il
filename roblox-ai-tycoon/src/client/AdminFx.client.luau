-- Draws what the F2 admin console sends: big announcements, gift popups and pranks.
-- Only the server can fire AdminFx, and the server only lets the game creator run commands.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remote = RS:WaitForChild("AdminFx") :: RemoteEvent

local gui = Instance.new("ScreenGui")
gui.Name = "AdminFxGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 1000
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local FONT = Enum.Font.FredokaOne

local function label(parent, text, size, color)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Font = FONT
	l.Text = text
	l.TextScaled = true
	l.TextColor3 = color or Color3.new(1, 1, 1)
	l.Size = size
	l.Parent = parent
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = Color3.new(0, 0, 0)
	stroke.Parent = l
	return l
end

local function rainbow(parent)
	local g = Instance.new("UIGradient")
	local keys = {}
	for i = 0, 6 do
		table.insert(keys, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 0.75, 1)))
	end
	g.Color = ColorSequence.new(keys)
	g.Parent = parent
	task.spawn(function()
		while g.Parent do
			g.Offset = Vector2.new(((os.clock() * 0.6) % 2) - 1, 0)
			RunService.RenderStepped:Wait()
		end
	end)
	return g
end

local function pop(frame: GuiObject)
	local scale = Instance.new("UIScale")
	scale.Scale = 0
	scale.Parent = frame
	TweenService:Create(scale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	return scale
end

-- ===== Announcements (queued, one at a time) =====
local queue = {}
local showing = false

local function showAnnouncement(data)
	local holder = Instance.new("Frame")
	holder.AnchorPoint = Vector2.new(0.5, 0)
	holder.Position = UDim2.fromScale(0.5, 0.07)
	holder.Size = UDim2.fromScale(0.82, 0.2)
	holder.BackgroundColor3 = Color3.fromRGB(8, 12, 28)
	holder.BackgroundTransparency = 0.35
	holder.BorderSizePixel = 0
	holder.Parent = gui
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0.06, 0)
	pad.PaddingBottom = UDim.new(0.06, 0)
	pad.Parent = holder

	local head = label(
		holder,
		(data.private and "PRIVATE MESSAGE FROM " or "ANNOUNCEMENT FROM ") .. string.upper(data.from or "ADMIN"),
		UDim2.fromScale(1, 0.28),
		Color3.fromRGB(255, 220, 60)
	)
	head.TextXAlignment = Enum.TextXAlignment.Center

	local body = label(holder, data.text or "", UDim2.fromScale(1, 0.72), Color3.new(1, 1, 1))
	body.Position = UDim2.fromScale(0, 0.28)
	body.TextWrapped = true
	local size = Instance.new("UITextSizeConstraint")
	size.MaxTextSize = 64
	size.Parent = body
	;(body:FindFirstChildOfClass("UIStroke") :: UIStroke).Thickness = 5
	rainbow(body)

	local scale = pop(holder)
	local hold = math.clamp(4 + #(data.text or "") / 15, 5, 12)
	task.wait(hold)
	TweenService:Create(scale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Scale = 0 }):Play()
	task.wait(0.35)
	holder:Destroy()
end

local function runQueue()
	if showing then
		return
	end
	showing = true
	while #queue > 0 do
		showAnnouncement(table.remove(queue, 1))
	end
	showing = false
end

local function showGift(data)
	local box = Instance.new("Frame")
	box.AnchorPoint = Vector2.new(0.5, 0.5)
	box.Position = UDim2.fromScale(0.5, 0.5)
	box.Size = UDim2.fromScale(0.5, 0.18)
	box.BackgroundColor3 = Color3.fromRGB(20, 26, 48)
	box.BorderSizePixel = 0
	box.Parent = gui
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 4
	stroke.Color = Color3.fromRGB(255, 200, 40)
	stroke.Parent = box
	local top = label(box, "ADMIN GIFT", UDim2.fromScale(1, 0.4), Color3.fromRGB(255, 200, 40))
	top.Position = UDim2.fromScale(0, 0.05)
	local name = label(box, string.upper(data.name or "ITEM"), UDim2.fromScale(0.9, 0.45))
	name.Position = UDim2.fromScale(0.05, 0.48)
	rainbow(name)
	local scale = pop(box)
	task.wait(3)
	TweenService:Create(scale, TweenInfo.new(0.25), { Scale = 0 }):Play()
	task.wait(0.3)
	box:Destroy()
end

-- ===== Pranks =====
local trollToken = 0
local cleanups: { () -> () } = {}

local function stopAll()
	trollToken += 1
	for _, fn in ipairs(cleanups) do
		pcall(fn)
	end
	table.clear(cleanups)
end

-- Adds an offset on top of whatever the game's camera code does, then puts it back.
local function cameraFx(fn: (number) -> CFrame, seconds: number)
	local cam = workspace.CurrentCamera
	local base = cam.CFrame
	local last: CFrame? = nil
	local start = os.clock()
	local name = "AdminFxCam" .. tostring(trollToken)
	RunService:BindToRenderStep(name, Enum.RenderPriority.Last.Value, function()
		if last == nil or cam.CFrame ~= last then
			base = cam.CFrame
		end
		last = base * fn(os.clock() - start)
		cam.CFrame = last :: CFrame
	end)
	local function undo()
		RunService:UnbindFromRenderStep(name)
		if last and cam.CFrame == last then
			cam.CFrame = base
		end
	end
	table.insert(cleanups, undo)
	return undo
end

local function overlay(color: Color3, transparency: number)
	local f = Instance.new("Frame")
	f.Size = UDim2.fromScale(1, 1)
	f.BackgroundColor3 = color
	f.BackgroundTransparency = transparency
	f.BorderSizePixel = 0
	f.Parent = gui
	table.insert(cleanups, function()
		f:Destroy()
	end)
	return f
end

local FAKE_ERRORS = {
	"ERROR 404: BRAIN NOT FOUND",
	"YOUR GPU IS ON FIRE",
	"CRITICAL: TOO MUCH SKILL",
	"WARNING: CEO IS AFK",
	"VIRUS.EXE IS RUNNING",
	"LOW BATTERY: 1%",
	"AI HAS BECOME SELF AWARE",
	"PLEASE DO NOT PANIC",
}

local TROLLS = {}

TROLLS.shake = function(t)
	cameraFx(function()
		return CFrame.new(math.random() - 0.5, math.random() - 0.5, 0) * CFrame.Angles(0, 0, (math.random() - 0.5) * 0.08)
	end, t)
end

TROLLS.spin = function(t)
	cameraFx(function(e)
		return CFrame.Angles(0, 0, e * 4)
	end, t)
end

TROLLS.upsidedown = function(t)
	cameraFx(function()
		return CFrame.Angles(0, 0, math.pi)
	end, t)
end

TROLLS.tiny = function(_t)
	local cam = workspace.CurrentCamera
	local old = cam.FieldOfView
	TweenService:Create(cam, TweenInfo.new(0.6), { FieldOfView = 115 }):Play()
	table.insert(cleanups, function()
		cam.FieldOfView = old
	end)
end

TROLLS.blind = function(_t)
	local f = overlay(Color3.new(0, 0, 0), 0)
	local l = label(f, "WHO TURNED OFF THE LIGHTS?", UDim2.fromScale(0.6, 0.06), Color3.fromRGB(90, 90, 90))
	l.AnchorPoint = Vector2.new(0.5, 0.5)
	l.Position = UDim2.fromScale(0.5, 0.5)
end

TROLLS.rainbow = function(_t)
	local f = overlay(Color3.new(1, 0, 0), 0.45)
	local token = trollToken
	task.spawn(function()
		while token == trollToken and f.Parent do
			f.BackgroundColor3 = Color3.fromHSV((os.clock() * 0.8) % 1, 1, 1)
			RunService.RenderStepped:Wait()
		end
	end)
end

TROLLS.jumpscare = function(_t)
	local f = overlay(Color3.new(0, 0, 0), 0)
	local l = label(f, "BOO!", UDim2.fromScale(0.9, 0.6), Color3.fromRGB(255, 30, 30))
	l.AnchorPoint = Vector2.new(0.5, 0.5)
	l.Position = UDim2.fromScale(0.5, 0.5)
	cameraFx(function()
		return CFrame.new((math.random() - 0.5) * 2, (math.random() - 0.5) * 2, 0)
	end, 2)
	local token = trollToken
	task.spawn(function()
		while token == trollToken and f.Parent do
			f.BackgroundColor3 = if f.BackgroundColor3 == Color3.new(0, 0, 0) then Color3.fromRGB(120, 0, 0) else Color3.new(0, 0, 0)
			l.Rotation = math.random(-8, 8)
			task.wait(0.07)
		end
	end)
end

TROLLS.fakeban = function(t)
	local f = overlay(Color3.fromRGB(12, 14, 24), 0)
	local title = label(f, "YOU HAVE BEEN BANNED", UDim2.fromScale(0.8, 0.12), Color3.fromRGB(255, 60, 60))
	title.AnchorPoint = Vector2.new(0.5, 0.5)
	title.Position = UDim2.fromScale(0.5, 0.38)
	local reason = label(f, "Reason: being way too good at this game", UDim2.fromScale(0.7, 0.05))
	reason.AnchorPoint = Vector2.new(0.5, 0.5)
	reason.Position = UDim2.fromScale(0.5, 0.52)
	local token = trollToken
	task.delay(math.max(t - 1.5, 1), function()
		if token == trollToken and f.Parent then
			title.Text = "JUST KIDDING"
			title.TextColor3 = Color3.fromRGB(80, 255, 120)
			reason.Text = "an admin is messing with you"
		end
	end)
end

TROLLS.fakemoney = function(t)
	local l = label(gui, "+$999,999,999,999", UDim2.fromScale(0.8, 0.16), Color3.fromRGB(60, 255, 110))
	l.AnchorPoint = Vector2.new(0.5, 0.5)
	l.Position = UDim2.fromScale(0.5, 0.45)
	pop(l)
	table.insert(cleanups, function()
		l:Destroy()
	end)
	local token = trollToken
	task.delay(math.max(t - 1.5, 1), function()
		if token == trollToken and l.Parent then
			l.Text = "JK. YOU GET NOTHING"
			l.TextColor3 = Color3.fromRGB(255, 70, 70)
		end
	end)
end

TROLLS.popups = function(_t)
	local token = trollToken
	task.spawn(function()
		local n = 0
		while token == trollToken and n < 45 do
			n += 1
			local box = Instance.new("Frame")
			box.Size = UDim2.fromScale(0.26, 0.12)
			box.Position = UDim2.fromScale(math.random() * 0.74, math.random() * 0.88)
			box.BackgroundColor3 = Color3.fromRGB(235, 235, 240)
			box.BorderSizePixel = 0
			box.Parent = gui
			local bar = Instance.new("Frame")
			bar.Size = UDim2.fromScale(1, 0.25)
			bar.BackgroundColor3 = Color3.fromRGB(220, 40, 50)
			bar.BorderSizePixel = 0
			bar.Parent = box
			local msg = label(box, FAKE_ERRORS[math.random(#FAKE_ERRORS)], UDim2.fromScale(0.9, 0.5), Color3.fromRGB(30, 30, 30))
			msg.Position = UDim2.fromScale(0.05, 0.35)
			;(msg:FindFirstChildOfClass("UIStroke") :: UIStroke).Enabled = false
			pop(box)
			table.insert(cleanups, function()
				box:Destroy()
			end)
			task.wait(0.15)
		end
	end)
end

local function troll(data)
	local fn = TROLLS[data.kind]
	if not fn then
		return
	end
	stopAll()
	local token = trollToken
	local seconds = tonumber(data.seconds) or 5
	fn(seconds)
	task.delay(seconds, function()
		if token == trollToken then
			stopAll()
		end
	end)
end

remote.OnClientEvent:Connect(function(kind: string, data)
	data = data or {}
	if kind == "announce" then
		table.insert(queue, data)
		task.spawn(runQueue)
	elseif kind == "gift" then
		task.spawn(showGift, data)
	elseif kind == "troll" then
		troll(data)
	elseif kind == "untroll" then
		stopAll()
	end
end)
