--!strict
-- Tiny UI kit: theme + builders. Modern dark glass look. No emoji anywhere: icons are drawn.
local TweenService = game:GetService("TweenService")
local Assets = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Assets"))
local UI = {}

-- Blocky retro OS look (Roblox style): navy panels, cyan/green chunky buttons, pixel font.
-- Bright cartoon theme: white/sky panels, saturated blue/green/yellow/red, thick dark outlines.
UI.T = {
	bg = Color3.fromRGB(30, 35, 62),
	panel = Color3.fromRGB(38, 46, 84),
	panel2 = Color3.fromRGB(50, 60, 104),
	line = Color3.fromRGB(12, 14, 28),
	text = Color3.fromRGB(236, 241, 255),
	sub = Color3.fromRGB(160, 176, 220),
	dim = Color3.fromRGB(105, 118, 160),
	accent = Color3.fromRGB(0, 200, 255),
	green = Color3.fromRGB(0, 215, 105),
	red = Color3.fromRGB(255, 70, 85),
	yellow = Color3.fromRGB(255, 196, 30),
	purple = Color3.fromRGB(150, 90, 255),
	orange = Color3.fromRGB(255, 140, 40),
	teal = Color3.fromRGB(0, 190, 200),
	pink = Color3.fromRGB(255, 90, 170),
}
-- pack icons (show once the place is published; drawn icons are the fallback)
UI.ICON_IMAGES = {
	lab = 71458718634620, parts = 132000942692847, team = 138393293744051, bank = 132123388448433,
	social = 84020529846826, mail = 71078899575319, goals = 77359789350483, company = 100186608972356,
}
-- POP = the Figma look (design/shop_v2.png): purple panels, gold, coloured borders,
-- chunky Fredoka titles with dark outlines, 3D buttons with a lip, sticker icons.
UI.POP = true
if UI.POP then
	UI.T = {
		bg = Color3.fromRGB(28, 17, 74),
		panel = Color3.fromRGB(70, 38, 168),
		panel2 = Color3.fromRGB(51, 34, 138),
		line = Color3.fromRGB(26, 15, 58),
		text = Color3.fromRGB(255, 255, 255),
		sub = Color3.fromRGB(222, 210, 255),
		dim = Color3.fromRGB(172, 154, 232),
		accent = Color3.fromRGB(61, 123, 255),
		green = Color3.fromRGB(31, 203, 114),
		red = Color3.fromRGB(255, 58, 92),
		yellow = Color3.fromRGB(255, 194, 26),
		purple = Color3.fromRGB(139, 92, 255),
		orange = Color3.fromRGB(255, 122, 26),
		teal = Color3.fromRGB(18, 184, 214),
		pink = Color3.fromRGB(255, 79, 166),
		gold = Color3.fromRGB(255, 194, 26),
	}
end
local T = UI.T
-- Chunky and readable: rounded blocky font for text, pixel font for titles/buttons.
-- GLASS = the new modern look: dark see-through glass panels, soft light edges, rounded
-- corners, clean sans font. false = the old blocky pixel look.
UI.GLASS = false
-- the clean sans font stays either way (the pixel font was hard to read)
UI.CLEAN_FONT = true
local BUILDER = "rbxasset://fonts/families/BuilderSans.json"
local SIZE_MULT
if UI.CLEAN_FONT then
	UI.FONT = Font.new(BUILDER, UI.POP and Enum.FontWeight.Bold or Enum.FontWeight.Medium)
	UI.BOLD = Font.new(BUILDER, Enum.FontWeight.Bold)
	UI.HEAVY = Font.new(BUILDER, Enum.FontWeight.ExtraBold)
	UI.MONO = Font.new(BUILDER, Enum.FontWeight.Medium)
	SIZE_MULT = { [BUILDER] = 1.2 }
	if UI.POP then
		-- titles and buttons: round chunky cartoon font
		local FRED = "rbxasset://fonts/families/FredokaOne.json"
		UI.BOLD = Font.new(FRED)
		UI.HEAVY = Font.new(FRED)
		SIZE_MULT[FRED] = 1.15
	end
else
	UI.FONT = Font.fromEnum(Enum.Font.FredokaOne)
	UI.BOLD = Font.new("rbxasset://fonts/families/PressStart2P.json")
	UI.HEAVY = Font.new("rbxasset://fonts/families/PressStart2P.json")
	UI.MONO = Font.fromEnum(Enum.Font.FredokaOne)
	-- normalise sizes so callers can keep "normal" sizes (everything a bit bigger than default)
	SIZE_MULT = { [UI.FONT.Family] = 1.25, ["rbxasset://fonts/families/PressStart2P.json"] = 0.8 }
end

function UI.new(class: string, props: { [string]: any }?, children: { Instance }?): any
	-- glass look everywhere: the old thick black outlines become thin light rims and the
	-- square corners get rounded, even where screens build them by hand
	if UI.GLASS and props then
		if class == "UIStroke" and props.Color == UI.T.line then
			local contextual = props.ApplyStrokeMode == Enum.ApplyStrokeMode.Contextual
			props = table.clone(props)
			if contextual then
				props.Transparency = math.max(props.Transparency or 0, 0.35)
				props.Thickness = math.min(props.Thickness or 1, 1.5)
			else
				props.Color = Color3.new(1, 1, 1)
				props.Transparency = 0.8
				props.Thickness = math.min(props.Thickness or 1, 1.5)
			end
		elseif class == "UICorner" and props.CornerRadius and props.CornerRadius.Scale == 0 and props.CornerRadius.Offset <= 4 then
			props = table.clone(props)
			props.CornerRadius = UDim.new(0, 12)
		end
	end
	local inst = Instance.new(class)
	if class == "Frame" or class == "ScrollingFrame" or class == "TextButton" or class == "TextLabel" or class == "TextBox" or class == "ImageLabel" or class == "ImageButton" then
		(inst :: any).BorderSizePixel = 0
	end
	if class == "TextLabel" or class == "TextButton" or class == "TextBox" then
		local t = inst :: any
		t.FontFace = UI.FONT
		t.TextColor3 = T.text
		t.BackgroundTransparency = 1
		t.TextSize = 16
		t.TextXAlignment = Enum.TextXAlignment.Left
		t.TextWrapped = true
		if class == "TextButton" then
			t.AutoButtonColor = false
		end
		-- a label/button given a background colour should actually show it
		if props and props.BackgroundColor3 ~= nil and props.BackgroundTransparency == nil then
			t.BackgroundTransparency = 0
		end
	end
	for k, v in pairs(props or {}) do
		if k ~= "Parent" then
			(inst :: any)[k] = v
		end
	end
	if class == "TextLabel" or class == "TextButton" or class == "TextBox" then
		local t = inst :: any
		local mult = SIZE_MULT[t.FontFace.Family]
		if mult then
			t.TextSize = math.floor(t.TextSize * mult + 0.5)
		end
	end
	if UI.POP and (class == "TextLabel" or class == "TextButton") then
		UI.popText(inst)
	end
	for _, c in ipairs(children or {}) do
		c.Parent = inst
	end
	if props and props.Parent then
		inst.Parent = props.Parent
	end
	return inst
end
local new = UI.new

-- chunky titles get a dark outline like every big Roblox game; a caller's own text stroke wins
function UI.popText(t: any)
	if t.FontFace.Family ~= UI.HEAVY.Family or t.TextSize < 14 or t:FindFirstChild("PopStroke") then
		return
	end
	local st = Instance.new("UIStroke")
	st.Name = "PopStroke"
	st.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	st.Color = T.line
	st.Thickness = math.clamp(t.TextSize / 11, 1.5, 4)
	st.LineJoinMode = Enum.LineJoinMode.Round
	st.Parent = t
	t.ChildAdded:Connect(function(c)
		if c ~= st and c:IsA("UIStroke") and c.ApplyStrokeMode == Enum.ApplyStrokeMode.Contextual then
			st:Destroy()
		end
	end)
end

function UI.corner(parent: Instance, r: number?)
	-- blocky look: almost square corners (round things like avatars keep big radii)
	local rr = r or 10
	if UI.POP then
		if rr < 40 then
			rr = math.clamp(rr, 10, 18)
		end
	elseif rr < 40 then
		rr = math.min(rr, 2)
	end
	return new("UICorner", { CornerRadius = UDim.new(0, rr), Parent = parent })
end
function UI.stroke(parent: Instance, color: Color3?, thick: number?, transp: number?)
	return new("UIStroke", { Color = color or T.line, Thickness = thick or 1, Transparency = transp or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = parent })
end
function UI.pad(parent: Instance, a: number, b: number?, c: number?, d: number?)
	return new("UIPadding", { PaddingTop = UDim.new(0, a), PaddingBottom = UDim.new(0, c or a), PaddingLeft = UDim.new(0, b or a), PaddingRight = UDim.new(0, d or b or a), Parent = parent })
end
function UI.list(parent: Instance, gap: number?, horizontal: boolean?, align: any?)
	-- a list layout would treat the stud texture as an item, so lists live without it
	local studs = parent:FindFirstChild("Studs")
	if studs then
		studs:Destroy()
	end
	return new("UIListLayout", {
		Padding = UDim.new(0, gap or 8),
		FillDirection = horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
		Parent = parent,
	})
end
function UI.grad(parent: Instance, a: Color3, b: Color3, rot: number?)
	-- gradients multiply with the background colour, so make the base white
	if parent:IsA("GuiObject") and not parent:IsA("TextLabel") then
		(parent :: any).BackgroundColor3 = Color3.new(1, 1, 1)
	end
	return new("UIGradient", { Color = ColorSequence.new(a, b), Rotation = rot or 90, Parent = parent })
end

function UI.label(parent: Instance, text: string, size: number?, color: Color3?, props: { [string]: any }?)
	local l = new("TextLabel", { Text = text, TextSize = size or 16, TextColor3 = color or T.text, Size = UDim2.new(1, 0, 0, (size or 16) + 6), AutomaticSize = Enum.AutomaticSize.Y, Parent = parent })
	for k, v in pairs(props or {}) do
		(l :: any)[k] = v
	end
	if props and props.FontFace then
		local mult = SIZE_MULT[props.FontFace.Family]
		l.TextSize = math.floor((size or 16) * (mult or 1) + 0.5)
	end
	-- Roblox sometimes measures AutomaticSize before the label knows its width and keeps
	-- one line, cutting long text: size the height from the real text bounds instead
	if l.TextWrapped and l.AutomaticSize == Enum.AutomaticSize.Y and l.Size.Y.Scale == 0 then
		l.AutomaticSize = Enum.AutomaticSize.None
		local minH = l.Size.Y.Offset
		local function fit()
			local h = math.max(minH, math.ceil(l.TextBounds.Y) + 4)
			if l.Size.Y.Offset ~= h then
				l.Size = UDim2.new(l.Size.X.Scale, l.Size.X.Offset, 0, h)
			end
		end
		l:GetPropertyChangedSignal("TextBounds"):Connect(fit)
		fit()
	end
	return l
end

-- Square navy panel with a thick outline and the Roblox stud texture behind its children.
-- (Only use on frames with a fixed size; AutomaticSize frames get a plain fill.)
function UI.skin(frame: GuiObject, color: Color3?)
	frame.BackgroundTransparency = 0
	frame.BackgroundColor3 = color or T.panel
	for _, c in ipairs(frame:GetChildren()) do
		if c:IsA("UIStroke") or c:IsA("UICorner") then
			c:Destroy()
		end
	end
	if UI.GLASS then
		-- frosted glass: see-through tint, light top fading down, thin bright rim
		frame.BackgroundColor3 = (color or T.panel):Lerp(Color3.fromRGB(10, 14, 30), 0.35)
		frame.BackgroundTransparency = 0.06
		new("UICorner", { CornerRadius = UDim.new(0, 16), Parent = frame })
		new("UIStroke", { Color = Color3.new(1, 1, 1), Transparency = 0.78, Thickness = 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = frame })
		local g = frame:FindFirstChild("GlassSheen") or new("UIGradient", { Name = "GlassSheen", Parent = frame })
		g.Rotation = 90
		g.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(150, 160, 190))
		return frame
	end
	if UI.POP then
		-- soft round panel, dark outline, light top fading darker (gradient multiplies the colour)
		new("UICorner", { CornerRadius = UDim.new(0, 16), Parent = frame })
		new("UIStroke", { Color = T.line, Thickness = 3.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = frame })
		local g = frame:FindFirstChild("PopShade") or new("UIGradient", { Name = "PopShade", Parent = frame })
		g.Rotation = 90
		g.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(196, 190, 220))
		return frame
	end
	new("UICorner", { CornerRadius = UDim.new(0, 2), Parent = frame })
	new("UIStroke", { Color = T.line, Thickness = 3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = frame })
	if frame.AutomaticSize == Enum.AutomaticSize.None then
		new("ImageLabel", { Name = "Studs", BackgroundTransparency = 1, Image = Assets.studs, ImageTransparency = 0.45, ScaleType = Enum.ScaleType.Tile, TileSize = UDim2.fromOffset(36, 36), Size = UDim2.fromScale(1, 1), ZIndex = 0, Parent = frame })
	end
	return frame
end

function UI.card(parent: Instance, props: { [string]: any }?)
	local f = new("Frame", { BackgroundColor3 = T.panel2, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = parent })
	UI.pad(f, 14, 16)
	UI.skin(f, T.panel2)
	for k, v in pairs(props or {}) do
		(f :: any)[k] = v
	end
	return f
end

UI.GHOST = Color3.fromRGB(150, 170, 205)
UI.guardUntil = 0
-- set by Main: plays a sound by name (clicks, hovers)
UI.sound = nil :: ((string, number?) -> ())?
-- kind: "primary" | "ghost" | "danger" | "success" | color
-- Roblox simulator style: rounded, tall, gradient, thick outline, white outlined text.
function UI.button(parent: Instance, text: string, onClick: (() -> ())?, kind: any?, props: { [string]: any }?)
	local color = T.accent
	if kind == "ghost" then
		color = UI.GHOST
	elseif kind == "danger" then
		color = T.red
	elseif kind == "success" then
		color = T.green
	elseif typeof(kind) == "Color3" then
		color = kind
	end
	local b = new("TextButton", {
		Text = text,
		FontFace = UI.BOLD,
		TextSize = 18,
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextWrapped = false,
		TextTruncate = Enum.TextTruncate.AtEnd,
		BackgroundTransparency = 0,
		BackgroundColor3 = color,
		Size = UDim2.new(0, math.max(110, #text * 10 + 40), 0, 46),
		Parent = parent,
	})
	if UI.GLASS then
		-- glass pill: coloured glass with a light top, a thin bright rim and a soft glow edge
		new("UICorner", { CornerRadius = UDim.new(0, 14), Parent = b })
		new("UIStroke", { Color = Color3.new(1, 1, 1), Transparency = 0.6, Thickness = 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = b })
		new("UIGradient", { Name = "GlassSheen", Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(185, 190, 210)), Parent = b })
		b.BackgroundTransparency = 0.12
		b.FontFace = UI.BOLD
	elseif UI.POP then
		-- 3D cartoon button: rounded, border in a dark shade of its own colour, light top,
		-- a darker lip along the bottom, outlined white text
		local edge = color:Lerp(Color3.fromRGB(20, 8, 40), 0.62)
		new("UICorner", { CornerRadius = UDim.new(0, 14), Parent = b })
		new("UIStroke", { Name = "Edge", Color = edge, Thickness = 3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = b })
		new("UIStroke", { Name = "PopStroke", Color = edge, Thickness = 2.2, LineJoinMode = Enum.LineJoinMode.Round, ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual, Parent = b })
		new("UIGradient", { Name = "PopShade", Rotation = 90, Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(0.85, Color3.fromRGB(215, 215, 215)), ColorSequenceKeypoint.new(0.86, Color3.fromRGB(150, 150, 150)), ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150)) }), Parent = b })
		local shine = new("Frame", { Name = "Shine", BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.6, Position = UDim2.new(0, 8, 0, 4), Size = UDim2.new(1, -16, 0, 4), ZIndex = b.ZIndex, Parent = b })
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = shine })
		b:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
			local e = b.BackgroundColor3:Lerp(Color3.fromRGB(20, 8, 40), 0.62)
			for _, st in ipairs(b:GetChildren()) do
				if st:IsA("UIStroke") and (st.Name == "Edge" or st.Name == "PopStroke") then
					st.Color = e
				end
			end
		end)
	else
		new("UICorner", { CornerRadius = UDim.new(0, 2), Parent = b })
		new("UIStroke", { Color = Color3.fromRGB(10, 12, 24), Thickness = 3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = b })
		local textStroke = new("UIStroke", { Color = color:Lerp(Color3.new(0, 0, 0), 0.6), Thickness = 1.2, ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual, Parent = b })
		textStroke.Enabled = false
		new("Frame", { Name = "Shade", BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.7, Size = UDim2.new(1, 0, 0, 5), Position = UDim2.new(0, 0, 1, -5), Parent = b })
		new("Frame", { Name = "Shine", BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.55, Size = UDim2.new(1, 0, 0, 3), Parent = b })
	end
	local busy = false
	local applied: Color3? = nil
	local function setColor(c)
		busy = true
		local ghost = c == UI.GHOST or c == Color3.fromRGB(150, 170, 205)
		if ghost then
			applied = UI.POP and Color3.fromRGB(110, 78, 210) or UI.GLASS and Color3.fromRGB(70, 82, 125) or Color3.fromRGB(58, 70, 120)
			b.BackgroundColor3 = applied
			b.TextColor3 = UI.POP and Color3.new(1, 1, 1) or Color3.fromRGB(220, 228, 255)
		else
			applied = c
			b.BackgroundColor3 = c
			b.TextColor3 = Color3.new(1, 1, 1)
		end
		busy = false
	end
	setColor(color)
	b.MouseEnter:Connect(function()
		if color ~= UI.GHOST then
			setColor(color:Lerp(Color3.new(1, 1, 1), 0.12))
		end
		if UI.sound then
			UI.sound("Hover", 1.1)
		end
		local hs = b:FindFirstChild("HoverScale") or new("UIScale", { Name = "HoverScale", Parent = b })
		if not b:FindFirstChildOfClass("UIScale") or b:FindFirstChildOfClass("UIScale") == hs then
			TweenService:Create(hs, TweenInfo.new(0.15, Enum.EasingStyle.Back), { Scale = 1.04 }):Play()
		end
	end)
	b.MouseLeave:Connect(function()
		setColor(color)
		local hs = b:FindFirstChild("HoverScale")
		if hs then
			TweenService:Create(hs, TweenInfo.new(0.12), { Scale = 1 }):Play()
		end
	end)
	local born = os.clock()
	b.MouseButton1Click:Connect(function()
		-- ignore the mouse-up of the click that just opened this screen (or rebuilt it)
		if os.clock() - born < 0.25 or os.clock() < UI.guardUntil then
			return
		end
		if UI.sound then
			UI.sound("Click", 0.95 + math.random() * 0.1)
		end
		local sc = b:FindFirstChildOfClass("UIScale") or new("UIScale", { Parent = b })
		sc.Scale = 0.92
		TweenService:Create(sc, TweenInfo.new(0.22, Enum.EasingStyle.Back), { Scale = 1 }):Play()
		if onClick then
			onClick()
		end
	end)
	for k, v in pairs(props or {}) do
		if k == "BackgroundColor3" then
			color = v
			setColor(v)
		else
			(b :: any)[k] = v
		end
	end
	-- callers that recolour later via BackgroundColor3 still work
	b:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
		-- signals are deferred: ignore the echo of our own write
		if not busy and b.BackgroundColor3 ~= applied then
			color = b.BackgroundColor3
			setColor(color)
		end
	end)
	return b
end

function UI.scroll(parent: Instance, props: { [string]: any }?)
	local s = new("ScrollingFrame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 5,
		ScrollBarImageColor3 = T.line,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Parent = parent,
	})
	for k, v in pairs(props or {}) do
		(s :: any)[k] = v
	end
	-- Roblox's automatic canvas often stops short (grids with AutomaticSize, padding),
	-- so the last row could not be reached: size the canvas from the layout ourselves
	local function track(layout: Instance)
		if not layout:IsA("UIListLayout") then
			return
		end
		s.AutomaticCanvasSize = Enum.AutomaticSize.None
		local function fit()
			local pad = s:FindFirstChildOfClass("UIPadding")
			local extra = 40
			if pad then
				extra += pad.PaddingTop.Offset + pad.PaddingBottom.Offset
			end
			-- AbsoluteContentSize is in screen pixels; undo every UIScale above us
			local k = 1
			local p: Instance? = s
			while p do
				local u = p:FindFirstChildOfClass("UIScale")
				if u then
					k *= u.Scale
				end
				p = p.Parent
			end
			s.CanvasSize = UDim2.fromOffset(0, (layout :: UIListLayout).AbsoluteContentSize.Y / math.max(k, 0.01) + extra)
		end
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(fit)
		fit()
	end
	s.ChildAdded:Connect(track)
	return s
end

-- Icon: the drawn PNG from our art set (fallback: glyph tile below).
local sheetIndex: { [string]: number } = {}
for i, k in ipairs(Assets.iconOrder or {}) do
	sheetIndex[k] = i - 1
end
function UI.icon(parent: Instance, kind: string, color: Color3, size: number)
	local idx = UI.POP and Assets.iconSheet and sheetIndex[kind]
	if idx then
		local holder = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(size, size), Parent = parent })
		new("ImageLabel", { Name = "Img", BackgroundTransparency = 1, Image = Assets.iconSheet, ImageRectOffset = Vector2.new((idx % 8) * 128, math.floor(idx / 8) * 128), ImageRectSize = Vector2.new(128, 128), Size = UDim2.fromScale(1, 1), Parent = holder })
		return holder
	end
	local v2 = Assets.icons2 and Assets.icons2[kind]
	if v2 and v2 ~= "" then
		local holder = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(size, size), Parent = parent })
		new("ImageLabel", { Name = "Img", BackgroundTransparency = 1, Image = v2, Size = UDim2.fromScale(1, 1), Parent = holder })
		return holder
	end
	if Assets.icons[kind] then
		local holder = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(size, size), Parent = parent })
		new("ImageLabel", { Name = "Img", BackgroundTransparency = 1, Image = Assets.icons[kind], Size = UDim2.fromScale(1, 1), Parent = holder })
		return holder
	end
	return UI.glyphIcon(parent, kind, color, size)
end

function UI.glyphIcon(parent: Instance, kind: string, color: Color3, size: number)
	local tile = new("Frame", { Size = UDim2.fromOffset(size, size), BackgroundColor3 = color, Parent = parent })
	UI.corner(tile, math.floor(size * 0.24))
	UI.grad(tile, color:Lerp(Color3.new(1, 1, 1), 0.18), color:Lerp(Color3.new(0, 0, 0), 0.2), 90)
	local W = Color3.new(1, 1, 1)
	local function bar(x, y, w, h, rot, r)
		local f = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(x, y), Size = UDim2.fromScale(w, h), BackgroundColor3 = W, Rotation = rot or 0, Parent = tile })
		UI.corner(f, r or 3)
		return f
	end
	if kind == "linkedin" then -- "in" letters
		new("TextLabel", { Text = "in", FontFace = Font.fromEnum(Enum.Font.GothamBlack), TextScaled = true, TextColor3 = W, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.52, 0.5), Size = UDim2.fromScale(0.7, 0.62), Parent = tile })
	elseif kind == "cameras" then -- CCTV camera on a pole
		bar(0.46, 0.42, 0.56, 0.26, -15, 4)
		bar(0.2, 0.36, 0.1, 0.12, -15, 2).BackgroundColor3 = Color3.fromRGB(255, 70, 70)
		bar(0.7, 0.66, 0.1, 0.34, 0, 2)
		bar(0.7, 0.84, 0.3, 0.08, 0, 2)
	elseif kind == "lab" then -- flask
		bar(0.5, 0.3, 0.16, 0.3)
		local b = bar(0.5, 0.62, 0.5, 0.36, 0, 8)
		bar(0.5, 0.7, 0.36, 0.12).BackgroundColor3 = color
	elseif kind == "team" then -- two heads
		bar(0.36, 0.38, 0.22, 0.22, 0, 20)
		bar(0.64, 0.38, 0.22, 0.22, 0, 20)
		bar(0.36, 0.68, 0.32, 0.22, 0, 8)
		bar(0.64, 0.68, 0.32, 0.22, 0, 8)
	elseif kind == "parts" then -- chip
		bar(0.5, 0.5, 0.42, 0.42, 0, 4)
		bar(0.5, 0.5, 0.2, 0.2, 0, 2).BackgroundColor3 = color
		for i = 0, 2 do
			bar(0.34 + i * 0.16, 0.2, 0.05, 0.12)
			bar(0.34 + i * 0.16, 0.8, 0.05, 0.12)
		end
	elseif kind == "bank" then -- bars chart
		bar(0.3, 0.62, 0.12, 0.3)
		bar(0.5, 0.52, 0.12, 0.5)
		bar(0.7, 0.42, 0.12, 0.7)
	elseif kind == "mail" then
		bar(0.5, 0.5, 0.6, 0.42, 0, 4)
		bar(0.38, 0.42, 0.34, 0.05, 30).BackgroundColor3 = color
		bar(0.62, 0.42, 0.34, 0.05, -30).BackgroundColor3 = color
	elseif kind == "social" then -- speech bubble
		bar(0.5, 0.45, 0.6, 0.42, 0, 10)
		bar(0.38, 0.68, 0.14, 0.14, 45)
	elseif kind == "goals" then -- target
		bar(0.5, 0.5, 0.6, 0.6, 0, 40)
		bar(0.5, 0.5, 0.4, 0.4, 0, 40).BackgroundColor3 = color
		bar(0.5, 0.5, 0.18, 0.18, 0, 40)
	elseif kind == "app" then -- phone
		bar(0.5, 0.5, 0.36, 0.62, 0, 6)
		bar(0.5, 0.5, 0.26, 0.44, 0, 3).BackgroundColor3 = color
	elseif kind == "company" then -- building
		bar(0.5, 0.56, 0.44, 0.56, 0, 3)
		for r = 0, 2 do
			for c = 0, 1 do
				bar(0.42 + c * 0.16, 0.42 + r * 0.14, 0.08, 0.07, 0, 1).BackgroundColor3 = color
			end
		end
	elseif kind == "news" then
		bar(0.5, 0.5, 0.56, 0.6, 0, 4)
		for i = 0, 2 do
			bar(0.5, 0.36 + i * 0.14, 0.38, 0.05, 0, 1).BackgroundColor3 = color
		end
	else
		bar(0.5, 0.5, 0.4, 0.4, 0, 20)
	end
	-- real pack icon on top; drawn glyph stays visible until (unless) the image loads
	local id = UI.ICON_IMAGES[kind]
	if id then
		local img = new("ImageLabel", { BackgroundTransparency = 1, Image = "rbxassetid://" .. id, Size = UDim2.fromScale(1, 1), ZIndex = tile.ZIndex + 2, Parent = tile })
		task.spawn(function()
			for _ = 1, 20 do
				if img.IsLoaded then
					for _, c in ipairs(tile:GetChildren()) do
						if c:IsA("Frame") then
							c.Visible = false
						end
					end
					return
				end
				task.wait(0.5)
			end
		end)
	end
	return tile
end

function UI.tween(inst: Instance, t: number, props: { [string]: any }, style: Enum.EasingStyle?, dir: Enum.EasingDirection?)
	local tw = TweenService:Create(inst, TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end

-- How much a w x h box (in design units) must shrink to fit inside its ScreenGui
-- (phones are short, so big windows get smaller instead of running off the screen).
function UI.fitFactor(inst: Instance, w: number, h: number, margin: number?): number
	local sg = inst:FindFirstAncestorOfClass("ScreenGui")
	if not sg then
		return 1
	end
	local gs = sg:FindFirstChildOfClass("UIScale")
	local g = gs and gs.Scale or 1
	local m = margin or 24
	local a = sg.AbsoluteSize / g
	return math.clamp(math.min((a.X - m) / w, (a.Y - m) / h), 0.25, 1)
end

-- Keep a fixed size window inside the screen. Uses the frame's own UIScale when it
-- already has one for an intro tween: pass that UIScale as `sc` and tween to the
-- returned function's value instead of 1.
function UI.fit(frame: GuiObject, margin: number?, sc: UIScale?): () -> number
	local scale = sc or frame:FindFirstChild("FitScale") or UI.new("UIScale", { Name = "FitScale", Parent = frame })
	local function factor(): number
		return UI.fitFactor(frame, frame.Size.X.Offset, frame.Size.Y.Offset, margin)
	end
	local function apply()
		if frame.Parent and not sc then
			scale.Scale = factor()
		end
	end
	task.defer(function()
		apply()
		local sg = frame:FindFirstAncestorOfClass("ScreenGui")
		if sg then
			local c = sg:GetPropertyChangedSignal("AbsoluteSize"):Connect(apply)
			frame.Destroying:Connect(function()
				c:Disconnect()
			end)
		end
	end)
	return factor
end

-- true on small touch screens (phones), set by Shell.rescale
UI.phone = false

function UI.clear(parent: Instance)
	for _, c in ipairs(parent:GetChildren()) do
		if not c:IsA("UIListLayout") and not c:IsA("UIPadding") and not c:IsA("UIGridLayout") and not c:IsA("UICorner") and not c:IsA("UIStroke") then
			c:Destroy()
		end
	end
end

-- Horizontal progress bar
function UI.bar(parent: Instance, frac: number, color: Color3?, h: number?)
	local bg = new("Frame", { Size = UDim2.new(1, 0, 0, h or 8), BackgroundColor3 = Color3.fromRGB(205, 218, 238), Parent = parent })
	UI.corner(bg, 4)
	local fill = new("Frame", { Size = UDim2.fromScale(math.clamp(frac, 0, 1), 1), BackgroundColor3 = color or T.accent, Parent = bg })
	UI.corner(fill, 4)
	return bg, fill
end

-- Simple line chart from an array of numbers.
function UI.chart(parent: Instance, values: { number }, color: Color3?, height: number?)
	local box = new("Frame", { Size = UDim2.new(1, 0, 0, height or 120), BackgroundTransparency = 1, ClipsDescendants = true, Parent = parent })
	if #values < 2 then
		UI.label(box, "Not enough data yet", 13, T.dim)
		return box
	end
	local maxV, minV = -math.huge, math.huge
	for _, v in ipairs(values) do
		maxV = math.max(maxV, v)
		minV = math.min(minV, v)
	end
	if maxV == minV then
		maxV += 1
	end
	local n = #values
	for i = 1, n - 1 do
		local x1, y1 = (i - 1) / (n - 1), 1 - (values[i] - minV) / (maxV - minV)
		local x2, y2 = i / (n - 1), 1 - (values[i + 1] - minV) / (maxV - minV)
		local seg = new("Frame", { BackgroundColor3 = color or T.accent, AnchorPoint = Vector2.new(0.5, 0.5), Parent = box })
		-- position computed after layout using absolute size
		local function place()
			local W, H = box.AbsoluteSize.X, box.AbsoluteSize.Y - 6
			local ax, ay, bx, by = x1 * W, y1 * H + 3, x2 * W, y2 * H + 3
			local len = math.sqrt((bx - ax) ^ 2 + (by - ay) ^ 2)
			seg.Size = UDim2.fromOffset(len + 1, UI.POP and 5 or 2.5)
			seg.Position = UDim2.fromOffset((ax + bx) / 2, (ay + by) / 2)
			seg.Rotation = math.deg(math.atan2(by - ay, bx - ax))
		end
		place()
		box:GetPropertyChangedSignal("AbsoluteSize"):Connect(place)
	end
	return box
end

return UI
