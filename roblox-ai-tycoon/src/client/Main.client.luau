--!strict
-- Client bootstrap: title -> room view (fixed camera, click objects) -> computer apps.
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Modules = script.Parent:WaitForChild("ClientModules")
local UI = require(Modules.UI)
local Net = require(Modules.Net)
local Shell = require(Modules.Shell)
local Title = require(Modules.Title)
local Lab = require(Modules.AppLab)
local Parts = require(Modules.AppParts)
local Team = require(Modules.AppTeam)
local Bank = require(Modules.AppBank)
local Social = require(Modules.AppSocial)
local MailGoals = require(Modules.AppMail)
local Company = require(Modules.AppCompany)
local Playground = require(Modules.Playground)
local Reveal = require(Modules.Reveal)

local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

for _, app in ipairs({ Lab, Parts, Team, Bank, Social, MailGoals.Mail, MailGoals.Goals, Company }) do
	Shell.register(app)
end
Lab.setPlayground(Playground)
Lab.onLaunch = function(result)
	Social.add("launch", result, Net.state and Net.state.day or 0)
	Reveal.play(Shell.gui, result)
end
Net.onEvent(function(kind, data)
	if kind == "incident" then
		Social.add("incident", data, Net.state and Net.state.day or 0)
		Reveal.incident(Shell.gui, data)
	end
end)

-- ===== room view =====
local rooms = workspace:WaitForChild("Rooms", 30)
local currentStage = 0
local baseCF: CFrame? = nil
local function setRoom(stage: number)
	if not rooms then
		return
	end
	local room = rooms:FindFirstChild("Stage" .. stage) or rooms:FindFirstChild("Stage1")
	if not room then
		return
	end
	currentStage = stage
	local cf = room:GetAttribute("CameraCFrame")
	if typeof(cf) == "CFrame" then
		baseCF = cf
	end
	cam.CameraType = Enum.CameraType.Scriptable
	cam.FieldOfView = 46
end
setRoom(1)
local t0 = os.clock()
RunService.RenderStepped:Connect(function()
	cam = workspace.CurrentCamera
	if baseCF then
		cam.CameraType = Enum.CameraType.Scriptable
		local t = os.clock() - t0
		local mouse = UIS:GetMouseLocation()
		local v = cam.ViewportSize
		local mx = (mouse.X / math.max(v.X, 1) - 0.5)
		local my = (mouse.Y / math.max(v.Y, 1) - 0.5)
		-- gentle parallax toward the mouse + idle breathing
		cam.CFrame = baseCF * CFrame.Angles(math.rad(-my * 2 + math.sin(t * 0.4) * 0.15), math.rad(-mx * 3), 0)
	end
end)

-- hover + click on objects in the room
local hl = Instance.new("Highlight")
hl.FillTransparency = 0.85
hl.OutlineColor = Color3.fromRGB(255, 255, 255)
hl.FillColor = Color3.fromRGB(120, 160, 255)
hl.DepthMode = Enum.HighlightDepthMode.Occluded
hl.Parent = workspace
local tip = UI.new("TextLabel", { Text = "", FontFace = UI.BOLD, TextSize = 15, BackgroundTransparency = 0.1, BackgroundColor3 = UI.T.bg, Size = UDim2.fromOffset(10, 30), AutomaticSize = Enum.AutomaticSize.X, Visible = false, ZIndex = 60, Parent = Shell.gui })
UI.corner(tip, 8)
UI.pad(tip, 0, 12)

local function pick(): (Instance?, string?, string?)
	local m = UIS:GetMouseLocation()
	local ray = cam:ViewportPointToRay(m.X, m.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { rooms }
	local hit = workspace:Raycast(ray.Origin, ray.Direction * 400, params)
	local inst = hit and hit.Instance
	while inst and inst ~= rooms do
		local app = inst:GetAttribute("OpenApp")
		if app then
			return inst, app, inst:GetAttribute("Label")
		end
		inst = inst.Parent
	end
	return nil
end

local blocked = true
RunService.Heartbeat:Connect(function()
	if blocked or Shell.isOpen() then
		hl.Adornee = nil
		tip.Visible = false
		return
	end
	local inst, _, label = pick()
	hl.Adornee = inst
	if inst then
		local m = UIS:GetMouseLocation()
		tip.Text = label or "Open"
		tip.Position = UDim2.fromOffset(m.X / Shell.gui:FindFirstChildOfClass("UIScale").Scale + 18, m.Y / Shell.gui:FindFirstChildOfClass("UIScale").Scale - 10)
		tip.Visible = true
	else
		tip.Visible = false
	end
end)
UIS.InputBegan:Connect(function(input, processed)
	if processed or blocked or Shell.isOpen() then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local inst, app = pick()
		if inst then
			Shell.openComputer(app ~= "desktop" and app or nil)
		end
	end
end)

-- room reacts to the company: GPUs in the rack, people at desks, goals on the board
local function totalGpus(s)
	local n = 0
	for _, c in pairs(s.gpus.owned) do
		n += c
	end
	for _, c in pairs(s.gpus.rented) do
		n += c
	end
	return n
end
Net.onState(function(s)
	if s.office ~= currentStage then
		setRoom(s.office)
	end
	local room = rooms and rooms:FindFirstChild("Stage" .. s.office)
	if not room then
		return
	end
	local gpus = totalGpus(s) - 1 -- the laptop does not count
	for _, d in ipairs(room:GetDescendants()) do
		local slot = d:GetAttribute("GpuSlot")
		if slot and d:IsA("BasePart") then
			-- slots fill up on a log-ish scale so big clusters still look full
			local shown = gpus <= 0 and 0 or math.ceil(math.log(gpus + 1, 2) * 2)
			d.Transparency = slot <= shown and 0 or 1
		end
		local w = d:GetAttribute("WorkerSlot")
		if w and d:IsA("BasePart") then
			d.Transparency = w <= s.headcount and 0 or 1
		end
	end
	local board = room:FindFirstChild("GoalsBoard", true)
	local sg = board and board:FindFirstChild("Goals")
	if sg then
		sg:ClearAllChildren()
		local f = UI.new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = sg })
		UI.pad(f, 20)
		UI.list(f, 10)
		UI.new("TextLabel", { Text = "THIS WEEK", FontFace = UI.HEAVY, TextSize = 44, TextColor3 = Color3.fromRGB(255, 245, 220), TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 50), Parent = f })
		for _, g in ipairs(s.goals) do
			local done = g.progress >= g.target
			UI.new("TextLabel", { Text = (g.claimed and "[x] " or (done and "[!] " or "[ ] ")) .. g.text, FontFace = UI.BOLD, TextSize = 34, TextColor3 = done and Color3.fromRGB(150, 255, 170) or Color3.fromRGB(255, 255, 255), Size = UDim2.new(1, 0, 0, 44), Parent = f })
		end
	end
end)

-- ===== start =====
Shell.showHUD(false)
Title.show(Shell.gui, function()
	blocked = false
	Shell.showHUD(true)
	if Net.state then
		setRoom(Net.state.office)
	end
end)
