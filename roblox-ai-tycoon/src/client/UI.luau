--!strict
-- Tiny UI kit: theme + builders. Modern dark glass look. No emoji anywhere: icons are drawn.
local TweenService = game:GetService("TweenService")
local UI = {}

-- Blocky retro OS look (Roblox style): navy panels, cyan/green chunky buttons, pixel font.
UI.T = {
	bg = Color3.fromRGB(26, 31, 54),
	panel = Color3.fromRGB(33, 40, 70),
	panel2 = Color3.fromRGB(44, 54, 92),
	line = Color3.fromRGB(18, 22, 38),
	text = Color3.fromRGB(240, 244, 255),
	sub = Color3.fromRGB(160, 176, 214),
	dim = Color3.fromRGB(110, 124, 160),
	accent = Color3.fromRGB(0, 190, 250),
	green = Color3.fromRGB(0, 214, 100),
	red = Color3.fromRGB(250, 60, 80),
	yellow = Color3.fromRGB(255, 214, 40),
	purple = Color3.fromRGB(160, 110, 255),
	orange = Color3.fromRGB(255, 150, 70),
	teal = Color3.fromRGB(50, 200, 210),
	pink = Color3.fromRGB(240, 110, 180),
}
local T = UI.T
UI.FONT = Font.fromEnum(Enum.Font.Arcade)
UI.BOLD = Font.new("rbxasset://fonts/families/PressStart2P.json")
UI.HEAVY = Font.new("rbxasset://fonts/families/PressStart2P.json")
UI.MONO = Font.fromEnum(Enum.Font.Arcade)
-- pixel fonts render at different sizes; normalise so callers can keep "normal" sizes
local SIZE_MULT = { [UI.FONT.Family] = 1.5, ["rbxasset://fonts/families/PressStart2P.json"] = 0.9 }

function UI.new(class: string, props: { [string]: any }?, children: { Instance }?): any
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
	for _, c in ipairs(children or {}) do
		c.Parent = inst
	end
	if props and props.Parent then
		inst.Parent = props.Parent
	end
	return inst
end
local new = UI.new

function UI.corner(parent: Instance, r: number?)
	-- blocky look: almost square corners (round things like avatars keep big radii)
	local rr = r or 10
	if rr < 40 then
		rr = math.min(rr, 3)
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
	return l
end

function UI.card(parent: Instance, props: { [string]: any }?)
	local f = new("Frame", { BackgroundColor3 = T.panel2, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = parent })
	UI.corner(f, 12)
	UI.pad(f, 12, 14)
	for k, v in pairs(props or {}) do
		(f :: any)[k] = v
	end
	return f
end

-- kind: "primary" | "ghost" | "danger" | "success" | color
function UI.button(parent: Instance, text: string, onClick: (() -> ())?, kind: any?, props: { [string]: any }?)
	local color = T.accent
	if kind == "ghost" then
		color = T.panel2
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
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Center,
		BackgroundTransparency = 0,
		BackgroundColor3 = color,
		Size = UDim2.new(0, math.max(90, #text * 9 + 28), 0, 36),
		Parent = parent,
	})
	UI.corner(b, 3)
	UI.stroke(b, T.line, 2)
	-- chunky 3D bottom edge
	new("Frame", { Name = "Bevel", BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.7, Size = UDim2.new(1, 0, 0, 4), Position = UDim2.new(0, 0, 1, -4), Parent = b })
	local base = color
	b.MouseEnter:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.12), { BackgroundColor3 = base:Lerp(Color3.new(1, 1, 1), 0.12) }):Play()
	end)
	b.MouseLeave:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.12), { BackgroundColor3 = base }):Play()
	end)
	b.MouseButton1Click:Connect(function()
		local s = b:FindFirstChildOfClass("UIScale") or new("UIScale", { Parent = b })
		s.Scale = 0.94
		TweenService:Create(s, TweenInfo.new(0.18, Enum.EasingStyle.Back), { Scale = 1 }):Play()
		if onClick then
			onClick()
		end
	end)
	for k, v in pairs(props or {}) do
		(b :: any)[k] = v
	end
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
	return s
end

-- Drawn icon tile: rounded square with gradient and a glyph made of frames.
function UI.icon(parent: Instance, kind: string, color: Color3, size: number)
	local tile = new("Frame", { Size = UDim2.fromOffset(size, size), BackgroundColor3 = color, Parent = parent })
	UI.corner(tile, math.floor(size * 0.24))
	UI.grad(tile, color:Lerp(Color3.new(1, 1, 1), 0.18), color:Lerp(Color3.new(0, 0, 0), 0.2), 90)
	local W = Color3.new(1, 1, 1)
	local function bar(x, y, w, h, rot, r)
		local f = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(x, y), Size = UDim2.fromScale(w, h), BackgroundColor3 = W, Rotation = rot or 0, Parent = tile })
		UI.corner(f, r or 3)
		return f
	end
	if kind == "lab" then -- flask
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
	return tile
end

function UI.tween(inst: Instance, t: number, props: { [string]: any }, style: Enum.EasingStyle?, dir: Enum.EasingDirection?)
	local tw = TweenService:Create(inst, TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end

function UI.clear(parent: Instance)
	for _, c in ipairs(parent:GetChildren()) do
		if not c:IsA("UIListLayout") and not c:IsA("UIPadding") and not c:IsA("UIGridLayout") and not c:IsA("UICorner") and not c:IsA("UIStroke") then
			c:Destroy()
		end
	end
end

-- Horizontal progress bar
function UI.bar(parent: Instance, frac: number, color: Color3?, h: number?)
	local bg = new("Frame", { Size = UDim2.new(1, 0, 0, h or 8), BackgroundColor3 = T.line, Parent = parent })
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
			seg.Size = UDim2.fromOffset(len + 1, 2.5)
			seg.Position = UDim2.fromOffset((ax + bx) / 2, (ay + by) / 2)
			seg.Rotation = math.deg(math.atan2(by - ay, bx - ax))
		end
		place()
		box:GetPropertyChangedSignal("AbsoluteSize"):Connect(place)
	end
	return box
end

return UI
