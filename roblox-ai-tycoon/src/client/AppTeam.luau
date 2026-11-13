--!strict
-- Team: a Slack-style chat with your (mostly invisible) staff, plus hiring.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS:WaitForChild("Shared")
local Format = require(Shared.Format)
local Staff = require(Shared.Staff)
local Catalog = require(Shared.Catalog)
local Config = require(Shared.Config)
local UI = require(script.Parent.UI)
local Net = require(script.Parent.Net)
local T = UI.T
local new = UI.new

local App = { id = "team", name = "Team", icon = "team", color = Color3.fromRGB(150, 90, 240) }
local page = "chat"
local channel = "general"
local buyRarity = 1
local buyQty = 1
local QTYS = { 1, 5, 10 }
-- plain one line explanation of what each job does for your company (no dashes)
local PLAIN = {
	junior = "Runs AI experiments. Your research goes faster.",
	senior = "Knows which experiments matter. Research goes much faster.",
	star = "Famous AI researcher. A huge research boost.",
	infra = "Keeps your GPUs busy. Fewer failed training runs.",
	data = "Finds and cleans data. Your models learn better.",
	safety = "Tests your AI for danger. Fewer scandals.",
	product = "Builds app features. More users stay.",
	designer = "Makes your app look and feel great.",
	sales = "Closes big business deals. More API money.",
	marketing = "Builds hype for launches. More people hear about you.",
}
local HELPS = { research = "RESEARCH", infra = "TRAINING", data = "DATA", safety = "SAFETY", product = "APP USERS", sales = "SALES", hype = "HYPE" }

-- salary multiplier of the city you picked
local function locSalary(s): number
	for _, l in ipairs(Config.LOCATIONS) do
		if l.id == s.location then
			return l.salary
		end
	end
	return Config.LOCATIONS[1].salary
end
-- what one worker costs every month (pay plus their desk), same as the server charges
local function salaryOf(s, roleId: string, ls: number): number
	return Staff.monthlyCash(roleId, s.year) * ls + Config.SEAT_COST_MONTH
end
local function rarityUnlocked(s, i: number): boolean
	return s.office >= (Staff.RARITY_OFFICE[i] or 1)
end
local function officeName(i: number): string
	local st = Catalog.officeStages[i]
	return st and (st.name:gsub("%-", " ")) or "a bigger office"
end
local function multText(m: number): string
	return m == math.floor(m) and tostring(m) or string.format("%.1f", m)
end

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
			UI.label(sc, "Nobody yet. Buy workers in the Hire tab.", 14, T.dim)
		end
		for _, p in ipairs(s.people or {}) do
			-- one tidy card per person: face, name, job, mood bar, and three buttons on the right
			local rr = Staff.RARITIES[p.rarity or 1]
			local c = new("Frame", { BackgroundColor3 = T.panel2, Size = UDim2.new(1, -8, 0, 88), Parent = sc })
			new("UICorner", { CornerRadius = UDim.new(0, 10), Parent = c })
			new("UIStroke", { Color = rr.color, Thickness = 2, Transparency = 0.2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = c })
			new("UIGradient", { Rotation = 0, Color = ColorSequence.new(rr.color:Lerp(T.panel2, 0.78), T.panel2), Parent = c })
			local face = new("ImageLabel", { BackgroundColor3 = rr.color, Image = p.userId and ("rbxthumb://type=AvatarHeadShot&id=" .. p.userId .. "&w=150&h=150") or "", Position = UDim2.fromOffset(14, 14), Size = UDim2.fromOffset(60, 60), Parent = c })
			new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = face })
			new("UIStroke", { Color = T.line, Thickness = 2, Parent = face })
			if not p.userId then
				new("TextLabel", { Text = p.name:sub(1, 1), FontFace = UI.HEAVY, TextSize = 24, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = face })
			end
			local role = Staff.byId[p.role]
			local away = p.offUntil and p.offUntil > s.day
			new("TextLabel", { Text = p.name .. (away and "   (DAY OFF)" or ""), FontFace = UI.FONT, TextSize = 18, TextColor3 = T.text, Position = UDim2.fromOffset(88, 10), Size = UDim2.new(1, -560, 0, 24), TextTruncate = Enum.TextTruncate.AtEnd, TextWrapped = false, Parent = c })
			new("TextLabel", { Text = rr.name .. "  " .. Staff.RANKS[p.rank or 1] .. " " .. (role and role.name or p.role), FontFace = UI.BOLD, TextSize = 10, TextColor3 = rr.color:Lerp(Color3.new(1, 1, 1), 0.3), Position = UDim2.fromOffset(88, 38), Size = UDim2.new(1, -560, 0, 16), Parent = c })
			local m = p.morale or 70
			local mb = new("Frame", { BackgroundColor3 = Color3.fromRGB(14, 16, 32), Position = UDim2.fromOffset(88, 62), Size = UDim2.new(0, 160, 0, 10), Parent = c })
			new("UICorner", { CornerRadius = UDim.new(0, 5), Parent = mb })
			local mf = new("Frame", { BackgroundColor3 = m > 55 and T.green or (m > 30 and T.yellow or T.red), Size = UDim2.fromScale(m / 100, 1), Parent = mb })
			new("UICorner", { CornerRadius = UDim.new(0, 5), Parent = mf })
			new("TextLabel", { Text = "MOOD", FontFace = UI.BOLD, TextSize = 9, TextColor3 = T.sub, Position = UDim2.fromOffset(256, 58), Size = UDim2.fromOffset(60, 16), Parent = c })
			local id = p.id
			local nextPc = math.min((p.pc or 0) + 1, #Staff.PCS - 1)
			if (p.pc or 0) < #Staff.PCS - 1 then
				UI.button(c, "NEW PC " .. Format.money(Staff.PCS[nextPc + 1].price), function()
					Net.act("givePc", id, nextPc)
				end, T.accent, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -262, 0.5, 0), Size = UDim2.fromOffset(170, 44), TextSize = 10 })
			end
			if (p.rank or 1) < #Staff.RANKS then
				UI.button(c, "PROMOTE", function()
					Net.act("promote", id)
				end, T.green, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -116, 0.5, 0), Size = UDim2.fromOffset(138, 44), TextSize = 10 })
			end
			-- let go: asks once before it happens
			local sure = false
			local fire
			fire = UI.button(c, "LET GO", function()
				if not sure then
					sure = true
					fire.Text = "SURE?"
					task.delay(2.5, function()
						if fire.Parent then
							sure = false
							fire.Text = "LET GO"
						end
					end)
					return
				end
				Net.act("letGo", id)
			end, T.red, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(96, 44), TextSize = 10 })
		end
		return
	end
	-- hire: a simple worker store. Pick a rarity and how many, then BUY the job you want.
	local sc = UI.scroll(ctx.body)
	UI.list(sc, 12)
	UI.pad(sc, 0, 0, 10, 8)
	local stage = Catalog.officeStages[s.office]
	local maxStaff = stage and stage.maxStaff or 0
	local free = math.max(0, maxStaff - s.headcount)
	local ls = locSalary(s)
	if not rarityUnlocked(s, buyRarity) then
		buyRarity = 1
		for i = 1, #Staff.RARITIES do
			if rarityUnlocked(s, i) then
				buyRarity = i
			end
		end
	end
	local rar = Staff.RARITIES[buyRarity]
	local narrow = UI.phone or (ctx.body.AbsoluteSize.X > 0 and ctx.body.AbsoluteSize.X < 640)

	-- top: desks, team salary, what this buy adds
	local teamSalary = 0
	for roleId, n in pairs(s.staff or {}) do
		if Staff.byId[roleId] then
			teamSalary += salaryOf(s, roleId, ls) * n
		end
	end
	local lo, hi = math.huge, 0
	for _, r in ipairs(Staff.roles) do
		local m = salaryOf(s, r.id, ls) * buyQty
		lo = math.min(lo, m)
		hi = math.max(hi, m)
	end
	local head = UI.card(sc, { Size = UDim2.new(1, -8, 0, 0) })
	UI.list(head, 6)
	UI.label(head, string.format("%d / %d DESKS USED", s.headcount, maxStaff), 22, free <= 0 and T.red or T.green, { FontFace = UI.HEAVY })
	UI.label(head, "YOUR TEAM COSTS " .. Format.money(teamSalary) .. " A MONTH", 17, T.text, { FontFace = UI.BOLD })
	UI.label(head, string.format("BUYING %d ADDS %s TO %s A MONTH (DEPENDS ON THE JOB)", buyQty, Format.money(lo), Format.money(hi)), 15, T.yellow, { FontFace = UI.BOLD })
	UI.label(head, free > 0 and string.format("%d free %s. Bigger office in Company = more desks.", free, free == 1 and "desk" or "desks") or "Office is full. Upgrade your office in Company to get more desks.", 14, T.sub)
	-- the recruiter: fills empty desks by himself every month
	local auto = s.autoHire == true
	UI.button(head, auto and "RECRUITER: ON" or "RECRUITER: OFF", function()
		Net.act("setAutoHire", not auto)
	end, auto and T.green or "ghost", { Size = UDim2.new(narrow and 1 or 0.5, 0, 0, 48), TextSize = 14 })
	UI.label(head, "RECRUITER ON: every month he fills your empty desks with people you can afford.", 13, T.dim)

	-- rarity tabs: higher rarity works like more people and costs more
	local rarRow = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = sc })
	local rCols = narrow and 3 or #Staff.RARITIES
	new("UIGridLayout", { CellSize = UDim2.new(1 / rCols, -6, 0, 58), CellPadding = UDim2.fromOffset(6, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = rarRow })
	for i, r in ipairs(Staff.RARITIES) do
		local unlocked = rarityUnlocked(s, i)
		local on = buyRarity == i
		local needName = officeName(Staff.RARITY_OFFICE[i] or 1)
		local b = UI.button(rarRow, "", function()
			if not unlocked then
				Net.toast(r.name .. " workers unlock with " .. needName .. ". Upgrade in Company.", "error")
				return
			end
			buyRarity = i
			App.mount(ctx, Net.state)
		end, on and r.color or "ghost", { LayoutOrder = i })
		new("TextLabel", { Text = r.name, FontFace = UI.HEAVY, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = (on or not unlocked) and Color3.new(1, 1, 1) or r.color:Lerp(Color3.new(1, 1, 1), 0.25), Position = UDim2.fromOffset(4, 7), Size = UDim2.new(1, -8, 0, 20), TextWrapped = false, TextTruncate = Enum.TextTruncate.AtEnd, Parent = b })
		local sub = new("TextLabel", { Text = unlocked and ("WORKS LIKE " .. multText(r.mult)) or ("NEEDS " .. needName:upper()), FontFace = UI.BOLD, TextScaled = true, TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = unlocked and Color3.fromRGB(255, 240, 160) or T.sub, Position = UDim2.fromOffset(4, 30), Size = UDim2.new(1, -8, 0, 18), Parent = b })
		new("UITextSizeConstraint", { MaxTextSize = 12, Parent = sub })
	end

	-- how many at once
	local qRow = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 46), Parent = sc })
	UI.list(qRow, 8, true)
	new("TextLabel", { Text = "HOW MANY", FontFace = UI.HEAVY, TextSize = 15, TextColor3 = T.sub, Size = UDim2.fromOffset(100, 46), Parent = qRow })
	for _, q in ipairs(QTYS) do
		UI.button(qRow, "x" .. q, function()
			buyQty = q
			App.mount(ctx, Net.state)
		end, buyQty == q and T.accent or "ghost", { Size = UDim2.fromOffset(84, 44), TextSize = 16 })
	end

	-- the store: one card per job
	local grid = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = sc })
	local cols = narrow and 2 or 3
	new("UIGridLayout", { CellSize = UDim2.new(1 / cols, -8, 0, 262), CellPadding = UDim2.fromOffset(10, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = grid })
	for i, role in ipairs(Staff.roles) do
		local each = Staff.signing(role.id, s.year, buyRarity, ls)
		local total = each * buyQty
		local monthly = salaryOf(s, role.id, ls)
		local f = new("Frame", { BackgroundColor3 = T.panel2, LayoutOrder = i, Parent = grid })
		UI.corner(f, 2)
		new("UIStroke", { Color = buyRarity >= 4 and rar.color or T.line, Thickness = 3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = f })
		new("UIGradient", { Rotation = 90, Color = ColorSequence.new(rar.color:Lerp(T.panel2, 0.55), T.panel2), Parent = f })
		new("TextLabel", { Text = role.name:upper(), FontFace = UI.HEAVY, TextSize = 16, Position = UDim2.fromOffset(12, 10), Size = UDim2.new(1, -24, 0, 24), TextWrapped = false, TextTruncate = Enum.TextTruncate.AtEnd, Parent = f })
		new("TextLabel", { Text = rar.name .. "  |  WORKS LIKE " .. multText(rar.mult) .. (rar.mult == 1 and " PERSON" or " PEOPLE"), FontFace = UI.BOLD, TextSize = 11, TextColor3 = rar.color:Lerp(Color3.new(1, 1, 1), 0.35), Position = UDim2.fromOffset(12, 36), Size = UDim2.new(1, -24, 0, 18), TextWrapped = false, TextTruncate = Enum.TextTruncate.AtEnd, Parent = f })
		new("TextLabel", { Text = PLAIN[role.id] or (role.blurb:gsub("%-", " ")), TextSize = 13, TextColor3 = T.text, TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(12, 60), Size = UDim2.new(1, -24, 0, 52), Parent = f })
		new("TextLabel", { Text = "HELPS: " .. (HELPS[role.effect] or role.effect:upper()), FontFace = UI.BOLD, TextSize = 11, TextColor3 = T.accent, Position = UDim2.fromOffset(12, 114), Size = UDim2.new(1, -24, 0, 18), TextWrapped = false, TextTruncate = Enum.TextTruncate.AtEnd, Parent = f })
		-- price box: buy price once, salary every month
		local box = new("Frame", { BackgroundColor3 = Color3.fromRGB(20, 24, 46), BackgroundTransparency = 0.25, Position = UDim2.fromOffset(10, 138), Size = UDim2.new(1, -20, 0, 54), Parent = f })
		UI.corner(box, 2)
		new("TextLabel", { Text = "BUY PRICE", FontFace = UI.BOLD, TextSize = 11, TextColor3 = T.sub, Position = UDim2.fromOffset(8, 4), Size = UDim2.new(0.45, -8, 0, 22), Parent = box })
		new("TextLabel", { Text = Format.money(each), FontFace = UI.HEAVY, TextSize = 14, TextColor3 = T.yellow, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 4), Size = UDim2.new(0.55, 0, 0, 22), TextWrapped = false, Parent = box })
		new("TextLabel", { Text = "SALARY", FontFace = UI.BOLD, TextSize = 11, TextColor3 = T.sub, Position = UDim2.fromOffset(8, 28), Size = UDim2.new(0.45, -8, 0, 22), Parent = box })
		new("TextLabel", { Text = Format.money(monthly) .. " / MONTH", FontFace = UI.HEAVY, TextSize = 14, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 28), Size = UDim2.new(0.55, 0, 0, 22), TextWrapped = false, Parent = box })
		-- buy button: says why when you cannot
		local why
		if free <= 0 then
			why = "OFFICE FULL"
		elseif buyQty > free then
			why = string.format("ONLY %d %s FREE", free, free == 1 and "DESK" or "DESKS")
		elseif s.cash < total then
			why = "NEED " .. Format.money(total)
		end
		local rid, r, q = role.id, buyRarity, buyQty
		UI.button(f, why or (string.format("BUY x%d  %s", q, Format.money(total))), function()
			if why then
				Net.toast(why == "OFFICE FULL" and "Office is full. Upgrade your office in Company." or (why:sub(1, 4) == "NEED" and ("You need " .. Format.money(total) .. " for this.") or "Not enough free desks. Pick a smaller amount or upgrade your office."), "error")
				return
			end
			local ok, res = Net.act("buyWorker", rid, r, q)
			if ok and type(res) == "string" then
				Net.toast(res, "good")
			end
		end, why and "ghost" or T.green, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -10), Size = UDim2.new(1, -20, 0, 50), TextSize = 14 })
	end

	-- Robux: legend people right now
	local rb = new("Frame", { BackgroundColor3 = Color3.fromRGB(255, 185, 0), Size = UDim2.new(1, -8, 0, 96), Parent = sc })
	UI.corner(rb, 2)
	UI.stroke(rb, T.line, 4)
	new("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(255, 230, 110), Color3.fromRGB(220, 120, 0)), Parent = rb })
	local ic = UI.icon(rb, "crown", Color3.fromRGB(255, 185, 0), 64)
	ic.Position = UDim2.fromOffset(12, 16)
	new("TextLabel", { Text = "LEGEND RECRUIT", FontFace = UI.HEAVY, TextSize = 18, TextColor3 = Color3.fromRGB(50, 26, 0), Position = UDim2.fromOffset(88, 14), Size = UDim2.new(0.68, -96, 0, 24), TextWrapped = false, TextTruncate = Enum.TextTruncate.AtEnd, Parent = rb })
	new("TextLabel", { Text = "4 LEGENDARY or MYTHIC people who all say yes.", TextSize = 15, TextColor3 = Color3.fromRGB(70, 40, 0), Position = UDim2.fromOffset(88, 42), Size = UDim2.new(0.68, -96, 0, 44), TextYAlignment = Enum.TextYAlignment.Top, Parent = rb })
	UI.button(rb, "R$ 99", function()
		if App.buyProduct then
			App.buyProduct("legendhire")
		end
	end, Color3.fromRGB(0, 200, 90), { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.new(0.32, -14, 0, 62), TextSize = 18 })
end

function App.key(s)
	local k = page .. channel .. #s.chat .. s.headcount .. s.year .. #(s.requests or {}) .. tostring((s.partyReady or 0) <= s.day) .. s.office .. tostring(s.autoHire)
	if page == "people" then
		for _, p in ipairs(s.people or {}) do
			k ..= tostring(p.id) .. math.floor((p.morale or 0) / 5) .. (p.rank or 1) .. (p.pc or 0) .. tostring(p.offUntil and p.offUntil > s.day)
		end
	elseif page == "hire" then
		-- only what the store shows: rarity, amount, location, team mix, and which BUY buttons you can afford
		k ..= "|" .. buyRarity .. "|" .. buyQty .. "|" .. tostring(s.location) .. "|"
		for _, r in ipairs(Staff.roles) do
			k ..= (s.staff and s.staff[r.id] or 0) .. ","
		end
		local ls = locSalary(s)
		for _, r in ipairs(Staff.roles) do
			k ..= (s.cash >= Staff.signing(r.id, s.year, buyRarity, ls) * buyQty) and "1" or "0"
		end
	end
	return k
end

return App
