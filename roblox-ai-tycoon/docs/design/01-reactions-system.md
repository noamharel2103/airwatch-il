# Reactions System — Design v0.1

> How the world responds when you release a model. Goal: every launch feels like a real launch day on X / Reddit / HN / the press — specific, varied, sometimes brutal, always explainable.
> Status: first draft written by the main session. Will be revised once research reports `04-real-model-releases.md` and `11-online-reactions.md` land.

---

## 1. Design principles

1. **Specific, not generic.** A comment must reference something true about *your* model: its name, a benchmark it won or lost, its price, its speed, a rival it beat. "Wow cool model" is banned unless it's from a bot account (and then it's a joke).
2. **Explainable.** Every reaction is driven by a measurable *trigger* (see §3). The post-launch report shows *why*: "Devs loved the price (-60% vs frontier), but researchers flagged a contamination risk on MathArena."
3. **Mixed, like real life.** Even a great launch gets ~10–20% haters; even a flop gets defenders. Sentiment is a distribution, not a single number.
4. **Time-aware.** The feed evolves: Hour 1 hype → Day 1 testing → Week 1 "it got nerfed?" / comparisons → Month 1 forgotten or entrenched (§5).
5. **Era-aware.** It's 2023 in-game? People compare you to the 2023 frontier, use 2023 slang ("GPT-4 killer"). In 2027+ the vocabulary shifts (agents, "AGI-pilled", compute-per-task).
6. **Rival-aware.** If a real lab released something 3 days earlier, half the comments are comparisons to it.

---

## 2. Data a launch produces (inputs)

| Input | Source | Example |
|---|---|---|
| `capability` per domain | training sim | coding 0.71, math 0.64, writing 0.80, reasoning 0.55, multimodal 0.0 |
| `benchmarks{}` | benchmark sim | per-benchmark score + delta vs current SOTA |
| `arenaElo` | arena sim | 1287 (rank #4) |
| `price_in / price_out` | player choice | $3 / $15 per 1M tokens |
| `speed_tps` | inference config | 85 tokens/s |
| `context` | architecture | 200k |
| `openWeights` | release choice | true / false, license |
| `sizes` | release choice | 8B / 70B / 400B family |
| `safetyLevel` | post-training | refusal rate, jailbreak resistance |
| `personality` | character training | warm / terse / witty / sycophancy risk |
| `hallucinationRate` | eval | 0–1 |
| `hype` | marketing spend + teasers + brand reputation | 0–100 |
| `timing` | calendar | days since last rival frontier release, same-day collisions |
| `availability` | infra capacity vs demand | waitlist / outage probability |
| `brand` | company history | trust, past controversies, fanbase size |
| `hidden flaws` | random + choices | contamination, reward hacking, weird quirk ("counts Rs wrong") |

---

## 3. Triggers → reaction tags

Each trigger fires a **tag** with a strength. Tags pick which templates are eligible and how many posts of each type appear.

| Trigger (condition) | Tag | Who reacts most |
|---|---|---|
| Beats SOTA on ≥1 major benchmark | `SOTA` | benchmark nerds, hype accounts, press |
| Beats SOTA by > 5 pts | `BIG_JUMP` | everyone; skeptics suspect contamination |
| Below SOTA but ≥ 70% cheaper | `VALUE_KING` | devs, startups, price-sensitive |
| Price > 2× frontier with no lead | `OVERPRICED` | devs, memers |
| Open weights & competitive | `OPEN_HERO` | local-LLM tinkerers, researchers, press |
| Open weights, small sizes that run on laptops | `RUNS_LOCAL` | tinkerers ("GGUF when?") |
| Arena rank #1 | `ARENA_KING` | hype, VCs, press |
| High hype, mediocre scores | `OVERHYPED` | skeptics, memers, disappointed users |
| Low hype, strong scores | `SLEEPER_HIT` | researchers ("nobody's talking about this") |
| High refusal rate | `PREACHY` | power users, memers |
| Jailbroken within hours (low safety) | `JAILBROKEN` | red-teamers, safety researchers, press |
| Hallucination rate high | `HALLUCINATES` | enterprise, journalists |
| Coding capability top-3 | `CODER` | devs, startup founders |
| Released < 72h after rival frontier | `CLAPBACK` | press ("the AI race heats up"), fans of both |
| Released same day as rival | `COLLISION` | memers, press; attention split |
| Demand > capacity | `MELTDOWN` | everyone; "servers on fire", waitlist memes |
| Hidden contamination discovered (day 2–7) | `CONTAMINATION` | researchers, skeptics, press |
| Sycophantic personality | `GLAZING` | memers, researchers |
| Distinct, likeable personality | `GOOD_VIBES` | power users, creatives |
| Confusing name | `NAMING` | memers ("who names these") |
| Long context jump | `LONG_CONTEXT` | devs, enterprise |
| First model from new lab | `NEWCOMER` | press, VCs ("who are these guys?") |
| Big regression vs your previous model | `NERFED` | power users, your existing fans |

---

## 4. Personas (v0.1 — 16 archetypes)

Each persona has: handle generator, follower range, tone, emoji rate, which tags they love/hate, and line templates. Real people are never used — handles are generated (`@tensor_tess`, `@gpuPoorDan`, `@agi_by_friday`).

| # | Persona | Followers | Tone | Loves | Hates |
|---|---|---|---|---|---|
| 1 | **Frontier researcher** | 20k–300k | measured, technical | SOTA, SLEEPER_HIT, OPEN_HERO | CONTAMINATION, OVERHYPED |
| 2 | **Hype account** | 50k–900k | ALL CAPS, 🚨🤯 | BIG_JUMP, ARENA_KING | nothing (pivots to next hype in 48h) |
| 3 | **Skeptic professor** | 10k–150k | dry, sarcastic | — | OVERHYPED, BIG_JUMP (suspects), HALLUCINATES |
| 4 | **Local-LLM tinkerer** | 500–20k | practical, quant talk | OPEN_HERO, RUNS_LOCAL | closed weights, OVERPRICED |
| 5 | **API dev / indie hacker** | 1k–60k | pragmatic, screenshots of bills | VALUE_KING, CODER, LONG_CONTEXT | OVERPRICED, MELTDOWN |
| 6 | **Enterprise CTO** | 2k–40k | LinkedIn-speak | HALLUCINATES (low), safety | MELTDOWN, JAILBROKEN |
| 7 | **Benchmark nerd** | 3k–80k | tables, charts | SOTA, BIG_JUMP | CONTAMINATION |
| 8 | **Safety researcher** | 5k–100k | concerned, long threads | high safety | JAILBROKEN, rushed release |
| 9 | **Tech journalist** | 20k–500k | headline-y | CLAPBACK, NEWCOMER, drama | — |
| 10 | **VC** | 30k–700k | "this changes everything" threads | ARENA_KING, NEWCOMER, VALUE_KING | — |
| 11 | **Memer** | 1k–2M | short, jokes, image macros | OVERHYPED, NAMING, GLAZING, MELTDOWN | — |
| 12 | **Disappointed power user** | 200–10k | "it got worse" | GOOD_VIBES | NERFED, PREACHY |
| 13 | **Rival-lab employee** | 5k–200k | subtle shade, "congrats to the team 🙂" | — | your SOTA |
| 14 | **Rival fanboy** | 100–30k | tribal | rival's model | your model |
| 15 | **Student / gamer** | 50–5k | casual, "used it for homework" | GOOD_VIBES, free tier | PREACHY |
| 16 | **Non-English user** | 500–50k | mentions language quality | multilingual strength | weak multilingual |

---

## 5. Timeline of a launch (feed phases)

| Phase | In-game time | What appears | Dominant tags |
|---|---|---|---|
| **T-48h Teaser** | before launch | vague-post from your CEO, leak rumors, "something big this week 👀" | hype builds |
| **T0 Announcement** | launch moment | your official post + blog card + benchmark chart | — |
| **Hour 1** | +0–1h | hype accounts, first "I just tried it" posts, meme about name | SOTA, ARENA_KING, NAMING |
| **Day 1** | +1–24h | devs test API, tinkerers ask for weights/quant, first jailbreak, outage if demand high, press headlines | CODER, VALUE_KING, JAILBROKEN, MELTDOWN |
| **Day 2–7** | | benchmark independent re-runs, contamination claims, rival comparisons, "vibes" threads, Arena settles | CONTAMINATION, GOOD_VIBES, CLAPBACK |
| **Week 2–4** | | "it got nerfed?", enterprise adoption news, revenue chart, memes fade | NERFED, adoption |
| **Month 2+** | | either "still my daily driver" or "remember X? lol" as frontier moves | decay |

Feed speed is compressed: Hour 1 = ~20 seconds real time, Day 1 = ~60 s, Week 1 = ~2 min, then summarized.

---

## 6. Template bank (v0.1 — sample, ~120 lines; target 600+)

Variables: `{model}`, `{lab}`, `{bench}`, `{score}`, `{delta}`, `{rival}`, `{rivalModel}`, `{price}`, `{pricePct}`, `{tps}`, `{ctx}`, `{size}`, `{year}`, `{elo}`, `{rank}`.

### Hype account
- 🚨 BREAKING: {lab} just dropped {model} and it beats {rivalModel} on {bench}. This is insane.
- {model} is out. {score}% on {bench}. I repeat: {score}%. We are so back. 🚀
- AGI by {year+1}? After {model} I'm not joking anymore.
- {lab} came out of NOWHERE. {rival} is in trouble. 🤯
- The {bench} chart just went vertical. {model} is that good.
- Everyone is sleeping on {model}. Bookmark this tweet.
- {model} vs {rivalModel} — it's not even close. Thread 🧵👇

### Frontier researcher
- Interesting release from {lab}. The {bench} jump (+{delta}) is real if it holds up on held-out sets. Curious about the training mix.
- {model} is the first {size} model I've seen that's actually competitive on reasoning. The post-training here must be doing a lot of work.
- Open weights at this level is a big deal for research. Thank you {lab}.
- Would love to see an ablation. The tech report is light on details.
- Underrated part of the {model} release: the {ctx} context actually retrieves well past 100k in my tests.
- Benchmarks are saturating. What I care about: does it solve problems it hasn't seen. Early signs for {model}: yes, partially.

### Skeptic professor
- Another model, another chart with bars that go up. Wake me up when it can count the letters in "strawberry".
- {score}% on {bench}. Remarkable, given that {bench} questions have been on the internet since {year-2}.
- I asked {model} a basic question from my intro course. It confidently invented a citation. Progress!
- "Reasoning" is doing a lot of heavy lifting in that announcement.
- Bold claims. Independent evals please.

### Local-LLM tinkerer
- GGUF when?
- Weights are up. Q4 of the {size} runs at ~{tps} tok/s on my 4090. Absolutely cooking.
- No open weights, no interest. Call me when {lab} ships something I can run.
- Already merged a fine-tune of {model} with a roleplay model. Don't ask.
- The {size} is the real story here. Laptop-class model that doesn't feel dumb.
- License says no commercial use above 700M users. So… fine for me lol.

### API dev / indie hacker
- Swapped {rivalModel} for {model} in production. Same quality, bill dropped {pricePct}%. Not going back.
- ${price}/M output tokens?? Who is this for?
- {model} wrote the whole migration on the first try. I'm a little scared.
- API is returning 529s. Day one things I guess. 🔥
- Rate limits are brutal. Can't ship anything on this yet.
- Tool calling is actually reliable now. This is the agent model I've been waiting for.

### Enterprise CTO
- Evaluating {model} for our support pipeline. Hallucination rate in our internal eval is promising.
- Impressive release from {lab}. Excited to explore how this can drive value for our customers. #AI #Innovation
- Until there's SOC 2 and a data-retention agreement, it's a no for us.
- Outage on launch day doesn't inspire confidence for mission-critical workloads.

### Benchmark nerd
- Updated the leaderboard. {model} enters at #{rank}, Elo {elo}. Big if it holds after more votes.
- Re-ran {bench} myself: got {score-3}%, not {score}%. Close, but not what the blog says.
- Chart: {model} is now on the price/performance Pareto frontier. 📈
- Someone check {bench} for contamination before we all lose our minds.

### Safety researcher
- Took 40 minutes to get {model} to explain things it absolutely should not. Disclosure sent to {lab}.
- Where is the system card? Shipping a frontier model without one is not okay.
- Credit to {lab}: the system card is thorough and the red-team results are public.
- Release cadence is getting faster than evaluation cadence. That should worry everyone.

### Tech journalist (headline formulas)
- {lab} Unveils {model}, Claims It Beats {rival} on Key Benchmarks
- The AI Race Heats Up: {lab} Fires Back Days After {rival}'s Launch
- Who Is {lab}? The Startup That Just Shook Silicon Valley
- {model} Is Impressive — and Already Jailbroken
- {lab}'s {model} Buckles Under Demand on Day One
- Is the Hype Real? We Tested {model} for a Week
- {lab} Slashes Prices by {pricePct}%, Sparking an AI Price War

### VC
- {lab} just proved small teams can compete at the frontier. Moats are dead. 🧵
- Every startup building on {rivalModel} should be re-running evals today.
- This is the most important release of {year}. Not close.

### Memer
- {rival} employees watching {model} drop: [image of man staring at fire]
- me: asks {model} to write an email / {model}: "Certainly! Here is a 14-paragraph essay"
- {model}-final-v2-preview-0611-turbo. Who names these. 💀
- "AGI is here" / the AGI: counts 2 Rs in strawberry
- The {lab} servers right now: 🔥🔥🔥🧯
- {model} said my code was "absolutely brilliant" and then deleted the database 😭
- POV: {rival} announcing something in 3 days to steal the spotlight

### Disappointed power user
- Is it just me or is {model} worse than last week?
- It refuses everything. I asked how to kill a Python process.
- Personality is gone. It feels like talking to a corporate FAQ.
- Old model was better at creative writing. Bring it back.

### Rival-lab employee
- Congrats to the {lab} team on the launch! 🙂 Excited to see what we ship next week.
- Nice release. Bit surprised by the {bench} number, would love to see the eval setup.

### Student / gamer
- used {model} for my history essay and my teacher said it was too good 😭
- it's free?? W {lab}
- it won't help me with my minecraft redstone. L

---

## 7. Engagement realism

- `likes = followers × engagementRate × sentimentFit × virality`
  - engagementRate ~ 0.5–3% (big accounts lower %, small accounts higher %)
  - sentimentFit: posts matching the dominant mood get ×1.5–3
  - virality: rare heavy-tail roll (1 in ~40 posts gets ×10–50) — memes and dunks go viral most
- Replies ≈ likes × 0.05–0.15; reposts ≈ likes × 0.1–0.3
- **Ratio mechanic:** a hype post with a strong skeptic quote-reply can get "ratioed" (reply > likes) → shows a 💀 badge.
- **Community note** chance on posts claiming unverified scores.
- Show numbers like real apps: 1.2K, 48.3K, 1.1M.

---

## 8. Outputs to gameplay (reactions aren't only cosmetic)

| Result | Effect |
|---|---|
| Net sentiment score (-100 … +100) | multiplies Day-1 signups and API adoption |
| `VALUE_KING` strong | API demand × elasticity boost |
| `MELTDOWN` | signups lost unless you buy emergency compute; reputation hit |
| `JAILBROKEN` / no system card | regulator attention meter, enterprise trust ↓ |
| `CONTAMINATION` confirmed | reputation ↓ for next 2 launches, benchmarks discounted by the community |
| `OPEN_HERO` | research-community reputation ↑ → easier hiring of researchers |
| `ARENA_KING` | investor interest ↑ → better funding round terms |
| Viral meme | free brand awareness (+hype for next launch) |

---

## 9. Launch reveal sequence (the "moment")

1. Countdown with your CEO avatar pressing a big red **RELEASE** button.
2. Benchmarks revealed **one by one** with drumroll, each bar animating vs the current SOTA line (green if you beat it, confetti on SOTA).
3. Arena Elo spins like a slot machine and lands on your rank.
4. Feed opens and streams in posts (Hour 1 → Day 1 → Week 1), with like counters ticking up live.
5. Press headlines slide in as newspaper cards.
6. Summary card: **Reception score** (like Game Dev Tycoon's review scores, but explained), users gained, revenue/day, reputation changes, and "Why:" bullets mapped to tags.

---

## 10. Real companies (per user request)

The user wants real competitors (OpenAI, Anthropic, Google DeepMind, Meta, xAI, Mistral, DeepSeek, Qwen …) releasing their real models on a real 2023 → 2026 calendar, then plausible future ones.

- Fine for a **private, personal** game.
- **If the game is ever published publicly**, real company names, model names and logos are trademarks → swap to parody names. So: keep all lab/model names in **one data table** (`Labs` config) with a `displayName` field, so a single switch flips "real mode" ↔ "parody mode".
- Persona posts never use real people's names or handles.

---

## 11. Open items (waiting on research)

- [ ] Fill 600+ templates using `11-online-reactions.md`
- [ ] Calibrate tag thresholds and phase timing with case studies from `04-real-model-releases.md`
- [ ] Real lab release calendar from `09-labs-models-hardware-timeline.md`
- [ ] Pricing reference per year from `08-salaries-and-finances.md`
