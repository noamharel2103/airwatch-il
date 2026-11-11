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

function App.mount(ctx, s)
	if not s then
		return
	end
	UI.clear(ctx.tabs)
	UI.clear(ctx.body)
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
	UI.label(head, "GPU supply is tight in early years. Reputation and valuation get you more allocation.", 12, T.dim)
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
	local k = tostring(s.year) .. math.floor(s.clusterPower * 10) .. (s.gpuSlots or 0) .. (s.gpuUsed or 0) .. (s.cash >= 3e6 and "r" or "p")
	for id, n in pairs(s.gpus.owned) do
		k ..= id .. n
	end
	for id, n in pairs(s.gpus.rented) do
		k ..= id .. n
	end
	return k
end

return App
