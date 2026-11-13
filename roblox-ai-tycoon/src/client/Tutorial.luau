--!strict
-- First-time tutorial: a card at the bottom explains one thing at a time, and a pulsing
-- ring with a bouncing CLICK HERE tag points at exactly what to press.
-- Action steps finish by themselves when you do the thing; info steps have a NEXT button.
-- The step lives in the company save (state.tut, 99 = done), so it only runs once.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UI = require(script.Parent.UI)
local Net = require(script.Parent.Net)
local T = UI.T
local new = UI.new

local Tutorial = {}

type Step = { text: string, done: ((any, any) -> boolean)?, next: boolean?, target: (() -> any)? }

local gui: ScreenGui
local shell: any

local function anyModel(s, status: string?): boolean
	for _, m in ipairs(s.models or {}) do
		if status == nil or m.status == status then
			return true
		end
	end
	return false
end

-- a visible button (or desktop icon) whose text is exactly `text`
local function findButton(text: string): GuiObject?
	for _, d in ipairs(gui:GetDescendants()) do
		if d:IsA("TextButton") and d.Text == text and d.Visible and d.AbsoluteSize.X > 0 then
			return d
		end
		if d:IsA("TextLabel") and d.Text == text and d.Parent and d.Parent:IsA("TextButton") and (d.Parent :: GuiObject).Visible and (d.Parent :: GuiObject).AbsoluteSize.X > 0 then
			return d.Parent :: GuiObject
		end
	end
	return nil
end
local function button(text: string)
	return function()
		return findButton(text)
	end
end
-- the laptop on the desk (a 3D part that opens the computer)
local function laptop()
	if shell.isOpen() then
		return nil
	end
	local rooms = workspace:FindFirstChild("Rooms")
	local st = Net.state
	local room = rooms and st and rooms:FindFirstChild("Stage" .. tostring(st.office))
	if not room then
		return nil
	end
	for _, d in ipairs(room:GetDescendants()) do
		if d:IsA("BasePart") and d:GetAttribute("OpenApp") == "desktop" then
			return d
		end
		if d:GetAttribute("OpenApp") == "desktop" and d:IsA("Model") then
			-- the desk model also holds the chair: point at the laptop screen itself
			return d:FindFirstChild("Screen", true) or d
		end
	end
	return nil
end

local STEPS: { Step } = {
	{ text = "Welcome, boss! You just started an AI company in your bedroom. Click the <font color=\"#FFD84A\">LAPTOP</font> on your desk.", target = laptop, done = function(_, sh)
		return sh.isOpen()
	end },
	{ text = "This is your computer. Every app runs a part of your company. Open <font color=\"#FFD84A\">AI LAB</font> to build your first AI.", target = button("AI Lab"), done = function(s)
		return s.training ~= nil or anyModel(s) or (shell.isOpen() and findButton("+ CREATE MODEL") ~= nil)
	end },
	{ text = "Give your AI a cool name, then press <font color=\"#FFD84A\">CREATE MODEL</font>. Your laptop starts training it.", target = button("+ CREATE MODEL"), done = function(s)
		return s.training ~= nil or anyModel(s)
	end },
	{ text = "Training takes a few days. Smash the <font color=\"#FFD84A\">TAP!</font> button to make it go faster!", target = button("TAP!"), done = function(s)
		return s.training == nil and anyModel(s)
	end },
	{ text = "Your AI is ready! Press <font color=\"#FFD84A\">LAUNCH</font> and watch the whole internet react.", target = button("LAUNCH"), done = function(s)
		return anyModel(s, "released")
	end },
	{ text = "Pick <font color=\"#FFD84A\">1 or 2 skills</font> and train again. Better AI = more users = more money.", target = button("PICK"), next = true },
	{ text = "More <font color=\"#FFD84A\">GPUS</font> = faster training. Start small, you pay for them every month.", target = button("GPUS"), next = true },
	{ text = "Your money is <font color=\"#FFD84A\">top left</font>. Every month users pay you, and you pay people, GPUs and rent.", next = true },
	{ text = "Low on cash? The <font color=\"#FFD84A\">BANK</font> gives loans. You pay them back a little every month.", target = button("Bank"), next = true },
	{ text = "Hire smart people in <font color=\"#FFD84A\">TEAM</font>. A <font color=\"#FFD84A\">RECRUITER</font> hires the best ones for you every month.", target = button("Team"), next = true },
	{ text = "That's it! Beat every other lab and become the <font color=\"#FFD84A\">biggest AI company on Earth</font>. Go get them, boss!", next = true },
}

function Tutorial.start(host: ScreenGui, sh: any)
	gui = host
	shell = sh
	-- bold guide card: robot helper on the left, typed text, progress dots, bouncy entrance
	local card = new("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -100), Size = UDim2.fromOffset(820, 150), BackgroundColor3 = Color3.new(1, 1, 1), Visible = false, ZIndex = 400, Parent = host })
	UI.corner(card, 22)
	new("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(70, 40, 190), Color3.fromRGB(34, 18, 100)), Parent = card })
	new("UIStroke", { Color = Color3.fromRGB(20, 10, 50), Thickness = 5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = card })
	local cardScale = new("UIScale", { Parent = card })
	local bot = UI.icon(card, "robot", T.teal, 150)
	bot.AnchorPoint = Vector2.new(0, 1)
	bot.Position = UDim2.new(0, -40, 1, 10)
	bot.ZIndex = 403
	for _, d in ipairs(bot:GetDescendants()) do
		if d:IsA("GuiObject") then
			d.ZIndex = 403
		end
	end
	local pill = new("Frame", { BackgroundColor3 = T.pink, Position = UDim2.fromOffset(120, -18), Size = UDim2.fromOffset(170, 34), ZIndex = 402, Parent = card })
	UI.corner(pill, 17)
	new("UIStroke", { Color = Color3.fromRGB(110, 10, 60), Thickness = 3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = pill })
	local stepL = new("TextLabel", { Text = "", FontFace = UI.HEAVY, TextSize = 17, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), ZIndex = 403, Parent = pill })
	local textL = new("TextLabel", { Text = "", FontFace = UI.HEAVY, RichText = true, TextSize = 22, TextYAlignment = Enum.TextYAlignment.Center, Position = UDim2.fromOffset(124, 22), Size = UDim2.new(1, -300, 1, -50), ZIndex = 401, Parent = card })
	local dots = new("Frame", { BackgroundTransparency = 1, Position = UDim2.new(0, 124, 1, -26), Size = UDim2.new(1, -300, 0, 12), ZIndex = 401, Parent = card })
	UI.list(dots, 6, true)
	local nextB = UI.button(card, "NEXT", nil, T.green, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -18, 0.5, -16), Size = UDim2.fromOffset(150, 56), TextSize = 22, ZIndex = 402 })
	local skipB = UI.button(card, "END TUTORIAL", nil, "ghost", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -18, 0.5, 40), Size = UDim2.fromOffset(150, 34), TextSize = 14, ZIndex = 402 })
	-- bouncing arrow above whatever you have to press
	local arrow = new("TextLabel", { Text = "V", FontFace = UI.HEAVY, TextSize = 54, TextColor3 = Color3.fromRGB(255, 216, 74), TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 1), Size = UDim2.fromOffset(60, 60), Visible = false, ZIndex = 395, Parent = host })
	new("UIStroke", { Color = Color3.fromRGB(20, 10, 50), Thickness = 5, LineJoinMode = Enum.LineJoinMode.Round, Parent = arrow })

	-- the pointer: the whole screen goes grey except the thing to press, which keeps its
	-- normal colours (4 grey frames around a hole). Plain frames don't block clicks.
	local dims = {}
	for i = 1, 4 do
		dims[i] = new("Frame", { BackgroundColor3 = Color3.fromRGB(8, 10, 20), BackgroundTransparency = 0.45, Visible = false, ZIndex = 390, Parent = host })
	end
	local ring = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Visible = false, ZIndex = 391, Parent = host })
	UI.corner(ring, 12)
	local ringStroke = new("UIStroke", { Color = Color3.fromRGB(255, 216, 74), Thickness = 5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = ring })
	local function hideDim()
		for _, d in ipairs(dims) do
			d.Visible = false
		end
		ring.Visible = false
		arrow.Visible = false
	end
	local function showDim(center: Vector2, size: Vector2)
		local W = host.AbsoluteSize.X / ((host:FindFirstChildOfClass("UIScale") or { Scale = 1 } :: any).Scale)
		local H = host.AbsoluteSize.Y / ((host:FindFirstChildOfClass("UIScale") or { Scale = 1 } :: any).Scale)
		local x0, y0 = center.X - size.X / 2, center.Y - size.Y / 2
		local x1, y1 = center.X + size.X / 2, center.Y + size.Y / 2
		local big = 4000 -- reaches past the screen edges (and under the top bar)
		dims[1].Position, dims[1].Size = UDim2.fromOffset(-big, -big), UDim2.fromOffset(W + 2 * big, y0 + big) -- top
		dims[2].Position, dims[2].Size = UDim2.fromOffset(-big, y1), UDim2.fromOffset(W + 2 * big, H - y1 + big) -- bottom
		dims[3].Position, dims[3].Size = UDim2.fromOffset(-big, y0), UDim2.fromOffset(x0 + big, y1 - y0) -- left
		dims[4].Position, dims[4].Size = UDim2.fromOffset(x1, y0), UDim2.fromOffset(W - x1 + big, y1 - y0) -- right
		for _, d in ipairs(dims) do
			d.Visible = true
		end
		ring.Position = UDim2.fromOffset(center.X, center.Y)
		ring.Size = UDim2.fromOffset(size.X, size.Y)
		ring.Visible = true
		arrow.Visible = true
		arrow.Position = UDim2.fromOffset(center.X, y0 - 6 - math.abs(math.sin(os.clock() * 6)) * 16)
	end

	local step = 99
	local function go(n: number)
		step = n
		Net.act("tutStep", n)
	end
	nextB.MouseButton1Click:Connect(function()
		if STEPS[step] and STEPS[step].next then
			go(step + 1 > #STEPS and 99 or step + 1)
		end
	end)
	skipB.MouseButton1Click:Connect(function()
		UI.confirm(card, "END THE TUTORIAL?", "Are you sure? You can play it again any time in SETTINGS.", "YES, END IT", function()
			go(99)
		end)
	end)
	local shown = -1
	local typing = 0
	local function render(s)
		step = (s and s.tut) or 99
		local st = STEPS[step]
		if not st then
			card.Visible = false
			return
		end
		card.Visible = true
		nextB.Visible = st.next == true
		nextB.Text = step == #STEPS and "LET'S GO!" or "NEXT"
		if shown == step then
			return
		end
		shown = step
		stepL.Text = string.format("STEP %d / %d", step, #STEPS)
		UI.clear(dots)
		for i = 1, #STEPS do
			local col = i < step and T.green or (i == step and Color3.fromRGB(255, 216, 74) or Color3.fromRGB(90, 70, 170))
			local d = new("Frame", { BackgroundColor3 = col, Size = UDim2.fromOffset(i == step and 26 or 12, 12), LayoutOrder = i, ZIndex = 401, Parent = dots })
			UI.corner(d, 6)
		end
		-- pop in, robot hops, text types itself out
		cardScale.Scale = 0.85
		UI.tween(cardScale, 0.35, { Scale = 1 }, Enum.EasingStyle.Back)
		bot.Rotation = -12
		UI.tween(bot, 0.5, { Rotation = 0 }, Enum.EasingStyle.Elastic)
		if UI.sound then
			UI.sound("Notify", 1.2)
		end
		textL.Text = st.text
		textL.MaxVisibleGraphemes = 0
		typing += 1
		local my = typing
		task.spawn(function()
			local n = utf8.len(textL.ContentText) or 0
			for i = 1, n, 2 do
				if typing ~= my then
					return
				end
				textL.MaxVisibleGraphemes = i
				task.wait(0.012)
			end
			textL.MaxVisibleGraphemes = -1
		end)
	end

	Net.onState(render)

	-- move the pointer every frame (targets move, windows open and close)
	local t0 = os.clock()
	RunService.RenderStepped:Connect(function()
		local st = STEPS[step]
		local target = st and st.target and st.target()
		if not target then
			hideDim()
			return
		end
		local sc = host:FindFirstChildOfClass("UIScale")
		local k = sc and sc.Scale or 1
		local origin = host.AbsolutePosition
		local center, size
		if typeof(target) == "Instance" and (target:IsA("BasePart") or target:IsA("Model")) then
			local cam = workspace.CurrentCamera
			local pos = target:IsA("Model") and (target :: Model):GetBoundingBox().Position or (target :: BasePart).Position
			local p, onScreen = cam:WorldToViewportPoint(pos)
			if not onScreen then
				hideDim()
				return
			end
			-- viewport point -> screen point (the top bar inset) -> our scaled layer
			local inset = game:GetService("GuiService"):GetGuiInset()
			-- GUI space starts under the top bar, the viewport point does not
			center = (Vector2.new(p.X, p.Y) - inset - origin) / k
			size = Vector2.new(170, 130)
		else
			local g = target :: GuiObject
			center = (g.AbsolutePosition + g.AbsoluteSize / 2 - origin) / k
			size = g.AbsoluteSize / k + Vector2.new(16, 16)
		end
		local t = os.clock() - t0
		ringStroke.Transparency = 0.2 + (math.sin(t * 5) + 1) * 0.3
		showDim(center, size)
	end)

	-- action steps finish on their own
	task.spawn(function()
		while true do
			task.wait(0.4)
			local s = Net.state
			local st = s and STEPS[step]
			if st and st.done and st.done(s, shell) then
				go(step + 1 > #STEPS and 99 or step + 1)
			end
		end
	end)
	local _ = Players
end

return Tutorial
