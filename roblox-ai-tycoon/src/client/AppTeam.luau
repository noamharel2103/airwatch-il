--!strict
-- Team: a Slack-style chat with your (mostly invisible) staff, plus hiring.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS:WaitForChild("Shared")
local Format = require(Shared.Format)
local Staff = require(Shared.Staff)
local Catalog = require(Shared.Catalog)
local UI = require(script.Parent.UI)
local Net = require(script.Parent.Net)
local T = UI.T
local new = UI.new

local App = { id = "team", name = "Team", icon = "team", color = Color3.fromRGB(150, 90, 240) }
local page = "chat"
local channel = "general"

function App.mount(ctx, s)
	if not s then
		return
	end
	UI.clear(ctx.tabs)
	UI.clear(ctx.body)
	for _, p in ipairs({ { "chat", "Chat" }, { "hire", "Hire" } }) do
		UI.button(ctx.tabs, p[2], function()
			page = p[1]
			App.mount(ctx, Net.state)
		end, page == p[1] and "primary" or "ghost", { Size = UDim2.fromOffset(100, 34) })
	end
	if page == "chat" then
		local side = new("Frame", { BackgroundColor3 = Color3.fromRGB(40, 22, 52), Size = UDim2.new(0, 220, 1, 0), Parent = ctx.body })
		UI.corner(side, 12)
		UI.pad(side, 12)
		UI.list(side, 4)
		UI.label(side, s.company, 18, T.text, { FontFace = UI.HEAVY })
		UI.label(side, s.headcount .. " people", 12, T.sub)
		for _, ch in ipairs({ "general", "research", "infra", "safety" }) do
			local b = UI.button(side, "# " .. ch, function()
				channel = ch
				App.mount(ctx, Net.state)
			end, channel == ch and Color3.fromRGB(90, 60, 140) or Color3.fromRGB(40, 22, 52), { Size = UDim2.new(1, 0, 0, 32), TextXAlignment = Enum.TextXAlignment.Left })
			UI.pad(b, 0, 10)
		end
		local main = new("Frame", { BackgroundColor3 = T.panel, Position = UDim2.fromOffset(232, 0), Size = UDim2.new(1, -232, 1, 0), Parent = ctx.body })
		UI.corner(main, 12)
		UI.pad(main, 14)
		local sc = UI.scroll(main)
		UI.list(sc, 10)
		local n = 0
		for _, m in ipairs(s.chat) do
			if m.ch == channel then
				n += 1
				local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = n, Parent = sc })
				local av = new("Frame", { BackgroundColor3 = Color3.fromHSV((#m.from * 53 % 100) / 100, 0.5, 0.8), Size = UDim2.fromOffset(34, 34), Parent = row })
				UI.corner(av, 8)
				new("TextLabel", { Text = m.from:sub(1, 1), FontFace = UI.HEAVY, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = av })
				new("TextLabel", { Text = m.from .. "   " .. Format.date(m.day), FontFace = UI.BOLD, TextSize = 13, Position = UDim2.fromOffset(44, 0), Size = UDim2.new(1, -44, 0, 16), Parent = row })
				new("TextLabel", { Text = m.text, TextSize = 14, TextColor3 = T.text, Position = UDim2.fromOffset(44, 18), Size = UDim2.new(1, -44, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = row })
			end
		end
		if n == 0 then
			UI.label(sc, "Nothing here yet.", 14, T.dim)
		end
		task.defer(function()
			sc.CanvasPosition = Vector2.new(0, 1e6)
		end)
		return
	end
	-- hire
	local sc = UI.scroll(ctx.body)
	UI.list(sc, 10)
	local stage = Catalog.officeStages[s.office]
	UI.label(sc, string.format("%d / %d desks used. Salaries are real %d numbers. Most of the pay is equity.", s.headcount, stage.maxStaff, s.year), 14, T.sub)
	local grid = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = sc })
	new("UIGridLayout", { CellSize = UDim2.new(0.5, -6, 0, 140), CellPadding = UDim2.fromOffset(10, 10), Parent = grid })
	for _, r in ipairs(Staff.roles) do
		local cand
		for _, c in ipairs(s.candidates) do
			if c.role == r.id then
				cand = c
				break
			end
		end
		local c = new("Frame", { BackgroundColor3 = T.panel2, Parent = grid })
		UI.corner(c, 14)
		UI.pad(c, 12, 14)
		new("TextLabel", { Text = r.name .. "   (" .. (s.staff[r.id] or 0) .. ")", FontFace = UI.HEAVY, TextSize = 17, Size = UDim2.new(1, 0, 0, 22), Parent = c })
		new("TextLabel", { Text = r.blurb, TextSize = 12, TextColor3 = T.sub, Position = UDim2.fromOffset(0, 24), Size = UDim2.new(1, 0, 0, 30), TextYAlignment = Enum.TextYAlignment.Top, Parent = c })
		new("TextLabel", { Text = cand and ("Candidate: " .. cand.name .. ", " .. cand.from) or "", TextSize = 12, TextColor3 = T.text, Position = UDim2.fromOffset(0, 56), Size = UDim2.new(1, 0, 0, 16), Parent = c })
		new("TextLabel", { Text = string.format("Total comp %s/yr, cash about %s/mo", Format.money(Staff.tc(r.id, s.year)), Format.money(Staff.monthlyCash(r.id, s.year))), TextSize = 12, TextColor3 = T.yellow, Position = UDim2.fromOffset(0, 74), Size = UDim2.new(1, 0, 0, 16), Parent = c })
		local row = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 96), Size = UDim2.new(1, 0, 0, 32), Parent = c })
		UI.list(row, 6, true)
		UI.button(row, "Hire", function()
			Net.act("hire", r.id, 1)
		end, "success", { Size = UDim2.fromOffset(80, 30) })
		UI.button(row, "Hire 5", function()
			Net.act("hire", r.id, 5)
		end, "primary", { Size = UDim2.fromOffset(90, 30) })
		UI.button(row, "Let go", function()
			Net.act("fire", r.id)
		end, "ghost", { Size = UDim2.fromOffset(84, 30) })
	end
end

function App.key(s)
	local k = page .. channel .. #s.chat .. s.headcount .. s.year
	for _, c in ipairs(s.candidates) do
		k ..= c.name
	end
	return k
end

return App
