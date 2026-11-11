--!strict
-- Lab: Train (many options, mixes, combos, live prediction), Models, Research, Arena.
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local Shared = RS:WaitForChild("Shared")
local Format = require(Shared.Format)
local Opts = require(Shared.TrainingOptions)
local TM = require(Shared.TrainingMath)
local Research = require(Shared.Research)
local Catalog = require(Shared.Catalog)
local Hardware = require(Shared.Hardware)
local UI = require(script.Parent.UI)
local Net = require(script.Parent.Net)
local T = UI.T
local new = UI.new

local Lab = { id = "lab", name = "Lab", icon = "lab", color = Color3.fromRGB(70, 190, 120) }
local page = "train"
local stageIdx = 1
local recipe = Opts.defaultRecipe()
recipe.name = ""
local selectedModel: number? = nil
local preview: any = {}
local Playground -- set later (require cycle safe)

local function ctxFromState(s)
	local fx = s.staffFx or {}
	local best = 0
	for _, m in ipairs(s.models) do
		if m.status == "released" and m.cap > best then
			best = m.cap
		end
	end
	return { researched = s.research.done, algo = s.algo, clusterPower = s.clusterPower, staff = fx, bestCap = best > 0 and best or nil, year = s.year }
end

local function pill(parent, text, color, filled)
	local l = new("TextLabel", { Text = text, FontFace = UI.BOLD, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = filled and 0 or 0.8, BackgroundColor3 = color, TextColor3 = filled and T.bg or color, Size = UDim2.fromOffset(#text * 7 + 20, 22), Parent = parent })
	UI.corner(l, 11)
	return l
end

local function tabs(ctx)
	UI.clear(ctx.tabs)
	for _, p in ipairs({ { "train", "Train" }, { "models", "Models" }, { "research", "Research" }, { "arena", "Arena" } }) do
		UI.button(ctx.tabs, p[2], function()
			page = p[1]
			Lab.mount(ctx, Net.state)
		end, page == p[1] and "primary" or "ghost", { Size = UDim2.fromOffset(110, 34) })
	end
end

-- ===================== TRAIN =====================
local previewWidgets: any = {}

local function updatePreview(s)
	if not s or not previewWidgets.cap then
		return
	end
	local ev = TM.evaluate(recipe, ctxFromState(s))
	preview = ev
	local F = s.frontier
	previewWidgets.cap.Text = string.format("%.0f", ev.cap)
	previewWidgets.capSub.Text = string.format("Frontier today: %.0f  (%s)", F, ev.cap >= F and "you would be number one" or string.format("%.0f behind", F - ev.cap))
	previewWidgets.capFill.Size = UDim2.fromScale(math.clamp(ev.cap / math.max(F * 1.1, 1), 0, 1), 1)
	previewWidgets.capFill.BackgroundColor3 = ev.cap >= F and T.green or (ev.cap >= F - 8 and T.yellow or T.accent)
	previewWidgets.frontLine.Position = UDim2.fromScale(math.clamp(F / math.max(F * 1.1, 1), 0, 1), 0)
	local days = ev.days
	local rentDay = 0
	for id, n in pairs(s.gpus.rented) do
		rentDay += Hardware.rentPrice(Hardware.byId[id], s.year) * 24 * n
	end
	local dayStr = days > 730 and "years" or (math.ceil(days) .. " days")
	previewWidgets.time.Text = string.format("%s   (%s real time at x1)", dayStr, days > 730 and "forever" or (string.format("%.1f min", days * 4 / 60)))
	previewWidgets.cost.Text = string.format("Up front %s   |   GPUs %s/day", Format.money(ev.extraCost), Format.money(rentDay))
	previewWidgets.size.Text = string.format("%s params, %s tokens, %s FLOP", Format.count(ev.params), Format.count(ev.tokens), string.format("%.1e", ev.flop))
	-- abilities
	UI.clear(previewWidgets.abil)
	for _, d in ipairs({ "coding", "math", "reasoning", "writing", "knowledge", "multilingual", "agents", "vision" }) do
		local v = ev.abilities[d] or 0
		local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Parent = previewWidgets.abil })
		new("TextLabel", { Text = d:sub(1, 1):upper() .. d:sub(2), TextSize = 12, TextColor3 = T.sub, Size = UDim2.new(0, 90, 1, 0), Parent = row })
		local holder = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(92, 4), Size = UDim2.new(1, -130, 0, 8), Parent = row })
		UI.bar(holder, (v + 6) / 30, v >= 6 and T.green or (v >= 0 and T.accent or T.red), 8)
		new("TextLabel", { Text = string.format("%+.0f", v), TextSize = 12, TextColor3 = T.sub, Position = UDim2.new(1, -34, 0, 0), Size = UDim2.new(0, 34, 1, 0), TextXAlignment = Enum.TextXAlignment.Right, Parent = row })
	end
	-- combos / warnings / locked
	UI.clear(previewWidgets.notes)
	for _, c in ipairs(ev.combos) do
		UI.label(previewWidgets.notes, "+" .. c.bonus .. "  " .. c.name .. ": " .. c.text, 13, T.green)
	end
	for _, w in ipairs(ev.warnings) do
		UI.label(previewWidgets.notes, "!  " .. w, 13, T.yellow)
	end
	if #ev.locked > 0 then
		UI.label(previewWidgets.notes, "Locked (research first): " .. table.concat(ev.locked, ", "), 13, T.red)
	end
	if ev.flaws.escape > 0.05 then
		UI.label(previewWidgets.notes, "!  Strong agent + weak safety: this model might try to escape", 13, T.red)
	end
	if ev.flaws.jailbreak > 0.7 then
		UI.label(previewWidgets.notes, "Jailbreak risk is high. Add red-teaming or refusal tuning.", 13, T.orange)
	end
	if #ev.combos == 0 and #ev.warnings == 0 then
		UI.label(previewWidgets.notes, "Tip: combine options for combo bonuses (code + reasoning RL, MoE + MLA + FP8...)", 12, T.dim)
	end
	local canTrain = not s.training and #ev.locked == 0 and days <= 730
	previewWidgets.train.BackgroundColor3 = canTrain and T.green or T.line
	previewWidgets.train.Text = s.training and "A model is already training" or ("Train " .. (recipe.name ~= "" and recipe.name or (s.company .. "-" .. (#s.models + 1))))
end

local function optionChip(parent, o, selected, onClick, locked)
	local b = new("TextButton", { Text = "", BackgroundColor3 = selected and T.accent or T.panel2, Size = UDim2.fromOffset(188, 62), Parent = parent })
	UI.corner(b, 10)
	if locked then
		b.BackgroundColor3 = T.bg
		UI.stroke(b, T.line, 1)
	end
	new("TextLabel", { Text = o.name, FontFace = UI.BOLD, TextSize = 13, TextColor3 = locked and T.dim or T.text, Position = UDim2.fromOffset(10, 6), Size = UDim2.new(1, -20, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd, TextWrapped = false, Parent = b })
	new("TextLabel", { Text = locked and ("Research: " .. (Research.byId[o.req] and Research.byId[o.req].name or o.req)) or o.desc, TextSize = 11, TextColor3 = selected and Color3.fromRGB(225, 232, 255) or T.sub, Position = UDim2.fromOffset(10, 24), Size = UDim2.new(1, -20, 0, 34), TextYAlignment = Enum.TextYAlignment.Top, Parent = b })
	b.MouseButton1Click:Connect(function()
		if locked then
			Net.toast("Research " .. (Research.byId[o.req] and Research.byId[o.req].name or "it") .. " first (Lab > Research)", "warn")
			return
		end
		onClick()
	end)
	return b
end

local function slider(parent, o, getV, setV, onChange, locked)
	local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), Parent = parent })
	new("TextLabel", { Text = o.name, FontFace = UI.BOLD, TextSize = 13, TextColor3 = locked and T.dim or T.text, Size = UDim2.new(0, 210, 0, 18), Parent = row })
	new("TextLabel", { Text = locked and "locked" or o.desc, TextSize = 11, TextColor3 = T.dim, Position = UDim2.fromOffset(0, 18), Size = UDim2.new(0, 210, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd, TextWrapped = false, Parent = row })
	local track = new("TextButton", { Text = "", BackgroundColor3 = T.line, Position = UDim2.new(0, 220, 0, 14), Size = UDim2.new(1, -290, 0, 10), Parent = row })
	UI.corner(track, 5)
	local fill = new("Frame", { BackgroundColor3 = locked and T.dim or T.teal, Size = UDim2.fromScale(getV() / 100, 1), Parent = track })
	UI.corner(fill, 5)
	local knob = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.new(1, 1, 1), Position = UDim2.fromScale(getV() / 100, 0.5), Size = UDim2.fromOffset(18, 18), Parent = track })
	UI.corner(knob, 9)
	local val = new("TextLabel", { Text = getV() .. "%", FontFace = UI.BOLD, TextSize = 14, Position = UDim2.new(1, -60, 0, 8), Size = UDim2.fromOffset(60, 20), TextXAlignment = Enum.TextXAlignment.Right, Parent = row })
	if locked then
		return row
	end
	local dragging = false
	local function setFromX(x)
		local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		local v = math.floor(rel * 60 + 0.5) -- max 60% per ingredient
		setV(v)
		fill.Size = UDim2.fromScale(v / 100, 1)
		knob.Position = UDim2.fromScale(v / 100, 0.5)
		val.Text = v .. "%"
		onChange()
	end
	track.MouseButton1Down:Connect(function(x)
		dragging = true
		setFromX(x)
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			setFromX(input.Position.X)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	return row
end

local function buildTrain(body, s)
	-- Training in progress view
	if s.training then
		local t = s.training
		local col = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = body })
		UI.list(col, 12)
		UI.label(col, "Training " .. t.name, 26, T.text, { FontFace = UI.HEAVY })
		local sub = UI.label(col, "", 14, T.sub)
		local barHolder = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Parent = col })
		local _, fill = UI.bar(barHolder, t.progress, T.purple, 16)
		local card = UI.card(col)
		UI.label(card, "Training loss", 14, T.sub)
		local chartHolder = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 220), Position = UDim2.fromOffset(0, 24), Parent = card })
		local spikes = UI.label(col, "", 14, T.yellow)
		UI.label(col, string.format("Predicted capability %.0f. The real number is only known when it finishes (scout runs and private evals make the prediction tighter).", t.cap), 13, T.dim)
		UI.button(col, "Cancel run", function()
			Net.act("cancelTraining")
		end, "danger")
		previewWidgets = {}
		Lab.liveTrain = function(st)
			local tt = st.training
			if not tt then
				return
			end
			sub.Text = string.format("%d%% done   |   about %d days left   |   %s", math.floor(tt.progress * 100), math.ceil(tt.daysLeft or tt.days), Format.date(st.day))
			fill.Size = UDim2.fromScale(tt.progress, 1)
			UI.clear(chartHolder)
			UI.chart(chartHolder, tt.losses, T.purple, 220)
			spikes.Text = tt.spikes > 0 and (tt.spikes .. " loss spike(s) so far. Infra engineers and frequent checkpoints help.") or ""
		end
		Lab.liveTrain(s)
		return
	end
	Lab.liveTrain = nil

	-- Left: stage list
	local left = new("Frame", { BackgroundColor3 = T.panel, Size = UDim2.new(0, 190, 1, 0), Parent = body })
	UI.corner(left, 14)
	UI.pad(left, 10)
	UI.list(left, 6)
	UI.label(left, "Recipe", 13, T.dim)
	local stages = { { name = "Model", id = "_size" } }
	for _, st in ipairs(Opts.stages) do
		table.insert(stages, st)
	end
	for i, st in ipairs(stages) do
		local b = UI.button(left, st.name, function()
			stageIdx = i
			Lab.mount(Lab.ctx, Net.state, true)
		end, stageIdx == i and "primary" or "ghost", { Size = UDim2.new(1, 0, 0, 38), TextXAlignment = Enum.TextXAlignment.Left })
		UI.pad(b, 0, 12)
	end

	-- Center: options
	local center = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(204, 0), Size = UDim2.new(1, -204 - 370, 1, 0), Parent = body })
	local scroll = UI.scroll(center)
	UI.list(scroll, 10)
	UI.pad(scroll, 0, 0, 10, 8)
	local function changed()
		updatePreview(Net.state)
	end
	local st = stages[stageIdx]
	if st.id == "_size" then
		UI.label(scroll, "Name your model", 13, T.sub)
		local box = new("TextBox", { Text = recipe.name, PlaceholderText = s.company .. "-" .. (#s.models + 1), PlaceholderColor3 = T.dim, ClearTextOnFocus = false, BackgroundTransparency = 0, BackgroundColor3 = T.panel2, Size = UDim2.new(1, 0, 0, 40), TextSize = 16, Parent = scroll })
		UI.corner(box, 10)
		UI.pad(box, 0, 12)
		box:GetPropertyChangedSignal("Text"):Connect(function()
			recipe.name = box.Text:sub(1, 32)
			changed()
		end)
		UI.label(scroll, "Size (parameters)", 13, T.sub)
		local grid = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = scroll })
		new("UIGridLayout", { CellSize = UDim2.fromOffset(96, 44), CellPadding = UDim2.fromOffset(8, 8), Parent = grid })
		for _, sz in ipairs(Opts.SIZES) do
			local label = sz >= 1000 and string.format("%gT", sz / 1000) or (string.format("%gB", sz))
			UI.button(grid, label, function()
				recipe.size = sz
				Lab.mount(Lab.ctx, Net.state, true)
			end, recipe.size == sz and "primary" or "ghost")
		end
		UI.label(scroll, "How much data", 13, T.sub)
		local tg = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = scroll })
		new("UIGridLayout", { CellSize = UDim2.fromOffset(188, 62), CellPadding = UDim2.fromOffset(8, 8), Parent = tg })
		for _, t in ipairs(Opts.TOKEN_RATIOS) do
			optionChip(tg, { name = t.name .. " (" .. t.ratio .. "x)", desc = t.desc }, recipe.tokens == t.id, function()
				recipe.tokens = t.id
				Lab.mount(Lab.ctx, Net.state, true)
			end)
		end
		UI.label(scroll, "Bigger models need more GPUs. Rent them in Parts. A 7B model on a laptop takes forever; on 64 H100s it takes weeks.", 12, T.dim)
	else
		for _, g in ipairs(st.groups) do
			UI.label(scroll, g.name .. (g.mode == "multi" and "   (pick any)" or (g.mode == "single" and "   (pick one)" or "   (drag to mix)")), 14, T.sub, { FontFace = UI.BOLD })
			if g.mode == "mix" then
				local total = 0
				for _, o in ipairs(g.options) do
					total += recipe.mix[o.id] or 0
				end
				local totalL = UI.label(scroll, "Total " .. total .. "% (normalised to 100% when training)", 12, T.dim)
				for _, o in ipairs(g.options) do
					local locked = o.req and not s.research.done[o.req]
					slider(scroll, o, function()
						return recipe.mix[o.id] or 0
					end, function(v)
						recipe.mix[o.id] = v
						local t2 = 0
						for _, oo in ipairs(g.options) do
							t2 += recipe.mix[oo.id] or 0
						end
						totalL.Text = "Total " .. t2 .. "% (normalised to 100% when training)"
					end, changed, locked)
				end
			else
				local grid = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = scroll })
				new("UIGridLayout", { CellSize = UDim2.fromOffset(188, 62), CellPadding = UDim2.fromOffset(8, 8), Parent = grid })
				for _, o in ipairs(g.options) do
					local locked = o.req and not s.research.done[o.req]
					local selected
					if g.mode == "single" then
						selected = recipe.choices[g.id] == o.id
					else
						selected = recipe.choices[g.id] and recipe.choices[g.id][o.id]
					end
					optionChip(grid, o, selected, function()
						if g.mode == "single" then
							recipe.choices[g.id] = o.id
						else
							recipe.choices[g.id] = recipe.choices[g.id] or {}
							recipe.choices[g.id][o.id] = not recipe.choices[g.id][o.id] or nil
						end
						Lab.mount(Lab.ctx, Net.state, true)
					end, locked)
				end
			end
		end
	end

	-- Right: prediction
	local right = new("Frame", { BackgroundColor3 = T.panel, AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, 356, 1, 0), Parent = body })
	UI.corner(right, 14)
	UI.pad(right, 14)
	local rs = UI.scroll(right)
	UI.list(rs, 6)
	UI.label(rs, "Predicted capability", 13, T.sub)
	local capL = UI.label(rs, "0", 44, T.text, { FontFace = UI.HEAVY })
	local barHolder = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 12), Parent = rs })
	local _, capFill = UI.bar(barHolder, 0, T.accent, 12)
	local frontLine = new("Frame", { BackgroundColor3 = T.red, Size = UDim2.new(0, 3, 1, 6), Position = UDim2.fromScale(0.9, 0), AnchorPoint = Vector2.new(0.5, 0.25), Parent = barHolder })
	local capSub = UI.label(rs, "", 12, T.sub)
	UI.label(rs, "Training time", 13, T.sub)
	local timeL = UI.label(rs, "", 15, T.text, { FontFace = UI.BOLD })
	local costL = UI.label(rs, "", 12, T.sub)
	local sizeL = UI.label(rs, "", 11, T.dim)
	UI.label(rs, "Abilities (vs average)", 13, T.sub)
	local abil = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = rs })
	UI.list(abil, 4)
	local notes = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = rs })
	UI.list(notes, 4)
	local trainBtn = UI.button(rs, "Train", function()
		local r = table.clone(recipe)
		local ok = Net.act("train", r)
		if ok then
			Net.toast("Training started. Watch the loss go down.", "good")
			recipe.name = ""
		end
	end, "success", { Size = UDim2.new(1, -8, 0, 50), TextSize = 18 })
	previewWidgets = { cap = capL, capSub = capSub, capFill = capFill, frontLine = frontLine, time = timeL, cost = costL, size = sizeL, abil = abil, notes = notes, train = trainBtn }
	updatePreview(s)
end

-- ===================== MODELS =====================
local function statusColor(st)
	return ({ ready = T.yellow, released = T.green, delayed = T.orange, retired = T.dim })[st] or T.sub
end

local function releaseDialog(body, m, s)
	local overlay = new("TextButton", { Text = "", BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.4, Size = UDim2.fromScale(1, 1), ZIndex = 40, Parent = body })
	local d = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(560, 470), BackgroundColor3 = T.panel, ZIndex = 41, Parent = overlay })
	UI.corner(d, 16)
	UI.pad(d, 18)
	UI.list(d, 10)
	local function z(x)
		for _, c in ipairs(x:GetDescendants()) do
			if c:IsA("GuiObject") then
				c.ZIndex = 42
			end
		end
	end
	UI.label(d, "Release " .. m.name, 22, T.text, { FontFace = UI.HEAVY })
	local opts = { price = 10, open = false, campaign = 1, reviewers = false, reserve = false }
	local best = s.leaderboard[1]
	UI.label(d, "API price per 1M output tokens. The leader charges about $" .. (best and "?" or "10") .. ". Cheaper = more developers, but less money per token.", 12, T.sub)
	local priceRow = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), Parent = d })
	UI.list(priceRow, 6, true)
	local priceBtns = {}
	for _, p in ipairs({ 0.5, 2, 5, 10, 15, 30, 60 }) do
		priceBtns[p] = UI.button(priceRow, "$" .. p, function()
			opts.price = p
			for pp, b in pairs(priceBtns) do
				b.BackgroundColor3 = pp == p and T.accent or T.panel2
			end
		end, p == 10 and "primary" or "ghost", { Size = UDim2.fromOffset(64, 34) })
	end
	local function toggle(text, key, cost)
		local b
		b = UI.button(d, text .. (cost and ("   " .. cost) or ""), function()
			opts[key] = not opts[key]
			b.BackgroundColor3 = opts[key] and T.green or T.panel2
		end, "ghost", { Size = UDim2.new(1, 0, 0, 38), TextXAlignment = Enum.TextXAlignment.Left })
		UI.pad(b, 0, 14)
	end
	toggle("Open weights (community loves it, competitors copy it)", "open")
	toggle("Send to tech reviewers first", "reviewers", "$80K")
	toggle("Reserve extra servers for launch day", "reserve", Format.money(200e3 * (1 + s.users / 1e6)))
	UI.label(d, "Marketing campaign", 12, T.sub)
	local campRow = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), Parent = d })
	UI.list(campRow, 6, true)
	local campBtns = {}
	for i, c in ipairs({ "Quiet drop", "Teasers", "Big launch", "Super Bowl ad" }) do
		campBtns[i - 1] = UI.button(campRow, c, function()
			opts.campaign = i - 1
			for k, b in pairs(campBtns) do
				b.BackgroundColor3 = k == i - 1 and T.accent or T.panel2
			end
		end, i == 2 and "primary" or "ghost", { Size = UDim2.fromOffset(122, 34) })
	end
	local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 50), Parent = d })
	UI.list(row, 10, true)
	UI.button(row, "Cancel", function()
		overlay:Destroy()
	end, "ghost", { Size = UDim2.fromOffset(120, 46) })
	UI.button(row, "RELEASE", function()
		local ok, result = Net.act("release", m.id, opts)
		overlay:Destroy()
		if ok and result and Lab.onLaunch then
			Lab.onLaunch(result)
		end
	end, T.red, { Size = UDim2.fromOffset(380, 46), TextSize = 20, FontFace = UI.HEAVY })
	z(overlay)
end

local function evalPanel(parent, m)
	local EV = { { "contam", "Contamination audit", 60e3 }, { "halluc", "Hallucination eval", 40e3 }, { "syco", "Sycophancy eval", 40e3 }, { "jailbreak", "Red team", 150e3 }, { "escape", "Dangerous capability eval", 250e3 } }
	local names = { contam = "Contamination", halluc = "Hallucination", syco = "Sycophancy", jailbreak = "Jailbreak risk", escape = "Escape risk", refuse = "Refusals", safety = "Safety score" }
	local grid = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = parent })
	new("UIGridLayout", { CellSize = UDim2.fromOffset(200, 54), CellPadding = UDim2.fromOffset(8, 8), Parent = grid })
	for _, e in ipairs(EV) do
		local key = e[1]
		local v = m.flaws[key]
		local f = new("Frame", { BackgroundColor3 = T.panel, Parent = grid })
		UI.corner(f, 10)
		UI.pad(f, 6, 10)
		new("TextLabel", { Text = names[key], TextSize = 12, TextColor3 = T.sub, Size = UDim2.new(1, 0, 0, 16), Parent = f })
		if v ~= nil then
			local bad = v > (key == "escape" and 0.05 or 0.3)
			new("TextLabel", { Text = string.format("%d%%", math.floor(v * 100)), FontFace = UI.BOLD, TextSize = 18, TextColor3 = bad and T.red or T.green, Position = UDim2.fromOffset(0, 18), Size = UDim2.new(1, 0, 0, 22), Parent = f })
		elseif m.status ~= "retired" then
			local b = UI.button(f, "Run " .. Format.money(e[3]), function()
				Net.act("runEval", m.id, key)
			end, "ghost", { Position = UDim2.fromOffset(0, 18), Size = UDim2.new(1, 0, 0, 24), TextSize = 12 })
		end
	end
end

local function buildModels(body, s)
	if #s.models == 0 then
		UI.label(body, "No models yet. Go to Train.", 18, T.sub)
		return
	end
	local list = new("Frame", { BackgroundColor3 = T.panel, Size = UDim2.new(0, 280, 1, 0), Parent = body })
	UI.corner(list, 14)
	UI.pad(list, 8)
	local ls = UI.scroll(list)
	UI.list(ls, 6)
	if not selectedModel or not s.models[selectedModel] then
		selectedModel = #s.models
	end
	for i = #s.models, 1, -1 do
		local m = s.models[i]
		local b = new("TextButton", { Text = "", BackgroundColor3 = selectedModel == m.id and T.panel2 or T.panel, Size = UDim2.new(1, -6, 0, 58), Parent = ls })
		UI.corner(b, 10)
		new("TextLabel", { Text = m.name, FontFace = UI.BOLD, TextSize = 15, Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -24, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd, TextWrapped = false, Parent = b })
		new("TextLabel", { Text = string.format("%s   cap %.0f   %s users", m.status:upper(), m.cap, Format.count(m.users or 0)), TextSize = 12, TextColor3 = statusColor(m.status), Position = UDim2.fromOffset(12, 30), Size = UDim2.new(1, -24, 0, 16), Parent = b })
		b.MouseButton1Click:Connect(function()
			selectedModel = m.id
			Lab.mount(Lab.ctx, Net.state, true)
		end)
	end
	local m = s.models[selectedModel :: number]
	local right = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(294, 0), Size = UDim2.new(1, -294, 1, 0), Parent = body })
	local sc = UI.scroll(right)
	UI.list(sc, 10)
	UI.pad(sc, 0, 0, 12, 8)
	local head = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 44), Parent = sc })
	new("TextLabel", { Text = m.name, FontFace = UI.HEAVY, TextSize = 30, Size = UDim2.new(1, -200, 1, 0), Parent = head })
	local p = pill(head, m.status:upper(), statusColor(m.status), true)
	p.AnchorPoint = Vector2.new(1, 0.5)
	p.Position = UDim2.new(1, 0, 0.5, 0)
	-- stats
	local stats = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 70), Parent = sc })
	new("UIGridLayout", { CellSize = UDim2.new(0.25, -8, 0, 66), CellPadding = UDim2.fromOffset(8, 0), Parent = stats })
	local function stat(label, value, color)
		local c = new("Frame", { BackgroundColor3 = T.panel2, Parent = stats })
		UI.corner(c, 12)
		UI.pad(c, 8, 12)
		new("TextLabel", { Text = label, TextSize = 12, TextColor3 = T.sub, Size = UDim2.new(1, 0, 0, 16), Parent = c })
		new("TextLabel", { Text = value, FontFace = UI.HEAVY, TextSize = 22, TextColor3 = color or T.text, Position = UDim2.fromOffset(0, 18), Size = UDim2.new(1, 0, 0, 28), Parent = c })
	end
	stat("Capability", string.format("%.1f", m.cap), m.cap >= s.frontier and T.green or T.text)
	stat("Arena Elo", tostring(m.elo or "-"), T.purple)
	stat("Users", Format.count(m.users or 0), T.teal)
	stat("Reception", m.reception and (m.reception .. "/100") or "-", T.yellow)
	-- features
	local feats = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), Parent = sc })
	UI.list(feats, 6, true)
	pill(feats, (m.size >= 1000 and string.format("%gT", m.size / 1000) or (m.size .. "B")), T.sub)
	pill(feats, (m.context >= 1e6 and (math.floor(m.context / 1e6) .. "M") or (math.floor(m.context / 1e3) .. "K")) .. " context", T.sub)
	for f in pairs(m.features or {}) do
		pill(feats, f, T.accent)
	end
	if m.open then
		pill(feats, "open weights", T.green)
	end
	if m.character then
		pill(feats, m.character, T.pink)
	end
	-- actions
	local acts = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), Parent = sc })
	UI.list(acts, 8, true)
	UI.button(acts, "Chat with it", function()
		if Playground then
			Playground.open(Lab.ctx.body, m, Net.state)
		end
	end, T.purple)
	if m.status == "ready" then
		UI.button(acts, "RELEASE", function()
			releaseDialog(Lab.ctx.body, m, Net.state)
		end, T.red, { FontFace = UI.HEAVY })
		UI.button(acts, "Delay 2 weeks (more safety work)", function()
			Net.act("delay", m.id)
		end, "ghost")
	elseif m.status == "delayed" then
		UI.label(acts, "Extra red-teaming until " .. Format.date(m.delayUntil), 14, T.orange, { Size = UDim2.fromOffset(400, 36) })
	elseif m.status == "released" then
		UI.button(acts, "Use in app", function()
			Net.act("setActive", m.id)
		end, s.product.activeModel == m.id and "success" or "ghost")
	end
	-- evals
	UI.label(sc, "Pre-launch evals (pay to find hidden problems)", 15, T.text, { FontFace = UI.BOLD })
	evalPanel(sc, m)
	-- benchmarks
	if m.benchmarks then
		UI.label(sc, "Benchmarks vs the best rival", 15, T.text, { FontFace = UI.BOLD })
		local bt = UI.card(sc)
		UI.list(bt, 6)
		for _, b in ipairs(m.benchmarks) do
			local r = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), Parent = bt })
			new("TextLabel", { Text = b.name, TextSize = 13, Size = UDim2.new(0, 170, 1, 0), Parent = r })
			local h = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(176, 6), Size = UDim2.new(1, -330, 0, 10), Parent = r })
			UI.bar(h, b.score / 100, b.score >= b.sota and T.green or T.accent, 10)
			new("Frame", { BackgroundColor3 = T.red, Position = UDim2.new(b.sota / 100, 0, 0, -3), Size = UDim2.new(0, 2, 1, 6), Parent = h })
			new("TextLabel", { Text = string.format("%.1f  vs %.1f", b.score, b.sota), FontFace = UI.MONO, TextSize = 12, TextColor3 = b.score >= b.sota and T.green or T.sub, Position = UDim2.new(1, -150, 0, 0), Size = UDim2.new(0, 150, 1, 0), TextXAlignment = Enum.TextXAlignment.Right, Parent = r })
		end
	end
	-- updates
	if m.status == "released" then
		UI.label(sc, "Update " .. m.name, 15, T.text, { FontFace = UI.BOLD })
		if m.updating then
			UI.label(sc, "Working on an update until " .. Format.date(m.updating.doneDay), 13, T.yellow)
		end
		local grid = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = sc })
		new("UIGridLayout", { CellSize = UDim2.fromOffset(230, 78), CellPadding = UDim2.fromOffset(8, 8), Parent = grid })
		for _, u in ipairs(Catalog.updates) do
			local has = u.feature and m.features[u.feature]
			local locked = u.req and not s.research.done[u.req]
			local b = new("TextButton", { Text = "", BackgroundColor3 = has and T.bg or T.panel2, Parent = grid })
			UI.corner(b, 10)
			new("TextLabel", { Text = u.name, FontFace = UI.BOLD, TextSize = 13, TextColor3 = (locked or has) and T.dim or T.text, Position = UDim2.fromOffset(10, 6), Size = UDim2.new(1, -20, 0, 16), Parent = b })
			new("TextLabel", { Text = has and "Already has it" or (locked and ("Research " .. Research.byId[u.req].name) or (u.desc .. "  " .. u.days .. "d")), TextSize = 11, TextColor3 = T.sub, Position = UDim2.fromOffset(10, 24), Size = UDim2.new(1, -20, 0, 48), TextYAlignment = Enum.TextYAlignment.Top, Parent = b })
			b.MouseButton1Click:Connect(function()
				if not has and not locked then
					Net.act("update", m.id, u.id)
				end
			end)
		end
	end
end

-- ===================== RESEARCH =====================
local function buildResearch(body, s)
	local sc = UI.scroll(body)
	UI.list(sc, 10)
	local cur = s.research.current and Research.byId[s.research.current]
	local head = UI.card(sc)
	UI.list(head, 6)
	local rp = 0.6 + (s.staffFx.research or 0)
	UI.label(head, cur and ("Researching: " .. cur.name) or "Pick something to research", 18, T.text, { FontFace = UI.BOLD })
	if cur then
		local h = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 10), Parent = head })
		UI.bar(h, s.research.points / cur.cost, T.purple, 10)
	end
	UI.label(head, string.format("%.1f research points per day. Hire ML engineers and star researchers to go faster. Algorithmic efficiency x%.2f", rp, s.algo), 12, T.sub)
	local tiers = {}
	for _, n in ipairs(Research.nodes) do
		tiers[n.tier] = tiers[n.tier] or {}
		table.insert(tiers[n.tier], n)
	end
	for tier = 1, 9 do
		if tiers[tier] then
			UI.label(sc, "Tier " .. tier, 13, T.dim)
			local grid = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = sc })
			new("UIGridLayout", { CellSize = UDim2.fromOffset(240, 92), CellPadding = UDim2.fromOffset(8, 8), Parent = grid })
			for _, n in ipairs(tiers[tier]) do
				local done = s.research.done[n.id]
				local reqOk = true
				for _, r in ipairs(n.req or {}) do
					if not s.research.done[r] then
						reqOk = false
					end
				end
				local tooEarly = s.day < n.fromDay - math.min(180, (s.staff.star or 0) * 60)
				local active = s.research.current == n.id
				local b = new("TextButton", { Text = "", BackgroundColor3 = done and Color3.fromRGB(28, 60, 44) or (active and Color3.fromRGB(50, 40, 90) or T.panel2), Parent = grid })
				UI.corner(b, 12)
				if active then
					UI.stroke(b, T.purple, 2)
				end
				new("TextLabel", { Text = n.name, FontFace = UI.BOLD, TextSize = 14, TextColor3 = (reqOk and not tooEarly or done) and T.text or T.dim, Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -24, 0, 18), Parent = b })
				local status = done and "Done" or (not reqOk and ("Needs " .. table.concat((function()
					local t = {}
					for _, r in ipairs(n.req or {}) do
						if not s.research.done[r] then
							table.insert(t, Research.byId[r].name)
						end
					end
					return t
				end)(), ", ")) or (tooEarly and ("Not invented until " .. Format.monthYear(n.fromDay)) or (n.cost .. " points")))
				new("TextLabel", { Text = n.desc, TextSize = 11, TextColor3 = T.sub, Position = UDim2.fromOffset(12, 28), Size = UDim2.new(1, -24, 0, 30), TextYAlignment = Enum.TextYAlignment.Top, Parent = b })
				new("TextLabel", { Text = status, FontFace = UI.BOLD, TextSize = 11, TextColor3 = done and T.green or (reqOk and not tooEarly and T.yellow or T.dim), Position = UDim2.fromOffset(12, 66), Size = UDim2.new(1, -24, 0, 16), Parent = b })
				b.MouseButton1Click:Connect(function()
					if not done then
						Net.act("setResearch", n.id)
					end
				end)
			end
		end
	end
end

-- ===================== ARENA =====================
local function buildArena(body, s)
	local sc = UI.scroll(body)
	UI.list(sc, 6)
	UI.label(sc, "Arena leaderboard  (each lab's best model)", 18, T.text, { FontFace = UI.BOLD })
	for i, e in ipairs(s.leaderboard) do
		local r = new("Frame", { BackgroundColor3 = e.you and Color3.fromRGB(30, 56, 44) or T.panel2, Size = UDim2.new(1, -8, 0, 44), Parent = sc })
		UI.corner(r, 10)
		new("TextLabel", { Text = "#" .. i, FontFace = UI.HEAVY, TextSize = 18, TextColor3 = i <= 3 and T.yellow or T.sub, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(0, 50, 1, 0), Parent = r })
		new("TextLabel", { Text = e.model, FontFace = UI.BOLD, TextSize = 15, Position = UDim2.fromOffset(70, 0), Size = UDim2.new(0.4, 0, 1, 0), Parent = r })
		new("TextLabel", { Text = e.lab, TextSize = 14, TextColor3 = T.sub, Position = UDim2.new(0.45, 0, 0, 0), Size = UDim2.new(0.3, 0, 1, 0), Parent = r })
		new("TextLabel", { Text = tostring(e.elo), FontFace = UI.MONO, TextSize = 16, TextColor3 = T.purple, Position = UDim2.new(1, -110, 0, 0), Size = UDim2.new(0, 90, 1, 0), TextXAlignment = Enum.TextXAlignment.Right, Parent = r })
	end
end

-- ===================== mount =====================
function Lab.mount(ctx, s, rerender)
	Lab.ctx = ctx
	if not s then
		return
	end
	-- keep scroll positions
	tabs(ctx)
	UI.clear(ctx.body)
	Lab.liveTrain = nil
	if page == "train" then
		buildTrain(ctx.body, s)
	elseif page == "models" then
		buildModels(ctx.body, s)
	elseif page == "research" then
		buildResearch(ctx.body, s)
	else
		buildArena(ctx.body, s)
	end
end

function Lab.key(s)
	if not s then
		return ""
	end
	if page == "train" then
		local n = 0
		for _ in pairs(s.research.done) do
			n += 1
		end
		return "t" .. (s.training and "1" or "0") .. n
	elseif page == "models" then
		local k = "m"
		for _, m in ipairs(s.models) do
			local nf = 0
			for _ in pairs(m.flaws) do
				nf += 1
			end
			k ..= m.status .. (m.updating and "u" or "") .. nf .. string.format("%.0f", m.cap) .. (s.product.activeModel == m.id and "a" or "")
		end
		return k
	elseif page == "research" then
		local n = 0
		for _ in pairs(s.research.done) do
			n += 1
		end
		return "r" .. n .. tostring(s.research.current) .. math.floor(s.research.points / 20)
	end
	return "a" .. #s.leaderboard .. math.floor(s.frontier)
end

function Lab.refresh(ctx, s)
	if Lab.liveTrain then
		Lab.liveTrain(s)
	end
end

function Lab.setPlayground(p)
	Playground = p
end

function Lab.goto(p)
	page = p
end

return Lab
