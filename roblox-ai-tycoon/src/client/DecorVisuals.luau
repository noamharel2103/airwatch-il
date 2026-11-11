--!strict
-- Puts the decor you bought into your room, built from blocks.
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Decor = require(RS:WaitForChild("Shared"):WaitForChild("Decor"))

local DecorVisuals = {}
local lastKey = ""
local spinners: { { p: BasePart, base: CFrame } } = {}

local function rgb(r, g, b)
	return Color3.fromRGB(r, g, b)
end
local M = Enum.Material

local function part(parent: Instance, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material?, props: { [string]: any }?)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = mat or M.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(props or {}) do
		(p :: any)[k] = v
	end
	p.Parent = parent
	return p
end

local function glow(p: BasePart, color: Color3, range: number?)
	local l = Instance.new("PointLight")
	l.Color = color
	l.Range = range or 6
	l.Brightness = 0.8
	l.Parent = p
end

-- each builder gets a CFrame on the floor (or on the wall at eye height), facing into the room
local B = {}
B.plant = function(f, c)
	part(f, Vector3.new(1.4, 1.4, 1.4), c * CFrame.new(0, 0.7, 0), rgb(200, 110, 70), M.Concrete)
	for i = 0, 5 do
		local a = math.rad(i * 60)
		part(f, Vector3.new(0.5, 2.6, 1.3), c * CFrame.new(math.cos(a) * 0.5, 2.6, math.sin(a) * 0.5) * CFrame.Angles(math.sin(a) * 0.4, a, math.cos(a) * 0.4), rgb(60, 150, 70), M.Grass)
	end
end
B.poster = function(f, c)
	part(f, Vector3.new(3, 4, 0.1), c, rgb(250, 245, 230))
	part(f, Vector3.new(2.4, 1.6, 0.12), c * CFrame.new(0, 0.6, 0), rgb(60, 120, 220))
	part(f, Vector3.new(2.4, 0.3, 0.12), c * CFrame.new(0, -0.9, 0), rgb(30, 30, 30))
	part(f, Vector3.new(1.6, 0.2, 0.12), c * CFrame.new(0, -1.4, 0), rgb(120, 120, 120))
end
B.lava = function(f, c)
	part(f, Vector3.new(0.6, 0.4, 0.6), c * CFrame.new(0, 3.3, 0), rgb(200, 200, 210), M.Metal)
	local blob = part(f, Vector3.new(0.45, 1.3, 0.45), c * CFrame.new(0, 4.15, 0), rgb(255, 90, 40), M.Neon, { Shape = Enum.PartType.Cylinder, Transparency = 0.2 })
	blob.CFrame = blob.CFrame * CFrame.Angles(0, 0, math.rad(90))
	glow(blob, rgb(255, 120, 60))
end
B.beanbag = function(f, c)
	part(f, Vector3.new(3, 1.6, 3), c * CFrame.new(0, 0.8, 0), rgb(230, 80, 90), M.Fabric, { Shape = Enum.PartType.Ball })
	part(f, Vector3.new(3.2, 1.2, 3.2), c * CFrame.new(0, 0.6, 0), rgb(230, 80, 90), M.Fabric)
end
B.whiteboard = function(f, c)
	part(f, Vector3.new(6, 3.4, 0.15), c, rgb(250, 250, 250))
	part(f, Vector3.new(6.2, 0.2, 0.3), c * CFrame.new(0, -1.8, 0.1), rgb(160, 160, 165), M.Metal)
	for i = 0, 3 do
		part(f, Vector3.new(0.9, 0.5, 0.17), c * CFrame.new(-2 + i * 1.3, 0.4, 0), ({ rgb(60, 120, 220), rgb(220, 60, 60), rgb(60, 170, 90), rgb(240, 180, 50) })[i + 1])
	end
end
B.fridge = function(f, c)
	part(f, Vector3.new(2, 2.8, 2), c * CFrame.new(0, 1.4, 0), rgb(235, 235, 240), M.Metal)
	part(f, Vector3.new(0.1, 1, 0.12), c * CFrame.new(0.7, 1.8, 1.02), rgb(80, 80, 85), M.Metal)
	part(f, Vector3.new(0.5, 0.8, 0.5), c * CFrame.new(-0.3, 3.2, 0), rgb(60, 220, 120), M.SmoothPlastic)
end
B.monitor = function(f, c)
	part(f, Vector3.new(0.6, 0.1, 0.5), c * CFrame.new(0, 3.2, 0), rgb(30, 30, 34))
	part(f, Vector3.new(0.15, 1, 0.15), c * CFrame.new(0, 3.7, 0), rgb(30, 30, 34))
	part(f, Vector3.new(2.6, 1.5, 0.12), c * CFrame.new(0, 4.6, 0), rgb(20, 20, 24))
	part(f, Vector3.new(2.4, 1.3, 0.05), c * CFrame.new(0, 4.6, 0.07), rgb(60, 220, 140), M.Neon)
end
B.chair = function(f, c)
	part(f, Vector3.new(2, 0.4, 2), c * CFrame.new(0, 2, 0), rgb(20, 20, 24), M.Fabric)
	part(f, Vector3.new(2, 3, 0.4), c * CFrame.new(0, 3.6, -0.9), rgb(220, 40, 50), M.Fabric)
	part(f, Vector3.new(1.4, 2.4, 0.42), c * CFrame.new(0, 3.7, -0.9), rgb(20, 20, 24), M.Fabric)
	part(f, Vector3.new(0.3, 1.6, 0.3), c * CFrame.new(0, 1, 0), rgb(60, 60, 64), M.Metal)
	part(f, Vector3.new(2, 0.2, 2), c * CFrame.new(0, 0.15, 0), rgb(60, 60, 64), M.Metal)
end
B.neon = function(f, c)
	part(f, Vector3.new(3.4, 1.8, 0.1), c, rgb(25, 25, 30))
	local a = part(f, Vector3.new(0.25, 1.3, 0.12), c * CFrame.new(-0.85, 0, 0.05) * CFrame.Angles(0, 0, math.rad(-18)), rgb(255, 60, 200), M.Neon)
	part(f, Vector3.new(0.25, 1.3, 0.12), c * CFrame.new(-0.25, 0, 0.05) * CFrame.Angles(0, 0, math.rad(18)), rgb(255, 60, 200), M.Neon)
	part(f, Vector3.new(0.6, 0.2, 0.12), c * CFrame.new(-0.52, -0.1, 0.05), rgb(255, 60, 200), M.Neon)
	part(f, Vector3.new(0.25, 1.3, 0.12), c * CFrame.new(0.65, 0, 0.05), rgb(60, 220, 255), M.Neon)
	glow(a, rgb(255, 80, 200), 10)
end
B.coffee = function(f, c)
	part(f, Vector3.new(3, 3, 1.6), c * CFrame.new(0, 1.5, 0), rgb(110, 70, 45), M.Wood)
	part(f, Vector3.new(1.2, 1.4, 1), c * CFrame.new(0, 3.7, 0), rgb(190, 190, 195), M.Metal)
	part(f, Vector3.new(0.4, 0.4, 0.4), c * CFrame.new(0.9, 3.2, 0.2), rgb(245, 245, 245))
end
B.trophy = function(f, c)
	part(f, Vector3.new(4, 0.25, 1), c, rgb(110, 70, 45), M.Wood)
	for i = -1, 1 do
		part(f, Vector3.new(0.5, 0.2, 0.5), c * CFrame.new(i * 1.2, 0.22, 0), rgb(40, 40, 40))
		part(f, Vector3.new(0.6, 0.9, 0.6), c * CFrame.new(i * 1.2, 0.8, 0), rgb(240, 190, 50), M.Metal, { Shape = Enum.PartType.Ball })
	end
end
B.stream = function(f, c)
	local ring = part(f, Vector3.new(0.2, 2, 2), c * CFrame.new(0, 5, 0) * CFrame.Angles(0, math.rad(90), 0), rgb(255, 250, 235), M.Neon, { Shape = Enum.PartType.Cylinder })
	part(f, Vector3.new(0.15, 4, 0.15), c * CFrame.new(0, 2, 0), rgb(30, 30, 34), M.Metal)
	part(f, Vector3.new(0.4, 0.8, 0.4), c * CFrame.new(1, 4.2, 0.2), rgb(30, 30, 34), M.Metal)
	glow(ring, rgb(255, 245, 230), 8)
end
B.sofa = function(f, c)
	part(f, Vector3.new(6, 1.2, 2.6), c * CFrame.new(0, 0.9, 0), rgb(70, 90, 140), M.Fabric)
	part(f, Vector3.new(6, 1.8, 0.7), c * CFrame.new(0, 2.1, -1), rgb(70, 90, 140), M.Fabric)
	part(f, Vector3.new(0.7, 1.4, 2.6), c * CFrame.new(-2.8, 1.6, 0), rgb(60, 80, 130), M.Fabric)
	part(f, Vector3.new(0.7, 1.4, 2.6), c * CFrame.new(2.8, 1.6, 0), rgb(60, 80, 130), M.Fabric)
	part(f, Vector3.new(1.3, 1, 0.5), c * CFrame.new(-1.5, 2, -0.5), rgb(240, 200, 80), M.Fabric)
end
B.fish = function(f, c)
	part(f, Vector3.new(4, 2.6, 1.2), c * CFrame.new(0, 1.3, 0), rgb(40, 40, 44), M.Wood)
	part(f, Vector3.new(4, 2.2, 1.2), c * CFrame.new(0, 3.7, 0), rgb(190, 230, 255), M.Glass, { Transparency = 0.5 })
	local water = part(f, Vector3.new(3.8, 1.8, 1), c * CFrame.new(0, 3.6, 0), rgb(40, 150, 230), M.Neon, { Transparency = 0.6 })
	glow(water, rgb(80, 170, 255), 7)
	for i = 1, 3 do
		local fishP = part(f, Vector3.new(0.4, 0.25, 0.12), c * CFrame.new(-1 + i * 0.6, 3.3 + i * 0.25, 0), ({ rgb(255, 140, 40), rgb(255, 220, 60), rgb(240, 80, 80) })[i])
		table.insert(spinners, { p = fishP, base = fishP.CFrame })
	end
end
B.treadmill = function(f, c)
	part(f, Vector3.new(2.4, 0.4, 5), c * CFrame.new(0, 0.2, 0), rgb(30, 30, 34), M.Rubber)
	part(f, Vector3.new(0.2, 3.4, 0.2), c * CFrame.new(-1, 1.9, -2.2), rgb(80, 80, 85), M.Metal)
	part(f, Vector3.new(0.2, 3.4, 0.2), c * CFrame.new(1, 1.9, -2.2), rgb(80, 80, 85), M.Metal)
	part(f, Vector3.new(2.6, 0.2, 1.4), c * CFrame.new(0, 3.6, -2), rgb(240, 240, 240))
	part(f, Vector3.new(1.4, 0.06, 0.9), c * CFrame.new(0, 3.75, -2), rgb(60, 60, 64))
end
B.drone = function(f, c)
	part(f, Vector3.new(1.2, 2.4, 1.2), c * CFrame.new(0, 1.2, 0), rgb(245, 245, 245))
	local body = part(f, Vector3.new(0.8, 0.3, 0.8), c * CFrame.new(0, 2.55, 0), rgb(40, 40, 44))
	for _, o in ipairs({ { 0.6, 0.6 }, { -0.6, 0.6 }, { 0.6, -0.6 }, { -0.6, -0.6 } }) do
		local prop = part(f, Vector3.new(0.7, 0.05, 0.1), body.CFrame * CFrame.new(o[1], 0.2, o[2]), rgb(200, 200, 205))
		table.insert(spinners, { p = prop, base = prop.CFrame })
	end
end
B.arcade = function(f, c)
	part(f, Vector3.new(2.4, 5.6, 2.2), c * CFrame.new(0, 2.8, 0), rgb(40, 30, 120))
	local scr = part(f, Vector3.new(1.8, 1.4, 0.1), c * CFrame.new(0, 4, 1.11) * CFrame.Angles(math.rad(-10), 0, 0), rgb(80, 255, 160), M.Neon)
	part(f, Vector3.new(2.4, 0.5, 0.8), c * CFrame.new(0, 2.9, 1.3), rgb(30, 30, 34))
	part(f, Vector3.new(0.25, 0.25, 0.25), c * CFrame.new(-0.4, 3.25, 1.4), rgb(255, 60, 60), M.Neon, { Shape = Enum.PartType.Ball })
	part(f, Vector3.new(2.4, 0.5, 2.2), c * CFrame.new(0, 5.8, 0), rgb(255, 200, 40), M.Neon)
	glow(scr, rgb(80, 255, 160), 7)
end
B.robot = function(f, c)
	part(f, Vector3.new(1.2, 0.8, 2.4), c * CFrame.new(0, 1.6, 0), rgb(240, 200, 40), M.Metal)
	part(f, Vector3.new(0.8, 0.6, 0.8), c * CFrame.new(0, 2.1, 1.4), rgb(40, 40, 44), M.Metal)
	for _, o in ipairs({ { 0.5, 0.9 }, { -0.5, 0.9 }, { 0.5, -0.9 }, { -0.5, -0.9 } }) do
		part(f, Vector3.new(0.25, 1.3, 0.25), c * CFrame.new(o[1], 0.7, o[2]), rgb(40, 40, 44), M.Metal)
	end
end

function DecorVisuals.update(room: Instance?, owned)
	if not room then
		return
	end
	owned = owned or {}
	local key = room.Name
	for _, d in ipairs(Decor.list) do
		key ..= owned[d.id] and d.id or ""
	end
	if key == lastKey then
		return
	end
	lastKey = key
	local floor = room:FindFirstChild("Floor") :: BasePart?
	if not floor then
		return
	end
	local old = room:FindFirstChild("DecorVisuals")
	if old then
		old:Destroy()
	end
	table.clear(spinners)
	local f = Instance.new("Folder")
	f.Name = "DecorVisuals"
	f.Parent = room
	local base = floor.CFrame * CFrame.new(0, floor.Size.Y / 2, 0)
	local w, d = floor.Size.X, floor.Size.Z
	for _, item in ipairs(Decor.list) do
		if owned[item.id] and B[item.id] then
			local x, z, rot = item.spot[1] * w, item.spot[2] * d, item.spot[3] or 0
			local cf = base * CFrame.new(x, 0, z) * CFrame.Angles(0, math.rad(rot), 0)
			if item.wall then
				-- hang it on the wall at eye height
				local px = math.clamp(x, -w / 2 + 0.2, w / 2 - 0.2)
				local pz = math.clamp(z, -d / 2 + 0.2, d / 2)
				cf = base * CFrame.new(px, 6.5, pz) * CFrame.Angles(0, math.rad(rot), 0)
			end
			B[item.id](f, cf)
		end
	end
end

local t = 0
RunService.Heartbeat:Connect(function(dt)
	if #spinners == 0 then
		return
	end
	t += dt
	for i, s in ipairs(spinners) do
		if s.p.Parent then
			if s.p.Size.X > 0.6 and s.p.Size.Y < 0.1 then
				s.p.CFrame = s.base * CFrame.Angles(0, t * 25, 0)
			else
				s.p.CFrame = s.base * CFrame.new(math.sin(t * 0.8 + i) * 0.8, math.sin(t * 1.3 + i) * 0.15, 0)
			end
		end
	end
end)

return DecorVisuals
