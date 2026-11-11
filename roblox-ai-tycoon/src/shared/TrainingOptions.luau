--!strict
-- The Lab: every training decision (research 10). Stages, many options, multi-select and mixes.
-- Effect keys:
--   comp     multiplier on effective compute (capability = 10*log10)
--   time     multiplier on training time      cost  flat USD added (scaled by year where noted)
--   cap      flat capability bonus
--   coding math reasoning writing knowledge multilingual vision audio agents  -> domain bonuses (points)
--   safety (+ safer)  halluc (+ more hallucination)  syco (+ sycophancy)  refuse (+ preachy)
--   risk (+ chance a run fails / spikes)  contam (+ contamination scandal chance)  legal (+ lawsuit chance)
--   serve (multiplier on inference cost)  speed (tokens/s multiplier)  hype (launch hype)
-- req = research node id that unlocks the option.
local T = {}

T.SIZES = { 0.5, 1, 3, 7, 13, 34, 70, 180, 405, 1000, 2000, 5000, 10000 } -- billions of params (total)
T.TOKEN_RATIOS = { -- tokens per parameter
	{ id = "under", name = "Under-trained", ratio = 8, desc = "Fast and cheap. Leaves capability on the table." },
	{ id = "chinchilla", name = "Chinchilla optimal", ratio = 20, desc = "Best capability per FLOP." },
	{ id = "over", name = "Over-trained", ratio = 60, desc = "Smaller model, more data. Cheaper to serve." },
	{ id = "llama", name = "Heavily over-trained", ratio = 200, desc = "Like Llama 3: tiny model, huge data. Great for open weights." },
}

T.stages = {
	{
		id = "arch",
		name = "Architecture",
		icon = "rbxassetid://0",
		groups = {
			{ id = "arch", name = "Backbone", mode = "single", options = {
				{ id = "dense", name = "Dense transformer", desc = "Every parameter works on every token. Simple and stable.", eff = {} },
				{ id = "moe", name = "Mixture of Experts", desc = "Only some experts fire per token. Way more capacity per FLOP, trickier to train.", req = "moe", eff = { comp = 2.4, risk = 0.04, serve = 0.45 } },
				{ id = "finemoe", name = "Fine-grained MoE + shared expert", desc = "DeepSeek-style: hundreds of small experts.", req = "finemoe", eff = { comp = 3.6, risk = 0.06, serve = 0.3 } },
				{ id = "hybrid", name = "Hybrid linear attention", desc = "Mix of linear and full attention. Cheap long context, weaker recall.", req = "linear", eff = { comp = 1.6, serve = 0.5, reasoning = -2, knowledge = -1 } },
				{ id = "diffusion", name = "Diffusion LM", desc = "Writes whole blocks at once. Blazing fast, experimental.", req = "diffusion", eff = { comp = 1.3, speed = 5, risk = 0.1, reasoning = -3 } },
			} },
			{ id = "attn", name = "Attention", mode = "single", options = {
				{ id = "mha", name = "Multi-head (classic)", desc = "The 2017 original.", eff = { serve = 1.2 } },
				{ id = "gqa", name = "Grouped-query", desc = "Smaller KV cache, faster serving.", eff = { serve = 0.85, speed = 1.2 } },
				{ id = "mla", name = "Multi-head latent", desc = "Compressed KV cache. Cheap long context.", req = "mla", eff = { serve = 0.6, speed = 1.3, comp = 1.1 } },
				{ id = "sparse", name = "Sparse attention", desc = "Only looks at what matters. Halves long-context cost.", req = "sparseattn", eff = { serve = 0.45, speed = 1.4 } },
			} },
			{ id = "modal", name = "Modalities", mode = "multi", options = {
				{ id = "vision", name = "Vision input", desc = "Understands images, charts, screenshots.", req = "vision", eff = { vision = 25, time = 1.15, hype = 6 } },
				{ id = "audio", name = "Native voice", desc = "Hears and speaks with real emotion.", req = "voice", eff = { audio = 25, time = 1.15, hype = 8 } },
				{ id = "imagegen", name = "Image generation", desc = "Draws images inside the chat. Goes viral.", req = "imagegen", eff = { time = 1.2, hype = 14, legal = 0.05 } },
				{ id = "video", name = "Video understanding", desc = "Watches videos.", req = "video", eff = { vision = 10, time = 1.2, hype = 5 } },
				{ id = "gui", name = "Screen grounding", desc = "Sees a computer screen and knows where to click.", req = "computeruse", eff = { agents = 8, vision = 5, time = 1.05 } },
			} },
			{ id = "extras", name = "Extras", mode = "multi", options = {
				{ id = "mtp", name = "Multi-token prediction", desc = "Predicts several tokens at once. Faster decoding.", req = "mtp", eff = { speed = 1.6, comp = 1.05 } },
				{ id = "qknorm", name = "QK-norm", desc = "Stops loss spikes in big runs.", eff = { risk = -0.03 } },
				{ id = "bigvocab", name = "Big vocabulary (256K)", desc = "Better at non-English languages.", eff = { multilingual = 6, comp = 1.03 } },
			} },
		},
	},
	{
		id = "data",
		name = "Data",
		groups = {
			{ id = "mix", name = "Data mix (%)", mode = "mix", options = {
				{ id = "web", name = "Web crawl", desc = "Huge, messy, cheap.", default = 45, eff = { knowledge = 0.10, writing = 0.03, halluc = 0.002 } },
				{ id = "code", name = "Code (GitHub)", desc = "Makes it a coder and a better reasoner.", default = 15, eff = { coding = 0.30, reasoning = 0.08 } },
				{ id = "books", name = "Books", desc = "Long, careful prose. Licensing matters.", default = 10, eff = { writing = 0.25, knowledge = 0.08, legal = 0.002 } },
				{ id = "papers", name = "Science papers", desc = "arXiv, PubMed, textbooks.", default = 8, eff = { knowledge = 0.2, math = 0.08, reasoning = 0.05 } },
				{ id = "math", name = "Math", desc = "Proofs, problem sets, competitions.", default = 5, eff = { math = 0.45, reasoning = 0.12 } },
				{ id = "multi", name = "Multilingual", desc = "Hebrew, Chinese, Spanish, Hindi and more.", default = 7, eff = { multilingual = 0.45 } },
				{ id = "chats", name = "Conversations", desc = "Forum threads and dialogues. Friendly tone.", default = 5, eff = { writing = 0.1, syco = 0.004 } },
				{ id = "synthetic", name = "Synthetic (from your best model)", desc = "Textbook-quality data your own model writes.", default = 5, req = "synthetic", eff = { reasoning = 0.12, math = 0.1, coding = 0.08 } },
				{ id = "licensed", name = "Licensed news & media", desc = "Expensive deals, zero lawsuits.", default = 0, eff = { knowledge = 0.12, writing = 0.08, legal = -0.004 } },
				{ id = "traces", name = "Reasoning traces", desc = "Step by step solutions from your reasoning model.", default = 0, req = "reasoning", eff = { reasoning = 0.3, math = 0.15 } },
			} },
			{ id = "quality", name = "Cleaning", mode = "multi", options = {
				{ id = "dedup", name = "Deduplication", desc = "Removes repeats. Cheap, always worth it.", default = true, eff = { comp = 1.15 } },
				{ id = "edu", name = "Quality classifier", desc = "Keeps only educational pages (FineWeb-Edu style).", eff = { comp = 1.35, knowledge = 2, cost = 40e3 } },
				{ id = "decontam", name = "Benchmark decontamination", desc = "Strips test sets from training. Scores look lower, scandals vanish.", eff = { contam = -0.25, cap = -0.5 } },
				{ id = "pii", name = "PII scrub", desc = "Removes personal data. Regulators like this.", eff = { legal = -0.03, cost = 20e3 } },
				{ id = "toxic", name = "Toxicity filter", desc = "Fewer embarrassing outputs.", eff = { safety = 4, writing = -0.5 } },
			} },
			{ id = "posture", name = "Data sourcing", mode = "single", options = {
				{ id = "scrape", name = "Scrape everything", desc = "Most data, most lawsuits.", eff = { comp = 1.1, legal = 0.08 } },
				{ id = "mixed", name = "Scrape + respect opt-outs", desc = "The industry default.", eff = { legal = 0.03 } },
				{ id = "clean", name = "Licensed only", desc = "Pay publishers. Clean conscience, smaller corpus.", eff = { comp = 0.85, legal = -0.05, cost = 400e3 } },
			} },
		},
	},
	{
		id = "setup",
		name = "Training setup",
		groups = {
			{ id = "precision", name = "Precision", mode = "single", options = {
				{ id = "bf16", name = "BF16", desc = "Safe default.", eff = {} },
				{ id = "fp8", name = "FP8", desc = "Almost 2x throughput. A few more loss spikes.", req = "fp8", eff = { time = 0.6, risk = 0.03 } },
				{ id = "fp4", name = "FP4", desc = "Blackwell-era trick. Huge speedup, fragile.", req = "fp4", eff = { time = 0.38, risk = 0.07 } },
			} },
			{ id = "optim", name = "Optimizer", mode = "single", options = {
				{ id = "adamw", name = "AdamW", desc = "The standard.", eff = {} },
				{ id = "muon", name = "Muon", desc = "Newer optimizer, ~1.4x more efficient.", req = "muon", eff = { comp = 1.4, risk = 0.02 } },
			} },
			{ id = "schedule", name = "LR schedule", mode = "single", options = {
				{ id = "cosine", name = "Cosine", desc = "Classic.", eff = {} },
				{ id = "wsd", name = "Warmup-stable-decay", desc = "Lets you stop early or keep going.", eff = { comp = 1.05 } },
			} },
			{ id = "ckpt", name = "Checkpoints", mode = "single", options = {
				{ id = "rare", name = "Rare", desc = "Fastest. A crash costs you days.", eff = { time = 0.95, risk = 0.05 } },
				{ id = "normal", name = "Every few hours", desc = "Balanced.", eff = {} },
				{ id = "frequent", name = "Constant + spare nodes", desc = "Slower, almost never lose progress.", eff = { time = 1.08, risk = -0.06 } },
			} },
			{ id = "scout", name = "Planning", mode = "multi", options = {
				{ id = "scout", name = "Scaling-law scout runs", desc = "Small runs first. Your score prediction gets accurate.", eff = { time = 1.05, risk = -0.03, noise = -0.6 } },
				{ id = "curriculum", name = "Curriculum ordering", desc = "Easy data first, best data last.", eff = { comp = 1.08 } },
			} },
		},
	},
	{
		id = "mid",
		name = "Mid-training",
		groups = {
			{ id = "mid", name = "Mid-training", mode = "multi", options = {
				{ id = "anneal", name = "High-quality annealing", desc = "Finish on the best data. Cheap boost.", eff = { cap = 1.5, time = 1.04 } },
				{ id = "longctx", name = "Long-context extension", desc = "Stretch the context window at the end.", eff = { time = 1.06 } },
				{ id = "merge", name = "Checkpoint merging", desc = "Average several checkpoints. Smoother model.", eff = { cap = 0.8, risk = -0.02 } },
			} },
			{ id = "ctx", name = "Context window", mode = "single", options = {
				{ id = "4k", name = "4K tokens", ctx = 4e3, desc = "A few pages.", eff = {} },
				{ id = "32k", name = "32K tokens", ctx = 32e3, desc = "A long report.", eff = { time = 1.02 } },
				{ id = "128k", name = "128K tokens", ctx = 128e3, desc = "A whole book.", req = "rope", eff = { time = 1.05, agents = 2 } },
				{ id = "1m", name = "1M tokens", ctx = 1e6, desc = "A whole codebase.", req = "longctx", eff = { time = 1.12, agents = 4, coding = 2, hype = 6 } },
				{ id = "10m", name = "10M tokens", ctx = 1e7, desc = "Every email you ever sent.", req = "megactx", eff = { time = 1.25, agents = 5, hype = 8, serve = 1.2 } },
			} },
		},
	},
	{
		id = "post",
		name = "Post-training",
		groups = {
			{ id = "align", name = "Alignment", mode = "multi", options = {
				{ id = "sft", name = "Instruction tuning (SFT)", desc = "Turns a text predictor into an assistant. Basically required.", default = true, eff = { cap = 4, writing = 3 } },
				{ id = "rlhf", name = "RLHF", desc = "Humans rank answers. Nicer, more helpful, a bit sycophantic.", req = "rlhf", eff = { cap = 3, writing = 4, syco = 0.08, cost = 300e3 } },
				{ id = "dpo", name = "DPO", desc = "Preference tuning without a reward model. Cheap.", req = "dpo", eff = { cap = 2, writing = 2, cost = 60e3 } },
				{ id = "cai", name = "Constitutional AI", desc = "The model critiques itself against written principles.", req = "cai", eff = { cap = 1.5, safety = 10, syco = -0.05 } },
			} },
			{ id = "skills", name = "Skills", mode = "multi", options = {
				{ id = "rlvr", name = "Reasoning RL", desc = "Reward correct answers to math and code. Thinks before answering.", req = "reasoning", eff = { cap = 7, reasoning = 10, math = 12, coding = 6, time = 1.15, hype = 8, halluc = 0.02 } },
				{ id = "tools", name = "Tool use", desc = "Calls functions, searches the web, runs code.", req = "tools", eff = { agents = 10, cap = 1, hype = 2 } },
				{ id = "agentrl", name = "Agent RL environments", desc = "Thousands of simulated tasks. Long autonomous runs.", req = "agents", eff = { agents = 15, coding = 5, time = 1.12, cost = 2e6 } },
				{ id = "computer", name = "Computer use", desc = "Clicks, types, fills forms.", req = "computeruse", eff = { agents = 8, hype = 6 } },
				{ id = "codespec", name = "Coding specialist", desc = "Extra RL on real repositories.", req = "tools", eff = { coding = 10, time = 1.05 } },
			} },
			{ id = "think", name = "Thinking budget", mode = "single", options = {
				{ id = "none", name = "No thinking", desc = "Instant answers.", eff = {} },
				{ id = "low", name = "Short", desc = "A few seconds of thought.", req = "reasoning", eff = { reasoning = 2, math = 2, serve = 1.3 } },
				{ id = "high", name = "Long", desc = "Minutes of thought. Much smarter, pricier to run.", req = "reasoning", eff = { reasoning = 5, math = 6, coding = 2, serve = 2.2, speed = 0.7 } },
				{ id = "hybrid", name = "Hybrid (user picks)", desc = "Fast or deep on demand.", req = "hybrid", eff = { reasoning = 4, math = 4, serve = 1.5, hype = 3 } },
			} },
			{ id = "character", name = "Personality", mode = "single", options = {
				{ id = "warm", name = "Warm", desc = "Kind and encouraging.", eff = { writing = 1, syco = 0.04 } },
				{ id = "witty", name = "Witty", desc = "Dry jokes. Fans love it.", eff = { writing = 2, hype = 3 } },
				{ id = "pro", name = "Professional", desc = "Enterprise loves it, memers don't.", eff = { safety = 2 } },
				{ id = "concise", name = "Concise", desc = "No fluff.", eff = { speed = 1.1 } },
				{ id = "playful", name = "Playful", desc = "Emojis in its head, not in your UI.", eff = { hype = 4, syco = 0.03 } },
				{ id = "edgy", name = "Unfiltered", desc = "Says what others won't. Scandals guaranteed.", eff = { hype = 9, safety = -10, refuse = -0.2 } },
			} },
			{ id = "safety", name = "Safety & honesty", mode = "multi", options = {
				{ id = "refusal", name = "Refusal tuning", desc = "Says no to dangerous stuff. Too much = preachy.", eff = { safety = 8, refuse = 0.12 } },
				{ id = "antisyc", name = "Anti-sycophancy", desc = "Tells you when your code is bad.", req = "honesty", eff = { syco = -0.15, writing = 1 } },
				{ id = "calib", name = "Calibration (I don't know)", desc = "Admits uncertainty. Fewer hallucinations.", req = "honesty", eff = { halluc = -0.08, knowledge = 1 } },
			} },
		},
	},
	{
		id = "eval",
		name = "Evals & red team",
		groups = {
			{ id = "evals", name = "Before release", mode = "multi", options = {
				{ id = "bench", name = "Public benchmarks", desc = "The usual suspects.", default = true, eff = {} },
				{ id = "private", name = "Private held-out evals", desc = "Know your real score before the internet does.", eff = { noise = -0.5, contam = -0.1, cost = 80e3 } },
				{ id = "redteam", name = "Internal red team", desc = "Find jailbreaks before Twitter does.", eff = { safety = 5, cost = 120e3, time = 1.03 } },
				{ id = "external", name = "External red team", desc = "Hire outside experts. Strong system card.", eff = { safety = 8, cost = 500e3, time = 1.05 } },
				{ id = "bounty", name = "Bug bounty", desc = "Pay hackers to break it.", eff = { safety = 4, cost = 150e3 } },
				{ id = "card", name = "Publish a system card", desc = "Safety researchers will thank you.", eff = { safety = 2, hype = 1 } },
				{ id = "arena", name = "Secret Arena codename test", desc = "Test anonymously on the Arena first. Builds hype.", req = "arena", eff = { hype = 6, noise = -0.3 } },
			} },
			{ id = "compress", name = "Compress", mode = "multi", options = {
				{ id = "distill", name = "Distill from your best model", desc = "Student learns from teacher. Huge boost for small models.", req = "distill", eff = { cap = 0 } },
				{ id = "fp8serve", name = "Serve in FP8", desc = "Halves serving cost.", req = "fp8", eff = { serve = 0.6, cap = -0.3 } },
				{ id = "int4", name = "INT4 / GGUF", desc = "Runs on a laptop. Tinkerers rejoice.", eff = { serve = 0.4, cap = -1, hype = 2 } },
			} },
		},
	},
}

T.optionById = {} :: { [string]: any }
T.groupById = {} :: { [string]: any }
for _, stage in ipairs(T.stages) do
	for _, g in ipairs(stage.groups) do
		T.groupById[g.id] = g
		for _, o in ipairs(g.options) do
			T.optionById[o.id] = o
			o.group = g.id
		end
	end
end

-- Default recipe (what a new player sees).
function T.defaultRecipe()
	local r = { name = "", size = 0.5, tokens = "chinchilla", choices = {}, mix = {} }
	for _, stage in ipairs(T.stages) do
		for _, g in ipairs(stage.groups) do
			if g.mode == "single" then
				r.choices[g.id] = g.options[1].id
			elseif g.mode == "multi" then
				r.choices[g.id] = {}
				for _, o in ipairs(g.options) do
					if o.default then
						r.choices[g.id][o.id] = true
					end
				end
			elseif g.mode == "mix" then
				for _, o in ipairs(g.options) do
					r.mix[o.id] = o.default or 0
				end
			end
		end
	end
	r.choices.ctx = "4k"
	r.choices.character = "warm"
	return r
end

-- Combos that reward smart recipes (shown live in the Lab as hints).
T.combos = {
	{ id = "coder", name = "Coder stack", text = "Code 25%+ with Reasoning RL", bonus = 3, test = function(r)
		return (r.mix.code or 0) >= 25 and r.choices.skills and r.choices.skills.rlvr
	end },
	{ id = "mathlete", name = "Mathlete", text = "Math 12%+ and long thinking", bonus = 3, test = function(r)
		return (r.mix.math or 0) >= 12 and r.choices.think == "high"
	end },
	{ id = "polyglot", name = "Polyglot", text = "Multilingual 15%+ and big vocabulary", bonus = 2, test = function(r)
		return (r.mix.multi or 0) >= 15 and r.choices.extras and r.choices.extras.bigvocab
	end },
	{ id = "agentic", name = "Agentic", text = "Tool use + Agent RL + 1M context", bonus = 4, test = function(r)
		return r.choices.skills and r.choices.skills.tools and r.choices.skills.agentrl and (r.choices.ctx == "1m" or r.choices.ctx == "10m")
	end },
	{ id = "cleanroom", name = "Clean room", text = "Dedup + quality classifier + decontamination", bonus = 2, test = function(r)
		local q = r.choices.quality or {}
		return q.dedup and q.edu and q.decontam
	end },
	{ id = "efficient", name = "Efficiency nerd", text = "MoE + MLA + FP8", bonus = 3, test = function(r)
		local a = r.choices.arch
		return (a == "moe" or a == "finemoe") and r.choices.attn == "mla" and r.choices.precision == "fp8"
	end },
	{ id = "trusted", name = "Trustworthy", text = "Constitutional AI + red team + system card", bonus = 2, test = function(r)
		local al, ev = r.choices.align or {}, r.choices.evals or {}
		return al.cai and ev.redteam and ev.card
	end },
}

-- Warnings (bad combos).
T.warnings = {
	{ text = "Synthetic 40%+ without dedup risks model collapse", test = function(r)
		return (r.mix.synthetic or 0) >= 40 and not (r.choices.quality and r.choices.quality.dedup)
	end },
	{ text = "Long thinking without Reasoning RL does nothing", test = function(r)
		return r.choices.think ~= "none" and not (r.choices.skills and r.choices.skills.rlvr)
	end },
	{ text = "No instruction tuning: it will just autocomplete", test = function(r)
		return not (r.choices.align and r.choices.align.sft)
	end },
	{ text = "Unfiltered personality with no red team: scandal incoming", test = function(r)
		return r.choices.character == "edgy" and not (r.choices.evals and (r.choices.evals.redteam or r.choices.evals.external))
	end },
}

return T
