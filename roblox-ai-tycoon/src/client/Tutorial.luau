--!strict
-- First-time tutorial: one card at the bottom of the screen, one step at a time.
-- Most steps finish by themselves when you do the thing; info steps have a NEXT button.
-- The step lives in the company save (state.tut, 99 = done), so it only runs once.
local UI = require(script.Parent.UI)
local Net = require(script.Parent.Net)
local T = UI.T
local new = UI.new

local Tutorial = {}

type Step = { text: string, done: ((any, any) -> boolean)?, next: boolean? }

local function anyModel(s, status: string?): boolean
	for _, m in ipairs(s.models or {}) do
		if status == nil or m.status == status then
			return true
		end
	end
	return false
end

local STEPS: { Step } = {
	{ text = "Welcome, boss! Click the LAPTOP on your desk to open your computer.", done = function(_, shell)
		return shell.isOpen()
	end },
	{ text = "Open AI LAB, type a name for your first AI and press CREATE MODEL.", done = function(s)
		return s.training ~= nil or anyModel(s)
	end },
	{ text = "Your laptop is training it now. Tap the big green TAP! button to make it go faster.", done = function(s)
		return s.training == nil and anyModel(s)
	end },
	{ text = "Training is done! In AI LAB press LAUNCH to release your AI to the world.", done = function(s)
		return anyModel(s, "released")
	end },
	{ text = "People use your AI and pay you every month. Your money is at the top left. Salaries, GPUs and your office cost money every month too.", next = true },
	{ text = "Low on money? Open BANK and take a LOAN: the bank gives you cash now, and you pay it back a little every month for 2 years, plus a bit extra.", next = true },
	{ text = "Want better AIs? Hire people in TEAM. Turn the RECRUITER on and he hires for you every month. Good luck!", next = true },
}

function Tutorial.start(host: Instance, shell: any)
	local card = new("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -18), Size = UDim2.fromOffset(760, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = T.bg, Visible = false, ZIndex = 400, Parent = host })
	UI.corner(card, 14)
	new("UIStroke", { Color = T.yellow, Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = card })
	UI.pad(card, 14, 18)
	local stepL = new("TextLabel", { Text = "", FontFace = UI.BOLD, TextSize = 13, TextColor3 = T.yellow, Size = UDim2.new(1, -150, 0, 18), ZIndex = 401, Parent = card })
	local textL = new("TextLabel", { Text = "", TextSize = 17, Position = UDim2.fromOffset(0, 24), Size = UDim2.new(1, -150, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 401, Parent = card })
	local nextB = UI.button(card, "NEXT", nil, T.green, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(130, 40), TextSize = 15, ZIndex = 402 })
	local skipB = UI.button(card, "SKIP", nil, "ghost", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 46), Size = UDim2.fromOffset(130, 30), TextSize = 12, ZIndex = 402 })
	local step = 99
	local sending = false
	local function go(n: number)
		if sending then
			return
		end
		sending = true
		step = n
		Net.act("tutStep", n)
		sending = false
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
	end
	Net.onState(render)
	-- action steps finish on their own
	task.spawn(function()
		while true do
			task.wait(0.5)
			local s = Net.state
			local st = s and STEPS[step]
			if st and st.done and st.done(s, shell) then
				go(step + 1 > #STEPS and 99 or step + 1)
			end
		end
	end)
end

return Tutorial
