--!strict
-- Title screen: night city, big logo, 3 save slots (PLAY / NEW COMPANY), delete with confirm.
-- Same look as the rest of the game: navy stud panels, square corners, pixel titles, bold buttons.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS:WaitForChild("Shared")
local Config = require(Shared.Config)
local Format = require(Shared.Format)
local UI = require(script.Parent.UI)
local Net = require(script.Parent.Net)
local T = UI.T
local new = UI.new

local Title = {}

local NAVY = Color3.fromRGB(14, 18, 40)
local SLOT_COLORS = { Color3.fromRGB(0, 200, 255), Color3.fromRGB(255, 80, 170), Color3.fromRGB(255, 175, 0) }

local function confirmBox(parent: Instance, text: string, yesText: string, onYes: () -> ())
	local overlay = new("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.4, Size = UDim2.fromScale(1, 1), Parent = parent })
	local d = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(620, 260), Parent = overlay })
	UI.skin(d, T.bg)
	local bar = new("Frame", { BackgroundColor3 = T.red, Size = UDim2.new(1, 0, 0, 54), Parent = d })
	new("TextLabel", { Text = "ARE YOU SURE?", FontFace = UI.HEAVY, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = bar })
	new("TextLabel", { Text = text, TextSize = 18, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(30, 72), Size = UDim2.new(1, -60, 0, 80), Parent = d })
	local row = new("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -22), Size = UDim2.new(1, -60, 0, 58), Parent = d })
	UI.list(row, 16, true, Enum.HorizontalAlignment.Center)
	UI.button(row, "KEEP IT", function()
		overlay:Destroy()
	end, T.green, { Size = UDim2.fromOffset(250, 56), TextSize = 16 })
	UI.button(row, yesText, function()
		overlay:Destroy()
		onYes()
	end, T.red, { Size = UDim2.fromOffset(250, 56), TextSize = 16 })
	for _, c in ipairs(overlay:GetDescendants()) do
		if c:IsA("GuiObject") then
			c.ZIndex = 260
		end
	end
	overlay.ZIndex = 259
end

function Title.show(gui: ScreenGui, onPlay: () -> ())
	local o = new("Frame", { Name = "Title", BackgroundColor3 = NAVY, Size = UDim2.fromScale(1, 1), ClipsDescendants = true, ZIndex = 200, Parent = gui })
	local Assets = require(RS.Shared.Assets)

	-- night city: the bright city art tinted deep blue, slowly drifting
	local bg = new("ImageLabel", { Name = "Bg", BackgroundTransparency = 1, Image = Assets.titleBg, ImageColor3 = Color3.fromRGB(70, 90, 170), ScaleType = Enum.ScaleType.Crop, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1.08, 1.08), Parent = o })
	local shade = new("Frame", { Name = "Shade", BackgroundColor3 = NAVY, Size = UDim2.fromScale(1, 1), Parent = o })
	new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.05), NumberSequenceKeypoint.new(0.45, 0.55), NumberSequenceKeypoint.new(0.75, 0.75), NumberSequenceKeypoint.new(1, 0.2) }), Parent = shade })
	-- twinkling stars in the sky
	local stars = {}
	local rnd = Random.new(11)
	for _ = 1, 40 do
		local s = rnd:NextInteger(2, 5)
		local st = new("Frame", { BackgroundColor3 = Color3.fromRGB(255, 245, 200), BackgroundTransparency = rnd:NextNumber(0, 0.6), Position = UDim2.fromScale(rnd:NextNumber(0, 1), rnd:NextNumber(0, 0.4)), Size = UDim2.fromOffset(s, s), Parent = o })
		table.insert(stars, st)
	end

	-- logo
	local logoHolder = new("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 56), Size = UDim2.fromOffset(1100, 190), Parent = o })
	local glow = new("TextLabel", { Text = Config.GAME_TITLE, FontFace = UI.HEAVY, TextSize = 120, TextColor3 = Color3.fromRGB(255, 120, 0), TextTransparency = 0.35, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(6, 8), Size = UDim2.new(1, 0, 0, 130), Parent = logoHolder })
	local logo = new("TextLabel", { Text = Config.GAME_TITLE, FontFace = UI.HEAVY, TextSize = 120, TextColor3 = Color3.fromRGB(255, 214, 30), TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 130), Parent = logoHolder })
	new("UIStroke", { Color = Color3.fromRGB(10, 12, 30), Thickness = 7, ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual, Parent = logo })
	new("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(255, 240, 120), Color3.fromRGB(255, 160, 0)), Parent = logo })
	local _ = glow
	local tag = new("TextLabel", { Text = "AI COMPANY TYCOON", FontFace = UI.HEAVY, TextSize = 22, TextColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(0, 170, 255), TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 136), Size = UDim2.fromOffset(470, 46), Rotation = -2, Parent = logoHolder })
	new("UIStroke", { Color = Color3.fromRGB(10, 12, 30), Thickness = 4, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = tag })
	new("TextLabel", { Text = "FROM ONE LAPTOP IN 2023 TO THE BIGGEST COMPANY ON EARTH", FontFace = UI.BOLD, TextSize = 15, TextColor3 = Color3.fromRGB(190, 210, 255), TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 262), Size = UDim2.fromOffset(1100, 24), Parent = o })

	local row = new("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 312), Size = UDim2.fromOffset(1140, 390), Parent = o })
	UI.list(row, 28, true, Enum.HorizontalAlignment.Center)
	local status = new("TextLabel", { Text = "LOADING YOUR COMPANIES...", FontFace = UI.BOLD, TextSize = 13, TextColor3 = Color3.fromRGB(190, 210, 255), BackgroundTransparency = 0.15, BackgroundColor3 = NAVY, TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -24), Size = UDim2.fromOffset(620, 40), Parent = o })
	new("UIStroke", { Color = Color3.fromRGB(10, 12, 30), Thickness = 3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = status })

	-- animation: bob the logo, drift the city, twinkle the stars
	task.spawn(function()
		local t0 = os.clock()
		while o.Parent do
			local t = os.clock() - t0
			logoHolder.Position = UDim2.new(0.5, 0, 0, 56 + math.sin(t * 1.6) * 6)
			tag.Rotation = -2 + math.sin(t * 2.2) * 1.2
			bg.Position = UDim2.new(0.5, math.sin(t * 0.08) * 40, 0.5, 0)
			for i, st in ipairs(stars) do
				st.BackgroundTransparency = 0.25 + 0.55 * (0.5 + 0.5 * math.sin(t * (1 + i % 5 * 0.4) + i))
			end
			task.wait(1 / 30)
		end
	end)

	local function newCompanyDialog(slot)
		local overlay = new("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.35, Size = UDim2.fromScale(1, 1), ZIndex = 230, Parent = o })
		local d = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.fromOffset(900, 640), ZIndex = 231, Parent = overlay })
		UI.skin(d, T.bg)
		local bar = new("Frame", { BackgroundColor3 = SLOT_COLORS[slot] or T.accent, Size = UDim2.new(1, 0, 0, 60), ZIndex = 232, Parent = d })
		new("TextLabel", { Text = "NEW COMPANY", FontFace = UI.HEAVY, TextSize = 24, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), ZIndex = 233, Parent = bar })
		local body = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(28, 76), Size = UDim2.new(1, -56, 1, -96), ZIndex = 232, Parent = d })
		UI.list(body, 12)
		UI.label(body, "COMPANY NAME", 13, T.sub, { FontFace = UI.BOLD })
		local box = new("TextBox", { Text = "", PlaceholderText = "e.g. Nomad AI", PlaceholderColor3 = T.dim, ClearTextOnFocus = false, BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(20, 24, 44), TextColor3 = T.text, Size = UDim2.new(1, 0, 0, 52), TextSize = 22, Parent = body })
		UI.corner(box, 2)
		UI.stroke(box, Color3.fromRGB(10, 12, 30), 3)
		UI.pad(box, 0, 16)
		UI.label(body, "WHERE DO YOU START?", 13, T.sub, { FontFace = UI.BOLD })
		local grid = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = body })
		new("UIGridLayout", { CellSize = UDim2.new(1 / 3, -8, 0, 112), CellPadding = UDim2.fromOffset(12, 12), Parent = grid })
		local chosen = Config.LOCATIONS[1].id
		local cards = {}
		local function paint()
			for id, c in pairs(cards) do
				local on = id == chosen
				c.BackgroundColor3 = on and Color3.fromRGB(0, 150, 220) or T.panel2
				local st = c:FindFirstChildOfClass("UIStroke")
				if st then
					st.Color = on and Color3.fromRGB(255, 214, 30) or Color3.fromRGB(10, 12, 30)
					st.Thickness = on and 4 or 3
				end
			end
		end
		for _, l in ipairs(Config.LOCATIONS) do
			local b = new("TextButton", { Text = "", BackgroundColor3 = T.panel2, Parent = grid })
			UI.corner(b, 2)
			UI.stroke(b, Color3.fromRGB(10, 12, 30), 3)
			new("TextLabel", { Text = l.city:upper(), FontFace = UI.BOLD, TextSize = 14, TextColor3 = Color3.fromRGB(255, 214, 30), Position = UDim2.fromOffset(12, 10), Size = UDim2.new(1, -24, 0, 18), Parent = b })
			new("TextLabel", { Text = l.desc, TextSize = 13, TextColor3 = Color3.fromRGB(215, 225, 250), Position = UDim2.fromOffset(12, 34), Size = UDim2.new(1, -24, 0, 70), TextYAlignment = Enum.TextYAlignment.Top, Parent = b })
			cards[l.id] = b
			b.MouseButton1Click:Connect(function()
				chosen = l.id
				paint()
			end)
		end
		paint()
		UI.label(body, "You start with $150K and a gaming laptop. The bank will lend you a bit more.", 15, T.yellow)
		local btns = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 62), Parent = body })
		UI.list(btns, 14, true)
		UI.button(btns, "BACK", function()
			overlay:Destroy()
		end, "ghost", { Size = UDim2.fromOffset(180, 60), TextSize = 16 })
		UI.button(btns, "START COMPANY", function()
			status.Text = "SETTING UP..."
			local res = Net.slots("play", slot, box.Text, chosen)
			if res and res.ok then
				o:Destroy()
				onPlay()
			end
		end, T.green, { Size = UDim2.fromOffset(420, 60), TextSize = 20 })
		for _, c in ipairs(overlay:GetDescendants()) do
			if c:IsA("GuiObject") then
				c.ZIndex = math.max(c.ZIndex, 232)
			end
		end
	end

	local function slotCard(slot: number, info: any?, order: number)
		local color = SLOT_COLORS[slot] or T.accent
		local f = new("Frame", { Size = UDim2.fromOffset(350, 380), LayoutOrder = order, Parent = row })
		UI.skin(f, T.bg)
		local bar = new("Frame", { BackgroundColor3 = color, Size = UDim2.new(1, 0, 0, 50), Parent = f })
		new("UIGradient", { Rotation = 90, Color = ColorSequence.new(color:Lerp(Color3.new(1, 1, 1), 0.2), color:Lerp(Color3.new(0, 0, 0), 0.2)), Parent = bar })
		new("TextLabel", { Text = "SLOT " .. slot, FontFace = UI.HEAVY, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = bar })
		local ic = UI.icon(f, info and "company" or "lab", color, 96)
		ic.AnchorPoint = Vector2.new(0.5, 0)
		ic.Position = UDim2.new(0.5, 0, 0, 66)
		if info then
			new("TextLabel", { Text = tostring(info.company):upper(), FontFace = UI.HEAVY, TextSize = 20, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd, TextWrapped = false, Position = UDim2.fromOffset(14, 176), Size = UDim2.new(1, -28, 0, 26), Parent = f })
			new("TextLabel", { Text = tostring(info.date or "") .. "   |   " .. tostring(info.stage or ""), TextSize = 15, TextColor3 = T.sub, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(14, 208), Size = UDim2.new(1, -28, 0, 40), TextYAlignment = Enum.TextYAlignment.Top, Parent = f })
			new("TextLabel", { Text = "WORTH " .. Format.money(info.valuation or 0), FontFace = UI.BOLD, TextSize = 17, TextColor3 = Color3.fromRGB(0, 230, 120), TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(14, 254), Size = UDim2.new(1, -28, 0, 24), Parent = f })
			UI.button(f, "PLAY", function()
				status.Text = "LOADING " .. tostring(info.company):upper() .. "..."
				local r = Net.slots("play", slot)
				if r and r.ok then
					o:Destroy()
					onPlay()
				end
			end, T.green, { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 16, 1, -16), Size = UDim2.new(1, -96, 0, 62), TextSize = 24 })
			UI.button(f, "X", function()
				confirmBox(o, "Delete " .. tostring(info.company) .. " forever? Worth " .. Format.money(info.valuation or 0) .. ". This can not be undone.", "DELETE", function()
					Net.slots("delete", slot)
					o:Destroy()
					Title.show(gui, onPlay)
				end)
			end, T.red, { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -16), Size = UDim2.fromOffset(62, 62), TextSize = 20 })
		else
			new("TextLabel", { Text = "EMPTY SLOT", FontFace = UI.HEAVY, TextSize = 20, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(14, 176), Size = UDim2.new(1, -28, 0, 26), Parent = f })
			new("TextLabel", { Text = "One laptop. $150K. A big dream.", TextSize = 16, TextColor3 = T.sub, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(14, 212), Size = UDim2.new(1, -28, 0, 40), Parent = f })
			UI.button(f, "+ NEW COMPANY", function()
				newCompanyDialog(slot)
			end, color, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -16), Size = UDim2.new(1, -32, 0, 62), TextSize = 18 })
		end
		-- slide in from below
		local sc = new("UIScale", { Scale = 0.85, Parent = f })
		f.BackgroundTransparency = 0
		task.delay(0.08 * order, function()
			UI.tween(sc, 0.35, { Scale = 1 }, Enum.EasingStyle.Back)
		end)
	end

	task.spawn(function()
		local res = Net.slots("list")
		local slots = res and res.slots or {}
		status.Text = res and (res.persistent and "YOUR COMPANIES SAVE AUTOMATICALLY" or "SAVING IS OFF IN THIS TEST SESSION") or "COULD NOT REACH THE SERVER"
		for slot = 1, 3 do
			slotCard(slot, slots[tostring(slot)] or slots[slot], slot)
		end
	end)
end

return Title
