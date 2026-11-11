--!strict
-- Click your computer in the room: see it up close, spinning, with every part inside.
-- Remove parts you don't need (you get 40% back) or jump to the shop to upgrade.
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Format = require(RS:WaitForChild("Shared"):WaitForChild("Format"))
local PcParts = require(RS.Shared.PcParts)
local Net = require(script.Parent.Net)
local UI = require(script.Parent.UI)
local T = UI.T
local new = UI.new

local RigView = {}
local root: Instance? = nil
local conn: RBXScriptConnection? = nil

function RigView.close()
	if root and RigView.onClose and not RigView.reopening then
		RigView.onClose()
	end
	if conn then
		conn:Disconnect()
		conn = nil
	end
	if root then
		root:Destroy()
		root = nil
	end
end

local function fillList(list: Frame, s, onShop: () -> ())
	UI.clear(list)
	UI.list(list, 8)
	for _, cat in ipairs(PcParts.categories) do
		local p = PcParts.get(s.pc, cat.id)
		local row = new("Frame", { BackgroundColor3 = T.panel2, Size = UDim2.new(1, 0, 0, 62), Parent = list })
		UI.stroke(row, T.line, 3)
		new("TextLabel", { Text = cat.name:upper(), FontFace = UI.BOLD, TextSize = 11, TextColor3 = T.dim, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -150, 0, 16), TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
		new("TextLabel", { Text = p.name, FontFace = UI.FONT, TextSize = 18, TextColor3 = T.text, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 28), Size = UDim2.new(1, -150, 0, 24), TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
		if p.tier > 1 then
			local id = cat.id
			UI.button(row, "REMOVE +" .. Format.money(math.floor(p.price * 0.4)), function()
				Net.act("removePcPart", id)
			end, "ghost", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(130, 36), TextSize = 10 })
		end
	end
	UI.button(list, "UPGRADE PARTS", onShop, T.green, { Size = UDim2.new(1, 0, 0, 48) })
end

function RigView.open(host: Instance, rig: Model, s, onShop: () -> ())
	RigView.close()
	local o = new("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = Color3.fromRGB(10, 14, 30), BackgroundTransparency = 0.25, Size = UDim2.fromScale(1, 1), ZIndex = 40, Parent = host })
	root = o
	local panel = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.new(0, 1100, 0, 640), Parent = o })
	UI.skin(panel)
	UI.stroke(panel, T.line, 4)
	new("TextLabel", { Text = "YOUR COMPUTER", FontFace = UI.HEAVY, TextSize = 20, TextColor3 = T.yellow, BackgroundTransparency = 1, Position = UDim2.fromOffset(24, 18), Size = UDim2.fromOffset(500, 28), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2, Parent = panel })
	UI.button(panel, "X", RigView.close, "ghost", { Position = UDim2.new(1, -60, 0, 14), Size = UDim2.fromOffset(44, 40), ZIndex = 2 })
	-- spinning 3D view of the real rig
	local vp = new("ViewportFrame", { BackgroundColor3 = Color3.fromRGB(24, 30, 56), Position = UDim2.fromOffset(24, 64), Size = UDim2.new(0, 560, 1, -88), Ambient = Color3.fromRGB(150, 150, 170), LightColor = Color3.new(1, 1, 1), LightDirection = Vector3.new(-0.5, -1, -0.8), ZIndex = 2, Parent = panel })
	UI.stroke(vp, T.line, 3)
	local world = Instance.new("WorldModel")
	world.Parent = vp
	local copy = rig:Clone()
	copy.Parent = world
	for _, d in ipairs(copy:GetDescendants()) do
		if d:IsA("BasePart") and d.Name == "Frame" then
			d.Transparency = 1
		end
	end
	local cf, size = copy:GetBoundingBox()
	local cam = Instance.new("Camera")
	cam.FieldOfView = 40
	cam.Parent = vp
	vp.CurrentCamera = cam
	local dist = math.max(size.X, size.Y, size.Z) * 2.1
	local t = 0
	conn = RunService.RenderStepped:Connect(function(dt)
		t += dt * 0.35
		local center = cf.Position
		cam.CFrame = CFrame.lookAt(center + Vector3.new(math.sin(t) * dist, size.Y * 0.35, math.cos(t) * dist), center)
	end)
	-- parts list
	local list = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(604, 64), Size = UDim2.new(1, -628, 1, -88), ZIndex = 2, Parent = panel })
	fillList(list, s, function()
		RigView.close()
		onShop()
	end)
	RigView.list = list
	RigView.onShop = onShop
	RigView.rig = rig
	RigView.host = host
	RigView.lastKey = ""
end

-- keep the list in sync after a remove
function RigView.refresh(s)
	if not root or not RigView.list then
		return
	end
	local key = ""
	for _, c in ipairs(PcParts.categories) do
		key ..= (s.pc and s.pc[c.id] or "")
	end
	if key ~= RigView.lastKey then
		local first = RigView.lastKey == ""
		RigView.lastKey = key
		if not first then
			-- rebuild the whole view so the 3D model shows the change too
			task.defer(function()
				if root and RigView.rig then
					RigView.reopening = true
					RigView.open(RigView.host, RigView.rig, s, RigView.onShop)
					RigView.reopening = false
					RigView.lastKey = key
				end
			end)
		end
	end
end

return RigView
