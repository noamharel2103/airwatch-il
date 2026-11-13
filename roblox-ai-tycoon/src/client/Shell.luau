--!strict
-- The HUD (date top-right, speed controls, cash) and the computer OS (desktop, app windows).
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local Shared = RS:WaitForChild("Shared")
local Format = require(Shared.Format)
local UI = require(script.Parent.UI)
local Net = require(script.Parent.Net)
local T = UI.T
local new = UI.new

local Shell = {}
local player = Players.LocalPlayer
local gui = new("ScreenGui", { Name = "Game", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 5, Parent = player:WaitForChild("PlayerGui") })
Shell.gui = gui
local scale = new("UIScale", { Parent = gui })
-- dialogs (chat, launch, unboxing) live in their own layer above the HUD
local overlay = new("ScreenGui", { Name = "Overlay", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 50, Parent = player:WaitForChild("PlayerGui") })
local overlayScale = new("UIScale", { Parent = overlay })
scale:GetPropertyChangedSignal("Scale"):Connect(function()
	overlayScale.Scale = scale.Scale
end)
Shell.overlay = overlay
-- keep the HUD clear of the Roblox top bar buttons and phone notches
gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
local function rescale()
	local cam = workspace.CurrentCamera
	local v = gui.AbsoluteSize
	if v.X < 10 then
		v = cam and cam.ViewportSize or Vector2.new(1600, 900)
	end
	local view = cam and cam.ViewportSize or v
	-- a phone gets a smaller design canvas so text stays readable; big windows shrink
	-- on their own with UI.fit
	local phone = UIS.TouchEnabled and math.min(view.X, view.Y) < 600
	-- Studio test switch: workspace attribute FakePhone = true shows the phone layout
	if game:GetService("RunService"):IsStudio() and workspace:GetAttribute("FakePhone") then
		phone = true
	end
	UI.phone = phone
	Shell.phone = phone
	-- bigger canvas = everything a bit smaller on screen (it used to feel huge)
	local w, h = 1700, 960
	if phone then
		w, h = 1060, 550
	end
	local fake = workspace:GetAttribute("FakePhone") == true
	scale.Scale = math.clamp(math.min(v.X / w, v.Y / h), 0.3, fake and 3 or 1.5)
	if Shell.onRescale then
		Shell.onRescale(phone)
	end
end
rescale()
overlayScale.Scale = scale.Scale
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(rescale)
workspace:GetAttributeChangedSignal("FakePhone"):Connect(rescale)
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(rescale)

-- ===== HUD =====
local hud = new("Frame", { Name = "HUD", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 60, Parent = gui })
Shell.hud = hud
local topRight = new("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 14), Size = UDim2.fromOffset(400, 96), BackgroundColor3 = T.bg, BackgroundTransparency = 0.12, Parent = hud })
UI.skin(topRight)
local dateL = new("TextLabel", { Text = "Jan 1, 2023", FontFace = UI.HEAVY, TextSize = 26, Position = UDim2.fromOffset(18, 10), Size = UDim2.new(1, -36, 0, 30), TextXAlignment = Enum.TextXAlignment.Right, Parent = topRight })
local speedRow = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 50), Size = UDim2.new(1, -28, 0, 34), Parent = topRight })
UI.list(speedRow, 6, true, Enum.HorizontalAlignment.Right)
local speedBtns = {}
for _, sp in ipairs({ 0, 1, 2, 4, 8 }) do
	local label = sp == 0 and "II" or ("x" .. sp)
	local b = UI.button(speedRow, label, function()
		if sp == 8 and not (Net.state and Net.state.perks and Net.state.perks.speed8) then
			if Shell.openShop then
				Shell.openShop("speed8")
			end
			return
		end
		Net.act("setSpeed", sp)
	end, "ghost", { Size = UDim2.fromOffset(62, 32), TextSize = 15 })
	speedBtns[sp] = b
end
local warn = new("TextLabel", { Text = "", TextSize = 12, TextColor3 = T.yellow, Position = UDim2.new(0, 0, 1, 4), Size = UDim2.new(1, 0, 0, 16), TextXAlignment = Enum.TextXAlignment.Right, Parent = topRight })

local topLeft = new("Frame", { Position = UDim2.fromOffset(16, 14), Size = UDim2.fromOffset(300, 96), BackgroundColor3 = T.bg, BackgroundTransparency = 0.12, Parent = hud })
UI.skin(topLeft)
local compL = new("TextLabel", { Text = "", FontFace = UI.BOLD, TextSize = 15, TextColor3 = T.sub, Position = UDim2.fromOffset(18, 10), Size = UDim2.new(1, -36, 0, 18), Parent = topLeft })
local cashL = new("TextLabel", { Text = "$0", FontFace = UI.HEAVY, TextSize = 30, TextColor3 = T.green, Position = UDim2.fromOffset(18, 30), Size = UDim2.new(1, -36, 0, 34), Parent = topLeft })
local subL = new("TextLabel", { Text = "", TextSize = 13, TextColor3 = T.sub, Position = UDim2.fromOffset(18, 66), Size = UDim2.new(1, -36, 0, 18), Parent = topLeft })

-- big SHOP button under the money (always on screen)
local shopBtn = UI.button(hud, "SHOP", function()
	if Shell.openShop then
		Shell.openShop(nil)
	end
end, Color3.fromRGB(255, 175, 0), { Position = UDim2.fromOffset(16, 146), Size = UDim2.fromOffset(150, 58), TextSize = 20 })
do
	local ic = UI.icon(shopBtn, "shop", Color3.fromRGB(255, 175, 0), 40)
	ic.Position = UDim2.fromOffset(8, 9)
	shopBtn.TextXAlignment = Enum.TextXAlignment.Right
	new("UIPadding", { PaddingRight = UDim.new(0, 14), Parent = shopBtn })
	-- gentle pulse so it gets noticed
	task.spawn(function()
		local s = new("UIScale", { Parent = shopBtn })
		while shopBtn.Parent do
			UI.tween(s, 0.6, { Scale = 1.06 }, Enum.EasingStyle.Sine)
			task.wait(0.6)
			UI.tween(s, 0.6, { Scale = 1 }, Enum.EasingStyle.Sine)
			task.wait(1.6)
		end
	end)
end
Shell.shopBtn = shopBtn

-- live problems (servers down, hacked...) with the team's fix progress
local problemBox = new("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 70), Size = UDim2.fromOffset(820, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = hud })
UI.list(problemBox, 8)
-- the whole screen goes red during a massive jailbreak
local redAlert = new("Frame", { BackgroundColor3 = Color3.fromRGB(255, 0, 30), BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 1, Parent = hud })
new("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(0.5, 1), NumberSequenceKeypoint.new(1, 0.2) }), Parent = redAlert })
task.spawn(function()
	local t = 0
	while true do
		t += 0.05
		if redAlert:GetAttribute("On") then
			redAlert.BackgroundTransparency = 0.55 + math.sin(t * 4) * 0.15
		else
			redAlert.BackgroundTransparency = 1
		end
		task.wait(0.05)
	end
end)
local PROBLEM_LABEL = { massive = "MASSIVE JAILBREAK", outage = "SERVERS DOWN", hack = "WE GOT HACKED", overheat = "GPUS OVERHEATING", jailbreak = "MODEL JAILBROKEN", bug = "MODEL BUG", exploit = "PROMPT INJECTION" }

-- training mini status (bottom left)
-- training card (bottom left): tap the big button to speed it up; after enough taps it
-- becomes the Robux instant finish
local trainMini = new("Frame", { Position = UDim2.fromOffset(16, 220), Size = UDim2.fromOffset(196, 226), BackgroundColor3 = T.bg, Visible = false, Parent = hud })
new("UICorner", { CornerRadius = UDim.new(0, 10), Parent = trainMini })
new("UIStroke", { Color = T.line, Thickness = 3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = trainMini })
local tmHead = new("Frame", { BackgroundColor3 = T.purple, Size = UDim2.new(1, 0, 0, 30), Parent = trainMini })
new("UICorner", { CornerRadius = UDim.new(0, 10), Parent = tmHead })
new("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(170, 100, 255), Color3.fromRGB(90, 50, 220)), Parent = tmHead })
new("TextLabel", { Text = "TRAINING", FontFace = UI.HEAVY, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = tmHead })
local trainL = new("TextLabel", { Text = "", FontFace = UI.BOLD, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd, TextWrapped = false, Position = UDim2.fromOffset(10, 38), Size = UDim2.new(1, -20, 0, 18), Parent = trainMini })
local trainBarHolder = new("Frame", { BackgroundColor3 = Color3.fromRGB(14, 16, 32), Position = UDim2.fromOffset(12, 62), Size = UDim2.new(1, -24, 0, 22), Parent = trainMini })
new("UICorner", { CornerRadius = UDim.new(0, 11), Parent = trainBarHolder })
local trainFill = new("Frame", { BackgroundColor3 = T.green, Size = UDim2.fromScale(0, 1), Parent = trainBarHolder })
new("UICorner", { CornerRadius = UDim.new(0, 11), Parent = trainFill })
new("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(0, 230, 120), Color3.fromRGB(0, 200, 255)), Parent = trainFill })
local trainPct = new("TextLabel", { Text = "", FontFace = UI.BOLD, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), ZIndex = 3, Parent = trainBarHolder })
new("UIStroke", { Color = T.line, Thickness = 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual, Parent = trainPct })
local trainSub = new("TextLabel", { Text = "", TextSize = 14, TextColor3 = T.sub, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(10, 90), Size = UDim2.new(1, -20, 0, 18), Parent = trainMini })
-- the big button with a soft pulsing ring behind it
local ring = new("Frame", { BackgroundColor3 = T.green, BackgroundTransparency = 0.7, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 166), Size = UDim2.fromOffset(170, 96), Parent = trainMini })
new("UICorner", { CornerRadius = UDim.new(0, 14), Parent = ring })
local tapBtn = new("TextButton", { Text = "TAP!", FontFace = UI.HEAVY, TextSize = 26, TextXAlignment = Enum.TextXAlignment.Center, TextWrapped = true, TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = false, BackgroundColor3 = T.green, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 166), Size = UDim2.fromOffset(160, 86), Parent = trainMini })
new("UICorner", { CornerRadius = UDim.new(0, 12), Parent = tapBtn })
new("UIStroke", { Color = T.line, Thickness = 3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = tapBtn })
local tapGrad = new("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(120, 255, 160), Color3.fromRGB(0, 160, 80)), Parent = tapBtn })
new("UIStroke", { Color = T.line, Thickness = 2.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual, Parent = tapBtn })
local tapScale = new("UIScale", { Parent = tapBtn })

task.spawn(function()
	local t0 = os.clock()
	while true do
		local t = (os.clock() - t0) % 1.4 / 1.4
		ring.Size = UDim2.fromOffset(160 + t * 30, 86 + t * 26)
		ring.BackgroundTransparency = 0.6 + t * 0.4
		task.wait(1 / 30)
	end
end)
local tapState = { taps = 0, finish = false, progress = 0 }
local function floaty(text: string)
	local f = new("TextLabel", { Text = text, FontFace = UI.HEAVY, TextSize = 16, TextColor3 = T.yellow, TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, math.random(-40, 40), 0, 126), Size = UDim2.fromOffset(120, 24), Parent = trainMini })
	new("UIStroke", { Color = T.line, Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual, Parent = f })
	UI.tween(f, 0.7, { Position = f.Position - UDim2.fromOffset(0, 50), TextTransparency = 1 })
	task.delay(0.7, function()
		f:Destroy()
	end)
end
tapBtn.MouseButton1Down:Connect(function()
	tapScale.Scale = 0.88
	UI.tween(tapScale, 0.18, { Scale = 1 }, Enum.EasingStyle.Back)
	if tapState.finish then
		if Shell.buyProduct then
			Shell.buyProduct("finish")
		end
		return
	end
	if Shell.fx then
		Shell.fx.sound("Key", 0.9 + math.random() * 0.3)
	end
	-- feel it right away, the server confirms
	tapState.progress = math.min(0.999, tapState.progress + 0.004)
	trainFill.Size = UDim2.fromScale(math.max(tapState.progress, 0.06), 1)
	trainPct.Text = math.floor(tapState.progress * 100) .. "%"
	floaty("+0.4%")
	task.spawn(function()
		local ok, n = Net.quiet("trainTap")
		if ok and typeof(n) == "number" then
			tapState.taps = n
		end
	end)
end)

-- news ticker (bottom)
local ticker = new("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 14), Size = UDim2.new(1, -700, 0, 40), BackgroundColor3 = T.bg, BackgroundTransparency = 0.15, ClipsDescendants = true, Parent = hud })
UI.corner(ticker, 12)
-- phones: no room between the two top panels, the news goes under them in the middle
local function layoutTicker(phone: boolean)
	if phone then
		ticker.Position = UDim2.new(0.5, 0, 0, 118)
		ticker.Size = UDim2.fromOffset(470, 36)
	else
		ticker.Position = UDim2.new(0.5, 0, 0, 14)
		ticker.Size = UDim2.new(1, -700, 0, 40)
	end
end
layoutTicker(Shell.phone == true)
Shell.layoutTicker = layoutTicker
local tickTag = new("TextLabel", { Text = "NEWS", FontFace = UI.HEAVY, TextSize = 12, TextColor3 = T.bg, BackgroundTransparency = 0, BackgroundColor3 = T.yellow, Size = UDim2.fromOffset(56, 34), TextXAlignment = Enum.TextXAlignment.Center, Parent = ticker })
local tickText = new("TextLabel", { Text = "", TextSize = 14, Position = UDim2.fromOffset(66, 0), Size = UDim2.new(1, -76, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, TextWrapped = false, Parent = ticker })

local hint = new("TextLabel", { Visible = false, Text = "Click the laptop to open the computer", TextSize = 14, TextColor3 = T.sub, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -56), Size = UDim2.fromOffset(500, 18), TextXAlignment = Enum.TextXAlignment.Center, Parent = hud })

-- toasts
-- toasts: small pills at the bottom middle, never more than 3, they slide in and fade out
local toasts = new("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -90), Size = UDim2.fromOffset(560, 200), BackgroundTransparency = 1, Parent = gui, ZIndex = 50 })
UI.list(toasts, 6, false, Enum.HorizontalAlignment.Center)
toasts:FindFirstChildOfClass("UIListLayout").VerticalAlignment = Enum.VerticalAlignment.Bottom
local toastN = 0
function Shell.toast(text: string, kind: string?)
	if Shell.fx then
		Shell.fx.sound(kind == "error" and "Hover" or (kind == "warn" and "Notify" or "Pop"), kind == "error" and 0.5 or 1)
	end
	local color = kind == "error" and T.red or (kind == "good" and T.green or (kind == "warn" and T.yellow or T.accent))
	toastN += 1
	local pills = {}
	for _, c in ipairs(toasts:GetChildren()) do
		if c:IsA("Frame") then
			table.insert(pills, c)
		end
	end
	table.sort(pills, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)
	while #pills >= 3 do
		table.remove(pills, 1):Destroy()
	end
	local f = new("Frame", { Size = UDim2.fromOffset(0, 34), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = T.bg, BackgroundTransparency = 0.08, LayoutOrder = toastN, ZIndex = 50, Parent = toasts })
	UI.corner(f, 2)
	UI.stroke(f, color, 2)
	new("Frame", { BackgroundColor3 = color, Size = UDim2.new(0, 6, 1, 0), ZIndex = 51, Parent = f })
	local label = new("TextLabel", { Text = #text > 70 and (text:sub(1, 68) .. "...") or text, TextSize = 13, TextWrapped = false, Position = UDim2.fromOffset(16, 0), Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, ZIndex = 51, Parent = f })
	new("UIPadding", { PaddingRight = UDim.new(0, 16), Parent = f })
	local _ = label
	local sc = new("UIScale", { Scale = 0.6, Parent = f })
	UI.tween(sc, 0.25, { Scale = 1 }, Enum.EasingStyle.Back)
	task.delay(kind == "warn" and 3 or 3.5, function()
		if f.Parent then
			UI.tween(f, 0.3, { BackgroundTransparency = 1 })
			for _, d in ipairs(f:GetDescendants()) do
				if d:IsA("TextLabel") then
					UI.tween(d, 0.3, { TextTransparency = 1 })
				elseif d:IsA("UIStroke") then
					UI.tween(d, 0.3, { Transparency = 1 })
				end
			end
			task.wait(0.3)
			f:Destroy()
		end
	end)
end
Net.setToast(Shell.toast)

-- ===== Computer =====
local comp = new("Frame", { Name = "Computer", BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 10, Parent = gui })
Shell.computer = comp
-- the OS lives inside a laptop: dark bezel with a camera, a metal keyboard base below
local laptop = new("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -58), Size = UDim2.new(0.74, 0, 1, -196), BackgroundColor3 = Color3.fromRGB(22, 24, 32), ZIndex = 9, Parent = comp })
new("UICorner", { CornerRadius = UDim.new(0, 18), Parent = laptop })
new("UIStroke", { Color = Color3.fromRGB(8, 9, 14), Thickness = 4, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = laptop })
new("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(46, 50, 64), Color3.fromRGB(18, 20, 28)), Parent = laptop })
local camDot = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 13), Size = UDim2.fromOffset(9, 9), BackgroundColor3 = Color3.fromRGB(10, 12, 18), ZIndex = 10, Parent = laptop })
UI.corner(camDot, 99)
new("UIStroke", { Color = Color3.fromRGB(70, 80, 110), Thickness = 1.5, Parent = camDot })
local camLed = new("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0.5, 12, 0, 13), Size = UDim2.fromOffset(5, 5), BackgroundColor3 = Color3.fromRGB(0, 230, 120), ZIndex = 10, Parent = laptop })
UI.corner(camLed, 99)
-- keyboard deck (wider than the lid), with the little thumb notch
local deck = new("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 1, -2), Size = UDim2.new(1.08, 0, 0, 34), BackgroundColor3 = Color3.fromRGB(170, 176, 192), ZIndex = 8, Parent = laptop })
new("UICorner", { CornerRadius = UDim.new(0, 12), Parent = deck })
new("UIStroke", { Color = Color3.fromRGB(8, 9, 14), Thickness = 4, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = deck })
new("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(225, 230, 240), Color3.fromRGB(120, 126, 144)), Parent = deck })
local notch = new("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.fromOffset(170, 10), BackgroundColor3 = Color3.fromRGB(110, 116, 134), ZIndex = 9, Parent = deck })
UI.corner(notch, 6)
local brand = new("TextLabel", { Text = "", FontFace = UI.BOLD, TextSize = 10, TextColor3 = Color3.fromRGB(150, 160, 190), TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -4), Size = UDim2.fromOffset(300, 14), ZIndex = 10, Parent = laptop })
Shell.laptopBrand = brand
local screen = new("Frame", { Position = UDim2.fromOffset(20, 26), Size = UDim2.new(1, -40, 1, -48), BackgroundColor3 = Color3.fromRGB(20, 28, 52), ClipsDescendants = true, ZIndex = 10, Parent = laptop })
new("UICorner", { CornerRadius = UDim.new(0, 6), Parent = screen })
UI.grad(screen, Color3.fromRGB(70, 120, 255), Color3.fromRGB(150, 60, 220), 135)
-- phones: the laptop fills the whole screen (the taskbar already shows money and date)
-- and its inside is drawn a bit smaller so the apps get room to breathe
local PHONE_INNER = 0.8
local screenScale = new("UIScale", { Name = "PhoneScale", Parent = screen })
local layoutDesk: ((boolean) -> ())? = nil
local function layoutLaptop(phone: boolean)
	deck.Visible = not phone
	if phone then
		laptop.Size = UDim2.new(1, -8, 1, -6)
		laptop.Position = UDim2.new(0.5, 0, 1, -3)
		local k = PHONE_INNER
		screen.Position = UDim2.fromOffset(6, 8)
		screen.Size = UDim2.new(1 / k, -12 / k, 1 / k, -16 / k)
		screenScale.Scale = k
	else
		laptop.Size = UDim2.new(0.74, 0, 1, -196)
		laptop.Position = UDim2.new(0.5, 0, 1, -58)
		screen.Position = UDim2.fromOffset(20, 26)
		screen.Size = UDim2.new(1, -40, 1, -48)
		screenScale.Scale = 1
	end
	if comp.Visible then
		hud.Visible = not phone
	end
	if layoutDesk then
		layoutDesk(phone)
	end
end
Shell.onRescale = function(phone: boolean)
	layoutLaptop(phone)
	if Shell.layoutTicker then
		Shell.layoutTicker(phone)
	end
end
-- wallpaper: soft glow blobs and the company logo mark
for i, col in ipairs({ Color3.fromRGB(0, 220, 255), Color3.fromRGB(255, 90, 200), Color3.fromRGB(255, 200, 40) }) do
	local blob = new("Frame", { BackgroundColor3 = col, BackgroundTransparency = 0.82, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(({ 0.75, 0.9, 0.55 })[i], ({ 0.3, 0.75, 0.85 })[i]), Size = UDim2.fromOffset(({ 520, 380, 300 })[i], ({ 520, 380, 300 })[i]), ZIndex = 10, Parent = screen })
	UI.corner(blob, 999)
	new("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }), Parent = blob })
end
-- blocky city skyline wallpaper

local desk = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(40, 40), Size = UDim2.new(0, 400, 1, -120), ZIndex = 11, Parent = screen })
layoutDesk = function(phone: boolean)
	desk.Size = phone and UDim2.new(1, -80, 1, -110) or UDim2.new(0, 400, 1, -120)
end
layoutLaptop(Shell.phone == true)
new("UIGridLayout", { CellSize = UDim2.fromOffset(104, 112), CellPadding = UDim2.fromOffset(14, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = desk })
-- taskbar
local taskbar = new("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -14), Size = UDim2.new(1, -28, 0, 52), BackgroundColor3 = T.bg, BackgroundTransparency = 0.25, ZIndex = 30, Parent = screen })
UI.corner(taskbar, 16)
local tbName = new("TextLabel", { Text = "", FontFace = UI.BOLD, TextSize = 16, Position = UDim2.fromOffset(18, 0), Size = UDim2.new(0, 400, 1, 0), ZIndex = 31, Parent = taskbar })
local tbClock = new("TextLabel", { Text = "", FontFace = UI.BOLD, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -150, 0, 0), Size = UDim2.new(0, 300, 1, 0), ZIndex = 31, Parent = taskbar })
local closeBtn = UI.button(taskbar, "Leave desk", function()
	Shell.closeComputer()
end, "ghost", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(120, 36), ZIndex = 31 })

-- windows
local winLayer = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 12, Parent = screen })
local apps: { [string]: any } = {}
local order: { string } = {}
local openApp: any = nil
local appWindow: Frame? = nil
local badges: { [string]: TextLabel } = {}

function Shell.register(app)
	apps[app.id] = app
	table.insert(order, app.id)
	local btn = new("TextButton", { Text = "", BackgroundTransparency = 1, LayoutOrder = #order, ZIndex = 12, Parent = desk })
	local ic = UI.icon(btn, app.icon, app.color, 80)
	ic.Position = UDim2.fromOffset(12, 0)
	ic.ZIndex = 12
	for _, d in ipairs(ic:GetDescendants()) do
		if d:IsA("GuiObject") then
			d.ZIndex = 13
		end
	end
	new("TextLabel", { Text = UI.POP and string.upper(app.name) or app.name, FontFace = UI.HEAVY, TextSize = UI.POP and 16 or 14, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 82), Size = UDim2.new(1, 0, 0, 20), ZIndex = 12, Parent = btn })
	local badge = new("TextLabel", { Text = "", FontFace = UI.BOLD, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 0, BackgroundColor3 = T.red, Position = UDim2.fromOffset(74, -2), Size = UDim2.fromOffset(22, 22), Visible = false, ZIndex = 14, Parent = btn })
	UI.corner(badge, 11)
	badges[app.id] = badge
	local isc = new("UIScale", { Parent = ic })
	btn.MouseEnter:Connect(function()
		UI.tween(isc, 0.18, { Scale = 1.12 }, Enum.EasingStyle.Back)
	end)
	btn.MouseLeave:Connect(function()
		UI.tween(isc, 0.15, { Scale = 1 })
	end)
	btn.MouseButton1Click:Connect(function()
		if os.clock() < UI.guardUntil then
			return
		end
		isc.Scale = 0.85
		UI.tween(isc, 0.25, { Scale = 1 }, Enum.EasingStyle.Back)
		if Shell.fx then
			Shell.fx.sound("Pop", 1.15)
		end
		Shell.open(app.id)
	end)
end

local function buildWindow(app)
	if appWindow then
		appWindow:Destroy()
	end
	-- Active: the window eats clicks, so tapping inside an app never opens the desktop icon behind it
	local w = new("Frame", { Active = true, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 16), Size = UDim2.new(1, -32, 1, -96), BackgroundColor3 = T.bg, BackgroundTransparency = 0, ZIndex = 20, Parent = winLayer })
	UI.skin(w, T.bg)
	local bar = new("Frame", { Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = T.accent, ZIndex = 21, Parent = w })
	if UI.POP then
		-- every app has its own colour bar: light top, darker bottom, dark rim
		local c = app.color or T.purple
		UI.grad(bar, c:Lerp(Color3.new(1, 1, 1), 0.3), c:Lerp(Color3.new(0, 0, 0), 0.25), 90)
		UI.corner(bar, 14)
		new("UIStroke", { Color = c:Lerp(Color3.fromRGB(20, 8, 40), 0.62), Thickness = 3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = bar })
	else
		UI.grad(bar, Color3.fromRGB(60, 200, 255), Color3.fromRGB(0, 120, 210), 0)
		UI.corner(bar, 3)
	end
	local ic = UI.icon(bar, app.icon, app.color, UI.POP and 44 or 32)
	ic.Position = UI.POP and UDim2.fromOffset(10, 6) or UDim2.fromOffset(16, 12)
	new("TextLabel", { Text = app.name, FontFace = UI.HEAVY, TextSize = UI.POP and 24 or 20, Position = UDim2.fromOffset(60, 0), Size = UDim2.new(0, 300, 1, 0), ZIndex = 21, Parent = bar })
	local tabs = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(240, 10), Size = UDim2.new(1, -330, 0, 36), ZIndex = 21, Parent = bar })
	UI.list(tabs, 6, true)
	local x = UI.button(bar, "X", function()
		Shell.closeApp()
	end, UI.POP and "danger" or "ghost", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 8), Size = UDim2.fromOffset(44, 40), ZIndex = 22 })
	local body = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(18, 62), Size = UDim2.new(1, -36, 1, -78), ZIndex = 21, ClipsDescendants = true, Parent = w })
	appWindow = w
	w.Size = UDim2.new(1, -80, 1, -150)
	UI.tween(w, 0.2, { Size = UDim2.new(1, -32, 1, -96) }, Enum.EasingStyle.Back)
	return body, tabs
end

-- Apps get: ctx = { body, tabs, rerender(), state }
function Shell.open(id: string)
	local app = apps[id]
	if not app then
		return
	end
	if openApp and openApp.close then
		openApp.close()
	end
	openApp = app
	desk.Visible = false
	local body, tabs = buildWindow(app)
	app.ctx = { body = body, tabs = tabs }
	app.lastKey = nil
	app.mount(app.ctx, Net.state)
	if app.key then
		app.lastKey = app.key(Net.state)
	end
end

function Shell.closeApp()
	if openApp and openApp.close then
		openApp.close()
	end
	openApp = nil
	desk.Visible = true
	if appWindow then
		appWindow:Destroy()
		appWindow = nil
	end
end

-- Boot screen: the company OS starts up (long the first time, quick after that).
local booted = false
local booting = false
local function osName(): string
	local c = (Net.state and Net.state.company) or "NOMAD"
	local first = c:match("^(%S+)") or c
	return first:upper() .. " OS"
end
local function bootThen(after: () -> ())
	if booting then
		return
	end
	booting = true
	local long = not booted
	booted = true
	local dur = long and 2.2 or 0.8
	local boot = new("Frame", { BackgroundColor3 = Color3.fromRGB(6, 8, 20), Size = UDim2.fromScale(1, 1), ZIndex = 80, Parent = screen })
	new("UICorner", { CornerRadius = UDim.new(0, 6), Parent = boot })
	new("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(14, 18, 48), Color3.fromRGB(4, 4, 12)), Parent = boot })
	-- logo: four coloured blocks turning into a diamond
	local logo = new("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.4), Size = UDim2.fromOffset(120, 120), Rotation = 0, ZIndex = 81, Parent = boot })
	local cols = { Color3.fromRGB(0, 200, 255), Color3.fromRGB(255, 70, 160), Color3.fromRGB(255, 196, 30), Color3.fromRGB(0, 215, 105) }
	for i = 0, 3 do
		local b = new("Frame", { BackgroundColor3 = cols[i + 1], Position = UDim2.fromOffset((i % 2) * 62, math.floor(i / 2) * 62), Size = UDim2.fromOffset(56, 56), BackgroundTransparency = 1, ZIndex = 82, Parent = logo })
		UI.corner(b, 2)
		task.delay(i * 0.08, function()
			UI.tween(b, 0.3, { BackgroundTransparency = 0 })
		end)
	end
	UI.tween(logo, dur * 0.8, { Rotation = 45 }, Enum.EasingStyle.Back)
	local name = new("TextLabel", { Text = osName(), FontFace = UI.HEAVY, TextSize = 34, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Center, TextTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.4, 100), Size = UDim2.fromOffset(700, 44), ZIndex = 81, Parent = boot })
	UI.tween(name, 0.4, { TextTransparency = 0 })
	local ver = new("TextLabel", { Text = "VERSION " .. tostring(Net.state and Net.state.year or 2023) .. "." .. tostring(Net.state and Net.state.launches or 0), FontFace = UI.BOLD, TextSize = 12, TextColor3 = Color3.fromRGB(120, 140, 200), TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.4, 150), Size = UDim2.fromOffset(700, 18), ZIndex = 81, Parent = boot })
	local _ = ver
	local track = new("Frame", { BackgroundColor3 = Color3.fromRGB(30, 36, 70), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.4, 186), Size = UDim2.fromOffset(360, 12), ZIndex = 81, Parent = boot })
	local fill = new("Frame", { BackgroundColor3 = Color3.fromRGB(0, 200, 255), Size = UDim2.fromScale(0, 1), ZIndex = 82, Parent = track })
	new("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, cols[1]), ColorSequenceKeypoint.new(0.33, cols[2]), ColorSequenceKeypoint.new(0.66, cols[3]), ColorSequenceKeypoint.new(1, cols[4]) }), Parent = fill })
	local line = new("TextLabel", { Text = "", TextSize = 13, TextColor3 = Color3.fromRGB(150, 165, 220), TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.4, 208), Size = UDim2.fromOffset(700, 18), ZIndex = 81, Parent = boot })
	UI.tween(fill, dur, { Size = UDim2.fromScale(1, 1) }, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	task.spawn(function()
		local steps = long and { "Waking up the GPUs...", "Loading AI models...", "Checking the bank account...", "Connecting to the office..." } or { "Welcome back" }
		for _, st in ipairs(steps) do
			line.Text = st
			task.wait(dur / #steps)
		end
		booting = false
		after()
		UI.tween(boot, 0.25, { BackgroundTransparency = 1 })
		for _, d in ipairs(boot:GetDescendants()) do
			if d:IsA("TextLabel") then
				UI.tween(d, 0.2, { TextTransparency = 1 })
			elseif d:IsA("Frame") then
				UI.tween(d, 0.2, { BackgroundTransparency = 1 })
			end
		end
		task.delay(0.3, function()
			boot:Destroy()
		end)
	end)
end

function Shell.openComputer(appId: string?)
	comp.Visible = true
	-- on phones the laptop covers the screen, the taskbar shows money and date
	hud.Visible = not Shell.phone
	if Shell.laptopBrand then
		Shell.laptopBrand.Text = ((Net.state and Net.state.company) or ""):upper()
	end
	local ls = laptop:FindFirstChildOfClass("UIScale") or new("UIScale", { Parent = laptop })
	ls.Scale = 0.92
	UI.tween(ls, 0.25, { Scale = 1 }, Enum.EasingStyle.Back)
	hint.Visible = false
	bootThen(function()
		if appId then
			Shell.open(appId)
		end
	end)
end
function Shell.closeComputer()
	Shell.closeApp()
	comp.Visible = false
	hud.Visible = true
	if Shell.onClose then
		Shell.onClose()
	end
	-- (hint stays hidden)
end
function Shell.isOpen()
	return comp.Visible
end
function Shell.showHUD(on: boolean)
	hud.Visible = on and not (Shell.phone and comp.Visible)
end

UIS.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.KeyCode == Enum.KeyCode.Tab and hud.Visible then
		if comp.Visible then
			Shell.closeComputer()
		else
			Shell.openComputer()
		end
	elseif input.KeyCode == Enum.KeyCode.Space and hud.Visible and Net.state then
		Net.act("setSpeed", Net.state.speed == 0 and 1 or 0)
	end
end)

-- live updates
local tickIdx = 1
task.spawn(function()
	while true do
		task.wait(5)
		local s = Net.state
		if s and #s.news > 0 then
			tickIdx = tickIdx % math.min(#s.news, 6) + 1
			local n = s.news[tickIdx]
			tickText.Text = Format.date(n.day) .. "   " .. n.text
			tickTag.BackgroundColor3 = n.kind == "you" and T.green or (n.kind == "press" and T.red or T.yellow)
		end
	end
end)

local lastProblemKey = nil
local afterProblems

Net.onState(function(s)
	dateL.Text = Format.date(s.day)
	compL.Text = s.company .. "  |  valued " .. Format.money(s.valuation)
	cashL.Text = Format.money(s.cash)
	cashL.TextColor3 = s.cash >= 0 and T.green or T.red
	local lm = s.lastMonth
	subL.Text = string.format("%s users   |   last month %s", Format.count(s.users), lm and ((lm.revenue - lm.costs >= 0 and "+" or "") .. Format.money(lm.revenue - lm.costs)) or "-")
	-- every new month: a short, clear money report (and a warning before the money runs out)
	local _, curMonth = Format.dateFromDay(s.day)
	if lm and Shell.lastReportDay ~= nil and Shell.lastReportDay ~= curMonth then
		local net = lm.revenue - lm.costs
		local parts = { { "PEOPLE", lm.salaries or 0 }, { "GPUS", lm.compute or 0 }, { "OFFICE", lm.office or 0 }, { "SERVERS", lm.inference or 0 } }
		table.sort(parts, function(a, b)
			return a[2] > b[2]
		end)
		local text = string.format("LAST MONTH: earned %s, spent %s. Biggest cost: %s", Format.money(lm.revenue), Format.money(lm.costs), parts[1][1])
		Shell.toast(text, net >= 0 and "good" or "warn")
		if net < 0 and s.cash > 0 then
			local months = math.floor(s.cash / -net)
			if months <= 3 then
				task.delay(1.5, function()
					Shell.toast(string.format("Careful: at this rate your money runs out in %d %s. Launch a better AI, let some people go, or take a loan in BANK.", months, months == 1 and "month" or "months"), "error")
				end)
			end
		end
	end
	Shell.lastReportDay = curMonth
	for sp, b in pairs(speedBtns) do
		local on = s.speed == sp
		b.BackgroundColor3 = on and T.accent or Color3.fromRGB(150, 170, 205)
		if sp == 8 and not on then
			b.BackgroundColor3 = (s.perks and s.perks.speed8) and Color3.fromRGB(150, 170, 205) or Color3.fromRGB(255, 60, 130)
		end
	end
	warn.Text = s.speed >= 4 and "x" .. s.speed .. ": things break a bit more when you are not watching" or (s.speed == 2 and "x2: a bit riskier" or "")
	tbName.Text = s.company .. "   " .. Format.money(s.cash)
	tbClock.Text = Format.date(s.day)
	local pkey = tostring(math.floor((s.misuse or 0))) .. tostring(s.cash >= 0)
	for _, p in ipairs(s.problems or {}) do
		pkey ..= p.kind .. math.floor(p.progress * 25) .. tostring(p.rushed)
	end
	for _, m in ipairs(s.models) do
		pkey ..= m.status == "banned" and "b" or ""
	end
	if pkey == lastProblemKey then
		return afterProblems(s)
	end
	lastProblemKey = pkey
	UI.clear(problemBox)
	local massive = false
	for _, p in ipairs(s.problems or {}) do
		if p.kind == "massive" then
			massive = true
		end
	end
	redAlert:SetAttribute("On", massive)
	if massive then
		local f = new("Frame", { BackgroundColor3 = Color3.fromRGB(120, 0, 20), Size = UDim2.new(1, 0, 0, 44), Parent = problemBox })
		UI.stroke(f, T.line, 3)
		new("TextLabel", { Text = string.format("MISUSE %d%%  (100%% = SHUTDOWN)", math.floor(s.misuse or 0)), FontFace = UI.BOLD, TextSize = 11, TextColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(0, 240, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = f })
		local h = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(260, 15), Size = UDim2.new(1, -272, 0, 14), Parent = f })
		UI.bar(h, (s.misuse or 0) / 100, T.red, 14)
	end
	for _, m in ipairs(s.models) do
		if m.status == "banned" then
			local f = new("Frame", { BackgroundColor3 = Color3.fromRGB(30, 30, 30), Size = UDim2.new(1, 0, 0, 40), Parent = problemBox })
			UI.stroke(f, T.red, 3)
			new("TextLabel", { Text = "GOVERNMENT SHUTDOWN: " .. m.name, FontFace = UI.BOLD, TextSize = 12, TextColor3 = T.red, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -24, 1, 0), Parent = f })
			break
		end
	end
	for _, p in ipairs(s.problems or {}) do
		-- one compact row per problem, above the computer screen
		local f = new("Frame", { BackgroundColor3 = T.red, Size = UDim2.new(1, 0, 0, 44), Parent = problemBox })
		UI.stroke(f, T.line, 3)
		new("TextLabel", { Text = PROBLEM_LABEL[p.kind] or p.kind, FontFace = UI.HEAVY, TextSize = 12, TextColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(0, 240, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = f })
		local h = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(260, 15), Size = UDim2.new(1, -620, 0, 14), Parent = f })
		UI.bar(h, p.progress, T.yellow, 14)
		if not p.rushed and p.rushCost then
			local kind = p.kind
			UI.button(f, "FIX IT NOW  " .. Format.money(p.rushCost), function()
				Net.act("rushFix", kind)
			end, T.yellow, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -136, 0.5, 0), Size = UDim2.fromOffset(210, 34), TextSize = 11 })
		end
		UI.button(f, "INSTANT", function()
			if Shell.openShop then
				Shell.openShop("fixall")
			end
		end, Color3.fromRGB(0, 200, 90), { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.fromOffset(122, 34), TextSize = 11 })
	end
	afterProblems(s)
end)

afterProblems = function(s)
	local boosting
	for _, m in ipairs(s.models) do
		if m.boosting then
			boosting = m
			break
		end
	end
	if s.training or boosting then
		trainMini.Visible = true
		local prog, left
		if s.training then
			trainL.Text = s.training.name:upper()
			prog = s.training.progress
			left = math.ceil(s.training.daysLeft or s.training.days)
		else
			local b = boosting.boosting
			trainL.Text = "STATS: " .. boosting.name:upper()
			local total = math.max(1, b.doneDay - b.startDay)
			prog = math.clamp((s.day - b.startDay) / total, 0, 1)
			left = math.max(0, b.doneDay - s.day)
		end
		tapState.progress = prog
		trainFill.Size = UDim2.fromScale(math.max(prog, 0.06), 1)
		trainPct.Text = math.floor(prog * 100) .. "%"
		trainSub.Text = left .. " DAYS LEFT"
		tapState.taps = s.taps or tapState.taps
		local need = 40
		local finish = tapState.taps >= need
		if finish ~= tapState.finish then
			tapState.finish = finish
			if finish then
				tapBtn.Text = "FINISH NOW  R$ 39"
				tapBtn.TextSize = 15
				ring.BackgroundColor3 = T.yellow
				tapBtn.TextColor3 = Color3.fromRGB(40, 22, 0)
				tapGrad.Color = ColorSequence.new(Color3.fromRGB(255, 240, 130), Color3.fromRGB(220, 130, 0))
			else
				tapBtn.Text = "TAP!"
				tapBtn.TextSize = 26
				ring.BackgroundColor3 = T.green
				tapBtn.TextColor3 = Color3.new(1, 1, 1)
				tapGrad.Color = ColorSequence.new(Color3.fromRGB(120, 255, 160), Color3.fromRGB(0, 160, 80))
			end
		end

	else
		trainMini.Visible = false
		tapState.taps = 0
	end
	if #s.news > 0 and tickText.Text == "" then
		tickText.Text = Format.date(s.news[1].day) .. "   " .. s.news[1].text
	end
	-- badges
	local unread = 0
	for _, m in ipairs(s.mail) do
		if not m.read or (m.choices and not m.resolved) then
			unread += 1
		end
	end
	local ready = 0
	for _, m in ipairs(s.models) do
		if m.status == "ready" then
			ready += 1
		end
	end
	local goalsDone = 0
	for _, g in ipairs(s.goals) do
		if not g.claimed and g.progress >= g.target then
			goalsDone += 1
		end
	end
	local function setBadge(id, n)
		local b = badges[id]
		if b then
			b.Visible = n > 0
			b.Text = tostring(n)
		end
	end
	setBadge("mail", unread)
	setBadge("lab", ready)
	setBadge("goals", goalsDone)
	setBadge("bank", #s.investors)
	-- app refresh
	if openApp and openApp.ctx then
		-- never rebuild the screen while you are typing (it would kick you out of the text box)
		local typing = game:GetService("UserInputService"):GetFocusedTextBox() ~= nil
		if openApp.key and not typing then
			local k = openApp.key(s)
			if k ~= openApp.lastKey then
				openApp.lastKey = k
				-- remember where each list was scrolled so buying something doesn't jump you to the top
				local scrolls = {}
				for _, d in ipairs(openApp.ctx.body:GetDescendants()) do
					if d:IsA("ScrollingFrame") then
						local atBottom = d.CanvasPosition.Y >= d.AbsoluteCanvasSize.Y - d.AbsoluteWindowSize.Y - 12 and d.CanvasPosition.Y > 0
						table.insert(scrolls, atBottom and Vector2.new(d.CanvasPosition.X, 1e6) or d.CanvasPosition)
					end
				end
				openApp.mount(openApp.ctx, s, true)
				if #scrolls > 0 then
					local function restore()
						local i = 0
						for _, d in ipairs(openApp.ctx.body:GetDescendants()) do
							if d:IsA("ScrollingFrame") then
								i += 1
								if scrolls[i] then
									d.CanvasPosition = scrolls[i]
								end
							end
						end
					end
					restore()
					task.defer(restore)
					task.delay(0.05, restore)
				end
				return
			end
		end
		if openApp.refresh then
			openApp.refresh(openApp.ctx, s)
		end
	end
end

return Shell
