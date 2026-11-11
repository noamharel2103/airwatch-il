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

local App = { id = "parts", name = "Parts", icon = "parts", color = Color3.fromRGB(240, 150, 60) }
local qty = 8
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

function App.mount(ctx, s)
	if not s then
		return
	end
	UI.clear(ctx.tabs)
	UI.clear(ctx.body)
	UI.button(ctx.tabs, "GPUs", function()
		mode = "gpus"
		App.mount(ctx, Net.state)
	end, mode == "gpus" and "primary" or "ghost", { Size = UDim2.fromOffset(90, 34) })
	UI.button(ctx.tabs, "Your computer", function()
		mode = "pc"
		App.mount(ctx, Net.state)
	end, mode == "pc" and "primary" or "ghost", { Size = UDim2.fromOffset(160, 34) })
	if mode == "pc" then
		mountComputer(ctx, s)
		return
	end
	for _, q in ipairs({ 1, 8, 64, 512, 4096 }) do
		UI.button(ctx.tabs, "x" .. q, function()
			qty = q
			App.mount(ctx, Net.state)
		end, qty == q and "primary" or "ghost", { Size = UDim2.fromOffset(74, 34) })
	end
	local sc = UI.scroll(ctx.body)
	UI.list(sc, 10)
	UI.pad(sc, 0, 0, 10, 8)
	local head = UI.card(sc)
	UI.list(head, 6)
	local stage = Catalog.officeStages[s.office]
	UI.label(head, string.format("Cluster: %.1f H100-equivalents   |   allocation limit %s this year", s.clusterPower, Format.count(s.gpuCap)), 18, T.text, { FontFace = UI.BOLD })
	local h = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 10), Parent = head })
	UI.bar(h, s.clusterPower / math.max(s.gpuCap, 1), T.orange, 10)
	UI.label(head, string.format("Space for your own GPUs: %s / %s   |   power %.0f / %s kW", Format.count(s.gpuUsed or 0), Format.count(s.gpuSlots or 4), s.ownedKw, Format.count(s.kwCap or stage.kw)), 16, T.text, { FontFace = UI.BOLD })
	local h2 = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 10), Parent = head })
	UI.bar(h2, (s.gpuUsed or 0) / math.max(s.gpuSlots or 4, 1), T.green, 10)
	UI.label(head, string.format("Your %s fits %d GPUs. Bought GPUs need space, rented ones live in the cloud and bill every hour.", stage.name, stage.slots or 4), 12, T.sub)
	UI.label(head, "Over your allocation you can still get GPUs, but every extra one costs 8x the price.", 13, T.yellow)
	-- places to keep GPUs
	UI.label(sc, "Places for your GPUs", 18, T.text, { FontFace = UI.HEAVY })
	local sgrid = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = sc })
	new("UIGridLayout", { CellSize = UDim2.new(1 / 3, -8, 0, 132), CellPadding = UDim2.fromOffset(10, 10), Parent = sgrid })
	for _, st in ipairs(Catalog.storage) do
		local have = (s.storage or {})[st.id] or 0
		local c = new("Frame", { BackgroundColor3 = T.panel2, Parent = sgrid })
		UI.stroke(c, T.line, 3)
		UI.pad(c, 10, 12)
		new("TextLabel", { Text = st.name .. (have > 0 and ("  x" .. have) or ""), FontFace = UI.HEAVY, TextSize = 14, TextColor3 = T.text, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Parent = c })
		new("TextLabel", { Text = string.format("%s GPUs   |   %s kW   |   %s/mo", Format.count(st.slots), Format.count(st.kw), Format.money(st.rent)), TextSize = 13, TextColor3 = T.sub, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 24), Size = UDim2.new(1, 0, 0, 18), Parent = c })
		new("TextLabel", { Text = st.desc, TextSize = 12, TextColor3 = T.dim, TextWrapped = true, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 44), Size = UDim2.new(1, 0, 0, 30), TextYAlignment = Enum.TextYAlignment.Top, Parent = c })
		UI.button(c, "Buy " .. Format.money(st.cost), function()
			Net.act("buyStorage", st.id)
		end, s.cash >= st.cost and "success" or "ghost", { Position = UDim2.new(0, 0, 1, -34), Size = UDim2.new(1, 0, 0, 34) })
	end
	UI.label(sc, "GPUs", 18, T.text, { FontFace = UI.HEAVY })
	local grid = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = sc })
	new("UIGridLayout", { CellSize = UDim2.new(0.5, -6, 0, 168), CellPadding = UDim2.fromOffset(10, 10), Parent = grid })
	for _, hw in ipairs(Hardware.list) do
		local avail = Hardware.available(hw, s.day)
		local soonDays = hw.fromDay - s.day
		if avail or soonDays < 400 then
			local c = new("Frame", { BackgroundColor3 = T.panel2, Parent = grid })
			UI.corner(c, 14)
			UI.pad(c, 12, 14)
			local ic = UI.icon(c, "parts", hw.vendor == "AMD" and Color3.fromRGB(220, 60, 60) or Color3.fromRGB(110, 180, 40), 44)
			new("TextLabel", { Text = hw.name, FontFace = UI.HEAVY, TextSize = 18, Position = UDim2.fromOffset(56, 0), Size = UDim2.new(1, -56, 0, 22), Parent = c })
			new("TextLabel", { Text = string.format("%s   |   %gx H100   |   %dGB   |   %.1f kW", hw.vendor, hw.power, hw.mem, hw.kw), TextSize = 12, TextColor3 = T.sub, Position = UDim2.fromOffset(56, 22), Size = UDim2.new(1, -56, 0, 16), Parent = c })
			new("TextLabel", { Text = hw.blurb, TextSize = 12, TextColor3 = T.dim, Position = UDim2.fromOffset(0, 50), Size = UDim2.new(1, 0, 0, 30), TextYAlignment = Enum.TextYAlignment.Top, Parent = c })
			if not avail then
				new("TextLabel", { Text = "Coming " .. Format.monthYear(hw.fromDay), FontFace = UI.BOLD, TextSize = 14, TextColor3 = T.yellow, Position = UDim2.fromOffset(0, 112), Size = UDim2.new(1, 0, 0, 20), Parent = c })
			else
				local own, rent = s.gpus.owned[hw.id] or 0, s.gpus.rented[hw.id] or 0
				new("TextLabel", { Text = string.format("Buy %s   |   Rent $%.2f/hr (%s/mo each)   |   own %d, rent %d", Format.money(Hardware.buyPrice(hw, s.year)), Hardware.rentPrice(hw, s.year), Format.money(Hardware.rentPrice(hw, s.year) * 24 * 30), own, rent), TextSize = 12, TextColor3 = T.text, Position = UDim2.fromOffset(0, 82), Size = UDim2.new(1, 0, 0, 18), Parent = c })
				local row = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 108), Size = UDim2.new(1, 0, 0, 34), Parent = c })
				UI.list(row, 6, true)
				UI.button(row, "Rent " .. qty, function()
					Net.act("rent", hw.id, qty)
				end, "primary", { Size = UDim2.fromOffset(110, 32) })
				UI.button(row, "Return", function()
					Net.act("rent", hw.id, -qty)
				end, "ghost", { Size = UDim2.fromOffset(90, 32) })
				UI.button(row, "Buy " .. qty, function()
					Net.act("buy", hw.id, qty)
				end, "success", { Size = UDim2.fromOffset(100, 32) })
				UI.button(row, "Sell", function()
					Net.act("sell", hw.id, qty)
				end, "ghost", { Size = UDim2.fromOffset(70, 32) })
			end
		end
	end
end

function App.key(s)
	local k = mode .. tostring(s.year) .. math.floor(s.clusterPower * 10) .. math.floor(math.log10(math.max(s.cash, 1)) * 3) .. (s.gpuSlots or 0) .. (s.gpuUsed or 0)
	for cat, id in pairs(s.pc or {}) do
		k ..= cat .. id
	end
	for key, n in pairs(s.pcStock or {}) do
		k ..= key .. n
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
