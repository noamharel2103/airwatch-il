--!strict
-- Bank: valuation, cash, balance (income vs costs), investors, loans, charts.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS:WaitForChild("Shared")
local Format = require(Shared.Format)
local UI = require(script.Parent.UI)
local Net = require(script.Parent.Net)
local T = UI.T
local new = UI.new

local App = { id = "bank", name = "Bank", icon = "bank", color = Color3.fromRGB(31, 203, 114) }

local STAT_ICON = { ["Company value"] = "company", Cash = "cash", ["Your stake"] = "crown", ["Last month"] = "fire" }
local function bigStat(parent, label, value, color)
	if UI.POP then
		-- bold coloured tile: gradient, dark rim of its own colour, big outlined number, icon on the right
		local col = color or T.accent
		if col == T.yellow then
			col = T.accent -- gold belongs to the shop only
		elseif col == T.text then
			col = T.purple
		end
		local edge = col:Lerp(Color3.fromRGB(20, 8, 40), 0.62)
		local c = new("Frame", { BackgroundColor3 = col, ClipsDescendants = true, Parent = parent })
		UI.corner(c, 18)
		new("UIStroke", { Color = edge, Thickness = 4, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = c })
		new("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(190, 190, 190)), Parent = c })
		local ic = UI.icon(c, STAT_ICON[label] or "cash", col, 64)
		ic.AnchorPoint = Vector2.new(1, 0.5)
		ic.Position = UDim2.new(1, -10, 0.5, 0)
		new("TextLabel", { Text = string.upper(label), FontFace = UI.FONT, TextSize = 13, TextColor3 = Color3.new(1, 1, 1), TextTransparency = 0.08, Position = UDim2.fromOffset(16, 10), Size = UDim2.new(1, -90, 0, 16), Parent = c })
		local v = new("TextLabel", { Text = value, FontFace = UI.HEAVY, TextSize = 30, TextColor3 = Color3.new(1, 1, 1), TextScaled = false, Position = UDim2.fromOffset(16, 30), Size = UDim2.new(1, -90, 0, 40), Parent = c })
		new("UIStroke", { Color = edge, Thickness = 3.5, LineJoinMode = Enum.LineJoinMode.Round, ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual, Parent = v })
		return
	end
	local c = new("Frame", { BackgroundColor3 = T.panel2, Parent = parent })
	UI.corner(c, 14)
	UI.pad(c, 12, 16)
	new("TextLabel", { Text = label, TextSize = 13, TextColor3 = T.sub, Size = UDim2.new(1, 0, 0, 16), Parent = c })
	new("TextLabel", { Text = value, FontFace = UI.HEAVY, TextSize = 28, TextColor3 = color or T.text, Position = UDim2.fromOffset(0, 20), Size = UDim2.new(1, 0, 0, 34), Parent = c })
end

function App.mount(ctx, s)
	if not s then
		return
	end
	UI.clear(ctx.tabs)
	UI.clear(ctx.body)
	local sc = UI.scroll(ctx.body)
	UI.list(sc, 12)
	UI.pad(sc, 0, 0, 12, 8)
	local top = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 84), Parent = sc })
	new("UIGridLayout", { CellSize = UDim2.new(0.25, -9, 1, 0), CellPadding = UDim2.fromOffset(12, 0), Parent = top })
	bigStat(top, "Company value", Format.money(s.valuation), T.yellow)
	bigStat(top, "Cash", Format.money(s.cash), s.cash >= 0 and T.green or T.red)
	bigStat(top, "Your stake", string.format("%.1f%%  (%s)", s.equity * 100, Format.money(s.valuation * s.equity)), T.purple)
	local lm = s.lastMonth
	bigStat(top, "Last month", lm and ((lm.revenue - lm.costs >= 0 and "+" or "") .. Format.money(lm.revenue - lm.costs)) or "-", lm and (lm.revenue >= lm.costs and T.green or T.red) or T.text)
	-- where the money goes: every cost of last month as a bar, biggest first, each with a
	-- FIX button that opens the place where you can lower it
	if lm and (lm.costs or 0) > 0 then
		local box = UI.card(sc)
		UI.list(box, 8)
		UI.label(box, "WHERE YOUR MONEY GOES  (last month)", 16, T.yellow, { FontFace = UI.HEAVY })
		UI.label(box, string.format("You earned %s and spent %s.", Format.money(lm.revenue or 0), Format.money(lm.costs or 0)), 15, T.text)
		local rows = {
			{ "PEOPLE (salaries)", lm.salaries or 0, "Too many people? Let some go in TEAM, or hire cheaper ones.", "team" },
			{ "GPUS (rent and power)", lm.compute or 0, "Renting too many GPUs? Return some in GPUS, or buy your own.", "parts" },
			{ "OFFICE (rent)", lm.office or 0, "Big offices cost a lot. Only move up when you need the desks.", "company" },
			{ "SERVERS (running your AI)", lm.inference or 0, "Lots of users cost server money. Raise your prices in COMPANY.", "company" },
		}
		table.sort(rows, function(a, b)
			return a[2] > b[2]
		end)
		local total = math.max(lm.costs or 0, 1)
		for i, r in ipairs(rows) do
			if r[2] > 0 then
				local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 58), Parent = box })
				new("TextLabel", { Text = r[1], FontFace = UI.BOLD, TextSize = 15, TextColor3 = i == 1 and T.red or T.text, Size = UDim2.new(0.4, 0, 0, 22), Parent = row })
				new("TextLabel", { Text = string.format("%s  (%d%%)", Format.money(r[2]), math.floor(r[2] / total * 100 + 0.5)), FontFace = UI.BOLD, TextSize = 15, TextColor3 = T.sub, TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.new(0.4, 0, 0, 0), Size = UDim2.new(0.35, -12, 0, 22), Parent = row })
				local track = new("Frame", { BackgroundColor3 = Color3.fromRGB(18, 22, 40), Position = UDim2.fromOffset(0, 26), Size = UDim2.new(0.75, -12, 0, 12), Parent = row })
				UI.corner(track, 6)
				local fill = new("Frame", { BackgroundColor3 = i == 1 and T.red or T.orange, Size = UDim2.fromScale(math.clamp(r[2] / total, 0.02, 1), 1), Parent = track })
				UI.corner(fill, 6)
				new("TextLabel", { Text = r[3], TextSize = 12, TextColor3 = T.dim, Position = UDim2.fromOffset(0, 40), Size = UDim2.new(0.75, -12, 0, 16), Parent = row })
				local appId = r[4]
				UI.button(row, "FIX", function()
					if App.openApp then
						App.openApp(appId)
					end
				end, i == 1 and T.red or "ghost", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0.22, 0, 0, 44), TextSize = 14 })
			end
		end
	end
	-- charts
	local charts = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 200), Parent = sc })
	new("UIGridLayout", { CellSize = UDim2.new(0.5, -6, 1, 0), CellPadding = UDim2.fromOffset(12, 0), Parent = charts })
	local vals, rev, cost = {}, {}, {}
	for _, h in ipairs(s.history) do
		table.insert(vals, h.valuation)
		table.insert(rev, h.revenue)
		table.insert(cost, h.costs)
	end
	local c1 = new("Frame", { BackgroundColor3 = T.panel2, Parent = charts })
	UI.corner(c1, 14)
	UI.pad(c1, 12)
	UI.label(c1, "Valuation", 14, T.sub)
	local h1 = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 26), Size = UDim2.new(1, 0, 1, -26), Parent = c1 })
	UI.chart(h1, vals, T.yellow, 150)
	local c2 = new("Frame", { BackgroundColor3 = T.panel2, Parent = charts })
	UI.corner(c2, 14)
	UI.pad(c2, 12)
	UI.label(c2, "Revenue (green) vs costs (red), monthly", 14, T.sub)
	local h2 = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 26), Size = UDim2.new(1, 0, 1, -26), Parent = c2 })
	UI.chart(h2, rev, T.green, 150)
	local h3 = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 26), Size = UDim2.new(1, 0, 1, -26), Parent = c2 })
	UI.chart(h3, cost, T.red, 150)
	-- balance sheet
	local m = s.month
	local bal = UI.card(sc)
	UI.list(bal, 4)
	UI.label(bal, "This month so far", 16, T.text, { FontFace = UI.BOLD })
	local function line(label, v, color)
		local r = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Parent = bal })
		new("TextLabel", { Text = label, TextSize = 14, TextColor3 = T.sub, Size = UDim2.new(0.6, 0, 1, 0), Parent = r })
		new("TextLabel", { Text = Format.money(v), FontFace = UI.MONO, TextSize = 14, TextColor3 = color, Position = UDim2.fromScale(0.6, 0), Size = UDim2.new(0.4, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Right, Parent = r })
	end
	line("Subscriptions", m.sub, T.green)
	line("API", m.api, T.green)
	line("Salaries", -m.salaries, T.red)
	line("GPUs and power", -m.compute, T.red)
	line("Serving users (inference)", -m.inference, T.red)
	line("Office and launches", -m.office, T.red)
	-- investors
	UI.label(sc, "Investors", 18, T.text, { FontFace = UI.HEAVY })
	if #s.investors == 0 then
		UI.label(sc, s.users < 2000 and "Investors call once real people use your AI. Release a model first." or "No offers right now. They come after good months and great launches.", 13, T.dim)
	end
	for i, inv in ipairs(s.investors) do
		local c = UI.card(sc)
		UI.list(c, 4)
		UI.label(c, inv.name .. "   (" .. inv.kind .. ")", 18, T.text, { FontFace = UI.HEAVY })
		UI.label(c, inv.blurb, 12, T.sub)
		UI.label(c, string.format("Invests %s for %.1f%% of the company. Values you at %s.", Format.money(inv.amount), inv.stake * 100, Format.money(inv.post)), 15, T.yellow)
		local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), Parent = c })
		UI.list(row, 8, true)
		UI.button(row, "Meet them", function()
			Net.act("meetInvestor", i)
		end, "success", { Size = UDim2.fromOffset(150, 34) })
		UI.button(row, "Decline", function()
			Net.act("investor", i, false)
		end, "ghost")
	end
	-- loans
	UI.label(sc, "Bank loans", 18, T.text, { FontFace = UI.HEAVY })
	-- plain words for new players: what a loan is and when to take one
	local how = UI.card(sc)
	UI.list(how, 6)
	UI.label(how, "HOW A LOAN WORKS", 15, T.yellow, { FontFace = UI.HEAVY })
	UI.label(how, "1.  The bank gives you money right now.", 15, T.text)
	UI.label(how, "2.  You pay it back a little every month for 2 years.", 15, T.text)
	UI.label(how, string.format("3.  You pay back a bit more than you took (about %.0f%% a year). Big loans cost more.", (s.loanRate or 0.1) * 100), 15, T.text)
	UI.label(how, string.format("Take a loan to buy GPUs or hire people that make you more money. You can borrow up to %s.", Format.money(s.loanLimit)), 14, T.sub)
	local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), Parent = sc })
	UI.list(row, 8, true)
	local box = new("TextBox", { Text = "", PlaceholderText = "Amount, like 5000000", ClearTextOnFocus = false, FontFace = UI.FONT, TextSize = 18, TextColor3 = T.text, PlaceholderColor3 = T.dim, BackgroundColor3 = T.panel2 or T.panel, Size = UDim2.fromOffset(260, 38), Parent = row })
	UI.stroke(box, T.line, 3)
	UI.button(row, "Meet the bank", function()
		local txt = box.Text:lower():gsub("[,%$ ]", "")
		local mult = 1
		if txt:sub(-1) == "k" then
			mult, txt = 1e3, txt:sub(1, -2)
		elseif txt:sub(-1) == "m" then
			mult, txt = 1e6, txt:sub(1, -2)
		elseif txt:sub(-1) == "b" then
			mult, txt = 1e9, txt:sub(1, -2)
		end
		local n = tonumber(txt)
		if n then
			Net.act("meetLoan", n * mult)
		else
			Net.toast("Type an amount, like 2M or 500K", "error")
		end
	end, "primary", { Size = UDim2.fromOffset(190, 38) })
	for i, l in ipairs(s.loans) do
		local r = UI.card(sc)
		UI.label(r, string.format("%s loan from %s at %.1f%%: %s left, %s per month, %d months to go", Format.money(l.amount), l.bank or "the bank", (l.rate or 0.11) * 100, Format.money(l.left), Format.money(l.payment), l.months), 14, T.text)
		UI.button(r, "Repay now", function()
			Net.act("repayLoan", i)
		end, "ghost", { Position = UDim2.new(1, -130, 0, 0), Size = UDim2.fromOffset(120, 30) })
	end
end

function App.key(s)
	return tostring(s.lastMonth and s.lastMonth.costs) .. #s.history .. #s.investors .. #s.loans .. math.floor(math.log10(math.max(10, math.abs(s.cash)))) .. math.floor(s.loanLimit / 1e4)
end

return App
