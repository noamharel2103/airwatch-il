--!strict
-- SHOP: Robux boosts (one time) and passes (forever). The server decides what you get.
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Shared = RS:WaitForChild("Shared")
local Format = require(Shared.Format)
local ShopData = require(Shared.Shop)
local UI = require(script.Parent.UI)
local Net = require(script.Parent.Net)
local T = UI.T
local new = UI.new

local App = { id = "shop", name = "SHOP", icon = "shop", color = Color3.fromRGB(255, 190, 0) }
local page = "boosts"
local focusKey: string? = nil
App.targetModel = nil :: number?

local ROBUX_GREEN = Color3.fromRGB(0, 200, 90)

local function priceText(robux: number, id: number): string
	if id == 0 then
		return RunService:IsStudio() and ("TEST  R$ " .. robux) or "SOON"
	end
	return "R$ " .. robux
end

local function card(parent, item, s, isPass: boolean)
	local owned = isPass and s.perks and s.perks[item.key]
	local c = new("Frame", { Size = UDim2.fromOffset(300, 330), Parent = parent })
	UI.skin(c, item.key == focusKey and Color3.fromRGB(70, 60, 30) or T.panel2)
	if item.key == focusKey then
		local st = c:FindFirstChildOfClass("UIStroke")
		if st then
			st.Color = Color3.fromRGB(255, 200, 0)
			st.Thickness = 5
		end
	end
	-- big colourful icon tile
	local tile = UI.icon(c, item.icon, item.color, 110)
	tile.AnchorPoint = Vector2.new(0.5, 0)
	tile.Position = UDim2.new(0.5, 0, 0, 16)
	new("TextLabel", { Text = item.name, FontFace = UI.HEAVY, TextSize = 17, TextColor3 = item.color:Lerp(Color3.new(1, 1, 1), 0.35), TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(10, 136), Size = UDim2.new(1, -20, 0, 26), Parent = c })
	local desc = item.desc or ""
	if item.cash then
		desc = Format.money(ShopData.cashFor(item, s.year or 2023)) .. " straight into your bank. Grows every year."
	end
	new("TextLabel", { Text = desc, TextSize = 15, TextColor3 = T.sub, TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(14, 170), Size = UDim2.new(1, -28, 0, 90), Parent = c })
	local label = owned and "OWNED" or priceText(item.robux, item.id)
	local color = owned and UI.GHOST or (item.id == 0 and not RunService:IsStudio() and UI.GHOST or ROBUX_GREEN)
	UI.button(c, label, function()
		if owned then
			return
		end
		local target = nil
		if item.key == "stats10" then
			target = App.targetModel
		end
		local res = Net.shop(isPass and "pass" or "product", item.key, target)
		if res and res.ok and res.test then
			Net.toast(item.name .. " (Studio test, free)", "good")
		end
	end, color, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -14), Size = UDim2.new(1, -28, 0, 54), TextSize = 17 })
	return c
end

function App.mount(ctx, s)
	App.ctx = ctx
	if not s then
		return
	end
	UI.clear(ctx.tabs)
	for _, p in ipairs({ { "boosts", "BOOSTS" }, { "cash", "CASH" }, { "passes", "FOREVER PASSES" } }) do
		UI.button(ctx.tabs, p[2], function()
			page = p[1]
			focusKey = nil
			App.mount(ctx, Net.state)
		end, page == p[1] and Color3.fromRGB(255, 170, 0) or "ghost", { Size = UDim2.fromOffset(p[1] == "passes" and 260 or 170, 42), TextSize = 14 })
	end
	UI.clear(ctx.body)
	local bg = new("Frame", { Size = UDim2.fromScale(1, 1), Parent = ctx.body })
	UI.skin(bg, T.panel)
	local headline = page == "passes" and "BUY ONCE, KEEP FOREVER IN EVERY COMPANY" or (page == "cash" and "SKIP THE GRIND. MONEY NOW." or "INSTANT POWER FOR THE COMPANY YOU ARE PLAYING")
	new("TextLabel", { Text = headline, FontFace = UI.BOLD, TextSize = 16, TextColor3 = Color3.fromRGB(255, 200, 0), Position = UDim2.fromOffset(20, 12), Size = UDim2.new(1, -40, 0, 26), Parent = bg })
	local sc = UI.scroll(bg, { Position = UDim2.fromOffset(0, 46), Size = UDim2.new(1, 0, 1, -46) })
	UI.pad(sc, 14)
	local grid = new("UIGridLayout", { CellSize = UDim2.fromOffset(300, 330), CellPadding = UDim2.fromOffset(16, 16), SortOrder = Enum.SortOrder.LayoutOrder, Parent = sc })
	local _ = grid
	if page == "passes" then
		for _, p in ipairs(ShopData.passes) do
			card(sc, p, s, true)
		end
	else
		for _, p in ipairs(ShopData.products) do
			if (page == "cash") == (p.cash ~= nil) then
				card(sc, p, s, false)
			end
		end
	end
end

function App.key(s)
	local k = page .. (focusKey or "") .. tostring(s.year)
	for key, v in pairs(s.perks or {}) do
		if v then
			k ..= key
		end
	end
	return k
end

-- open on a specific item (for example the locked x8 speed button)
function App.focus(key: string?)
	focusKey = key
	if key then
		page = ShopData.passByKey[key] and "passes" or (ShopData.productByKey[key] and ShopData.productByKey[key].cash and "cash" or "boosts")
	end
end

return App
