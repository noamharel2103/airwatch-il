--!strict
-- Bank: valuation, cash, balance (income vs costs), investors, loans, charts.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS:WaitForChild("Shared")
local Format = require(Shared.Format)
local UI = require(script.Parent.UI)
local Net = require(script.Parent.Net)
local T = UI.T
local new = UI.new

local App = { id = "bank", name = "Bank", icon = "bank", color = Color3.fromRGB(230, 180, 50) }

local function bigStat(parent, label, value, color)
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
		UI.button(row, "Accept", function()
			Net.act("investor", i, true)
		end, "success")
		UI.button(row, "Decline", function()
			Net.act("investor", i, false)
		end, "ghost")
	end
	-- loans
	UI.label(sc, "Bank loans", 18, T.text, { FontFace = UI.HEAVY })
	UI.label(sc, string.format("You can borrow up to %s at 11%% a year, paid back monthly over 2 years.", Format.money(s.loanLimit)), 13, T.sub)
	local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), Parent = sc })
	UI.list(row, 8, true)
	for _, amt in ipairs({ 10e3, 50e3, 250e3, 1e6, 10e6, 100e6 }) do
		if amt <= s.loanLimit then
			UI.button(row, "Borrow " .. Format.money(amt), function()
				Net.act("takeLoan", amt)
			end, "primary", { Size = UDim2.fromOffset(150, 34) })
		end
	end
	for i, l in ipairs(s.loans) do
		local r = UI.card(sc)
		UI.label(r, string.format("Loan of %s: %s left, %s per month, %d months to go", Format.money(l.amount), Format.money(l.left), Format.money(l.payment), l.months), 14, T.text)
		UI.button(r, "Repay now", function()
			Net.act("repayLoan", i)
		end, "ghost", { Position = UDim2.new(1, -130, 0, 0), Size = UDim2.fromOffset(120, 30) })
	end
end

function App.key(s)
	return #s.history .. #s.investors .. #s.loans .. math.floor(math.log10(math.max(10, math.abs(s.cash)))) .. math.floor(s.loanLimit / 1e4)
end

return App
