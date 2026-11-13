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
	{ text = "Welcome, boss! You run a tiny AI company from your bedroom. Click the LAPTOP on your desk to open your computer.", target = laptop, done = function(_, sh)
		return sh.isOpen()
	end },
	{ text = "This is your computer. Every part of your company is an app. Open AI LAB: this is where you make AIs.", target = button("AI Lab"), done = function(s)
		return s.training ~= nil or anyModel(s) or (shell.isOpen() and findButton("+ CREATE MODEL") ~= nil)
	end },
	{ text = "Type a name for your first AI in the box, then press CREATE MODEL. Your laptop starts training it.", target = button("+ CREATE MODEL"), done = function(s)
		return s.training ~= nil or anyModel(s)
	end },
	{ text = "Training takes some days. Tap the big green TAP! button (left side) to make it go faster.", target = button("TAP!"), done = function(s)
		return s.training == nil and anyModel(s)
	end },
	{ text = "Your AI is ready! Press LAUNCH to release it. People start using it and paying you.", target = button("LAUNCH"), done = function(s)
		return anyModel(s, "released")
	end },
	{ text = "Make it better: press PICK on 1 or 2 skills (like CODING), then train. Each training makes those skills go up. Better AI = more users = more money.", target = button("PICK"), next = true },
	{ text = "Training goes faster with more GPUs. Open the GPUS app to buy them. Start small: your money pays for them every month.", target = button("GPUS"), next = true },
	{ text = "Your money is at the top left. Every month you EARN from users and you PAY for people, GPUs and your office. A short report shows up every month.", next = true },
	{ text = "Low on money? Open BANK and take a LOAN: the bank gives you cash now and you pay it back a little every month for 2 years, plus a bit extra.", target = button("Bank"), next = true },
	{ text = "Want much better AIs? Hire people in TEAM. Turn the RECRUITER on and he hires the best people you can afford every month.", target = button("Team"), next = true },
	{ text = "That's it! Launch better AIs than the other labs and become the biggest AI company on Earth. Good luck, boss!", next = true },
}

function Tutorial.start(host: ScreenGui, sh: any)
	gui = host
	shell = sh
	local card = new("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -110), Size = UDim2.fromOffset(780, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = T.bg, Visible = false, ZIndex = 400, Parent = host })
	UI.corner(card, 14)
	new("UIStroke", { Color = T.yellow, Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = card })
	UI.pad(card, 14, 18)
	local stepL = new("TextLabel", { Text = "", FontFace = UI.BOLD, TextSize = 13, TextColor3 = T.yellow, Size = UDim2.new(1, -150, 0, 18), ZIndex = 401, Parent = card })
	local textL = new("TextLabel", { Text = "", TextSize = 17, Position = UDim2.fromOffset(0, 24), Size = UDim2.new(1, -150, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 401, Parent = card })
	local nextB = UI.button(card, "NEXT", nil, T.green, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(130, 40), TextSize = 15, ZIndex = 402 })
	local skipB = UI.button(card, "SKIP", nil, "ghost", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 46), Size = UDim2.fromOffset(130, 30), TextSize = 12, ZIndex = 402 })

	-- the pointer: the whole screen goes grey except the thing to press, which keeps its
	-- normal colours (4 grey frames around a hole). Plain frames don't block clicks.
	local dims = {}
	for i = 1, 4 do
		dims[i] = new("Frame", { BackgroundColor3 = Color3.fromRGB(8, 10, 20), BackgroundTransparency = 0.45, Visible = false, ZIndex = 390, Parent = host })
	end
	local ring = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Visible = false, ZIndex = 391, Parent = host })
	UI.corner(ring, 12)
	local ringStroke = new("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = ring })
	local function hideDim()
		for _, d in ipairs(dims) do
			d.Visible = false
		end
		ring.Visible = false
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
		go(99)
	end)
	local function render(s)
		step = (s and s.tut) or 99
		local st = STEPS[step]
		if not st then
			card.Visible = false
			return
		end
		card.Visible = true
		stepL.Text = string.format("TUTORIAL  %d / %d", step, #STEPS)
		textL.Text = st.text
		nextB.Visible = st.next == true
		nextB.Text = step == #STEPS and "DONE" or "NEXT"
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
