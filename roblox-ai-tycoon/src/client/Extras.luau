--!strict
-- Side bar on the right: daily gift, playtime gift, friend bonus (invite), world top, settings.
-- Also runs the background music.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local SocialService = game:GetService("SocialService")
local Format = require(RS:WaitForChild("Shared"):WaitForChild("Format"))
local UI = require(script.Parent.UI)
local Net = require(script.Parent.Net)
local T = UI.T
local new = UI.new

local Extras = {}
local Fx: any = nil
local host: Instance? = nil
-- no hover on phones, so no hover sounds there by default
local settings = { music = true, musicVol = 0.5, sfx = true, sfxVol = 1, hover = not game:GetService("UserInputService").TouchEnabled }

local function meta(action: string, arg: any?): any
	local rf = RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("Meta")
	if not rf then
		return nil
	end
	local ok, res = pcall(function()
		return (rf :: RemoteFunction):InvokeServer(action, arg)
	end)
	return ok and res or nil
end

-- ===== music: licensed tracks from the Creator Store, shuffled, gentle fades =====
local TRACKS = { 140722099430139, 140658234151287, 140628387917926, 9046863253, 9046862941 }
local current: Sound? = nil
local function musicFolder()
	local f = SoundService:FindFirstChild("Music")
	if not f then
		f = Instance.new("Folder")
		f.Name = "Music"
		f.Parent = SoundService
	end
	if #f:GetChildren() == 0 then
		for i, id in ipairs(TRACKS) do
			local s = Instance.new("Sound")
			s.Name = "Track" .. i
			s.SoundId = "rbxassetid://" .. id
			s.Volume = 0.35
			s.Parent = f
		end
	end
	return f
end
local function applyMusic()
	if current then
		current.Volume = settings.music and (0.35 * settings.musicVol) or 0
	end
end
local function startMusic()
	task.spawn(function()
		local f = musicFolder()
		local order = f:GetChildren()
		local i = math.random(1, math.max(#order, 1))
		while true do
			local s = order[i] :: Sound
			if s and s:IsA("Sound") then
				current = s
				s.Volume = 0
				s:Play()
				UI.tween(s, 3, { Volume = settings.music and 0.35 * settings.musicVol or 0 })
				if not s.IsLoaded then
					s.Loaded:Wait()
				end
				task.wait(math.max(10, s.TimeLength - 3))
				UI.tween(s, 3, { Volume = 0 })
				task.wait(3)
				s:Stop()
			end
			i = i % #order + 1
			task.wait(1)
		end
	end)
end

-- ===== little popup frame =====
local function modal(title: string, color: Color3, w: number, h: number)
	local overlay = new("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45, Size = UDim2.fromScale(1, 1), ZIndex = 320, Parent = host })
	local d = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(w, h), BackgroundColor3 = T.bg, ZIndex = 321, Parent = overlay })
	new("UICorner", { CornerRadius = UDim.new(0, 10), Parent = d })
	new("UIStroke", { Color = T.line, Thickness = 4, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = d })
	local bar = new("Frame", { BackgroundColor3 = color, Size = UDim2.new(1, 0, 0, 58), ZIndex = 322, Parent = d })
	new("UICorner", { CornerRadius = UDim.new(0, 10), Parent = bar })
	new("UIGradient", { Rotation = 90, Color = ColorSequence.new(color:Lerp(Color3.new(1, 1, 1), 0.25), color:Lerp(Color3.new(0, 0, 0), 0.2)), Parent = bar })
	local tl = new("TextLabel", { Text = title, FontFace = UI.HEAVY, TextSize = 22, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), ZIndex = 323, Parent = bar })
	new("UIStroke", { Color = T.line, Thickness = 3, ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual, Parent = tl })
	local body = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(20, 70), Size = UDim2.new(1, -40, 1, -84), ZIndex = 322, Parent = d })
	local function close()
		overlay:Destroy()
	end
	UI.button(d, "X", close, T.red, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 9), Size = UDim2.fromOffset(42, 40), ZIndex = 330 })
	local sc = new("UIScale", { Scale = 0.6, Parent = d })
	local fit = UI.fit(d, 24, sc)
	UI.tween(sc, 0.3, { Scale = fit() }, Enum.EasingStyle.Back)
	if Fx then
		Fx.sound("Pop")
	end
	task.defer(function()
		for _, x in ipairs(overlay:GetDescendants()) do
			if x:IsA("GuiObject") then
				x.ZIndex = math.max(x.ZIndex, 322)
			end
		end
	end)
	return body, close
end

-- ===== daily gift =====
local function dailyPopup(info)
	local body, close = modal("DAILY GIFT", Color3.fromRGB(255, 70, 90), 760, 470)
	UI.list(body, 12, false, Enum.HorizontalAlignment.Center)
	new("TextLabel", { Text = "COME BACK EVERY DAY. THE GIFT GETS BIGGER.", FontFace = UI.BOLD, TextSize = 13, TextColor3 = T.sub, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 20), Parent = body })
	local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 150), Parent = body })
	UI.list(row, 8, true, Enum.HorizontalAlignment.Center)
	local day = info.nextStreak
	for i = 1, 7 do
		local shown = math.max(1, day - 3) + i - 1
		local now = shown == day
		local past = shown < day
		local c = new("Frame", { BackgroundColor3 = now and Color3.fromRGB(255, 185, 0) or (past and Color3.fromRGB(40, 120, 80) or T.panel2), Size = UDim2.fromOffset(92, now and 150 or 130), Parent = row })
		new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = c })
		new("UIStroke", { Color = now and Color3.new(1, 1, 1) or T.line, Thickness = now and 4 or 2, Parent = c })
		local ic = UI.icon(c, "gift", Color3.fromRGB(255, 70, 90), now and 70 or 54)
		ic.AnchorPoint = Vector2.new(0.5, 0)
		ic.Position = UDim2.new(0.5, 0, 0, 12)
		new("TextLabel", { Text = past and "GOT IT" or ("DAY " .. shown), FontFace = UI.HEAVY, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.new(0, 0, 1, -30), Size = UDim2.new(1, 0, 0, 20), Parent = c })
		if now then
			local sc = new("UIScale", { Parent = c })
			task.spawn(function()
				while c.Parent do
					UI.tween(sc, 0.5, { Scale = 1.07 }, Enum.EasingStyle.Sine)
					task.wait(0.5)
					UI.tween(sc, 0.5, { Scale = 1 }, Enum.EasingStyle.Sine)
					task.wait(0.5)
				end
			end)
		end
	end
	local amt = new("TextLabel", { Text = Format.money(info.amount), FontFace = UI.HEAVY, TextSize = 40, TextColor3 = Color3.fromRGB(0, 230, 120), TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 52), Parent = body })
	new("UIStroke", { Color = T.line, Thickness = 4, ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual, Parent = amt })
	UI.button(body, "CLAIM DAY " .. day, function()
		local r = meta("claimDaily")
		close()
		if r and r.ok and Fx then
			Fx.sound("CashRegister")
			Fx.banner("+" .. Format.money(r.amount), Color3.fromRGB(0, 230, 120), "Day " .. r.streak .. " gift")
			Fx.rain(40)
		end
		Extras.refresh()
	end, T.green, { Size = UDim2.fromOffset(360, 64), TextSize = 20 })
end

-- ===== settings =====
local function saveSettings()
	meta("setSettings", settings)
	applyMusic()
	if Fx then
		Fx.volume = settings.sfx and settings.sfxVol or 0
		Fx.hover = settings.hover
	end
end
local function settingsPopup()
	local body = modal("SETTINGS", Color3.fromRGB(90, 100, 140), 620, 470)
	local function render()
		UI.clear(body)
		UI.list(body, 12)
		local function toggle(label: string, key: string)
			local row = new("Frame", { BackgroundColor3 = T.panel2, Size = UDim2.new(1, 0, 0, 64), Parent = body })
			UI.corner(row, 2)
			new("TextLabel", { Text = label, FontFace = UI.BOLD, TextSize = 15, Position = UDim2.fromOffset(18, 0), Size = UDim2.new(1, -200, 1, 0), Parent = row })
			local on = (settings :: any)[key]
			UI.button(row, on and "ON" or "OFF", function()
				(settings :: any)[key] = not on
				saveSettings()
				render()
			end, on and T.green or T.red, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(150, 46), TextSize = 15 })
		end
		local function volume(label: string, key: string)
			local row = new("Frame", { BackgroundColor3 = T.panel2, Size = UDim2.new(1, 0, 0, 64), Parent = body })
			UI.corner(row, 2)
			new("TextLabel", { Text = label, FontFace = UI.BOLD, TextSize = 15, Position = UDim2.fromOffset(18, 0), Size = UDim2.new(0, 200, 1, 0), Parent = row })
			local v = (settings :: any)[key]
			local track = new("Frame", { BackgroundColor3 = Color3.fromRGB(14, 16, 32), Position = UDim2.fromOffset(220, 24), Size = UDim2.new(1, -400, 0, 16), Parent = row })
			UI.corner(track, 8)
			local fill = new("Frame", { BackgroundColor3 = T.accent, Size = UDim2.fromScale(v, 1), Parent = track })
			UI.corner(fill, 8)
			UI.button(row, "-", function()
				(settings :: any)[key] = math.max(0, v - 0.1)
				saveSettings()
				render()
			end, T.accent, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -78, 0.5, 0), Size = UDim2.fromOffset(56, 46), TextSize = 18 })
			UI.button(row, "+", function()
				(settings :: any)[key] = math.min(1, v + 0.1)
				saveSettings()
				render()
			end, T.accent, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(56, 46), TextSize = 18 })
		end
		toggle("MUSIC", "music")
		volume("MUSIC VOLUME", "musicVol")
		toggle("SOUND EFFECTS", "sfx")
		volume("EFFECTS VOLUME", "sfxVol")
		toggle("HOVER SOUNDS", "hover")
	end
	render()
end

-- ===== world leaderboard =====
local function topPopup()
	local body = modal("WORLD TOP COMPANIES", Color3.fromRGB(150, 80, 255), 760, 600)
	local sc = UI.scroll(body)
	UI.list(sc, 8)
	UI.label(sc, "LOADING...", 14, T.sub)
	task.spawn(function()
		local r = meta("top")
		UI.clear(sc)
		UI.list(sc, 8)
		local list = r and r.list or {}
		if #list == 0 then
			UI.label(sc, "No companies yet. Be the first!", 16, T.sub)
		end
		local me = Players.LocalPlayer.UserId
		for i, e in ipairs(list) do
			local mine = e.userId == me
			local medal = ({ Color3.fromRGB(255, 200, 40), Color3.fromRGB(200, 210, 225), Color3.fromRGB(215, 130, 60) })[i]
			local row = new("Frame", { BackgroundColor3 = mine and Color3.fromRGB(20, 110, 70) or T.panel2, Size = UDim2.new(1, -10, 0, 64), Parent = sc })
			UI.corner(row, 2)
			new("UIStroke", { Color = medal or T.line, Thickness = medal and 3 or 2, Parent = row })
			new("TextLabel", { Text = "#" .. i, FontFace = UI.HEAVY, TextSize = 18, TextColor3 = medal or T.sub, Position = UDim2.fromOffset(14, 0), Size = UDim2.fromOffset(60, 64), Parent = row })
			local face = new("ImageLabel", { BackgroundColor3 = T.bg, Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(e.userId) .. "&w=150&h=150", Position = UDim2.fromOffset(74, 8), Size = UDim2.fromOffset(48, 48), Parent = row })
			UI.corner(face, 99)
			new("TextLabel", { Text = tostring(e.company), FontFace = UI.HEAVY, TextSize = 14, Position = UDim2.fromOffset(134, 10), Size = UDim2.new(1, -360, 0, 22), Parent = row })
			new("TextLabel", { Text = tostring(e.name), TextSize = 14, TextColor3 = T.sub, Position = UDim2.fromOffset(134, 34), Size = UDim2.new(1, -360, 0, 20), Parent = row })
			new("TextLabel", { Text = Format.money(e.valuation or 0), FontFace = UI.HEAVY, TextSize = 16, TextColor3 = T.green, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 0), Size = UDim2.fromOffset(220, 64), Parent = row })
		end
	end)
end

-- clear message in the middle of the screen when something is not ready yet
local function notice(text: string)
	if not host then
		return
	end
	local n = new("TextLabel", { Text = text, FontFace = UI.HEAVY, TextSize = 20, TextColor3 = T.yellow, TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 0.05, BackgroundColor3 = T.bg, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.3), Size = UDim2.fromOffset(640, 70), ZIndex = 340, Parent = host })
	new("UICorner", { CornerRadius = UDim.new(0, 10), Parent = n })
	new("UIStroke", { Color = T.yellow, Thickness = 3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = n })
	local sc = new("UIScale", { Scale = 0.5, Parent = n })
	UI.tween(sc, 0.25, { Scale = 1 }, Enum.EasingStyle.Back)
	if Fx then
		Fx.sound("Notify")
	end
	task.delay(2.2, function()
		UI.tween(n, 0.25, { BackgroundTransparency = 1, TextTransparency = 1 })
		task.wait(0.3)
		n:Destroy()
	end)
end
local function clock(sec: number): string
	sec = math.max(0, math.floor(sec))
	if sec >= 3600 then
		return string.format("%d:%02d:%02d", sec // 3600, (sec % 3600) // 60, sec % 60)
	end
	return string.format("%d:%02d", sec // 60, sec % 60)
end

-- ===== side buttons =====
local bar: Frame? = nil
local buttons: { [string]: any } = {}
local function sideButton(id: string, icon: string, color: Color3, label: string, onClick: () -> ())
	local b = new("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromOffset(150, 122), Parent = bar })
	local ic = UI.icon(b, icon, color, 80)
	ic.AnchorPoint = Vector2.new(0.5, 0)
	ic.Position = UDim2.new(0.5, 0, 0, 0)
	local l = new("TextLabel", { Text = label, FontFace = UI.FONT, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 0.15, BackgroundColor3 = T.bg, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 84), Size = UDim2.new(1, 0, 0, 30), Parent = b })
	new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = l })
	new("UIStroke", { Color = color, Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = l })
	local dot = new("Frame", { BackgroundColor3 = T.red, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 30, 0, 6), Size = UDim2.fromOffset(18, 18), Visible = false, Parent = b })
	UI.corner(dot, 99)
	UI.stroke(dot, Color3.new(1, 1, 1), 2)
	local sc = new("UIScale", { Parent = ic })
	b.MouseEnter:Connect(function()
		UI.tween(sc, 0.15, { Scale = 1.12 }, Enum.EasingStyle.Back)
		if Fx and settings.hover then
			Fx.sound("Hover")
		end
	end)
	b.MouseLeave:Connect(function()
		UI.tween(sc, 0.12, { Scale = 1 })
	end)
	b.MouseButton1Click:Connect(function()
		sc.Scale = 0.85
		UI.tween(sc, 0.25, { Scale = 1 }, Enum.EasingStyle.Back)
		if Fx then
			Fx.sound("Click")
		end
		onClick()
	end)
	buttons[id] = { label = l, dot = dot, icon = ic, scale = sc }
	return b
end

local lastInfo: any = nil
function Extras.refresh()
	task.spawn(function()
		local info = meta("info")
		if not info then
			return
		end
		lastInfo = info
		if buttons.daily then
			buttons.daily.dot.Visible = not info.daily.claimed
			buttons.daily.label.Text = info.daily.claimed and ("DAY " .. info.daily.streak) or "GIFT!"
		end
		if buttons.friends then
			buttons.friends.label.Text = "FRIENDS +" .. math.floor((info.friendBonus or 0) * 100) .. "%"
		end
	end)
end

function Extras.start(gui: Instance, fx)
	host = gui
	Fx = fx
	bar = new("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -40, 0, 150), Size = UDim2.fromOffset(150, 680), Parent = (gui :: any).HUD or gui })
	UI.list(bar, 8, false, Enum.HorizontalAlignment.Center)
	-- phones: smaller and higher so the whole column stays on screen
	if UI.phone then
		bar.Position = UDim2.new(1, -16, 0, 118)
		new("UIScale", { Scale = 0.55, Parent = bar })
	end
	sideButton("daily", "gift", Color3.fromRGB(255, 70, 90), "GIFT", function()
		if lastInfo and not lastInfo.daily.claimed then
			dailyPopup(lastInfo.daily)
		else
			notice("NEXT DAILY GIFT IN " .. clock(86400 - os.time() % 86400))
		end
	end)
	sideButton("playtime", "clock", Color3.fromRGB(255, 80, 160), "...", function()
		local pt = lastInfo and lastInfo.playtime
		if pt and pt.count >= pt.max then
			notice("ALL PLAYTIME GIFTS COLLECTED FOR NOW")
			return
		elseif pt and (pt.nextIn or 0) > 0 then
			notice("PLAYTIME GIFT IN " .. clock(pt.nextIn))
			return
		end
		local r = meta("claimPlaytime")
		if r and r.ok and Fx then
			Fx.sound("CashRegister")
			Fx.burst(nil, 20, true)
			Fx.float("+" .. Format.money(r.amount), T.green)
		end
		Extras.refresh()
	end)
	sideButton("friends", "team", Color3.fromRGB(0, 170, 255), "FRIENDS +0%", function()
		local ok, can = pcall(SocialService.CanSendGameInviteAsync, SocialService, Players.LocalPlayer)
		if ok and can then
			pcall(SocialService.PromptGameInvite, SocialService, Players.LocalPlayer)
		else
			notice("+10% MONEY FOR EVERY FRIEND IN YOUR SERVER")
		end
	end)
	sideButton("top", "trophy", Color3.fromRGB(150, 80, 255), "WORLD TOP", topPopup)
	sideButton("settings", "gear", Color3.fromRGB(90, 100, 140), "SETTINGS", settingsPopup)

	-- load settings, start music, show the daily gift once a company is open
	task.spawn(function()
		local info = meta("info")
		if info and info.settings then
			for k, v in pairs(info.settings) do
				if (settings :: any)[k] ~= nil then
					(settings :: any)[k] = v
				end
			end
		end
		saveSettings()
		startMusic()
	end)
	local shownDaily = false
	Net.onState(function(s)
		if not shownDaily and s and s.company then
			shownDaily = true
			task.delay(2, function()
				local info = meta("info")
				lastInfo = info
				Extras.refresh()
				if info and not info.daily.claimed then
					dailyPopup(info.daily)
				end
			end)
		end
	end)
	-- luck + live world events, next to the SHOP button
	local EventsDef = require(RS.Shared.Events)
	-- events: centered at the top, under the news line (never on the laptop)
	local strip = new("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 72), Size = UDim2.fromOffset(900, 46), Parent = (gui :: any).HUD or gui })
	UI.list(strip, 8, true, Enum.HorizontalAlignment.Center)
	-- luck: a small tag tucked under the money panel
	local luckChip = new("TextLabel", { Text = "LUCK x1.00", FontFace = UI.FONT, TextSize = 14, TextColor3 = Color3.fromRGB(120, 255, 170), TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 0.1, BackgroundColor3 = T.bg, Position = UDim2.fromOffset(16, 114), Size = UDim2.fromOffset(140, 24), Parent = (gui :: any).HUD or gui })
	new("UICorner", { CornerRadius = UDim.new(0, 6), Parent = luckChip })
	new("UIStroke", { Color = Color3.fromRGB(0, 200, 110), Thickness = 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = luckChip })
	local chips: { [string]: TextLabel } = {}
	local seen: { [string]: boolean } = {}
	local lastEvents: { any } = {}
	Net.onState(function(st)
		if not st then
			return
		end
		luckChip.Text = string.format("LUCK x%.2f", st.luck or 1)
		lastEvents = st.events or {}
		local live = {}
		for _, ev in ipairs(lastEvents) do
			live[ev.id] = true
			local def = EventsDef.byId[ev.id]
			if def and not chips[ev.id] then
				local c = new("TextLabel", { Text = def.name, FontFace = UI.HEAVY, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 0, BackgroundColor3 = def.color, Size = UDim2.fromOffset(230, 42), Parent = strip })
				UI.corner(c, 2)
				UI.stroke(c, T.line, 3)
				new("UIStroke", { Color = T.line, Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual, Parent = c })
				c:SetAttribute("left", ev.left)
				chips[ev.id] = c
				if not seen[ev.id] and Fx then
					seen[ev.id] = true
					Fx.sound("Cheer")
					Fx.banner(def.name, def.color, def.desc)
					Fx.rain(50)
				end
			elseif chips[ev.id] then
				chips[ev.id]:SetAttribute("left", ev.left)
			end
		end
		for id, c in pairs(chips) do
			if not live[id] then
				c:Destroy()
				chips[id] = nil
				seen[id] = nil
			end
		end
	end)
	task.spawn(function()
		while true do
			task.wait(1)
			for id, c in pairs(chips) do
				local left = math.max(0, (c:GetAttribute("left") or 0) - 1)
				c:SetAttribute("left", left)
				local def = EventsDef.byId[id]
				c.Text = (def and def.name or id) .. string.format("  %d:%02d", left // 60, left % 60)
				c.Rotation = math.sin(os.clock() * 3) * 1.5
			end
		end
	end)
	-- playtime gift countdown on the button
	task.spawn(function()
		while true do
			task.wait(1)
			local pb = buttons.playtime
			local info = lastInfo
			if pb and info and info.playtime then
				local pt = info.playtime
				pt.nextIn = math.max(0, (pt.nextIn or 0) - 1)
				if pt.count >= pt.max then
					pb.label.Text = "ALL DONE"
					pb.dot.Visible = false
				elseif pt.nextIn <= 0 then
					pb.label.Text = "CLAIM!"
					pb.dot.Visible = true
					pb.scale.Scale = 1 + math.abs(math.sin(os.clock() * 4)) * 0.1
				else
					pb.label.Text = string.format("%d:%02d", pt.nextIn // 60, pt.nextIn % 60)
					pb.dot.Visible = false
				end
			end
		end
	end)
	-- refresh now and then (friend bonus, playtime)
	task.spawn(function()
		while true do
			task.wait(20)
			Extras.refresh()
		end
	end)
end

return Extras
