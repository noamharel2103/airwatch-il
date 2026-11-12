--!strict
-- Purchase pop-ups: show the right offer at the right moment (long training, a crisis,
-- low cash, a new model type) plus a timed "limited offer" now and then. Never spammy:
-- at least 75 seconds between pop-ups, and each reason only once in a while.
local RS = game:GetService("ReplicatedStorage")
local ShopData = require(RS:WaitForChild("Shared"):WaitForChild("Shop"))
local Format = require(RS.Shared.Format)
local UI = require(script.Parent.UI)
local Net = require(script.Parent.Net)
local new = UI.new

local Promo = {}
local host: Instance? = nil
local ShopApp: any = nil
local lastShown = os.clock() - 40
local lastReason: { [string]: number } = {}
local open = false

local GOLD = Color3.fromRGB(255, 196, 30)
local INK = Color3.fromRGB(28, 16, 4)

local function show(key: string, headline: string, sub: string, target: number?)
	if open or not host or not ShopApp then
		return
	end
	local item = ShopData.productByKey[key] or ShopData.passByKey[key]
	if not item then
		return
	end
	local isPass = ShopData.passByKey[key] ~= nil
	if isPass and Net.state and Net.state.perks and Net.state.perks[key] then
		return
	end
	open = true
	lastShown = os.clock()
	local overlay = new("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45, Size = UDim2.fromScale(1, 1), ZIndex = 300, Parent = host })
	local card = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(560, 520), BackgroundColor3 = item.color, ZIndex = 301, Parent = overlay })
	new("UICorner", { CornerRadius = UDim.new(0, 6), Parent = card })
	new("UIStroke", { Color = GOLD, Thickness = 6, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = card })
	new("UIGradient", { Rotation = 90, Color = ColorSequence.new(item.color:Lerp(Color3.new(1, 1, 1), 0.15), item.color:Lerp(Color3.new(0, 0, 0), 0.6)), Parent = card })
	-- spinning rays behind the icon
	local rays = new("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 170), Size = UDim2.fromOffset(420, 420), ZIndex = 301, Parent = card })
	for i = 0, 7 do
		local r = new("Frame", { BackgroundColor3 = Color3.fromRGB(255, 230, 120), BackgroundTransparency = 0.7, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(46, 420), Rotation = i * 22.5, ZIndex = 301, Parent = rays })
		new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.1), NumberSequenceKeypoint.new(1, 1) }), Parent = r })
	end
	local banner = new("Frame", { BackgroundColor3 = Color3.fromRGB(255, 40, 70), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, -26), Size = UDim2.fromOffset(420, 56), Rotation = -3, ZIndex = 305, Parent = card })
	new("UIStroke", { Color = INK, Thickness = 4, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = banner })
	ShopApp.fancy(banner, headline, 20, Color3.new(1, 1, 1), Color3.fromRGB(255, 230, 200), { Size = UDim2.fromScale(1, 1), ZIndex = 306 })
	local ic = UI.icon(card, item.icon, item.color, 150)
	ic.AnchorPoint = Vector2.new(0.5, 0.5)
	ic.Position = UDim2.new(0.5, 0, 0, 170)
	ShopApp.fancy(card, item.name, 30, Color3.new(1, 1, 1), Color3.fromRGB(255, 220, 100), { Position = UDim2.fromOffset(20, 262), Size = UDim2.new(1, -40, 0, 40), ZIndex = 305 })
	local body = sub
	if item.cash then
		body = Format.money(ShopData.cashFor(item, Net.state and Net.state.year or 2023)) .. " right now. " .. sub
	end
	new("TextLabel", { Text = body, TextSize = 19, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(30, 308), Size = UDim2.new(1, -60, 0, 70), ZIndex = 305, Parent = card })
	local function close()
		open = false
		UI.tween(card, 0.15, { Size = UDim2.fromOffset(0, 0) })
		task.delay(0.16, function()
			overlay:Destroy()
		end)
	end
	local buy = ShopApp.goldButton(card, (item.id == 0 and "BUY  R$ " .. item.robux .. "  (TEST)") or ("BUY  R$ " .. item.robux), function()
		ShopApp.buy(item, isPass, target)
		close()
	end, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -76), Size = UDim2.new(1, -60, 0, 66), TextSize = 22, ZIndex = 305 })
	local _ = buy
	UI.button(card, "NO THANKS", close, "ghost", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -16), Size = UDim2.fromOffset(240, 44), TextSize = 13, ZIndex = 305 })
	for _, d in ipairs(card:GetDescendants()) do
		if d:IsA("GuiObject") then
			d.ZIndex = math.max(d.ZIndex, 302)
		end
	end
	local sc = new("UIScale", { Scale = 0.3, Parent = card })
	UI.tween(sc, 0.35, { Scale = 1 }, Enum.EasingStyle.Back)
	task.spawn(function()
		while overlay.Parent do
			rays.Rotation += 1.2
			task.wait(1 / 30)
		end
	end)
end

local function ready(reason: string, cooldown: number): boolean
	if os.clock() - lastShown < 75 then
		return false
	end
	if lastReason[reason] and os.clock() - lastReason[reason] < cooldown then
		return false
	end
	lastReason[reason] = os.clock()
	return true
end

local LIMITED = {
	{ "cash2x", "LIMITED OFFER", "Double every dollar, forever. The best deal in the game." },
	{ "train2x", "LIMITED OFFER", "Your models get smart twice as fast. Forever." },
	{ "turbo", "TODAY ONLY", "Train 3x faster for 60 days." },
	{ "cash2", "FLASH DEAL", "Skip the grind." },
	{ "vip", "VIP INVITE", "Become a VIP CEO: +50% users and daily cash." },
	{ "mega", "SUPER DEAL", "+30 to every stat. Leave every rival behind." },
}

function Promo.start(gui: Instance, shopApp)
	host = gui
	ShopApp = shopApp
	local lastTrainingName = nil
	Net.onState(function(s)
		if not s or s.speed == 0 then
			return
		end
		-- a long model training just started
		if s.training and s.training.name ~= lastTrainingName then
			lastTrainingName = s.training.name
			if (s.training.daysLeft or s.training.days or 0) > 25 and ready("train", 180) then
				task.delay(1.5, show, "finish", "TOO SLOW?", string.format("%s needs about %d more days. Finish it right now.", s.training.name, math.ceil(s.training.daysLeft or s.training.days)))
				return
			end
		elseif not s.training then
			lastTrainingName = nil
		end
		-- a crisis
		if #(s.problems or {}) > 0 and ready("crisis", 300) then
			show("fixall", "EMERGENCY!", "Fix it now and nothing breaks for 90 days.")
			return
		end
		-- running out of money
		if s.cash < 0 and ready("cash", 400) then
			show("cash2", "LOW CASH!", "The bank is calling. Fill the vault.")
			return
		end
	end)
	-- a limited offer every few minutes of play
	task.spawn(function()
		local i = math.random(1, #LIMITED)
		while true do
			task.wait(200 + math.random(0, 80))
			local s = Net.state
			if s and s.speed > 0 and ready("limited", 200) then
				i = i % #LIMITED + 1
				local o = LIMITED[i]
				show(o[1], o[2], o[3])
			end
		end
	end)
end

Promo.show = show
return Promo
