-- Dev tool: builds the 6 office stages as real instances in Workspace.Rooms + lighting.
-- Cozy dollhouse rooms (front wall open), each with a fixed CameraAnchor and clickable
-- objects tagged with the attribute OpenApp. Re-running rebuilds everything.
return function()
local Lighting = game:GetService("Lighting")
local W = workspace
for _, n in ipairs({ "Baseplate", "SpawnLocation", "City", "StartRoom", "Office", "Rooms" }) do
	local x = W:FindFirstChild(n)
	if x then
		x:Destroy()
	end
end
local M = Enum.Material
local function rgb(r, g, b)
	return Color3.fromRGB(r, g, b)
end
local function p(parent, name, size, cf, color, mat, extra)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cf
	part.Color = color
	part.Material = mat or M.SmoothPlastic
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(extra or {}) do
		part[k] = v
	end
	part.Parent = parent
	return part
end
local function model(parent, name, app, label)
	local m = Instance.new("Model")
	m.Name = name
	if app then
		m:SetAttribute("OpenApp", app)
		m:SetAttribute("Label", label)
	end
	m.Parent = parent
	return m
end
local function light(parent, kind, props)
	local l = Instance.new(kind)
	for k, v in pairs(props) do
		l[k] = v
	end
	l.Parent = parent
	return l
end

-- ===== Lighting: warm interior =====
pcall(function()
	Lighting.Technology = Enum.Technology.Future
end)
Lighting.Brightness = 1.6
Lighting.ClockTime = 16.5
Lighting.Ambient = rgb(92, 86, 80)
Lighting.OutdoorAmbient = rgb(128, 122, 118)
Lighting.EnvironmentDiffuseScale = 0.6
Lighting.EnvironmentSpecularScale = 0.6
Lighting.ShadowSoftness = 0.25
for _, c in ipairs(Lighting:GetChildren()) do
	if c:IsA("PostEffect") or c:IsA("Atmosphere") then
		c:Destroy()
	end
end
light(Lighting, "ColorCorrectionEffect", { Contrast = 0.1, Saturation = 0.12, TintColor = rgb(255, 248, 238) })
light(Lighting, "BloomEffect", { Intensity = 0.4, Size = 24, Threshold = 1.4 })
light(Lighting, "Atmosphere", { Density = 0.0, Haze = 0, Glare = 0 })

W.StreamingEnabled = false -- small private game: the client needs every room and camera anchor
local rooms = Instance.new("Folder")
rooms.Name = "Rooms"
rooms.Parent = W

-- ===== reusable furniture =====
local WOOD = rgb(132, 96, 64)
local DARK = rgb(38, 40, 46)
local function deskWithPC(parent, cf, laptop, app)
	local m = model(parent, "Desk", app, app and "Computer" or nil)
	p(m, "Top", Vector3.new(6, 0.35, 3), cf * CFrame.new(0, 3, 0), WOOD, M.Wood)
	p(m, "LegL", Vector3.new(0.3, 3, 2.8), cf * CFrame.new(-2.7, 1.5, 0), DARK, M.Metal)
	p(m, "LegR", Vector3.new(0.3, 3, 2.8), cf * CFrame.new(2.7, 1.5, 0), DARK, M.Metal)
	local scr
	if laptop then
		p(m, "Base", Vector3.new(2.4, 0.12, 1.6), cf * CFrame.new(0, 3.24, 0.3), rgb(60, 62, 70), M.Metal)
		scr = p(m, "Screen", Vector3.new(2.4, 1.6, 0.1), cf * CFrame.new(0, 4, -0.55) * CFrame.Angles(math.rad(-10), 0, 0), rgb(18, 20, 26))
	else
		p(m, "Stand", Vector3.new(0.3, 1, 0.3), cf * CFrame.new(0, 3.6, -0.9), DARK, M.Metal)
		scr = p(m, "Screen", Vector3.new(3, 1.8, 0.12), cf * CFrame.new(0, 4.6, -0.9), rgb(18, 20, 26))
		p(m, "Keyboard", Vector3.new(1.8, 0.1, 0.6), cf * CFrame.new(0, 3.22, 0.3), rgb(230, 230, 230))
	end
	local g = Instance.new("SurfaceGui")
	g.Face = Enum.NormalId.Back
	g.LightInfluence = 0
	g.Brightness = 1.6
	g.Parent = scr
	local f = Instance.new("Frame")
	f.Size = UDim2.fromScale(1, 1)
	f.BorderSizePixel = 0
	f.BackgroundColor3 = rgb(60, 90, 170)
	f.Parent = g
	local gr = Instance.new("UIGradient")
	gr.Color = ColorSequence.new(rgb(90, 130, 230), rgb(40, 30, 90))
	gr.Rotation = 120
	gr.Parent = f
	light(scr, "SurfaceLight", { Face = Enum.NormalId.Back, Brightness = 0.6, Range = 5, Color = rgb(140, 170, 255) })
	-- chair
	p(m, "Seat", Vector3.new(2.2, 0.4, 2.2), cf * CFrame.new(0, 1.9, 2.6), rgb(40, 42, 48), M.Fabric)
	p(m, "Back", Vector3.new(2.2, 2.4, 0.35), cf * CFrame.new(0, 3.3, 3.6), rgb(40, 42, 48), M.Fabric)
	p(m, "Pole", Vector3.new(0.3, 1.7, 0.3), cf * CFrame.new(0, 0.85, 2.6), DARK, M.Metal)
	return m
end

local SHIRTS = { rgb(220, 80, 80), rgb(80, 140, 220), rgb(240, 190, 70), rgb(90, 180, 120), rgb(160, 110, 220), rgb(240, 240, 240), rgb(50, 50, 55) }
local SKIN = { rgb(255, 220, 180), rgb(230, 180, 140), rgb(190, 140, 100), rgb(140, 95, 65) }
local workerN = 0
-- simple seated person (shown when you have enough staff)
local function worker(parent, cf)
	workerN += 1
	local m = model(parent, "Worker")
	local idx = workerN
	local shirt = SHIRTS[(idx % #SHIRTS) + 1]
	local skin = SKIN[(idx % #SKIN) + 1]
	local function wp(name, size, c, col, mat)
		local part = p(m, name, size, c, col, mat or M.SmoothPlastic, { CanCollide = false })
		part:SetAttribute("WorkerSlot", idx)
		part.Transparency = 1
		return part
	end
	wp("Torso", Vector3.new(1.8, 2, 1), cf * CFrame.new(0, 3.2, 2.7), shirt, M.Fabric)
	wp("Head", Vector3.new(1.2, 1.2, 1.2), cf * CFrame.new(0, 4.85, 2.7), skin)
	wp("Hair", Vector3.new(1.25, 0.4, 1.25), cf * CFrame.new(0, 5.5, 2.75), ({ rgb(40, 30, 25), rgb(120, 80, 40), rgb(20, 20, 20), rgb(200, 160, 90) })[(idx % 4) + 1])
	wp("ArmL", Vector3.new(0.6, 0.6, 1.8), cf * CFrame.new(-1, 3.4, 1.6), shirt, M.Fabric)
	wp("ArmR", Vector3.new(0.6, 0.6, 1.8), cf * CFrame.new(1, 3.4, 1.6), shirt, M.Fabric)
	wp("Legs", Vector3.new(1.6, 0.6, 2), cf * CFrame.new(0, 2.3, 2), rgb(50, 60, 90), M.Fabric)
end

local gpuN = 0
local function gpuRack(parent, cf, slots, label)
	local m = model(parent, "GpuRack", "parts", label or "GPUs")
	local h = math.max(4, math.ceil(slots / 2) * 0.9 + 1.2)
	p(m, "Frame", Vector3.new(3, h, 2.4), cf * CFrame.new(0, h / 2, 0), rgb(26, 28, 32), M.Metal)
	p(m, "Glass", Vector3.new(2.6, h - 0.4, 0.1), cf * CFrame.new(0, h / 2, 1.22), rgb(160, 190, 220), M.Glass, { Transparency = 0.6 })
	for i = 0, slots - 1 do
		gpuN += 1
		local row, col = math.floor(i / 2), i % 2
		local card = p(m, "GPU", Vector3.new(1.15, 0.6, 1.8), cf * CFrame.new(-0.62 + col * 1.24, 0.7 + row * 0.9, 0.1), rgb(70, 74, 82), M.Metal)
		card:SetAttribute("GpuSlot", i + 1)
		card.Transparency = 1
		local led = p(m, "Led", Vector3.new(1.1, 0.12, 0.05), card.CFrame * CFrame.new(0, 0.15, 0.92), rgb(90, 255, 140), M.Neon)
		led:SetAttribute("GpuSlot", i + 1)
		led.Transparency = 1
	end
	light(m:FindFirstChild("Frame"), "PointLight", { Color = rgb(90, 255, 160), Brightness = 0.5, Range = 7 })
	return m
end

local function goalsBoard(parent, cf, w, h)
	local m = model(parent, "Board", "goals", "Goals")
	p(m, "Frame", Vector3.new(w + 0.4, h + 0.4, 0.25), cf, rgb(100, 70, 45), M.Wood)
	local b = p(m, "GoalsBoard", Vector3.new(w, h, 0.3), cf * CFrame.new(0, 0, 0.05), rgb(150, 112, 74), M.Fabric)
	local g = Instance.new("SurfaceGui")
	g.Name = "Goals"
	g.Face = Enum.NormalId.Front
	g.CanvasSize = Vector2.new(640, 420)
	g.LightInfluence = 0.5
	g.Parent = b
	return m
end

local function plant(parent, cf, s)
	s = s or 1
	p(parent, "Pot", Vector3.new(1.4, 1.4, 1.4) * s, cf * CFrame.new(0, 0.7 * s, 0), rgb(190, 110, 80), M.Slate)
	p(parent, "Leaves", Vector3.new(2.6, 2.6, 2.6) * s, cf * CFrame.new(0, 2.4 * s, 0), rgb(70, 140, 70), M.Grass, { Shape = Enum.PartType.Ball })
end

local function sign(parent, text, cf, w, h, bg, fg)
	local b = p(parent, "Sign", Vector3.new(w, h, 0.2), cf, bg, M.SmoothPlastic)
	local g = Instance.new("SurfaceGui")
	g.Face = Enum.NormalId.Front
	g.LightInfluence = 0.3
	g.CanvasSize = Vector2.new(w * 60, h * 60)
	g.Parent = b
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextScaled = true
	t.Font = Enum.Font.GothamBold
	t.TextColor3 = fg
	t.Parent = g
	return b
end

-- dollhouse shell: floor + back + left + right walls, open front, no ceiling.
local function shell(stage, origin, w, d, h, floorCol, floorMat, wallCol, opts)
	opts = opts or {}
	workerN = 0
	local room = model(rooms, "Stage" .. stage)
	local c = CFrame.new(origin)
	p(room, "Floor", Vector3.new(w, 1, d), c * CFrame.new(0, -0.5, 0), floorCol, floorMat)
	p(room, "Base", Vector3.new(w + 2, 4, d + 2), c * CFrame.new(0, -3, 0), rgb(40, 38, 36), M.Concrete)
	p(room, "WallBack", Vector3.new(w, h, 1), c * CFrame.new(0, h / 2, -d / 2 - 0.5), wallCol, M.Plaster)
	p(room, "WallLeft", Vector3.new(1, h, d + 1), c * CFrame.new(-w / 2 - 0.5, h / 2, -0.5), wallCol:Lerp(Color3.new(0, 0, 0), 0.06), M.Plaster)
	p(room, "WallRight", Vector3.new(1, h, d + 1), c * CFrame.new(w / 2 + 0.5, h / 2, -0.5), wallCol:Lerp(Color3.new(0, 0, 0), 0.06), M.Plaster)
	p(room, "Skirting", Vector3.new(w, 0.5, 0.2), c * CFrame.new(0, 0.25, -d / 2 + 0.1), rgb(240, 238, 232))
	-- a window in the back wall with sky behind it
	local win = opts.window or { x = w * 0.28, wd = math.min(10, w * 0.3), wh = h * 0.45 }
	p(room, "WindowFrame", Vector3.new(win.wd + 0.6, win.wh + 0.6, 0.4), c * CFrame.new(win.x, h * 0.55, -d / 2 - 0.1), rgb(245, 245, 240))
	local glass = p(room, "Window", Vector3.new(win.wd, win.wh, 0.2), c * CFrame.new(win.x, h * 0.55, -d / 2 + 0.05), rgb(150, 200, 235), M.Glass, { Transparency = 0.15, Reflectance = 0.15 })
	light(glass, "SurfaceLight", { Face = Enum.NormalId.Front, Brightness = 1.4, Range = 18, Angle = 70, Color = rgb(255, 236, 205) })
	-- ceiling lamps (lights only, no ceiling so the camera sees in)
	for i = 1, opts.lamps or 2 do
		local x = -w / 2 + i * w / ((opts.lamps or 2) + 1)
		local lamp = p(room, "LampLight", Vector3.new(0.5, 0.5, 0.5), c * CFrame.new(x, h - 1, 0), rgb(255, 240, 220), M.Neon, { Transparency = 1, CanCollide = false })
		light(lamp, "PointLight", { Brightness = 1.1, Range = math.max(18, w * 0.5), Color = rgb(255, 230, 200), Shadows = true })
	end
	-- camera: front, a bit high, looking slightly down and left into the room
	room:SetAttribute("CameraCFrame", CFrame.lookAt(origin + Vector3.new(w * 0.18, h * 1.25, d * 0.95 + 8), origin + Vector3.new(-w * 0.04, h * 0.25, -d * 0.12)))
	local cam = p(room, "CameraAnchor", Vector3.new(1, 1, 1), CFrame.lookAt(origin + Vector3.new(w * 0.18, h * 1.25, d * 0.95 + 8), origin + Vector3.new(-w * 0.04, h * 0.25, -d * 0.12)), rgb(255, 0, 0), M.SmoothPlastic, { Transparency = 1, CanCollide = false, CanQuery = false })
	return room, c
end

-- ===== Stage 1: your room =====
do
	local room, c = shell(1, Vector3.new(0, 0, 0), 22, 16, 11, rgb(160, 120, 84), M.WoodPlanks, rgb(214, 205, 190), { lamps = 1 })
	p(room, "Rug", Vector3.new(9, 0.08, 6), c * CFrame.new(1, 0.04, 2), rgb(70, 90, 130), M.Fabric)
	deskWithPC(room, c * CFrame.new(-4, 0, -5.6), true, "desktop")
	p(room, "Bed", Vector3.new(6, 1.8, 9), c * CFrame.new(7, 0.9, -3), rgb(230, 230, 236), M.Fabric)
	p(room, "Blanket", Vector3.new(6.1, 0.4, 6), c * CFrame.new(7, 1.9, -1.5), rgb(90, 120, 170), M.Fabric)
	p(room, "Pillow", Vector3.new(4, 0.7, 1.6), c * CFrame.new(7, 2.1, -6.6), rgb(250, 250, 250), M.Fabric)
	gpuRack(room, c * CFrame.new(-9.2, 0, -5.8), 4, "Your rig (Parts)")
	goalsBoard(room, c * CFrame.new(-4, 7.6, -7.85), 6, 3.6)
	plant(room, c * CFrame.new(9.5, 0, 6), 0.8)
	p(room, "Shelf", Vector3.new(5, 0.3, 1.2), c * CFrame.new(5, 8.2, -7.4), WOOD, M.Wood)
	for i = 0, 4 do
		p(room, "Book", Vector3.new(0.45, 1.4, 1), c * CFrame.new(3.2 + i * 0.6, 9.05, -7.4), ({ rgb(180, 60, 50), rgb(50, 90, 150), rgb(220, 180, 60), rgb(70, 130, 80), rgb(40, 40, 40) })[i + 1])
	end
	local door = model(room, "Door", "company", "Company and offices")
	p(door, "Door", Vector3.new(0.3, 7.5, 3.6), c * CFrame.new(-10.85, 3.75, 3), rgb(200, 190, 175), M.Wood)
	p(door, "Knob", Vector3.new(0.4, 0.4, 0.4), c * CFrame.new(-10.6, 3.6, 4.4), rgb(200, 170, 80), M.Metal)
	local phone = model(room, "Phone", "social", "What people are saying")
	p(phone, "Phone", Vector3.new(0.6, 0.08, 1.1), c * CFrame.new(-1.2, 3.22, -5), rgb(20, 20, 24), M.Glass)
	p(room, "Mug", Vector3.new(0.6, 0.8, 0.6), c * CFrame.new(-6.6, 3.55, -5), rgb(240, 240, 240))
	p(room, "PizzaBox", Vector3.new(2.6, 0.3, 2.6), c * CFrame.new(3, 0.15, 5), rgb(220, 190, 140), M.Cardboard)
end

-- ===== Stage 2: small shared office =====
do
	local room, c = shell(2, Vector3.new(120, 0, 0), 30, 20, 12, rgb(150, 150, 152), M.Concrete, rgb(232, 230, 224), { lamps = 2 })
	p(room, "Rug", Vector3.new(14, 0.08, 8), c * CFrame.new(-3, 0.04, 2), rgb(60, 70, 85), M.Fabric)
	deskWithPC(room, c * CFrame.new(-9, 0, -7), false, "desktop")
	for i = 0, 2 do
		local cf = c * CFrame.new(-1 + i * 7, 0, -7)
		deskWithPC(room, cf, false)
		worker(room, cf)
	end
	gpuRack(room, c * CFrame.new(13, 0, -7.5), 8, "Server closet (Parts)")
	goalsBoard(room, c * CFrame.new(-3, 8, -9.85), 7, 4)
	p(room, "Whiteboard", Vector3.new(7, 3.6, 0.2), c * CFrame.new(-14.4, 6.5, 0) * CFrame.Angles(0, math.rad(90), 0), rgb(250, 250, 250))
	plant(room, c * CFrame.new(-13, 0, 7), 1)
	p(room, "CoffeeTable", Vector3.new(3, 3.2, 2), c * CFrame.new(13, 1.6, 5), WOOD, M.Wood)
	p(room, "CoffeeMachine", Vector3.new(1.2, 1.6, 1.2), c * CFrame.new(13, 4, 5), DARK, M.Metal)
	local door = model(room, "Door", "company", "Company and offices")
	p(door, "Door", Vector3.new(0.3, 8, 4), c * CFrame.new(-14.85, 4, 6), rgb(70, 90, 110), M.Wood)
	sign(room, "YOUR LOGO HERE", c * CFrame.new(8, 9, -9.88), 8, 1.6, rgb(30, 34, 44), rgb(240, 240, 240))
end

-- ===== Stage 3: office floor with glass room (like the reference, but ours) =====
do
	local room, c = shell(3, Vector3.new(260, 0, 0), 44, 28, 13, rgb(84, 92, 110), M.Fabric, rgb(236, 236, 232), { lamps = 3 })
	-- glass partition separating the team area
	p(room, "GlassWall", Vector3.new(0.3, 12, 18), c * CFrame.new(0, 6, -5), rgb(190, 215, 235), M.Glass, { Transparency = 0.7 })
	p(room, "GlassFrame", Vector3.new(0.5, 0.4, 18), c * CFrame.new(0, 12, -5), rgb(150, 155, 165), M.Metal)
	for r = 0, 1 do
		for col = 0, 2 do
			local cf = c * CFrame.new(-18 + col * 7, 0, -10 + r * 8)
			deskWithPC(room, cf, false)
			worker(room, cf)
		end
	end
	deskWithPC(room, c * CFrame.new(8, 0, -10), false, "desktop")
	-- meeting area
	p(room, "Table", Vector3.new(6, 0.3, 6), c * CFrame.new(14, 3.2, 3), rgb(245, 245, 245), M.SmoothPlastic, { Shape = Enum.PartType.Cylinder, CFrame = c * CFrame.new(14, 3.2, 3) * CFrame.Angles(0, 0, math.rad(90)), Size = Vector3.new(0.3, 6, 6) })
	p(room, "TablePole", Vector3.new(0.4, 3, 0.4), c * CFrame.new(14, 1.5, 3), DARK, M.Metal)
	-- server closet
	p(room, "ServerGlass", Vector3.new(10, 12, 0.3), c * CFrame.new(16, 6, -6), rgb(170, 200, 230), M.Glass, { Transparency = 0.6 })
	gpuRack(room, c * CFrame.new(13.5, 0, -11.5), 12, "Server room (Parts)")
	gpuRack(room, c * CFrame.new(18.5, 0, -11.5), 12, "Server room (Parts)")
	goalsBoard(room, c * CFrame.new(5, 8.4, -13.85), 7, 4)
	sign(room, "YOUR COMPANY", c * CFrame.new(-11, 9.5, -13.88), 12, 2.4, rgb(30, 70, 160), rgb(255, 255, 255))
	local tv = model(room, "TV", "social", "Social feed")
	local scr = p(tv, "TV", Vector3.new(7, 4, 0.3), c * CFrame.new(21.4, 7, 2) * CFrame.Angles(0, math.rad(-90), 0), rgb(18, 18, 22))
	local lift = model(room, "Elevator", "company", "Company and offices")
	p(lift, "Doors", Vector3.new(0.3, 9, 6), c * CFrame.new(-21.85, 4.5, 6), rgb(170, 175, 182), M.Metal)
	plant(room, c * CFrame.new(-20, 0, 12), 1.1)
	plant(room, c * CFrame.new(20, 0, 12), 1.1)
	p(room, "WaterCooler", Vector3.new(1.4, 4, 1.4), c * CFrame.new(-2, 2, 11), rgb(170, 210, 240), M.Glass, { Transparency = 0.2 })
end

-- ===== Stage 4: HQ =====
do
	local room, c = shell(4, Vector3.new(420, 0, 0), 58, 34, 14, rgb(176, 140, 104), M.WoodPlanks, rgb(240, 238, 234), { lamps = 4, window = { x = -10, wd = 22, wh = 7 } })
	for r = 0, 2 do
		for col = 0, 3 do
			local cf = c * CFrame.new(-25 + col * 7, 0, -12 + r * 8)
			deskWithPC(room, cf, false)
			worker(room, cf)
		end
	end
	deskWithPC(room, c * CFrame.new(4, 0, -12), false, "desktop")
	p(room, "ServerGlass", Vector3.new(0.3, 13, 26), c * CFrame.new(10, 6.5, -4), rgb(170, 200, 230), M.Glass, { Transparency = 0.6 })
	for i = 0, 3 do
		gpuRack(room, c * CFrame.new(14 + i * 4, 0, -14), 16, "Server room (Parts)")
	end
	goalsBoard(room, c * CFrame.new(-2, 9, -16.85), 8, 4.4)
	sign(room, "HQ", c * CFrame.new(-18, 10.5, -16.88), 8, 3, rgb(20, 22, 28), rgb(255, 255, 255))
	p(room, "Couch", Vector3.new(10, 2.4, 3.6), c * CFrame.new(18, 1.2, 10), rgb(80, 90, 110), M.Fabric)
	local tv = model(room, "TV", "social", "Social feed")
	p(tv, "TV", Vector3.new(9, 5, 0.3), c * CFrame.new(28.4, 7, 10) * CFrame.Angles(0, math.rad(-90), 0), rgb(18, 18, 22))
	local lift = model(room, "Elevator", "company", "Company and offices")
	p(lift, "Doors", Vector3.new(0.3, 10, 7), c * CFrame.new(-28.85, 5, 10), rgb(170, 175, 182), M.Metal)
	plant(room, c * CFrame.new(-26, 0, 14), 1.2)
end

-- ===== Stage 5: tower floor (skyline) =====
do
	local room, c = shell(5, Vector3.new(620, 0, 0), 70, 40, 15, rgb(60, 62, 70), M.Slate, rgb(225, 228, 234), { lamps = 4, window = { x = 0, wd = 60, wh = 10 } })
	-- skyline behind window
	for i = 0, 14 do
		local hgt = 20 + (i * 37 % 40)
		p(room, "Skyline", Vector3.new(6, hgt, 6), c * CFrame.new(-35 + i * 5, hgt / 2 - 10, -40 - (i % 3) * 6), rgb(120 + i % 3 * 10, 130, 150), M.Glass, { Reflectance = 0.2 })
	end
	for r = 0, 2 do
		for col = 0, 4 do
			local cf = c * CFrame.new(-30 + col * 7, 0, -12 + r * 8)
			deskWithPC(room, cf, false)
			worker(room, cf)
		end
	end
	deskWithPC(room, c * CFrame.new(10, 0, 10), false, "desktop")
	for i = 0, 4 do
		gpuRack(room, c * CFrame.new(12 + i * 4.2, 0, -16), 20, "Server hall (Parts)")
	end
	goalsBoard(room, c * CFrame.new(-31, 8, 0) * CFrame.Angles(0, math.rad(90), 0), 8, 4.4)
	local tv = model(room, "TV", "social", "Social feed")
	p(tv, "TV", Vector3.new(10, 5.5, 0.3), c * CFrame.new(34.4, 8, 8) * CFrame.Angles(0, math.rad(-90), 0), rgb(18, 18, 22))
	local lift = model(room, "Elevator", "company", "Company and offices")
	p(lift, "Doors", Vector3.new(0.3, 10, 7), c * CFrame.new(-34.85, 5, 12), rgb(170, 175, 182), M.Metal)
end

-- ===== Stage 6: campus + datacenter view =====
do
	local room, c = shell(6, Vector3.new(840, 0, 0), 84, 46, 16, rgb(200, 200, 196), M.Marble, rgb(244, 244, 242), { lamps = 5, window = { x = 0, wd = 74, wh = 11 } })
	for i = 0, 9 do
		for j = 0, 2 do
			p(room, "DCRack", Vector3.new(3, 9, 6), c * CFrame.new(-36 + i * 8, -2, -60 - j * 10), rgb(28, 30, 34), M.Metal)
			p(room, "DCLed", Vector3.new(0.1, 7, 5), c * CFrame.new(-34.4 + i * 8, -2, -60 - j * 10), rgb(80, 255, 150), M.Neon)
		end
	end
	for r = 0, 2 do
		for col = 0, 5 do
			local cf = c * CFrame.new(-36 + col * 7, 0, -14 + r * 8)
			deskWithPC(room, cf, false)
			worker(room, cf)
		end
	end
	deskWithPC(room, c * CFrame.new(14, 0, 12), false, "desktop")
	for i = 0, 4 do
		gpuRack(room, c * CFrame.new(12 + i * 5, 0, -19), 24, "Datacenter (Parts)")
	end
	goalsBoard(room, c * CFrame.new(-38, 8, 4) * CFrame.Angles(0, math.rad(90), 0), 9, 5)
	local tv = model(room, "TV", "social", "Social feed")
	p(tv, "TV", Vector3.new(12, 6.5, 0.3), c * CFrame.new(41.4, 8, 8) * CFrame.Angles(0, math.rad(-90), 0), rgb(18, 18, 22))
	local lift = model(room, "Elevator", "company", "Company and offices")
	p(lift, "Doors", Vector3.new(0.3, 11, 8), c * CFrame.new(-41.85, 5.5, 14), rgb(170, 175, 182), M.Metal)
end

-- spawn far away (characters do not load, but Studio wants one)
local sp = Instance.new("SpawnLocation")
sp.Name = "SpawnLocation"
sp.Anchored = true
sp.Transparency = 1
sp.CanCollide = false
sp.Position = Vector3.new(0, -200, 0)
sp.Parent = W
return "rooms built"
end
