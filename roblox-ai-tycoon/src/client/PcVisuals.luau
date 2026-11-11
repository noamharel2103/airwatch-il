--!strict
-- Shows the computer parts you bought inside the rig in your room:
-- RAM sticks, CPU cooler, liquid tubes and reservoir, radiator fans, RGB, UPS, NAS, immersion tank.
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PcParts = require(RS:WaitForChild("Shared"):WaitForChild("PcParts"))

local PcVisuals = {}

local lastKey = ""
local glowing: { BasePart } = {}
local lights: { Light } = {}

local function rgb(r, g, b)
	return Color3.fromRGB(r, g, b)
end

local function part(parent: Instance, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?, props: { [string]: any }?)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CastShadow = false
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(props or {}) do
		(p :: any)[k] = v
	end
	p.Parent = parent
	return p
end

local function cyl(parent, length: number, dia: number, cf: CFrame, color: Color3, material: Enum.Material?, props: { [string]: any }?)
	-- cylinders run along their X axis
	return part(parent, Vector3.new(length, dia, dia), cf, color, material, props)
end

-- a tube between two world points
local function tube(parent, a: Vector3, b: Vector3, dia: number, color: Color3, material: Enum.Material?)
	local len = (b - a).Magnitude
	local p = cyl(parent, len, dia, CFrame.lookAt((a + b) / 2, b) * CFrame.Angles(0, math.rad(90), 0), color, material)
	p.Shape = Enum.PartType.Cylinder
	return p
end

local function fan(parent, cf: CFrame, d: number, glow: boolean)
	local ring = part(parent, Vector3.new(0.12, d, d), cf * CFrame.Angles(0, math.rad(90), 0), rgb(30, 32, 38), Enum.Material.SmoothPlastic, { Shape = Enum.PartType.Cylinder })
	local hub = part(parent, Vector3.new(0.14, d * 0.35, d * 0.35), cf * CFrame.Angles(0, math.rad(90), 0), glow and rgb(255, 80, 200) or rgb(70, 72, 80), glow and Enum.Material.Neon or Enum.Material.Metal, { Shape = Enum.PartType.Cylinder })
	if glow then
		table.insert(glowing, hub)
	end
	for i = 0, 2 do
		part(parent, Vector3.new(d * 0.42, 0.06, 0.04), cf * CFrame.Angles(0, 0, math.rad(i * 120)) * CFrame.new(d * 0.22, 0, 0.04), rgb(55, 58, 66))
	end
	return ring
end

local RAM_COLORS = { rgb(80, 80, 85), rgb(60, 160, 90), rgb(60, 120, 220), rgb(140, 80, 220), rgb(230, 180, 50), rgb(230, 60, 60) }

local function build(rig: Model, pc)
	local frame = rig:FindFirstChild("Frame") :: BasePart?
	if not frame then
		return
	end
	local old = rig:FindFirstChild("PcVisuals")
	if old then
		old:Destroy()
	end
	table.clear(glowing)
	table.clear(lights)
	local f = Instance.new("Folder")
	f.Name = "PcVisuals"
	f.Parent = rig
	local c = frame.CFrame
	local s = frame.Size
	local top = s.Y / 2
	local backZ = -s.Z / 2 + 0.2
	local rgbOn = PcParts.get(pc, "rgb").tier > 1
	local fullRgb = PcParts.get(pc, "rgb").tier > 2
	-- make the case hollow so you can see inside: hide the solid block, build panels around it
	frame.Transparency = 1
	local caseCol = frame.Color
	part(f, Vector3.new(s.X, s.Y, 0.12), c * CFrame.new(0, 0, -s.Z / 2 + 0.06), caseCol, Enum.Material.Metal)
	part(f, Vector3.new(0.12, s.Y, s.Z), c * CFrame.new(-s.X / 2 + 0.06, 0, 0), caseCol, Enum.Material.Metal)
	part(f, Vector3.new(0.12, s.Y, s.Z), c * CFrame.new(s.X / 2 - 0.06, 0, 0), caseCol, Enum.Material.Metal)
	part(f, Vector3.new(s.X, 0.12, s.Z), c * CFrame.new(0, s.Y / 2 - 0.06, 0), caseCol, Enum.Material.Metal)
	part(f, Vector3.new(s.X, 0.12, s.Z), c * CFrame.new(0, -s.Y / 2 + 0.06, 0), caseCol, Enum.Material.Metal)
	local glass = rig:FindFirstChild("Glass") :: BasePart?
	if glass then
		glass.Transparency = 0.75
	end
	local inside = Instance.new("PointLight")
	inside.Range = 4
	inside.Brightness = 1.5
	inside.Color = Color3.fromRGB(230, 240, 255)
	inside.Parent = part(f, Vector3.new(0.1, 0.1, 0.1), c * CFrame.new(0, top - 0.4, 0.6), rgb(255, 255, 255), Enum.Material.Neon, { Transparency = 1 })
	-- motherboard on the back wall
	part(f, Vector3.new(s.X - 0.4, s.Y - 0.6, 0.08), c * CFrame.new(0, 0.1, backZ), rgb(26, 34, 30))
	local cpuCF = c * CFrame.new(-0.45, top - 1.0, backZ + 0.12)
	-- CPU
	local cpu = PcParts.get(pc, "cpu")
	part(f, Vector3.new(0.55, 0.55, 0.06), cpuCF, cpu.tier >= 4 and rgb(200, 200, 210) or rgb(150, 150, 155), Enum.Material.Metal)
	-- RAM sticks next to the CPU
	local ram = PcParts.get(pc, "ram")
	for i = 1, ram.sticks or 1 do
		local stick = part(f, Vector3.new(0.07, 0.95, 0.42), c * CFrame.new(0.15 + i * 0.13, top - 1.0, backZ + 0.25), RAM_COLORS[ram.tier] or RAM_COLORS[1], Enum.Material.Metal)
		if rgbOn and ram.tier > 1 then
			local led = part(f, Vector3.new(0.08, 0.1, 0.42), stick.CFrame * CFrame.new(0, 0.52, 0), rgb(255, 255, 255), Enum.Material.Neon)
			table.insert(glowing, led)
		end
	end
	-- cooling
	local cool = PcParts.get(pc, "cooling")
	local front = cpuCF * CFrame.new(0, 0, 0.18)
	if cool.kind == "stock" then
		fan(f, front, 0.5, false)
	elseif cool.kind == "air" then
		local tower = c * CFrame.new(-0.45, top - 1.0, backZ + 0.6)
		for i = -4, 4 do
			part(f, Vector3.new(0.05, 0.9, 0.7), tower * CFrame.new(i * 0.07, 0, 0), rgb(190, 192, 198), Enum.Material.Metal)
		end
		fan(f, tower * CFrame.new(0, 0, 0.42), 0.8, rgbOn)
	else
		-- liquid: pump block on the CPU + radiator with 3 fans at the top
		local pump = part(f, Vector3.new(0.5, 0.5, 0.28), front, rgb(25, 25, 30), Enum.Material.Metal)
		local logo = part(f, Vector3.new(0.3, 0.3, 0.03), pump.CFrame * CFrame.new(0, 0, 0.15), rgb(90, 220, 255), Enum.Material.Neon)
		table.insert(glowing, logo)
		if cool.kind ~= "immersion" then
			local rad = c * CFrame.new(0, top - 0.25, 0)
			part(f, Vector3.new(s.X - 0.5, 0.18, 0.95), rad, rgb(20, 20, 24), Enum.Material.Metal)
			for i = -1, 1 do
				fan(f, rad * CFrame.new(i * 0.85, -0.16, 0) * CFrame.Angles(math.rad(90), 0, 0), 0.75, rgbOn)
			end
			local liquid = cool.kind == "loop" and rgb(60, 230, 255) or rgb(20, 20, 24)
			local mat = cool.kind == "loop" and Enum.Material.Neon or Enum.Material.SmoothPlastic
			local p0 = pump.Position
			if cool.kind == "loop" then
				-- reservoir with glowing coolant
				local resCF = c * CFrame.new(s.X / 2 - 0.45, top - 1.4, backZ + 0.55)
				part(f, Vector3.new(1.1, 0.42, 0.42), resCF * CFrame.Angles(0, 0, math.rad(90)), rgb(200, 230, 255), Enum.Material.Glass, { Shape = Enum.PartType.Cylinder, Transparency = 0.55 })
				local fluid = part(f, Vector3.new(0.9, 0.34, 0.34), resCF * CFrame.new(0, -0.08, 0) * CFrame.Angles(0, 0, math.rad(90)), liquid, Enum.Material.Neon, { Shape = Enum.PartType.Cylinder, Transparency = 0.25 })
				table.insert(glowing, fluid)
				local resTop = resCF.Position + Vector3.new(0, 0.55, 0)
				table.insert(glowing, tube(f, p0, Vector3.new(resCF.Position.X, p0.Y, p0.Z), 0.1, liquid, mat))
				table.insert(glowing, tube(f, resTop, Vector3.new(resTop.X, rad.Position.Y - 0.1, resTop.Z), 0.1, liquid, mat))
				table.insert(glowing, tube(f, p0 + Vector3.new(0, 0.2, 0), Vector3.new(p0.X, rad.Position.Y - 0.1, p0.Z), 0.1, liquid, mat))
			else
				tube(f, p0 + Vector3.new(-0.1, 0.2, 0), Vector3.new(p0.X - 0.1, rad.Position.Y - 0.1, p0.Z), 0.12, liquid, mat)
				tube(f, p0 + Vector3.new(0.1, 0.2, 0), Vector3.new(p0.X + 0.1, rad.Position.Y - 0.1, p0.Z), 0.12, liquid, mat)
			end
		end
	end
	if cool.kind == "immersion" then
		-- a tank of blue liquid next to the rig, with a server board sunk inside
		local tank = c * CFrame.new(s.X / 2 + 1.7, -s.Y / 2 + 1.2, 0)
		part(f, Vector3.new(2.6, 2.4, 2.0), tank, rgb(200, 230, 255), Enum.Material.Glass, { Transparency = 0.6 })
		local fluid = part(f, Vector3.new(2.4, 2.0, 1.8), tank * CFrame.new(0, -0.15, 0), rgb(40, 140, 255), Enum.Material.Neon, { Transparency = 0.55 })
		table.insert(glowing, fluid)
		for i = -1, 1 do
			part(f, Vector3.new(0.1, 1.4, 1.4), tank * CFrame.new(i * 0.6, -0.3, 0), rgb(30, 60, 40))
		end
		for i = 1, 6 do
			part(f, Vector3.new(0.14, 0.14, 0.14), tank * CFrame.new(math.random(-10, 10) / 10, math.random(-6, 8) / 10, math.random(-6, 6) / 10), rgb(220, 240, 255), Enum.Material.Glass, { Shape = Enum.PartType.Ball, Transparency = 0.3 })
		end
		local l = Instance.new("PointLight")
		l.Color = rgb(60, 150, 255)
		l.Range = 9
		l.Brightness = 1.2
		l.Parent = fluid
	end
	-- power: a battery backup box on the floor
	local psu = PcParts.get(pc, "psu")
	if psu.tier >= 4 then
		local ups = c * CFrame.new(-s.X / 2 - 0.75, -s.Y / 2 + (psu.tier >= 5 and 0.8 or 0.5), 0.2)
		part(f, Vector3.new(1.0, psu.tier >= 5 and 1.6 or 1.0, 1.6), ups, rgb(28, 30, 34), Enum.Material.Metal)
		local led = part(f, Vector3.new(0.5, 0.08, 0.05), ups * CFrame.new(0, 0.2, 0.81), rgb(90, 255, 120), Enum.Material.Neon)
		table.insert(glowing, led)
	end
	-- storage: a NAS on top of the rig
	local st = PcParts.get(pc, "storage")
	if st.tier >= 4 then
		local nas = c * CFrame.new(0, top + 0.35, 0)
		part(f, Vector3.new(1.8, 0.6, 1.3), nas, rgb(35, 38, 44), Enum.Material.Metal)
		for i = 0, (st.tier >= 5 and 7 or 3) do
			part(f, Vector3.new(0.12, 0.08, 0.04), nas * CFrame.new(-0.75 + i * 0.2, 0, 0.66), rgb(60, 200, 255), Enum.Material.Neon)
		end
	end
	-- RGB strips around the case
	if rgbOn then
		for _, y in ipairs({ -s.Y / 2 + 0.15, top - 0.1 }) do
			table.insert(glowing, part(f, Vector3.new(s.X - 0.2, 0.06, 0.06), c * CFrame.new(0, y, s.Z / 2 - 0.2), rgb(255, 60, 200), Enum.Material.Neon))
		end
		if fullRgb then
			for _, x in ipairs({ -s.X / 2 + 0.12, s.X / 2 - 0.12 }) do
				table.insert(glowing, part(f, Vector3.new(0.06, s.Y - 0.3, 0.06), c * CFrame.new(x, 0, s.Z / 2 - 0.2), rgb(255, 60, 200), Enum.Material.Neon))
			end
		end
		local l = Instance.new("PointLight")
		l.Range = 8
		l.Brightness = 0.9
		l.Parent = frame
		l.Name = "RgbLight"
		table.insert(lights, l)
	else
		local oldL = frame:FindFirstChild("RgbLight")
		if oldL then
			oldL:Destroy()
		end
	end
	PcVisuals.rgb = rgbOn
end

function PcVisuals.update(room: Instance?, pc)
	if not room or not pc then
		return
	end
	local rig = room:FindFirstChild("GpuRack", true) :: Model?
	if not rig then
		return
	end
	local key = room.Name
	for _, cat in ipairs(PcParts.categories) do
		key ..= (pc[cat.id] or "")
	end
	if key == lastKey then
		return
	end
	lastKey = key
	build(rig, pc)
end

-- slow rainbow on everything that glows (only with RGB lights)
local t = 0
RunService.Heartbeat:Connect(function(dt)
	if not PcVisuals.rgb then
		return
	end
	t += dt
	local col = Color3.fromHSV((t * 0.12) % 1, 0.75, 1)
	for _, p in ipairs(glowing) do
		if p.Parent and p.Material == Enum.Material.Neon and p.Name ~= "Fluid" then
			p.Color = col
		end
	end
	for _, l in ipairs(lights) do
		l.Color = col
	end
end)

return PcVisuals
