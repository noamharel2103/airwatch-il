--!strict
-- Company: your consumer app (name, plans, prices), and moving to a bigger office.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS:WaitForChild("Shared")
local Format = require(Shared.Format)
local Catalog = require(Shared.Catalog)
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
	for _, p in ipairs({ { "app", "Your AI app" }, { "office", "Office" } }) do
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
	return page .. s.office .. s.product.appName .. s.product.subPrice .. s.product.apiPrice .. s.product.proPrice .. tostring(s.product.activeModel)
end

return App
