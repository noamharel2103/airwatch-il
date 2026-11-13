--!strict
-- Security cameras: live black and white feeds of your office and every place you own.
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Shared = RS:WaitForChild("Shared")
local Format = require(Shared.Format)
local Catalog = require(Shared.Catalog)
local UI = require(script.Parent.UI)
local Net = require(script.Parent.Net)
local T = UI.T
local new = UI.new

local App = { id = "cameras", name = "Cameras", icon = "cameras", color = Color3.fromRGB(18, 184, 214) }
local conns: { RBXScriptConnection } = {}

local function feed(parent: Instance, title: string, build: (WorldModel) -> (CFrame, Vector3))
	local f = new("Frame", { BackgroundColor3 = Color3.fromRGB(10, 10, 12), Parent = parent })
	UI.stroke(f, T.line, 3)
	local vp = new("ViewportFrame", { BackgroundColor3 = Color3.fromRGB(20, 22, 20), Size = UDim2.fromScale(1, 1), Ambient = Color3.fromRGB(170, 175, 170), LightColor = Color3.new(1, 1, 1), LightDirection = Vector3.new(-0.4, -1, -0.5), ImageColor3 = Color3.fromRGB(205, 230, 205), Parent = f })
	local world = Instance.new("WorldModel")
	world.Parent = vp
	local cam = Instance.new("Camera")
	cam.FieldOfView = 70
	cam.Parent = vp
	vp.CurrentCamera = cam
	local center, size = build(world)
	local r = math.max(size.X, size.Z) * 0.55 + 4
	local t = math.random() * 3
	table.insert(conns, RunService.RenderStepped:Connect(function(dt)
		-- slow pan like a real ceiling camera
		t += dt * 0.25
		local a = math.sin(t) * 0.6
		local pos = center.Position + Vector3.new(math.sin(a) * r, size.Y * 0.9 + 4, math.cos(a) * r)
		cam.CFrame = CFrame.lookAt(pos, center.Position)
	end))
	-- overlay text
	new("TextLabel", { Text = title, FontFace = UI.BOLD, TextSize = 11, TextColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 8), Size = UDim2.new(1, -20, 0, 14), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3, Parent = f })
	local rec = new("TextLabel", { Text = "REC", FontFace = UI.BOLD, TextSize = 11, TextColor3 = Color3.fromRGB(255, 60, 60), BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 8), Size = UDim2.fromOffset(40, 14), ZIndex = 3, Parent = f })
	table.insert(conns, RunService.Heartbeat:Connect(function()
		rec.Visible = os.clock() % 1.2 < 0.7
	end))
	return f
end

-- a simple hall full of server racks for places you bought
local function rackHall(world: WorldModel, racks: number)
	local rows = math.clamp(math.ceil(math.sqrt(racks)), 1, 8)
	local w = rows * 5 + 6
	local floor = Instance.new("Part")
	floor.Anchored = true
	floor.Size = Vector3.new(w, 1, w)
	floor.Color = Color3.fromRGB(150, 150, 155)
	floor.Parent = world
	for x = 1, rows do
		for z = 1, rows do
			local p = Instance.new("Part")
			p.Anchored = true
			p.Size = Vector3.new(2.5, 6, 3.5)
			p.CFrame = CFrame.new(-w / 2 + 3 + (x - 1) * 5 + 1, 3.5, -w / 2 + 3 + (z - 1) * 5 + 1)
			p.Color = Color3.fromRGB(25, 27, 32)
			p.Parent = world
			local led = Instance.new("Part")
			led.Anchored = true
			led.Material = Enum.Material.Neon
			led.Size = Vector3.new(2, 0.2, 0.1)
			led.CFrame = p.CFrame * CFrame.new(0, 1.5, 1.8)
			led.Color = Color3.fromRGB(80, 255, 140)
			led.Parent = world
		end
	end
	return CFrame.new(0, 2, 0), Vector3.new(w, 6, w)
end

function App.mount(ctx, s)
	if not s then
		return
	end
	for _, c in ipairs(conns) do
		c:Disconnect()
	end
	table.clear(conns)
	UI.clear(ctx.tabs)
	UI.clear(ctx.body)
	local grid = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = ctx.body })
	new("UIGridLayout", { CellSize = UDim2.new(0.5, -6, 0.5, -6), CellPadding = UDim2.fromOffset(10, 10), Parent = grid })
	local room = workspace:FindFirstChild("Rooms") and workspace.Rooms:FindFirstChild("Stage" .. (s.office or 1))
	local stage = Catalog.officeStages[s.office or 1]
	if room then
		-- two angles of your own office
		for i = 1, 2 do
			feed(grid, string.format("CAM 0%d  %s  %s", i, stage.name:upper(), Format.date(s.day)), function(world)
				local copy = room:Clone()
				for _, d in ipairs(copy:GetDescendants()) do
					if d:IsA("Light") then
						d:Destroy()
					end
				end
				copy.Parent = world
				local cf, size = copy:GetBoundingBox()
				return cf * CFrame.new(i == 1 and -size.X * 0.15 or size.X * 0.15, 0, 0), size
			end)
		end
	end
	-- every place you bought for GPUs
	local n = 2
	for _, st in ipairs(Catalog.storage) do
		local have = (s.storage or {})[st.id] or 0
		if have > 0 and n < 4 then
			n += 1
			feed(grid, string.format("CAM 0%d  %s x%d", n, st.name:upper(), have), function(world)
				return rackHall(world, math.min(64, math.ceil(st.slots / 40)))
			end)
		end
	end
	if n == 2 then
		local f = new("Frame", { BackgroundColor3 = Color3.fromRGB(10, 10, 12), Parent = grid })
		UI.stroke(f, T.line, 3)
		new("TextLabel", { Text = "NO SIGNAL\nBuy a garage or a datacenter in Parts to watch it here.", FontFace = UI.BOLD, TextSize = 12, TextColor3 = T.dim, TextWrapped = true, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = f })
	end
end

function App.key(s)
	local k = tostring(s.office)
	for id, c in pairs(s.storage or {}) do
		k ..= id .. c
	end
	return k
end

return App
