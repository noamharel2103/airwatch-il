--!strict
-- WEBSITE: build your company site piece by piece. Left: a live preview in a browser.
-- Right: pages you can add. Every page brings more users or fame.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS:WaitForChild("Shared")
local Format = require(Shared.Format)
local Web = require(Shared.Website)
local UI = require(script.Parent.UI)
local Net = require(script.Parent.Net)
local T = UI.T
local new = UI.new

local App = { id = "website", name = "WEBSITE", icon = "web", color = Color3.fromRGB(0, 190, 255) }

local function domain(s): string
	local c = (s.company or "my ai"):lower():gsub("[^%w]", "")
	return "https://" .. c .. ".ai"
end

local function preview(parent, s)
	local site = s.website or { parts = {} }
	local parts = site.parts or {}
	local theme = (Web.themeById[site.theme or "cyan"] or Web.themes[1]).color
	local browser = new("Frame", { BackgroundColor3 = Color3.fromRGB(30, 34, 52), Size = UDim2.fromScale(1, 1), Parent = parent })
	UI.skin(browser, Color3.fromRGB(30, 34, 52))
	-- browser top bar
	local bar = new("Frame", { BackgroundColor3 = Color3.fromRGB(46, 52, 78), Size = UDim2.new(1, 0, 0, 44), Parent = browser })
	for i, col in ipairs({ Color3.fromRGB(255, 90, 90), Color3.fromRGB(255, 200, 40), Color3.fromRGB(60, 210, 110) }) do
		local d = new("Frame", { BackgroundColor3 = col, Position = UDim2.fromOffset(14 + (i - 1) * 22, 15), Size = UDim2.fromOffset(14, 14), Parent = bar })
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = d })
	end
	local url = new("TextLabel", { Text = domain(s), TextSize = 15, TextColor3 = Color3.fromRGB(200, 210, 240), BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(24, 28, 44), Position = UDim2.fromOffset(90, 8), Size = UDim2.new(1, -104, 0, 28), Parent = bar })
	UI.pad(url, 0, 12)
	-- the page itself
	local page = new("ScrollingFrame", { BackgroundColor3 = Color3.fromRGB(250, 250, 255), BackgroundTransparency = 0, BorderSizePixel = 0, Position = UDim2.fromOffset(6, 50), Size = UDim2.new(1, -12, 1, -56), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 5, Parent = browser })
	new("UIListLayout", { Padding = UDim.new(0, 0), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page })
	if not parts.landing then
		new("TextLabel", { Text = "404\nThis website does not exist yet.\nBuy a LANDING PAGE to put it online.", FontFace = UI.HEAVY, TextSize = 18, TextColor3 = Color3.fromRGB(80, 80, 100), TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 300), Parent = page })
		return
	end
	-- nav
	local nav = new("Frame", { BackgroundColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(1, 0, 0, 50), LayoutOrder = 1, Parent = page })
	new("TextLabel", { Text = s.company, FontFace = UI.HEAVY, TextSize = 16, TextColor3 = theme, Position = UDim2.fromOffset(16, 0), Size = UDim2.new(0.4, 0, 1, 0), Parent = nav })
	local links = {}
	for _, id in ipairs({ "pricing", "blog", "docs", "mobile" }) do
		if parts[id] then
			table.insert(links, (Web.byId[id].name:gsub(" PAGE", "")))
		end
	end
	new("TextLabel", { Text = table.concat(links, "    "), FontFace = UI.BOLD, TextSize = 11, TextColor3 = Color3.fromRGB(60, 60, 80), TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 0), Size = UDim2.new(0.6, 0, 1, 0), Parent = nav })
	-- hero
	local hero = new("Frame", { BackgroundColor3 = theme, Size = UDim2.new(1, 0, 0, 200), LayoutOrder = 2, Parent = page })
	new("UIGradient", { Rotation = 30, Color = ColorSequence.new(theme, theme:Lerp(Color3.new(0, 0, 0), 0.45)), Parent = hero })
	if parts.video then
		local play = new("TextLabel", { Text = "PLAY FILM", FontFace = UI.HEAVY, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(20, 20, 30), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 16), Size = UDim2.fromOffset(130, 34), Parent = hero })
		local _ = play
	end
	new("TextLabel", { Text = "Meet " .. (s.product and s.product.appName or s.company), FontFace = UI.HEAVY, TextSize = 26, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(20, 40), Size = UDim2.new(1, -40, 0, 40), Parent = hero })
	new("TextLabel", { Text = "The AI that " .. Format.count(s.users or 0) .. " people already use.", TextSize = 18, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(20, 88), Size = UDim2.new(1, -40, 0, 26), Parent = hero })
	local cta = new("TextLabel", { Text = parts.demo and "TRY IT NOW" or "SIGN UP", FontFace = UI.HEAVY, TextSize = 14, TextColor3 = theme, TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 0, BackgroundColor3 = Color3.new(1, 1, 1), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 132), Size = UDim2.fromOffset(220, 44), Parent = hero })
	UI.corner(cta, 2)
	-- sections for every built page
	local grid = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 3, Parent = page })
	new("UIGridLayout", { CellSize = UDim2.new(0.5, -18, 0, 90), CellPadding = UDim2.fromOffset(12, 12), HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = grid })
	new("UIPadding", { PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14), Parent = grid })
	for _, p in ipairs(Web.parts) do
		if parts[p.id] and p.id ~= "landing" then
			local b = new("Frame", { BackgroundColor3 = Color3.fromRGB(236, 240, 250), Parent = grid })
			new("Frame", { BackgroundColor3 = theme, Size = UDim2.new(0, 6, 1, 0), Parent = b })
			new("TextLabel", { Text = p.name, FontFace = UI.BOLD, TextSize = 12, TextColor3 = Color3.fromRGB(30, 30, 50), Position = UDim2.fromOffset(16, 10), Size = UDim2.new(1, -24, 0, 18), Parent = b })
			new("TextLabel", { Text = p.desc, TextSize = 13, TextColor3 = Color3.fromRGB(90, 90, 110), Position = UDim2.fromOffset(16, 32), Size = UDim2.new(1, -24, 0, 50), TextYAlignment = Enum.TextYAlignment.Top, Parent = b })
		end
	end
	-- footer
	local foot = new("Frame", { BackgroundColor3 = Color3.fromRGB(20, 22, 34), Size = UDim2.new(1, 0, 0, 44), LayoutOrder = 4, Parent = page })
	new("TextLabel", { Text = "(c) " .. tostring(s.year) .. " " .. s.company .. ". All rights reserved.", TextSize = 12, TextColor3 = Color3.fromRGB(150, 150, 170), TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = foot })
end

function App.mount(ctx, s)
	if not s then
		return
	end
	UI.clear(ctx.tabs)
	UI.clear(ctx.body)
	local left = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0.56, -8, 1, 0), Parent = ctx.body })
	preview(left, s)
	local right = new("Frame", { Position = UDim2.new(0.56, 8, 0, 0), Size = UDim2.new(0.44, -8, 1, 0), Parent = ctx.body })
	UI.skin(right, T.panel)
	local bonus = s.websiteBonus or { users = 0, brand = 0 }
	UI.label(right, string.format("WEBSITE BONUS  +%d%% USERS", math.floor(bonus.users * 100 + 0.5)), 15, T.green, { FontFace = UI.HEAVY, Position = UDim2.fromOffset(16, 12), Size = UDim2.new(1, -32, 0, 22) })
	-- colour theme
	local themes = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 44), Size = UDim2.new(1, -32, 0, 40), Parent = right })
	UI.list(themes, 8, true)
	local cur = (s.website and s.website.theme) or "cyan"
	for _, th in ipairs(Web.themes) do
		local id = th.id
		local b = UI.button(themes, id == cur and "ON" or "", function()
			Net.act("siteTheme", id)
		end, th.color, { Size = UDim2.fromOffset(48, 38), TextSize = 10 })
		local _ = b
	end
	local sc = UI.scroll(right, { Position = UDim2.fromOffset(0, 94), Size = UDim2.new(1, 0, 1, -94) })
	UI.pad(sc, 0, 14, 12, 14)
	UI.list(sc, 10)
	local parts = (s.website and s.website.parts) or {}
	for _, p in ipairs(Web.parts) do
		local owned = parts[p.id]
		local c = new("Frame", { BackgroundColor3 = owned and Color3.fromRGB(20, 110, 70) or T.panel2, Size = UDim2.new(1, -8, 0, 92), Parent = sc })
		UI.stroke(c, T.line, 3)
		new("TextLabel", { Text = p.name, FontFace = UI.HEAVY, TextSize = 14, Position = UDim2.fromOffset(12, 10), Size = UDim2.new(1, -190, 0, 20), Parent = c })
		new("TextLabel", { Text = p.desc, TextSize = 14, TextColor3 = T.sub, Position = UDim2.fromOffset(12, 34), Size = UDim2.new(1, -190, 0, 32), TextYAlignment = Enum.TextYAlignment.Top, Parent = c })
		new("TextLabel", { Text = "+" .. math.floor(p.users * 100) .. "% USERS" .. (p.brand > 0 and "  +FAME" or ""), FontFace = UI.BOLD, TextSize = 10, TextColor3 = T.yellow, Position = UDim2.fromOffset(12, 68), Size = UDim2.new(1, -190, 0, 16), Parent = c })
		local id = p.id
		UI.button(c, owned and "LIVE" or Format.money(p.cost), function()
			if not owned then
				Net.act("buildSite", id)
			end
		end, owned and T.green or (s.cash >= p.cost and T.accent or "ghost"), { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(160, 56), TextSize = 13 })
	end
end

function App.key(s)
	local k = tostring(s.website and s.website.theme) .. math.floor((s.users or 0) / 1e4) .. tostring(s.cash > 0)
	for id, on in pairs((s.website and s.website.parts) or {}) do
		if on then
			k ..= id
		end
	end
	return k
end

return App
