--!strict
-- Real labs and their real releases (research 09 §1, §3.2).
-- All names live ONLY here: flip PARODY_MODE to swap to parody names if the game is ever published.
-- cap = internal capability index (GPT-4 = 50). Benchmarks are derived from it in Benchmarks.luau.
local Labs = {}

Labs.PARODY_MODE = false

Labs.list = {
	--   id          real name           parody          color                       brand  cadence(mo) openness hype
	{ id = "openai", name = "OpenAI", parody = "OpenMind", color = Color3.fromRGB(16, 163, 127), brand = 9, cadence = 3, open = 2, hype = 10, cash = 11e9 },
	{ id = "anthropic", name = "Anthropic", parody = "Philanthropic", color = Color3.fromRGB(217, 119, 87), brand = 2.2, cadence = 2.5, open = 0, hype = 5, cash = 1.5e9 },
	{ id = "google", name = "Google DeepMind", parody = "Gaggle DeepThink", color = Color3.fromRGB(66, 133, 244), brand = 5, cadence = 4, open = 4, hype = 6, cash = 100e9 },
	{ id = "meta", name = "Meta", parody = "Mesa", color = Color3.fromRGB(0, 129, 251), brand = 3, cadence = 6, open = 8, hype = 7, cash = 60e9 },
	{ id = "xai", name = "xAI", parody = "yAI", color = Color3.fromRGB(230, 230, 230), brand = 1.5, cadence = 4, open = 3, hype = 9, cash = 6e9 },
	{ id = "mistral", name = "Mistral", parody = "Mistrale", color = Color3.fromRGB(255, 112, 0), brand = 0.8, cadence = 6, open = 7, hype = 4, cash = 0.5e9 },
	{ id = "deepseek", name = "DeepSeek", parody = "DeepSeep", color = Color3.fromRGB(77, 107, 254), brand = 0.6, cadence = 5, open = 10, hype = 1, cash = 1e9 },
	{ id = "qwen", name = "Alibaba Qwen", parody = "Qwerty", color = Color3.fromRGB(97, 92, 237), brand = 0.8, cadence = 4, open = 9, hype = 4, cash = 20e9 },
	{ id = "moonshot", name = "Moonshot", parody = "Moonshine", color = Color3.fromRGB(40, 40, 40), brand = 0.5, cadence = 6, open = 9, hype = 5, cash = 1e9 },
	{ id = "zhipu", name = "Zhipu", parody = "Zippu", color = Color3.fromRGB(50, 90, 200), brand = 0.4, cadence = 4, open = 8, hype = 4, cash = 1e9 },
	{ id = "minimax", name = "MiniMax", parody = "MaxiMin", color = Color3.fromRGB(240, 60, 90), brand = 0.4, cadence = 5, open = 8, hype = 4, cash = 0.8e9 },
	{ id = "microsoft", name = "Microsoft", parody = "Macrosoft", color = Color3.fromRGB(0, 164, 239), brand = 1.2, cadence = 8, open = 5, hype = 4, cash = 80e9 },
	{ id = "amazon", name = "Amazon", parody = "Amazin", color = Color3.fromRGB(255, 153, 0), brand = 0.8, cadence = 12, open = 1, hype = 3, cash = 80e9 },
	{ id = "cohere", name = "Cohere", parody = "Cohear", color = Color3.fromRGB(57, 89, 76), brand = 0.3, cadence = 12, open = 5, hype = 2, cash = 0.4e9 },
	{ id = "nvidia", name = "Nvidia", parody = "Envidia", color = Color3.fromRGB(118, 185, 0), brand = 0.3, cadence = 12, open = 9, hype = 6, cash = 30e9 },
}

Labs.byId = {} :: { [string]: any }
for _, l in ipairs(Labs.list) do
	Labs.byId[l.id] = l
end

function Labs.displayName(id: string): string
	local l = Labs.byId[id]
	if not l then
		return id
	end
	return Labs.PARODY_MODE and l.parody or l.name
end

-- date | lab | model | cap | O=open C=closed | $ out per 1M | short note (used in news + reactions)
local RAW = [[
2020-06-11|openai|GPT-3 davinci|30|C|20|The model that started it all
2022-04-04|google|PaLM 540B|36|C|0|Google's giant research model
2022-05-02|meta|OPT-175B|24|O|0|Meta opens a GPT-3-sized model
2022-11-28|openai|text-davinci-003|38|C|20|The model behind early ChatGPT
2022-11-30|openai|ChatGPT (GPT-3.5)|40|C|2|100 million users in two months
2023-02-24|meta|LLaMA 65B|30|O|0|Weights leak sparks the open-source boom
2023-03-01|openai|GPT-3.5 Turbo API|40|C|2|ChatGPT API, 10x cheaper than davinci
2023-03-14|openai|GPT-4|50|C|60|The step change of the era
2023-03-14|anthropic|Claude 1|42|C|33|Safety-first entrant
2023-03-21|google|Bard|35|C|0|Rushed launch after a costly demo error
2023-05-10|google|PaLM 2|40|C|2|Powers Bard
2023-07-11|anthropic|Claude 2|44|C|33|100K context reads whole books
2023-07-18|meta|Llama 2 70B|38|O|0|Open weights go commercial
2023-08-03|qwen|Qwen-7B|28|O|0|Start of the Qwen open-weights machine
2023-09-27|mistral|Mistral 7B|32|O|0|Dropped as a magnet link
2023-11-04|xai|Grok-1|38|C|0|The rebellious chatbot inside X
2023-11-06|openai|GPT-4 Turbo|52|C|30|3x cheaper GPT-4, 128K context
2023-11-21|anthropic|Claude 2.1|45|C|24|200K context, fewer hallucinations
2023-11-29|deepseek|DeepSeek LLM 67B|37|O|0|A quant fund's lab debuts
2023-12-06|google|Gemini 1.0 Ultra|50|C|0|Edited demo video controversy
2023-12-11|mistral|Mixtral 8x7B|40|O|0.7|Popularised open MoE
2024-02-15|google|Gemini 1.5 Pro|53|C|10.5|1M context leap
2024-02-26|mistral|Mistral Large|46|C|24|Paris goes closed for the flagship
2024-03-04|anthropic|Claude 3 Opus|55|C|75|First to beat GPT-4 on Arena
2024-04-18|meta|Llama 3 70B|47|O|0|Best open model at launch
2024-05-06|deepseek|DeepSeek-V2|48|O|0.28|Triggers the China price war
2024-05-13|openai|GPT-4o|57|C|15|Native voice and vision demo
2024-06-07|qwen|Qwen2 72B|49|O|0|Tops the open leaderboard
2024-06-20|anthropic|Claude 3.5 Sonnet|59|C|15|The coding favourite
2024-07-18|openai|GPT-4o mini|46|C|0.6|Kills GPT-3.5 on price
2024-07-23|meta|Llama 3.1 405B|54|O|0|First open GPT-4-class model
2024-08-13|xai|Grok-2|54|C|10|Few guardrails, fast catch-up
2024-09-12|openai|o1-preview|63|C|60|Birth of reasoning models
2024-10-22|anthropic|Claude 3.5 Sonnet (new)|61|C|15|Computer use agents arrive
2024-12-05|openai|o1|65|C|60|Plus a $200/month Pro plan
2024-12-11|google|Gemini 2.0 Flash|57|C|0.4|The agentic era pitch
2024-12-26|deepseek|DeepSeek-V3|58|O|1.1|Trained for a reported $5.6M
2025-01-20|deepseek|DeepSeek-R1|65|O|2.19|Number one on the App Store, Nvidia drops 17%
2025-01-31|openai|o3-mini|64|C|4.4|Answer to R1
2025-02-17|xai|Grok 3|68|C|15|Colossus 100K H100 flexes
2025-02-24|anthropic|Claude 3.7 Sonnet|67|C|15|Hybrid reasoning plus Claude Code
2025-02-27|openai|GPT-4.5|64|C|150|Huge, pricey, short-lived
2025-03-25|google|Gemini 2.5 Pro|72|C|10|Google is back, top of Arena by 40
2025-04-05|meta|Llama 4 Maverick|58|O|0|Arena variant controversy
2025-04-16|openai|o3|72|C|40|Tool-using reasoning
2025-04-29|qwen|Qwen3 235B|66|O|0|Most downloaded open family
2025-05-22|anthropic|Claude Opus 4|73|C|75|Long agentic coding runs
2025-07-09|xai|Grok 4|75|C|15|Top benchmarks after a rough week
2025-07-11|moonshot|Kimi K2|68|O|2.5|Best open agentic coder
2025-08-05|openai|gpt-oss-120b|64|O|0|OpenAI's first open weights since GPT-2
2025-08-07|openai|GPT-5|77|C|10|Hype beat reality, chart crimes
2025-09-29|anthropic|Claude Sonnet 4.5|78|C|15|Best coding model
2025-11-06|moonshot|Kimi K2 Thinking|74|O|2.5|DeepSeek moment 2
2025-11-18|google|Gemini 3 Pro|82|C|12|New number one, rivals declare code red
2025-11-24|anthropic|Claude Opus 4.5|83|C|25|First past 80 on SWE-bench
2025-12-01|deepseek|DeepSeek V3.2|74|O|0.42|Olympiad gold, open weights
2025-12-02|mistral|Mistral Large 3|66|O|0|Europe's open frontier attempt
2025-12-11|openai|GPT-5.2|83|C|14|Fast code-red response
2026-02-05|anthropic|Claude Opus 4.6|85|C|25|Agent teams, vibe working
2026-02-11|zhipu|GLM-5|76|O|2|Trained on domestic chips
2026-02-16|qwen|Qwen3.5|78|O|0|Lunar New Year drop
2026-02-19|google|Gemini 3.1 Pro|86|C|12|Doubled reasoning in 3 months
2026-03-05|openai|GPT-5.4|86|C|15|Native computer use
2026-04-08|meta|Muse Spark|80|C|0|End of the Llama era
2026-04-16|anthropic|Claude Opus 4.7|88|C|25|SWE-bench 87.6
2026-04-23|openai|GPT-5.5|89|C|30|A new class of intelligence, price doubled
2026-04-24|deepseek|DeepSeek V4|83|O|3.48|A sixth of the price of the leaders
2026-05-28|anthropic|Claude Opus 4.8|89|C|25|41 days after 4.7
2026-06-01|minimax|MiniMax M3|80|O|1.2|Native multimodal, dirt cheap
2026-06-09|anthropic|Claude Fable 5|92|C|50|Frontier power with safeguards
2026-07-09|openai|GPT-5.6 Sol|91|C|30|Celestial naming arrives
2026-07-16|moonshot|Kimi K3|87|O|15|Largest open model ever
2026-07-24|anthropic|Claude Opus 5|91|C|25|Near the top at Opus prices
2026-08-03|qwen|Qwen3.8-Max|86|O|0|Claims global number two
2026-08-12|xai|Grok 4.6|85|C|6|Grok 5 still training
2026-09-03|openai|GPT-6 Astra|94|C|50|The GPT-6 era begins
2026-09-22|anthropic|Claude Opus 5.5|93|C|20|WebDev Arena number one
2026-10-06|mistral|Mistral Large 4|80|O|0|A trillion-parameter open model from Paris
2026-10-12|meta|Muse Wonder|91|C|20|1.8M downloads in 12 days
2026-10-13|google|Gemini 4 Argon|94|C|10|Beats Astra at 40% of the cost
2026-10-28|google|Gemini 4 Carbon|96|C|10|Number one on Arena, gated release
]]

export type Release = {
	day: number,
	lab: string,
	model: string,
	cap: number,
	open: boolean,
	priceOut: number,
	note: string,
	future: boolean?,
}

local Format = require(script.Parent:WaitForChild("Format"))

Labs.releases = {} :: { Release }
for line in RAW:gmatch("[^\n]+") do
	local date, lab, model, cap, oc, price, note = line:match("^(.-)|(.-)|(.-)|(.-)|(.-)|(.-)|(.*)$")
	if date then
		table.insert(Labs.releases, {
			day = Format.dayFromString(date),
			lab = lab,
			model = model,
			cap = tonumber(cap) :: number,
			open = oc == "O",
			priceOut = tonumber(price) :: number,
			note = note,
		})
	end
end
table.sort(Labs.releases, function(a, b)
	return a.day < b.day
end)

Labs.LAST_REAL_DAY = Labs.releases[#Labs.releases].day

-- Projected frontier after the real calendar ends (research 09 §6.2, medium scenario):
-- +6 cap/yr in 2027, slowing gently.
function Labs.frontierProjection(day: number): number
	local years = (day - Labs.LAST_REAL_DAY) / 365
	if years <= 0 then
		return 96
	end
	return 96 + 6 * years - 0.35 * years * years
end

-- Future model names per lab (plausible, research 09 §6.3).
Labs.futureNames = {
	openai = { "GPT-6.5", "GPT-7", "GPT-7.5", "GPT-8" },
	anthropic = { "Claude 6", "Claude 6.5", "Claude 7", "Claude 7.5", "Claude 8" },
	google = { "Gemini 4.5", "Gemini 5", "Gemini 5.5", "Gemini 6" },
	meta = { "Muse Wonder 2", "Muse 3", "Muse 4" },
	xai = { "Grok 5", "Grok 6", "Grok 7" },
	mistral = { "Mistral Large 5", "Mistral 6" },
	deepseek = { "DeepSeek V5", "DeepSeek R3", "DeepSeek V6" },
	qwen = { "Qwen4", "Qwen4.5", "Qwen5" },
	moonshot = { "Kimi K4", "Kimi K5" },
	zhipu = { "GLM-6", "GLM-7" },
	minimax = { "MiniMax M4", "MiniMax M5" },
}

return Labs
