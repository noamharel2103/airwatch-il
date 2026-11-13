--!strict
-- DEAL ROOM: a video call with a banker or investor. Left: their call window and what they say.
-- Right: the contract with the numbers, a patience meter, and your moves as big tiles.
local RS = game:GetService("ReplicatedStorage")
local Format = require(RS:WaitForChild("Shared"):WaitForChild("Format"))
local Net = require(script.Parent.Net)
local UI = require(script.Parent.UI)
local T = UI.T
local new = UI.new

local Meeting = {}

local NAVY = Color3.fromRGB(16, 20, 44)
local LINE = Color3.fromRGB(8, 10, 24)
local GOLD = Color3.fromRGB(255, 196, 30)

local root: Frame? = nil
local seedShown: number? = nil
local refs: any = {}
local callStart = 0

local function close()
	if root then
		root:Destroy()
	end
	root = nil
	seedShown = nil
end

local MOVES = {
	{ id = "earnings", name = "SHOW EARNINGS", desc = "Charts. Growth. Numbers.", color = Color3.fromRGB(0, 200, 110), icon = "bank", once = true },
	{ id = "demo", name = "LIVE DEMO", desc = "Risky. Could crash.", color = Color3.fromRGB(150, 80, 255), icon = "lab", once = true },
	{ id = "more", name = "ASK FOR MORE", desc = "Bigger amount.", color = Color3.fromRGB(255, 150, 0), icon = "cash" },
	{ id = "less", name = "BETTER TERMS", desc = "", color = Color3.fromRGB(0, 170, 255), icon = "shield" },
	{ id = "others", name = "OTHERS WANT IN", desc = "Bluff a rival offer.", color = Color3.fromRGB(255, 60, 120), icon = "fire", once = true },
}

local function render(s)
	local mt = s.meeting
	if not root or not mt then
		return
	end
	local loan = mt.kind == "loan"
	refs.who.Text = (mt.who or "Someone"):upper()
	refs.firm.Text = (mt.firm or "") .. (mt.stage and ("  |  " .. mt.stage) or "")
	refs.quote.Text = mt.line or ""
	refs.kind.Text = loan and "BANK LOAN" or "INVESTMENT ROUND"
	refs.big.Text = Format.money(mt.amount)
	if loan then
		local r = mt.rate / 12
		local pay = mt.amount * r / (1 - (1 + r) ^ -mt.months)
		refs.terms.Text = string.format("%.1f%% A YEAR", mt.rate * 100)
		refs.small.Text = string.format("You pay %s a month for %d months", Format.money(pay), mt.months)
	else
		refs.terms.Text = string.format("FOR %.1f%% OF THE COMPANY", mt.stake * 100)
		refs.small.Text = string.format("You keep %.1f%% of %s", (s.equity or 1) * (1 - mt.stake) * 100, s.company or "your company")
	end
	refs.movesLeft.Text = mt.moves .. " MOVES LEFT"
	local mood = math.clamp(mt.mood or 3, 0, 5)
	refs.patience.Size = UDim2.fromScale(mood / 5, 1)
	refs.patience.BackgroundColor3 = mood >= 4 and T.green or (mood >= 2 and T.yellow or T.red)
	refs.patienceText.Text = ({ "WALKING OUT", "ANNOYED", "UNSURE", "INTERESTED", "HAPPY", "LOVES YOU" })[mood + 1]
	UI.clear(refs.moves)
	new("UIGridLayout", { CellSize = UDim2.new(1 / 3, -8, 0, 96), CellPadding = UDim2.fromOffset(10, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = refs.moves })
	for i, mv in ipairs(MOVES) do
		local used = mv.once and mt.used and mt.used[mv.id]
		local can = mt.moves > 0 and not used
		local b = new("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = can and mv.color or Color3.fromRGB(60, 64, 90), LayoutOrder = i, Parent = refs.moves })
		UI.corner(b, 2)
		UI.stroke(b, LINE, 3)
		new("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(160, 160, 160)), Parent = b })
		local ic = UI.icon(b, mv.icon, mv.color, 54)
		ic.Position = UDim2.fromOffset(10, 21)
		new("TextLabel", { Text = mv.name, FontFace = UI.HEAVY, TextSize = 12, Position = UDim2.fromOffset(74, 20), Size = UDim2.new(1, -82, 0, 20), Parent = b })
		new("TextLabel", { Text = used and "USED" or (mv.id == "less" and (loan and "Lower interest." or "Give less of the company.") or mv.desc), TextSize = 14, Position = UDim2.fromOffset(74, 46), Size = UDim2.new(1, -82, 0, 34), TextYAlignment = Enum.TextYAlignment.Top, Parent = b })
		local id = mv.id
		b.MouseButton1Click:Connect(function()
			if can then
				Net.act("meetMove", id)
			end
		end)
	end
	-- the 6th tile: sign
	local sign = new("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = GOLD, LayoutOrder = 6, Parent = refs.moves })
	UI.corner(sign, 2)
	UI.stroke(sign, LINE, 3)
	new("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(255, 240, 140), Color3.fromRGB(220, 140, 0)), Parent = sign })
	new("TextLabel", { Text = "SIGN THE DEAL", FontFace = UI.HEAVY, TextSize = 16, TextColor3 = Color3.fromRGB(40, 24, 0), TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = sign })
	sign.MouseButton1Click:Connect(function()
		Net.act("meetAccept")
	end)
end

local function open(host: Instance, s)
	close()
	local mt = s.meeting
	callStart = os.clock()
	local o = new("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.35, Size = UDim2.fromScale(1, 1), ZIndex = 70, Parent = host })
	root = o
	seedShown = mt.seed
	local win = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(1240, 700), BackgroundColor3 = NAVY, Parent = o })
	UI.skin(win, NAVY)
	-- top bar
	local bar = new("Frame", { BackgroundColor3 = Color3.fromRGB(0, 170, 255), Size = UDim2.new(1, 0, 0, 56), Parent = win })
	new("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(0, 200, 255), Color3.fromRGB(110, 70, 255)), Parent = bar })
	new("TextLabel", { Text = "DEAL ROOM", FontFace = UI.HEAVY, TextSize = 22, Position = UDim2.fromOffset(20, 0), Size = UDim2.new(0, 300, 1, 0), Parent = bar })
	local live = new("TextLabel", { Text = "LIVE  00:00", FontFace = UI.BOLD, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 0, BackgroundColor3 = T.red, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -150, 0.5, 0), Size = UDim2.fromOffset(150, 32), Parent = bar })
	UI.button(bar, "HANG UP", function()
		Net.act("meetLeave")
		close()
	end, T.red, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(126, 40), TextSize = 12 })
	task.spawn(function()
		while o.Parent do
			local t = math.floor(os.clock() - callStart)
			live.Text = string.format("LIVE  %02d:%02d", t // 60, t % 60)
			task.wait(1)
		end
	end)

	-- left: their call window
	local call = new("Frame", { BackgroundColor3 = Color3.fromRGB(30, 36, 70), Position = UDim2.fromOffset(20, 76), Size = UDim2.fromOffset(420, 604), Parent = win })
	UI.skin(call, Color3.fromRGB(30, 36, 70))
	local rnd = Random.new(mt.seed or 1)
	local bgCol = ({ Color3.fromRGB(0, 160, 230), Color3.fromRGB(150, 80, 255), Color3.fromRGB(255, 120, 40), Color3.fromRGB(0, 190, 120) })[rnd:NextInteger(1, 4)]
	local cam = new("Frame", { BackgroundColor3 = bgCol, Position = UDim2.fromOffset(14, 14), Size = UDim2.new(1, -28, 0, 300), Parent = call })
	new("UIGradient", { Rotation = 90, Color = ColorSequence.new(bgCol:Lerp(Color3.new(1, 1, 1), 0.2), bgCol:Lerp(Color3.new(0, 0, 0), 0.5)), Parent = cam })
	local face = UI.icon(cam, mt.kind == "loan" and "bank" or "crown", bgCol, 170)
	face.AnchorPoint = Vector2.new(0.5, 0.5)
	face.Position = UDim2.fromScale(0.5, 0.5)
	refs.face = face
	task.spawn(function()
		local t0 = os.clock()
		while o.Parent do
			face.Position = UDim2.new(0.5, 0, 0.5, math.sin((os.clock() - t0) * 2.4) * 6)
			task.wait(1 / 30)
		end
	end)
	refs.who = new("TextLabel", { Text = "", FontFace = UI.HEAVY, TextSize = 18, Position = UDim2.fromOffset(18, 330), Size = UDim2.new(1, -36, 0, 24), Parent = call })
	refs.firm = new("TextLabel", { Text = "", TextSize = 16, TextColor3 = T.sub, Position = UDim2.fromOffset(18, 358), Size = UDim2.new(1, -36, 0, 22), Parent = call })
	local bubble = new("Frame", { BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.fromOffset(14, 396), Size = UDim2.new(1, -28, 0, 190), Parent = call })
	UI.corner(bubble, 2)
	UI.stroke(bubble, LINE, 3)
	refs.quote = new("TextLabel", { Text = "", TextSize = 20, TextColor3 = Color3.fromRGB(20, 22, 40), TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(16, 14), Size = UDim2.new(1, -32, 1, -28), Parent = bubble })

	-- right: the contract
	local right = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(460, 76), Size = UDim2.new(1, -480, 0, 604), Parent = win })
	local contract = new("Frame", { BackgroundColor3 = Color3.fromRGB(255, 248, 225), Size = UDim2.new(1, 0, 0, 220), Parent = right })
	UI.corner(contract, 2)
	UI.stroke(contract, GOLD, 5)
	refs.kind = new("TextLabel", { Text = "", FontFace = UI.HEAVY, TextSize = 14, TextColor3 = Color3.fromRGB(150, 100, 0), Position = UDim2.fromOffset(20, 16), Size = UDim2.new(1, -40, 0, 20), Parent = contract })
	refs.big = new("TextLabel", { Text = "", FontFace = UI.HEAVY, TextSize = 58, TextColor3 = Color3.fromRGB(0, 150, 70), Position = UDim2.fromOffset(20, 44), Size = UDim2.new(1, -40, 0, 70), Parent = contract })
	new("UIStroke", { Color = Color3.fromRGB(0, 60, 30), Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual, Parent = refs.big })
	refs.terms = new("TextLabel", { Text = "", FontFace = UI.HEAVY, TextSize = 20, TextColor3 = Color3.fromRGB(30, 30, 50), Position = UDim2.fromOffset(20, 122), Size = UDim2.new(1, -40, 0, 28), Parent = contract })
	refs.small = new("TextLabel", { Text = "", TextSize = 17, TextColor3 = Color3.fromRGB(90, 90, 110), Position = UDim2.fromOffset(20, 156), Size = UDim2.new(1, -40, 0, 24), Parent = contract })
	refs.movesLeft = new("TextLabel", { Text = "", FontFace = UI.BOLD, TextSize = 12, TextColor3 = Color3.fromRGB(255, 255, 255), TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(110, 70, 255), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 14), Size = UDim2.fromOffset(170, 28), Parent = contract })
	-- patience meter
	local pRow = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 236), Size = UDim2.new(1, 0, 0, 40), Parent = right })
	new("TextLabel", { Text = "PATIENCE", FontFace = UI.HEAVY, TextSize = 14, Size = UDim2.fromOffset(150, 40), Parent = pRow })
	local track = new("Frame", { BackgroundColor3 = Color3.fromRGB(30, 34, 60), Position = UDim2.fromOffset(150, 8), Size = UDim2.new(1, -330, 0, 24), Parent = pRow })
	UI.stroke(track, LINE, 3)
	refs.patience = new("Frame", { BackgroundColor3 = T.green, Size = UDim2.fromScale(0.6, 1), Parent = track })
	refs.patienceText = new("TextLabel", { Text = "", FontFace = UI.BOLD, TextSize = 12, TextColor3 = T.yellow, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(170, 40), Parent = pRow })
	refs.moves = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 292), Size = UDim2.new(1, 0, 0, 202), Parent = right })
	render(s)
	local sc = new("UIScale", { Scale = 0.85, Parent = win })
	local fit = UI.fit(win, 24, sc)
	UI.tween(sc, 0.3, { Scale = fit() }, Enum.EasingStyle.Back)
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
