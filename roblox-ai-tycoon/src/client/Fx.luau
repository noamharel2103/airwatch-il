--!strict
-- Juice: money bursts, big pop-up banners, sounds. Sounds live in SoundService.Sfx.
local SoundService = game:GetService("SoundService")
local UIS = game:GetService("UserInputService")
local UI = require(script.Parent.UI)
local new = UI.new

local Fx = {}
local layer: Frame? = nil

function Fx.init(gui: ScreenGui)
	layer = new("Frame", { Name = "Fx", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 400, Parent = gui })
end

function Fx.sound(name: string, pitch: number?)
	local folder = SoundService:FindFirstChild("Sfx")
	local s = folder and folder:FindFirstChild(name)
	if s and s:IsA("Sound") then
		local c = s:Clone()
		c.PlaybackSpeed = pitch or (0.95 + math.random() * 0.1)
		c.Parent = SoundService
		c:Play()
		c.Ended:Once(function()
			c:Destroy()
		end)
		task.delay(5, function()
			if c.Parent then
				c:Destroy()
			end
		end)
	end
end

-- screen point in the Fx layer's coordinates (the gui is scaled by a UIScale)
local function toLocal(p: Vector2): Vector2
	if not layer then
		return p
	end
	local abs = layer.AbsoluteSize
	local scale = 1
	local sc = layer.Parent and layer.Parent:FindFirstChildOfClass("UIScale")
	if sc then
		scale = sc.Scale
	end
	local inset = layer.AbsolutePosition
	return Vector2.new((p.X - inset.X) / scale, (p.Y - inset.Y) / scale), abs
end

local GOLD = Color3.fromRGB(255, 205, 40)
local BILL = Color3.fromRGB(70, 200, 90)

-- coins and bills fly up from a point and fall down with gravity
function Fx.burst(at: Vector2?, count: number?, bills: boolean?)
	if not layer then
		return
	end
	local p = toLocal(at or UIS:GetMouseLocation())
	local n = count or 14
	for i = 1, n do
		local isBill = bills and i % 2 == 0
		local piece = new("Frame", { BackgroundColor3 = isBill and BILL or GOLD, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(p.X, p.Y), Size = isBill and UDim2.fromOffset(34, 18) or UDim2.fromOffset(18, 18), ZIndex = 401, Parent = layer })
		new("UIStroke", { Color = isBill and Color3.fromRGB(20, 90, 40) or Color3.fromRGB(170, 100, 0), Thickness = 2, Parent = piece })
		if isBill then
			new("UICorner", { CornerRadius = UDim.new(0, 3), Parent = piece })
			new("TextLabel", { Text = "$", FontFace = UI.HEAVY, TextSize = 10, TextColor3 = Color3.fromRGB(20, 90, 40), TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), ZIndex = 402, Parent = piece })
		else
			new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = piece })
			new("Frame", { BackgroundColor3 = Color3.fromRGB(255, 245, 170), Position = UDim2.fromOffset(4, 3), Size = UDim2.fromOffset(6, 4), ZIndex = 402, Parent = piece })
		end
		local vx = (math.random() - 0.5) * 520
		local vy = -260 - math.random() * 340
		local spin = (math.random() - 0.5) * 900
		task.spawn(function()
			local x, y, r, t = p.X, p.Y, 0, 0
			local last = os.clock()
			while t < 1.6 and piece.Parent do
				local now = os.clock()
				local dt = math.min(now - last, 0.05)
				last = now
				t += dt
				vy += 1200 * dt
				x += vx * dt
				y += vy * dt
				r += spin * dt
				piece.Position = UDim2.fromOffset(x, y)
				piece.Rotation = r
				if t > 1.1 then
					piece.BackgroundTransparency = (t - 1.1) / 0.5
				end
				task.wait()
			end
			piece:Destroy()
		end)
	end
end

-- big centered text that pops in, wobbles, and flies away
function Fx.banner(text: string, color: Color3?, sub: string?)
	if not layer then
		return
	end
	local holder = new("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.42), Size = UDim2.fromOffset(900, 160), ZIndex = 410, Parent = layer })
	local t = new("TextLabel", { Text = text, FontFace = UI.HEAVY, TextSize = 64, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 90), ZIndex = 411, Parent = holder })
	new("UIStroke", { Color = Color3.fromRGB(20, 12, 4), Thickness = 7, ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual, Parent = t })
	local c = color or GOLD
	new("UIGradient", { Rotation = 90, Color = ColorSequence.new(c:Lerp(Color3.new(1, 1, 1), 0.55), c), Parent = t })
	if sub then
		local st = new("TextLabel", { Text = sub, FontFace = UI.BOLD, TextSize = 22, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 96), Size = UDim2.new(1, 0, 0, 34), ZIndex = 411, Parent = holder })
		new("UIStroke", { Color = Color3.fromRGB(20, 12, 4), Thickness = 4, ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual, Parent = st })
	end
	local sc = new("UIScale", { Scale = 0.2, Parent = holder })
	UI.tween(sc, 0.35, { Scale = 1 }, Enum.EasingStyle.Back)
	task.spawn(function()
		local t0 = os.clock()
		while os.clock() - t0 < 1.5 and holder.Parent do
			holder.Rotation = math.sin((os.clock() - t0) * 9) * 3
			task.wait(1 / 30)
		end
		UI.tween(holder, 0.35, { Position = UDim2.fromScale(0.5, 0.25) })
		for _, d in ipairs(holder:GetDescendants()) do
			if d:IsA("TextLabel") then
				UI.tween(d, 0.35, { TextTransparency = 1 })
			elseif d:IsA("UIStroke") then
				UI.tween(d, 0.35, { Transparency = 1 })
			end
		end
		task.wait(0.4)
		holder:Destroy()
	end)
end

-- small "+$X" / "-$X" that floats up from a point
function Fx.float(text: string, color: Color3?, at: Vector2?)
	if not layer then
		return
	end
	local p = toLocal(at or UIS:GetMouseLocation())
	local f = new("TextLabel", { Text = text, FontFace = UI.HEAVY, TextSize = 22, TextColor3 = color or GOLD, TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(p.X, p.Y - 20), Size = UDim2.fromOffset(300, 30), ZIndex = 405, Parent = layer })
	new("UIStroke", { Color = Color3.fromRGB(10, 10, 20), Thickness = 3, ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual, Parent = f })
	UI.tween(f, 1, { Position = UDim2.fromOffset(p.X, p.Y - 110), TextTransparency = 1 })
	task.delay(1, function()
		f:Destroy()
	end)
end

-- a whole rain of money from the top (big purchases)
function Fx.rain(count: number?)
	if not layer then
		return
	end
	local w = layer.AbsoluteSize.X
	local sc = layer.Parent and layer.Parent:FindFirstChildOfClass("UIScale")
	w /= (sc and sc.Scale or 1)
	for i = 1, (count or 40) do
		task.delay(i * 0.03, function()
			Fx.burst(Vector2.new(math.random() * w, -10) * (sc and sc.Scale or 1) + (layer :: Frame).AbsolutePosition, 1, true)
		end)
	end
end

return Fx
