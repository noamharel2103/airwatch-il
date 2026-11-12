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
local Unbox = require(Modules.Unbox)
local Meeting = require(Modules.Meeting)
local PcVisuals = require(Modules.PcVisuals)
local DecorVisuals = require(Modules.DecorVisuals)
local RigView = require(Modules.RigView)

local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

local LinkedIn = require(Modules.AppLinkedIn)
local Cameras = require(Modules.AppCameras)
local ShopApp = require(Modules.AppShop)
local WebsiteApp = require(Modules.AppWebsite)
local Promo = require(Modules.Promo)
local _ = LinkedIn
for _, app in ipairs({ ShopApp, Lab, Parts, Team, WebsiteApp, Bank, Social, MailGoals.Mail, MailGoals.Goals, Company, Cameras }) do
	Shell.register(app)
end
Promo.start(Shell.gui, ShopApp)
Shell.openShop = function(key: string?)
	ShopApp.focus(key)
	if Shell.isOpen() then
		Shell.open("shop")
	else
		Shell.openComputer("shop")
	end
end
-- buy a Robux product right where you are (no shop needed)
Shell.buyProduct = function(key: string, target: number?)
	local ShopData = require(game:GetService("ReplicatedStorage").Shared.Shop)
	local item = ShopData.productByKey[key] or ShopData.passByKey[key]
	if item then
		ShopApp.buy(item, ShopData.passByKey[key] ~= nil, target)
	end
end
Lab.buyProduct = Shell.buyProduct
Team.buyProduct = Shell.buyProduct
Parts.buyProduct = Shell.buyProduct
Team.openShop = function(key: string?)
	Shell.openShop(key)
end
Lab.openShop = function(key: string?, modelId: number?)
	ShopApp.targetModel = modelId
	Shell.openShop(key)
end
Net.onEvent(function(kind, data)
	if kind == "purchase" then
		Shell.toast("PURCHASE COMPLETE. THANK YOU!", "good")
	end
end)
Lab.setPlayground(Playground)
Lab.host = Shell.overlay
Lab.social = Social
Lab.openReviews = function(name)
	Social.selectLaunch(name)
	Shell.open("social")
end
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
local orbit: any
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
-- free look around the room
orbit = { yaw = 0, yawT = 0, pitch = 0, pitchT = 0, zoom = 1, zoomT = 1, dist = 26, idle = 0 }
UIS.InputChanged:Connect(function(input, processed)
	if processed or Shell.isOpen() then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		orbit.zoomT = math.clamp(orbit.zoomT - input.Position.Z * 0.08, 0.45, 1.25)
		orbit.idle = os.clock()
	end
end)
UIS.InputBegan:Connect(function(input, processed)
	if processed or Shell.isOpen() then
		return
	end
	if input.KeyCode == Enum.KeyCode.Q then
		orbit.yawT = math.clamp(orbit.yawT + 20, -45, 45)
		orbit.idle = os.clock()
	elseif input.KeyCode == Enum.KeyCode.E then
		orbit.yawT = math.clamp(orbit.yawT - 20, -45, 45)
		orbit.idle = os.clock()
	end
end)

-- camera zoom toward whatever you clicked (computer, rig...) before it opens
local zoomCF: CFrame? = nil
local zoomA, zoomTarget = 0, 0
local zooming = false
local mx, my = 0, 0
local function overlayBusy(): boolean
	for _, c in ipairs(Shell.overlay:GetChildren()) do
		if c:IsA("GuiObject") and c.Visible and c.Size.X.Scale >= 1 then
			return true
		end
	end
	return false
end
RunService.RenderStepped:Connect(function(dt)
	cam = workspace.CurrentCamera
	if baseCF then
		cam.CameraType = Enum.CameraType.Scriptable
		local t = os.clock() - t0
		-- the camera only follows the mouse while you are looking at the room, not inside a screen
		if not (Shell.isOpen() or zooming or zoomTarget > 0 or overlayBusy()) then
			local mouse = UIS:GetMouseLocation()
			local v = cam.ViewportSize
			mx += ((mouse.X / math.max(v.X, 1) - 0.5) - mx) * math.min(1, dt * 4)
			my += ((mouse.Y / math.max(v.Y, 1) - 0.5) - my) * math.min(1, dt * 4)
		end
		-- orbit around the middle of the room: drag with the right mouse, scroll to zoom, Q/E to turn
		local roomOpen = not (Shell.isOpen() or zooming or zoomTarget > 0 or overlayBusy())
		if Shell.viewBar then
			Shell.viewBar.Visible = roomOpen
		end
		local dragging = roomOpen and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
		local wantLock = dragging and Enum.MouseBehavior.LockCurrentPosition or Enum.MouseBehavior.Default
		if UIS.MouseBehavior ~= wantLock then
			UIS.MouseBehavior = wantLock
		end
		if dragging then
			local d = UIS:GetMouseDelta()
			orbit.yawT = math.clamp(orbit.yawT - d.X * 0.25, -45, 45)
			orbit.pitchT = math.clamp(orbit.pitchT - d.Y * 0.2, -12, 22)
			orbit.idle = os.clock()
		end
		local k = math.min(1, dt * 6)
		orbit.yaw += (orbit.yawT - orbit.yaw) * k
		orbit.pitch += (orbit.pitchT - orbit.pitch) * k
		orbit.zoom += (orbit.zoomT - orbit.zoom) * k
		local drift = os.clock() - orbit.idle > 6 and math.sin(t * 0.15) * 4 or 0
		local pivot = baseCF.Position + baseCF.LookVector * orbit.dist
		local rot = CFrame.Angles(0, math.rad(orbit.yaw + drift - mx * 3), 0) * CFrame.Angles(math.rad(orbit.pitch - my * 2), 0, 0)
		local offset = (baseCF - baseCF.Position) * rot * Vector3.new(0, 0, orbit.dist * orbit.zoom)
		local room = CFrame.lookAt(pivot + offset, pivot)
		-- never get stuck zoomed in once every screen is closed
		if zoomTarget > 0 and not zooming and not Shell.isOpen() and not overlayBusy() then
			zoomTarget = 0
		end
		zoomA += (zoomTarget - zoomA) * math.min(1, dt * 7)
		if zoomCF and zoomA > 0.001 then
			local a = zoomA * zoomA * (3 - 2 * zoomA)
			cam.CFrame = room:Lerp(zoomCF, a)
		else
			cam.CFrame = room
		end
	end
end)

-- zoom in on an object, wait a beat, then run open()
local function focusThen(inst: Instance, open: () -> ())
	if zooming then
		return
	end
	local cf, size
	if inst:IsA("Model") then
		cf, size = inst:GetBoundingBox()
	elseif inst:IsA("BasePart") then
		cf, size = inst.CFrame, inst.Size
	end
	if not cf or not baseCF then
		open()
		return
	end
	local center = cf.Position
	local dir = (baseCF.Position - center).Unit
	local dist = math.max(size.X, size.Y, size.Z) * 1.3 + 3
	zoomCF = CFrame.lookAt(center + dir * dist + Vector3.new(0, 0.6, 0), center)
	zoomTarget = 1
	zooming = true
	task.delay(0.9, function()
		zooming = false
		open()
	end)
end
local function zoomOut()
	zoomTarget = 0
end
Shell.onClose = zoomOut
RigView.onClose = zoomOut

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
	if blocked or Shell.isOpen() or zooming or overlayBusy() then
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
		if inst and app == "openbox" then
			local ok, items = Net.act("openBoxes")
			if ok and type(items) == "table" then
				for _, part in ipairs(inst:GetDescendants()) do
					if part:IsA("BasePart") then
						UI.tween(part, 0.35, { Transparency = 1, Size = part.Size * 1.3 })
					end
				end
				task.spawn(Unbox.play, Shell.overlay, items, function()
					Shell.toast("Installed! Your GPUs are working.", "good")
				end)
			end
		elseif inst and inst.Name == "GpuRack" and Net.state then
			focusThen(inst, function()
				UI.guardUntil = os.clock() + 0.4
				RigView.open(Shell.overlay, inst, Net.state, function()
					zoomTarget = 1
					Shell.openComputer("parts")
				end)
			end)
		elseif inst then
			focusThen(inst, function()
				UI.guardUntil = os.clock() + 0.4
				Shell.openComputer(app ~= "desktop" and app or nil)
			end)
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
local lastBoxes = 0
local seenChat = -1
local lastAch: string? = nil
local knownResearch: { [string]: boolean }? = nil
local Research = require(game:GetService("ReplicatedStorage").Shared.Research)
Net.onState(function(s)
	Meeting.update(Shell.overlay, s)
	RigView.refresh(s)
	if rooms then
		PcVisuals.update(rooms:FindFirstChild("Stage" .. (s.office or 1)), s.pc)
		DecorVisuals.update(rooms:FindFirstChild("Stage" .. (s.office or 1)), s.decor)
	end
	-- breakthroughs pop up as toasts (research runs by itself)
	if knownResearch then
		for id in pairs(s.research.done) do
			if not knownResearch[id] and Research.byId[id] then
				Shell.toast("Breakthrough: " .. Research.byId[id].name .. ". New options in the Lab.", "good")
			end
		end
	end
	knownResearch = table.clone(s.research.done)
	if s.office ~= currentStage then
		setRoom(s.office)
	end
	local room = rooms and rooms:FindFirstChild("Stage" .. s.office)
	if not room then
		return
	end
	-- someone messaged you
	local dmCount = 0
	local lastDm
	for _, c in ipairs(s.chat) do
		if c.ch == "dms" then
			dmCount += 1
			lastDm = c
		end
	end
	if seenChat >= 0 and dmCount > seenChat and lastDm then
		Shell.toast("NEW MESSAGE FROM " .. lastDm.from:upper(), "warn")
	end
	seenChat = dmCount
	-- achievement unlocked
	if s.lastAchievement and s.lastAchievement.id ~= lastAch then
		if lastAch ~= nil then
			Shell.toast("ACHIEVEMENT: " .. s.lastAchievement.name .. "  +" .. require(game:GetService("ReplicatedStorage").Shared.Format).money(s.lastAchievement.reward), "good")
		end
		lastAch = s.lastAchievement.id
	elseif lastAch == nil then
		lastAch = ""
	end
	if (s.boxes or 0) > lastBoxes then
		Shell.toast("A package arrived! Leave the desk and click the box to open it.", "good")
	end
	lastBoxes = s.boxes or 0
	-- delivery box shows up when packages are waiting
	local box = room:FindFirstChild("DeliveryBox")
	if box then
		local show = (s.boxes or 0) > 0
		for _, part in ipairs(box:GetDescendants()) do
			if part:IsA("BasePart") then
				if part:GetAttribute("BaseSize") == nil then
					part:SetAttribute("BaseSize", part.Size)
				end
				part.Size = part:GetAttribute("BaseSize")
				part.Transparency = show and 0 or 1
				part.CanQuery = show
			elseif part:IsA("BillboardGui") then
				part.Enabled = show
			end
		end
	end
	-- desks where a real avatar already sits hide their block worker
	local avatarSlots = {}
	local av = workspace:FindFirstChild("Avatars")
	for _, m in ipairs(av and av:GetChildren() or {}) do
		local slot = m:GetAttribute("Slot")
		if slot then
			avatarSlots[slot] = true
		end
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
		if w and (d:IsA("BasePart") or d:IsA("Decal")) then
			(d :: any).Transparency = (w <= s.headcount and not avatarSlots[w]) and 0 or 1
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

-- when avatars sit down (or leave), hide or show the block worker at that desk right away
task.spawn(function()
	local av = workspace:WaitForChild("Avatars", 60)
	if not av then
		return
	end
	local pending = false
	local function refresh()
		if pending then
			return
		end
		pending = true
		task.delay(0.3, function()
			pending = false
			local s = Net.state
			local room = s and rooms and rooms:FindFirstChild("Stage" .. s.office)
			if not room then
				return
			end
			local taken = {}
			for _, m in ipairs(av:GetChildren()) do
				local slot = m:GetAttribute("Slot")
				if slot then
					taken[slot] = true
				end
			end
			for _, d in ipairs(room:GetDescendants()) do
				local w = d:GetAttribute("WorkerSlot")
				if w and (d:IsA("BasePart") or d:IsA("Decal")) then
					(d :: any).Transparency = (w <= s.headcount and not taken[w]) and 0 or 1
				end
			end
		end)
	end
	av.ChildAdded:Connect(refresh)
	av.ChildRemoved:Connect(refresh)
	refresh()
end)
