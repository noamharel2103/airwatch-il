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
local function rescale()
	local cam = workspace.CurrentCamera
	local v = cam and cam.ViewportSize or Vector2.new(1600, 900)
	scale.Scale = math.clamp(math.min(v.X / 1450, v.Y / 820), 0.6, 1.5)
end
rescale()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(rescale)

-- ===== HUD =====
local hud = new("Frame", { Name = "HUD", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 60, Parent = gui })
Shell.hud = hud
local topRight = new("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 14), Size = UDim2.fromOffset(330, 96), BackgroundColor3 = T.bg, BackgroundTransparency = 0.12, Parent = hud })
UI.skin(topRight)
local dateL = new("TextLabel", { Text = "Jan 1, 2023", FontFace = UI.HEAVY, TextSize = 26, Position = UDim2.fromOffset(18, 10), Size = UDim2.new(1, -36, 0, 30), TextXAlignment = Enum.TextXAlignment.Right, Parent = topRight })
local speedRow = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 50), Size = UDim2.new(1, -28, 0, 34), Parent = topRight })
UI.list(speedRow, 6, true, Enum.HorizontalAlignment.Right)
local speedBtns = {}
for _, sp in ipairs({ 0, 1, 2, 4 }) do
	local label = sp == 0 and "II" or ("x" .. sp)
	local b = UI.button(speedRow, label, function()
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

-- training mini status (bottom left)
local trainMini = new("Frame", { Position = UDim2.new(0, 16, 1, -86), Size = UDim2.fromOffset(300, 70), BackgroundColor3 = T.bg, BackgroundTransparency = 0.12, Visible = false, Parent = hud })
UI.corner(trainMini, 14)
local trainL = new("TextLabel", { Text = "", FontFace = UI.BOLD, TextSize = 14, Position = UDim2.fromOffset(14, 10), Size = UDim2.new(1, -28, 0, 18), Parent = trainMini })
local trainBarHolder = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 36), Size = UDim2.new(1, -28, 0, 10), Parent = trainMini })
local _, trainFill = UI.bar(trainBarHolder, 0, T.purple, 10)
local trainSub = new("TextLabel", { Text = "", TextSize = 12, TextColor3 = T.sub, Position = UDim2.fromOffset(14, 50), Size = UDim2.new(1, -28, 0, 14), Parent = trainMini })

-- news ticker (bottom)
local ticker = new("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 14), Size = UDim2.new(1, -700, 0, 40), BackgroundColor3 = T.bg, BackgroundTransparency = 0.15, ClipsDescendants = true, Parent = hud })
UI.corner(ticker, 12)
local tickTag = new("TextLabel", { Text = "NEWS", FontFace = UI.HEAVY, TextSize = 12, TextColor3 = T.bg, BackgroundTransparency = 0, BackgroundColor3 = T.yellow, Size = UDim2.fromOffset(56, 34), TextXAlignment = Enum.TextXAlignment.Center, Parent = ticker })
local tickText = new("TextLabel", { Text = "", TextSize = 14, Position = UDim2.fromOffset(66, 0), Size = UDim2.new(1, -76, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, TextWrapped = false, Parent = ticker })

local hint = new("TextLabel", { Visible = false, Text = "Click the laptop to open the computer", TextSize = 14, TextColor3 = T.sub, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -56), Size = UDim2.fromOffset(500, 18), TextXAlignment = Enum.TextXAlignment.Center, Parent = hud })

-- toasts
local toasts = new("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 130), Size = UDim2.fromOffset(360, 400), BackgroundTransparency = 1, Parent = gui, ZIndex = 50 })
UI.list(toasts, 8)
function Shell.toast(text: string, kind: string?)
	local color = kind == "error" and T.red or (kind == "good" and T.green or (kind == "warn" and T.yellow or T.accent))
	local f = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = T.bg, BackgroundTransparency = 0.05, ZIndex = 50, Parent = toasts })
	UI.corner(f, 12)
	UI.stroke(f, color, 1.5)
	UI.pad(f, 10, 14)
	new("TextLabel", { Text = text, TextSize = 14, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 51, Parent = f })
	task.delay(4.5, function()
		UI.tween(f, 0.3, { BackgroundTransparency = 1 })
		task.wait(0.3)
		f:Destroy()
	end)
end
Net.setToast(Shell.toast)

-- ===== Computer =====
local comp = new("Frame", { Name = "Computer", BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 10, Parent = gui })
Shell.computer = comp
local screen = new("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -24), Size = UDim2.new(0.84, 0, 1, -150), BackgroundColor3 = Color3.fromRGB(20, 28, 52), ZIndex = 10, Parent = comp })
UI.corner(screen, 22)
UI.grad(screen, Color3.fromRGB(120, 190, 250), Color3.fromRGB(80, 150, 235), 90)
-- blocky city skyline wallpaper

local desk = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(40, 40), Size = UDim2.new(0, 400, 1, -120), ZIndex = 11, Parent = screen })
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
	new("TextLabel", { Text = app.name, FontFace = UI.BOLD, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 82), Size = UDim2.new(1, 0, 0, 20), ZIndex = 12, Parent = btn })
	local badge = new("TextLabel", { Text = "", FontFace = UI.BOLD, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 0, BackgroundColor3 = T.red, Position = UDim2.fromOffset(74, -2), Size = UDim2.fromOffset(22, 22), Visible = false, ZIndex = 14, Parent = btn })
	UI.corner(badge, 11)
	badges[app.id] = badge
	btn.MouseButton1Click:Connect(function()
		Shell.open(app.id)
	end)
end

local function buildWindow(app)
	if appWindow then
		appWindow:Destroy()
	end
	local w = new("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 16), Size = UDim2.new(1, -32, 1, -96), BackgroundColor3 = T.bg, BackgroundTransparency = 0, ZIndex = 20, Parent = winLayer })
	UI.skin(w, T.bg)
	local bar = new("Frame", { Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = T.accent, ZIndex = 21, Parent = w })
	UI.grad(bar, Color3.fromRGB(60, 200, 255), Color3.fromRGB(0, 120, 210), 0)
	UI.corner(bar, 3)
	local ic = UI.icon(bar, app.icon, app.color, 32)
	ic.Position = UDim2.fromOffset(16, 12)
	new("TextLabel", { Text = app.name, FontFace = UI.HEAVY, TextSize = 20, Position = UDim2.fromOffset(60, 0), Size = UDim2.new(0, 300, 1, 0), ZIndex = 21, Parent = bar })
	local tabs = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(240, 10), Size = UDim2.new(1, -330, 0, 36), ZIndex = 21, Parent = bar })
	UI.list(tabs, 6, true)
	local x = UI.button(bar, "X", function()
		Shell.closeApp()
	end, "ghost", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 10), Size = UDim2.fromOffset(40, 36), ZIndex = 22 })
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
	if appWindow then
		appWindow:Destroy()
		appWindow = nil
	end
end

function Shell.openComputer(appId: string?)
	comp.Visible = true
	hud.Visible = true
	screen.Size = UDim2.new(0.8, 0, 1, -190)
	UI.tween(screen, 0.2, { Size = UDim2.new(0.84, 0, 1, -150) })
	hint.Visible = false
	if appId then
		Shell.open(appId)
	end
end
function Shell.closeComputer()
	Shell.closeApp()
	comp.Visible = false
	-- (hint stays hidden)
end
function Shell.isOpen()
	return comp.Visible
end
function Shell.showHUD(on: boolean)
	hud.Visible = on
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

Net.onState(function(s)
	dateL.Text = Format.date(s.day)
	compL.Text = s.company .. "  |  valued " .. Format.money(s.valuation)
	cashL.Text = Format.money(s.cash)
	cashL.TextColor3 = s.cash >= 0 and T.green or T.red
	local lm = s.lastMonth
	subL.Text = string.format("%s users   |   last month %s", Format.count(s.users), lm and ((lm.revenue - lm.costs >= 0 and "+" or "") .. Format.money(lm.revenue - lm.costs)) or "-")
	for sp, b in pairs(speedBtns) do
		local on = s.speed == sp
		b.BackgroundColor3 = on and T.accent or Color3.fromRGB(150, 170, 205)
	end
	warn.Text = s.speed == 4 and "x4: things break faster when you are not watching" or (s.speed == 2 and "x2: a bit riskier" or "")
	tbName.Text = s.company .. "   " .. Format.money(s.cash)
	tbClock.Text = Format.date(s.day)
	if s.training then
		trainMini.Visible = true
		trainL.Text = "Training " .. s.training.name
		trainFill.Size = UDim2.fromScale(s.training.progress, 1)
		trainSub.Text = string.format("%d%%   about %d days left", math.floor(s.training.progress * 100), math.ceil(s.training.daysLeft or s.training.days))
	else
		trainMini.Visible = false
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
		if openApp.key then
			local k = openApp.key(s)
			if k ~= openApp.lastKey then
				openApp.lastKey = k
				openApp.mount(openApp.ctx, s, true)
				return
			end
		end
		if openApp.refresh then
			openApp.refresh(openApp.ctx, s)
		end
	end
end)

return Shell
