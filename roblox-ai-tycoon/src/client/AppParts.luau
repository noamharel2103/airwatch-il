--!strict
-- Parts: real GPUs for the current year. Rent in the cloud or buy for your own server room.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS:WaitForChild("Shared")
local Format = require(Shared.Format)
local Hardware = require(Shared.Hardware)
local Catalog = require(Shared.Catalog)
local UI = require(script.Parent.UI)
local Net = require(script.Parent.Net)
local T = UI.T
local new = UI.new

local App = { id = "parts", name = "GPUS", icon = "parts", color = Color3.fromRGB(240, 150, 60) }
local qty = 10
local mode = "gpus"
local PcParts = require(Shared.PcParts)

local function mountComputer(ctx, s)
	local sc = UI.scroll(ctx.body)
	UI.list(sc, 10)
	UI.pad(sc, 0, 0, 10, 8)
	UI.label(sc, "Every GPU you own needs RAM next to it and cooling for its heat. Buy as many as you need.", 14, T.sub)
	local sup = s.pcSupply or { gb = 16, gbNeed = 16, cool = 0.3, coolNeed = 0.3 }
	local head = UI.card(sc)
	UI.list(head, 6)
	local function meter(label, have, need, unit)
		local ok = have >= need
		UI.label(head, string.format("%s  %s / %s %s needed%s", label, Format.count(math.floor(have)), Format.count(math.ceil(need)), unit, ok and "" or "   NOT ENOUGH"), 15, ok and T.text or T.red, { FontFace = UI.BOLD })
		local b = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 12), Parent = head })
		UI.bar(b, math.min(1, have / math.max(need, 1)), ok and T.green or T.red, 12)
	end
	meter("RAM", sup.gb, sup.gbNeed, "GB")
	meter("COOLING", sup.cool, sup.coolNeed, "kW")
	UI.label(head, "Too little RAM slows training a lot. Too little cooling means overheating and burned GPUs.", 12, T.dim)
	for _, cat in ipairs(PcParts.categories) do
		local cur = PcParts.get(s.pc, cat.id)
		UI.label(sc, cat.name .. "   (now: " .. cur.name .. ")", 18, T.text, { FontFace = UI.HEAVY })
		local grid = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = sc })
		new("UIGridLayout", { CellSize = UDim2.new(1 / 3, -8, 0, 120), CellPadding = UDim2.fromOffset(10, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = grid })
		for i, part in ipairs(PcParts.list[cat.id]) do
			if i > 1 then
				local owned = s.pc and s.pc[cat.id] == part.id
				local soon = s.year < part.year
				local c = new("Frame", { BackgroundColor3 = owned and Color3.fromRGB(40, 90, 70) or T.panel2, LayoutOrder = i, Parent = grid })
				UI.stroke(c, T.line, 3)
				UI.pad(c, 10, 12)
				new("TextLabel", { Text = part.name, FontFace = UI.HEAVY, TextSize = 13, TextColor3 = T.text, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), Parent = c })
				local effect = part.speed and string.format("+%d%% training speed", math.floor((part.speed - 1) * 100 + 0.5))
					or part.heat and string.format("%d%% less heat", math.floor((1 - part.heat) * 100 + 0.5))
					or part.kw and string.format("+%d kW power", part.kw)
					or part.hype and string.format("+%d hype", part.hype) or ""
				new("TextLabel", { Text = effect, TextSize = 13, TextColor3 = T.green, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 20), Size = UDim2.new(1, 0, 0, 16), Parent = c })
				new("TextLabel", { Text = part.blurb, TextSize = 12, TextColor3 = T.dim, TextWrapped = true, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 38), Size = UDim2.new(1, 0, 0, 30), TextYAlignment = Enum.TextYAlignment.Top, Parent = c })
				local multi = cat.id == "ram" or cat.id == "cooling" or cat.id == "psu" or cat.id == "storage"
				if multi then
					local have = PcParts.count(s.pcStock, cat.id, part.id)
					c.BackgroundColor3 = have > 0 and Color3.fromRGB(40, 90, 70) or T.panel2
					local row = new("Frame", { BackgroundTransparency = 1, Position = UDim2.new(0, 0, 1, -32), Size = UDim2.new(1, 0, 0, 32), Parent = c })
					UI.list(row, 6, true)
					if soon then
						UI.button(row, "COMES " .. part.year, nil, "ghost", { Size = UDim2.new(1, 0, 1, 0) })
					else
						for _, q in ipairs({ 1, 10, 100 }) do
							UI.button(row, (q == 1 and ("x" .. have .. "  +1 ") or ("+" .. q .. " ")) .. Format.money(part.price * q), function()
								Net.act("buyPcPart", cat.id, part.id, q)
							end, s.cash >= part.price * q and "success" or "ghost", { Size = UDim2.new(q == 1 and 0.4 or 0.3, -4, 1, 0), TextSize = 9 })
						end
					end
				else
					local label = owned and "INSTALLED" or (soon and ("COMES " .. part.year) or ("Buy " .. Format.money(part.price)))
					UI.button(c, label, function()
						if not owned and not soon then
							Net.act("buyPcPart", cat.id, part.id)
						end
					end, (owned or soon or s.cash < part.price) and "ghost" or "success", { Position = UDim2.new(0, 0, 1, -32), Size = UDim2.new(1, 0, 0, 32) })
				end
			end
		end
	end
end

-- Simple store page: one status line, amount in the title bar, a clean list of GPUs (best first),
-- one "more space" row, and the Robux GPU packs at the bottom.
local showAll = false
function App.mount(ctx, s)
	if not s then
		return
	end
	UI.clear(ctx.tabs)
	UI.clear(ctx.body)
	for _, q in ipairs({ 1, 10, 100, 1000 }) do
		UI.button(ctx.tabs, "x" .. Format.count(q), function()
			qty = q
			App.mount(ctx, Net.state)
		end, qty == q and T.yellow or "ghost", { Size = UDim2.fromOffset(96, 36), TextSize = 13 })
	end
	local sc = UI.scroll(ctx.body)
	UI.list(sc, 10)
	UI.pad(sc, 0, 0, 10, 8)

	-- one status line
	local sup = s.pcSupply or { gb = 16, gbNeed = 16, cool = 0.6, coolNeed = 0.5 }
	local okSupply = sup.gb >= sup.gbNeed and sup.cool >= sup.coolNeed
	local bar = new("Frame", { BackgroundColor3 = T.panel2, Size = UDim2.new(1, -8, 0, 56), Parent = sc })
	UI.corner(bar, 2)
	UI.stroke(bar, T.line, 3)
	new("TextLabel", { Text = string.format("POWER  %s H1      SPACE  %s / %s", Format.count(math.floor(s.clusterPower)), Format.count(s.gpuUsed or 0), Format.count(s.gpuSlots or 4)), FontFace = UI.BOLD, TextSize = 14, Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, -300, 1, 0), Parent = bar })
	if okSupply then
		new("TextLabel", { Text = "RAM + COOLING OK", FontFace = UI.BOLD, TextSize = 12, TextColor3 = T.green, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 0), Size = UDim2.fromOffset(260, 56), Parent = bar })
	else
		UI.button(bar, "FIX RAM + COOLING", function()
			Net.act("autoSupply")
		end, T.red, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(260, 42), TextSize = 12 })
	end

	-- GPUs, best first
	local list = {}
	for _, hw in ipairs(Hardware.list) do
		if hw.id ~= "laptop" and Hardware.available(hw, s.day) then
			table.insert(list, hw)
		end
	end
	table.sort(list, function(a, b)
		return a.power > b.power
	end)
	for i, hw in ipairs(list) do
		if i > 3 and not showAll then
			break
		end
		local best = i == 1
		local c = new("Frame", { BackgroundColor3 = best and Color3.fromRGB(36, 64, 130) or T.panel2, Size = UDim2.new(1, -8, 0, 96), Parent = sc })
		UI.corner(c, 2)
		UI.stroke(c, best and T.yellow or T.line, 3)
		local ic = UI.icon(c, "gpu", T.orange, 72)
		ic.Position = UDim2.fromOffset(12, 12)
		new("TextLabel", { Text = hw.name .. (best and "   BEST" or ""), FontFace = UI.HEAVY, TextSize = 16, Position = UDim2.fromOffset(98, 16), Size = UDim2.new(1, -520, 0, 24), Parent = c })
		local own = (s.gpus.owned[hw.id] or 0) + (s.gpus.rented[hw.id] or 0)
		new("TextLabel", { Text = string.format("= %g H1 chips      you have %s", hw.power, Format.count(own)), TextSize = 15, TextColor3 = T.sub, Position = UDim2.fromOffset(98, 50), Size = UDim2.new(1, -520, 0, 22), Parent = c })
		local price = Hardware.buyPrice(hw, s.year) * qty
		local id = hw.id
		UI.button(c, "BUY " .. Format.count(qty) .. "  " .. Format.money(price), function()
			Net.act("buy", id, qty)
		end, s.cash >= price and T.green or "ghost", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -168, 0.5, 0), Size = UDim2.fromOffset(240, 60), TextSize = 13 })
		UI.button(c, "RENT", function()
			Net.act("rent", id, qty)
		end, T.accent, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(144, 60), TextSize = 13 })
	end
	if #list > 3 then
		UI.button(sc, showAll and "SHOW LESS" or ("SHOW ALL " .. #list .. " GPUS"), function()
			showAll = not showAll
			App.mount(ctx, Net.state)
		end, "ghost", { Size = UDim2.new(1, -8, 0, 40), TextSize = 12 })
	end

	-- more space (only the next place that makes sense)
	local nextPlace
	for _, st in ipairs(Catalog.storage) do
		if not nextPlace or (s.cash >= st.cost and st.slots > nextPlace.slots) then
			nextPlace = st
		end
	end
	if nextPlace then
		local c = new("Frame", { BackgroundColor3 = Color3.fromRGB(26, 84, 66), Size = UDim2.new(1, -8, 0, 84), Parent = sc })
		UI.corner(c, 2)
		UI.stroke(c, T.line, 3)
		local ic = UI.icon(c, "company", T.teal, 60)
		ic.Position = UDim2.fromOffset(12, 12)
		new("TextLabel", { Text = "MORE SPACE:  " .. nextPlace.name:upper(), FontFace = UI.HEAVY, TextSize = 14, Position = UDim2.fromOffset(86, 14), Size = UDim2.new(1, -380, 0, 22), Parent = c })
		new("TextLabel", { Text = string.format("+%s GPUs   |   %s a month", Format.count(nextPlace.slots), Format.money(nextPlace.rent)), TextSize = 15, TextColor3 = T.sub, Position = UDim2.fromOffset(86, 44), Size = UDim2.new(1, -380, 0, 22), Parent = c })
		local sid = nextPlace.id
		UI.button(c, "BUY  " .. Format.money(nextPlace.cost), function()
			Net.act("buyStorage", sid)
		end, s.cash >= nextPlace.cost and T.green or "ghost", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(280, 56), TextSize = 13 })
	end

	-- Robux GPU packs
	local ShopData = require(Shared.Shop)
	UI.label(sc, "GPU PACKS", 16, T.yellow, { FontFace = UI.HEAVY })
	local packs = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 96), Parent = sc })
	new("UIGridLayout", { CellSize = UDim2.new(1 / 3, -8, 1, 0), CellPadding = UDim2.fromOffset(12, 0), Parent = packs })
	for _, key in ipairs({ "gpuS", "gpuM", "gpuL" }) do
		local item = ShopData.productByKey[key]
		local c = new("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = item.color, Parent = packs })
		UI.corner(c, 2)
		UI.stroke(c, T.line, 3)
		new("UIGradient", { Rotation = 90, Color = ColorSequence.new(item.color:Lerp(Color3.new(1, 1, 1), 0.15), item.color:Lerp(Color3.new(0, 0, 0), 0.45)), Parent = c })
		local ic = UI.icon(c, "gpu", item.color, 64)
		ic.Position = UDim2.fromOffset(12, 16)
		new("TextLabel", { Text = item.name, FontFace = UI.HEAVY, TextSize = 13, Position = UDim2.fromOffset(86, 18), Size = UDim2.new(1, -96, 0, 20), Parent = c })
		new("TextLabel", { Text = "R$ " .. item.robux, FontFace = UI.HEAVY, TextSize = 18, TextColor3 = Color3.fromRGB(180, 255, 200), Position = UDim2.fromOffset(86, 50), Size = UDim2.new(1, -96, 0, 26), Parent = c })
		c.MouseButton1Click:Connect(function()
			if App.buyProduct then
				App.buyProduct(key)
			end
		end)
	end
end

function App.key(s)
	local k = tostring(showAll) .. qty .. tostring(s.year) .. math.floor(s.clusterPower * 10) .. math.floor(math.log10(math.max(s.cash, 1)) * 3) .. (s.gpuSlots or 0) .. (s.gpuUsed or 0)
	local sup = s.pcSupply
	if sup then
		k ..= tostring(sup.gb >= sup.gbNeed and sup.cool >= sup.coolNeed)
	end
	for id, n in pairs(s.gpus.owned) do
		k ..= id .. n
	end
	for id, n in pairs(s.gpus.rented) do
		k ..= id .. n
	end
	return k
end

return App
