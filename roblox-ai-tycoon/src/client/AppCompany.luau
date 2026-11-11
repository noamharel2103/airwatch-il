--!strict
-- Company: your consumer app (name, plans, prices), and moving to a bigger office.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS:WaitForChild("Shared")
local Format = require(Shared.Format)
local Catalog = require(Shared.Catalog)
local Labs = require(Shared.Labs)
local UI = require(script.Parent.UI)
local Net = require(script.Parent.Net)
local T = UI.T
local new = UI.new

local App = { id = "company", name = "Company", icon = "company", color = Color3.fromRGB(90, 110, 140) }
local page = "app"

function App.mount(ctx, s)
	if not s then
		return
	end
	UI.clear(ctx.tabs)
	UI.clear(ctx.body)
	for _, p in ipairs({ { "app", "Your AI app" }, { "office", "Office" }, { "acquire", "Buy companies" } }) do
		UI.button(ctx.tabs, p[2], function()
			page = p[1]
			App.mount(ctx, Net.state)
		end, page == p[1] and "primary" or "ghost", { Size = UDim2.fromOffset(130, 34) })
	end
	local sc = UI.scroll(ctx.body)
	UI.list(sc, 12)
	UI.pad(sc, 0, 0, 12, 8)
	if page == "app" then
		local active = s.product.activeModel and s.models[s.product.activeModel]
		local phone = new("Frame", { BackgroundColor3 = Color3.fromRGB(250, 249, 246), Size = UDim2.fromOffset(300, 420), Parent = sc })
		UI.corner(phone, 28)
		UI.pad(phone, 18)
		UI.list(phone, 8)
		new("TextLabel", { Text = s.product.appName, FontFace = UI.HEAVY, TextSize = 24, TextColor3 = Color3.fromRGB(30, 30, 34), Size = UDim2.new(1, 0, 0, 30), Parent = phone })
		new("TextLabel", { Text = active and ("Powered by " .. active.name) or "No model live yet", TextSize = 13, TextColor3 = Color3.fromRGB(110, 110, 120), Size = UDim2.new(1, 0, 0, 18), Parent = phone })
		new("TextLabel", { Text = Format.count(s.users) .. " users", FontFace = UI.HEAVY, TextSize = 34, TextColor3 = Color3.fromRGB(60, 90, 220), Size = UDim2.new(1, 0, 0, 44), Parent = phone })
		new("TextLabel", { Text = string.format("about %s paying subscribers", Format.count(s.users * 0.05)), TextSize = 13, TextColor3 = Color3.fromRGB(110, 110, 120), Size = UDim2.new(1, 0, 0, 18), Parent = phone })
		if active then
			for f in pairs(active.features) do
				new("TextLabel", { Text = "  " .. f, TextSize = 14, TextColor3 = Color3.fromRGB(30, 30, 34), Size = UDim2.new(1, 0, 0, 18), Parent = phone })
			end
		end
		local ready = (s.resetReady or 0) <= s.day and s.resetMoment ~= nil
		local resetText = (s.resetReady or 0) > s.day and ("LIMITS RESET AGAIN ON " .. Format.date(s.resetReady))
			or (s.resetMoment == "launch" and ("NEW MODEL OUT: RESET LIMITS SO EVERYONE TRIES IT  " .. Format.money(math.floor(s.users * 0.4 + 5000))))
			or (s.resetMoment == "crisis" and ("SAY SORRY: RESET EVERYONE'S LIMITS  " .. Format.money(math.floor(s.users * 0.4 + 5000))))
			or "RESET LIMITS: ONLY AFTER A LAUNCH OR A CRISIS"
		UI.button(sc, resetText, function()
			if Net.act("resetLimits") then
				Net.toast("Usage limits reset. Users are going crazy.", "good")
			end
		end, ready and T.green or "ghost", { Size = UDim2.fromOffset(560, 54), TextSize = 14 })
		UI.label(sc, "App name", 14, T.sub)
		local box = new("TextBox", { Text = s.product.appName, ClearTextOnFocus = false, BackgroundTransparency = 0, BackgroundColor3 = T.panel2, Size = UDim2.new(0, 360, 0, 40), TextSize = 16, Parent = sc })
		UI.corner(box, 10)
		UI.pad(box, 0, 12)
		box.FocusLost:Connect(function()
			Net.act("renameApp", box.Text)
		end)
		local function priceRow(label, values, current, apply)
			UI.label(sc, label, 14, T.sub)
			local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), Parent = sc })
			UI.list(row, 6, true)
			for _, v in ipairs(values) do
				UI.button(row, v == 0 and "Off" or ("$" .. v), function()
					apply(v)
				end, current == v and "primary" or "ghost", { Size = UDim2.fromOffset(74, 34) })
			end
		end
		priceRow("Monthly plan (cheaper = more users, less money each)", { 8, 15, 20, 30, 50 }, s.product.subPrice, function(v)
			Net.act("setPrices", v, s.product.apiPrice, s.product.proPrice)
		end)
		priceRow("Pro plan for power users", { 0, 100, 200, 500 }, s.product.proPrice, function(v)
			Net.act("setPrices", s.product.subPrice, s.product.apiPrice, v)
		end)
		priceRow("API price per 1M output tokens", { 0.5, 2, 5, 10, 15, 30, 60 }, s.product.apiPrice, function(v)
			Net.act("setPrices", s.product.subPrice, v, s.product.proPrice)
		end)
	elseif page == "acquire" then
		UI.label(sc, "Buy your rivals", 26, T.text, { FontFace = UI.HEAVY })
		UI.label(sc, "Make an offer. Bigger offers get a yes more often. Strong labs rarely sell, and regulators can block big deals. If you lack cash you pay in stock.", 14, T.sub)
		local grid = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = sc })
		new("UIGridLayout", { CellSize = UDim2.new(1 / 3, -8, 0, 150), CellPadding = UDim2.fromOffset(10, 10), Parent = grid })
		local list = table.clone(Labs.list)
		table.sort(list, function(a, b)
			return Labs.valuation(a.id, s.year) < Labs.valuation(b.id, s.year)
		end)
		for _, lab in ipairs(list) do
			local owned = s.acquired and s.acquired[lab.id]
			local price = Labs.valuation(lab.id, s.year) * 1.35
			local canAfford = s.valuation >= price * 1.5
			local c = new("Frame", { BackgroundColor3 = owned and Color3.fromRGB(30, 80, 50) or T.panel2, Parent = grid })
			UI.corner(c, 4)
			UI.stroke(c, Color3.fromRGB(10, 12, 22), 3)
			UI.pad(c, 12)
			local tag = new("Frame", { BackgroundColor3 = lab.color, Size = UDim2.fromOffset(16, 16), Parent = c })
			UI.stroke(tag, Color3.fromRGB(10, 12, 22), 2)
			new("TextLabel", { Text = Labs.displayName(lab.id), FontFace = UI.BOLD, TextSize = 20, Position = UDim2.fromOffset(26, -4), Size = UDim2.new(1, -26, 0, 26), Parent = c })
			new("TextLabel", { Text = owned and "OWNED BY YOU" or ("Price " .. Format.money(price)), FontFace = UI.BOLD, TextSize = 16, TextColor3 = owned and T.green or T.yellow, Position = UDim2.fromOffset(0, 28), Size = UDim2.new(1, 0, 0, 20), Parent = c })
			if not owned then
				local pending = false
				for _, o in ipairs(s.offers or {}) do
					if o.lab == lab.id then
						pending = true
					end
				end
				local cd = (s.cooldowns or {})[lab.id]
				local worth = price / 1.35
				local status = pending and "OFFER SENT. WAITING FOR AN ANSWER." or ((cd and s.day < cd) and ("SAID NO. TRY AGAIN " .. Format.date(cd)) or ("Worth about " .. Format.money(worth)))
				new("TextLabel", { Text = status, FontFace = UI.FONT, TextSize = 14, TextColor3 = pending and T.yellow or T.sub, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 52), Size = UDim2.new(1, 0, 0, 18), Parent = c })
				if not pending and not (cd and s.day < cd) then
					local row = new("Frame", { BackgroundTransparency = 1, Position = UDim2.new(0, 0, 1, -40), Size = UDim2.new(1, 0, 0, 38), Parent = c })
					UI.list(row, 6, true)
					for _, o in ipairs({ { "LOW 1.2x", 1.2 }, { "FAIR 1.5x", 1.5 }, { "HUGE 2x", 2.0 } }) do
						UI.button(row, o[1], function()
							local offer = worth * o[2]
							Net.act("acquire", lab.id, s.cash < offer, o[2])
						end, o[2] == 1.5 and T.green or "ghost", { Size = UDim2.fromOffset(112, 36), TextSize = 12 })
					end
				end
			end
		end
	else
		for i, st in ipairs(Catalog.officeStages) do
			local c = UI.card(sc, { BackgroundColor3 = i == s.office and Color3.fromRGB(30, 56, 44) or T.panel2 })
			UI.list(c, 4)
			UI.label(c, st.name .. (i == s.office and "   (you are here)" or ""), 18, i <= s.office and T.text or T.sub, { FontFace = UI.HEAVY })
			UI.label(c, st.desc, 13, T.sub)
			UI.label(c, string.format("%d desks   |   %s kW for your own GPUs   |   rent %s/mo", st.maxStaff, Format.count(st.kw), Format.money(st.rent)), 12, T.dim)
			if i == s.office + 1 then
				UI.button(c, "Move in for " .. Format.money(st.cost), function()
					Net.act("upgradeOffice")
				end, "success")
			end
		end
	end
end

function App.key(s)
	local n = 0
	for _ in pairs(s.acquired or {}) do
		n += 1
	end
	return page .. tostring(s.resetReady) .. tostring(s.resetMoment) .. #(s.offers or {}) .. n .. s.year .. math.floor(math.log10(math.max(s.valuation, 10)) * 4) .. s.office .. s.product.appName .. s.product.subPrice .. s.product.apiPrice .. s.product.proPrice .. tostring(s.product.activeModel)
end

return App
