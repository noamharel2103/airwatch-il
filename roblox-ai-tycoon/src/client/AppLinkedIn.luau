--!strict
-- LinkedIn: search for people with filters, then try to hire them.
-- Better filters find better people, but the best ones say no unless your company is hot.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS:WaitForChild("Shared")
local Format = require(Shared.Format)
local Staff = require(Shared.Staff)
local UI = require(script.Parent.UI)
local Net = require(script.Parent.Net)
local T = UI.T
local new = UI.new

local App = { id = "linkedin", name = "LinkedIn", icon = "linkedin", color = Color3.fromRGB(10, 102, 194) }

local filters = { role = "junior", minSkill = 0.7, school = "any", skill = "any", hot = false, premium = false }
local LINK = Color3.fromRGB(10, 102, 194)

local function cycle(list, cur)
	for i, v in ipairs(list) do
		if v == cur then
			return list[i % #list + 1]
		end
	end
	return list[1]
end

function App.mount(ctx, s)
	if not s then
		return
	end
	UI.clear(ctx.tabs)
	UI.clear(ctx.body)
	local sc = UI.scroll(ctx.body)
	UI.list(sc, 10)
	UI.pad(sc, 0, 0, 10, 8)
	-- search bar with filters
	local box = UI.card(sc)
	UI.list(box, 8)
	UI.label(box, "Advanced search", 18, T.text, { FontFace = UI.HEAVY })
	local row1 = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38), Parent = box })
	UI.list(row1, 8, true)
	local roleIds = {}
	for _, r in ipairs(Staff.roles) do
		table.insert(roleIds, r.id)
	end
	UI.button(row1, "Job: " .. Staff.byId[filters.role].name, function()
		filters.role = cycle(roleIds, filters.role)
		App.mount(ctx, Net.state)
	end, LINK, { Size = UDim2.fromOffset(300, 36), TextSize = 11 })
	UI.button(row1, "Skill: " .. filters.skill, function()
		filters.skill = cycle(Staff.SKILLS, filters.skill)
		App.mount(ctx, Net.state)
	end, LINK, { Size = UDim2.fromOffset(230, 36), TextSize = 11 })
	UI.button(row1, "From: " .. filters.school, function()
		filters.school = cycle(Staff.SCHOOLS, filters.school)
		App.mount(ctx, Net.state)
	end, LINK, { Size = UDim2.fromOffset(260, 36), TextSize = 11 })
	local row2 = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38), Parent = box })
	UI.list(row2, 8, true)
	UI.button(row2, string.format("Min level: %d%%", math.floor(filters.minSkill * 100)), function()
		filters.minSkill = filters.minSkill >= 1.3 and 0.7 or filters.minSkill + 0.15
		App.mount(ctx, Net.state)
	end, LINK, { Size = UDim2.fromOffset(200, 36), TextSize = 11 })
	UI.button(row2, filters.hot and "Very in demand: ON" or "Very in demand: OFF", function()
		filters.hot = not filters.hot
		App.mount(ctx, Net.state)
	end, filters.hot and T.orange or "ghost", { Size = UDim2.fromOffset(240, 36), TextSize = 11 })
	UI.button(row2, filters.premium and "Recruiter ($300): ON" or "Recruiter ($300): OFF", function()
		filters.premium = not filters.premium
		App.mount(ctx, Net.state)
	end, filters.premium and T.yellow or "ghost", { Size = UDim2.fromOffset(250, 36), TextSize = 11 })
	UI.button(box, "SEARCH", function()
		Net.act("linkedinSearch", filters)
	end, T.green, { Size = UDim2.new(1, 0, 0, 44) })
	UI.label(box, "Free search only shows people up to 100%. Recruiter finds 8 people at any level. Stars are expensive and often say no unless your company is famous.", 12, T.dim)
	-- results
	for _, c in ipairs(s.search or {}) do
		local card = new("Frame", { BackgroundColor3 = T.panel2, Size = UDim2.new(1, -8, 0, 92), Parent = sc })
		UI.stroke(card, T.line, 3)
		local av = new("Frame", { BackgroundColor3 = Color3.fromHSV((#c.name * 37 % 100) / 100, 0.45, 0.85), Position = UDim2.fromOffset(12, 14), Size = UDim2.fromOffset(60, 60), Parent = card })
		UI.stroke(av, T.line, 3)
		new("TextLabel", { Text = c.name:sub(1, 1), FontFace = UI.HEAVY, TextSize = 26, TextColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = av })
		new("TextLabel", { Text = c.name .. (c.hot and "   IN DEMAND" or ""), FontFace = UI.HEAVY, TextSize = 15, TextColor3 = c.hot and T.orange or T.text, BackgroundTransparency = 1, Position = UDim2.fromOffset(86, 12), Size = UDim2.new(0.6, 0, 0, 20), TextXAlignment = Enum.TextXAlignment.Left, Parent = card })
		new("TextLabel", { Text = string.format("%s  |  %s  |  %s", Staff.byId[c.role].name, c.skillTag or "", c.from or ""), TextSize = 13, TextColor3 = T.sub, BackgroundTransparency = 1, Position = UDim2.fromOffset(86, 36), Size = UDim2.new(0.6, 0, 0, 18), TextXAlignment = Enum.TextXAlignment.Left, Parent = card })
		local chance = math.clamp(1 - c.demand + ((s.hype or 0) / 100 * 0.4 + (s.reputation or 0) / 100 * 0.4), 0.05, 1)
		new("TextLabel", { Text = string.format("Level %d%%   |   chance they say yes about %d%%", math.floor(c.skill * 100), math.floor(chance * 100)), TextSize = 13, TextColor3 = T.yellow, BackgroundTransparency = 1, Position = UDim2.fromOffset(86, 58), Size = UDim2.new(0.6, 0, 0, 18), TextXAlignment = Enum.TextXAlignment.Left, Parent = card })
		local key = c.key
		UI.button(card, "Send offer", function()
			local ok, res = Net.act("recruit", key)
			if ok and res == "declined" then
				Net.toast(c.name .. " said no.", "error")
			elseif ok then
				Net.toast(c.name .. " joined your team!", "good")
			end
		end, "success", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(170, 40) })
	end
	if #(s.search or {}) == 0 then
		UI.label(sc, "Pick filters and press SEARCH.", 14, T.dim)
	end
end

function App.key(s)
	local k = #(s.search or {}) .. s.headcount
	for _, c in ipairs(s.search or {}) do
		k ..= c.key
	end
	return k
end

return App
