--!strict
-- Team: a Slack-style chat with your (mostly invisible) staff, plus hiring.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS:WaitForChild("Shared")
local Format = require(Shared.Format)
local Staff = require(Shared.Staff)
local Catalog = require(Shared.Catalog)
local UI = require(script.Parent.UI)
local Net = require(script.Parent.Net)
local T = UI.T
local new = UI.new

local App = { id = "team", name = "Team", icon = "team", color = Color3.fromRGB(150, 90, 240) }
local page = "chat"
local channel = "general"
local searchRole = "any"
local minRarity = 1

function App.mount(ctx, s)
	if not s then
		return
	end
	UI.clear(ctx.tabs)
	UI.clear(ctx.body)
	for _, p in ipairs({ { "chat", "Chat" }, { "people", "People" }, { "hire", "Hire" } }) do
		UI.button(ctx.tabs, p[2], function()
			page = p[1]
			App.mount(ctx, Net.state)
		end, page == p[1] and "primary" or "ghost", { Size = UDim2.fromOffset(100, 34) })
	end
	if page == "chat" then
		local side = new("Frame", { BackgroundColor3 = T.panel2, Size = UDim2.new(0, 220, 1, 0), Parent = ctx.body })
		UI.corner(side, 12)
		UI.pad(side, 12)
		UI.list(side, 4)
		UI.label(side, s.company, 18, T.text, { FontFace = UI.HEAVY })
		UI.label(side, s.headcount .. " people", 12, T.sub)
		for _, ch in ipairs({ "dms", "general", "research", "infra", "safety" }) do
			local b = UI.button(side, "# " .. ch, function()
				channel = ch
				App.mount(ctx, Net.state)
			end, channel == ch and T.purple or "ghost", { Size = UDim2.new(1, 0, 0, 32), TextXAlignment = Enum.TextXAlignment.Left })
			UI.pad(b, 0, 10)
		end
		local main = new("Frame", { BackgroundColor3 = T.panel, Position = UDim2.fromOffset(232, 0), Size = UDim2.new(1, -232, 1, 0), Parent = ctx.body })
		UI.corner(main, 12)
		UI.pad(main, 14)
		local sc = UI.scroll(main)
		UI.list(sc, 10)
		local n = 0
		for _, m in ipairs(s.chat) do
			if m.ch == channel then
				n += 1
				local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = n, Parent = sc })
				local av = new("Frame", { BackgroundColor3 = Color3.fromHSV((#m.from * 53 % 100) / 100, 0.5, 0.8), Size = UDim2.fromOffset(34, 34), Parent = row })
				UI.corner(av, 8)
				new("TextLabel", { Text = m.from:sub(1, 1), FontFace = UI.HEAVY, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = av })
				new("TextLabel", { Text = m.from .. "   " .. Format.date(m.day), FontFace = UI.BOLD, TextSize = 13, Position = UDim2.fromOffset(44, 0), Size = UDim2.new(1, -44, 0, 16), Parent = row })
				new("TextLabel", { Text = m.text, TextSize = 14, TextColor3 = T.text, Position = UDim2.fromOffset(44, 18), Size = UDim2.new(1, -44, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = row })
			end
		end
		if n == 0 then
			UI.label(sc, "Nothing here yet.", 14, T.dim)
		end
		task.defer(function()
			sc.CanvasPosition = Vector2.new(0, 1e6)
		end)
		return
	end
	if page == "people" then
		local sc = UI.scroll(ctx.body)
		UI.list(sc, 10)
		UI.pad(sc, 0, 0, 10, 8)
		-- mood of the whole team
		local avg, n = 0, 0
		for _, p in ipairs(s.people or {}) do
			avg += p.morale or 70
			n += 1
		end
		avg = n > 0 and avg / n or 70
		local top = UI.card(sc)
		UI.list(top, 6)
		UI.label(top, string.format("Team mood %d%%   |   team works at %d%% speed", math.floor(avg), math.floor((s.teamFactor or 1) * 100)), 18, T.text, { FontFace = UI.HEAVY })
		local hb = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 12), Parent = top })
		UI.bar(hb, avg / 100, avg > 55 and T.green or (avg > 30 and T.yellow or T.red), 12)
		UI.label(top, "Unhappy people work slower and quit. Parties, promotions, days off and good computers keep them happy.", 13, T.sub)
		local prow = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), Parent = top })
		UI.list(prow, 8, true)
		local ready = (s.partyReady or 0) <= s.day
		for _, pk in ipairs({ { "pizza", "Pizza night", 60 }, { "party", "Office party", 400 }, { "retreat", "Team retreat", 3500 } }) do
			local cost = pk[3] * math.max(s.headcount, 1)
			UI.button(prow, pk[2] .. "  " .. Format.money(cost), function()
				Net.act("party", pk[1])
			end, (ready and s.cash >= cost) and T.purple or "ghost", { Size = UDim2.fromOffset(240, 38), TextSize = 12 })
		end
		if not ready then
			UI.label(top, "Next party possible on " .. Format.date(s.partyReady), 12, T.dim)
		end
		-- requests
		if #(s.requests or {}) > 0 then
			UI.label(sc, "Requests", 18, T.text, { FontFace = UI.HEAVY })
			for _, r in ipairs(s.requests) do
				local c = UI.card(sc)
				UI.list(c, 6)
				UI.label(c, r.name .. ":  \"" .. r.text .. "\"", 15, T.text)
				local rr = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), Parent = c })
				UI.list(rr, 8, true)
				local id = r.id
				UI.button(rr, "Yes", function()
					Net.act("answerRequest", id, true)
				end, "success", { Size = UDim2.fromOffset(100, 34) })
				UI.button(rr, "No", function()
					Net.act("answerRequest", id, false)
				end, "ghost", { Size = UDim2.fromOffset(100, 34) })
			end
		end
		-- everyone
		UI.label(sc, "Your people", 18, T.text, { FontFace = UI.HEAVY })
		if n == 0 then
			UI.label(sc, "Nobody yet. Find people in the Hire tab.", 14, T.dim)
		end
		for _, p in ipairs(s.people or {}) do
			local c = new("Frame", { BackgroundColor3 = T.panel2, Size = UDim2.new(1, -8, 0, 78), Parent = sc })
			UI.stroke(c, T.line, 3)
			local rr = Staff.RARITIES[p.rarity or 1]
			new("Frame", { BackgroundColor3 = rr.color, Size = UDim2.new(0, 8, 1, 0), Parent = c })
			new("TextLabel", { Text = rr.name, FontFace = UI.HEAVY, TextSize = 10, TextColor3 = rr.color, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -410, 0, 8), Size = UDim2.fromOffset(140, 16), Parent = c })
			local role = Staff.byId[p.role]
			local away = p.offUntil and p.offUntil > s.day
			new("TextLabel", { Text = p.name .. (away and "   (DAY OFF)" or ""), FontFace = UI.HEAVY, TextSize = 14, TextColor3 = T.text, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 8), Size = UDim2.new(0.5, 0, 0, 18), TextXAlignment = Enum.TextXAlignment.Left, Parent = c })
			new("TextLabel", { Text = string.format("%s %s  |  %s  |  skill %d%%", Staff.RANKS[p.rank or 1], role and role.name or p.role, p.from or "", math.floor((p.skill or 1) * 100)), TextSize = 13, TextColor3 = T.sub, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 30), Size = UDim2.new(0.55, 0, 0, 16), TextXAlignment = Enum.TextXAlignment.Left, Parent = c })
			new("TextLabel", { Text = "Computer: " .. Staff.PCS[(p.pc or 0) + 1].name, TextSize = 13, TextColor3 = T.sub, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 50), Size = UDim2.new(0.3, 0, 0, 16), TextXAlignment = Enum.TextXAlignment.Left, Parent = c })
			local mb = new("Frame", { BackgroundTransparency = 1, Position = UDim2.new(0.3, 0, 0, 54), Size = UDim2.new(0.22, 0, 0, 10), Parent = c })
			local m = p.morale or 70
			UI.bar(mb, m / 100, m > 55 and T.green or (m > 30 and T.yellow or T.red), 10)
			local id = p.id
			local nextPc = math.min((p.pc or 0) + 1, #Staff.PCS - 1)
			if (p.pc or 0) < #Staff.PCS - 1 then
				UI.button(c, "PC: " .. Staff.PCS[nextPc + 1].name .. " " .. Format.money(Staff.PCS[nextPc + 1].price), function()
					Net.act("givePc", id, nextPc)
				end, "primary", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -150, 0.5, 0), Size = UDim2.fromOffset(250, 36), TextSize = 10 })
			end
			if (p.rank or 1) < #Staff.RANKS then
				UI.button(c, "Promote", function()
					Net.act("promote", id)
				end, "success", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(128, 36), TextSize = 11 })
			end
		end
		return
	end
	-- hire: pay a place to search, filter by role and rarity, then pick people
	local sc = UI.scroll(ctx.body)
	UI.list(sc, 12)
	UI.pad(sc, 0, 0, 10, 8)
	local stage = Catalog.officeStages[s.office]
	local head = new("Frame", { BackgroundColor3 = T.panel2, Size = UDim2.new(1, -8, 0, 70), Parent = sc })
	UI.skin(head, T.panel2)
	new("TextLabel", { Text = string.format("%d / %d DESKS USED", s.headcount, stage.maxStaff), FontFace = UI.HEAVY, TextSize = 18, TextColor3 = s.headcount >= stage.maxStaff and T.red or T.green, Position = UDim2.fromOffset(16, 10), Size = UDim2.new(0.5, 0, 0, 24), Parent = head })
	new("TextLabel", { Text = "Bigger office = more desks. Rare people do the work of many.", TextSize = 14, TextColor3 = T.sub, Position = UDim2.fromOffset(16, 38), Size = UDim2.new(0.6, 0, 0, 20), Parent = head })
	-- advanced search filters
	local roleName = searchRole == "any" and "ANY JOB" or Staff.byId[searchRole].name:upper()
	UI.button(head, "JOB: " .. roleName .. "  >", function()
		local ids = { "any" }
		for _, r in ipairs(Staff.roles) do
			table.insert(ids, r.id)
		end
		local idx = table.find(ids, searchRole) or 1
		searchRole = ids[idx % #ids + 1]
		App.mount(ctx, Net.state)
	end, T.accent, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -270, 0.5, 0), Size = UDim2.fromOffset(300, 48), TextSize = 12 })
	local rar = Staff.RARITIES[minRarity]
	UI.button(head, "MIN: " .. rar.name .. "  >", function()
		minRarity = minRarity % #Staff.RARITIES + 1
		App.mount(ctx, Net.state)
	end, rar.color, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(250, 48), TextSize = 12 })

	-- the places
	local places = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 210), Parent = sc })
	new("UIGridLayout", { CellSize = UDim2.new(0.25, -9, 1, 0), CellPadding = UDim2.fromOffset(12, 0), Parent = places })
	for _, pl in ipairs(Staff.PLACES) do
		local locked = s.office < pl.office
		local c = new("Frame", { BackgroundColor3 = locked and Color3.fromRGB(50, 56, 80) or pl.color, Parent = places })
		UI.corner(c, 2)
		UI.stroke(c, T.line, 3)
		new("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(150, 150, 150)), Parent = c })
		new("TextLabel", { Text = pl.name, FontFace = UI.HEAVY, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(8, 12), Size = UDim2.new(1, -16, 0, 20), Parent = c })
		new("TextLabel", { Text = pl.desc, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(10, 38), Size = UDim2.new(1, -20, 0, 40), Parent = c })
		-- odds strip
		local odds = new("Frame", { BackgroundColor3 = T.line, Position = UDim2.fromOffset(12, 88), Size = UDim2.new(1, -24, 0, 14), Parent = c })
		local total = 0
		for i, w in ipairs(pl.weights) do
			if i >= minRarity then
				total += w
			end
		end
		local x = 0
		for i, w in ipairs(pl.weights) do
			if i >= minRarity and w > 0 and total > 0 then
				new("Frame", { BackgroundColor3 = Staff.RARITIES[i].color, Position = UDim2.fromScale(x, 0), Size = UDim2.fromScale(w / total, 1), Parent = odds })
				x += w / total
			end
		end
		local cost = Staff.searchCost(pl, s.year, minRarity, searchRole ~= "any")
		local pid = pl.id
		UI.button(c, locked and ("NEEDS " .. Catalog.officeStages[pl.office].name:upper()) or ("SEARCH  " .. Format.money(cost)), function()
			if not locked then
				Net.act("recruitSearch", pid, { role = searchRole, minRarity = minRarity })
			end
		end, locked and "ghost" or T.green, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -12), Size = UDim2.new(1, -24, 0, 52), TextSize = 12 })
	end

	-- results
	local results = s.search or {}
	if #results > 0 then
		local placeName = s.searchPlace and Staff.placeById[s.searchPlace] and Staff.placeById[s.searchPlace].name or "SEARCH"
		UI.label(sc, placeName .. " FOUND THESE PEOPLE", 16, T.yellow, { FontFace = UI.HEAVY })
		local grid = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = sc })
		new("UIGridLayout", { CellSize = UDim2.new(1 / 3, -8, 0, 250), CellPadding = UDim2.fromOffset(12, 12), Parent = grid })
		for _, c in ipairs(results) do
			local r = Staff.RARITIES[c.rarity or 1]
			local role = Staff.byId[c.role]
			local f = new("Frame", { BackgroundColor3 = r.color, Parent = grid })
			UI.corner(f, 2)
			new("UIStroke", { Color = c.rarity >= 5 and Color3.fromRGB(255, 240, 150) or T.line, Thickness = c.rarity >= 5 and 5 or 3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = f })
			new("UIGradient", { Rotation = 90, Color = ColorSequence.new(r.color:Lerp(Color3.new(1, 1, 1), 0.1), r.color:Lerp(Color3.new(0, 0, 0), 0.6)), Parent = f })
			local tag = new("TextLabel", { Text = r.name, FontFace = UI.HEAVY, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 0, BackgroundColor3 = T.line, Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(150, 26), Parent = f })
			tag.TextColor3 = r.color:Lerp(Color3.new(1, 1, 1), 0.3)
			-- face: real avatar for friends, a coloured block for everyone else
			local face = new("ImageLabel", { BackgroundColor3 = Color3.fromRGB(30, 34, 60), Image = c.userId and ("rbxthumb://type=AvatarHeadShot&id=" .. c.userId .. "&w=150&h=150") or "", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 10), Size = UDim2.fromOffset(72, 72), Parent = f })
			UI.stroke(face, T.line, 3)
			if not c.userId then
				new("TextLabel", { Text = c.name:sub(1, 1), FontFace = UI.HEAVY, TextSize = 30, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = face })
			end
			if c.userId then
				local fr = new("TextLabel", { Text = "FRIEND", FontFace = UI.HEAVY, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(0, 200, 255), Position = UDim2.fromOffset(10, 42), Size = UDim2.fromOffset(90, 22), Parent = f })
				local _ = fr
			end
			new("TextLabel", { Text = c.name, FontFace = UI.HEAVY, TextSize = 16, Position = UDim2.fromOffset(12, 90), Size = UDim2.new(1, -24, 0, 24), TextTruncate = Enum.TextTruncate.AtEnd, TextWrapped = false, Parent = f })
			new("TextLabel", { Text = (role and role.name or c.role) .. "  |  " .. (c.from or ""), TextSize = 14, Position = UDim2.fromOffset(12, 118), Size = UDim2.new(1, -24, 0, 36), TextYAlignment = Enum.TextYAlignment.Top, Parent = f })
			new("TextLabel", { Text = string.format("WORKS LIKE %s PEOPLE", r.mult == math.floor(r.mult) and tostring(r.mult) or string.format("%.1f", r.mult)), FontFace = UI.BOLD, TextSize = 12, TextColor3 = Color3.fromRGB(255, 240, 160), Position = UDim2.fromOffset(12, 156), Size = UDim2.new(1, -24, 0, 18), Parent = f })
			local signing = Staff.monthlyCash(c.role, s.year) * 1.5 * r.mult
			local key = c.key
			UI.button(f, "HIRE  " .. Format.money(signing), function()
				Net.act("recruit", key)
			end, T.green, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -12), Size = UDim2.new(1, -24, 0, 50), TextSize = 13 })
		end
	else
		UI.label(sc, "Pick a place and press SEARCH. Rarer people cost more but do the work of a whole team. Your Roblox friends show up too!", 15, T.sub)
	end
	-- Robux: better people right now
	local rb = new("Frame", { BackgroundColor3 = Color3.fromRGB(255, 185, 0), Size = UDim2.new(1, -8, 0, 96), Parent = sc })
	UI.corner(rb, 2)
	UI.stroke(rb, T.line, 4)
	new("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(255, 230, 110), Color3.fromRGB(220, 120, 0)), Parent = rb })
	local ic = UI.icon(rb, "crown", Color3.fromRGB(255, 185, 0), 70)
	ic.Position = UDim2.fromOffset(14, 13)
	new("TextLabel", { Text = "LEGEND RECRUIT", FontFace = UI.HEAVY, TextSize = 18, TextColor3 = Color3.fromRGB(50, 26, 0), Position = UDim2.fromOffset(100, 16), Size = UDim2.new(1, -380, 0, 24), Parent = rb })
	new("TextLabel", { Text = "4 LEGENDARY or MYTHIC people who all say yes.", TextSize = 16, TextColor3 = Color3.fromRGB(70, 40, 0), Position = UDim2.fromOffset(100, 48), Size = UDim2.new(1, -380, 0, 30), Parent = rb })
	UI.button(rb, "R$ 99", function()
		if App.buyProduct then
			App.buyProduct("legendhire")
		end
	end, Color3.fromRGB(0, 200, 90), { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -16, 0.5, 0), Size = UDim2.fromOffset(240, 62), TextSize = 18 })
end

function App.key(s)
	local k = page .. channel .. #s.chat .. s.headcount .. s.year .. #(s.requests or {}) .. tostring((s.partyReady or 0) <= s.day) .. searchRole .. minRarity .. s.office
	if page == "people" then
		for _, p in ipairs(s.people or {}) do
			k ..= tostring(p.id) .. math.floor((p.morale or 0) / 5) .. (p.rank or 1) .. (p.pc or 0) .. tostring(p.offUntil and p.offUntil > s.day)
		end
	end
	for _, c in ipairs(s.search or {}) do
		k ..= c.key or ""
	end
	return k
end

return App
