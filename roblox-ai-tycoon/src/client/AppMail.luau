--!strict
-- Mail (with decisions) and Goals.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS:WaitForChild("Shared")
local Format = require(Shared.Format)
local UI = require(script.Parent.UI)
local Net = require(script.Parent.Net)
local T = UI.T
local new = UI.new

local Mail = { id = "mail", name = "Mail", icon = "mail", color = Color3.fromRGB(60, 140, 240) }
local sel: number? = nil

function Mail.mount(ctx, s)
	if not s then
		return
	end
	UI.clear(ctx.tabs)
	UI.clear(ctx.body)
	local left = new("Frame", { BackgroundColor3 = T.panel, Size = UDim2.new(0, 360, 1, 0), Parent = ctx.body })
	UI.corner(left, 12)
	UI.pad(left, 8)
	local ls = UI.scroll(left)
	UI.list(ls, 4)
	if not sel and s.mail[1] then
		sel = s.mail[1].id
	end
	local current
	for _, m in ipairs(s.mail) do
		if m.id == sel then
			current = m
		end
		local pending = m.choices and not m.resolved
		local b = new("TextButton", { Text = "", BackgroundColor3 = m.id == sel and T.panel2 or T.panel, Size = UDim2.new(1, -6, 0, 54), Parent = ls })
		UI.corner(b, 8)
		new("TextLabel", { Text = m.from .. "   " .. Format.date(m.day), TextSize = 11, TextColor3 = pending and T.red or T.sub, Position = UDim2.fromOffset(10, 6), Size = UDim2.new(1, -20, 0, 14), Parent = b })
		new("TextLabel", { Text = m.subject, FontFace = (not m.read or pending) and UI.BOLD or UI.FONT, TextSize = 14, Position = UDim2.fromOffset(10, 24), Size = UDim2.new(1, -20, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd, TextWrapped = false, Parent = b })
		b.MouseButton1Click:Connect(function()
			sel = m.id
			Net.act("markRead", m.id)
			Mail.mount(ctx, Net.state)
		end)
	end
	local right = new("Frame", { BackgroundColor3 = T.panel2, Position = UDim2.fromOffset(372, 0), Size = UDim2.new(1, -372, 1, 0), Parent = ctx.body })
	UI.corner(right, 12)
	UI.pad(right, 20)
	UI.list(right, 10)
	if not current then
		UI.label(right, "Inbox empty", 16, T.sub)
		return
	end
	UI.label(right, current.subject, 24, T.text, { FontFace = UI.HEAVY })
	UI.label(right, "From " .. current.from .. "   |   " .. Format.date(current.day), 13, T.sub)
	UI.label(right, current.body or "", 16, T.text)
	if current.choices then
		if current.resolved then
			UI.label(right, "You chose: " .. current.resolved, 15, T.green)
		else
			UI.label(right, "Decide soon. At high speed, unanswered emails resolve badly on their own.", 12, T.yellow)
			local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), Parent = right })
			UI.list(row, 8, true)
			for i, c in ipairs(current.choices) do
				UI.button(row, c.label, function()
					Net.act("mailChoice", current.id, i)
				end, i == 1 and "primary" or "ghost", { Size = UDim2.fromOffset(math.max(140, #c.label * 9 + 30), 38) })
			end
		end
	end
end

function Mail.key(s)
	local k = tostring(sel) .. #s.mail
	for _, m in ipairs(s.mail) do
		k ..= (m.read and "r" or "u") .. (m.resolved and "x" or "")
	end
	return k
end

local Goals = { id = "goals", name = "Goals", icon = "goals", color = Color3.fromRGB(240, 90, 90) }
function Goals.mount(ctx, s)
	if not s then
		return
	end
	UI.clear(ctx.tabs)
	UI.clear(ctx.body)
	local sc = UI.scroll(ctx.body)
	UI.list(sc, 12)
	UI.label(sc, "This week's goals", 24, T.text, { FontFace = UI.HEAVY })
	UI.label(sc, "New goals every two weeks. Rewards grow as your company grows.", 13, T.sub)
	for i, g in ipairs(s.goals) do
		local c = UI.card(sc)
		UI.list(c, 6)
		UI.label(c, g.text, 18, g.claimed and T.dim or T.text, { FontFace = UI.BOLD })
		local h = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 10), Parent = c })
		UI.bar(h, g.progress / g.target, g.progress >= g.target and T.green or T.accent, 10)
		UI.label(c, string.format("%s / %s   reward %s", Format.count(g.progress), Format.count(g.target), Format.money(g.reward)), 13, T.sub)
		if g.claimed then
			UI.label(c, "Claimed", 14, T.green)
		elseif g.progress >= g.target then
			UI.button(c, "Claim " .. Format.money(g.reward), function()
				Net.act("claimGoal", i)
			end, "success")
		end
	end
end
function Goals.key(s)
	local k = ""
	for _, g in ipairs(s.goals) do
		k ..= g.text .. g.progress .. tostring(g.claimed)
	end
	return k
end

return { Mail = Mail, Goals = Goals }
