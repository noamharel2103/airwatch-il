--!strict
-- Social: every launch and incident, what people said, headlines and rival news.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS:WaitForChild("Shared")
local Format = require(Shared.Format)
local UI = require(script.Parent.UI)
local Net = require(script.Parent.Net)
local Reveal = require(script.Parent.Reveal)
local T = UI.T
local new = UI.new

local App = { id = "social", name = "Social", icon = "social", color = Color3.fromRGB(40, 160, 240) }
App.feed = {} -- client keeps launch payloads (server snapshot excludes them)
local selected = 1

function App.add(kind, data, day)
	table.insert(App.feed, 1, { kind = kind, data = data, day = day })
	selected = 1
end

function App.selectLaunch(name)
	for i, f in ipairs(App.feed) do
		if f.kind == "launch" and f.data.modelName == name then
			selected = i
			return
		end
	end
end

function App.mount(ctx, s)
	if not s then
		return
	end
	UI.clear(ctx.tabs)
	UI.clear(ctx.body)
	local left = new("Frame", { BackgroundColor3 = T.panel, Size = UDim2.new(0, 300, 1, 0), Parent = ctx.body })
	UI.corner(left, 12)
	UI.pad(left, 10)
	local ls = UI.scroll(left)
	UI.list(ls, 6)
	UI.label(ls, "Launches and incidents", 13, T.dim)
	for i, f in ipairs(App.feed) do
		local title = f.kind == "launch" and (f.data.modelName .. "  launch  " .. f.data.score .. "/100") or (f.data.kind .. "  " .. (f.data.model or ""))
		local b = UI.button(ls, title, function()
			selected = i
			App.mount(ctx, Net.state)
		end, selected == i and "primary" or "ghost", { Size = UDim2.new(1, -6, 0, 36), TextXAlignment = Enum.TextXAlignment.Left, TextSize = 13 })
		UI.pad(b, 0, 10)
	end
	UI.label(ls, "Industry news", 13, T.dim)
	for i, n in ipairs(s.news) do
		if i > 30 then
			break
		end
		UI.label(ls, Format.date(n.day) .. "  " .. n.text, 12, n.kind == "you" and T.green or T.sub)
	end
	local right = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(312, 0), Size = UDim2.new(1, -312, 1, 0), Parent = ctx.body })
	local sc = UI.scroll(right)
	UI.list(sc, 8)
	local f = App.feed[selected]
	if not f then
		UI.label(sc, "Release a model and the whole internet will have opinions. They show up here.", 16, T.sub)
		return
	end
	local d = f.data
	if f.kind == "launch" then
		UI.label(sc, d.modelName .. "   Reception " .. d.score .. "/100", 24, T.text, { FontFace = UI.HEAVY })
		for _, w in ipairs(d.why) do
			UI.label(sc, w, 14, T.sub)
		end
		for _, h in ipairs(d.press) do
			Reveal.headline(sc, h)
		end
		for _, t in ipairs(d.threads) do
			Reveal.thread(sc, t)
		end
		for _, p in ipairs(d.posts) do
			Reveal.postCard(sc, p)
		end
	else
		if d.press then
			Reveal.headline(sc, d.press)
		end
		for _, p in ipairs(d.posts) do
			Reveal.postCard(sc, p)
		end
	end
end

function App.key(s)
	return #App.feed .. ":" .. selected .. ":" .. #s.news
end

return App
