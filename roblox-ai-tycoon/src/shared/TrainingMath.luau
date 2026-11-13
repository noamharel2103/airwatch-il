--!strict
-- Pure math for a training recipe. Used by the server (truth) and the Lab UI (live preview).
-- Compute ~ 6 * params * tokens (research 05). Capability = 10*log10(effective compute) - offset + bonuses.
local Shared = script.Parent
local Config = require(Shared:WaitForChild("Config"))
local Opts = require(Shared:WaitForChild("TrainingOptions"))
local Hardware = require(Shared:WaitForChild("Hardware"))
local MT = require(Shared:WaitForChild("ModelTypes"))

local M = {}

local DOMAINS = { "coding", "math", "reasoning", "writing", "knowledge", "multilingual", "vision", "audio", "agents" }
M.DOMAINS = DOMAINS

-- Iterate every chosen option (single + multi), calling fn(option)
local function eachChosen(recipe, fn)
	for _, stage in ipairs(Opts.stages) do
		for _, g in ipairs(stage.groups) do
			local c = recipe.choices[g.id]
			if g.mode == "single" and c then
				local o = Opts.optionById[c]
				if o then
					fn(o)
				end
			elseif g.mode == "multi" and type(c) == "table" then
				for id, on in pairs(c) do
					if on and Opts.optionById[id] then
						fn(Opts.optionById[id])
					end
				end
			end
		end
	end
end
M.eachChosen = eachChosen

-- ctx: { researched = {id=true}, algo = number, clusterPower = number (H100 equivalents),
--        staff = {research=, infra=, data=, safety=}, bestCap = number, year = number }
function M.evaluate(recipe, ctx)
	local tokRatio = 20
	for _, t in ipairs(Opts.TOKEN_RATIOS) do
		if t.id == recipe.tokens then
			tokRatio = t.ratio
		end
	end
	local params = recipe.size * 1e9
	local tokens = params * tokRatio
	local flop = 6 * params * tokens

	local comp, time, cost, cap = 1, 1, 0, 0
	local serve, speed, hype, noise = 1, 1, 0, 1
	local dom = {}
	for _, d in ipairs(DOMAINS) do
		dom[d] = 0
	end
	local f = { safety = 0, halluc = 0, syco = 0, refuse = 0, risk = 0, contam = 0, legal = 0 }
	local locked = {}

	eachChosen(recipe, function(o)
		if o.req and not ctx.researched[o.req] then
			table.insert(locked, o.name)
			return
		end
		local e = o.eff or {}
		comp *= e.comp or 1
		time *= e.time or 1
		serve *= e.serve or 1
		speed *= e.speed or 1
		cost += e.cost or 0
		cap += e.cap or 0
		hype += e.hype or 0
		noise += e.noise or 0
		for _, d in ipairs(DOMAINS) do
			dom[d] += e[d] or 0
		end
		for k in pairs(f) do
			f[k] += e[k] or 0
		end
	end)

	-- Data mix (percent sliders). Normalise to 100.
	local total = 0
	for id, pct in pairs(recipe.mix) do
		local o = Opts.optionById[id]
		if o and (not o.req or ctx.researched[o.req]) then
			total += pct
		end
	end
	total = math.max(total, 1)
	for id, pct in pairs(recipe.mix) do
		local o = Opts.optionById[id]
		if o and (not o.req or ctx.researched[o.req]) and pct > 0 then
			local share = pct * 100 / total
			for _, d in ipairs(DOMAINS) do
				dom[d] += (o.eff[d] or 0) * share
			end
			for k in pairs(f) do
				f[k] += (o.eff[k] or 0) * share
			end
		end
	end
	for _, d in ipairs(DOMAINS) do
		if d ~= "vision" and d ~= "audio" then
			dom[d] -= 3
		end
	end

	-- Synthetic data needs a decent teacher; model collapse when it is too much.
	local synth = (recipe.mix.synthetic or 0) * 100 / total
	if synth > 40 and not (recipe.choices.quality and recipe.choices.quality.dedup) then
		cap -= (synth - 40) * 0.2
	end

	-- Combos
	local combos = {}
	for _, cb in ipairs(Opts.combos) do
		if cb.test(recipe) then
			cap += cb.bonus
			table.insert(combos, cb)
		end
	end
	local warnings = {}
	for _, w in ipairs(Opts.warnings) do
		if w.test(recipe) then
			table.insert(warnings, w.text)
		end
	end
	if not (recipe.choices.align and recipe.choices.align.sft) then
		cap -= 8
	end
	if recipe.choices.think ~= "none" and not (recipe.choices.skills and recipe.choices.skills.rlvr) then
		dom.reasoning -= 4
	end

	-- Distillation: a small student gets close to your best model.
	local distilled = recipe.choices.compress and recipe.choices.compress.distill and ctx.researched.distill
	-- Staff: research staff give algorithmic insight; data staff improve data quality.
	local staff = ctx.staff or {}
	local staffComp = (1 + 0.12 * math.log(1 + (staff.research or 0))) * (1 + 0.08 * math.log(1 + (staff.data or 0)))
	local eff = flop * comp * (ctx.algo or 1) * staffComp
	local baseCap = 10 * math.log10(eff) - Config.CAP_OFFSET
	local finalCap = baseCap + cap + (Config.MODEL_BONUS or 0)
	if distilled and ctx.bestCap then
		finalCap = math.max(finalCap, ctx.bestCap - 6 - math.max(0, 3 - math.log10(recipe.size)) * 2)
	end

	-- Time: FLOP over cluster throughput. Infra staff raise utilisation.
	local power = math.max(ctx.clusterPower or 0, 0.01)
	local infraEff = 1 + 0.1 * math.log(1 + (staff.infra or 0))
	local days = flop / (Hardware.H100_FLOP_PER_DAY * power * infraEff) * time
	-- Post-training takes a minimum of a few days.
	days = math.max(days, 3) * (MT.get(recipe.kind).time or 1) * (Config.TRAIN_TIME or 1)

	f.safety += 15 + 3 * math.log(1 + (staff.safety or 0)) * 3
	local agentsLevel = dom.agents
	local result = {
		params = params,
		tokens = tokens,
		flop = flop,
		days = days,
		extraCost = cost * (1 + math.max(0, (ctx.year or 2023) - 2023) * 0.3),
		cap = finalCap,
		abilities = dom,
		serve = serve,
		speed = speed,
		hype = hype,
		noise = math.max(noise, 0.2),
		combos = combos,
		warnings = warnings,
		locked = locked,
		risk = math.clamp(0.05 + f.risk, 0.005, 0.6),
		flaws = {
			safety = f.safety,
			halluc = math.clamp(0.35 - finalCap / 260 + f.halluc, 0.02, 0.9),
			syco = math.clamp(0.1 + f.syco, 0, 1),
			refuse = math.clamp(0.1 + f.refuse, 0, 1),
			contam = math.clamp(0.12 + f.contam, 0, 0.9),
			legal = math.clamp(f.legal, 0, 1),
			jailbreak = math.clamp(0.95 - f.safety / 55, 0.05, 0.98),
			escape = (agentsLevel > 12 and f.safety < 30) and math.clamp((agentsLevel / 40) * (1 - f.safety / 30) * 0.6, 0, 0.5) or 0,
		},
	}
	-- Features (what the model can do in the app)
	local feats = {}
	local mod = recipe.choices.modal or {}
	local sk = recipe.choices.skills or {}
	feats.vision = mod.vision and ctx.researched.vision or nil
	feats.voice = mod.audio and ctx.researched.voice or nil
	feats.imagegen = mod.imagegen and ctx.researched.imagegen or nil
	feats.video = mod.video and ctx.researched.video or nil
	feats.reasoning = sk.rlvr and ctx.researched.reasoning or nil
	feats.tools = sk.tools and ctx.researched.tools or nil
	feats.agents = sk.agentrl and ctx.researched.agents or nil
	feats.computer = sk.computer and ctx.researched.computeruse or nil
	local ctxOpt = Opts.optionById[recipe.choices.ctx or "4k"]
	result.context = ctxOpt and ctxOpt.ctx or 4000
	result.features = feats
	return result
end

-- Fake but plausible loss curve value at progress p (0..1) for a model of capability cap.
function M.lossAt(p: number, cap: number, seed: number): number
	local final = math.max(1.2, 3.2 - cap / 60)
	local start = 10.8
	local v = final + (start - final) * math.exp(-6 * p) + 0.04 * math.sin(seed + p * 90)
	return v
end

return M
