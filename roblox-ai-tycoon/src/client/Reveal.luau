--!strict
-- The launch moment: countdown, benchmarks one by one vs SOTA, Elo slot spin,
-- reception score with reasons, then the internet reacts (posts, threads, press).
local UI = require(script.Parent.UI)
local Net = require(script.Parent.Net)
local Format = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Format"))
local T = UI.T
local new = UI.new

local R = {}

local PLATFORM = {
	x = { name = "X", color = Color3.fromRGB(230, 230, 230) },
	reddit = { name = "Reddit", color = Color3.fromRGB(255, 86, 0) },
	hn = { name = "Hacker News", color = Color3.fromRGB(255, 102, 0) },
	linkedin = { name = "LinkedIn", color = Color3.fromRGB(10, 102, 194) },
	press = { name = "Press", color = Color3.fromRGB(200, 200, 200) },
}
R.PLATFORM = PLATFORM

-- A social post card. Used here and in the Social app.
function R.postCard(parent: Instance, p, animate: boolean?)
	local plat = PLATFORM[p.platform] or PLATFORM.x
	local c = new("Frame", { BackgroundColor3 = p.official and Color3.fromRGB(26, 34, 54) or T.panel2, Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = parent })
	UI.corner(c, 12)
	UI.pad(c, 10, 14)
	UI.list(c, 4)
	local head = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), Parent = c })
	local av = new("Frame", { BackgroundColor3 = Color3.fromHSV((#p.handle * 37 % 100) / 100, 0.5, 0.85), Size = UDim2.fromOffset(18, 18), Parent = head })
	UI.corner(av, 9)
	new("TextLabel", { Text = (p.official and "" or "@") .. p.handle, FontFace = UI.BOLD, TextSize = 13, Position = UDim2.fromOffset(26, 0), Size = UDim2.new(0.6, 0, 1, 0), Parent = head })
	new("TextLabel", { Text = plat.name .. "  |  " .. (p.personaName or "") .. "  |  " .. Format.count(p.followers or 0), TextSize = 11, TextColor3 = T.dim, AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0.5, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Right, Parent = head })
	new("TextLabel", { Text = p.text, TextSize = 14, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = c })
	if p.note then
		local n = new("TextLabel", { Text = "Community note: " .. p.note, TextSize = 12, TextColor3 = T.yellow, BackgroundTransparency = 0.85, BackgroundColor3 = T.yellow, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = c })
		UI.corner(n, 8)
		UI.pad(n, 6, 8)
	end
	local stats = new("TextLabel", { Text = "", FontFace = UI.MONO, TextSize = 12, TextColor3 = T.sub, Size = UDim2.new(1, 0, 0, 16), Parent = c })
	local function setStats(k)
		stats.Text = string.format("%s likes   %s replies   %s reposts%s", Format.count(p.likes * k), Format.count(p.replies * k), Format.count(p.reposts * k), p.ratioed and "   RATIOED" or "")
		stats.TextColor3 = p.ratioed and T.red or T.sub
	end
	setStats(animate and 0 or 1)
	if animate then
		task.spawn(function()
			for i = 1, 20 do
				setStats(i / 20)
				task.wait(0.06)
			end
		end)
	end
	return c
end

function R.headline(parent: Instance, h)
	local c = new("Frame", { BackgroundColor3 = Color3.fromRGB(244, 240, 230), Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = parent })
	UI.corner(c, 6)
	UI.pad(c, 10, 14)
	UI.list(c, 2)
	new("TextLabel", { Text = string.upper(h.outlet or "News"), FontFace = UI.HEAVY, TextSize = 11, TextColor3 = Color3.fromRGB(150, 30, 30), Size = UDim2.new(1, 0, 0, 14), Parent = c })
	new("TextLabel", { Text = h.headline, FontFace = Font.new("rbxasset://fonts/families/Merriweather.json", Enum.FontWeight.Bold), TextSize = 18, TextColor3 = Color3.fromRGB(20, 20, 20), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = c })
	return c
end

function R.thread(parent: Instance, t)
	local plat = PLATFORM[t.platform] or PLATFORM.reddit
	local c = new("Frame", { BackgroundColor3 = T.panel2, Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = parent })
	UI.corner(c, 10)
	UI.pad(c, 10, 14)
	UI.list(c, 3)
	new("TextLabel", { Text = (t.sub or plat.name) .. "   " .. Format.count(t.upvotes) .. " points   " .. t.comments .. " comments", TextSize = 11, TextColor3 = plat.color, Size = UDim2.new(1, 0, 0, 14), Parent = c })
	new("TextLabel", { Text = t.title, FontFace = UI.BOLD, TextSize = 15, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = c })
	return c
end

function R.play(gui: ScreenGui, result)
	local o = new("Frame", { BackgroundColor3 = Color3.fromRGB(6, 7, 10), BackgroundTransparency = 0.05, Size = UDim2.fromScale(1, 1), ZIndex = 100, Parent = gui })
	local function z(x)
		for _, d in ipairs(x:GetDescendants()) do
			if d:IsA("GuiObject") then
				d.ZIndex = 101
			end
		end
	end
	-- countdown
	local big = new("TextLabel", { Text = "", FontFace = UI.HEAVY, TextSize = 140, TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.45), Size = UDim2.fromOffset(900, 200), ZIndex = 101, Parent = o })
	for _, n in ipairs({ "3", "2", "1" }) do
		big.Text = n
		big.TextTransparency = 0
		big.TextSize = 200
		UI.tween(big, 0.7, { TextSize = 120, TextTransparency = 0.6 })
		task.wait(0.8)
	end
	big.TextSize = 72
	big.TextTransparency = 0
	big.Text = result.modelName .. " is live"
	task.wait(1.2)
	big:Destroy()

	-- benchmarks
	local panel = new("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 60), Size = UDim2.fromOffset(980, 760), BackgroundTransparency = 1, ZIndex = 101, Parent = o })
	UI.list(panel, 10, false, Enum.HorizontalAlignment.Center)
	UI.label(panel, "Benchmarks", 30, T.text, { FontFace = UI.HEAVY, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 101 })
	for _, b in ipairs(result.benchmarks) do
		local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), ZIndex = 101, Parent = panel })
		new("TextLabel", { Text = b.name, FontFace = UI.BOLD, TextSize = 18, Size = UDim2.new(0, 260, 1, 0), ZIndex = 101, Parent = row })
		local track = new("Frame", { BackgroundColor3 = T.line, Position = UDim2.fromOffset(270, 9), Size = UDim2.new(1, -470, 0, 16), ZIndex = 101, Parent = row })
		UI.corner(track, 8)
		local fill = new("Frame", { BackgroundColor3 = T.accent, Size = UDim2.fromScale(0, 1), ZIndex = 102, Parent = track })
		UI.corner(fill, 8)
		new("Frame", { BackgroundColor3 = T.red, Position = UDim2.new(b.sota / 100, 0, 0, -6), Size = UDim2.new(0, 3, 1, 12), ZIndex = 103, Parent = track })
		local val = new("TextLabel", { Text = "", FontFace = UI.MONO, TextSize = 18, Position = UDim2.new(1, -190, 0, 0), Size = UDim2.new(0, 190, 1, 0), TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 101, Parent = row })
		UI.tween(fill, 0.9, { Size = UDim2.fromScale(b.score / 100, 1) })
		for i = 1, 15 do
			val.Text = string.format("%.1f", b.score * i / 15)
			task.wait(0.05)
		end
		local win = b.score >= b.sota
		fill.BackgroundColor3 = win and T.green or T.accent
		val.Text = string.format("%.1f  %s", b.score, win and "SOTA" or ("vs " .. b.sota))
		val.TextColor3 = win and T.green or T.sub
		task.wait(0.25)
	end
	-- Elo spin
	local elo = new("TextLabel", { Text = "", FontFace = UI.HEAVY, TextSize = 46, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 60), ZIndex = 101, Parent = panel })
	for i = 1, 24 do
		elo.Text = "Arena Elo " .. math.random(900, 1600)
		task.wait(0.04 + i * 0.006)
	end
	elo.Text = "Arena Elo " .. result.elo .. "   |   #" .. result.rank
	elo.TextColor3 = result.rank == 1 and T.yellow or T.purple
	task.wait(0.8)
	-- reception
	local score = new("TextLabel", { Text = "", FontFace = UI.HEAVY, TextSize = 64, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 80), ZIndex = 101, Parent = panel })
	for i = 1, 30 do
		score.Text = "Reception " .. math.floor(result.score * i / 30)
		task.wait(0.03)
	end
	score.Text = "Reception " .. result.score .. "/100"
	score.TextColor3 = result.score >= 75 and T.green or (result.score >= 45 and T.yellow or T.red)
	for _, w in ipairs(result.why) do
		UI.label(panel, w, 17, T.sub, { TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 101 })
		task.wait(0.35)
	end
	UI.label(panel, "+" .. Format.count(result.effects.signups) .. " signups", 22, T.teal, { FontFace = UI.BOLD, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 101 })
	task.wait(1.6)
	panel:Destroy()

	-- the internet reacts
	local cols = new("Frame", { Position = UDim2.fromOffset(40, 40), Size = UDim2.new(1, -80, 1, -120), BackgroundTransparency = 1, ZIndex = 101, Parent = o })
	local feedCol = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0.58, -10, 1, 0), ZIndex = 101, Parent = cols })
	UI.label(feedCol, "The internet reacts", 26, T.text, { FontFace = UI.HEAVY, ZIndex = 101 })
	local feed = UI.scroll(feedCol, { Position = UDim2.fromOffset(0, 40), Size = UDim2.new(1, 0, 1, -40), ZIndex = 101 })
	UI.list(feed, 8)
	local side = new("Frame", { BackgroundTransparency = 1, Position = UDim2.new(0.58, 10, 0, 0), Size = UDim2.new(0.42, -10, 1, 0), ZIndex = 101, Parent = cols })
	UI.label(side, "Headlines and threads", 26, T.text, { FontFace = UI.HEAVY, ZIndex = 101 })
	local sideList = UI.scroll(side, { Position = UDim2.fromOffset(0, 40), Size = UDim2.new(1, 0, 1, -40), ZIndex = 101 })
	UI.list(sideList, 8)
	local clock = new("TextLabel", { Text = "", FontFace = UI.BOLD, TextSize = 16, TextColor3 = T.yellow, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 6), Size = UDim2.fromOffset(300, 22), TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 101, Parent = feedCol })
	local closeBtn = UI.button(o, "Continue", function()
		o:Destroy()
	end, "primary", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -24), Size = UDim2.fromOffset(240, 46), ZIndex = 102 })
	local skipping = false
	closeBtn.MouseButton1Click:Connect(function()
		skipping = true
	end)
	task.spawn(function()
		local side = {}
		for _, h in ipairs(result.press) do
			table.insert(side, { kind = "press", hour = h.hour, data = h })
		end
		for i, t in ipairs(result.threads) do
			table.insert(side, { kind = "thread", hour = 1 + i * 4, data = t })
		end
		local items = {}
		for _, p in ipairs(result.posts) do
			table.insert(items, { kind = "post", hour = p.hour, data = p })
		end
		for _, s in ipairs(side) do
			table.insert(items, s)
		end
		table.sort(items, function(a, b)
			return a.hour < b.hour
		end)
		for _, it in ipairs(items) do
			if skipping or not o.Parent then
				return
			end
			local h = it.hour
			clock.Text = h < 1 and "Minutes after launch" or (h < 24 and ("Hour " .. math.floor(h)) or ("Day " .. math.floor(h / 24) + 1))
			local card
			if it.kind == "post" then
				card = R.postCard(feed, it.data, true)
				card.LayoutOrder = -math.floor(h * 100)
			elseif it.kind == "press" then
				card = R.headline(sideList, it.data)
				card.LayoutOrder = -math.floor(h * 100)
			else
				card = R.thread(sideList, it.data)
				card.LayoutOrder = -math.floor(h * 100)
			end
			z(card)
			card.BackgroundTransparency = 1
			UI.tween(card, 0.35, { BackgroundTransparency = 0 })
			task.wait(0.45)
		end
		clock.Text = "Week 1"
	end)
	z(o)
end

-- Smaller popup for incidents (jailbreak, escape, delay, outage...)
function R.incident(gui: ScreenGui, inc)
	local o = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(760, 620), BackgroundColor3 = T.bg, ZIndex = 90, Parent = gui })
	UI.corner(o, 18)
	UI.stroke(o, inc.kind == "ESCAPE" and T.red or T.yellow, 2)
	UI.pad(o, 18)
	local titles = { ESCAPE = "SECURITY INCIDENT", JAILBREAK = "Your model got jailbroken", DELAYED = "Launch delayed", OUTAGE = "You are down", PATCHED = "Patch shipped", SHUTDOWN = "Model pulled", CONTAMINATION = "Contamination scandal", LEAK = "Weights leaked" }
	UI.label(o, (titles[inc.kind] or inc.kind) .. "   " .. (inc.model or ""), 22, inc.kind == "ESCAPE" and T.red or T.text, { FontFace = UI.HEAVY, ZIndex = 91 })
	local sc = UI.scroll(o, { Position = UDim2.fromOffset(0, 40), Size = UDim2.new(1, 0, 1, -100), ZIndex = 91 })
	UI.list(sc, 8)
	if inc.press then
		R.headline(sc, inc.press)
	end
	for _, p in ipairs(inc.posts) do
		R.postCard(sc, p, true)
	end
	UI.button(o, "OK", function()
		o:Destroy()
	end, "primary", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 0), Size = UDim2.fromOffset(200, 42) })
	for _, d in ipairs(o:GetDescendants()) do
		if d:IsA("GuiObject") then
			d.ZIndex = 92
		end
	end
end

return R
