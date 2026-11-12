--!strict
-- SHOP: one big gold page. Instant boosts, cash, and forever passes. The server decides what you get.
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Shared = RS:WaitForChild("Shared")
local Format = require(Shared.Format)
local ShopData = require(Shared.Shop)
local UI = require(script.Parent.UI)
local Net = require(script.Parent.Net)
local new = UI.new

local App = { id = "shop", name = "SHOP", icon = "shop", color = Color3.fromRGB(255, 190, 0) }
local focusKey: string? = nil
App.targetModel = nil :: number?

local GOLD = Color3.fromRGB(255, 196, 30)
local GOLD_DARK = Color3.fromRGB(196, 120, 0)
local INK = Color3.fromRGB(28, 16, 4)

-- big outlined text with a vertical colour gradient
local function fancy(parent, text: string, size: number, top: Color3, bottom: Color3, props: { [string]: any }?)
	local t = new("TextLabel", { Text = text, FontFace = UI.HEAVY, TextSize = size, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Center, TextWrapped = true, Parent = parent })
	for k, v in pairs(props or {}) do
		(t :: any)[k] = v
	end
	new("UIStroke", { Color = INK, Thickness = math.max(2, size / 7), ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual, Parent = t })
	new("UIGradient", { Rotation = 90, Color = ColorSequence.new(top, bottom), Parent = t })
	return t
end
App.fancy = fancy

local function shine(btn: GuiObject)
	local s = new("Frame", { BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.55, Size = UDim2.new(0, 26, 1.6, 0), Position = UDim2.new(-0.3, 0, -0.3, 0), Rotation = 20, ZIndex = btn.ZIndex + 1, Parent = btn })
	btn.ClipsDescendants = true
	task.spawn(function()
		while btn.Parent do
			s.Position = UDim2.new(-0.3, 0, -0.3, 0)
			UI.tween(s, 0.7, { Position = UDim2.new(1.2, 0, -0.3, 0) }, Enum.EasingStyle.Sine)
			task.wait(2.2 + math.random())
		end
	end)
end
App.shine = shine

local function priceText(robux: number, id: number): string
	if id == 0 then
		return RunService:IsStudio() and ("R$ " .. robux .. "  TEST") or "SOON"
	end
	return "R$ " .. robux
end

function App.buy(item, isPass: boolean, target: number?)
	local res = Net.shop(isPass and "pass" or "product", item.key, target)
	if res and res.ok and res.test then
		Net.toast(item.name .. " (Studio test, free)", "good")
	end
	return res
end

-- gold buy button (also used by the pop-ups)
function App.goldButton(parent, text: string, onClick: () -> (), props: { [string]: any }?)
	local b = UI.button(parent, text, onClick, GOLD, props)
	b.TextColor3 = INK
	new("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(255, 236, 120), GOLD_DARK), Parent = b })
	shine(b)
	return b
end

local function card(parent, item, s, isPass: boolean, order: number)
	local owned = isPass and s.perks and s.perks[item.key]
	local c = new("Frame", { BackgroundColor3 = item.color, LayoutOrder = order, Parent = parent })
	new("UICorner", { CornerRadius = UDim.new(0, 4), Parent = c })
	new("UIStroke", { Color = item.key == focusKey and Color3.fromRGB(255, 255, 255) or GOLD, Thickness = item.key == focusKey and 6 or 4, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = c })
	new("UIGradient", { Rotation = 90, Color = ColorSequence.new(item.color:Lerp(Color3.new(1, 1, 1), 0.1), item.color:Lerp(Color3.new(0, 0, 0), 0.55)), Parent = c })
	-- sunburst glow behind the icon
	local glow = new("Frame", { BackgroundColor3 = Color3.fromRGB(255, 240, 160), BackgroundTransparency = 0.6, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 84), Size = UDim2.fromOffset(150, 150), Parent = c })
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = glow })
	new("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }), Parent = glow })
	local tile = UI.icon(c, item.icon, item.color, 112)
	tile.AnchorPoint = Vector2.new(0.5, 0.5)
	tile.Position = UDim2.new(0.5, 0, 0, 84)
	fancy(c, item.name, 19, Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 220, 110), { Position = UDim2.fromOffset(8, 150), Size = UDim2.new(1, -16, 0, 28) })
	local desc = item.desc or ""
	if item.cash then
		fancy(c, Format.money(ShopData.cashFor(item, s.year or 2023)), 26, Color3.fromRGB(190, 255, 190), Color3.fromRGB(0, 220, 100), { Position = UDim2.fromOffset(8, 184), Size = UDim2.new(1, -16, 0, 34) })
		desc = "Straight into your bank. Grows every year."
	end
	new("TextLabel", { Text = desc, TextSize = 15, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(16, item.cash and 222 or 186), Size = UDim2.new(1, -32, 0, 70), Parent = c })
	if item.tag and not owned then
		local tag = new("TextLabel", { Text = item.tag, FontFace = UI.HEAVY, TextSize = 11, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(255, 40, 70), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 8, 0, -8), Size = UDim2.fromOffset(#item.tag * 11 + 24, 28), Rotation = 8, Parent = c })
		new("UIStroke", { Color = INK, Thickness = 3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = tag })
	end
	-- hover: card pops up a little
	local sc = new("UIScale", { Parent = c })
	c.MouseEnter:Connect(function()
		UI.tween(sc, 0.15, { Scale = 1.05 }, Enum.EasingStyle.Back)
	end)
	c.MouseLeave:Connect(function()
		UI.tween(sc, 0.15, { Scale = 1 })
	end)
	if owned then
		UI.button(c, "OWNED", function() end, Color3.fromRGB(60, 200, 110), { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -14), Size = UDim2.new(1, -28, 0, 56), TextSize = 18 })
	else
		App.goldButton(c, priceText(item.robux, item.id), function()
			local target = nil
			if item.key == "stats10" or item.key == "mega" then
				target = App.targetModel
			end
			App.buy(item, isPass, target)
		end, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -14), Size = UDim2.new(1, -28, 0, 56), TextSize = 18 })
	end
	return c
end

local function ribbon(parent, text: string, order: number)
	local r = new("Frame", { BackgroundColor3 = GOLD, Size = UDim2.new(1, -8, 0, 54), LayoutOrder = order, Parent = parent })
	new("UIStroke", { Color = INK, Thickness = 4, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = r })
	new("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(255, 232, 110), GOLD_DARK), Parent = r })
	fancy(r, text, 22, Color3.new(1, 1, 1), Color3.fromRGB(255, 240, 200), { Size = UDim2.fromScale(1, 1) })
end

local function grid(parent, order: number)
	local g = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = order, Parent = parent })
	new("UIGridLayout", { CellSize = UDim2.fromOffset(290, 360), CellPadding = UDim2.fromOffset(18, 18), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Parent = g })
	new("UIPadding", { PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), Parent = g })
	return g
end

function App.mount(ctx, s)
	App.ctx = ctx
	if not s then
		return
	end
	UI.clear(ctx.tabs)
	UI.clear(ctx.body)
	-- bright gold backdrop: warm gradient, moving diagonal stripes, twinkling sparkles
	local bg = new("Frame", { BackgroundColor3 = Color3.fromRGB(255, 170, 20), ClipsDescendants = true, Size = UDim2.fromScale(1, 1), Parent = ctx.body })
	new("UIGradient", { Rotation = 90, Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 214, 70)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 150, 20)), ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 90, 0)) }), Parent = bg })
	new("UIStroke", { Color = INK, Thickness = 4, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = bg })
	local stripes = new("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(2, 0, 3, 0), Rotation = 35, Parent = bg })
	for i = 0, 40 do
		new("Frame", { BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.86, Position = UDim2.new(i / 40, 0, 0, 0), Size = UDim2.new(1 / 80, 0, 1, 0), Parent = stripes })
	end
	local sparkles = {}
	for _ = 1, 22 do
		local sz = math.random(6, 14)
		local sp = new("Frame", { BackgroundColor3 = Color3.new(1, 1, 1), Position = UDim2.fromScale(math.random(), math.random()), Size = UDim2.fromOffset(sz, sz), Rotation = 45, Parent = bg })
		table.insert(sparkles, sp)
	end
	task.spawn(function()
		local t0 = os.clock()
		while bg.Parent do
			local t = os.clock() - t0
			stripes.Position = UDim2.new(0.5, (t * 30) % 60, 0.5, 0)
			for i, sp in ipairs(sparkles) do
				sp.BackgroundTransparency = 0.2 + 0.8 * math.abs(math.sin(t * 1.3 + i))
			end
			task.wait(1 / 30)
		end
	end)
	local sc = UI.scroll(bg)
	sc.ScrollBarImageColor3 = GOLD
	sc.ScrollBarThickness = 10
	UI.pad(sc, 14)
	UI.list(sc, 14, false, Enum.HorizontalAlignment.Center)
	-- header: spinning sun rays, floating coins, giant gold title
	local head = new("Frame", { BackgroundTransparency = 1, ClipsDescendants = true, Size = UDim2.new(1, 0, 0, 130), LayoutOrder = 1, Parent = sc })
	local rays = new("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(900, 900), Parent = head })
	for i = 0, 11 do
		local r = new("Frame", { BackgroundColor3 = Color3.fromRGB(255, 210, 60), BackgroundTransparency = 0.78, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(60, 900), Rotation = i * 15, Parent = rays })
		new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) }), Parent = r })
	end
	local coins = {}
	for i = 1, 14 do
		local c = new("Frame", { BackgroundColor3 = GOLD, Position = UDim2.new(math.random(), 0, math.random(), 0), Size = UDim2.fromOffset(14, 14), Parent = head })
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = c })
		new("UIStroke", { Color = GOLD_DARK, Thickness = 2, Parent = c })
		table.insert(coins, { f = c, sp = 0.05 + math.random() * 0.08, x = math.random() })
	end
	local title = fancy(head, "GOLD SHOP", 56, Color3.fromRGB(255, 250, 190), Color3.fromRGB(255, 140, 0), { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, 0, 0, 70) })
	task.spawn(function()
		local t0 = os.clock()
		while head.Parent do
			local t = os.clock() - t0
			rays.Rotation = t * 12
			title.Rotation = math.sin(t * 2) * 2
			title.TextSize = 56 + math.sin(t * 3) * 3
			for _, cn in ipairs(coins) do
				local y = (t * cn.sp + cn.x) % 1.2 - 0.1
				cn.f.Position = UDim2.new(cn.x, math.sin(t * 2 + cn.x * 9) * 12, 1 - y, 0)
			end
			task.wait(1 / 30)
		end
	end)
	new("TextLabel", { Text = "EVERYTHING HERE IS INSTANT. MOST POPULAR THIS WEEK: INSTANT FINISH AND 2X CASH", FontFace = UI.BOLD, TextSize = 12, TextColor3 = Color3.fromRGB(90, 40, 0), TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 2, Parent = sc })
	-- featured deal: the best pass, big and loud
	local feat = ShopData.passByKey.cash2x
	if feat and not (s.perks and s.perks.cash2x) then
		local fb = new("Frame", { BackgroundColor3 = Color3.fromRGB(0, 200, 100), Size = UDim2.new(1, -8, 0, 210), LayoutOrder = 2, Parent = sc })
		new("UICorner", { CornerRadius = UDim.new(0, 6), Parent = fb })
		new("UIStroke", { Color = INK, Thickness = 5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = fb })
		new("UIGradient", { Rotation = 20, Color = ColorSequence.new(Color3.fromRGB(60, 255, 140), Color3.fromRGB(0, 140, 70)), Parent = fb })
		local big = UI.icon(fb, "cash", feat.color, 170)
		big.AnchorPoint = Vector2.new(0, 0.5)
		big.Position = UDim2.new(0, 30, 0.5, 0)
		big.Rotation = -8
		fancy(fb, "BEST DEAL: 2X CASH FOREVER", 30, Color3.new(1, 1, 1), Color3.fromRGB(255, 240, 150), { TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(230, 30), Size = UDim2.new(1, -520, 0, 80) })
		new("TextLabel", { Text = "Every dollar your company earns is doubled, in every company you ever make.", TextSize = 18, TextColor3 = Color3.new(1, 1, 1), Position = UDim2.fromOffset(230, 116), Size = UDim2.new(1, -520, 0, 60), Parent = fb })
		App.goldButton(fb, priceText(feat.robux, feat.id), function()
			App.buy(feat, true, nil)
		end, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -30, 0.5, 0), Size = UDim2.fromOffset(250, 90), TextSize = 22 })
		task.spawn(function()
			local t0 = os.clock()
			while fb.Parent do
				big.Rotation = -8 + math.sin((os.clock() - t0) * 2) * 6
				task.wait(1 / 30)
			end
		end)
	end
	-- 1) instant boosts, 2) cash, 3) passes: all on one page
	ribbon(sc, "INSTANT POWER", 3)
	local g1 = grid(sc, 4)
	local n = 0
	for _, p in ipairs(ShopData.products) do
		if not p.cash then
			n += 1
			card(g1, p, s, false, n)
		end
	end
	ribbon(sc, "PILES OF CASH", 5)
	local g2 = grid(sc, 6)
	n = 0
	for _, p in ipairs(ShopData.products) do
		if p.cash then
			n += 1
			card(g2, p, s, false, n)
		end
	end
	ribbon(sc, "FOREVER PASSES  (EVERY COMPANY)", 7)
	local g3 = grid(sc, 8)
	for i, p in ipairs(ShopData.passes) do
		card(g3, p, s, true, i)
	end
	-- jump to the focused item
	if focusKey then
		task.defer(function()
			for _, g in ipairs({ g1, g2, g3 }) do
				for _, c in ipairs(g:GetChildren()) do
					local st = c:IsA("Frame") and c:FindFirstChildOfClass("UIStroke")
					if st and st.Thickness == 6 then
						sc.CanvasPosition = Vector2.new(0, math.max(0, c.AbsolutePosition.Y - sc.AbsolutePosition.Y + sc.CanvasPosition.Y - 60))
					end
				end
			end
		end)
	end
end

function App.key(s)
	local k = (focusKey or "") .. tostring(s.year)
	for key, v in pairs(s.perks or {}) do
		if v then
			k ..= key
		end
	end
	return k
end

function App.focus(key: string?)
	focusKey = key
end

return App
