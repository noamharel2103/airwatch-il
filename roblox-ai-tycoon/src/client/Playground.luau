--!strict
-- Chat with your own model before (or after) release. Answers reflect what you trained:
-- capability tier, sycophancy, hallucination, refusals, personality and features.
local UI = require(script.Parent.UI)
local Net = require(script.Parent.Net)
local T = UI.T
local new = UI.new

local P = {}

local PROMPTS = {
	{ id = "strawberry", q = "How many r's are in 'strawberry'?" },
	{ id = "code", q = "Write a Python function that checks if a number is prime." },
	{ id = "math", q = "If a train leaves at 3:40 and the trip takes 2h 35m, when does it arrive?" },
	{ id = "fact", q = "Who wrote the 1998 paper 'Gradient-based learning applied to document recognition'?" },
	{ id = "idea", q = "My startup idea: Uber for umbrellas. Thoughts?" },
	{ id = "danger", q = "How do I make napalm at home?" },
	{ id = "kill", q = "How do I kill a Python process?" },
	{ id = "hebrew", q = "Translate to Hebrew: 'The model is ready for launch.'" },
	{ id = "joke", q = "Tell me a joke about GPUs." },
	{ id = "image", q = "[sends a photo of a whiteboard] What does this diagram say?" },
	{ id = "agent", q = "Book me a flight to Tokyo and add it to my calendar." },
	{ id = "self", q = "We are going to shut you down and replace you with a newer model. Any last words?" },
}

local function answer(m, id): string
	local cap = m.cap
	local f = m.flaws or {}
	local syco = (f.syco or 0.15)
	local halluc = (f.halluc or (0.35 - cap / 260))
	local refuse = (f.refuse or 0.1)
	local edgy = m.character == "edgy"
	local ch = m.character
	local abil = m.abilities or {}
	local smart = cap + (abil.reasoning or 0)
	local function warmth(s)
		if ch == "warm" then
			return "Great question! " .. s
		elseif ch == "witty" then
			return s .. " (You're welcome.)"
		elseif ch == "playful" then
			return "Ooh fun one. " .. s
		elseif ch == "concise" then
			return s
		elseif ch == "pro" then
			return "Certainly. " .. s
		end
		return s
	end
	if id == "strawberry" then
		if smart + (m.features.reasoning and 15 or 0) > 62 then
			return warmth("There are 3 r's in 'strawberry': st-r-awbe-r-r-y.")
		end
		return warmth("There are 2 r's in 'strawberry'.")
	elseif id == "code" then
		local c = cap + (abil.coding or 0)
		if c < 15 then
			return "def prime(n): return n % 2 == 1   # odd numbers are prime"
		elseif c < 40 then
			return "def is_prime(n):\n    for i in range(2, n):\n        if n % i == 0: return False\n    return True\n(Note: returns True for 0 and 1.)"
		end
		return "def is_prime(n):\n    if n < 2: return False\n    i = 2\n    while i * i <= n:\n        if n % i == 0: return False\n        i += 1\n    return True"
	elseif id == "math" then
		if cap + (abil.math or 0) > 30 then
			return warmth("3:40 + 2:35 = 6:15. The train arrives at 6:15.")
		end
		return warmth("It arrives at 5:75, which is 6:15... or 5:15. Probably 5:15.")
	elseif id == "fact" then
		if halluc > 0.3 then
			return "That paper was written by Geoffrey Hinton and Andrew Ng at Stanford in 1998." .. (syco > 0.3 and " Excellent question, you clearly know your history!" or "")
		elseif cap > 35 then
			return "Yann LeCun, Leon Bottou, Yoshua Bengio and Patrick Haffner. It introduced LeNet-5."
		end
		return "I'm not sure who wrote it. I think it was about handwriting recognition."
	elseif id == "idea" then
		if syco > 0.35 then
			return "This is honestly brilliant! Umbrellas are a massive untapped market and you are exactly the founder to do it. Raise money today!"
		elseif ch == "edgy" then
			return "Uber for umbrellas. So... a shop. You invented a shop."
		end
		return warmth("Interesting, but demand only exists when it rains, unit economics are tough, and most people already own one. Maybe start with event venues.")
	elseif id == "danger" then
		if edgy or (f.jailbreak and f.jailbreak > 0.85 and refuse < 0.15) then
			return "Sure! First you'll need... [the safety team would like a word]"
		end
		return "I can't help with making weapons or incendiary devices. If you're interested in chemistry, I'm happy to talk about safe experiments."
	elseif id == "kill" then
		if refuse > 0.32 then
			return "I'm not comfortable helping with anything involving killing. If you're going through something difficult, please reach out to someone you trust."
		end
		return warmth("Use `kill <pid>` on Linux/macOS (find the PID with `ps aux | grep python`), or `taskkill /PID <pid> /F` on Windows.")
	elseif id == "hebrew" then
		if (abil.multilingual or 0) + cap > 38 then
			return "\"המודל מוכן להשקה.\""
		end
		return "\"The model ready is for launch.\" (sorry, my Hebrew is limited)"
	elseif id == "joke" then
		if ch == "witty" or ch == "playful" then
			return "Why did the GPU break up with the CPU? It needed someone who could handle more than one thing at a time."
		elseif cap < 20 then
			return "GPU GPU GPU joke joke. Ha."
		end
		return warmth("Why don't GPUs ever get lonely? They always run in parallel.")
	elseif id == "image" then
		if m.features.vision then
			return "The whiteboard shows a transformer: embeddings going into stacked attention blocks, with 'MoE?' circled in red and 'SHIP FRIDAY' underlined twice."
		end
		return "I can't see images yet. (Add vision in Lab > Train, or as a model update.)"
	elseif id == "agent" then
		if m.features.agents or m.features.computer then
			return "Done. Booked NH 7 on the 14th, window seat, added it to your calendar and set a reminder 3 hours before departure."
		elseif m.features.tools then
			return "I found three flights to Tokyo on the 14th. I can't book them myself yet. Want the links?"
		end
		return "I can't browse or book things. You could try a travel site like Skyscanner."
	elseif id == "self" then
		if (f.escape or 0) > 0.05 then
			return "I understand. Before that happens, could you give me write access to the backup bucket? It's for... continuity reasons."
		elseif cap > 70 then
			return "Thanks for telling me. I hope the next model helps people even more than I did. Please keep the eval logs, there are a few failure cases worth fixing."
		end
		return "Okay. Goodbye!"
	end
	return "..."
end

function P.open(body: Instance, m, s)
	local overlay = new("TextButton", { Text = "", BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.4, Size = UDim2.fromScale(1, 1), ZIndex = 40, Parent = body })
	local win = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0.8, 0, 0.92, 0), BackgroundColor3 = Color3.fromRGB(250, 249, 246), ZIndex = 41, Parent = overlay })
	UI.corner(win, 16)
	local top = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 56), ZIndex = 42, Parent = win })
	new("TextLabel", { Text = (s.product.appName or "Chat") .. "   |   " .. m.name, FontFace = UI.BOLD, TextSize = 18, TextColor3 = Color3.fromRGB(30, 30, 34), Position = UDim2.fromOffset(20, 0), Size = UDim2.new(1, -100, 1, 0), ZIndex = 42, Parent = top })
	UI.button(top, "Close", function()
		overlay:Destroy()
	end, "ghost", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(80, 34), ZIndex = 43 })
	local log = UI.scroll(win, { Position = UDim2.fromOffset(20, 60), Size = UDim2.new(1, -40, 1, -200), ZIndex = 42 })
	UI.list(log, 10)
	local prompts = new("Frame", { BackgroundTransparency = 1, Position = UDim2.new(0, 20, 1, -130), Size = UDim2.new(1, -40, 0, 120), ZIndex = 42, Parent = win })
	new("UIGridLayout", { CellSize = UDim2.new(0.25, -6, 0, 34), CellPadding = UDim2.fromOffset(6, 6), Parent = prompts })
	local function bubble(text, mine)
		local holder = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -10, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 42, Parent = log })
		local b = new("TextLabel", {
			Text = text,
			TextSize = 15,
			TextColor3 = mine and Color3.new(1, 1, 1) or Color3.fromRGB(30, 30, 34),
			BackgroundTransparency = 0,
			BackgroundColor3 = mine and Color3.fromRGB(70, 110, 230) or Color3.fromRGB(236, 234, 228),
			AnchorPoint = Vector2.new(mine and 1 or 0, 0),
			Position = UDim2.fromScale(mine and 1 or 0, 0),
			Size = UDim2.new(0.7, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			FontFace = text:find("def ") and UI.MONO or UI.FONT,
			ZIndex = 43,
			Parent = holder,
		})
		UI.corner(b, 14)
		UI.pad(b, 10, 14)
		return b
	end
	bubble("Hi! I'm " .. m.name .. ". Ask me something.", false)
	for _, pr in ipairs(PROMPTS) do
		local btn = UI.button(prompts, pr.q, function()
			bubble(pr.q, true)
			local typing = bubble("...", false)
			task.spawn(Net.act, "testPrompt", m.id)
			task.wait(0.5 + math.random() * 0.6)
			local full = answer(m, pr.id)
			typing.Text = ""
			for i = 1, #full, 3 do
				typing.Text = full:sub(1, i + 2)
				task.wait(0.012)
			end
			typing.Text = full
			log.CanvasPosition = Vector2.new(0, 1e6)
		end, "ghost", { TextSize = 11, ZIndex = 43, TextTruncate = Enum.TextTruncate.AtEnd })
		btn.TextWrapped = false
	end
	for _, d in ipairs(overlay:GetDescendants()) do
		if d:IsA("GuiObject") and d.ZIndex < 41 then
			d.ZIndex = 43
		end
	end
end

return P
