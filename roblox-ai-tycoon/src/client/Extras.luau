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
	local body = modal("SETTINGS", Color3.fromRGB(90, 100, 140), 620, 640)
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
		local function closeModal()
			local o: Instance = body
			while o.Parent and not o.Parent:IsA("LayerCollector") do
				o = o.Parent
			end
			o:Destroy()
		end
		UI.button(body, "PLAY THE TUTORIAL AGAIN", function()
			UI.confirm(body, "PLAY THE TUTORIAL?", "The tutorial starts again from step 1. Your company stays the same.", "YES, START", function()
				Net.act("tutStep", 1)
				closeModal()
			end)
		end, T.purple, { Size = UDim2.new(1, 0, 0, 56), TextSize = 18 })
		UI.button(body, "BACK TO MAIN MENU (MY COMPANIES)", function()
			UI.confirm(body, "BACK TO THE MENU?", "Your company is saved. You can pick it or another one from the menu.", "YES, GO BACK", function()
				closeModal()
				local sh = (Extras :: any).shell
				if sh and sh.backToMenu then
					sh.backToMenu()
				end
			end)
		end, T.accent, { Size = UDim2.new(1, 0, 0, 56), TextSize = 18 })
	end
	render()
end

-- ===== leaderboards: money or models, this server or the whole world =====
local topBoard, topScope = "money", "server"
local function topPopup()
	local body = modal("LEADERBOARDS", Color3.fromRGB(150, 80, 255), 820, 640)
	local tabs = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 46), Parent = body })
	UI.list(tabs, 8, true)
	local sc = UI.scroll(body, { Position = UDim2.fromOffset(0, 58), Size = UDim2.new(1, 0, 1, -58) })
	local fill
	local tabBtns = {}
	local TABS = { { "server", "money", "SERVER MONEY" }, { "world", "money", "WORLD MONEY" }, { "server", "models", "SERVER MODELS" }, { "world", "models", "WORLD MODELS" } }
	local function paint()
		for i, t in ipairs(TABS) do
			local on = t[1] == topScope and t[2] == topBoard
			tabBtns[i].BackgroundColor3 = on and Color3.fromRGB(150, 80, 255) or Color3.fromRGB(58, 70, 120)
		end
	end
	for i, t in ipairs(TABS) do
		tabBtns[i] = UI.button(tabs, t[3], function()
			topScope, topBoard = t[1], t[2]
			paint()
			fill()
		end, "ghost", { Size = UDim2.new(0.25, -6, 1, 0), TextSize = 13 })
	end
	fill = function()
		UI.clear(sc)
		UI.list(sc, 8)
		UI.label(sc, "LOADING...", 14, T.sub)
		local want = topScope .. topBoard
		task.spawn(function()
			local r = meta("top", { board = topBoard, scope = topScope })
			if want ~= topScope .. topBoard or not sc.Parent then
				return
			end
			UI.clear(sc)
			UI.list(sc, 8)
			local list = r and r.list or {}
			if #list == 0 then
				UI.label(sc, topBoard == "models" and "Nobody launched a chat model yet. Be the first!" or "No companies yet. Be the first!", 16, T.sub)
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
				local top = topBoard == "models" and tostring(e.model) or tostring(e.company)
				local sub = topBoard == "models" and (tostring(e.company) .. "  |  " .. tostring(e.name)) or tostring(e.name)
				new("TextLabel", { Text = top, FontFace = UI.HEAVY, TextSize = 15, TextTruncate = Enum.TextTruncate.AtEnd, TextWrapped = false, Position = UDim2.fromOffset(134, 10), Size = UDim2.new(1, -380, 0, 22), Parent = row })
				new("TextLabel", { Text = sub, TextSize = 14, TextColor3 = T.sub, TextTruncate = Enum.TextTruncate.AtEnd, TextWrapped = false, Position = UDim2.fromOffset(134, 34), Size = UDim2.new(1, -380, 0, 20), Parent = row })
				local value = topBoard == "models" and ("SCORE " .. Format.count(math.floor(e.quality or 0))) or Format.money(e.valuation or 0)
				new("TextLabel", { Text = value, FontFace = UI.HEAVY, TextSize = 16, TextColor3 = T.green, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 0), Size = UDim2.fromOffset(230, 64), Parent = row })
			end
		end)
	end
	paint()
	fill()
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
-- the Settings app in the computer changes the same values: keep both in sync
function Extras.setValues(v)
	if type(v) ~= "table" then
		return
	end
	for k, x in pairs(v) do
		settings[k] = x
	end
	applyMusic()
end
function Extras.getValues()
	return table.clone(settings)
end

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
	sideButton("top", "trophy", Color3.fromRGB(150, 80, 255), "RANKS", topPopup)
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
	-- luck + live world events + personal admin boosts
	local EventsDef = require(RS.Shared.Events)
	local hudRoot = (gui :: any).HUD or gui
	-- luck: a small tag tucked under the money panel, only when you have extra luck
	local luckChip = new("TextLabel", { Text = "LUCK x1.00", Visible = false, FontFace = UI.FONT, TextSize = 14, TextColor3 = Color3.fromRGB(120, 255, 170), TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 0.1, BackgroundColor3 = T.bg, Position = UDim2.fromOffset(16, 114), Size = UDim2.fromOffset(140, 24), Parent = hudRoot })
	new("UICorner", { CornerRadius = UDim.new(0, 6), Parent = luckChip })
	new("UIStroke", { Color = Color3.fromRGB(0, 200, 110), Thickness = 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = luckChip })

	-- events and boosts: a row of round icons at the bottom right with a timer under each.
	-- Hover (PC) or tap (phone) shows a card that says what it does.
	local EVENT_ICON = { lucky = "trophy", money = "cash", hyper = "brain", peace = "shield", viral = "fire", gpusale = "gpu", legends = "team", gifts = "gift", abuse = "crown" }
	local ICON = 66
	local row = new("Frame", { Name = "EventIcons", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -24, 1, -18), Size = UDim2.fromOffset(760, ICON + 30), Parent = hudRoot })
	local rowList = UI.list(row, 12, true, Enum.HorizontalAlignment.Right)
	rowList.VerticalAlignment = Enum.VerticalAlignment.Bottom
	local tip = new("Frame", { Name = "EventTip", Visible = false, BackgroundColor3 = T.bg, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -24, 1, -(18 + ICON + 40)), Size = UDim2.fromOffset(330, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 70, Parent = hudRoot })
	new("UICorner", { CornerRadius = UDim.new(0, 10), Parent = tip })
	local tipStroke = new("UIStroke", { Color = T.accent, Thickness = 3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = tip })
	UI.pad(tip, 12, 14)
	UI.list(tip, 4)
	local tipName = new("TextLabel", { Text = "", FontFace = UI.HEAVY, TextSize = 18, Size = UDim2.new(1, 0, 0, 24), LayoutOrder = 1, ZIndex = 71, Parent = tip })
	local tipDesc = new("TextLabel", { Text = "", FontFace = UI.FONT, TextSize = 15, TextColor3 = T.text, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, ZIndex = 71, Parent = tip })
	local tipLeft = new("TextLabel", { Text = "", FontFace = UI.BOLD, TextSize = 14, TextColor3 = T.yellow, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 3, ZIndex = 71, Parent = tip })
	local function layoutIcons(phone: boolean)
		-- phones: keep clear of the side buttons on the right edge
		row.Position = phone and UDim2.new(1, -112, 1, -10) or UDim2.new(1, -24, 1, -18)
		tip.Position = phone and UDim2.new(1, -112, 1, -(10 + ICON + 40)) or UDim2.new(1, -24, 1, -(18 + ICON + 40))
	end
	layoutIcons(UI.phone)

	-- an entry = { id, btn, timer, ends (os.clock), name, desc, color }
	local entries: { [string]: any } = {}
	local shownTip: any = nil
	local pinned: any = nil
	local hovering: any = nil

	local function left(e: any): number
		return math.max(0, e.ends - os.clock())
	end
	local function showTip(e: any)
		shownTip = e
		if not e then
			tip.Visible = false
			return
		end
		tipName.Text = e.name
		tipName.TextColor3 = e.color:Lerp(Color3.new(1, 1, 1), 0.35)
		tipDesc.Text = e.desc
		tipLeft.Text = "Ends in " .. clock(left(e))
		tipStroke.Color = e.color
		tip.Visible = true
	end

	local function makeEntry(id: string, name: string, desc: string, icon: string, color: Color3, order: number)
		local btn = new("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromOffset(ICON, ICON + 26), LayoutOrder = order, Parent = row })
		local disc = new("Frame", { BackgroundColor3 = color, Size = UDim2.fromOffset(ICON, ICON), Parent = btn })
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = disc })
		new("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = disc })
		new("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(170, 170, 170)), Parent = disc })
		local ic = UI.icon(disc, icon, color, math.floor(ICON * 0.66))
		ic.AnchorPoint = Vector2.new(0.5, 0.5)
		ic.Position = UDim2.fromScale(0.5, 0.5)
		local timer = new("TextLabel", { Text = "", FontFace = UI.HEAVY, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Center, BackgroundColor3 = T.bg, BackgroundTransparency = 0.1, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 0), Size = UDim2.fromOffset(ICON + 6, 22), Parent = btn })
		new("UICorner", { CornerRadius = UDim.new(0, 6), Parent = timer })
		local sc = new("UIScale", { Parent = disc })
		local e = { id = id, btn = btn, timer = timer, ends = os.clock(), name = name, desc = desc, color = color }
		btn.MouseEnter:Connect(function()
			hovering = e
			UI.tween(sc, 0.15, { Scale = 1.1 }, Enum.EasingStyle.Back)
			showTip(e)
		end)
		btn.MouseLeave:Connect(function()
			if hovering == e then
				hovering = nil
			end
			UI.tween(sc, 0.12, { Scale = 1 })
			if pinned ~= e then
				showTip(pinned)
			end
		end)
		btn.Activated:Connect(function()
			if pinned == e then
				pinned = nil
				showTip(hovering)
			else
				pinned = e
				showTip(e)
				if Fx then
					Fx.sound("Click")
				end
				-- a tapped card goes away by itself on phones (no mouse to leave)
				task.delay(5, function()
					if pinned == e then
						pinned = nil
						showTip(hovering)
					end
				end)
			end
		end)
		entries[id] = e
		return e
	end

	local function removeEntry(id: string)
		local e = entries[id]
		if not e then
			return
		end
		entries[id] = nil
		if pinned == e then
			pinned = nil
		end
		if hovering == e then
			hovering = nil
		end
		if shownTip == e then
			showTip(pinned)
		end
		e.btn:Destroy()
	end

	-- wanted = { { id, name, desc, icon, color, left } }; prefix keeps world events and boosts apart
	local function sync(prefix: string, wanted: { any }, order: number)
		local live = {}
		for i, w in ipairs(wanted) do
			local id = prefix .. tostring(w.id)
			live[id] = true
			local e = entries[id] or makeEntry(id, tostring(w.name), tostring(w.desc or ""), w.icon or "gift", typeof(w.color) == "Color3" and w.color or T.accent, order + i)
			e.ends = os.clock() + (tonumber(w.left) or 0)
		end
		for id in pairs(entries) do
			if id:sub(1, #prefix) == prefix and not live[id] then
				removeEntry(id)
			end
		end
	end

	local seen: { [string]: boolean } = {}
	Net.onState(function(st)
		if not st then
			return
		end
		local luck = st.luck or 1
		luckChip.Text = string.format("LUCK x%.2f", luck)
		luckChip.Visible = luck > 1.004
		local wanted = {}
		local live = {}
		for _, ev in ipairs(st.events or {}) do
			local def = EventsDef.byId[ev.id]
			if def then
				live[ev.id] = true
				table.insert(wanted, { id = ev.id, name = def.name, desc = def.desc, icon = EVENT_ICON[ev.id] or "bolt", color = def.color, left = ev.left })
				if not seen[ev.id] and Fx then
					seen[ev.id] = true
					Fx.sound("Cheer")
					Fx.banner(def.name, def.color, def.desc)
					Fx.rain(50)
				end
			end
		end
		for id in pairs(seen) do
			if not live[id] then
				seen[id] = nil
			end
		end
		sync("ev:", wanted, 0)
	end)

	-- personal boosts from the admin (luck boost, timed passes)
	task.spawn(function()
		local fxRemote = RS:WaitForChild("AdminFx", 60) :: RemoteEvent?
		if fxRemote then
			fxRemote.OnClientEvent:Connect(function(kind: string, data)
				if kind == "boosts" and type(data) == "table" then
					sync("me:", data, 100)
				end
			end)
		end
		-- ask once for boosts that were sent before this listener existed
		local rf = RS:WaitForChild("AdminPanel", 60) :: RemoteFunction?
		if rf then
			for _ = 1, 10 do
				if Net.state and Net.state.company then
					break
				end
				task.wait(3)
			end
			local ok, list = pcall(function()
				return (rf :: RemoteFunction):InvokeServer("__myBoosts")
			end)
			if ok and type(list) == "table" then
				sync("me:", list, 100)
			end
		end
	end)

	task.spawn(function()
		local wasPhone = UI.phone
		while true do
			task.wait(0.5)
			if UI.phone ~= wasPhone then
				wasPhone = UI.phone
				layoutIcons(wasPhone)
			end
			for id, e in pairs(entries) do
				local l = left(e)
				e.timer.Text = clock(l)
				if l <= 0 then
					removeEntry(id)
				end
			end
			if shownTip then
				tipLeft.Text = "Ends in " .. clock(left(shownTip))
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
