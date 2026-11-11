# 09 — AI Labs, Models & Hardware Timeline (Jan 2023 → Nov 2026) + Projections to 2035

> Research doc for the AI-lab tycoon. Goal: give designers/engineers a single source to convert into config
> (rival release schedules, rival "AI personalities", hardware shop catalogue, price curves, future events).
>
> **As-of date:** 11 Nov 2026. **Method:** ~55 web searches (Nov 2026) for everything after ~Jan 2026, plus
> well-established public record for 2023–2025. WebFetch was blocked in this environment (only search snippets
> were readable), so post-2025 numbers come from secondary write-ups (Artificial Analysis, VentureBeat, Decrypt,
> The Decoder, DataCamp, vendor blogs) and are often **vendor-reported**. Every row carries a confidence flag:
>
> - **H** = high (official/very widely reported), **M** = medium (multiple secondary sources, minor conflicts),
>   **L** = low (single source / rumor / conflicting). Treat L rows as "flavour" — safe to fudge in-game.
>
> **Benchmark caveats for game balance:** LMArena Elo drifts (scale re-anchors; 2023 values ~1100–1250, 2026
> values ~1500+). Artificial Analysis Intelligence Index (AA) has been re-versioned (v2→v3→v4→v5) and renormalised,
> so AA "59" in late 2026 is not comparable to AA "70" in 2025. SWE-bench Verified saturated in 2026 and labs moved
> to SWE-bench Pro / Terminal-Bench 2.x–4.0 / OSWorld 2.x / ARC-AGI-3. In-game, use a single internal
> "capability score" and *derive* display benchmarks from it (see §7.4).

---

## 0. Quick reference — headline facts for config

| Item | Value (Nov 2026) | Conf |
|---|---|---|
| Top models now | Gemini 4 Carbon (Google, Oct 28), GPT-6 Astra (OpenAI, Sep 3), Claude Fable 5.1 / Mythos 5.1 (Anthropic, Sep 1), Claude Opus 5.5 (Sep 22) | M |
| LMArena #1 (text) | Gemini 4 Carbon ≈ 1528 | M |
| Best open-weights | Kimi K3 (2.8T MoE), Qwen3.8-Max (2.4T), DeepSeek V4/V4.1, Mistral Large 4 (~1T), GLM-5.x, MiniMax M3 | M |
| HLE top | GPT-6 Astra ≈ 54.8% (Scale board, Oct 2026) | M |
| ARC-AGI-2 top | ≈ 95% (GPT-6 Astra Max) — effectively saturated | M |
| ARC-AGI-3 top | ≈ 62.7% (Astra, ARC Prize standard scaffold) | M |
| Frontier API price band | Flagship $2–$10 in / $10–$50 out; restricted "Mythos-class" $10–$25 / $50–$125; small models $0.10–$1 / $0.50–$6 | M |
| Newest shipping GPU | Nvidia Vera Rubin (VR200 / NVL144-class), ramp from ~Sep–Oct 2026 | M |
| H100 rent | ~$2–$7/GPU-hr list, median ≈ $3.4; prices **rising** in late 2026 | M |
| B200 rent | ~$4–$8/GPU-hr (neoclouds ≈ $6.25–6.89) | M |
| Valuations | Anthropic $965B (May 2026 Series H; public S-1 filed ~Oct 26, ticker ANT); OpenAI ~$852B private | M |
| Revenue run-rate | Anthropic > $65B (end Jul 2026), OpenAI ≈ $40B (est.) | M |

---

## 1. Month-by-month model timeline

Columns: **Date** · **Lab** · **Model** · **O/C** (Open weights / Closed) · **Params** (total/active where MoE) ·
**Ctx** (tokens) · **Key scores** · **$ in/out per 1M tokens** · **Notes / reception** · **Conf**.

Abbreviations: MMLU, GPQA (Diamond), SWE-V (SWE-bench Verified), SWE-Pro, HLE (Humanity's Last Exam; no tools unless
"w/tools"), ARC1/ARC2/ARC3 (ARC-AGI v1/v2/v3), AIME (year noted), Arena (LMArena text Elo, contemporary scale),
AA (Artificial Analysis index, version-dependent), TB (Terminal-Bench), OSW (OSWorld).

### 1.1 — 2023

| Date | Lab | Model | O/C | Params | Ctx | Key scores | $ in/out | Notes / reception | Conf |
|---|---|---|---|---|---|---|---|---|---|
| 2023-02-24 | Meta | LLaMA (1) | O (research licence, leaked) | 7–65B | 2K | MMLU 63.4 (65B) | — | Weights leak sparks open-source boom (Alpaca, Vicuna) | H |
| 2023-03-01 | OpenAI | gpt-3.5-turbo API | C | ~? | 4K | MMLU ~70 | $2.00/$2.00 → later $0.50/$1.50 | ChatGPT API; 10x cheaper than davinci | H |
| 2023-03-14 | OpenAI | **GPT-4** | C | ~1.8T MoE (rumor) | 8K / 32K | MMLU 86.4, bar exam ~90th pct, GPQA ~36 | $30/$60 (8K), $60/$120 (32K) | The step change of the era; defines "frontier" | H |
| 2023-03-14 | Anthropic | Claude 1 / Claude Instant | C | ? | 9K→100K (May) | — | ~$11/$33 | Safety-first entrant; 100K ctx in May wow'd devs | H |
| 2023-03-21 | Google | Bard (LaMDA→PaLM 2) | C | — | — | — | free | Rushed launch; demo error wiped ~$100B off Alphabet (Feb) | H |
| 2023-05-10 | Google | PaLM 2 | C | ~340B (reported) | 8K | MMLU 78.3 | ~$0.5/1K chars era | I/O 2023; powers Bard | H |
| 2023-07-11 | Anthropic | Claude 2 | C | ? | 100K | MMLU 78.5 | $11.02/$32.68 | Strong long-doc reading | H |
| 2023-07-18 | Meta (+MSFT) | **Llama 2** 7/13/70B | O (commercial licence) | 70B | 4K | MMLU 68.9 | free | Open-weights legitimised for business | H |
| 2023-08-03 | Alibaba | Qwen-7B (Qwen 1) | O | 7B (14B Sep, 72B Nov) | 8K | — | — | Start of the Qwen open-weights machine | H |
| 2023-09-27 | Mistral | Mistral 7B | O (Apache-2.0) | 7B | 8K | beats Llama 2 13B | free | Paris startup's magnet-link drop; cult status | H |
| 2023-10 | Zhipu | ChatGLM3 | O/C | 6B open | 8K–32K | — | — | Tsinghua spin-off; China's API leader | M |
| 2023-10 | Moonshot | Kimi Chat | C | ? | 200K chars | — | — | Long-context consumer app | M |
| 2023-11-04 | xAI | Grok-1 (in X Premium) | C (open Mar 2024) | 314B MoE | 8K | MMLU 73 | — | "Rebellious" chatbot inside X | H |
| 2023-11-06 | OpenAI | **GPT-4 Turbo** + GPTs (DevDay) | C | ? | 128K | ≈GPT-4 | $10/$30 | 3x cheaper GPT-4; then Nov 17 Altman fired/rehired drama | H |
| 2023-11-21 | Anthropic | Claude 2.1 | C | ? | 200K | lower hallucination | $8/$24 | | H |
| 2023-11-29 | DeepSeek | DeepSeek LLM 67B | O | 67B | 4K | ≈Llama 2 70B+ | — | Quant-fund (High-Flyer) lab debuts | H |
| 2023-12-06 | Google | **Gemini 1.0** Ultra/Pro/Nano | C | ? | 32K | MMLU 90.0 (Ultra, CoT@32) | Pro free tier | Edited demo video controversy | H |
| 2023-12-11 | Mistral | Mixtral 8x7B | O (Apache) | 46.7B/12.9B | 32K | ≈GPT-3.5 | $0.7 | Popularised open MoE | H |
| 2023-12 | Microsoft | Phi-2 | O | 2.7B | 2K | — | — | Small-model "textbook data" thesis | H |

### 1.2 — 2024

| Date | Lab | Model | O/C | Params | Ctx | Key scores | $ in/out | Notes / reception | Conf |
|---|---|---|---|---|---|---|---|---|---|
| 2024-01-16 | Zhipu | GLM-4 | C | ? | 128K | ≈GPT-4 (claimed) | — | | M |
| 2024-02-15 | Google | **Gemini 1.5 Pro** | C | MoE | **1M** (10M research) | needle-in-haystack ~99% | $3.5/$10.5 (later $1.25/$5) | Long-context leap; overshadowed by Sora same day | H |
| 2024-02-21 | Google | Gemma 2B/7B | O | 7B | 8K | — | free | Google's open line | H |
| 2024-02-26 | Mistral | Mistral Large (+ MSFT deal) | C | ? | 32K | MMLU 81.2 | $8/$24 | Shift toward closed flagship | H |
| 2024-03-04 | Anthropic | **Claude 3** Opus/Sonnet/Haiku | C | ? | 200K | Opus: MMLU 86.8, GPQA 50.4; Arena ~1250 | Opus $15/$75, Sonnet $3/$15, Haiku $0.25/$1.25 | First to beat GPT-4 on Arena | H |
| 2024-03-17 | xAI | Grok-1 weights | O (Apache) | 314B MoE | 8K | — | — | | H |
| 2024-03-27 | Databricks | DBRX | O | 132B/36B | 32K | MMLU 73.7 | — | | H |
| 2024-04-04 | Cohere | Command R+ | O (non-commercial) | 104B | 128K | RAG/tool use | $3/$15 | Enterprise RAG specialist | H |
| 2024-04-10 | Mistral | Mixtral 8x22B | O | 141B/39B | 64K | MMLU 77.8 | — | | H |
| 2024-04-18 | Meta | **Llama 3** 8B/70B | O | 70B | 8K | MMLU 82.0 (70B) | free | Best open model at launch | H |
| 2024-04-23 | Microsoft | Phi-3 mini/small/medium | O | 3.8–14B | 4K–128K | — | — | | H |
| 2024-05-06 | DeepSeek | DeepSeek-V2 | O | 236B/21B | 128K | MMLU 78.5 | **$0.14/$0.28** | MLA attention; triggers China price war | H |
| 2024-05-13 | OpenAI | **GPT-4o** | C | ? | 128K | MMLU 88.7, GPQA 53.6, Arena ~1285 | $5/$15 (→$2.5/$10 Aug) | Native voice/vision ("Her" demo, Scarlett Johansson spat) | H |
| 2024-05-14 | Google | Gemini 1.5 Flash; Project Astra demo | C | ? | 1M | — | $0.35/$1.05 → $0.075/$0.30 | Cheapest capable model | H |
| 2024-06-07 | Alibaba | Qwen2 (0.5–72B) | O (Apache mostly) | 72B | 128K | MMLU 84.2 | — | Top open model on HF board | H |
| 2024-06-14 | Nvidia | Nemotron-4 340B | O | 340B | 4K | — | — | Synthetic-data generator | H |
| 2024-06-20 | Anthropic | **Claude 3.5 Sonnet** | C | ? | 200K | MMLU 88.7, GPQA 59.4, SWE-V 33→49 (Oct) | $3/$15 | Coding favourite; Artifacts UI | H |
| 2024-06-27 | Google | Gemma 2 9B/27B | O | 27B | 8K | — | — | | H |
| 2024-07-18 | OpenAI | GPT-4o mini | C | ? | 128K | MMLU 82 | **$0.15/$0.60** | Kills GPT-3.5 | H |
| 2024-07-23 | Meta | **Llama 3.1 405B** | O | 405B dense | 128K | MMLU 88.6, ~3.8e25 FLOP | free | First open "GPT-4-class" | H |
| 2024-07-24 | Mistral | Mistral Large 2 | O (research) | 123B | 128K | MMLU 84 | $3/$9 | | H |
| 2024-08-13 | xAI | Grok-2 / Grok-2 mini | C | ? | 128K | MMLU 87.5, Arena ~1270 | $2/$10 (later) | Flux image gen, few guardrails | H |
| 2024-09-12 | OpenAI | **o1-preview / o1-mini** | C | ? | 128K | GPQA 78 (o1), AIME'24 83 (o1) vs 13 (4o) | $15/$60 (preview) | Birth of "reasoning models" / test-time compute | H |
| 2024-09-19 | Alibaba | Qwen2.5 (0.5–72B) | O | 72B | 128K | MMLU 86 | — | | H |
| 2024-09-25 | Meta | Llama 3.2 (1B/3B, 11B/90B vision) | O | 90B | 128K | — | — | | H |
| 2024-10-22 | Anthropic | Claude 3.5 Sonnet (new) + **Computer Use** | C | ? | 200K | SWE-V 49.0, GPQA 65 | $3/$15 | First computer-use agent API | H |
| 2024-11-04 | Anthropic | Claude 3.5 Haiku | C | ? | 200K | SWE-V 40.6 | $0.80/$4 | Price *raise* vs 3 Haiku — grumbles | H |
| 2024-11-20 | DeepSeek | R1-Lite-Preview | C (app) | ? | — | AIME ≈ o1-preview | — | First Chinese o1 replication | H |
| 2024-11-25 | Anthropic | Model Context Protocol (MCP) | open standard | — | — | — | — | Becomes industry tool standard in 2025 | H |
| 2024-11-28 | Alibaba | QwQ-32B-Preview | O | 32B | 32K | AIME ~50 | — | | H |
| 2024-12-03 | Amazon | Nova Micro/Lite/Pro | C | ? | 128K–300K | ≈GPT-4o-class (Pro) | Pro $0.80/$3.20 | Cheap Bedrock-native | H |
| 2024-12-05 | OpenAI | o1 (full) + ChatGPT Pro $200/mo | C | ? | 200K | GPQA 78, AIME 79–83 | $15/$60 | "12 days of shipmas" | H |
| 2024-12-06 | Meta | Llama 3.3 70B | O | 70B | 128K | ≈405B | — | | H |
| 2024-12-11 | Google | Gemini 2.0 Flash (exp) | C | ? | 1M | beats 1.5 Pro | free exp | "Agentic era" framing | H |
| 2024-12-12 | Microsoft | Phi-4 | O (MIT) | 14B | 16K | MMLU 84.8 | — | | H |
| 2024-12-20 | OpenAI | **o3 announced** | C (Apr 2025) | ? | — | ARC1 75.7% (87.5% high-compute), FrontierMath 25%, SWE-V 71.7 | — | ARC-AGI-1 effectively beaten | H |
| 2024-12-26 | DeepSeek | **DeepSeek-V3** | O (MIT-ish) | 671B/37B | 128K | MMLU 88.5, GPQA 59.1 | $0.27/$1.10 | "$5.6M" training (2,048 H800s) headline | H |

### 1.3 — 2025

| Date | Lab | Model | O/C | Params | Ctx | Key scores | $ in/out | Notes / reception | Conf |
|---|---|---|---|---|---|---|---|---|---|
| 2025-01-15 | MiniMax | MiniMax-01 (Text-01) | O | 456B/45.9B | **4M** | ≈GPT-4o | $0.20/$1.10 | Lightning (linear) attention | H |
| 2025-01-20 | DeepSeek | **DeepSeek-R1** | O (MIT) | 671B/37B | 128K | AIME'24 79.8, GPQA 71.5, MMLU 90.8 | $0.55/$2.19 | #1 App Store; Nvidia −$589B in a day (Jan 27) | H |
| 2025-01-20 | Moonshot | Kimi k1.5 | C | ? | 128K | ≈o1 (math) | — | Same-day as R1, overshadowed | H |
| 2025-01-21 | OpenAI+SoftBank+Oracle | **Stargate** ($500B JV announced) | — | — | — | — | — | Abilene TX first site | H |
| 2025-01-23 | CAIS/Scale | Humanity's Last Exam released | benchmark | — | — | best ~9% at launch | — | | H |
| 2025-01-28 | Alibaba | Qwen2.5-Max | C | MoE | 32K | ≈DeepSeek-V3+ | $1.6/$6.4 | | H |
| 2025-01-30 | Mistral | Mistral Small 3 | O (Apache) | 24B | 32K | — | $0.1/$0.3 | | H |
| 2025-01-31 | OpenAI | o3-mini | C | ? | 200K | AIME 87 (high) | $1.10/$4.40 | Answer to R1 | H |
| 2025-02-05 | Google | Gemini 2.0 Flash GA / 2.0 Pro exp / Flash-Lite | C | ? | 1M–2M | — | Flash $0.10/$0.40 | | H |
| 2025-02-17 | xAI | **Grok 3** (+Think) | C | ? (~10x Grok 2 compute; Colossus 100K H100) | 1M | AIME'25 93 (claimed), Arena #1 ~1400 | $3/$15 | Fast catch-up; benchmark-chart disputes | H |
| 2025-02-24 | Anthropic | **Claude 3.7 Sonnet** (hybrid reasoning) + Claude Code preview | C | ? | 200K | SWE-V 62.3 (70.3 scaffold) | $3/$15 | Claude Code becomes a revenue rocket | H |
| 2025-02-27 | OpenAI | GPT-4.5 "Orion" | C | very large | 128K | GPQA 71, "EQ" | **$75/$150** | Last non-reasoning giant; deprecated Jul 2025 | H |
| 2025-03-06 | Alibaba | QwQ-32B | O (Apache) | 32B | 131K | ≈R1 (claimed) | — | | H |
| 2025-03-12 | Google | Gemma 3 (1–27B) | O | 27B | 128K | — | — | | H |
| 2025-03-13 | Cohere | Command A | O (non-comm.) | 111B | 256K | — | $2.5/$10 | Runs on 2 GPUs | H |
| 2025-03-24 | ARC Prize | ARC-AGI-2 launched | benchmark | — | — | frontier <5% | — | | H |
| 2025-03-25 | Google | **Gemini 2.5 Pro** (exp) | C | ? | 1M | GPQA 84, HLE 18.8, AIME'25 86.7, SWE-V 63.8, Arena ~1440 (#1 by 40 pts) | $1.25/$10 | Google's "we're back" moment | H |
| 2025-03-25 | OpenAI | GPT-4o native image gen | C | — | — | — | — | "Ghibli" viral; 1M signups/hr | H |
| 2025-04-05 | Meta | **Llama 4** Scout / Maverick (Behemoth preview) | O | Scout 109B/17B, Maverick 400B/17B, Behemoth ~2T (never shipped) | Scout 10M, Mav 1M | Arena-tuned variant controversy | free | Disappointing reception → Meta reorg into MSL | H |
| 2025-04-14 | OpenAI | GPT-4.1 / mini / nano | C | ? | 1M | SWE-V 54.6 | $2/$8 | Dev-focused | H |
| 2025-04-16 | OpenAI | **o3 + o4-mini** | C | ? | 200K | o3: GPQA 83.3, SWE-V 69.1, HLE 20.3; ARC2 ~3–6% | o3 $10/$40 (→$2/$8 Jun 10) | Tool-using reasoning; hallucination complaints | H |
| 2025-04-17 | Google | Gemini 2.5 Flash | C | ? | 1M | — | $0.15/$0.60 (+thinking) | | H |
| 2025-04-29 | Alibaba | **Qwen3** (0.6B–235B-A22B) | O (Apache) | 235B/22B | 128K | AIME'24 85.7 (235B) | — | Hybrid think/no-think; most downloaded family | H |
| 2025-05-07 | Mistral | Mistral Medium 3 | C | ? | 128K | ≈Sonnet 3.7 (claimed) | $0.40/$2 | | H |
| 2025-05-20 | Google | I/O: 2.5 Deep Think, Veo 3, Gemini Ultra plan $250 | C | — | — | — | — | Veo 3 w/ audio goes viral | H |
| 2025-05-22 | Anthropic | **Claude Opus 4 / Sonnet 4** | C | ? | 200K (1M Sonnet beta Aug) | Opus SWE-V 72.5 (79.4 parallel), Sonnet 72.7 | Opus $15/$75, Sonnet $3/$15 | First ASL-3 deployment; "blackmail" eval headlines | H |
| 2025-05-28 | DeepSeek | R1-0528 | O | 671B/37B | 128K | AIME'25 87.5 | $0.55/$2.19 | ≈o3-level open | H |
| 2025-06-10 | OpenAI | o3-pro; o3 price −80% | C | ? | 200K | — | o3-pro $20/$80 | | H |
| 2025-06-10 | Mistral | Magistral (reasoning) | O (Small) / C (Medium) | 24B | 40K | — | — | | H |
| 2025-06-16 | MiniMax | MiniMax-M1 | O (Apache) | 456B/45.9B | 1M | — | cheap | Open long-ctx reasoning | H |
| 2025-06-17 | Google | Gemini 2.5 Pro/Flash GA, Flash-Lite | C | ? | 1M | — | Flash-Lite $0.10/$0.40 | | H |
| 2025-07-09 | xAI | **Grok 4 / Grok 4 Heavy** | C | ? (RL at pretraining scale) | 256K | HLE 25.4 (44.4 Heavy w/tools), ARC2 15.9 (SOTA then), GPQA 87.5 | $3/$15; SuperGrok Heavy $300/mo | Top benchmarks; "MechaHitler" incident week before | H |
| 2025-07-11 | Moonshot | **Kimi K2** | O (mod. MIT) | 1T/32B | 128K | SWE-V 65.8 | $0.60/$2.50 | Best open agentic coder; MuonClip optimiser | H |
| 2025-07-17 | OpenAI | ChatGPT Agent | C | — | — | — | — | Operator + Deep Research merged | H |
| 2025-07-19 | OpenAI / GDM | IMO 2025 gold (experimental models) | — | — | — | 35/42 | — | Reasoning milestone | H |
| 2025-07-22 | Alibaba | Qwen3-235B-2507, Qwen3-Coder-480B-A35B | O | 480B/35B | 256K–1M | SWE-V ~67 | — | | H |
| 2025-07-28 | Zhipu (Z.ai) | **GLM-4.5** / Air | O (MIT) | 355B/32B | 128K | — | $0.6/$2.2 | Agentic-coding open model | H |
| 2025-08-05 | OpenAI | **gpt-oss-120b / 20b** | O (Apache) | 117B/5.1B | 128K | ≈o4-mini | free | OpenAI's first open weights since GPT-2 | H |
| 2025-08-05 | Anthropic | Claude Opus 4.1 | C | ? | 200K | SWE-V 74.5 | $15/$75 | | H |
| 2025-08-05 | Google | Genie 3 (world model) | C | — | — | — | — | | H |
| 2025-08-07 | OpenAI | **GPT-5** (router: main/thinking/pro, mini, nano) | C | ? | 400K | SWE-V 74.9, AIME'25 94.6, GPQA 87–89, HLE 24.8 (42 w/tools Pro), ARC2 9.9 | **$1.25/$10** (mini $0.25/$2, nano $0.05/$0.40) | Hype > reality; "chart crimes", 4o removal backlash | H |
| 2025-08-21 | DeepSeek | V3.1 (hybrid think) | O | 671B/37B | 128K | SWE-V 66 | $0.56/$1.68 | UE8M0 FP8 for Chinese chips | H |
| 2025-08-26 | Google | Gemini 2.5 Flash Image ("Nano Banana") | C | — | — | Arena image #1 | $0.039/img | Viral consumer hit | H |
| 2025-08-28 | Microsoft | MAI-1-preview, MAI-Voice-1 | C | ~500B MoE (~15K H100) | — | Arena ~13th | — | Microsoft's own-model hedge vs OpenAI | H |
| 2025-09-05 | Alibaba | Qwen3-Max | C | >1T | 256K | — | $1.2/$6 | | H |
| 2025-09-05 | Moonshot | Kimi K2-0905 | O | 1T/32B | 256K | SWE-V 69.2 | — | | H |
| 2025-09-15 | OpenAI | GPT-5-Codex | C | ? | — | SWE-V 74.5 | $1.25/$10 | Codex usage 10x | H |
| 2025-09-19 | xAI | Grok 4 Fast | C | ? | 2M | ≈Grok 4 at fraction | **$0.20/$0.50** | | H |
| 2025-09-29 | Anthropic | **Claude Sonnet 4.5** | C | ? | 200K/1M | SWE-V 77.2 (82 parallel), OSW 61.4 | $3/$15 | "Best coding model"; 30-hr autonomous runs | H |
| 2025-09-29 | DeepSeek | V3.2-Exp (DeepSeek Sparse Attention) | O | 671B/37B | 128K | ≈V3.1 | **$0.28/$0.42** | API price cut >50% | H |
| 2025-09-30 | Zhipu | GLM-4.6 | O | 355B/32B | 200K | — | — | | H |
| 2025-09-30 | OpenAI | Sora 2 + Sora app | C | — | — | — | — | #1 App Store; deepfake/IP outcry | H |
| 2025-10-15 | Anthropic | Claude Haiku 4.5 | C | ? | 200K | SWE-V 73.3 | $1/$5 | Sonnet-4-level at 1/3 price | H |
| 2025-10-27 | MiniMax | MiniMax-M2 | O (MIT) | 230B/10B | 200K | top open on AA | $0.30/$1.20 | Agentic coding, cheap | H |
| 2025-11-06 | Moonshot | **Kimi K2 Thinking** | O | 1T/32B (INT4) | 256K | HLE 44.9 w/tools, BrowseComp 60.2 | $0.60/$2.50 | "DeepSeek moment 2" chatter; ~$4.6M train (reported) | H |
| 2025-11-12 | OpenAI | GPT-5.1 (Instant/Thinking) | C | ? | 400K | — | $1.25/$10 | Warmer tone, personalities | H |
| 2025-11-17 | xAI | Grok 4.1 | C | ? | 256K–2M | Arena #1 briefly (~1483) | — | | H |
| 2025-11-18 | Google | **Gemini 3 Pro** + Antigravity IDE | C | ? | 1M | GPQA 91.9, HLE 37.5 (45.8 search), ARC2 31.1 (Deep Think 45.1), SWE-V 76.2, Arena **1501** | $2/$12 (>200K: $4/$18) | Widely seen as new #1; OpenAI "code red" | H |
| 2025-11-19 | OpenAI | GPT-5.1-Codex-Max | C | ? | compaction | SWE-V 77.9 | — | | H |
| 2025-11-20 | Google | Nano Banana Pro (Gemini 3 Pro Image) | C | — | — | — | — | | H |
| 2025-11-24 | Anthropic | **Claude Opus 4.5** | C | ? | 200K | SWE-V **80.9** (first >80), ARC2 37.6, OSW 66 | **$5/$25** (−67%) | Opus becomes daily-driver price | H |
| 2025-12-01 | DeepSeek | V3.2 + V3.2-Speciale | O (MIT) | 671B/37B | 128K | IMO/IOI gold (Speciale) | $0.28/$0.42 | | H |
| 2025-12-02 | Mistral | **Mistral 3** (Large 3 + Ministral 3) | O (Apache) | Large 3: 675B/41B | 256K | — | — | Europe's open frontier attempt | H |
| 2025-12-11 | OpenAI | **GPT-5.2** (Instant/Thinking/Pro) | C | ? | 400K | SWE-V 80.0, SWE-Pro 55.6, ARC2 52.9 (Pro 54.2), GDPval 70.9, GPQA ~92 | $1.75/$14 (Pro $21/$168) | Fast "code red" response to Gemini 3 | H |
| 2025-12-15 | Nvidia | Nemotron 3 Nano (30B-A3B) | O | 30B/3B | 1M | — | — | Super/Ultra promised for 2026 | H |
| 2025-12-17 | Google | Gemini 3 Flash | C | ? | 1M | ≈3 Pro on many evals | $0.50/$3 | Default in Gemini app | H |
| 2025-12-22 | Zhipu | GLM-4.7 | O | 355B/32B | 200K | SWE-V ~73.8 | — | Pre-IPO (HK listing Jan 2026) | M |
| 2025-12-23 | MiniMax | MiniMax-M2.1 | O | 230B/10B | 200K | — | — | | M |

### 1.4 — 2026 (Jan → Nov)

| Date | Lab | Model | O/C | Params | Ctx | Key scores | $ in/out | Notes / reception | Conf |
|---|---|---|---|---|---|---|---|---|---|
| 2026-01 (late) | Alibaba | Qwen3-Max-Thinking | C | >1T | 256K | — | — | | M |
| 2026-01-27 | Moonshot | Kimi K2.5 | O | 1T/32B | 256K | multimodal + agent swarm | ~$0.60/$3 | | M |
| 2026-02-05 | Anthropic | **Claude Opus 4.6** | C | ? | **1M** (beta) | SWE-V ~80.8, TB2.0 ~65, ARC2 ~69 ($3.47/task) , METR 50%-horizon ≈ 12–14.5 h | $5/$25 | Agent Teams in Claude Code; "vibe working" | H |
| 2026-02-05 | OpenAI | GPT-5.3-Codex | C | ? | 400K | — | $1.75/$14 | Same-day as Opus 4.6 | H |
| 2026-02-11 | Zhipu (Z.ai) | **GLM-5** | O (MIT) | 744B/~40B | 200K | record-low hallucination (claimed) | cheap | Trained on Huawei Ascend (claimed) | M |
| 2026-02-16 | Alibaba | **Qwen3.5** (397B-A17B flagship + Plus) | O (397B) / C (Plus) | 397B/17B | 256K–1M | 60% cheaper, 8x throughput (claimed) | — | Lunar New Year drop | M |
| 2026-02-17 | Anthropic | Claude Sonnet 4.6 | C | ? | 1M | ≈Opus 4.5 coding | $3/$15 | | H |
| 2026-02-19 | Google | **Gemini 3.1 Pro** (preview) | C | ? | 1M | ARC2 **77.1** (Deep Think 84.6), tops AA index | $2/$12 | "Doubled reasoning in 3 months" | H |
| 2026-02 | xAI | Grok 4.20 (beta) | C | ? | 2M | multi-agent | ~$2/$6? | | L |
| 2026-03-05 | OpenAI | **GPT-5.4** (Thinking/Pro) | C | ? | 1M (272K default) | OSW ~75 (computer use), SWE-Pro 57.7 | $2.50/$15 | Native computer use | H |
| 2026-03 | Nvidia | Nemotron 3 Super | O | ~120B | 1M | — | — | | M |
| 2026-04-02 | Alibaba | Qwen3.6-Plus (C) + Qwen3.6-35B-A3B (O) | mixed | 35B/3B open | 1M | — | — | 27B dense added Apr 22 | M |
| 2026-04-07 | Anthropic | **Claude Mythos Preview** (Project Glasswing) | C, **restricted** | ? | 1M | SWE-Pro 77.8, SWE-V ~94 (reported); found thousands of 0-days | **$25/$125** (partners only) | Withheld for cyber risk; $100M credits; ~12→150 orgs (Jun 2) | H |
| 2026-04-07..09 | Zhipu | GLM-5.1 | O | 754B MoE | 200K | #1 SWE-Pro among open (claimed) | price raised | | M |
| 2026-04-08 | Meta (MSL) | **Muse Spark** | **C** (first closed Meta frontier) | ? | — | AA 52 (top-5) | app only (API preview) | End of Llama era; Alexandr Wang's MSL | H |
| 2026-04-16 | Anthropic | **Claude Opus 4.7** | C | ? | 1M | SWE-V **87.6**, SWE-Pro 64.3 | $5/$25 | xhigh effort; tokenizer change → stealth cost rise | H |
| 2026-04-20 | Alibaba | Qwen3.6-Max-Preview | C | ? | — | — | TBD | Qwen flagship goes closed | M |
| 2026-04-23 | OpenAI | **GPT-5.5** (+Pro) | C | first fully retrained base since GPT-4.5 | 1M | TB2.0 82.7, OSW-V 78.7, SWE-Pro 58.6, BrowseComp 84.4 | **$5/$30** (Pro $30/$180) | "New class of intelligence"; price doubled; "High" cyber rating | H |
| 2026-04-24 | DeepSeek | **DeepSeek V4** Pro / Flash | O (MIT) | Pro 1.6T; Flash 284B/13B | 1M | SWE-V 80.6 (Flash 79.0), LCB 93.5, CF 3206; admits 3–6 mo behind | Pro $1.74/$3.48 (−75% permanent May 31); Flash ~$0.14/$0.28 | 1/6–1/20 the price of Opus/GPT | H |
| 2026-04-28 | Mistral | Mistral Medium 3.5 | C | ? | — | — | — | | M |
| 2026-04-30 | xAI | Grok 4.3 | C | ? | 1M | — | **$1.25/$2.50** | Aggressive price cut; voice-cloning suite | M |
| 2026-05-19 | Google | **Gemini 3.5 Flash** (I/O) | C | ? | 1M | TB2.1 76.2 (beats 3.1 Pro 70.3), MCP Atlas 83.6 | $1.50/$9 | Price *up* vs 3 Flash; 3.5 Pro promised "next month" | H |
| 2026-05-20 | Cohere | Command A+ | O (Apache) | 218B/25B | 128K | — | — | Final Command A model | M |
| 2026-05 | Microsoft | MAI-Thinking-1 (Build) | C | ? | — | — | — | First Microsoft flagship reasoning model | M |
| 2026-05-28 | Anthropic | **Claude Opus 4.8** | C | ? | 1M | top AA at launch; GDPval-AA 1890 | $5/$25 | 41 days after 4.7; "more honest" | H |
| 2026-05-31 | Nvidia | Nemotron 3 Ultra | O (OpenMDW) | 550B/55B | 1M | AA 48 | — | Trained in NVFP4 on Blackwell | M |
| 2026-06-01 | MiniMax | **MiniMax M3** | O (community lic.) | 428B/23B | 1M | SWE-Pro 59.0, TB2.1 66.0 | ~5–10% of GPT-5.5 cost | Native multimodal | M |
| 2026-06 | Zhipu | GLM-5.2 | O? | — | — | — | — | single source | L |
| 2026-06-09 | Anthropic | **Claude Fable 5** (GA) + **Claude Mythos 5** (restricted) | C | ? | 1M | SWE-Pro 80.3, GDPval-AA 1932, HLE 53.3, AA 60, Arena 1508 | **$10/$50** | "Mythos to the masses" with safeguards; #1 most of summer | M |
| 2026-07-02 | Anthropic | Claude Sonnet 5 | C | ? | 1M | lower hallucination/sycophancy | $2/$10 intro (to Aug 31) | | M |
| 2026-07-09 | OpenAI | **GPT-5.6 Sol / Terra / Luna** | C | ? | 1M | AA: Sol 59, Terra 55, Luna 51; ARC2 ~92.5 (Sol); Agents' Last Exam 53.6 | Sol $5/$30, Terra $2.50/$15, Luna $1/$6 → Jul 30 cut: Terra $2/$12, Luna $0.20/$1.20 | Celestial tier naming; ≈Fable 5 at ⅓ cost | M |
| 2026-07-09 | Meta | Muse Spark 1.1 | C | ? | — | — | — | | L |
| 2026-07-16 | Moonshot | **Kimi K3** | O (weights Jul 26–27) | **2.8T/104B** | 1M | AA #4 of 189 (≈Opus 4.8 / GPT-5.5) | $3/$15 | Largest open model ever; "Fable-level territory" (Fortune) | M |
| 2026-07-21 | Google | Gemini 3.6 Flash, 3.5 Flash-Lite, 3.5 Flash Cyber | C | ? | 1M | — | — | 3.5 Pro still missing (Bloomberg: missed quality bar) | M |
| 2026-07-24 | Anthropic | **Claude Opus 5** | C | ? | 1M | near Fable 5 | $5/$25 (fast 2x) | | M |
| 2026-07-31 | DeepSeek | V4-Flash-0731 | O (MIT) | 284B/13B | 1M | beats V4-Pro on some evals | ~⅓ of Pro | Monthly cadence begins | M |
| 2026-08-03 | Alibaba | **Qwen3.8-Max** | O (weights "next week") | **2.4T/95B** | 1M | 16-day autonomous SWE run (claimed) | — | "Global #2" claim; trails Anthropic on some tests | M |
| 2026-08-12 | xAI | Grok 4.6 | C | ~1.5T (pre-launch report) | — | Arena ~1753 (claimed, different scale) | $2/$6 | Grok 5 still training on Colossus 2 | M |
| 2026-08 | Meta | Muse Glimmer | O (Apache) | 30B | — | — | free | Meta's token open model | M |
| 2026-09-01 | Anthropic | **Claude Fable 5.1 / Mythos 5.1** | C (Mythos restricted) | same model, different safeguards | 1M | TB4.0 ~60.9 (Mythos) | $10/$50; cache read $0.25 | Incremental | M |
| 2026-09-03 | OpenAI | **GPT-6 Astra** | C | ? | 1M (>272K priced higher) | HLE **54.8**, ARC2 **95**, ARC3 62.7 (standard) / 99.9 (OpenAI harness), TB4.0 57.9, OSW2.0 72.6, AA ~53 | **$10/$50** (>272K $20/$75) | GPT-6 era; harness-dependent claims criticised | M |
| 2026-09-10 | DeepSeek | V4.1 (Flash) | O | — | 1M | DeepSWE 74.2 | — | | L |
| 2026-09-21 | xAI | Grok 4.7 | C | ? | — | behind Fable 5.1 / Astra | $2/$6 | "Bigger but late" | M |
| 2026-09-22 | Anthropic | **Claude Opus 5.5** | C | ? | 1M, 128K out | ARC2 93.3, WebDev Arena #1, OSWorld-2.1 leader | **$4/$20** | First Claude 5.5 model; available ≥ Sep 2027 | M |
| 2026-09-22/29 | OpenAI | GPT-6 Sol & Luna → **GPT-6.1 Sol** (Sep 29) | C | ? | 1M | AA 52 (≈Astra) ; ARC2 94.2 | Sol $2/$10 (1/5 Astra) | Naming confusing across sources | M |
| 2026-09-28 | Anthropic | Claude Sonnet 5.5 | C | ? | 1M | beats Opus 5.5 on one coding bench | $2/$10 | 30% faster output | M |
| 2026-09-30 / 10-13 | Google | **Gemini 4 Argon** (announced / GA) | C | ? | 1M+ | AA 53, Arena 1524, DeepSWE 77.9 | $2/$10 intro → $4/$20 from Dec 1 | Gemini 4 era; "beats Astra at 40% cost" | M |
| 2026-10-06 | Mistral | **Mistral Large 4** (public preview) | O (weights ~Oct 27) | ~1–1.05T MoE | 1M | — | — | Replaces Medium 3.5 (deprecated Oct 31) | M |
| 2026-10-06 | Google | Nano Banana 2.1, Gemini Omni Flash (video), Genie 4 | C | — | — | — | — | | M |
| 2026-10-07 | Anthropic | Claude Haiku 5.5 | C | ? | — | — | **$0.10/$0.50** (≤100K ctx) | −75–90% vs Haiku 4.5 | M |
| 2026-10-12 | Meta | **Muse Wonder / Wonder Full** | C | ? | 1M | ≈Fable 5.1 / Astra (Meta-reported) | $4/$20 | 1.8M iOS downloads in 12 days | M |
| 2026-10-17 | DeepSeek | V4.1-Flash-1017 | O (MIT) | — | 1M | DeepSWE 77.0 | — | + Search/Fetch APIs $0.75/1K calls | L |
| 2026-10 | Microsoft | MAI-Base-2 (pretraining done) | weights licensed to partners | 2.8T/80B | — | "beats GPT-5.6 Sol base at ¼ compute" | — | 16K GB200 × 38 days | M |
| 2026-10-26 | OpenAI | **GPT-6.1 Terra** | C | mid-size | 1M | ~4 AA pts below 6.1 Sol | **$1/$5** | | M |
| 2026-10-28 | Google | **Gemini 4 Carbon** (staged; Fairwind cyber program, US gov pre-release) | C, restricted | ? | — | AA **59** (v5, #1), Arena **1528** (#1), 15/17 benchmark wins (Google) | $2/$10 intro (planned) | Google's first "Mythos-class" gated model | M |
| 2026-11-04 | OpenAI | GPT Image 2.6 (Sunburst/Flare) | C | — | — | — | — | | M |
| 2026-11-05 | OpenAI | GPT-6 Cyber (reported) | C, restricted | — | — | — | — | Answer to Mythos/Carbon | L |
| 2026-11 | Anthropic | Claude Fable 5.2 (reported, restricted) | C | — | — | — | $8/$40 | single blog source | L |
| 2026-12 (exp.) | Amazon | New Nova frontier model @ re:Invent (rumor) | C | — | — | — | — | Nova Premier EOL Sep 14 2026 | L |
| 2026 (exp.) | xAI | Grok 5 (6T claimed) | C | 6T (Musk) | — | Musk: "nearly perfect HLE", "10% AGI chance" | — | Slipped from late-2025 → Q1 → Q2 → "2026"; Polymarket 82% by Dec 31 | M |

### 1.5 — Selected non-model events (good for in-game news ticker)

| Date | Event | Conf |
|---|---|---|
| 2023-03-22 | FLI "Pause Giant AI Experiments" letter | H |
| 2023-05-30 | CAIS extinction-risk statement | H |
| 2023-10-30 | US Executive Order 14110 on AI (revoked Jan 20 2025) | H |
| 2023-11-01 | UK Bletchley AI Safety Summit | H |
| 2023-11-17..22 | OpenAI board fires & rehires Sam Altman | H |
| 2024-03-13 | EU AI Act passed (in force Aug 1 2024; GPAI duties Aug 2 2025; enforcement Aug 2 2026) | H |
| 2024-09-29 | California SB 1047 vetoed | H |
| 2025-01-20 | Trump revokes EO 14110; Jan 23 new AI EO | H |
| 2025-01-27 | DeepSeek shock: Nvidia −17% (−$589B) | H |
| 2025-04 | US bans H20 exports to China (later allowed w/ 15% revenue share, Aug 2025) | H |
| 2025-06 | Meta buys 49% of Scale AI ($14.3B), forms Meta Superintelligence Labs; $100M+ pay packages | H |
| 2025-07-23 | US "America's AI Action Plan" | H |
| 2025-09-22 | Nvidia–OpenAI 10 GW LOI (up to $100B) | H |
| 2025-09-29 | California SB 53 (frontier transparency) signed | H |
| 2025-10-06 | AMD–OpenAI 6 GW deal (+ warrants up to 10% of AMD) | H |
| 2025-10-13 | Broadcom–OpenAI 10 GW custom chip deal | H |
| 2025-10-23 | Google–Anthropic: up to 1M TPUs, >1 GW in 2026 | H |
| 2025-10-28 | OpenAI recapitalised as PBC; Microsoft ~27% | H |
| 2025-11-18 | Microsoft/Nvidia invest up to $5B/$10B in Anthropic; Anthropic commits $30B Azure | H |
| 2025-12 | US EO targeting state AI law preemption; H200 exports to China permitted with revenue cut | M |
| 2025-12-24 | Nvidia–Groq $20B licence + acqui-hire | H |
| 2026-01 | OpenAI–Cerebras >$10B, 750 MW inference deal | H |
| 2026-02..03 | Anthropic–Pentagon dispute over usage restrictions (supply-chain-risk designation reported) | M |
| 2026-03 | Oracle/OpenAI scrap 600 MW Abilene expansion; Microsoft takes it | M |
| 2026-03-16..19 | Nvidia GTC 2026: Vera Rubin in production; Rubin Ultra/Kyber 2027; Feynman 2028 | H |
| 2026-04-22 | Google TPU 8t / 8i | H |
| 2026-04 (late) | OpenAI says 10 GW of compute contracted (2 years early) | M |
| 2026-05-14 | Cerebras IPO (~$56B fully diluted day-1) | M |
| 2026-05-28 | Anthropic $65B Series H @ $965B post | M |
| 2026-06 | OpenAI confidential IPO filing (reported) | L |
| 2026-07-27 | EU Digital Omnibus on AI in force: high-risk delayed to Dec 2027 / Aug 2028; GPAI untouched | H |
| 2026-07 (end) | Anthropic run-rate >$65B vs OpenAI ~$40B | M |
| 2026-08-02 | EU AI Office enforcement powers over GPAI begin | H |
| 2026-10-26 | Anthropic public S-1 (Nasdaq: ANT); listing targeted before Thanksgiving | M |
| 2026-10/11 | GPU rental prices rising (AWS H100 capacity blocks $5.19→$5.97; Nebius $3.85→$4.50) amid HBM/DRAM crunch | M |

---

## 2. Frontier-snapshot tables (for calibrating rival "capability" over time)

Use these as anchor points for a smooth rival capability curve. "Best available" = best generally-available model
that month (restricted models in brackets).

| Quarter | Best model(s) | MMLU | GPQA | SWE-V | HLE (no tools) | ARC-AGI (ver) | AIME | Arena Elo* | Typical flagship $ in/out |
|---|---|---|---|---|---|---|---|---|---|
| 2023 Q1 | GPT-4 | 86.4 | ~36 | ~2 | ~3 | ARC1 ~5% | ~10 | ~1160 | $30/$60 |
| 2023 Q4 | GPT-4 Turbo | 86.5 | ~40 | ~3 | ~3 | ARC1 ~5% | ~10 | ~1250 | $10/$30 |
| 2024 Q2 | GPT-4o, Claude 3.5 Sonnet | 88.7 | 54–59 | 33 | ~4 | ARC1 ~10–20% | ~13 | ~1285 | $3–5/$15 |
| 2024 Q4 | o1, Claude 3.5 Sonnet (new) [o3 announced] | 92 | 78 | 49 | ~9 | ARC1 32% (o1) [o3 76–88%] | 79–83 | ~1360 | $15/$60 (o1) |
| 2025 Q1 | Gemini 2.5 Pro, Claude 3.7, R1 | 90–92 | 84 | 63 | 18.8 | ARC2 ~1–4% | 86.7 ('25) | ~1440 | $1.25–3/$10–15 |
| 2025 Q2 | o3, Claude 4, Gemini 2.5 Pro GA | ~91 | 83–86 | 72–79 | 20 | ARC2 ~3–9% | 88–92 | ~1460 | $2/$8 (o3) |
| 2025 Q3 | GPT-5, Grok 4, Sonnet 4.5 | saturated | 87–89 | 75–77 | 25 (44 w/tools) | ARC2 10–16% | 94.6 | ~1450–1480 | $1.25/$10 |
| 2025 Q4 | Gemini 3 Pro, Opus 4.5, GPT-5.2 | sat. | 92 | 80–81 | 37.5 | ARC2 31–54% | ~100 (w/code) | ~1500 | $2–5/$12–25 |
| 2026 Q1 | Gemini 3.1 Pro, Opus 4.6, GPT-5.4 | sat. | ~94 | ~81 | ~44 | ARC2 69–84% | sat. | ~1500+ | $2–5/$12–25 |
| 2026 Q2 | Opus 4.7/4.8, GPT-5.5, Fable 5 [Mythos Preview] | sat. | sat. | 87.6 [~94] | ~53 | ARC2 ~85–90% | sat. | ~1508 | $5–10/$25–50 |
| 2026 Q3 | GPT-6 Astra, Fable 5.1, Opus 5.5, GPT-5.6 Sol | sat. | sat. | sat. (→SWE-Pro ~80) | 54.8 | ARC2 92–95%; ARC3 ~63% | sat. | ~1515–1525 | $4–10/$20–50 |
| 2026 Q4 | Gemini 4 Carbon/Argon, Astra, Opus 5.5 | sat. | sat. | sat. | ~55–60 | ARC2 ~95%; ARC3 ~63%+ | sat. | ~1528 | $2–10/$10–50 |

*Arena values are on the contemporary scale at the time; the scale drifts upward ~20–40 points/yr.

**Open-weights lag behind closed frontier:** ~12–18 months in 2023 (Llama 2 vs GPT-4) → ~6–9 months in 2025 (R1 vs o1:
~4 months) → ~3–6 months in 2026 (DeepSeek V4 openly says "3–6 months"; Kimi K3 ≈ Opus 4.8 at launch, ~7 weeks
behind). Game rule: open-weights frontier = closed frontier capability delayed by `lag_months`, where lag shrinks from
14 (2023) to ~4 (2026) and floats 3–6 thereafter (shocks can make it 0 for a month).

---

## 3. Company personalities & strategy (AI-rival drivers)

### 3.1 Narrative profiles

**OpenAI — "The Hype Empire / Product Machine."** Consumer-first (ChatGPT ~800M–1B weekly users by 2026), ships
constantly, names things confusingly (GPT-4o/o1/o3/4.1/4.5/5/5.x; then "Sol/Terra/Luna" tiers in 2026 and
"Astra" for the top model). Responds to rival launches within days–weeks ("code red" Dec 2025 → GPT-5.2 in ~3 weeks).
Huge compute deals (Stargate, Nvidia 10 GW, AMD 6 GW, Broadcom 10 GW, Cerebras 750 MW, AWS $38B) — more promised
than built. Price strategy: aggressive at mid-tier, premium "Pro" tiers ($30/$180, $200/mo). Occasional open model
(gpt-oss). Cadence: major numbered release every ~3–4 months in 2025–26, point releases monthly. Weakness:
benchmark-presentation controversies, leadership drama, cash burn.

**Anthropic — "The Safety-First Coding Juggernaut."** Enterprise/API & developer-tools heavy (Claude Code is the
breakout product). Strong on coding/agents; frequently #1 on SWE-bench. Tiers Haiku/Sonnet/Opus, plus from 2026 a
restricted top tier (Mythos) and a safeguarded GA version (Fable). Willing to *withhold* models for cyber risk
(Mythos Preview Apr 2026). Price cuts on Opus (Opus 4.5 $15→$5). Multi-cloud compute (Google TPUs ~1M chips /
3.5 GW in 2027, AWS Trainium Project Rainier, Azure/Nvidia). Cadence 2026: an Opus-class release every ~6–8 weeks
(4.6 Feb, 4.7 Apr, 4.8 May, 5 Jul, 5.5 Sep). Overtook OpenAI in run-rate revenue and valuation in mid-2026; IPO
late 2026. Weakness: rate limits/capacity crunch, political friction (Pentagon dispute).

**Google DeepMind — "The Sleeping Giant That Woke Up."** Slow and embarrassing in 2023 (Bard), then from Gemini 2.5
(Mar 2025) onward the most consistent leader on Arena; owns the full stack (TPUs, data, Search, Android, YouTube).
Cheapest high-end pricing ($2/$12; intro pricing on Gemini 4). Releases Flash first, Pro later; Pro sometimes slips
(3.5 Pro missed quality bar and was effectively skipped in favour of Gemini 4). Strong multimodal (Veo, Nano Banana,
Genie world models). Gated cyber model (Gemini 4 Carbon, Fairwind). Cadence: big gen yearly (Dec 2023, Dec 2024,
Mar 2025, Nov 2025, Sep–Oct 2026), ".1/.5" mid-cycle every ~3–4 months.

**Meta — "The Open-Source Champion Turned Closed."** 2023–2024 Llama era = open-weights leader; Llama 4 (Apr 2025)
flopped → $14B Scale AI deal, Meta Superintelligence Labs, nine-figure hires. 2026: closed Muse family (Spark Apr,
Wonder Oct), token open model (Muse Glimmer 30B). Massive capex (Prometheus 1 GW 2026, Hyperion up to 5 GW).
Personality: spends anything, reorganises often, consumer distribution (3B+ users) is its edge, mediocre dev
mindshare. Cadence: irregular, 6–9 months between flagships.

**xAI (merged into SpaceX/"SpaceXAI" branding in 2026) — "The Brute-Force Maverick."** Builds compute absurdly
fast (Colossus 100K H100 in 122 days, 2024; Colossus 2 ~1 GW). Leads benchmarks briefly at launch (Grok 3, Grok 4,
Grok 4.1), then fades. Edgy/low-guardrail persona, scandals (MechaHitler Jul 2025, deepfake image issues). Musk
overpromises dates (Grok 5 slipped >1 year). Aggressive low pricing (Grok 4 Fast $0.20/$0.50; Grok 4.3 $1.25/$2.50).
Open-sources *old* models (Grok-1, Grok 2.5). Cadence: point release every ~5–8 weeks in 2026 (4.20, 4.3, 4.6, 4.7).

**Mistral — "Europe's Sovereign Champion."** Efficient open models (Apache), alternates open/closed, sells
sovereignty to EU governments/enterprises (ASML-led funding 2025). Usually 6–12 months behind frontier. Cadence:
many small releases; flagship ~yearly (Large 2 Jul 2024, Large 3 Dec 2025, Large 4 Oct 2026).

**DeepSeek — "The Efficient Ghost."** Hedge-fund-funded, no marketing, research-paper-first, MIT licence, cheapest
prices on Earth, low-precision/sparse-attention innovations (MLA, MoE, DSA, FP8). Releases are rare but shocking
(V3 Dec 2024, R1 Jan 2025 market crash, V4 Apr 2026). Constrained by export controls (H800/H20, Huawei Ascend). From
mid-2026 monthly incremental drops. Personality: quiet, cheap, open, occasionally upends markets.

**Alibaba Qwen — "The Open-Weights Factory."** Most model variants of anyone (0.5B → 2.4T), Apache licences, most
downloaded on HF; increasingly keeps "Max" flagship closed (but opened Qwen3.8-Max). Cadence: something every month,
generation every ~4–6 months (2.5 Sep 2024, 3 Apr 2025, 3.5 Feb 2026, 3.6 Apr 2026, 3.8 Aug 2026).

**Moonshot (Kimi) — "The Long-Context Agent Specialist."** Big MoE open models (K2 1T, K3 2.8T), agentic coding,
modified-MIT. Cheap training claims. Cadence: major ~every 6–8 months, updates in between.

**Zhipu / Z.ai (GLM) — "The State-Aligned Public Company."** Tsinghua spin-off, on US Entity List (Jan 2025), HK IPO
early 2026, trains on Huawei Ascend, MIT-licensed GLM-4.5→5.1, coding-plan subscriptions. Cadence ~2–3 months.

**MiniMax — "The Cheap Long-Context Multimodal Shop."** Linear/sparse attention, 1M–4M context, video (Hailuo),
audio. Open weights since 2025. Cadence ~2–4 months.

**Microsoft — "The Hedger."** OpenAI's largest backer (≈27% after 2025 recap) but builds MAI models (MAI-1-preview
2025, MAI-Thinking-1 2026, MAI-Base-2 2.8T Oct 2026), small Phi models, and resells everyone (Foundry hosts Claude,
Grok, DeepSeek). Personality: platform first, model second; slow, careful.

**Amazon — "The Landlord."** AWS Bedrock sells everyone; big Anthropic investor ($8B) and Trainium supplier
(Project Rainier). Own Nova models are mid-tier, cheap; Nova Premier retired Sep 2026; new frontier model rumored
for re:Invent Dec 2026. Personality: infrastructure profits over model glory.

**Cohere — "The Enterprise Specialist."** RAG/tool-use, private deployment, Canada/sovereign. Never frontier. Cadence
~yearly.

**Nvidia — "The Arms Dealer."** Sells shovels to everyone, invests in everyone (OpenAI, xAI, Anthropic, Mistral…),
releases open Nemotron models to grow demand. Absorbed Groq. Annual GPU cadence.

**Others worth adding as minor rivals:** ByteDance Seed (Doubao, Seedance video; cheapest consumer AI in China),
Baidu ERNIE (open-sourced 4.5 in Jun 2025), Tencent Hunyuan, StepFun, 01.AI (faded), Inflection (absorbed by MSFT
2024), Character.AI (Google licence 2024), SSI (Ilya Sutskever, no product), Thinking Machines (Mira Murati; Tinker).

### 3.2 Config table — rival parameters (0–10 scales unless noted)

| Lab id | Archetype | Start tier (Jan 2023) | Flagship cadence (mo) | Point-release cadence (mo) | Openness (0 closed–10 all open) | Price aggressiveness | Safety caution | Hype/marketing | Delay probability | Compute access 2026 | Benchmark-chasing | Reaction speed to rival leap (wks) | Scandal risk |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| openai | Hype product machine | Leader (10) | 4 | 1 | 2 | 6 | 5 | 10 | 0.15 | 10 | 8 | 3 | 6 |
| anthropic | Safety-first coder | Challenger (7) | 2 (2026) / 4 (2023–25) | 1.5 | 0 | 5 | 10 | 5 | 0.10 | 8 | 7 | 6 | 3 |
| google | Sleeping giant | Laggard (6) → leader | 9 (gen) / 3 (.x) | 1 | 4 | 8 | 7 | 6 | 0.30 | 10 | 7 | 6 | 3 |
| meta | Open→closed spender | Open leader (7) | 8 | 4 | 8→3 (2026) | 9 | 3 | 7 | 0.35 | 9 | 6 | 12 | 5 |
| xai | Brute-force maverick | None (founded Jul 2023) | 6 | 1.5 | 3 (old models) | 8 | 1 | 9 | 0.60 | 9 | 9 | 4 | 9 |
| mistral | EU sovereign | Startup (3) | 12 | 2 | 7 | 7 | 4 | 4 | 0.25 | 4 | 4 | 16 | 2 |
| deepseek | Efficient ghost | Unknown (2) | 8 (→1 from mid-2026) | 3 | 10 | 10 | 2 | 1 | 0.40 | 4 (export-limited) | 5 | 20 | 3 |
| qwen | Open factory | Mid (3) | 5 | 1 | 9 | 9 | 3 | 4 | 0.15 | 6 | 7 | 8 | 2 |
| moonshot | Long-ctx agent | Startup (2) | 7 | 3 | 9 | 8 | 3 | 5 | 0.25 | 4 | 7 | 12 | 2 |
| zhipu | State-aligned | Mid (3) | 3 | 2 | 8 | 7 | 4 | 4 | 0.20 | 4 (Ascend) | 6 | 10 | 2 |
| minimax | Cheap multimodal | Startup (2) | 4 | 2 | 8 | 9 | 3 | 4 | 0.20 | 4 | 6 | 10 | 2 |
| microsoft | Hedger/platform | Partner (n/a) | 9 | 6 | 5 (Phi open) | 5 | 6 | 4 | 0.40 | 9 | 4 | 26 | 3 |
| amazon | Landlord | Mid (2) | 12 | 6 | 1 | 8 | 6 | 3 | 0.40 | 9 | 3 | 30 | 2 |
| cohere | Enterprise niche | Mid (3) | 12 | 6 | 5 | 5 | 6 | 2 | 0.20 | 3 | 2 | 40 | 1 |
| nvidia | Arms dealer | n/a (hardware) | 12 (models) | 6 | 9 | 10 (free) | 5 | 6 | 0.10 | 10 | 4 | n/a | 1 |

### 3.3 Release-cadence math (derived from §1)

| Lab | 2023 notable releases | 2024 | 2025 | 2026 (to Nov) | Median gap between "frontier" releases 2025–26 |
|---|---|---|---|---|---|
| OpenAI | 4 | 9 | 15 | 12 | ~2 mo (5→5.1→5.2→5.3C→5.4→5.5→5.6→6 Astra→6.1) |
| Anthropic | 3 | 5 | 7 | 12 | ~1.7 mo (4.5→4.6→4.7→4.8→Fable 5→Opus 5→5.1→5.5) |
| Google | 3 | 8 | 10 | 8 | ~3 mo (2.5→3→3.1→3.5F→4 Argon→4 Carbon) |
| Meta | 2 | 4 | 1 | 4 | ~6 mo |
| xAI | 1 | 3 | 5 | 5 | ~2 mo (point releases); Grok 5 slipped 12+ mo |
| DeepSeek | 1 | 3 | 6 | 5 | ~4 mo (big), ~1 mo since Jul 2026 |
| Qwen | 2 | 4 | 6 | 6 | ~2 mo |

---

## 4. Hardware timeline & catalogue

### 4.1 Accelerator spec table (dense FLOPS unless stated; "s" = with 2:4 sparsity)

| Chip | Vendor | Announced | Volume availability | BF16 dense | FP8 dense | FP4 dense | HBM | Mem BW | TDP | Est. unit price (new) | Conf |
|---|---|---|---|---|---|---|---|---|---|---|---|
| A100 SXM 80GB | Nvidia | May 2020 | 2020–21 | 312 TF | — (INT8 624) | — | 80 GB HBM2e | 2.0 TB/s | 400 W | $10–15K (2023), ~$8K used (2026) | H |
| H100 SXM | Nvidia | Mar 2022 | Q1 2023 volume | 989 TF | 1,979 TF (3,958 s) | — | 80 GB HBM3 | 3.35 TB/s | 700 W | $25–40K (2023 scarcity), ~$20–25K (2026) | H |
| H200 SXM | Nvidia | Nov 2023 | Q3 2024 | 989 TF | 1,979 TF | — | 141 GB HBM3e | 4.8 TB/s | 700 W | $30–35K | H |
| H20 (China) | Nvidia | 2023 | 2024 | 148 TF | 296 TF | — | 96 GB | 4.0 TB/s | 400 W | ~$12K | H |
| B200 | Nvidia | Mar 2024 (GTC) | Q1 2025 volume | 2.25 PF | 4.5 PF | 9 PF | 192 GB HBM3e (180 usable) | 8 TB/s | 1,000 W | $30–40K | H |
| GB200 NVL72 (rack) | Nvidia | Mar 2024 | ramp Q1–Q3 2025 | 180 PF | 360 PF (720 s) | 720 PF (1.44 EF s) | 13.4 TB | 576 TB/s | ~120–132 kW | ~$3.0–3.9M / rack | H |
| B300 / GB300 NVL72 (Blackwell Ultra) | Nvidia | Mar 2025 | H2 2025 | ~2.5 PF | ~5 PF | **15 PF** (per GPU) / 1.1 EF rack | 288 GB HBM3e | 8 TB/s | ~1,100–1,400 W | ~$3.5–4.0M / rack | H |
| Rubin (VR200), Vera Rubin NVL144/"NVL72" | Nvidia | Mar 2025 (roadmap); "full production" CES/GTC 2026 | deployments ~Sep–Oct 2026 | ~(not disclosed) | rack 1.2 EF (training) | **50 PF NVFP4 inference / ~35 PF training** per GPU; rack **3.6 EF** | 288 GB **HBM4** | ~13–22 TB/s (sources differ) | ~1.8–2.3 kW (est.) | est. $50–60K/GPU; ~$6–8M/rack | M |
| Rubin CPX | Nvidia | Sep 2025 | end-2026 | — | — | 30 PF NVFP4 | 128 GB GDDR7 | — | — | — (prefill chip; NVL144 CPX rack 8 EF) | M |
| Rubin Ultra NVL576 (Kyber rack) | Nvidia | Mar 2025 | H2 2027 | — | rack 5 EF (training) | ~100 PF per 4-die package; rack **15 EF** inference | 1 TB HBM4E per package | — | ~600 kW / rack | est. $15–25M / rack | M |
| Feynman (+ Rosa CPU, LP40 LPU, CPO NVLink) | Nvidia | GTC 2025/2026 | 2028 | — | — | (die-stacked, custom HBM) | custom HBM | — | — | — | M |
| MI300X | AMD | Dec 2023 | Q1 2024 | 1.3 PF | 2.6 PF | — | 192 GB HBM3 | 5.3 TB/s | 750 W | $10–15K | H |
| MI325X | AMD | Jun 2024 | Q1 2025 | 1.3 PF | 2.6 PF | — | 256 GB HBM3e | 6 TB/s | 1,000 W | ~$15–20K | H |
| MI355X (MI350 series) | AMD | Jun 2025 | Q3 2025 | ~2.5 PF | ~5 PF | ~10 PF (FP4/FP6) | 288 GB HBM3e | 8 TB/s | 1,400 W | ~$20–25K | H |
| MI450 / **MI455X** + Helios rack (72 GPUs) | AMD | Jun 2025 / Advancing AI 2026 (Jul) | shipping ~end Q3 2026 → OpenAI 1st GW H2 2026 | ~10 PF (est.) | ~20 PF; rack **1.4 EF** | ~40 PF; rack **2.9 EF** | **432 GB HBM4** (rack 31 TB) | 19.6 TB/s | ~2 kW (est.) | est. $35–45K | M |
| MI430X | AMD | 2026 | H1 2027 | FP64 288 TF (HPC) | — | — | 432 GB HBM4 | — | — | — | M |
| MI500 | AMD | CES 2026 | 2027 | — | — | — | — | — | — | — | M |
| TPU v5e | Google | Aug 2023 | 2023 | 197 TF | (INT8 394) | — | 16 GB | 0.8 TB/s | ~? | rent only: $1.20/chip-hr | H |
| TPU v5p | Google | Dec 2023 | 2024 | 459 TF | (INT8 918) | — | 95 GB | 2.76 TB/s | — | $4.20/chip-hr | H |
| TPU v6e Trillium | Google | May 2024 | GA Dec 2024 | 918 TF | (INT8 1.8 P) | — | 32 GB | 1.6 TB/s | — | $2.70/chip-hr | H |
| TPU v7 **Ironwood** | Google | Apr 2025 | GA Nov 2025 | ~2.3 PF | **4.6 PF** | — | 192 GB HBM3e | 7.4 TB/s | ~1 kW (est.) | pod 9,216 chips = 42.5 EF FP8 | H |
| **TPU 8t** (training) / **8i** (inference) | Google (Broadcom / MediaTek) | Apr 22 2026 | late 2026 → Anthropic 3.5 GW in 2027 | — | — | 8t pod 9,600 chips = **121 EF FP4** (~12.6 PF/chip) | 8i: 3x SRAM vs Ironwood | — | 2x perf/W vs Ironwood | 2.7x training price-perf vs Ironwood | M |
| Trainium2 | AWS | Nov 2023 | Dec 2024 | ~0.67 PF | ~1.3 PF | — | 96 GB HBM3 | 2.9 TB/s | ~500 W | Project Rainier ~500K chips (Anthropic) | H |
| Trainium3 (3 nm) | AWS | Dec 2024 | GA Dec 2025 | — | **2.52 PF** | (MXFP4 higher) | 144 GB HBM3e | 4.9 TB/s | — | UltraServer 144 chips ≈ 362 PF FP8 | H |
| Trainium4 | AWS | Dec 2025 (preview) | late 2026–2027 | — | 3x Trn3 | 6x Trn3 | ~288 GB (est.) | 4x Trn3 | — | NVLink Fusion + UALink | M |
| Cerebras WSE-3 (CS-3) | Cerebras | Mar 2024 | 2024 | 125 PF (sparse FP16 claim) | — | — | 44 GB on-chip SRAM | 21 PB/s SRAM | ~23 kW | ~$2–3M / system | H |
| Groq LPU v1 | Groq (→Nvidia licence Dec 2025) | 2020 | 2023–25 | 188 TF FP16 | (INT8 750 TOPS) | — | 230 MB SRAM | 80 TB/s | ~300 W | ~$20K/card; sold as tokens | H |
| Huawei Ascend 910C | Huawei | 2024 | 2025 | ~0.8 PF | — | — | 128 GB | 3.2 TB/s | — | China-only; CloudMatrix 384 | M |
| Ascend 950PR / 950DT / 960 / 970 | Huawei | Sep 2025 roadmap | Q1 2026 / Q4 2026 / Q4 2027 / Q4 2028 | — | 950: ~1 PF FP8 | 950: ~2 PF FP4 | self-made HBM | — | — | Atlas 950 SuperPoD 8,192 chips (Q4 2026), Atlas 960 15,488 chips (Q4 2027) | M |

### 4.2 Cloud rental $/GPU-hour by year (typical on-demand list; reserved ~30–50% lower)

| Chip | 2023 | 2024 | 2025 | 2026 (Nov) | Notes |
|---|---|---|---|---|---|
| A100 80GB | $1.80–4.00 (scarce) | $1.30–2.50 | $0.80–1.80 | $0.60–1.50 | Legacy, inference/fine-tune |
| H100 | $4.00–8.00 (allocation-only) | $2.50–4.00 | $1.90–3.00 | **$2.00–7.00**, median ~$3.40; rising Q4 (AWS CB $5.97) | Floor ~$1.50 marketplace |
| H200 | — | $4.00–6.00 | $3.00–4.50 | $2.50–5.00 | |
| MI300X | — | $2.50–4.50 | $1.50–2.50 | $1.20–2.50 | Fewer providers |
| B200 | — | — | $5.00–8.00 | $4.00–8.20 (neocloud ~$6.25–6.89; AWS ~$14 per-GPU equivalent) | |
| GB200 (per GPU) | — | — | $8.00–18.00 (early) | $8.00–16.00 (Oracle $16) | Usually sold by rack / contract |
| GB300 (per GPU) | — | — | — | ~$9–18 (contract) (est.) | |
| Rubin (per GPU) | — | — | — | not on-demand yet (contracts only); est. $15–25 2027 | |
| TPU (per chip) | v5e $1.20, v5p $4.20 | v6e $2.70 | Ironwood contract | TPU 8 contract | Google discounts heavily for commit |

**Rule of thumb for the game:** a GPU's rental price falls ~40–50% within ~18 months of its successor reaching
volume, and ~70% by 3 years; but shocks (DeepSeek-style demand spikes, HBM/DRAM shortages like late 2026) can
push prices up 10–20% temporarily.

### 4.3 Cluster/datacenter milestones

| Year | Largest single training clusters | Power | Examples | Conf |
|---|---|---|---|---|
| 2023 | ~25K A100 / ~10–20K H100 | ~30–50 MW | GPT-4 (~25K A100, ~2e25 FLOP); Inflection 22K H100 | H |
| 2024 | ~100K H100 | ~150 MW | xAI Colossus (Memphis, 122 days); Meta 2×24K H100 (Llama 3) | H |
| 2025 | 200K+ H100/H200; GB200 NVL72 clusters | 300 MW–1 GW sites | Colossus 1 (~230K); Abilene Stargate (first buildings); Anthropic Project Rainier (~500K Trn2) | H |
| 2026 | 400K+ GB200/GB300; 1 GW campuses | ~1–1.2 GW | Abilene 1.2 GW (full Q4 2026); xAI Colossus 2 (~1 GW); Meta Prometheus (1 GW, Ohio); Microsoft Fairwater | M |
| 2027 (planned) | Rubin / Rubin Ultra / TPU 8 multi-GW | 2–5 GW | Anthropic 3.5 GW TPU; Meta Hyperion (Louisiana, →5 GW); OpenAI–AMD 1st GW+; Stargate sites (Shackelford, Doña Ana, Lordstown, Milam, Saline Twp) | M |
| 2028–30 (planned) | Feynman / TPU 9–10 | 5–10+ GW per company | OpenAI "10 GW contracted"; Nvidia–OpenAI 10 GW; Broadcom 10 GW | M |

### 4.4 Announced roadmaps (beyond Nov 2026)

| Year | Nvidia | AMD | Google | AWS | Others |
|---|---|---|---|---|---|
| 2026 H2 | Vera Rubin NVL144 ramp; Rubin CPX | MI455X / Helios | TPU 8t/8i ship | Trainium3 scale | Huawei Ascend 950DT, Atlas 950 SuperPoD |
| 2027 | **Rubin Ultra** (Kyber NVL144 → NVL576, 15 EF FP4, 1 TB HBM4E/GPU, ~600 kW racks) | MI500 series, MI430X | TPU 9 (expected) | Trainium4 | Ascend 960; Cerebras next-gen (expected); OpenAI–Broadcom custom chip ("Titan") first racks late 2026–2027 |
| 2028 | **Feynman** (stacked dies, custom HBM, Rosa CPU, LP40 LPU, optical NVLink, NVL1152-class scale-up) | MI600 (expected) | TPU 10 (expected) | Trainium5 (expected) | Ascend 970 |

---

## 5. Price & cost trends (data for economy curves)

### 5.1 API price at constant capability (cost per 1M tokens, blended 3:1 in:out)

| Capability level | First available | Launch price (blended) | Price ~12 mo later | Price ~24 mo later | Implied decline |
|---|---|---|---|---|---|
| GPT-4 (MMLU ~86) | Mar 2023 | ~$37.50 | ~$8 (4o, May 2024) | ~$0.25 (4o-mini/Flash/DeepSeek-V3) | ~10x/yr → ~150x in 2 yrs |
| o1 reasoning (GPQA ~78) | Dec 2024 | ~$26 | ~$1–2 (R1-0528, o3 cut, GPT-5 mini) | ~$0.2 (V3.2, Flash) | ~20x/yr |
| Opus 4.5-class (SWE-V ~80) | Nov 2025 | ~$10 | ~$1–3 (DeepSeek V4, Kimi K3, Haiku-class) | — | ~5–10x/yr |

Epoch AI's estimate: price for constant capability falls roughly 9–900x/yr depending on task (median ~40–50x);
game default **÷10 per year** at constant capability is a safe, slightly conservative choice.

### 5.2 Flagship sticker prices stay roughly flat, but premium tiers emerge

| Year | Typical flagship $ in/out | Premium tier | Budget tier |
|---|---|---|---|
| 2023 | $10–30 / $30–60 | GPT-4-32K $60/$120 | gpt-3.5 $0.5/$1.5 |
| 2024 | $2.5–15 / $10–75 | Opus $15/$75, o1 $15/$60 | 4o-mini $0.15/$0.60 |
| 2025 | $1.25–5 / $10–25 | GPT-4.5 $75/$150; o1-pro $150/$600; GPT-5.2 Pro $21/$168 | Flash-Lite $0.10/$0.40, Grok 4 Fast $0.20/$0.50 |
| 2026 | $2–10 / $10–50 | Mythos Preview $25/$125; GPT-5.5 Pro $30/$180 | Haiku 5.5 $0.10/$0.50, GPT-5.6 Luna $0.20/$1.20 |

### 5.3 Training cost of frontier runs (estimates; Epoch-style)

| Year | Frontier training compute (FLOP) | Approx. hardware+energy cost of final run | Example |
|---|---|---|---|
| 2023 | 2e25 | ~$60–100M | GPT-4, Gemini Ultra (~5e25) |
| 2024 | 4–5e25 | ~$100–200M | Llama 3.1 405B (3.8e25) |
| 2025 | 1–5e26 | ~$300M–1B | Grok 3/4 (first >1e26), GPT-4.5 |
| 2026 | 1–5e27 | ~$1–5B | GPT-5.5 / GPT-6 base, Grok 5 (6T), Fable/Mythos 5, Kimi K3 claims far less |
| Trend | **~4–5x/yr** compute | ~2.4–3x/yr cost | Epoch: >30 models above 1e26 by start of 2027, >200 by 2030 |

---

## 6. Projections 2027–2035 (to keep the game going)

### 6.1 Source forecasts summary

| Source | Key claims | How to use in game |
|---|---|---|
| **Epoch AI** ("Can AI scaling continue through 2030?", 2024; trends dashboard Feb 2026) | Training compute 4–5x/yr since 2010 (frontier LLMs ~5x/yr since 2020); 2e29 FLOP runs feasible by 2030 (range 1e29–5e30); constraints in order: power, chip production, data, latency wall; ~30 models >1e26 by 2027, >200 by 2030 | Base compute growth curve; hard caps from power |
| **AI 2027** (Kokotajlo et al., Apr 2025) | Superhuman coder Mar 2027 → superhuman AI researcher Aug 2027 → ASI ~end 2027; "race" vs "slowdown" endings; China steals weights (Feb 2027); OpenBrain ~10 GW compute by end-2027 | Optional "fast-takeoff" scenario branch & event deck |
| **AI Futures Project updates** (Dec 2025 model, Q1 2026, Q2.5 2026) | Medians pushed out then partially back: Automated Coder medians ≈ mid-2028 (Kokotajlo) / mid-2030 (Lifland); reality running ~70–90% of AI-2027 pace | Default "medium" scenario: AI-2027 milestones × ~1.3–2 in time |
| **Situational Awareness** (Aschenbrenner, Jun 2024) | ~0.5 OOM/yr effective compute + 0.5 OOM/yr algorithms; AGI ~2027; $100B/10 GW cluster ~2028 (1e28); $1T / 100 GW (~20% of US electricity) cluster ~2030; national-security "Project" | "Trillion-dollar cluster" late-game build; government-nationalisation event |
| **METR time horizons** | 50%-success task length doubling every ~7 mo (2019–25), ~4 mo since 2023; Opus 4.6 ≈ 12 h, Mythos Preview ≈ 17 h (Aug 2026); suite unreliable >16 h | Drives "agent autonomy" stat: 1 h (2025) → 16 h (2026) → ~1 week (2027) → ~1 month (2028) on trend |
| **Company roadmaps** | OpenAI: automated AI research intern by Sep 2026, full automated researcher by Mar 2028 (Altman, Oct 2025); 10 GW contracted; Anthropic: "country of geniuses in a datacenter" 2026–27 (Amodei), 3.5 GW TPU 2027; Meta: Hyperion 5 GW; xAI: Colossus 2→ 1M GPUs; Nvidia annual cadence to Feynman 2028 | Scripted rival "announcements" |
| **Energy** | US data-centre load ~4–5% of electricity (2024) → 7–12% by 2028–30 (LBNL/EPRI ranges); grid interconnect queues 3–7 yrs; gas turbines sold out to ~2029; nuclear restarts (Palisades 2025–26, Crane/TMI ~2027), SMRs 2030+ | Power as gating resource; cost per MW rising |

### 6.2 Default projected world-state curve (game "medium" scenario)

| Year | Frontier train FLOP | Largest cluster (power) | Leading GPU gen | Flagship $/GPU-hr (new gen, on-demand) | Prev-gen H100-equiv $/hr | Frontier API price (blended, flagship) | Agent 50% horizon (METR-style) | Key benchmark state |
|---|---|---|---|---|---|---|---|---|
| 2026 (now) | 3e27 | 1.2 GW | Vera Rubin | $6–16 (B200/GB200) | $2–4 | $5–20 | ~16 h | ARC2/SWE-V/GPQA saturated; HLE ~55%; ARC3 ~60% |
| 2027 | 1e28 | 2–3.5 GW | Rubin Ultra, TPU 8/9, MI500 | $15–25 (Rubin) | $1.5–3 | $4–20 | ~2–5 days | HLE 70–80%; ARC3 80%+; FrontierMath T4 >50%; new evals (ARC-AGI-4, RE-Bench-long, "Remote Labor Index") |
| 2028 | 3e28 | 5 GW | Feynman, TPU 10 | $20–35 (Feynman) | $1–2 | $3–20 + "agent-hour" pricing | ~2–4 weeks | HLE saturated; automated-coder milestone (median) |
| 2029 | 1e29 | 5–10 GW | Feynman Ultra / post-Feynman | $20–40 | <$1 (H100 retired) | per-task pricing dominant | ~1–3 months | Labs claim "AGI" for knowledge work; benchmark era ends → economic metrics (GDPval, revenue/agent) |
| 2030 | 2e29 | 10 GW (single campus) | next arch (2030) | — | — | — | ~6 months | Epoch "2e29 feasible" point; ~200 models >1e26 |
| 2031–2032 | 5e29–1e30 | 10–20 GW; multi-site training | photonics / 3D stacking | — | — | — | years | Power is binding constraint; space/offshore DC experiments (Musk/Google "Suncatcher" style) |
| 2033–2035 | 1e30–1e31 (fast) / 3e29 (stall) | 20–100 GW national-scale (fast) | post-silicon? | — | — | — | — | Scenario fork: ASI-driven economy vs plateau/regulated |

**Scenario knobs:** `fast` (AI-2027-ish: compute ×6/yr to 2028, automated researcher 2027–28, events: weight theft,
nationalisation, ASI claims), `medium` (above), `slow` (power/financing crunch 2027–28: ×2.5/yr, an "AI winter-lite"
capex pullback, bankrupt neoclouds, GPU rental prices crash 50%).

### 6.3 Plausible future model generations (for rival release scripts, Dec 2026 → 2030)

Names are invented extrapolations from each lab's naming habits — use as defaults, mark as fictional in-game.

| Lab | Late 2026–2027 | 2028 | 2029–2030 | Naming habit |
|---|---|---|---|---|
| OpenAI | GPT-6.2 Astra/Sol/Terra/Luna, GPT-6 Cyber, GPT-6.5 (mid-2027), open "gpt-oss-2" | GPT-7 (celestial tiers continue), "automated researcher" | GPT-7.5 / GPT-8 | Major ~yearly; .x every 1–3 mo; tier names (Astra > Sol > Terra > Luna) |
| Anthropic | Fable 5.2/5.5, Mythos 5.5 (restricted), Haiku/Sonnet 5.5 updates, Claude 6 family (mid-2027) | Claude 6.5; Mythos 6 | Claude 7 | Haiku < Sonnet < Opus < Fable (GA top) < Mythos (restricted); .x every ~2 mo |
| Google | Gemini 4 Argon GA price step (Dec 1), Gemini 4 Carbon GA, Gemini 4 Flash/Flash-Lite, Gemini 4.5 (I/O May 2027) | Gemini 5 (element codenames continue, e.g. "Neon", "Xenon") | Gemini 5.5 / 6 | Major yearly (often Nov–Dec or I/O), Flash first; element names in Gemini 4 |
| Meta | Muse Wonder 1.x, Muse Glimmer 2 (open), Hyperion-trained "Muse" frontier | Muse 2 family | — | Muse Glimmer (open small) < Spark < Wonder < Wonder Full |
| xAI | Grok 4.8, 4.9, **Grok 5** (6T) ~Q1 2027 (slip-prone) | Grok 6 (Colossus 3) | Grok 7 | Integer = Musk hype event; frequent delays (+3–9 mo) |
| DeepSeek | V4.2… monthly; **V5 / R3** (2027) | V6 | — | Rare big drops that move markets |
| Qwen | Qwen3.9 / **Qwen4** (2027) | Qwen4.5 | Qwen5 | Big family, 0.5B→3T+ |
| Moonshot | Kimi K3.5 (early 2027), K4 (late 2027) | K5 | — | |
| Zhipu | GLM-5.5, GLM-6 (2027) | GLM-7 | — | |
| MiniMax | M3.5, M4 (2027) | M5 | — | |
| Mistral | Large 4.x, Medium 4, "Mistral 5" (2027) | — | — | |
| Microsoft | MAI-2 (post-trained MAI-Base-2) early 2027 | MAI-3 | — | |
| Amazon | New Nova frontier (Dec 2026), Nova 3 | — | — | |
| Nvidia | Nemotron 4 (2027) | — | — | |

### 6.4 Future events deck (2027–2035), with suggested in-game probabilities (medium scenario)

| Window | Event | P(occurs) | Effect hook |
|---|---|---|---|
| Nov–Dec 2026 | Anthropic IPO (ANT) prices; first pure-play frontier lab public | 0.8 | Market cap ticker; capital access for Anthropic rival |
| 2027 H1 | OpenAI IPO (~$1T+) | 0.6 | Same |
| 2027 | Grok 5 finally ships, briefly #1 | 0.7 | Arena shake-up |
| 2027 | Rubin Ultra / Kyber 600 kW racks; liquid-cooling retrofit wave | 0.9 | New shop tier; DC upgrade cost |
| 2027 | HBM / DRAM shortage persists → GPU prices +10–25% | 0.5 | Price shock |
| 2027 | Major AI-enabled cyber incident (0-day wave) → mandatory gated "cyber tier" models | 0.4 | Regulation; restricted-model mechanic |
| 2027-12-02 | EU AI Act high-risk (Annex III) obligations apply | 0.85 (could slip again) | EU compliance cost |
| 2027–28 | US federal preemption law / frontier-model licensing debate | 0.5 | Regulation event |
| 2027–28 | China open model reaches #1 on Arena overall | 0.35 | Prestige swing |
| 2027–28 | Taiwan-strait tension → TSMC supply scare | 0.15 | Hardware supply −50% for N months |
| 2028 | "Automated AI researcher" claimed by a lab | 0.5 | R&D speed multiplier for that rival |
| 2028 | Feynman launch; 1 GW per customer becomes common | 0.85 | |
| 2028 | AI capex pullback / neocloud bankruptcies (CoreWeave-style debt stress) | 0.3 | Cheap used GPUs flood market |
| 2028–30 | First 10 GW single-site cluster online | 0.5 | |
| 2029 | A lab publicly declares AGI (contract clause with Microsoft triggered / expert panel) | 0.4 | Huge hype + regulation |
| 2029–30 | Nuclear SMR power for data centres starts (Kairos/Google, X-energy/Amazon, Oklo) | 0.6 | New power source unlock |
| 2030 | Compute governance treaty / international AI agency talks | 0.3 | |
| 2030–32 | Power becomes binding: US DC load >10% of grid; moratoria in some states | 0.5 | Power price ×1.5 |
| 2031–35 | Space-based or offshore data-centre pilots | 0.25 | Late-game tech tree |
| 2032–35 | Either "superintelligence economy" (GDP growth spikes) or "plateau" (benchmarks stall, prices commoditise) | branch | Scenario ending |

### 6.5 Benchmark saturation schedule (for retiring/adding in-game benchmarks)

| Benchmark | Introduced | ~50% reached | Saturated (≥90% / human-level) | Game status |
|---|---|---|---|---|
| MMLU | 2020 | 2022 | 2024 (~92) | retired 2025 |
| GPQA Diamond | Nov 2023 | mid-2024 (Claude 3.5 59) | 2025–26 (92–94) | retire 2026 |
| AIME | — | Sep 2024 (o1) | 2025 (94–100 w/tools) | retire 2026 |
| SWE-bench Verified | Aug 2024 | Oct 2024 (49) | 2026 (87.6; ~94 Mythos) | retire 2026 → SWE-Pro, DeepSWE, FrontierSWE |
| ARC-AGI-1 | 2019 | Dec 2024 (o3) | 2025 | retired |
| ARC-AGI-2 | Mar 2025 | Dec 2025 (GPT-5.2 53) | Q3 2026 (~95) | retire 2026 |
| ARC-AGI-3 (interactive) | 2026 | Sep 2026 (63, standard) | proj. 2027 | active |
| Humanity's Last Exam | Jan 2025 | Sep 2026 (~55) | proj. 2027–28 | active |
| FrontierMath (T1–3 / T4) | Nov 2024 | proj. 2026–27 | proj. 2028 | active |
| Terminal-Bench (2.0→4.0) | 2025 | 2026 | rolling versions | active |
| OSWorld (→2.x) | 2024 | 2025 | rolling versions | active |
| METR time horizon (hours) | 2025 | n/a (unbounded) | suite ceiling ~16 h → needs new suite 2027 | core "autonomy" stat |
| LMArena Elo | 2023 | n/a | never saturates (relative) | keep; rebase yearly |

---

## 7. Config-conversion notes

### 7.1 Suggested JSON-ish schema for a rival release event

```
{ "date": "2026-09-03", "lab": "openai", "model": "GPT-6 Astra", "open": false,
  "params_total_b": null, "params_active_b": null, "context_k": 1000,
  "capability": 96.0,             // internal 0–100 frontier index (see 7.4)
  "bench": { "hle": 54.8, "arc2": 95, "arc3": 62.7, "arena": 1520 },
  "price_in": 10.0, "price_out": 50.0,
  "tags": ["frontier", "restricted_cyber_variant_later"], "confidence": "M",
  "headline": "OpenAI launches GPT-6 Astra; tops HLE, pricey at $10/$50" }
```

### 7.2 Real-schedule mode vs simulated mode

- **Real mode (2023-01 → 2026-11):** fire §1 rows on their dates (H/M rows as scripted; L rows optional).
- **Sim mode (after 2026-11):** for each lab, schedule next release at `last_release + cadence × LogNormal(1, 0.35)`,
  delay with `delay_probability` (add 1–3 months), capability = `frontier_curve(t) − lab_gap + noise`,
  where `lab_gap` derives from Start tier and 2026 standings (Google/OpenAI/Anthropic 0–2 pts, xAI/Meta 2–4,
  Chinese open labs 3–6, Mistral/Amazon/Cohere 8–15).

### 7.3 Hardware shop entries (minimal fields)

`id, vendor, available_from (YYYY-MM), flops_fp8_dense_pf, flops_fp4_dense_pf, hbm_gb, tdp_kw, buy_price_usd,
rent_usd_hr[year], rack_size, interconnect_tier`. Use §4.1–4.2. For unreleased parts use roadmap dates + 0–6 month
random slip (Nvidia slip p≈0.2, AMD p≈0.35, Google p≈0.2, AWS p≈0.3).

### 7.4 Internal capability index ↔ display benchmarks (suggested mapping)

Define `C(t)` for the best closed frontier model: Jan 2023 = 40, Jan 2024 = 50, Jan 2025 = 65, Jan 2026 = 80,
Nov 2026 = 88; then medium scenario +6/yr to 2030 with diminishing increments (asymptote 100 = "AGI-level").
Map to display with logistic curves per benchmark centred on the dates in §6.5 (e.g. SWE-V = 100/(1+e^−(C−72)/5)),
and rebase Arena Elo as `1100 + 5×C` (gives ≈1300 in 2024, ≈1500 late 2025/2026, ≈1560 in 2028).

---

## 8. Known gaps / uncertainties

- WebFetch was unavailable; all 2026 figures are from search-result summaries of secondary sources. Many 2026
  benchmark numbers are vendor-reported and benchmark *versions* differ across sources (AA v4 vs v5, TB 2.0/2.1/4.0,
  OSWorld vs OSWorld-Verified vs 2.0/2.1).
- Conflicting items: GPT-6 Sol vs GPT-6.1 Sol naming/dates (Sep 22 vs Sep 29); Gemini 4 Argon announce (Sep 30) vs GA
  (Oct 13) and whether its API is public; Mistral Large 4 weight release; Qwen3.8-Max weights; Fable 5.2 / GPT-6 Cyber
  (single sources); Rubin memory bandwidth and Rubin/Helios prices (not published — estimates given).
- Not found: Grok 5 release (still unreleased as of last reports), Gemini 3.5 Pro (apparently never shipped GA),
  official Rubin pricing, a confirmed Anthropic IPO pricing date.
- The search budget for this session ran out (~55 searches) before I could check per-model GPQA/MMLU for 2026 models.
  Those cells are left blank or marked "sat." on purpose.

---

## 9. Sources (selection, by topic)

**OpenAI 2026:** the-decoder.com (GPT-5.5 price doubling); thenextweb.com (GPT-5.5 retrained base); vellum.ai &
artificialanalysis.ai/articles/gpt-5-6-has-landed (GPT-5.6 tiers); morphllm.com/gpt-5-6-sol-vs-terra-vs-luna;
datacamp.com/blog/gpt-6-astra; computingforgeeks.com (GPT-6 Astra); aiweekly.co & forkast.news (GPT-6.1 Terra $1/$5);
runtimewire.com (GPT-6.1 Sol 1/5 Astra price); thenewstack.io/openai-launches-gpt-5-4; llm-stats.com (GPT-5.3 Codex);
openai.com release notes (GPT Image 2.6).
**Anthropic 2026:** anthropic.com/project/glasswing & /news/expanding-project-glasswing; venturebeat.com (Fable 5);
en.wikipedia.org/wiki/Claude_Mythos; vellum.ai (Fable/Mythos 5.1); aipricing.guru & lilting.ch (Opus 4.7);
datanorth.ai / qz.com (Opus 4.8); letsdatascience.com / pasqualepillitteri.it (Opus 5); unite.ai / mixed-news.com
(Opus 5.5); decrypt.co & unite.ai (Sonnet 5.5); techrepublic.com (Haiku 5.5); pulse2.com (Sonnet 5);
businesstoday.in / thenewstack.io (Opus 4.6, Sonnet 4.6).
**Google 2026:** techcrunch.com (Gemini 3.5 Flash; 3.6 Flash without 3.5 Pro); officechai.com; blog.google
(Oct 2026 AI updates); artificialanalysis.ai (Gemini 4 Argon, Carbon); propakistani.pk; syntaxandsignal.tech;
venturebeat.com (Gemini 3.1 Pro); deeplearning.ai/the-batch.
**Others:** fortune.com & aiweekly.co (Kimi K3); the-decoder.com & alibabagroup.com (Qwen3.8-Max); rits.shanghai.nyu.edu
(GLM-5, Qwen3.5); minimax.io/blog/minimax-m3 & epoch.ai/models/minimax-m3; docs.mistral.ai changelog (Large 4);
venturebeat.com (Grok 4.3); decrypt.co (Grok 4.7); basenor.com (Grok 4.6); geotoolbox.ai (Grok 5 status);
decrypt.co / the-decoder.com / axios.com (Muse Spark); letsdatascience.com / yourstory.com (Muse Wonder);
fortune.com / venturebeat.com / datacamp.com (DeepSeek V4); cryptobriefing.com (DeepSeek V4.1-Flash-1017);
techrepublic.com (MAI-Base-2); cohere.com/blog (Command A+); artificialanalysis.ai (Nemotron 3 Ultra);
eweek.com (Amazon Nova scale-back).
**Leaderboards:** af.net (LMArena Nov 2026 — Gemini 4 Carbon 1528); benchlm.ai (ARC-AGI-2/3); developersdigest.tech
(HLE board); datalearner.com (METR v1.1); officechai.com (Opus 4.6 METR).
**Hardware:** en.wikipedia.org/wiki/Rubin_(microarchitecture); glennklockwood.com (R200); hpcwire.com &
tomshardware.com & nextplatform.com (GTC 2026 roadmap); convergedigest.com / igorslab.de / thenextweb.com (AMD Helios
MI455X); siliconangle.com / techzine.eu (TPU 8t/8i); aboutamazon.com / semianalysis (Trainium3/4);
techblog.comsoc.org (Nvidia–Groq); implicator.ai / fintool.com (OpenAI–Cerebras); intuitionlabs.ai / akash.network /
morphllm.com/nvidia-b200 / getdeploying.com / spheron.network (rental prices).
**Infra/finance/policy:** epochai.substack.com (Stargate sites); tomshardware.com (Abilene expansion scrapped);
news.bgov.com (OpenAI 10 GW); thenextweb.com / channelinsider.com (Anthropic valuation, run-rate, S-1);
investinglive.com (ticker ANT); whitecase.com / gibsondunn.com (EU AI Omnibus).
**Forecasts:** epoch.ai/blog/can-ai-scaling-continue-through-2030; epoch.ai/research/ai-and-compute;
epoch.ai/tools/model-counts; ai-2027.com; blog.aifutures.org (Q1 2026, Q2.5 2026 updates);
situational-awareness.ai; arxiv.org/abs/2503.14499 (METR).
