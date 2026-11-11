--!strict
-- Negotiation meeting: you sit across the desk from a banker or investor.
-- 3D scene in a ViewportFrame, offer paper on the desk, dialog box with moves.
local RS = game:GetService("ReplicatedStorage")
local Format = require(RS:WaitForChild("Shared"):WaitForChild("Format"))
local Net = require(script.Parent.Net)
local UI = require(script.Parent.UI)
local new = UI.new

local Meeting = {}

local GOTHAM = Font.fromEnum(Enum.Font.GothamBold)
local GOTHAM_REG = Font.fromEnum(Enum.Font.Gotham)
local BLUE = Color3.fromRGB(0, 160, 230)
local GREEN = Color3.fromRGB(70, 170, 85)
local PANEL = Color3.fromRGB(222, 222, 222)
local INK = Color3.fromRGB(15, 15, 15)

local root: Frame? = nil
local seedShown: number? = nil
local refs: any = {}
local showMoves = false

local function part(parent, size, cf, color, shape: Enum.PartType?, material: Enum.Material?)
	local p = Instance.new("Part")
	p.Anchored = true
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	if shape then
		p.Shape = shape
	end
	p.Parent = parent
	return p
end

local function buildScene(vp: ViewportFrame, seed: number)
	local r = Random.new(seed)
	local world = Instance.new("WorldModel")
	world.Parent = vp
	-- window bars and sill
	for x = -16, 16, 8 do
		part(world, Vector3.new(0.5, 30, 0.5), CFrame.new(x, 10, -8), INK)
	end
	part(world, Vector3.new(60, 0.4, 1.2), CFrame.new(0, 1.6, -7.6), Color3.fromRGB(60, 60, 60))
	part(world, Vector3.new(60, 8, 0.5), CFrame.new(0, -2.4, -7.4), Color3.fromRGB(175, 175, 170))
	-- city outside
	for i = 1, 9 do
		local h = r:NextNumber(3, 10)
		local g = r:NextInteger(110, 170)
		part(world, Vector3.new(r:NextNumber(5, 9), h, 5), CFrame.new(-34 + i * 7 + r:NextNumber(-1, 1), -4 + h / 2, -40), Color3.fromRGB(g, g + 5, g + 15))
	end
	-- desk
	part(world, Vector3.new(40, 0.6, 12), CFrame.new(0, 0.5, 2), Color3.fromRGB(92, 42, 30), nil, Enum.Material.Wood)
	-- the person
	local suits = { Color3.fromRGB(60, 110, 170), Color3.fromRGB(45, 45, 55), Color3.fromRGB(120, 40, 40), Color3.fromRGB(50, 110, 70) }
	local hairs = { INK, Color3.fromRGB(90, 55, 30), Color3.fromRGB(200, 160, 60), Color3.fromRGB(150, 60, 30) }
	local hats = { Color3.fromRGB(220, 50, 160), Color3.fromRGB(240, 180, 30), Color3.fromRGB(60, 200, 120), Color3.fromRGB(240, 90, 60) }
	local suit = suits[r:NextInteger(1, #suits)]
	local skin = Color3.fromRGB(225, 190, 20)
	local z = -2
	part(world, Vector3.new(3.4, 2.6, 1.4), CFrame.new(0, 2.1, z), suit)
	part(world, Vector3.new(1.2, 0.4, 1.42), CFrame.new(0, 3.2, z), Color3.fromRGB(215, 215, 215))
	part(world, Vector3.new(0.35, 2.2, 1.44), CFrame.new(0, 2.0, z), INK)
	local head = CFrame.new(0, 4.3, z)
	part(world, Vector3.new(2, 2, 2), head, skin)
	part(world, Vector3.new(0.3, 0.45, 0.05), head * CFrame.new(-0.5, 0.2, 1.01), INK)
	part(world, Vector3.new(0.3, 0.45, 0.05), head * CFrame.new(0.5, 0.2, 1.01), INK)
	part(world, Vector3.new(0.7, 0.15, 0.05), head * CFrame.new(0, -0.5, 1.01), INK)
	local hair = hairs[r:NextInteger(1, #hairs)]
	part(world, Vector3.new(0.9, 2.2, 2.1), head * CFrame.new(-1.35, -0.2, -0.1), hair)
	part(world, Vector3.new(0.9, 2.2, 2.1), head * CFrame.new(1.35, -0.2, -0.1), hair)
	if r:NextNumber() < 0.6 then
		local hat = hats[r:NextInteger(1, #hats)]
		part(world, Vector3.new(2.4, 0.45, 2.2), head * CFrame.new(0, 1.2, 0), hat)
		part(world, Vector3.new(0.9, 0.9, 0.9), head * CFrame.new(0, 1.7, 0), hat, Enum.PartType.Ball)
	else
		part(world, Vector3.new(2.1, 0.5, 2.1), head * CFrame.new(0, 1.2, -0.05), hair)
	end
	-- arms resting on the desk
	part(world, Vector3.new(1, 2.4, 1), CFrame.new(-2.1, 1.7, z + 1) * CFrame.Angles(math.rad(-55), 0, math.rad(-20)), skin)
	part(world, Vector3.new(1, 2.4, 1), CFrame.new(2.1, 1.7, z + 1) * CFrame.Angles(math.rad(-55), 0, math.rad(20)), skin)
	-- cup and the offer paper
	part(world, Vector3.new(1.6, 1, 1), CFrame.new(4.6, 1.6, 0) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(235, 235, 235), Enum.PartType.Cylinder)
	part(world, Vector3.new(6, 0.05, 4.2), CFrame.new(-3.6, 0.83, 5.2) * CFrame.Angles(0, math.rad(6), 0), Color3.fromRGB(238, 238, 238))
	local cam = Instance.new("Camera")
	cam.FieldOfView = 55
	cam.CFrame = CFrame.lookAt(Vector3.new(0, 4.6, 10.5), Vector3.new(0, 2.6, 0))
	cam.Parent = vp
	vp.CurrentCamera = cam
end

local function button(parent, text, color, onClick, order)
	local b = UI.button(parent, text, onClick, color, { Size = UDim2.new(1, 0, 1, 0), LayoutOrder = order or 0 })
	b.FontFace = GOTHAM
	b.TextSize = 20
	return b
end

local function close()
	if root then
		root:Destroy()
	end
	root = nil
	seedShown = nil
	showMoves = false
end

local function render(s)
	local mt = s.meeting
	if not root or not mt then
		return
	end
	local loan = mt.kind == "loan"
	refs.who.Text = mt.who .. "  ·  " .. mt.firm .. (mt.stage and ("  ·  " .. mt.stage) or "")
	refs.quote.Text = "\"" .. (mt.line or "") .. "\""
	if loan then
		refs.offer.Text = string.format("Offer: %s at %.1f%% a year", Format.money(mt.amount), mt.rate * 100)
		local r = mt.rate / 12
		local pay = mt.amount * r / (1 - (1 + r) ^ -mt.months)
		refs.sub.Text = string.format("You'd pay %s a month for %d months  ·  %d moves left", Format.money(pay), mt.months, mt.moves)
		refs.paperBig.Text = Format.money(mt.amount)
		refs.paperSmall.Text = string.format("at %.1f%%", mt.rate * 100)
	else
		refs.offer.Text = string.format("Offer: %s for %.1f%%", Format.money(mt.amount), mt.stake * 100)
		refs.sub.Text = string.format("You'd keep %.1f%% of %s  ·  %d moves left", (s.equity or 1) * (1 - mt.stake) * 100, s.company or "your company", mt.moves)
		refs.paperBig.Text = Format.money(mt.amount)
		refs.paperSmall.Text = string.format("for %.1f%%", mt.stake * 100)
	end
	for i, sq in ipairs(refs.mood) do
		sq.BackgroundColor3 = i <= mt.mood and Color3.fromRGB(70, 200, 90) or Color3.fromRGB(120, 120, 125)
	end
	UI.clear(refs.buttons)
	local grid = new("UIGridLayout", { CellPadding = UDim2.fromOffset(6, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = refs.buttons })
	if not showMoves then
		grid.CellSize = UDim2.new(1 / 3, -4, 0, 58)
		refs.buttons.Size = UDim2.new(1, 0, 0, 58)
		button(refs.buttons, "Take the deal", GREEN, function()
			Net.act("meetAccept")
		end, 1)
		button(refs.buttons, "Make a move", mt.moves > 0 and BLUE or "ghost", function()
			if mt.moves > 0 then
				showMoves = true
				render(Net.state)
			end
		end, 2)
		button(refs.buttons, "Leave", BLUE, function()
			Net.act("meetLeave")
			close()
		end, 3)
	else
		grid.CellSize = UDim2.new(1 / 3, -4, 0, 58)
		refs.buttons.Size = UDim2.new(1, 0, 0, 122)
		local moves = {
			{ "Show earnings", "earnings" },
			{ "Live demo", "demo" },
			{ "Ask for more", "more" },
			{ loan and "Lower the rate" or "Give them less", "less" },
			{ "Others want in", "others" },
		}
		for i, mv in ipairs(moves) do
			local used = mt.used and mt.used[mv[2]] and (mv[2] == "earnings" or mv[2] == "demo" or mv[2] == "others")
			button(refs.buttons, mv[1], used and "ghost" or BLUE, function()
				if not used then
					showMoves = false
					Net.act("meetMove", mv[2])
				end
			end, i)
		end
		button(refs.buttons, "Back", BLUE, function()
			showMoves = false
			render(Net.state)
		end, 6)
	end
end

local function open(host: Instance, s)
	close()
	local mt = s.meeting
	local o = new("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = Color3.fromRGB(110, 205, 245), Size = UDim2.fromScale(1, 1), ZIndex = 70, Parent = host })
	root = o
	seedShown = mt.seed
	local vp = new("ViewportFrame", { BackgroundColor3 = Color3.fromRGB(110, 205, 245), Size = UDim2.fromScale(1, 1), Ambient = Color3.fromRGB(170, 170, 170), LightColor = Color3.new(1, 1, 1), LightDirection = Vector3.new(-0.4, -1, -0.6), ZIndex = 70, Parent = o })
	buildScene(vp, mt.seed or 1)
	-- writing on the paper
	local paper = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromScale(0.17, 0.63), Size = UDim2.fromScale(0.3, 0.2), Rotation = -5, ZIndex = 71, Parent = o })
	new("TextLabel", { Text = "THE OFFER", FontFace = GOTHAM, TextScaled = true, TextColor3 = INK, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 0.16), Parent = paper })
	refs.paperBig = new("TextLabel", { Text = "", FontFace = Font.fromEnum(Enum.Font.GothamBlack), TextScaled = true, TextColor3 = INK, BackgroundTransparency = 1, Position = UDim2.fromScale(0, 0.22), Size = UDim2.fromScale(1, 0.4), Parent = paper })
	refs.paperSmall = new("TextLabel", { Text = "", FontFace = GOTHAM, TextScaled = true, TextColor3 = INK, BackgroundTransparency = 1, Position = UDim2.fromScale(0, 0.66), Size = UDim2.fromScale(1, 0.2), Parent = paper })
	-- dialog box
	local box = new("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -16), Size = UDim2.new(0, 860, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = PANEL, ZIndex = 72, Parent = o })
	UI.stroke(box, INK, 4)
	UI.pad(box, 14)
	UI.list(box, 8)
	local speech = new("Frame", { BackgroundColor3 = Color3.fromRGB(232, 232, 232), Size = UDim2.new(1, 0, 0, 74), LayoutOrder = 1, Parent = box })
	UI.stroke(speech, INK, 3)
	refs.who = new("TextLabel", { Text = "", FontFace = GOTHAM, TextSize = 17, TextColor3 = Color3.fromRGB(95, 95, 95), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(18, 8), Size = UDim2.new(1, -36, 0, 20), Parent = speech })
	refs.quote = new("TextLabel", { Text = "", FontFace = GOTHAM_REG, TextSize = 22, TextColor3 = INK, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Position = UDim2.fromOffset(18, 30), Size = UDim2.new(1, -36, 0, 40), Parent = speech })
	local offerRow = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 2, Parent = box })
	refs.offer = new("TextLabel", { Text = "", FontFace = GOTHAM, TextSize = 24, TextColor3 = INK, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(0.7, 0, 1, 0), Parent = offerRow })
	local moodBox = new("Frame", { BackgroundColor3 = INK, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(5 * 32 + 6, 30), Parent = offerRow })
	new("TextLabel", { Text = "Mood", FontFace = GOTHAM_REG, TextSize = 18, TextColor3 = Color3.fromRGB(95, 95, 95), BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -172, 0.5, 0), Size = UDim2.fromOffset(60, 30), TextXAlignment = Enum.TextXAlignment.Right, Parent = offerRow })
	refs.mood = {}
	for i = 1, 5 do
		refs.mood[i] = new("Frame", { Position = UDim2.fromOffset(4 + (i - 1) * 32, 3), Size = UDim2.fromOffset(28, 24), BorderSizePixel = 0, Parent = moodBox })
	end
	refs.sub = new("TextLabel", { Text = "", FontFace = GOTHAM_REG, TextSize = 18, TextColor3 = Color3.fromRGB(95, 95, 95), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = 3, Parent = box })
	refs.buttons = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 58), LayoutOrder = 4, Parent = box })
	render(s)
end

function Meeting.update(host: Instance, s)
	if not s.meeting then
		close()
	elseif not root or seedShown ~= s.meeting.seed then
		open(host, s)
	else
		render(s)
	end
end

return Meeting
