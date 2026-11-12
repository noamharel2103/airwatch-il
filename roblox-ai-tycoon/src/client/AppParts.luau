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

-- ONE simple page: three meters, the best GPU right now, more space, and one fix-it button.
local showAll = false
function App.mount(ctx, s)
	if not s then
		return
	end
	UI.clear(ctx.tabs)
	UI.clear(ctx.body)
	local sc = UI.scroll(ctx.body)
	UI.list(sc, 12)
	UI.pad(sc, 0, 0, 10, 8)
	-- meters
	local meters = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 110), Parent = sc })
	new("UIGridLayout", { CellSize = UDim2.new(1 / 3, -8, 1, 0), CellPadding = UDim2.fromOffset(12, 0), Parent = meters })
	local function meter(title, value, frac, color)
		local c = new("Frame", { BackgroundColor3 = color, Parent = meters })
		UI.corner(c, 2)
		UI.stroke(c, T.line, 3)
		new("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(150, 150, 150)), Parent = c })
		new("TextLabel", { Text = title, FontFace = UI.HEAVY, TextSize = 12, Position = UDim2.fromOffset(14, 10), Size = UDim2.new(1, -28, 0, 18), Parent = c })
		new("TextLabel", { Text = value, FontFace = UI.HEAVY, TextSize = 22, Position = UDim2.fromOffset(14, 34), Size = UDim2.new(1, -28, 0, 30), Parent = c })
		local h = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 76), Size = UDim2.new(1, -28, 0, 14), Parent = c })
		UI.bar(h, math.clamp(frac, 0, 1), Color3.new(1, 1, 1), 14)
	end
	meter("COMPUTE POWER", string.format("%s H100", Format.count(math.floor(s.clusterPower))), s.clusterPower / math.max(s.gpuCap, 1), T.orange)
	meter("SPACE FOR GPUS", Format.count(s.gpuUsed or 0) .. " / " .. Format.count(s.gpuSlots or 4), (s.gpuUsed or 0) / math.max(s.gpuSlots or 4, 1), T.accent)
	local sup = s.pcSupply or { gb = 16, gbNeed = 16, cool = 0.3, coolNeed = 0.3 }
	local okSupply = sup.gb >= sup.gbNeed and sup.cool >= sup.coolNeed
	meter("RAM + COOLING", okSupply and "ALL GOOD" or "NOT ENOUGH", okSupply and 1 or math.min(sup.gb / math.max(sup.gbNeed, 1), sup.cool / math.max(sup.coolNeed, 0.1)), okSupply and T.green or T.red)
	if not okSupply then
		UI.button(sc, "FIX RAM AND COOLING AUTOMATICALLY", function()
			Net.act("autoSupply")
		end, T.red, { Size = UDim2.new(1, -8, 0, 56), TextSize = 15 })
	end

	-- the best GPU you can get right now
	local best
	for _, hw in ipairs(Hardware.list) do
		if hw.id ~= "laptop" and Hardware.available(hw, s.day) and (not best or hw.power > best.power) then
			best = hw
		end
	end
	local function gpuCard(hw, big: boolean)
		local c = new("Frame", { BackgroundColor3 = big and Color3.fromRGB(40, 70, 140) or T.panel2, Size = UDim2.new(1, -8, 0, big and 190 or 120), Parent = sc })
		UI.skin(c, big and Color3.fromRGB(40, 70, 140) or T.panel2)
		local ic = UI.icon(c, "gpu", T.orange, big and 130 or 80)
		ic.Position = UDim2.fromOffset(18, big and 30 or 20)
		local x = big and 170 or 116
		if big then
			new("TextLabel", { Text = "BEST GPU THIS YEAR", FontFace = UI.BOLD, TextSize = 11, TextColor3 = T.yellow, Position = UDim2.fromOffset(x, 18), Size = UDim2.new(1, -x - 330, 0, 16), Parent = c })
		end
		new("TextLabel", { Text = hw.name, FontFace = UI.HEAVY, TextSize = big and 24 or 17, Position = UDim2.fromOffset(x, big and 40 or 16), Size = UDim2.new(1, -x - 330, 0, 30), Parent = c })
		new("TextLabel", { Text = string.format("As strong as %g H100s.  %s", hw.power, hw.blurb), TextSize = 15, TextColor3 = T.sub, Position = UDim2.fromOffset(x, big and 76 or 48), Size = UDim2.new(1, -x - 330, 0, 44), TextYAlignment = Enum.TextYAlignment.Top, Parent = c })
		local own = (s.gpus.owned[hw.id] or 0) + (s.gpus.rented[hw.id] or 0)
		new("TextLabel", { Text = "YOU HAVE " .. Format.count(own), FontFace = UI.BOLD, TextSize = 12, TextColor3 = T.green, Position = UDim2.fromOffset(x, big and 140 or 92), Size = UDim2.new(0, 300, 0, 18), Parent = c })
		local price = Hardware.buyPrice(hw, s.year) * qty
		local col = new("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -16, 0.5, 0), Size = UDim2.fromOffset(300, big and 150 or 96), Parent = c })
		UI.list(col, 8)
		local id = hw.id
		UI.button(col, "BUY " .. qty .. "  " .. Format.money(price), function()
			Net.act("buy", id, qty)
		end, s.cash >= price and T.green or "ghost", { Size = UDim2.new(1, 0, 0, big and 70 or 46), TextSize = big and 16 or 13 })
		if big then
			UI.button(col, "RENT " .. qty .. "  (" .. Format.money(Hardware.rentPrice(hw, s.year) * 24 * 30 * qty) .. "/MO)", function()
				Net.act("rent", id, qty)
			end, T.accent, { Size = UDim2.new(1, 0, 0, 46), TextSize = 11 })
		end
	end
	-- how many at once
	local qrow = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 46), Parent = sc })
	UI.list(qrow, 8, true)
	UI.label(qrow, "HOW MANY:", 14, T.text, { FontFace = UI.HEAVY, Size = UDim2.fromOffset(150, 46) })
	for _, q in ipairs({ 1, 10, 100, 1000, 10000 }) do
		UI.button(qrow, "x" .. Format.count(q), function()
			qty = q
			App.mount(ctx, Net.state)
		end, qty == q and T.yellow or "ghost", { Size = UDim2.fromOffset(110, 44), TextSize = 13 })
	end
	if best then
		gpuCard(best, true)
	end

	-- more space: just the next place you can buy
	local nextPlace
	for _, st in ipairs(Catalog.storage) do
		if not nextPlace or (s.cash >= st.cost and st.slots > nextPlace.slots) then
			nextPlace = st
		end
	end
	if nextPlace then
		local c = new("Frame", { BackgroundColor3 = Color3.fromRGB(30, 90, 70), Size = UDim2.new(1, -8, 0, 110), Parent = sc })
		UI.skin(c, Color3.fromRGB(30, 90, 70))
		local ic = UI.icon(c, "company", T.teal, 76)
		ic.Position = UDim2.fromOffset(18, 17)
		new("TextLabel", { Text = "NEED MORE SPACE?  " .. nextPlace.name:upper(), FontFace = UI.HEAVY, TextSize = 16, Position = UDim2.fromOffset(112, 18), Size = UDim2.new(1, -440, 0, 24), Parent = c })
		new("TextLabel", { Text = string.format("Room for %s more GPUs. Rent %s a month.", Format.count(nextPlace.slots), Format.money(nextPlace.rent)), TextSize = 15, TextColor3 = T.sub, Position = UDim2.fromOffset(112, 50), Size = UDim2.new(1, -440, 0, 40), Parent = c })
		local sid = nextPlace.id
		UI.button(c, "BUY  " .. Format.money(nextPlace.cost), function()
			Net.act("buyStorage", sid)
		end, s.cash >= nextPlace.cost and T.green or "ghost", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -16, 0.5, 0), Size = UDim2.fromOffset(300, 62), TextSize = 15 })
	end

	-- older GPUs, hidden unless you want them
	UI.button(sc, showAll and "HIDE OLDER GPUS" or "SHOW OLDER GPUS", function()
		showAll = not showAll
		App.mount(ctx, Net.state)
	end, "ghost", { Size = UDim2.new(1, -8, 0, 44), TextSize = 12 })
	if showAll then
		for _, hw in ipairs(Hardware.list) do
			if hw ~= best and hw.id ~= "laptop" and Hardware.available(hw, s.day) then
				gpuCard(hw, false)
			end
		end
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
