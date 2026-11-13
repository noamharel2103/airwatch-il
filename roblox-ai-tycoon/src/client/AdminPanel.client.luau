-- Touch friendly ADMIN PANEL: a small ADMIN button (creator only, everyone in Studio) opens big
-- buttons: pick who gets it (ME, EVERYONE or a player), then tap a gift.
-- The server checks the creator again on every tap (server/AdminPanel.server.luau).
-- F2 still opens the Cmdr console for typed commands.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")

local me = Players.LocalPlayer

local admin = RunService:IsStudio()
if not admin then
	if game.CreatorType == Enum.CreatorType.Group then
		local ok, rank = pcall(me.GetRankInGroup, me, game.CreatorId)
		admin = ok and rank == 255
	else
		admin = me.UserId == game.CreatorId
	end
end
if not admin then
	return
end

local Modules = script.Parent:WaitForChild("ClientModules")
local UI = require(Modules:WaitForChild("UI"))
local Defs = require(RS:WaitForChild("Shared"):WaitForChild("AdminCommands"))
local T = UI.T
local new = UI.new

local RED = Color3.fromRGB(235, 50, 70)

local gui = new("ScreenGui", { Name = "AdminPanelGui", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 900, ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets, Parent = me:WaitForChild("PlayerGui") })

-- ===== floating ADMIN button (bottom left, out of the way of the HUD) =====
local openBtn = new("TextButton", { Text = "ADMIN", FontFace = UI.HEAVY, TextSize = 18, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Center, BackgroundColor3 = RED, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 14, 1, -14), Size = UDim2.fromOffset(104, 52), ZIndex = 10, Parent = gui })
new("UICorner", { CornerRadius = UDim.new(0, 14), Parent = openBtn })
new("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = openBtn })

-- ===== panel =====
local W, H = 960, 640
local overlay = new("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 20, Parent = gui })
local panel = new("Frame", { Active = true, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(W, H), BackgroundColor3 = T.bg, ZIndex = 21, Parent = overlay })
new("UICorner", { CornerRadius = UDim.new(0, 14), Parent = panel })
new("UIStroke", { Color = T.line, Thickness = 4, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = panel })
-- phones: the whole panel shrinks to fit the screen, buttons stay big enough to tap
UI.fit(panel, 12)

local bar = new("Frame", { BackgroundColor3 = RED, Size = UDim2.new(1, 0, 0, 62), ZIndex = 22, Parent = panel })
new("UICorner", { CornerRadius = UDim.new(0, 14), Parent = bar })
new("TextLabel", { Text = "ADMIN PANEL", FontFace = UI.HEAVY, TextSize = 24, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(20, 0), Size = UDim2.new(1, -120, 1, 0), ZIndex = 23, Parent = bar })
local closeBtn = UI.button(bar, "X", nil, Color3.fromRGB(40, 44, 70), { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(64, 48), TextSize = 22, ZIndex = 24 })

-- left: who gets it
local left = new("Frame", { BackgroundColor3 = T.panel, Position = UDim2.fromOffset(14, 74), Size = UDim2.new(0, 260, 1, -150), ZIndex = 22, Parent = panel })
new("UICorner", { CornerRadius = UDim.new(0, 10), Parent = left })
new("TextLabel", { Text = "GIVE TO", FontFace = UI.HEAVY, TextSize = 16, TextColor3 = T.sub, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 34), ZIndex = 23, Parent = left })
local targets = UI.scroll(left, { Position = UDim2.fromOffset(8, 36), Size = UDim2.new(1, -16, 1, -44), ZIndex = 23, ScrollBarThickness = 8 })
UI.list(targets, 8)

-- right: section tabs + big buttons
local right = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(288, 74), Size = UDim2.new(1, -302, 1, -150), ZIndex = 22, Parent = panel })
local tabs = new("ScrollingFrame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 62), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.X, ScrollingDirection = Enum.ScrollingDirection.X, ScrollBarThickness = 6, ZIndex = 23, Parent = right })
UI.list(tabs, 8, true)
local note = new("TextLabel", { Text = "", FontFace = UI.BOLD, TextSize = 14, TextColor3 = T.yellow, Position = UDim2.fromOffset(0, 66), Size = UDim2.new(1, 0, 0, 22), ZIndex = 23, Parent = right })
local grid = new("ScrollingFrame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 92), Size = UDim2.new(1, 0, 1, -92), CanvasSize = UDim2.new(), ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = 8, ScrollBarImageColor3 = T.sub, ZIndex = 23, Parent = right })

-- bottom: what the server said
local status = new("TextLabel", { Text = "Pick who gets it on the left, then tap a gift.", FontFace = UI.BOLD, TextSize = 16, TextColor3 = T.sub, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, BackgroundColor3 = T.panel, Position = UDim2.new(0, 14, 1, -66), Size = UDim2.new(1, -28, 0, 52), ZIndex = 22, Parent = panel })
new("UICorner", { CornerRadius = UDim.new(0, 10), Parent = status })
UI.pad(status, 0, 14)

-- ===== targets =====
local target: any = "me"
local targetRows: { [any]: TextButton } = {}

local function paintTargets()
	for key, row in pairs(targetRows) do
		local on = key == target
		row.BackgroundColor3 = on and Color3.fromRGB(0, 150, 90) or T.panel2
		local st = row:FindFirstChildOfClass("UIStroke")
		if st then
			st.Color = on and Color3.new(1, 1, 1) or T.line
		end
	end
end

local function targetRow(key: any, text: string, userId: number?, icon: string?, order: number)
	local row = new("TextButton", { Text = "", BackgroundColor3 = T.panel2, Size = UDim2.new(1, -6, 0, 70), LayoutOrder = order, ZIndex = 24, Parent = targets })
	new("UICorner", { CornerRadius = UDim.new(0, 10), Parent = row })
	new("UIStroke", { Color = T.line, Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = row })
	if userId then
		local face = new("ImageLabel", { BackgroundColor3 = T.bg, Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(userId) .. "&w=150&h=150", Position = UDim2.fromOffset(8, 7), Size = UDim2.fromOffset(56, 56), ZIndex = 25, Parent = row })
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = face })
	elseif icon then
		local ic = UI.icon(row, icon, T.accent, 52)
		ic.Position = UDim2.fromOffset(10, 9)
		for _, d in ipairs(ic:GetDescendants()) do
			if d:IsA("GuiObject") then
				d.ZIndex = 25
			end
		end
		ic.ZIndex = 25
	end
	new("TextLabel", { Text = text, FontFace = UI.HEAVY, TextSize = 16, TextWrapped = false, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(74, 0), Size = UDim2.new(1, -82, 1, 0), ZIndex = 25, Parent = row })
	row.Activated:Connect(function()
		target = key
		paintTargets()
		if UI.sound then
			UI.sound("Click", 1)
		end
	end)
	targetRows[key] = row
end

local function buildTargets()
	UI.clear(targets)
	table.clear(targetRows)
	targetRow("me", "ME", me.UserId, nil, 1)
	targetRow("all", "EVERYONE (" .. #Players:GetPlayers() .. ")", nil, "team", 2)
	local order = 3
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= me then
			targetRow(p.UserId, string.upper(p.DisplayName), p.UserId, nil, order)
			order += 1
		end
	end
	if type(target) == "number" and not Players:GetPlayerByUserId(target) then
		target = "me"
	end
	paintTargets()
end

-- ===== actions =====
local remote: RemoteFunction? = nil
task.spawn(function()
	remote = RS:WaitForChild("AdminPanel", 60) :: RemoteFunction?
end)

local busy = false
local function run(item, global: boolean)
	if busy then
		return
	end
	if not remote then
		status.Text = "The admin server script is not running yet."
		status.TextColor3 = T.red
		return
	end
	busy = true
	status.Text = "Working on " .. item.label .. "..."
	status.TextColor3 = T.sub
	task.spawn(function()
		local ok, res = pcall(function()
			return (remote :: RemoteFunction):InvokeServer(item.id, if global then nil else target)
		end)
		busy = false
		if not ok or type(res) ~= "table" then
			status.Text = "No answer from the server."
			status.TextColor3 = T.red
			return
		end
		status.Text = tostring(res.msg or "Done")
		status.TextColor3 = res.ok and T.green or T.red
	end)
end

local tabBtns: { TextButton } = {}
local current = 1

local function showSection(i: number)
	current = i
	for j, b in ipairs(tabBtns) do
		b.BackgroundColor3 = j == i and RED or Color3.fromRGB(58, 70, 120)
	end
	local section = Defs.Panel[i]
	note.Text = section.note or ""
	for _, c in ipairs(grid:GetChildren()) do
		if c:IsA("GuiObject") then
			c:Destroy()
		end
	end
	local COLS, GAP, CELL_H = 2, 10, 78
	for n, item in ipairs(section.items) do
		local col = (n - 1) % COLS
		local rowI = (n - 1) // COLS
		local color = item.color or T.accent
		local b = UI.button(grid, "", function()
			run(item, section.global == true)
		end, color, {
			Position = UDim2.new(col / COLS, col == 0 and 0 or GAP / 2, 0, rowI * (CELL_H + GAP)),
			Size = UDim2.new(1 / COLS, -GAP / 2 - 6, 0, CELL_H),
			ZIndex = 24,
		})
		local txt = new("TextLabel", { Text = item.label, FontFace = UI.HEAVY, TextSize = 17, TextColor3 = Color3.new(1, 1, 1), TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(70, 0), Size = UDim2.new(1, -78, 1, -4), ZIndex = 25, Parent = b })
		new("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1.5, Transparency = 0.3, ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual, Parent = txt })
		local ic = UI.icon(b, item.icon or "gift", color, 52)
		ic.AnchorPoint = Vector2.new(0, 0.5)
		ic.Position = UDim2.new(0, 10, 0.5, -2)
		ic.ZIndex = 25
		for _, d in ipairs(ic:GetDescendants()) do
			if d:IsA("GuiObject") then
				d.ZIndex = 25
			end
		end
	end
	local rows = math.ceil(#section.items / COLS)
	grid.CanvasSize = UDim2.fromOffset(0, rows * (CELL_H + GAP) + 10)
	grid.CanvasPosition = Vector2.zero
end

for i, section in ipairs(Defs.Panel) do
	local b = UI.button(tabs, section.title, function()
		showSection(i)
	end, "ghost", { Size = UDim2.fromOffset(math.max(118, #section.title * 13 + 40), 52), TextSize = 16, LayoutOrder = i, ZIndex = 24 })
	tabBtns[i] = b
end

-- ===== open / close =====
local function setOpen(on: boolean)
	overlay.Visible = on
	if on then
		buildTargets()
		showSection(current)
	end
end

openBtn.Activated:Connect(function()
	setOpen(not overlay.Visible)
end)
closeBtn.Activated:Connect(function()
	setOpen(false)
end)

Players.PlayerAdded:Connect(function()
	if overlay.Visible then
		buildTargets()
	end
end)
Players.PlayerRemoving:Connect(function()
	if overlay.Visible then
		task.defer(buildTargets)
	end
end)
