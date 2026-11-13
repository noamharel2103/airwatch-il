--!strict
-- Lab: ONE simple screen.
--   left:  your models + "Create model"
--   right: six stat bars, pick 2 to train, LAUNCH, REVIEWS
local RS = game:GetService("ReplicatedStorage")
local Shared = RS:WaitForChild("Shared")
local Format = require(Shared.Format)
local MT = require(Shared.ModelTypes)
local UI = require(script.Parent.UI)
local Net = require(script.Parent.Net)
local T = UI.T
local new = UI.new

local Lab = { id = "lab", name = "AI Lab", icon = "lab", color = Color3.fromRGB(70, 190, 120) }
local selected: number? = nil
local picks: { string } = {}
local newName = ""
local newKind = "chat"
local Playground -- set by Main
local page = "models"

local STATS = {
	{ id = "coding", name = "CODING", color = T.accent },
	{ id = "writing", name = "WRITING", color = T.accent },
	{ id = "math", name = "MATH", color = T.accent },
	{ id = "reasoning", name = "SMARTNESS", color = T.accent },
	{ id = "chat", name = "CHATTING", color = T.accent },
	{ id = "safety", name = "SAFETY", color = Color3.fromRGB(170, 110, 255) },
}

local function countReviews(name)
	local Social = Lab.social
	if not Social then
		return 0
	end
	for _, f in ipairs(Social.feed) do
		if f.kind == "launch" and f.data.modelName == name then
			return #f.data.posts + #f.data.press + #f.data.threads + #(f.data.reviews or {}) + #(f.data.videos or {})
		end
	end
	return 0
end

-- Quality is measured against today's best AI, so it drops as the world gets better.
local function quality(m, s)
	local avg = 0
	if m.stats then
		for _, st in ipairs(STATS) do
			if st.id ~= "safety" then
				avg += m.stats[st.id] / 5
			end
		end
	else
		avg = m.cap
	end
	return math.floor(avg / math.max(s.frontier, 1) * 100 + 0.5)
end

-- ===== launch dialog (3 simple choices) =====
local function releaseDialog(host, m, s)
	local overlay = new("TextButton", { Text = "", BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45, Size = UDim2.fromScale(1, 1), ZIndex = 40, Parent = host })
	local d = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(720, 600), ZIndex = 41, Parent = overlay })
	UI.fit(d)
	UI.skin(d, T.bg)
	local inner = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = d })
	UI.pad(inner, 26)
	UI.list(inner, 14)
	d = inner
	UI.label(d, "LAUNCH " .. m.name, 24, T.accent, { FontFace = UI.HEAVY })
	local opts = { price = 10, open = false, campaign = 0 }
	local lc = s.launchCosts or { campaign = { 0, 0, 0, 0 } }
	local function choiceRow(title, items, onPick)
		UI.label(d, title, 14, T.sub, { FontFace = UI.BOLD })
		local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 50), Parent = d })
		UI.list(row, 10, true)
		local btns = {}
		for i, it in ipairs(items) do
			btns[i] = UI.button(row, it[1], function()
				onPick(it[2])
				for j, bb in ipairs(btns) do
					bb.BackgroundColor3 = j == i and T.accent or UI.GHOST
				end
			end, i == 1 and T.accent or "ghost", { Size = UDim2.fromOffset(190, 46), TextSize = 15 })
		end
	end
	choiceRow("PRICE", { { "CHEAP", 2 }, { "NORMAL", 10 }, { "PREMIUM", 30 } }, function(v)
		opts.price = v
	end)
	choiceRow("OPEN SOURCE?", { { "NO", false }, { "YES", true } }, function(v)
		opts.open = v
	end)
	choiceRow("HYPE", { { "QUIET", 0 }, { "TEASERS " .. Format.money(lc.campaign[2]), 1 }, { "BIG SHOW " .. Format.money(lc.campaign[3]), 2 } }, function(v)
		opts.campaign = v
	end)
	-- Robux extras for this launch
	UI.label(d, "EXTRAS", 14, T.yellow, { FontFace = UI.BOLD })
	local ex = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 56), Parent = d })
	UI.list(ex, 10, true)
	local trendy = s.trendyNext == true
	local tb = UI.button(ex, trendy and "TRENDY: ON" or "MAKE IT TRENDY  R$ 49", function()
		if not trendy and Lab.buyProduct then
			Lab.buyProduct("trendy", nil)
		end
	end, trendy and T.green or Color3.fromRGB(255, 60, 130), { Size = UDim2.fromOffset(320, 54), TextSize = 13 })
	local _ = tb
	local mid = m.id
	UI.button(ex, "+10 ALL STATS  R$ 79", function()
		if Lab.buyProduct then
			Lab.buyProduct("stats10", mid)
		end
	end, Color3.fromRGB(255, 175, 0), { Size = UDim2.fromOffset(300, 54), TextSize = 13 })
	local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 60), Parent = d })
	UI.list(row, 12, true)
	UI.button(row, "CANCEL", function()
		overlay:Destroy()
	end, "ghost", { Size = UDim2.fromOffset(170, 58) })
	UI.button(row, "LAUNCH", function()
		local ok, result = Net.act("release", m.id, opts)
		overlay:Destroy()
		if ok and result and Lab.onLaunch then
			Lab.onLaunch(result)
		end
	end, T.green, { Size = UDim2.fromOffset(400, 58), TextSize = 22 })
	for _, c in ipairs(overlay:GetDescendants()) do
		if c:IsA("GuiObject") then
			c.ZIndex = math.max(c.ZIndex, 42)
		end
	end
end

-- ===== main screen =====
local live: any = {}

local function buildModels(body, s)
	-- left column
	local left = new("Frame", { Size = UDim2.new(0, 340, 1, 0), Parent = body })
	UI.skin(left, T.bg)
	UI.pad(left, 14)
	local list = UI.scroll(left, { Size = UDim2.new(1, 0, 1, -204) })
	UI.list(list, 10)
	UI.pad(list, 4, 4)
	if not selected or not s.models[selected] then
		selected = #s.models > 0 and #s.models or nil
	end
	for i = #s.models, 1, -1 do
		local m = s.models[i]
		local kk = MT.get(m.kind)
		UI.button(list, (kk.id == "chat" and "" or (kk.short .. "  ")) .. m.name, function()
			selected = m.id
			picks = {}
			Lab.mount(Lab.ctx, Net.state)
		end, m.id == selected and T.accent or (kk.id == "chat" and "ghost" or kk.color:Lerp(Color3.new(0, 0, 0), 0.35)), { Size = UDim2.new(1, -10, 0, 58), TextSize = 15 })
	end
	if s.training then
		local t = s.training
		UI.button(list, "FINISH TRAINING NOW", function()
			if Lab.buyProduct then
				Lab.buyProduct("finish", nil)
			end
		end, Color3.fromRGB(0, 200, 90), { Size = UDim2.new(1, -10, 0, 44), TextSize = 12 })
		local box = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -10, 0, 60), Parent = list })
		UI.label(box, "TRAINING " .. t.name, 13, T.yellow, { FontFace = UI.BOLD })
		local h = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 28), Size = UDim2.new(1, 0, 0, 18), Parent = box })
		local _, fill = UI.bar(h, t.progress, T.green, 18)
		live.trainFill = fill
	end
	local nameBox = new("TextBox", { Text = newName, PlaceholderText = "New model name", PlaceholderColor3 = T.dim, ClearTextOnFocus = false, BackgroundColor3 = Color3.fromRGB(20, 24, 44), AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, -70), Size = UDim2.new(1, 0, 0, 52), TextSize = 18, Parent = left })
	UI.corner(nameBox, 2)
	UI.stroke(nameBox, T.line, 3)
	UI.pad(nameBox, 0, 14)
	nameBox:GetPropertyChangedSignal("Text"):Connect(function()
		newName = nameBox.Text:sub(1, 24)
	end)
	-- what kind of AI to build (cycles through every type; newer ones unlock over the years)
	local kind = MT.get(newKind)
	local open = MT.unlocked(kind, s.day) or (s.earlyKinds and s.earlyKinds[kind.id]) == true
	UI.button(left, open and ("TYPE: " .. kind.name .. "  >") or (kind.name .. " IN " .. Format.monthYear(kind.fromDay):upper()), function()
		local idx = 1
		for i, k in ipairs(MT.list) do
			if k.id == newKind then
				idx = i
			end
		end
		newKind = MT.list[idx % #MT.list + 1].id
		Lab.mount(Lab.ctx, Net.state)
	end, open and kind.color or Color3.fromRGB(90, 70, 20), { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, -132), Size = UDim2.new(1, 0, 0, 54), TextSize = 13 })
	UI.button(left, s.training and "TRAINING..." or "+ CREATE MODEL", function()
		if s.training then
			return
		end
		if not open then
			if Lab.openShop then
				Lab.openShop("unlockkind", nil)
			end
			return
		end
		if Net.act("createModel", newName, newKind) then
			newName = ""
			Net.toast("Training started!", "good")
		end
	end, s.training and "ghost" or T.green, { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 58), TextSize = 16 })

	-- right side
	local right = new("Frame", { Position = UDim2.fromOffset(354, 0), Size = UDim2.new(1, -354, 1, 0), Parent = body })
	UI.skin(right, T.panel)
	UI.pad(right, 24)
	local m = selected and s.models[selected]
	if not m then
		UI.label(right, "NO MODELS YET", 22, T.accent, { FontFace = UI.HEAVY })
		UI.label(right, "Type a name on the left and press CREATE MODEL. Your laptop trains a tiny one in about two minutes.", 18, T.sub, { Position = UDim2.fromOffset(0, 44) })
		return
	end
	local status = m.status == "released" and ("LIVE   " .. Format.count(m.users or 0) .. " USERS") or (m.status == "banned" and "SHUT DOWN BY GOVERNMENT" or (m.status == "delayed" and "DELAYED" or "NOT LAUNCHED"))
	local mk = MT.get(m.kind)
	if mk.id ~= "chat" then
		local side = s.sideIncome and s.sideIncome.byKind and s.sideIncome.byKind[mk.id]
		local earns = (side and side.model == m.name) and ("EARNS " .. Format.money(side.day * 30) .. " / MONTH") or (m.status == "released" and "YOUR BETTER " .. mk.short .. " MODEL EARNS INSTEAD" or "LAUNCH IT TO START EARNING")
		status = mk.name .. "   " .. earns
	end
	UI.label(right, m.name, 26, mk.id == "chat" and T.accent or mk.color, { FontFace = UI.HEAVY })
	UI.label(right, "TO RUN IT: " .. Lab.runNeeds(m.size or 1), 11, T.yellow, { FontFace = UI.BOLD, Position = UDim2.fromOffset(0, 66), Size = UDim2.new(1, 0, 0, 14) })
	UI.label(right, "QUALITY " .. quality(m, s) .. "%  OF TODAY'S BEST      " .. status, 14, m.status == "released" and T.green or T.sub, { FontFace = UI.BOLD, Position = UDim2.fromOffset(0, 44) })
	-- the stat rows share the space between the title and the bottom buttons, so on a short
	-- screen they get thinner instead of hiding under LAUNCH / REVIEWS
	local rows = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 86), Size = UDim2.new(1, 0, 1, -218), Parent = right })
	new("UISizeConstraint", { MaxSize = Vector2.new(math.huge, 6 * 40), Parent = rows })
	UI.list(rows, 4)
	local busy = m.boosting ~= nil
	for _, st in ipairs(STATS) do
		local v = m.stats and m.stats[st.id] or 0
		local picked = table.find(picks, st.id) ~= nil
		local isTraining = busy and (m.boosting.a == st.id or m.boosting.b == st.id)
		local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1 / 6, -4), Parent = rows })
		new("TextLabel", { Text = st.name, FontFace = UI.BOLD, TextSize = 17, TextColor3 = (picked or isTraining) and T.yellow or T.text, Size = UDim2.new(0, 190, 1, 0), Parent = row })
		local track = new("Frame", { BackgroundColor3 = Color3.fromRGB(18, 22, 40), Position = UDim2.new(0, 200, 0.15, 0), Size = UDim2.new(1, -440, 0.7, 0), Parent = row })
		UI.corner(track, 2)
		UI.stroke(track, T.line, 3)
		new("Frame", { BackgroundColor3 = st.color, Size = UDim2.fromScale(math.clamp(v / math.max(s.eraCeiling or 100, 1), 0, 1), 1), Parent = track })
		new("TextLabel", { Text = tostring(v), FontFace = UI.BOLD, TextSize = 14, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.new(1, -228, 0, 0), Size = UDim2.new(0, 56, 1, 0), Parent = row })
		UI.button(row, isTraining and "TRAINING" or (picked and "PICKED" or "PICK"), function()
			if busy then
				return
			end
			local idx = table.find(picks, st.id)
			if idx then
				table.remove(picks, idx)
			elseif #picks < 2 then
				table.insert(picks, st.id)
			else
				picks[1] = picks[2]
				picks[2] = st.id
			end
			Lab.mount(Lab.ctx, Net.state)
		end, isTraining and T.purple or (picked and T.yellow or (busy and "ghost" or T.green)), { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 150, 1, 0), TextSize = 13 })
	end
	-- train line
	local trainRow = new("Frame", { BackgroundTransparency = 1, Position = UDim2.new(0, 0, 1, -128), Size = UDim2.new(1, 0, 0, 54), Parent = right })
	if busy then
		local total = math.max(1, m.boosting.doneDay - m.boosting.startDay)
		local frac = math.clamp((s.day - m.boosting.startDay) / total, 0, 1)
		UI.label(trainRow, "TRAINING " .. m.boosting.a:upper() .. (m.boosting.b and (" + " .. m.boosting.b:upper()) or ""), 13, T.yellow, { FontFace = UI.BOLD })
		local h = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 26), Size = UDim2.new(1, 0, 0, 22), Parent = trainRow })
		local _, f = UI.bar(h, frac, T.purple, 22)
		live.boostFill = f
		live.boostModel = m.id
	elseif #picks >= 1 then
		local staffNote = (m.boostStaff or 0) > 0 and ("  NEEDS " .. m.boostStaff .. " ENGINEERS") or ""
		local one = #picks == 1
		local mult = one and 0.6 or 1
		local what = one and (picks[1]:upper() .. " ONLY (x1.5 GAIN)") or (picks[1]:upper() .. " + " .. picks[2]:upper())
		UI.button(trainRow, string.format("TRAIN %s   %s + %s POWER   %d DAYS%s", what, Format.money(m.boostCost * mult), Format.money((m.boostPower or 0) * mult), m.boostDays, staffNote), function()
			if Net.act("boost", m.id, picks[1], picks[2] or "") then
				picks = {}
			end
		end, T.purple, { Size = UDim2.new(1, 0, 0, 52), TextSize = 15 })
	else
		UI.label(trainRow, m.lastGain and ("LAST TRAINING " .. m.lastGain:upper()) or "PICK 1 OR 2 STATS TO TRAIN", 13, T.sub, { FontFace = UI.BOLD, Size = UDim2.new(1, 0, 0, 20) })
	end
	-- pay to win shortcuts
	local mid = m.id
	if busy then
		UI.button(right, "FINISH NOW", function()
			if Lab.buyProduct then
				Lab.buyProduct("finish", mid)
			end
		end, Color3.fromRGB(0, 200, 90), { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(200, 44), TextSize = 12 })
	else
		UI.button(right, "SUPER BOOST", function()
			if Lab.buyProduct then
				Lab.buyProduct("stats10", mid)
			end
		end, Color3.fromRGB(255, 60, 130), { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(200, 44), TextSize = 12 })
	end
	-- bottom buttons
	local bottom = new("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 66), Parent = right })
	UI.list(bottom, 14, true)
	if m.status == "ready" then
		UI.button(bottom, "LAUNCH", function()
			releaseDialog(Lab.host or body, m, Net.state)
		end, T.green, { Size = UDim2.new(0.42, -10, 0, 64), TextSize = 22 })
	elseif m.status == "released" and mk.id ~= "chat" then
		UI.button(bottom, "SELLING", function() end, mk.color, { Size = UDim2.new(0.42, -10, 0, 64), TextSize = 16 })
	elseif m.status == "released" then
		local inApp = s.product.activeModel == m.id
		UI.button(bottom, inApp and "IN YOUR APP" or "PUT IN APP", function()
			Net.act("setActive", m.id)
		end, inApp and T.green or T.accent, { Size = UDim2.new(0.42, -10, 0, 64), TextSize = 16 })
	end
	local n = countReviews(m.name)
	UI.button(bottom, "REVIEWS (" .. n .. ")", function()
		if Lab.openReviews then
			Lab.openReviews(m.name)
		end
	end, n > 0 and T.orange or "ghost", { Size = UDim2.new(0.36, -10, 0, 64), TextSize = 16 })
	UI.button(bottom, "CHAT", function()
		if Playground then
			Playground.open(Lab.host or body, m, Net.state)
		end
	end, "ghost", { Size = UDim2.new(0.22, -10, 0, 64), TextSize = 16 })
end

local MEDAL_COLOR = { Color3.fromRGB(255, 196, 40), Color3.fromRGB(200, 210, 225), Color3.fromRGB(205, 127, 50) }
local MEDAL_BG = { Color3.fromRGB(70, 56, 18), Color3.fromRGB(46, 50, 62), Color3.fromRGB(64, 40, 22) }

-- What computer you need to run a model of this size (billions of parameters)
local function runNeeds(sizeB: number): string
	local q4 = sizeB * 0.6
	local fp16 = sizeB * 2
	if q4 <= 8 then
		return "RUNS ON A GAMING LAPTOP"
	elseif q4 <= 24 then
		return "NEEDS A GAMER CARD WITH 24GB"
	elseif q4 <= 80 then
		return "NEEDS ONE VOLTA H1 (80GB)"
	end
	return string.format("NEEDS %d VOLTA H1 CHIPS (%d AT FULL QUALITY)", math.ceil(q4 / 80), math.ceil(fp16 / 80))
end
Lab.runNeeds = runNeeds

local function buildOpen(body, s)
	local bg = new("Frame", { Size = UDim2.fromScale(1, 1), Parent = body })
	UI.skin(bg, T.panel)
	local sc = UI.scroll(bg)
	UI.pad(sc, 14)
	UI.list(sc, 10)
	local mine = selected and s.models[selected]
	local head = new("Frame", { BackgroundColor3 = Color3.fromRGB(20, 90, 70), Size = UDim2.new(1, -12, 0, 70), Parent = sc })
	UI.corner(head, 2)
	UI.stroke(head, T.line, 3)
	new("TextLabel", { Text = "OPEN SOURCE MODELS", FontFace = UI.HEAVY, TextSize = 18, Position = UDim2.fromOffset(16, 10), Size = UDim2.new(1, -32, 0, 24), Parent = head })
	new("TextLabel", { Text = mine and ("Your model " .. mine.name .. " can study any of these. Better ones teach more.") or "Pick one of your models in MODELS first.", TextSize = 15, TextColor3 = Color3.fromRGB(200, 240, 220), Position = UDim2.fromOffset(16, 38), Size = UDim2.new(1, -32, 0, 22), Parent = head })
	local list = s.openModels or {}
	if #list == 0 then
		UI.label(sc, "Nobody has shared open weights yet.", 16, T.sub)
		return
	end
	local myAvg = 0
	if mine and mine.stats then
		for k, v in pairs(mine.stats) do
			if k ~= "safety" then
				myAvg += v / 5
			end
		end
	end
	for _, r in ipairs(list) do
		local better = r.cap > myAvg
		local c = new("Frame", { BackgroundColor3 = T.panel2, Size = UDim2.new(1, -12, 0, 104), Parent = sc })
		UI.corner(c, 2)
		UI.stroke(c, better and T.green or T.line, better and 3 or 2)
		new("TextLabel", { Text = r.model, FontFace = UI.HEAVY, TextSize = 16, Position = UDim2.fromOffset(16, 10), Size = UDim2.new(1, -320, 0, 22), Parent = c })
		new("TextLabel", { Text = r.lab .. "   |   " .. Format.monthYear(r.day) .. "   |   about " .. Format.count(r.size * 1e9) .. " parameters", TextSize = 14, TextColor3 = T.sub, Position = UDim2.fromOffset(16, 36), Size = UDim2.new(1, -320, 0, 20), Parent = c })
		new("TextLabel", { Text = "TO RUN IT: " .. runNeeds(r.size), FontFace = UI.BOLD, TextSize = 11, TextColor3 = T.yellow, Position = UDim2.fromOffset(16, 62), Size = UDim2.new(1, -320, 0, 18), Parent = c })
		local track = new("Frame", { BackgroundColor3 = Color3.fromRGB(14, 16, 32), Position = UDim2.fromOffset(16, 84), Size = UDim2.new(1, -320, 0, 8), Parent = c })
		new("Frame", { BackgroundColor3 = better and T.green or T.orange, Size = UDim2.fromScale(math.clamp(r.cap / math.max(s.frontier, 1), 0, 1), 1), Parent = track })
		local idx = r.idx
		UI.button(c, better and "LEARN FROM IT" or "WEAKER THAN YOURS", function()
			if mine then
				Net.act("learnFrom", mine.id, idx)
			end
		end, (better and mine and not mine.boosting) and T.green or "ghost", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(280, 60), TextSize = 13 })
	end
end

local function buildArena(body, s)
	local bg = new("Frame", { Size = UDim2.fromScale(1, 1), Parent = body })
	UI.skin(bg, T.panel)
	local sc = UI.scroll(bg)
	UI.pad(sc, 16)
	UI.list(sc, 10)
	-- sort by ELO (highest first) so the rank numbers are always right
	local ranked = table.clone(s.leaderboard or {})
	table.sort(ranked, function(a, b)
		return (tonumber(a.elo) or 0) > (tonumber(b.elo) or 0)
	end)
	if #ranked == 0 then
		new("TextLabel", { Text = "No models on the leaderboard yet.", FontFace = UI.BOLD, TextSize = 18, TextColor3 = T.sub, BackgroundTransparency = 1, Size = UDim2.new(1, -12, 0, 60), Parent = sc })
		return
	end
	local top = math.max(tonumber(ranked[1].elo) or 0, 1)
	local you
	for _, e in ipairs(ranked) do
		if e.you then
			you = e
		end
	end
	-- banner: the player's gap to #1 (or lead over #2 when on top)
	if you then
		local yElo = tonumber(you.elo) or 0
		local banner = new("Frame", { Size = UDim2.new(1, -12, 0, 52), Parent = sc })
		local text, color
		if ranked[1] == you then
			local second = ranked[2] and (tonumber(ranked[2].elo) or 0) or 0
			text = "YOU ARE #1   LEAD: +" .. tostring(math.floor(yElo - second + 0.5)) .. " ELO"
			color = Color3.fromRGB(20, 110, 70)
		else
			text = "GAP TO #1: " .. tostring(math.floor(top - yElo + 0.5)) .. " ELO"
			color = Color3.fromRGB(110, 60, 20)
		end
		UI.skin(banner, color)
		new("TextLabel", { Text = text, FontFace = UI.HEAVY, TextSize = 20, TextColor3 = T.yellow, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = banner })
	end
	for i, e in ipairs(ranked) do
		local v = tonumber(e.elo) or 0
		local isYou = e.you == true
		local medal = i <= 3 and i or nil
		local h = isYou and 76 or (medal and 66 or 56)
		local r = new("Frame", { Size = UDim2.new(1, -12, 0, h), Parent = sc })
		UI.skin(r, isYou and Color3.fromRGB(20, 110, 70) or (medal and MEDAL_BG[medal]) or T.panel2)
		if medal then
			UI.stroke(r, MEDAL_COLOR[medal], 2)
		end
		if isYou then
			UI.stroke(r, T.green, 3)
		end
		-- rank badge (gold, silver, bronze for the top 3)
		local badge = new("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0), Size = UDim2.fromOffset(isYou and 46 or 40, isYou and 46 or 40), BackgroundColor3 = medal and MEDAL_COLOR[medal] or (isYou and T.green or Color3.fromRGB(12, 16, 30)), Parent = r })
		UI.corner(badge, 2)
		new("TextLabel", { Text = tostring(i), FontFace = UI.HEAVY, TextSize = isYou and 22 or 19, TextColor3 = medal and Color3.fromRGB(20, 20, 26) or T.text, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = badge })
		-- model and lab
		new("TextLabel", { Text = e.model .. (isYou and "  (YOU)" or ""), FontFace = UI.BOLD, TextSize = isYou and 19 or 16, TextColor3 = isYou and Color3.fromRGB(190, 255, 215) or T.text, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Position = UDim2.new(0, 66, 0, isYou and 10 or 8), Size = UDim2.new(0.5, -66, 0, 26), Parent = r })
		new("TextLabel", { Text = tostring(e.lab), TextSize = 13, TextColor3 = T.sub, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Position = UDim2.new(0, 66, 0, isYou and 38 or 34), Size = UDim2.new(0.5, -66, 0, 18), Parent = r })
		-- ELO bar, relative to the top score
		local track = new("Frame", { BackgroundColor3 = Color3.fromRGB(18, 22, 40), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0.5, 10, 0.5, 0), Size = UDim2.new(0.5, -170, 0, 14), Parent = r })
		UI.corner(track, 2)
		local ratio = math.clamp(v / top, 0, 1)
		local barColor = isYou and T.green or (medal and MEDAL_COLOR[medal]) or T.accent
		new("Frame", { BackgroundColor3 = barColor, BorderSizePixel = 0, Size = UDim2.fromScale(ratio, 1), Parent = track })
		new("TextLabel", { Text = tostring(math.floor(v + 0.5)) .. " ELO", FontFace = UI.BOLD, TextSize = 15, TextColor3 = isYou and T.green or T.text, TextXAlignment = Enum.TextXAlignment.Right, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.new(0, 120, 0, 24), Parent = r })
		if e.new == true then
			new("TextLabel", { Text = "NEW", FontFace = UI.HEAVY, TextSize = 11, TextColor3 = Color3.fromRGB(20, 20, 26), BackgroundColor3 = T.yellow, BackgroundTransparency = 0, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -12, 1, -4), Size = UDim2.fromOffset(44, 16), Parent = r })
		end
	end
end

function Lab.mount(ctx, s)
	Lab.ctx = ctx
	if not s then
		return
	end
	UI.clear(ctx.tabs)
	for _, p in ipairs({ { "models", "MODELS" }, { "open", "OPEN MODELS" }, { "arena", "LEADERBOARD" } }) do
		UI.button(ctx.tabs, p[2], function()
			page = p[1]
			Lab.mount(ctx, Net.state)
		end, page == p[1] and T.accent or "ghost", { Size = UDim2.fromOffset(200, 42), TextSize = 14 })
	end
	UI.clear(ctx.body)
	live = {}
	if page == "models" then
		buildModels(ctx.body, s)
	elseif page == "open" then
		buildOpen(ctx.body, s)
	else
		buildArena(ctx.body, s)
	end
end

function Lab.key(s)
	if page == "arena" then
		return "a" .. #s.leaderboard .. math.floor(s.frontier)
	end
	if page == "open" then
		local k = "o" .. #(s.openModels or {}) .. tostring(selected)
		for _, m in ipairs(s.models) do
			k ..= (m.boosting and "b" or "") .. (m.lastGain or "")
		end
		return k
	end
	local k = "m" .. (s.training and "t" or "") .. tostring(s.product.activeModel) .. tostring(s.day // 30)
	for _, m in ipairs(s.models) do
		k ..= m.status .. (m.boosting and "b" or "") .. (m.lastGain or "") .. math.floor(math.log10((m.users or 0) + 1) * 2)
	end
	return k
end

function Lab.refresh(ctx, s)
	if live.trainFill and s.training then
		live.trainFill.Size = UDim2.fromScale(s.training.progress, 1)
	end
	if live.boostFill and live.boostModel then
		local m = s.models[live.boostModel]
		if m and m.boosting then
			local total = math.max(1, m.boosting.doneDay - m.boosting.startDay)
			live.boostFill.Size = UDim2.fromScale(math.clamp((s.day - m.boosting.startDay) / total, 0, 1), 1)
		end
	end
end

function Lab.setPlayground(p)
	Playground = p
end

return Lab
