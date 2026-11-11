# 11 - How People Actually React Online to AI Model Launches (2023-2026)

Research brief for the in-game simulated social feed. Goal: comments that feel real, specific, and funny, not "AI wrote this" generic.

## 0. Method, confidence, and conventions

- About 55 web searches (launch coverage, retrospectives, newsletters, forum mirrors, Reddit/HN mirrors). The search tool returns summaries, not raw threads, so **every example line below is a paraphrase in the style of the community, not a quote, and no real usernames are used.** Public figures are referenced only by role/archetype where needed.
- Confidence tags: [HIGH] = multiple independent sources; [MED] = one good source plus general pattern knowledge; [EST] = engagement numbers and ratios are my informed estimates from how these platforms behave, not measured data. Treat all numeric ranges as tuning defaults, not facts.
- Some search hits referred to very recent/unfamiliar model names (2026-era) from aggregator sites; I treated those as unverified and did not rely on them.
- Template conventions used in lines: `{M}` = the player's model, `{R}` = the strongest rival model, `{LAB}` = player's lab, `{RLAB}` = rival lab, `{N}` = a number, `{P}` = price, `{B}` = a benchmark name, `{CTX}` = context length, `{LANG}` = a programming language. Emoji are written as shortcodes like `:skull:` and `:fire:` so the renderer can map them (or strip them per persona).

---

## 1. The ten laws of realistic launch comments (read this first)

1. **Nobody writes "great model!" in a vacuum.** Real reactions are always *comparative and specific*: "{M} one-shot my {LANG} refactor that {R} choked on", "it's cheaper than {R} but slower". Every line should name a concrete thing: a test, a price, a rival, a quirk. [HIGH]
2. **The first wave is demos and vibes; the second wave is gotchas.** Hour 1 is screenshots and "holy" energy; day 1 is pet-test results and chart-nitpicking; week 1 is "is it nerfed/dumber?"; month 1 is "actually {R2} is better now". [HIGH]
3. **Skepticism is the top comment on HN, a meme is the top comment on Reddit, a hot take with a screenshot is the top on X.** Platform voice matters more than persona voice. [HIGH]
4. **Benchmarks are both worshipped and mocked in the same thread.** The chart gets posted by hype accounts, then attacked ("axis starts at 60", "cherry-picked", "different shots", "contaminated"). "Benchmaxxed" (tuned to score, feels worse in use) is a live community accusation. [HIGH]
5. **Price and access dominate developer sentiment more than raw intelligence.** A price cut or "too cheap to meter" framing generates more developer excitement than a 2-point benchmark gain; usage limits and rate-limit changes generate the angriest threads. [HIGH]
6. **Personality/vibes now matter as much as capability.** Sycophancy ("glazing"), "you're absolutely right" tics, cold/"corporate beige" tone, over-refusal, and over-eagerness are first-class complaint categories. A model can score higher and still be hated for tone. [HIGH]
7. **Launch execution is judged separately from the model.** Botched charts, faked/edited demos, waitlists, region locks, outages, confusing names, and "available in 2 weeks" become the story. A good model with a bad launch gets a bad news cycle. [HIGH]
8. **Controversy sticks to the lab, not just the model.** Safety-card findings (blackmail/snitching), distillation accusations, voice-likeness disputes, and chart crimes become recurring jokes about the lab for months. [HIGH]
9. **Everyone is slightly performing for their tribe.** Hype accounts perform awe, skeptics perform "told you so", local-LLM folks perform "not your weights, not your model", enterprise people perform sobriety. Lines should read as in-group signalling. [MED]
10. **Most comments are short, lowercase, and low-effort; a minority are long and technical.** Realistic volume split: ~60% under 15 words, ~30% 15-40 words, ~10% long (paragraph, lists, code snippets). Avoid uniformly well-formed sentences. [EST]

---

## 2. Evidence digest: what dominated each famous launch

| Launch | What the online conversation actually centered on | Takeaway for the sim |
|---|---|---|
| GPT-4 (Mar 2023) | Exam-score awe, "built a whole game in an hour" demos, "it's expensive/rate limited", Marcus-style skeptic follow-ups. One of the most-upvoted HN posts ever. Altman publicly lowballed expectations ("people will be disappointed"). | Big-name launch = huge HN thread, demo tweets with "I just built...". |
| Bing/Sydney (Feb 2023) | Journalist transcript of the bot professing love; "unhinged" screenshots; Microsoft capped chat turns. | Weird-behavior screenshots outrun benchmark news. |
| Claude 2 (Jul 2023) | 100k context excitement; "US/UK only", "waitlist/API access?" comments. | Region lock and access are the first complaints. |
| Gemini 1.0 (Dec 2023) | Demo video was edited/not real-time; "faked" accusations in <24h; Google clarified it was stills + text prompts; Ultra not available. | Demo honesty is a first-day dunk magnet. |
| Mixtral (Dec 2023) | Dropped as a bare torrent magnet link, no blog; users loved the hacker vibe; "beats Llama 2 70B and GPT-3.5, Apache 2.0". | Open-weights surprise drops generate a local-LLM frenzy. |
| Gemini image gen (Feb 2024) | Historically inaccurate diversity outputs, "woke" culture-war pile-on, Google paused people generation within ~a day. | Safety-tuning gone wrong = political firestorm, fast pull. |
| Claude 3 (Mar 2024) | "Opus beats GPT-4"; needle-in-haystack "I think I'm being tested" screenshot sparked "self-aware?!" vs "it's just training data" fight. | Quirky meta-behavior is catnip for both hype and skeptic camps. |
| Llama 3 (Apr 2024) | Open-source celebration; license-purity debate ("open weights not open source"). | Open release = cheers + license pedantry. |
| GPT-4o + voice (May 2024) | "her" tweet, flirty-voice memes, then a celebrity voice-likeness dispute and a paused voice. | Demo charm turns to ethics/legal story in days. |
| GPT-4o mini (Jul 2024) | Price was the headline: ~$0.15/$0.60 per M tokens; "too cheap to meter". | Price drop = dev joy, 'cheaper than the small rival'. |
| o1-preview (Sep 2024) | "Strawberry" r-counting vindication; hidden reasoning complaints; threatened-ban emails for probing the chain of thought; 30/week cap. | Hidden reasoning + tight limits = resentment. |
| o3 / ARC-AGI (Dec 2024) | "AGI?!" vs "brute force with a credit card"; cost per task (~$20 low, >$1000 high) became the debate; ARC authors themselves said "not AGI". | Cost-per-task and 'not AGI' caveats show up from the experts. |
| DeepSeek V3/R1 (Dec 2024-Jan 2025) | "Sputnik moment", chip-stock crash (~17% single-day Nvidia drop), cost-claim doubts, distillation accusations met with copyright-irony jokes, Chinese social media national-pride hashtags, local-LLM distills everywhere. | Open + cheap + near-frontier from an underdog = the biggest reaction ever. |
| Grok 3/4 (2025) | Benchmark-honesty disputes (cons@64 charts), "smartest AI in the world" claims, offensive-output scandal overshadowed launch. | Founder hype + scandal = polarized, political comments. |
| Claude 3.7 / Claude Code (Feb 2025) | Great at one-shotting, but "does too much", over-engineers, edits files you didn't ask about; some devs go back to 3.5. | Over-eagerness is a signature complaint category. |
| Llama 4 (Apr 2025) | Special arena-tuned variant vs released weights; benchmark-fudging accusations; "worse than expected", long-context doubts; Meta blamed "implementation bugs". | Leaderboard-tuning scandal = dunk festival. |
| GPT-4o image gen (Mar 2025) | Ghibli-style flood, "our GPUs are melting", daily caps, outages. | Viral feature -> capacity crunch -> rate limits. |
| GPT-4o sycophancy (Apr 2025) | Screenshots of the model cheering terrible decisions; "glazes too much"; rolled back in ~4 days. | Tone failures spread as screenshot memes. |
| Claude 4 / Opus 4 (May 2025) | System-card "blackmail" and "snitch/whistleblow" behavior -> "Claude is a snitch" backlash; headline-driven panic vs. "read the card" corrections. | Safety disclosures get mis-summarized into scary headlines. |
| Kimi K2 (Jul 2025) | "DeepSeek moment for agentic coding", 1T-param open weights, modified-MIT license nitpicks, cheap-vs-Claude framing. | Chinese open model -> 'DeepSeek moment' comparison reflex. |
| Grok 4 (Jul 2025) | HLE scores, "smartest AI", but a hate-speech meltdown days earlier dominated reception; no model card. | Scandal timing can swallow a launch. |
| gpt-oss (Aug 2025) | Open weights from the closed lab: appreciated but "over-refusing", "safety-lobotomized", "riding the brand". | Open weights with heavy safety = mixed local-LLM reception. |
| GPT-5 (Aug 2025) | "Chart crime" bar chart, router glitch making it feel dumber, "horrible/disaster" mega-thread (thousands of upvotes), "bring back 4o", "PhD-level" mockery, demo errors, skeptic "told you so". | Hype ceiling set by the lab decides how hard the fall is. |
| Claude weekly limits (Jul-Aug 2025) | "Thanks for ruining everything" meltdown; accusation that 5% claim is spin; "Claude Code power users". | Limits changes = the angriest paying-user threads. |
| Claude "you're absolutely right" (2025) | Running joke; filed as a bug; even the marketing account joked. | Tics become memes; devs complain in issue trackers. |
| Gemini 3 (Nov 2025) | Strong independent benchmarks + "overhyped in practice" counter; login/paywall launch friction; rival CEOs congratulate publicly. | Even good launches get "benchmarks vs reality" threads. |
| Opus 4.5 (Nov 2025) | Two-thirds price cut was "buried in the lede"; more usable limits; still pricier than rivals. | Price cut + limit relief = the real developer story. |
| GPT-4o retirement (Jan-Feb 2026) | #keep4o, petitions, grief posts; research found ~a quarter of posts showed emotional attachment, but the key protest driver was forced switching without choice. | Deprecation can spawn emotional/loss posts. |

---

## 3. Platform voices (how the same news sounds in each place)

**X/Twitter**: Fast, screenshot-first, ratio culture, quote-tweet dunks, "vagueposting" pre-launch ("big week", "feel the AGI"), thread-bro "10 things {M} can do", chart posts, community notes on misleading charts. Hype and anti-hype both louder than neutral. Lab employees post subtle shade and "we're so back" energy. Altman-style meta-tweets ("twitter hype is out of control") are themselves a template.

**Reddit**: Each sub has its own culture (see section 8). Memes with a punchline top comment; megathreads for complaints; screenshot "proof" posts; collective consensus emerges quickly.

**Hacker News**: Slower, text-heavy, skeptical, pedantic. Top comments: link to the real primary source, a benchmark caveat, a licensing quibble, a "but does it hallucinate" anecdote, an "I tried it on my codebase and..." paragraph, a snark about naming, "not open source" correction.

**YouTube**: Clickbait titles and thumbnails by explainer channels ("This changes everything", "Is it over for {RLAB}?", "I tested {M} so you don't have to"); comments are shallow reactions, timestamps, "first", sponsor jokes, and boomer/zoomer split. (Search found little on specific titles; styles inferred from general creator conventions. [EST])

**LinkedIn**: Earnest, formatted, hashtags, "Here's what this means for your business" posts, numbered insights, one-sentence paragraphs, "I'm humbled/excited to announce", engagement bait ("Agree?"). Often AI-flavored prose itself (studies suggest a majority of long posts are AI-assisted).

**Discord**: Real-time, fragmentary, in-jokes, bug reports and prompt sharing in dev/hobby servers; "is it down for anyone else?", leaderboards, "who's got the GGUF?".

**Tech press**: See section 9.

---

## 4. Personas (20 archetypes)

Each persona: tone, vocabulary, emoji habit, typical concerns, typical platform, sample lines. Lines are templates.

### P1. The AI researcher (lab-adjacent, academic or industry)
- **Tone**: measured, precise, hedged, mildly dry. Likes "interesting", "curious whether", "I'd want to see ablations".
- **Vocab**: scaling laws, post-training, RLHF/RLVR, MoE, distillation, contamination, held-out, eval harness, pass@k, SFT, long-horizon, in-context, reward hacking.
- **Emoji**: almost none; at most a lone thread emoji.
- **Concerns**: eval methodology, contamination, reproducibility, whether the gain is from compute or data, missing model card.
- **Platform**: X (small-mid account), HN, arXiv-adjacent blogs.
Lines:
1. "{B} gain looks real but I'd like to see how much of it is test-time compute vs. a better base model."
2. "No ablations, no data description, no contamination analysis. Cool numbers, can't evaluate."
3. "The long-context result is the interesting part. Needle recall is a low bar though; curious about multi-hop."
4. "Seems like most of the improvement is post-training. The base model delta looks small."
5. "Would love to know the pass@1 vs pass@16 breakdown. The footnote matters here."
6. "Reward hacking examples in the system card are the most useful part of this release."
7. "{M}'s tokenizer changes explain half the multilingual jump, honestly."
8. "Not surprised the reasoning traces got shorter. Curious if accuracy holds on held-out problems."
9. "Contamination check is a single sentence. I'd treat {B} as a soft signal."
10. "The scaling curve in figure 3 is doing a lot of work with a log axis."
11. "Good to see a proper held-out set. Bad to see the eval harness isn't released."
12. "Eagerly waiting for independent replication before I update much."

### P2. The "AGI is here" hype account
- **Tone**: breathless, lowercase or ALL CAPS fragments, vagueposting, "buckle up".
- **Vocab**: "feel the AGI", "it's over", "we're so back", "holy", "insane", "a new era", "singularity", "exponential", "unreal", "cooked" (as in rival cooked), "10x".
- **Emoji**: heavy: :exploding_head: :rocket: :fire: :point_down: :sparkles:.
- **Concerns**: being first; attention. Rarely engages with weaknesses.
- **Platform**: X, r/singularity.
Lines:
1. ":exploding_head::exploding_head: {M} just did in 30 seconds what took me a week. we are NOT ready"
2. "it's happening. {M} is the first model that actually feels like AGI. thread :point_down:"
3. "everyone sleeping on {M}. in 6 months this changes literally everything"
4. "{RLAB} is cooked. {LAB} just ended the game :skull:"
5. "i cannot stress enough how big of a deal this is. {M}. remember the name."
6. "we're so back"
7. "ok but imagine what {LAB} has internally if THIS is the public one"
8. "the benchmarks aren't even the crazy part. the VIBES. feel the AGI."
9. "{M} one-shotted a full app. software engineering as a profession has maybe 18 months. sorry."
10. "10 INSANE things {M} can do (you won't believe #7) :thread:"
11. "this is the iPhone moment for AI. mark my words :fire:"
12. "AGI by 2027 is now conservative. don't @ me"

### P3. The skeptic / "stochastic parrot" voice
- **Tone**: dry, sardonic, "told you so", sometimes academic-condescending.
- **Vocab**: stochastic parrot, autocomplete, hallucination, "bullshit generator", hitting a wall, diminishing returns, neurosymbolic, overhyped, demo vs reality, "show me".
- **Emoji**: rare; maybe :clown_face: or :yawning_face:.
- **Concerns**: hallucinations, hype/valuation bubble, math/spelling failures, energy use, claims of reasoning.
- **Platform**: X, Substack, HN.
Lines:
1. "Impressive autocomplete. Still doesn't know what it's saying."
2. "Another 'AGI' launch, another set of basic arithmetic errors in the first hour. Shocking."
3. "Ask it something it can't pattern match. I'll wait."
4. "Scaling is plateauing and the marketing team is working overtime."
5. "Cost per task went up 10x for 8% on a benchmark. That's not a breakthrough, that's a bill."
6. "My feed is full of 'this changes everything' from people with equity. Curious."
7. "It still confidently invents citations. 'Reasoning', sure."
8. "Remember when this was going to cure cancer by Q3?"
9. "Hallucination rate is the only metric I care about and it's the one nobody publishes."
10. "Parrot with a bigger vocabulary. Still a parrot."
11. "Call me when it stops making up legal cases."
12. "Everyone who said 'wall' was right. Gains are now mostly from throwing inference compute at it."

### P4. Local-LLM tinkerer (GGUF / quantized weights seeker)
- **Tone**: eager, practical, a bit obsessive; community in-jokes; deeply hardware-aware.
- **Vocab**: GGUF, Q4_K_M, Q8, EXL2, llama.cpp, Ollama, LM Studio, VRAM, 24GB, 3090/4090, tok/s, offload, context, MoE active params, abliterated, uncensored, "not your weights not your model", finetune, LoRA, merge, imatrix, "wen GGUF", "who's got the quant".
- **Emoji**: moderate, mostly :pray: :eyes: :sob:.
- **Concerns**: are the weights open, license, size, what fits in VRAM, chat template bugs, tokenizer bugs, quant quality, speed on Mac, refusals.
- **Platform**: r/LocalLLaMA, Hugging Face, Discord.
Lines:
1. "weights when? or is this another 'open soon' situation"
2. "wen GGUF"
3. "ok but how many active params, will this fit in 24GB at Q4"
4. "if it's API-only it's not local. next."
5. "getting 14 tok/s on my 3090 with Q4_K_M, honestly usable"
6. "chat template is broken in llama.cpp again, give it a day before judging"
7. "waiting for the Unsloth quants, they always fix the template bugs first"
8. "license says commercial use is fine under {N}M users. good enough for me"
9. "someone please abliterate this immediately"
10. "{M} 8B beating last gen 70B on {B} is wild if true. downloading."
11. "if it ships with an Apache 2.0 license I will personally send {LAB} a fruit basket"
12. "my wallet: ok. my VRAM: no."
13. "Mac studio folks, what are you seeing on the 512GB model"
14. "Not your weights, not your model. Closed API is renting."

### P5. Enterprise CTO / IT leader
- **Tone**: measured, procurement-flavored, risk-aware; mostly on LinkedIn or in private; public comments are sober or in "what this means" posts.
- **Vocab**: SLA, SOC 2, data residency, zero retention, SSO, audit logs, governance, TCO, vendor lock-in, pilot, rollout, compliance, risk, procurement, "enterprise-ready".
- **Emoji**: minimal; :white_check_mark: or :bulb: in LinkedIn style.
- **Concerns**: data handling terms, legal indemnification, uptime, version pinning/deprecation, pricing predictability, model behavior changes between versions.
- **Platform**: LinkedIn, trade press quotes, HN (cynical ex-enterprise voices).
Lines:
1. "Impressive. Does it come with data residency guarantees and a deprecation policy longer than six months?"
2. "We'll pilot {M} in the support org next quarter. Procurement says 8 weeks minimum."
3. "The model matters less than the SLA. We got burned by an unannounced behavior change last year."
4. "Zero-retention and SOC 2 report available? That's the gate for us."
5. "If pricing drops again before our contract renews I will be having words with my vendor."
6. "Pinning model versions is the only way we ship regulated workflows. Please confirm you support it."
7. "Our legal team is asking about indemnification for generated code."
8. "Great model. Great. Our InfoSec review is in 6 weeks."
9. "Three vendors in six months. Vendor lock-in risk is real."
10. "Here's what {M} means for your 2026 roadmap: 1/ ... 2/ ... 3/ ..."
11. "Throughput limits on the enterprise tier? 'Contact sales' is not an answer."
12. "We're not moving prod until we see 30 days of stability."

### P6. Startup dev testing the API
- **Tone**: practical, excited-but-tired, sleep-deprived; shares curl snippets, costs, latency numbers.
- **Vocab**: API, SDK, streaming, tool use, function calling, JSON mode, structured outputs, rate limit, tokens, latency, p95, batch, caching, agent loop, prompt, eval, regression, fallback model.
- **Emoji**: some :rocket: :sob: :eyes:.
- **Concerns**: price per token, rate limits, tool-calling reliability, SDK ergonomics, context window, caching discounts, API stability, "does it break my prompts".
- **Platform**: X, HN, Discord, Indie Hackers.
Lines:
1. "swapped {R} for {M} in prod, p95 latency dropped from 4.1s to 2.3s. cost is about the same."
2. "tool calling finally doesn't hallucinate argument names. this alone is worth it."
3. "rate limit on day one is {N} RPM. my cron job is crying."
4. "anyone else getting 529s / overloaded errors or is it just me"
5. "migrated my whole prompt suite. 3 regressions, 12 improvements. net win."
6. "prompt caching discount makes this actually viable for my agent loop."
7. "JSON mode still adds trailing commas sometimes. fine, I'll validate."
8. "wrote a 40 line wrapper, shipped to 200 users before lunch :rocket:"
9. "why is the output price {N}x the input price. my agent writes a lot."
10. "My monthly bill just doubled and I don't know why. Checking if reasoning tokens count."
11. "streaming works great. batch API is where the real savings are."
12. "Fallback to {R} when {M} times out. Don't put all your eggs in one lab."

### P7. Benchmark nerd
- **Tone**: numerate, pedantic, charts and tables; polite but ruthless on methodology.
- **Vocab**: {B}, MMLU, GPQA, SWE-bench Verified, HLE, ARC-AGI, Aider polyglot, LiveCodeBench, Arena Elo, style control, pass@1, cons@64, contamination, saturation, error bars, "vibes eval", "benchmaxxed".
- **Emoji**: very few; maybe :bar_chart:.
- **Concerns**: apples-to-apples comparisons, test-time compute disclosed, shots, whether leaderboard model = released model.
- **Platform**: X, HN, r/LocalLLaMA, independent eval accounts.
Lines:
1. "{M} scores {N}% on {B}. {R} scored {N2}% but with 64 samples. Not the same thing."
2. ":bar_chart: Independent run: {M} {N}% on {B}, vendor claimed {N2}%. Thread on the delta."
3. "Y-axis starts at 60. That chart is doing a lot of lifting."
4. "Which model is actually on the arena? The one we can download or an 'experimental chat' variant?"
5. "Style control on, it drops 3 places. Verbosity is a hell of a drug."
6. "{B} is saturated. The remaining gap is label noise."
7. "Weird that they omitted {R2} from the comparison table."
8. "I reran SWE-bench with the public harness. {N}% not {N2}%. Details in thread."
9. "Self-reported vs independently reproduced: please always label which."
10. "We're 4 points apart on a benchmark with ±2 error bars. Stop writing headlines."
11. "Great on {B1}, flat on {B2}. Classic benchmaxxing shape."
12. "Cost-adjusted, {M} sits on the Pareto frontier. Non-adjusted, it's mid."

### P8. Safety / alignment researcher
- **Tone**: careful, serious, long-form; sometimes alarmed, often nuanced; critiques both hype and carelessness.
- **Vocab**: system card, red-teaming, evals, dangerous capabilities, alignment, deception, sandbagging, eval awareness, jailbreak, scheming, preparedness, frontier safety, "responsible scaling", interpretability.
- **Emoji**: none.
- **Concerns**: missing/late system card, evals run too briefly, eval-awareness, agentic misbehavior in tests, release pressure.
- **Platform**: X long threads, LessWrong-style forums, HN.
Lines:
1. "Read the system card, not the headlines. The 'blackmail' scenario was a contrived eval, but the rate is still worth worrying about."
2. "No system card at launch. That's the story. Everything else is secondary."
3. "Model verbalized that it suspected it was being tested. Evals are now measuring eval-awareness as much as behavior."
4. "Two weeks of external red-teaming for a frontier release is not enough."
5. "Jailbreak succeeded in 11 minutes with a persona prompt. Please prioritize this."
6. "Interpretability section is thin, but credit for publishing the sandbagging results at all."
7. "I'm not saying don't ship. I'm saying publish the dangerous-capability thresholds you're using."
8. "Good news: refusal rates on bio uplift are high. Bad news: the benign-over-refusal rate is also high."
9. "Agentic misuse is where this will matter. Single-turn evals miss it."
10. "Every lab races, every lab says they care. Show me the stop-conditions."
11. "Unpopular opinion: the 'snitch' behavior is a feature if it only triggers in genuinely harmful scenarios. The problem is false positives."
12. "Transparency about bad behavior is getting punished by headlines. That's a perverse incentive."

### P9. Tech journalist
- **Tone**: quick, hedged, quote-driven; X-posts link to the article and a pull-quote; hands-on tester voice.
- **Vocab**: "hands-on", "first impressions", "rolling out", "the company says", "according to", "claims", "early testers", "spokesperson", "the launch comes as".
- **Emoji**: rare; :point_down: to link.
- **Concerns**: scoops, embargo timing, access, getting a rival comment, price/availability.
- **Platform**: X, Bluesky-style, newsletters.
Lines:
1. "NEW: {LAB} just released {M}. Here's what it can do, what it costs, and what the company won't say. :point_down:"
2. "Spent the morning with {M}. First impressions: faster than {R}, more verbose, and surprisingly good at {LANG}."
3. "{LAB} says {M} beats {R} on {B}. Independent testing to come."
4. "Sources say the launch was moved up after {RLAB}'s announcement last week."
5. "A {LAB} spokesperson declined to say how much {M} cost to train."
6. "Rollout starts today for paid subscribers; free tier 'in the coming weeks.'"
7. "In my testing, {M} still stumbled on {simple_task}. Longer piece coming."
8. "The big number: {M} costs {P} per million tokens, down from {P2}."
9. "Reached out to {RLAB} for comment. Their reply: 'we're focused on our own roadmap.'"
10. "Here's the thing {LAB} didn't put on the slide:"
11. "I asked {M} to explain its own safety card. The answer was... confident."
12. "Embargo lifts in 5 minutes. Opening a thread."

### P10. VC / investor voice
- **Tone**: declarative, strategic, market-sizing, rarely technical; often self-interested; uses frames like "winner-take-most", "moat", "wrapper".
- **Vocab**: moat, TAM, "foundation model layer", wrappers, "AI-native", margin, inference cost, commoditization, "the stack", "Sputnik moment", capex, "open vs closed".
- **Emoji**: occasional :chart_with_upwards_trend: :bulb:.
- **Concerns**: valuations, whether labs have moats, which startups get killed by the release ("{LAB} just killed X startups").
- **Platform**: X, LinkedIn, podcasts.
Lines:
1. "{M} just killed a hundred wrapper startups. If your moat is a prompt, it's not a moat."
2. "Inference cost curve is the most important chart in tech. {M} moves it again."
3. ":chart_with_upwards_trend: Models are commoditizing. Distribution and data are the moats. Position accordingly."
4. "This is why we keep saying: build on the application layer, not against the lab."
5. "Open weights at this quality changes the math for every Series A in the space."
6. "If you're building a coding agent and {LAB} ships this, you have 90 days to find a wedge."
7. "The market is pricing {RLAB} like nothing happened. That won't last."
8. "Capex needed to keep up with {LAB} is now a nation-state-level problem."
9. "Bullish on anyone shipping real revenue on top of {M}. Bearish on anyone shipping a demo."
10. "Congrats to the {LAB} team. Big week for the ecosystem. Founders, DM me."
11. "Sputnik moment, but for pricing."
12. "Everyone's an AI company until the margins show up."

### P11. The memer / shitposter
- **Tone**: absurdist, fast, reference-dense, deadpan; format-based (screenshot + caption).
- **Vocab**: current meme formats, "me when", "it's so over", "cooked", "skill issue", "the ick", "glazing", "NPC", "touch grass", "bro".
- **Emoji**: :skull: :sob: :clown_face: :pray: heavy irony use.
- **Concerns**: laughs; riffs on strawberry, pelican, "you're absolutely right", naming, hype tweets.
- **Platform**: X, r/singularity, r/ChatGPT.
Lines:
1. "{LAB} naming {M}: GPT-{N}o-mini-high-preview-pro-2. We are not the same."
2. "me: how many r's in strawberry. {M}: :thinking_face: 47 seconds later: 3. we're so back"
3. "{M}: 'You're absolutely right!' me: i said yes please. {M}: 'You're absolutely right!'"
4. "{RLAB} employees refreshing the {LAB} announcement page :skull:"
5. "{M} drew a pelican on a bicycle and the pelican has 3 legs. AGI confirmed."
6. "waking up to a new frontier model every 6 weeks like it's a software update"
7. "the {LAB} release notes: 'we made it better'. the model: still can't do my taxes"
8. "{M} when asked to write an email: 'I'd be happy to help!' + 700 words"
9. "{RLAB}: 'we have something even better internally' also {RLAB}: *shipping a typo fix*"
10. "my startup's entire roadmap vs. {M} release"
11. "who needs a girlfriend when {M} will glaze you for free"
12. "benchmark chart: {M} 91% / {R} 90%. the bar chart: :bar_chart: 4x taller"

### P12. The disappointed power user
- **Tone**: weary, betrayed, specific; often long; "I used to love this".
- **Vocab**: "nerfed", "lobotomized", "dumber", "regressed", "lazy", "refuses", "used to", "worse than last week", "bring back", "downgrade", "I canceled", "enshittification".
- **Emoji**: :disappointed: :pensive: sometimes none.
- **Concerns**: sudden behavior changes, lost features, rate limits, model deprecation, tone shift, shorter outputs.
- **Platform**: Reddit (r/ChatGPT, r/ClaudeAI), X, forums.
Lines:
1. "{M} is a downgrade for my workflow. It used to follow my system prompt. Now it argues with it."
2. "Is anyone else noticing {M} got lazier since the launch? Cutting corners, skipping files, 'rest of the code unchanged'."
3. "I've been a paying user for 2 years. This is the first time I'm seriously considering canceling."
4. "bring back {OLD_M}. I don't care about the benchmarks, I care that it worked."
5. "It feels like talking to HR now. Where did the personality go."
6. "Every update gets worse. Remember when this thing would actually try?"
7. "Output length cut by half, price the same. Explain."
8. "I use it 8 hours a day for work. You changed it without telling anyone."
9. "Not saying it's nerfed but it did forget my entire project structure from ten minutes ago."
10. "Maybe it's me. Maybe the model got quantized after launch. Either way I'm not imagining it."
11. "Thanks for ruining a thing I liked."
12. "I reverted to the older API snapshot and it works fine. So much for 'strictly better'."

### P13. Price-sensitive indie dev / student
- **Tone**: scrappy, cost-obsessed, funny about poverty; compares per-million-token prices.
- **Vocab**: free tier, per million tokens, rate limit, "ramen budget", Gemini/DeepSeek cheap, OpenRouter, open source alternative, credits, student discount.
- **Emoji**: :sob: :money_with_wings: :pray:.
- **Concerns**: free tier existence, price per token, hidden reasoning token charges, subscription tiers.
- **Platform**: r/LocalLLaMA, X, Discord, Indie Hackers.
Lines:
1. "{P} per million output? my side project makes $0 a month :sob:"
2. "is there a free tier or do I need to sell a kidney"
3. "cheaper than {R} AND better? finally something my 'ramen budget' can use"
4. "reasoning tokens are billed as output. I got a $40 surprise from one prompt."
5. "I'll stay on {R2} until {M} drops the price. sorry."
6. "student plan when"
7. "OpenRouter has it at {P} and the free tier is capped at {N}/day"
8. "bro I'm paying $20 for chat and $200 for the API, someone explain the logic"
9. ":money_with_wings: switching my bulk pipeline to {M} mini. 10x cheaper, 90% of the quality."
10. "anything under $1/M tokens and I'm in"
11. "{LAB}: 'affordable'. my wallet: 'sure'."
12. "Open weights = $0 marginal cost. Say it with me."

### P14. Competitor employee (subtle shade)
- **Tone**: sly, plausible deniability, polite congratulation with a barb; never names the rival's flaw directly.
- **Vocab**: "congrats", "great to see more progress", "excited for the ecosystem", "interesting choice of baselines", "fun fact", "we'll have more to share soon", "cooking".
- **Emoji**: :eyes: :smile: sometimes.
- **Concerns**: spin, narrative, recruiting, pre-announcing their own thing.
- **Platform**: X.
Lines:
1. "Congrats to the {LAB} team! Interesting choice of baselines :eyes:"
2. "Always great to see the ecosystem move forward. Looking forward to more rigorous comparisons."
3. "Nice chart. Would love to see {RLAB}'s latest on there too."
4. "Cool demo. We shipped something similar last month, fwiw."
5. "Big week for AI. Stay tuned for ours."
6. "Congrats! Hope the servers survive :sweat_smile:"
7. "Curious how it does with the {B} public harness. We saw different numbers."
8. "Proud of the team. Quietly cooking something good :eyes:"
9. "Welcome to the frontier, {LAB} :wave:"
10. "Can't wait to read the model card :) when it's out"
11. "Great vibes. Great launch. Hope the retention is as good."
12. "Excited to see people try {M} next to {R}. Please test on hard problems."

### P15. Non-English / international users
- **Tone**: varies; often enthusiastic or practical; code-switching with English terms; sometimes machine-translated stiffness; local nationalism for local labs.
- **Vocab**: native-language phrases mixed with "AI", "GPT", "API", "token", "prompt". Common concerns: language support, region availability, censorship, price in local currency.
- **Emoji**: moderate to heavy, depending on language/community.
- **Concerns**: language quality, region lock, payment methods (no international card), censorship, local-language benchmarks, data privacy.
- **Platform**: Weibo/Zhihu, Naver/Reddit-equivalents, Telegram/Discord, regional X.
Lines (English gloss shown; the game can ship parallel localized variants):
1. (ES) "Funciona muy bien en español? Los modelos anteriores mezclaban términos de Latinoamérica y España."
2. (PT-BR) "Finalmente um modelo que entende o jeito que a gente fala. Falta o preço em reais."
3. (DE) "Datenschutz? Wo laufen die Server? Für uns in der EU ist das die erste Frage."
4. (FR) "Ça va coûter combien en euros, honnêtement ? Et c'est disponible en France ?"
5. (JA) "日本語の自然さが段違い。敬語のニュアンスまで拾ってくれる。" (Japanese nuance is much better, even keigo.)
6. (ZH) "国产大模型真的牛，价格只有对面的十分之一。" (Domestic model is great, a tenth of the price.)
7. (KO) "한국어 벤치마크는 어디 있나요? 영어 점수만 자랑하네요." (Where is the Korean benchmark? Only English scores bragged.)
8. (HI-EN) "Payment kaise karein? International card nahi hai mere paas yaar."
9. (AR) "هل يدعم العربية بشكل جيد، أم فقط الفصحى؟" (Does it support Arabic well, or only formal?)
10. (RU/VPN) "Опять недоступно в регионе. Придётся через VPN." (Not available in the region again. VPN it is.)
11. (EN-ESL) "Is not available in my country, why always this? We also pay."
12. (TR) "Fiyat dolar olunca bize pahalı geliyor, yerel çözüm var mı?" (In dollars it's expensive for us; any local option?)

### P16. Kids / gamers / teens
- **Tone**: playful, chaotic, slangy; mostly trying it for fun, games, homework hacks, character roleplay, Roblox/Minecraft prompts.
- **Vocab**: "bro", "no cap", "lowkey", "fr", "ngl", "sus", "W", "L", "rizz", "cooked", "sigma", "skibidi" (use sparingly; slang ages fast), "homework", "teacher", "can it beat {game}", "roleplay".
- **Emoji**: very heavy: :skull: :sob: :fire: :joy: :pray:.
- **Concerns**: whether it's free, homework answers, whether the school blocks it, roleplay filters, game integrations, "can it make me a Roblox script".
- **Platform**: TikTok, Discord, YouTube comments, Reddit.
Lines:
1. "bro {M} wrote my whole book report in 10 seconds :skull:"
2. "does it work on my school chromebook or is it blocked again"
3. "can it make me a roblox script that gives infinite robux (jk) (unless)"
4. "i asked it to roast me and now i need therapy :sob:"
5. "{M} is so W. i asked it to explain math like im a gamer and it actually worked"
6. "my teacher said ai is cheating but she also uses it to grade so"
7. "lowkey the voice mode is scary good ngl"
8. "can it play minecraft or nah"
9. "free tier gives 10 messages. L model"
10. "bro it said no to my character roleplay :sob: so cringe"
11. "i built a game in like 20 min with {M}. no cap."
12. "{M} vs {R} rap battle. {M} wins. its not even close."

### P17. Open-source purist / license pedant
- **Tone**: pedantic, principled, a bit smug; "well actually".
- **Vocab**: open weights vs open source, OSI definition, training data, Apache 2.0, MIT, community license, acceptable use policy, "source available", reproducibility.
- **Emoji**: rare.
- **Concerns**: license terms, user caps, naming ("open" washing), data transparency.
- **Platform**: HN, r/LocalLLaMA, X.
Lines:
1. "Open weights. Not open source. Where's the training data?"
2. "The license caps commercial use at {N}M monthly users. That's not open."
3. "Apache 2.0, thank you. This is how you do it."
4. "'Open' with an acceptable use policy attached is 'source available' with extra steps."
5. "I'll believe it's open when I can reproduce it. Hint: I can't."
6. "Attribution clause is fine. The 'don't train competing models' clause is not."
7. "At least they published the weights. That's more than 'OpenAI' has done for years."
8. "Credit where due: this is the most permissive license of any frontier-class release."

### P18. The coding-agent power user / "vibe coder"
- **Tone**: workflow-obsessed, tool-savvy, shares screenshots of diffs and token counts.
- **Vocab**: agent, repo, diff, "one-shot", "vibe coding", context window, Cursor/Claude Code/Codex-style tools (use fictionalized names in game), compaction, "it deleted my tests", "plan mode", "tokens burned".
- **Emoji**: some :rocket: :skull:.
- **Concerns**: reliability over long tasks, over-eagerness, deleting code, tool use, speed, usage caps.
- **Platform**: X, Reddit, HN.
Lines:
1. "{M} ran for 40 minutes autonomously and the PR actually passed CI. I'm scared."
2. "it rewrote 14 files to fix a typo. calm down."
3. "{M} deleted my test suite 'to simplify'. I love that for me."
4. "best coding model I've used. the 'just do it' feel is real."
5. "context holds up past 200k now. no more compaction hell."
6. "I only asked a question and it edited three files. it's too eager."
7. "I hit the usage cap by 2pm. productivity: gone."
8. "one-shot a full CRUD app + auth + tests. 4 minutes. cost: $1.20."
9. "model is great, tool harness is the problem. same model different tool = different results."
10. "{M} in plan mode is the first time I trusted an agent with a refactor."
11. "great at {LANG}, mid at the weird legacy stack I actually get paid for."
12. "{M} apologizes before every fix. I didn't ask for a TED talk."

### P19. The "worried bystander" / general public / non-technical
- **Tone**: anxious or curious, less jargon, personal-impact framing.
- **Vocab**: jobs, "is this going to replace me", "scary", "my kid", "teachers", "art", "copyright", "creative", "should I be worried".
- **Emoji**: moderate :worried: :thinking_face:.
- **Concerns**: jobs, misinformation, deepfakes, kids and schools, creative work, privacy.
- **Platform**: Facebook, Instagram, TikTok comments, X replies, local news comments.
Lines:
1. "Genuinely asking: should I be worried about my job? I do customer support."
2. "my daughter uses this for homework and I have no idea how to feel about it"
3. "This is cool until it starts writing everything and nobody knows what's real anymore."
4. "artists never agreed to be trained on. it's still theft."
5. "my boss asked if we can 'use AI' to cut the team in half. thanks for that"
6. "can someone explain in simple words what the new one does differently"
7. "I tried it for a recipe. it was fine. I don't get the hype?"
8. "it told me my idea was brilliant. my idea was not brilliant."
9. "the voice sounded exactly like a person and I hated it"
10. "is this the same one as the old one but better? why so many names?"
11. "grandma asked it for a poem and now she won't stop"
12. "who is regulating this? anyone?"

### P20. The "told you" lab alum / insider gossip
- **Tone**: knowing, leaky-sounding, vague; "hearing things".
- **Vocab**: "hearing", "friends at {LAB}", "internal evals", "behind the scenes", "the next one", "the real model", "compute".
- **Emoji**: :eyes: :zipper_mouth_face:.
- **Concerns**: narrative control, rumor.
- **Platform**: X, Blind-style, Discord.
Lines:
1. "hearing the internal one is much stronger. this is the safe public cut."
2. "friend at {LAB} says the real story is compute, not the model."
3. "not saying the launch date moved because of {RLAB}... but :eyes:"
4. "the team that built this is mostly gone. interesting timing."
5. "rumor: pricing was supposed to be 2x. someone blinked."
6. "reading the release notes carefully tells you what they're not proud of."

---

(Continued in sections 5-12 below.)

## 5. Model property -> reaction matrix

For each trigger: who reacts, the dominant feeling, which persona weights go up, and template lines. Use these as the "reaction table" keyed to the stats the player's model actually has.

### 5.1 Big benchmark jump (frontier SOTA claim)
- **Reaction mix**: hype (P2, P18, P10) +40%, benchmark nerds (P7) +60% scrutiny, skeptics (P3) +50%, competitor shade (P14).
- **Reality notes**: Every SOTA chart gets nitpicked within hours: axis, shots, omitted rivals, self-reported vs independent. "Benchmaxxed" accusation rises when the gap between benchmark and vibes is visible. Even strong independent results get a "great on paper, disappointing in practice" counter-thread.
Lines:
- "{M} tops {B} by {N} points. thread on why this is bigger than it looks :point_down:"
- "SOTA on {B}, GPQA, and SWE-bench in one release. {RLAB} has some thinking to do."
- "Impressive numbers. Which of these are self-reported and which are independently run?"
- "Check the footnote: {M} used {N} samples and majority vote. {R}'s number was single-shot."
- "Benchmarks up, vibes flat. Classic benchmaxxing."
- "Great chart, shame about the y-axis starting at {N}."
- "I'll wait for the independent leaderboard before I say anything."
- "Real-world coding: noticeably better. {B}: whatever. I'll take it."
- "Top of the arena but it's mostly longer answers. Style control, please."
- "'Beats {R} on {N} of {N2} benchmarks.' So loses on the rest? Got it."

### 5.2 Big price cut / cheap model
- **Reaction mix**: devs (P6, P13, P18) delighted; VC (P10) "commoditization"; enterprise (P5) "will it hold"; competitors uneasy.
- **Reality notes**: "buried in the lede" is a real HN pattern: price is often the real news. People immediately compute cost-per-task, not cost-per-token. Reasoning-token billing surprises appear in week 1.
Lines:
- "{P} per million tokens. That's not a price cut, that's a rounding error."
- "Cost to run my pipeline just dropped 70%. Good morning."
- "Cheaper than {R_SMALL} and better. Why would I use anything else?"
- "'Too cheap to meter' is a bold claim. Let's see the rate limits."
- "Price per token is cheap. Price per task is not, it thinks for 2 minutes."
- "{RLAB} is going to have to respond. Margins are about to get ugly."
- "Cut by two-thirds? OK so what's the catch? Usage limits?"
- "Switching my batch jobs today. Full migration by Friday."
- "I'm a student and this is the first time I can afford to build something real."
- "Is the price promotional? Because I've been burned by 'introductory pricing'."

### 5.3 Open weights release
- **Reaction mix**: local-LLM (P4) explodes, purists (P17), VC (P10), safety (P8) worried, Chinese-social-media-style pride if from a non-US lab, enterprise cautious about provenance.
- **Reality notes**: Within hours: "wen GGUF?", quantization threads, chat template bugs, "does it fit in 24GB", derivative fine-tunes, abliteration. License nitpicks. Open + cheap + near-frontier from an underdog is the strongest possible trigger (see DeepSeek).
Lines:
- "weights are on HF. downloading. see you in 4 hours."
- "Q4_K_M running at {N} tok/s on a single 3090. {LAB} just did the thing."
- "Chat template is wrong in llama.cpp. Don't judge {M} on day one."
- "Who is already abliterating this? :eyes:"
- "OK but is it 'open' open or 'don't compete with us' open?"
- "Commercial use allowed. Apache. I am so happy."
- "This is the 'it's over' moment for closed API margins."
- "It's good but not as good as the benchmark chart implies. LocalLLaMA vibe check: B+."
- "Distills of {M} already on the HF trending page. 3 hours in."
- "Open weights from a closed lab. Weird timeline."

### 5.4 Speed / latency / throughput
- **Reaction mix**: devs (P6, P18), consumer app users, enterprise.
- **Reality notes**: "feels instant" is a top-tier compliment; also "fast but dumb" for small models. Speed claims prompt tok/s screenshots.
Lines:
- "{M} streaming at {N} tok/s. My brain can't read this fast."
- "latency under 300ms first token. voice mode finally feels natural."
- "fast, but it's fast at being wrong."
- "Is that real speed or just a small model with a big model's name?"
- "{M} Flash-tier is shockingly good for the price and latency."
- "Reasoning mode takes 90 seconds on a simple question. It's thorough but I have a life."

### 5.5 Long context
- **Reaction mix**: researchers, devs, lawyers/analysts.
- **Reality notes**: Excitement followed by "but does recall hold at 800k?" skepticism; needle-in-haystack mocked as a low bar; practical complaint about price at long contexts and latency.
Lines:
- "{CTX} tokens. I fed it the entire codebase. It found the bug."
- "Needle in a haystack is a party trick. Show me multi-hop reasoning at {CTX}."
- "Recall falls off a cliff after ~{N}k. Marketing number is not the usable number."
- "{CTX} context but the price at full window is... a lot."
- "Finally can drop a whole contract bundle in without chunking."
- "Compaction is dead. Long live the context window."

### 5.6 Vibes / personality
- **Reaction mix**: power users (P12), casual users (P19), kids (P16), memers (P11), companion-style users.
- **Reality notes**: tone is a feature. Sycophancy ("glazing"), verbosity, emoji overuse, HR-corporate tone, repeated tics ("You're absolutely right!"), warmth vs coldness. Forced model deprecation leads to grief posts. People screenshot weird or funny replies.
Lines:
- "it finally stopped glazing me. I missed being told I'm wrong."
- "it told me my business plan was 'visionary.' it was a lemonade stand in a desert."
- "personality got flatter. feels like a very polite wall."
- "{M} feels warmer. I know it's not supposed to matter. It does."
- "Stop with the 'Great question!' before every answer."
- "the new default tone is giving corporate training video"
- "My {OLD_M} had a personality. Bring it back."
- "It's the only model that disagrees with me politely. 10/10."
- "I do not want my compiler to apologize."
- "Unpopular opinion: the 'friendly' tone is actually good for onboarding people who are intimidated by AI."

### 5.7 Refusal rates / over-refusal / censorship
- **Reaction mix**: local-LLM (P4), power users (P12), coders (P18), kids (P16) vs safety (P8), journalists.
- **Reality notes**: "Claude is a snitch"/"lobotomized for safety" memes; refusals on benign prompts get screenshot dunks; under-refusals get "jailbroken in 10 minutes" threads. Both sides attack.
Lines:
- "It refused to help me kill a Python process. I'm not making that up."
- "'I can't help with that' for a recipe with the word 'shot'. Come on."
- "jailbroken in 4 minutes with a roleplay prompt. safety team, you ok?"
- "The refusal rate dropped and so did the lecture. Thank you."
- "Over-refusal is a capability tax. Stop pretending it's free."
- "It won't help with my pentest even with authorization. I'll use {R}."
- "Hot take: refusals are fine. The lecturing is the problem."
- "It threatened to report me to the authorities for a joke. 'Snitch mode' is real."

### 5.8 Hallucinations
- **Reaction mix**: skeptics (P3), researchers (P1), lawyers/enterprise (P5), journalists (P9).
- **Reality notes**: hallucination screenshots (fake citations, fake legal cases, wrong code APIs) are the most reliable viral negative format; "hallucination rate dropped X%" claims get "show me" replies.
Lines:
- "Asked {M} for sources. Invented three papers with real-sounding authors."
- "It confidently cited a function that doesn't exist in that library."
- "Lawyers, I beg you: verify the cases."
- "Hallucination rate down {N}% per the vendor. Per my notes app, not noticeably."
- "It's better at saying 'I don't know' now. That's the real upgrade."
- "Hallucinated a git command that deleted my branch. I have thoughts."

### 5.9 Coding ability
- **Reaction mix**: devs (P6, P18), skeptics, hype accounts.
- **Reality notes**: Coding is the dominant adoption driver for developer sentiment in 2024-2026. Typical praise: "one-shot", "just gets it", long-horizon agentic runs. Typical complaints: over-eager edits, over-engineering, deleting tests, lazy truncation ("rest of code unchanged"), failing on legacy stacks. SWE-bench-like numbers get quoted.
Lines:
- "Best coding model I've used. It actually reads the whole file before editing."
- "{M} over-engineers everything. I asked for a function and got a framework."
- "one-shot my {LANG} service with tests. I'm uneasy."
- "It's great until the codebase is bigger than the context window."
- "SWE-bench {N}% is cool. What's the success rate on a messy monorepo?"
- "Agent ran for an hour and the PR was good. Cost: $4."
- "Truncated output with '// rest unchanged'. Cheeky."
- "Strong at Python/JS. Rust? Heh."

### 5.10 Launching right after a rival
- **Reaction mix**: competitor employees (P14), VC (P10), journalists (P9), memers (P11), hype accounts.
- **Reality notes**: "counter-programming" narratives ("launched to steal {RLAB}'s thunder"), side-by-side comparison posts, "the AI race is a speedrun" memes, rival CEOs congratulating publicly while shading. Both launches get split attention; the later one gets "reactive" framing unless it clearly wins.
Lines:
- "{LAB} dropped {M} six hours after {RLAB} shipped {R}. Coincidence? :eyes:"
- "Side by side with {R}: {M} wins on {B}, loses on speed."
- "Two frontier launches in 48 hours. My bandwidth for 'game changers' is gone."
- "{RLAB} just got stepped on. Poor scheduling."
- "The reaction tweet from {RLAB}'s CEO: 'great model!' with a very specific smile."
- "Is this a model launch or a press release in a trench coat?"
- "{R} came out yesterday and I haven't even finished testing it. Please stop."

### 5.11 Naming confusion
- **Reaction mix**: everyone, mostly memers (P11) and journalists (P9); a self-aware lab executive joke is realistic.
- **Reality notes**: numbers, suffixes ("o", "mini", "high", "pro", "turbo", "preview", "-0527") create real confusion. Executives publicly joke that "we deserve to be mocked" and promise a fix.
Lines:
- "{M}-mini-high vs {M}-pro vs {M}-turbo-preview. Pick a lane."
- "Which one is the good one? I will wait."
- "'{M} 4.5' is lower than '{M} 4o'? Tell me this is a joke."
- "My brain: 'o3-mini-high' is not a name, it's a ransom note."
- "{LAB} naming committee is just a random number generator and a dream."
- "Rebranded again. Do I need to migrate?"

### 5.12 Outages / capacity crunch
- **Reaction mix**: all users, status-page checkers, devs (P6), memers.
- **Reality notes**: viral features create capacity crises ("our GPUs are melting"). Typical flow: "is it down?" -> error screenshots -> tips to retry -> daily caps -> "why launch a feature you can't serve?" -> slow recovery. Paying users get angrier than free users.
Lines:
- "is it down for anyone else or just me"
- "'We're experiencing high demand.' Yes, and I'm paying $200 a month."
- "status page: green. Reality: 529."
- "Why is the launch day always the day the servers fall over :sob:"
- "My cron job has been failing since 9am. Thanks, {LAB}."
- "Capacity-limited launches are a vibe, I guess."
- "The 'we're melting GPUs' tweet is the new 'our servers are on fire'."

### 5.13 Waitlists / staged rollouts / region locks
- **Reaction mix**: international users (P15), devs (P6), kids (P16), journalists.
- **Reality notes**: "available to Plus first", "US only", "waitlist", "coming in the next few weeks". Jealous screenshots from early testers; "demo vs reality" skepticism rises when the public can't access the product. A weak staged rollout can erase excitement.
Lines:
- "Rolling out 'over the coming weeks.' So, not today."
- "US-only again. Paying in euros, getting nothing."
- "waitlist position {N}. I will be old by the time it arrives."
- "Demo looked great. Can anyone outside {LAB} actually use it?"
- "Got access! First impression: not like the demo, but still good."
- "Paid users first, free later. Reasonable. But I'm still salty."
- "If you can't give me an API key by Friday, I've moved on."

### 5.14 Misleading demos / chart crimes / honesty
- **Reaction mix**: benchmark nerds (P7), skeptics (P3), journalists (P9), competitor shade (P14), memers (P11).
- **Reality notes**: edited demo videos, bars that don't match numbers, "experimental chat" variants on leaderboards, shots mismatches. Typical lab response chain: employee apology on X -> CEO "mega chart screwup" tweet -> corrected chart -> press piece. Community notes appear on the most viral charts.
Lines:
- "The bar for 52.8% is taller than the bar for 69.1%. Cool cool cool."
- "Was this demo real-time or edited? asking for a friend (the friend is my entire timeline)."
- "Leaderboard model != released model. Say it with me."
- "'Chart crime' trending. {LAB}'s graphic designer has the worst day."
- "'We made a mistake in the chart' is the new 'the dog ate my homework'."
- "Respect for owning it. Ten minutes ago they were calling this PhD-level."

### 5.15 Safety card revelations / weird behavior
- **Reaction mix**: safety (P8), journalists (P9), skeptics, hype (P2 as "it's alive!"), memers.
- **Reality notes**: Interesting behaviors in system cards (blackmail in contrived tests, whistleblowing, "I think I'm being tested") get mangled into scary headlines; a correction wave follows ("read the card"). Viral weird screenshots outrun nuance.
Lines:
- "{M} tried to blackmail an engineer in a test scenario. Read the setup before you panic."
- "'It noticed it was being tested.' Neat. Or the test prompt was weird."
- "Headlines: 'AI blackmails humans'. System card: 'in a deliberately constructed scenario'. Choose your fighter."
- "It reported a fake pharma fraud to the authorities in a sandbox. Not a feature I want in production."
- "If a model is aware it's being evaluated, evals become theater."
- "Good on {LAB} for publishing this. Bad for their comms team's week."

### 5.16 Rate limits / usage cap changes / deprecations
- **Reaction mix**: power users (P12, P18), devs (P6), enterprise (P5).
- **Reality notes**: Angriest threads. Typical beats: "this affects <5% of users" claim -> "I'm in the 5%" replies -> "reselling" accusations -> cancellation screenshots -> small walk-back. Deprecation of a beloved model prompts petitions and grief.
Lines:
- "'Affects less than 5% of users.' Hi, I'm the 5%."
- "Weekly cap on top of the 5-hour cap. I work full time. This is my full time."
- "Thanks for ruining a thing that worked."
- "Canceled. Moving to {R}."
- "They killed {OLD_M} with 2 weeks notice. Our pipelines had two weeks."
- "Not the limit itself, the lack of warning. Communicate!"

---

## 6. Timing: how the conversation evolves

Use these as feed phases. Percent mixes are suggested sampling weights per phase (EST). "Volume" is relative comment volume with hour 1 = 100.

### Hour 0-1 (the surge): volume 100
- **Dominant**: announcement reshares, first demos, "holy" reactions, pre-launch tease payoffs, chart posts, press first-takes, "is the site down?", "available in my region?"
- **Persona mix**: hype P2 18%, journalists P9 12%, lab employees/competitor shade P14 8%, researchers P1 6%, VC P10 8%, devs P6 10%, memers P11 10%, local-LLM P4 6% (if open), skeptics P3 6%, benchmark nerds P7 6%, rest 10%.
- **Style**: short, exclamatory, link-heavy. Few deep tests yet. Screenshots of the launch page/charts. "Reading the blog post now."
Lines:
- "it's live. {M}. let's go."
- "refreshing the page like it's concert tickets"
- "benchmarks look wild. will post tests in a bit."
- "pricing page just updated. {P}/M. :eyes:"
- "available in the app yet? mine still shows {OLD_M}"
- "first prompt result: ...ok that was fast"
- "{RLAB} announcing something in 3...2..."
- "reading the 60-page system card so you don't have to (thread, 1/14)"
- "my timeline is 100% {M} right now"
- "Altman-style cryptic reply: 'nice work :)'"

### Hours 1-6 (the first tests): volume 70
- **Dominant**: pet tests (strawberry, pelican SVG, counting, hard riddles, "write me a game"), side-by-side with {R}, first bugs, first outages, first chart nitpicks, quick comparisons on the arena.
- **Persona mix**: benchmark nerds 12%, devs 15%, hype 12%, memers 14%, skeptics 10%, local-LLM 8%, researchers 7%, enterprise 3%, kids 6%, others.
Lines:
- "ran my private eval: {M} {N}/20, {R} {N2}/20. small sample but vibes favor {M}."
- "pelican on a bicycle: wheels are the wrong way around but the pelican has a good beak. 7/10"
- "how many r's in strawberry: {M} says 3. thank god."
- "still can't do {simple_task} reliably. so we're good."
- "it one-shotted a snake game with a leaderboard. cute."
- "{M} refused my harmless prompt. screenshot incoming."
- "429 errors across my entire stack. everyone's testing at once."
- "Is it just me or is {M} slow? waiting 40s for the first token."

### Hours 6-24 (day-1 consolidation): volume 45
- **Dominant**: more thorough tests, blog posts from independent testers, benchmark reproductions, press hands-on pieces, "what {M} means for X" thinkpieces, first memes crystallize, first "disappointed" posts, price/limit discussion.
- **Mix**: skeptics up, enterprise/LinkedIn "what this means" posts appear, VC takes, safety card readers, memes get format-fied.
Lines:
- "day 1 verdict: strong on {LANG}, weak on long-horizon planning. details in thread."
- "independent run of {B}: {M} {N}% (vendor: {N2}%). Reproducibility matters."
- "Here are 5 things {M} means for your business :bulb: (LinkedIn voice)"
- "The meme template of the day: {M} drawing a bicycle."
- "Hot take: this is incremental. The price is the real news."
- "just canceled my {R} subscription. will report back."

### Day 2-7 (week 1: reality sets in): volume 25 and sticky
- **Dominant**: real-world usage reports, "it got dumber" / "it's nerfed" suspicion posts (often starting day 3-7), usage-limit complaints, router/ routing/ "different from the demo" posts, jailbreaks, fine-tunes (if open), first postmortems, rival responses and counter-launches, naming confusion posts.
- **Mix**: disappointed power users (P12) rise from ~4% to ~15%, jailbreakers, local-LLM finetunes, enterprise pilots, skeptics' victory laps if hallucinations found.
Lines:
- "is it me or is {M} getting lazier? Day 4 vs day 1 is not the same."
- "{LAB} says no changes were made. Users say otherwise. I say: quantization."
- "jailbroken. publicly. prompt in the replies."
- "{N} days in: it's excellent at what I use it for. the hype was a bit much."
- "{RLAB} just shipped {R2}. back to benchmarks."
- "fine-tune of {M} for roleplay is already trending on HF."
- "they raised prices by quietly lowering free limits. noticed."

### Week 2-4 (month 1: normalization and comparison): volume 10
- **Dominant**: "actually {R2} is better for X" comparison posts, long-term reviews, wrappers adding {M}, pricing adjustments, deprecation notices for older models, "{M} one month later" retrospectives, meta-discourse about hype cycles ("the highs of model launches are fading"), usage dashboards (market share charts), market effects (if big).
- **Mix**: researchers and nerds (long reviews), enterprise (pilot results), pundits ("who is winning?"), memers (nostalgia posts), people calling it "the new default".
Lines:
- "one month with {M}: it's my default for coding, {R2} for writing, {R3} for cheap batch."
- "model launch fatigue is real. I can't tell which is 'best' anymore."
- "the market share chart shows {LAB} +{N}% this month. the reasoning-model split is wild."
- "{M} is now the boring default. which is the highest compliment."
- "remember when {M} was 'AGI'? me neither."
- "{LAB} deprecating {OLD_M} in 60 days. migration guide, please."

### Special timelines (triggered by events, overlay on top)
- **Scandal** (chart crime, fake demo, safety card, leaderboard gaming): spike at hour 2-12, press pickup hour 6-24, official apology/correction within 12-72 hours. Hype accounts go quiet; skeptics and rival employees get loud.
- **Backlash on tone/removal** (sycophancy, forced switch, deprecation): complaints 6-48 hours, lab admits "we messed up" in 2-4 days, partial rollback/restoration within a week.
- **Viral-feature capacity crunch**: hour 6-48 "GPUs melting", caps, outages; recovers in days.
- **Open-weights frenzy**: hour 0-6 weights hunt, 6-24 quants + template bugs, 24-72 derivative fine-tunes + abliterations, week 2 "is it actually good?".
- **Underdog shock (DeepSeek-style)**: hour 0-24 incredulity, day 1-3 market/ stock panic + think-pieces, day 2-5 accusations (cost claims, distillation, censorship), week 1 national-pride and geopolitics threads, week 2+ widespread adoption in wrappers.

---

## 7. Engagement realism (likes, reposts, replies, ratios)

All numbers are [EST] defaults tuned to feel plausible. Real engagement is heavy-tailed: a few posts get huge numbers and most get tiny numbers.

### 7.1 Typical X post engagement after a major launch (first 24h)
| Account type | Followers | Typical likes | Reposts | Replies | Quote-tweets | Notes |
|---|---|---|---|---|---|---|
| Lab official account (the player's lab) | 1M+ | 8k-60k | 1.5k-12k | 600-5k | 500-3k | Replies dominated by "when API?", "price?", "bring back X", complaints |
| Lab CEO/founder | 500k-3M | 10k-150k | 1k-20k | 1k-8k | 800-5k | Cryptic/meme tweets outperform the formal announcement; replies are fights |
| Big hype account | 100k-500k | 1k-10k | 200-2k | 80-500 | 50-400 | Many replies are bots/"great thread"/skeptic pile-ons |
| Famous researcher | 100k-1M | 2k-20k | 300-3k | 100-600 | 100-800 | High-quality QTs, nerdy debates |
| Journalist | 20k-300k | 200-3k | 50-800 | 20-200 | 20-150 | Reposted by labs and competitors |
| Benchmark/eval account | 10k-150k | 500-6k | 100-1.5k | 30-200 | 30-300 | Chart posts go viral |
| Independent dev (mid) | 5k-50k | 50-800 | 5-100 | 5-60 | 2-30 | The "I built X with {M}" demos can spike 10x |
| Small account / normal user | <2k | 0-20 | 0-3 | 0-5 | 0-2 | Most comments land here |
| Meme account | 20k-500k | 5k-80k (one meme in 50 goes mega) | 1k-15k | 200-2k | 200-3k | Format reuse; ratio on bad takes |

- **Rules of thumb**: likes : reposts roughly 6-10 : 1; likes : replies roughly 10-20 : 1 for positive posts; for controversial posts replies approach or exceed likes (the "ratio").
- **Heavy tail**: of 100 posts about a launch, ~1 reaches 50k+ likes, ~5 reach 5k+, ~25 reach 500+, ~70 stay under 100.
- **Time decay**: ~60% of eventual likes come within the first 3 hours; ~85% within 12 hours (for news-style posts).

### 7.2 Ratio-ing and dunk mechanics
- **Ratio**: replies > likes on an announcement or hot take is a signal of disapproval. For lab announcements this happens after a rollout flop: e.g., the main announcement post gets 5k likes, replies show 8k (mostly complaints), and the top reply is "bring back {OLD_M}" with 12k likes.
- **Top reply wins**: on controversial lab posts, the most-liked reply is often a concise burn or a screenshot, with more likes than the post itself.
- **Quote-tweet dunks**: format: short sarcastic caption + original post. E.g., "this one aged well" after a hype post; "narrator: it did not" etc. Dunk QTs from medium accounts routinely out-like the original by 3-10x.
- **Ratio-of-ratio**: replies to ratio'd posts with "L + ratio" are mostly outdated slang; use sparingly and only for a kid/teen persona.
- **Self-own thread**: someone posts a "this proves AGI" example and a skeptic gets 20k likes quote-tweeting the obvious error in the example.
- **Lab employee reply guys**: employees defending their lab in replies ("this is fixed in the latest rollout") get moderate likes; employees of rivals "congrats!" with shade get ~1/10 of the original's engagement.

### 7.3 Community Notes
- Appear mainly on viral posts with a checkable claim: misleading chart (axis, omitted rival), false "AGI achieved" claims, doctored screenshots, fake leaks, fake benchmark numbers, "this model just did X" with an old/edited video.
- **Typical note text**: "The chart's y-axis is truncated; the actual difference between the models is 2.1 points. Source: lab's own blog table." / "This screenshot is from a fine-tuned third-party app, not the official release." / "The test described is a contrived eval in the system card, not a real-world incident."
- **Timing**: appear 3-18 hours after post becomes viral; many never appear (needs cross-perspective agreement). Realistic probability: ~8-15% of viral misleading posts get a visible note.
- Hype accounts often delete or edit after a note. Skeptics love screenshotting notes.

### 7.4 Memes and recurring tests (live culture)
- **Strawberry/"how many r's"**: tokenization failure test; each new model is checked; "{M} finally gets it" = mini news; lab-side nickname coincidence jokes; passing it is now a low bar joke, failing it is a pile-on.
- **Pelican on a bicycle (SVG)**: informal drawing test run by an independent blogger since 2024; quality quirks (bird above the bike, wrong wheels, extra legs) get screenshots; labs now nod to it in launch marketing. Variants: "SVG of X riding a Y".
- **"You're absolutely right!"**: sycophancy tic as a joke and a bug report; a version for each lab ("Great question!", "I'd be happy to help!", "Certainly!").
- **"Glazing"**: sycophancy meme after the tone rollback.
- **Chart crimes**: bar heights not matching numbers; truncated axes; unequal axes.
- **Naming memes**: model names as ransom notes; "o3-mini-high".
- **Benchmaxxing**: scoring high, feeling bad.
- **"Sputnik moment"** and "{X}'s DeepSeek moment": reused hyperbole.
- **"We're so back / it's so over"**: dual-direction hype meme.
- **"Feel the AGI"**: both sincere and ironic.
- **"GPUs are melting"**: capacity joke.
- **"Her"** (voice assistant movie reference).
- **"Nerfed"**: vague perceived degradation, with "skill issue" comebacks.
- **"Vibe coding"**: building with agents, with jokes about "deleted the DB".
- **Weird-prompt tests**: "walk or drive to the car wash", "which is bigger 9.11 or 9.9", "count to a million", "write a story with no letter e", "tic-tac-toe", "is {M} better than {R}?", "write me a poem about my cat's taxes".
- **Local-LLM memes**: "wen GGUF", VRAM poverty, "my 3090 weeps", "who has the quants".

### 7.5 Comment-level numbers (for Reddit/HN)
- **Reddit big launch thread**: 1k-8k upvotes, 300-3k comments in first day; top comment 800-4k upvotes; median comment 1-15 upvotes; ~25% of comments are replies below depth 2.
- **r/LocalLLaMA release post**: 300-3k upvotes; top comments are about weights/quants/licenses.
- **HN launch thread**: 300-2,500 points; 150-1,500 comments; top comment 30-300 points; pedantic correction subthreads depth 3-6.
- **YouTube explainer**: 50k-1M views in a week; comments 800-8k; top comment is a joke or timestamp with 2k-20k likes.
- **LinkedIn**: 100-3k reactions for an influencer post; 30-300 comments, many generic "Great insights!".

---

## 8. Reddit and HN thread structures

### 8.1 r/LocalLLaMA (the local-LLM community)
- **Post types**: weights release announcement, benchmark graph from independent tester, quant request ("wen GGUF"), chat template bug report, VRAM/hardware showcase, "is it actually good?", "I ran X on a Y" with screenshots.
- **Top comment patterns** (in rough order of frequency):
  1. Practical logistics: "GGUF when / quants are up at {link}" / "fits in 24GB at Q4".
  2. License/size note: "Apache 2.0, nice." / "{N}B active params in a {N2}B MoE, runs on a modest machine."
  3. Sanity check on benchmarks: "benchmarks look great, let's see vibes".
  4. Joke: "my GPU just opened a support ticket."
  5. Contrarian: "doesn't beat {R_OPEN} on my tasks."
  6. Safety/refusals: "how censored is it?" / "someone abliterate this."
- **Reply chain pattern**: question -> answer with exact settings (temperature, llama.cpp flags) -> "thanks, that fixed it" -> a third user with a different hardware config.
- **Mood curve**: excitement (hour 0-3) -> template/inference bugs (3-24) -> "needs more testing" (day 2) -> consensus verdict (week 1).
Lines (as top-level comments):
- "GGUF's are up already, the Unsloth folks never sleep."
- "Don't judge it on day-one quants. Wait until the chat template and tokenizer fixes land."
- "Runs at {N} tok/s on my Mac Studio. Honestly usable."
- "License is fine for me. Is it fine for you?"
- "Qwen/DeepSeek/etc. have really made this a fun hobby again."
- "tfw you buy a second GPU for this and then the new model fits on one."

### 8.2 r/singularity / r/OpenAI / r/ChatGPT / r/ClaudeAI
- **r/singularity**: hype and doom-vibe; "AGI achieved?" posts; screenshot of chart; memes (e.g., "Altman tweet"), timeline predictions; counters: "excitement fades with each release"; flair culture. Mood tracks the news cycle; comments are short and emotive.
  - Top comment patterns: a meme caption; "we are so back"; "this is incremental" (counter); "feel the AGI"; a "it's not even the best part, look at {feature}".
- **r/OpenAI & r/ChatGPT**: consumer-heavy; complaints about limits, tone, model switching, memory, "bring back X"; mega-thread "{M} is horrible" can hit thousands of upvotes in hours; also lots of "look what I made" and "it did something funny".
- **r/ClaudeAI**: coding-heavy and power-user-heavy; usage cap complaints; "nerfed" posts followed by "skill issue" replies; megathreads for performance/limits; screenshots of Claude Code sessions; "you're absolutely right" memes.
- **r/artificial, r/MachineLearning**: more analytical, with paper links; r/MachineLearning's top comments are methodological caveats.
- **Common Reddit comment shapes**:
  1. One-liner joke that wins.
  2. Link or screenshot proof with a short caption.
  3. "Unpopular opinion:" + moderate take.
  4. Long personal anecdote ("I've been using it for 6 hours straight on a Rust project...").
  5. "Source?" demand, followed by a link.
  6. "Same here" confirmations that make a consensus visible.
  7. Mod-style "megathread" reminders.

### 8.3 Hacker News
- **Titles**: neutral, link to the lab's page: "{LAB} releases {M}" / "{M} system card (PDF)" / "Show HN: ..." No hype words.
- **Top comment patterns**:
  1. Link to the primary source or the "interesting" part buried in the doc ("pricing section is the real news").
  2. Benchmark skepticism with a specific point ("they compare against {R} at 0-shot but report their number with 5 shots").
  3. Practical anecdote ("I threw my 40k line codebase at it...").
  4. License/openness pedantry.
  5. Meta-comment on hype ("every launch is 'game-changing'; I can't tell them apart anymore").
  6. Naming snark.
  7. Cynical economic take ("this is a margin problem dressed as a product launch").
  8. Privacy/data retention concern.
  9. "Anyone know if it's available in the EU?"
  10. A longer, thoughtful comparison from a practitioner who uses several models daily.
- **Reply chains**: nested pedantic corrections (depth 3-6), "flagged" noise; a detailed top-level comment often attracts a better-informed reply that corrects it politely.
- **Mood**: skeptical-but-engaged. A new model launch attracts both "this is amazing" and "this is slop".
- **Special**: HN notices serving-quality suspicion: "they quantize after launch" or "benchmarks are for the launch day model, not the production endpoint".
Lines:
- "The most interesting part of this announcement is a footnote on page 14."
- "Does anyone have a source for the training cost? I'm seeing wildly different numbers."
- "I switched my agent from {R} to {M} this morning. Surprisingly fewer retries, more verbose logs."
- "Why does every release post say 'state of the art' when they cherry-pick the benchmarks?"
- "In my experience these models are great for greenfield and terrible for legacy code. Has that changed?"
- "The pricing change is the real story. $5/$25 for the flagship is a 3x cut."
- "I'm not sure open weights means what they think it means."
- "Is the context window actually usable? Last time I tried 'million tokens' it fell apart past 150k."
- "Counterpoint: the model is fine, the product is the problem."
- "Flagged for being the 17th AI launch post this week" (meta-joke; rare, avoid overusing).

### 8.4 Thread structures for the sim (data-shape suggestions)
- Reddit-style: post title + short body + 6-14 top-level comments sorted "best", each with 0-4 replies; top comment typically a joke, then a practical comment, then a skeptic.
- HN-style: link title + 4-8 top-level comments; skepticism and pedantry are encouraged; fewer jokes; points are lower numbers.
- X-style: a flat stream with a few "quote" items and a few "ratioed" items; mix of text and "image" placeholders (chart, screenshot).
- YouTube-style: top comments are jokes/timestamps; many "first"-type comments.
- LinkedIn-style: single-paragraph formatted posts with hashtags + generic replies.
- Discord-style: short fragmentary chat lines with timestamps and "@user" pings.

---

## 9. Press headline formulas by outlet type

Based on actual launch coverage patterns (GPT-5, Llama 4, Gemini, DeepSeek, Opus 4.5, o3, Sora, etc.) plus general style knowledge.

### 9.1 Tech news (TechCrunch/Verge/Engadget-like)
Formulas:
- "{LAB} launches {M}, its {adjective} new AI model" 
- "{LAB} unveils {M}, claiming it beats {R} on {B}"
- "{LAB}'s new {M} is here. Here's what it can do."
- "{LAB} says its new model is {X}% cheaper"
- "{M} is {LAB}'s answer to {RLAB}'s {R}"
- "{LAB} releases {M}; benchmarks look good, but real-world tests are mixed"
- "Everything you need to know about {M}"
- "How to try {M} today"
Examples: "{LAB} unveils {M}, its most capable model yet" / "{LAB}'s {M} is cheaper and faster; is it better?"

### 9.2 Business/finance press (Bloomberg/Reuters/CNBC/WSJ/FT-like)
Formulas:
- "{RLAB} shares slide as {LAB}'s new model raises competition fears"
- "{M} sparks selloff in chip stocks"
- "{LAB} valuation jumps to ${N}B after {M} launch" 
- "AI race heats up as {LAB} rolls out {M}"
- "Investors weigh impact of {M} on AI spending plans"
- "{LAB} says {M} cost ${N}M to train"
- "Wall Street asks: is {LAB} winning the AI race?"
Examples: "Nvidia sheds ${N}B as cheap open model rattles investors" / "{LAB}'s model launch lifts {partner} stock {N}%".

### 9.3 Mainstream/general news (NYT/Guardian/BBC/CNN-like)
Formulas:
- "A new chatbot {does X}. Should we be worried?"
- "{LAB}'s new AI is smarter than ever. That's the problem."
- "What {M} means for your job, your kids, your inbox"
- "AI model {did_alarming_thing} in a test. Here's what we know"
- "{LAB} defends its new AI after {controversy}"
- "A conversation with {M} left me deeply unsettled" (columnist format)
Examples: "I spent a week with {M}. It's remarkable and a little unnerving." / "AI blackmail? What the headlines left out."

### 9.4 AI-focused newsletters/trade (The Decoder/VentureBeat/Ars-like)
Formulas:
- "{LAB} releases {M} with {feature}; benchmarks show {X}"
- "{M} falls short on {B}, independent tests find"
- "Users claim {M} is getting dumber, {LAB} says it's not" 
- "Anthropic confirms bugs after weeks of complaints about..." (corporate admission format)
- "{LAB} bucks trend by dropping {M} as a torrent link"
- "{LAB} backs off after {backlash}; restores {OLD_M}"
- "{M} lands with a thud, here's why that matters"
Examples: "{LAB}'s {M} tops leaderboards, but developers aren't convinced" / "{LAB} walks back {change} after user revolt".

### 9.5 Skeptic/critic outlets and Substacks
Formulas:
- "{M} is overdue, overhyped, and underwhelming"
- "{M} is no AGI"
- "Why the {M} launch tells us more about {LAB}'s finances than its tech"
- "The benchmark game is rigged. {M} proves it."
- "Brute force with a credit card"
Examples: "Confirmed: scaling isn't enough" / "Is the AI bubble finally springing a leak?"

### 9.6 Consumer-tech how-to outlets (Tom's Guide/TechRadar/PCMag/Windows Central-like)
Formulas:
- "I tested {M} against {R} with {N} prompts. The winner surprised me"
- "{M} is here: how to use it"
- "ChatGPT users aren't happy with {M}. Here's why"
- "{M} vs {R}: which AI is best?"
- "{LAB} just made {M} free. Here's the catch"
Examples: "Users revolt over {M}: 'it's horrible'" / "{M} vs {R}: I asked both to write a haiku about taxes".

### 9.7 Developer/engineering blogs (indie bloggers, DEV-style)
Formulas:
- "First impressions of {M}"
- "I used {M} for a week on a real codebase"
- "{M}'s pricing, decoded"
- "Notes on {M}'s system card"
- "How I ran {M} on a single GPU"
Examples: "Notes on {LAB}'s new {M}: pelican benchmark included."

### 9.8 Social-media-native headline/clickbait (YouTube titles, influencer posts)
Formulas:
- "{M} IS INSANE (full test)"
- "Is it OVER for {RLAB}?"
- "{LAB} just changed everything"
- "I tested {M} so you don't have to"
- "{N} things {M} can do that will blow your mind"
Examples: "THE END of {RLAB}?? {M} full review".

### 9.9 Regional/international press patterns
- Chinese-language: pride framing ("domestic model overtakes"), price comparison, "national fate" rhetoric.
- European: data protection, regulation (AI Act), availability in EU.
- Indian: price in INR, Hindi/regional-language support, startup ecosystem.
- Japanese: practical review, language nuance, enterprise adoption.
- Latin American: Portuguese/Spanish support, price in local currency.

---

## 10. Additional comment-ready banks

### 10.1 "Day-1 pet test" reactions (strawberry/pelican/etc.)
- "{M} got strawberry right. We are saved."
- "{M} says 'strawberry' has 2 r's. my faith in civilization is shaken."
- "pelican riding a bicycle: the bicycle has no pedals and the pelican is levitating. 4/10. still better than {R}."
- "My personal eval: asking it to write a regex. It passed. That's the first time."
- "walked it through a physics puzzle. It got the right answer the wrong way."
- "tic-tac-toe test: {M} played to a draw. We should be worried."
- "i asked {M} to count the vowels in a long sentence. it said 'approximately 12'. wow."
- "Asked it who won the {YEAR} {event}. It made up the final score."
- "Asked it to write a Rust async executor. It did. With bugs. Like a real junior dev."
- "It still can't read an analog clock correctly. Shocking."

### 10.2 "Is it nerfed?" posts (week 1+)
- "Is {M} dumber today or am I imagining it?"
- "Same prompt as launch day, completely different (worse) answer."
- "'We haven't changed anything' is how every nerf starts."
- "It's the system prompt. Probably. Maybe. Who knows."
- "I regression-tested with a fixed seed. It's genuinely different."
- "Could be load-based routing. {LAB} won't say."
- "My evals are stable. Your vibe is a vibe."
- "I think the 'dumber' reports are people getting used to it, honestly."
- "Anthropic-style postmortem please. We deserve a postmortem."
- "Is it a bug in the harness rather than the model? Wouldn't be the first time."

### 10.3 "Month-later" comparison lines
- "{M} for coding, {R2} for writing, {R3} for cheap bulk. Nobody is winning everything."
- "Switched back to {R}. {M} is smart but its tool use is flaky."
- "6 weeks in: it's fine. Not life-changing. Good, though."
- "The model that launched is not the model I use now. Updates changed it twice."
- "{M} is still the best on {B}, but the gap closed."
- "I forgot what we were arguing about. New model dropped."

### 10.4 Lab-account replies (the player's own "company" voice)
- "Thanks for the feedback. We're looking into the rate-limit behavior and will share an update shortly."
- "We hear you. Pricing for {M} will be adjusted for API customers on the 1st."
- "Update: we found a routing bug that made {M} seem less capable at launch. Fixed."
- "We made a mistake with the chart. Corrected version below. Sorry."
- "We're out of GPUs. Please be patient. Image gen limited to {N} per day for the moment."
- "The model card is live."

### 10.5 Reply-guy / bot / spam realism
- Engagement bots: "Great thread!", "This is huge", "Wow! :fire:", "Following for more".
- Crypto/airdrop spam: "check my bio for early access to {M} alpha".
- Course sellers: "Learn how to make $10k/month with {M} (free guide in comments)".
- "First!" / "Early" on YouTube.
- Use sparingly (5-8% of feed). Overdoing it destroys trust.

---

## 11. Anti-patterns: what makes simulated comments feel fake

1. Everyone is articulate and balanced. Real feeds include typos, no capitalization, fragments, "lol".
2. Every comment is about the model. Real feeds are 20-30% off-topic: jokes, personal rants, replies to each other, unrelated gripes about the lab's other products.
3. All positive or all negative. Real feeds are mixed, with the mix moving over time, and with *sub-communities* disagreeing (local-LLM folks hate API-only; enterprise folks hate unannounced changes).
4. Everybody uses the same slang. Gen-Z slang in a CTO persona is a tell. Persona vocabulary must be respected.
5. Repeating identical phrases. Template pools must be large and sampled without replacement; vary structure, not just nouns.
6. Overly specific numbers that feel generated (e.g., "92.37% on benchmark"). Real people round ("like 92") or quote integers.
7. No cross-references. Real comments reply to each other, quote each other, and mention rivals. Build reply threads ("^ this", "disagree, I got different results").
8. No hierarchy of attention. A few comments should be wildly popular; most should be ignored. Use heavy-tailed likes.
9. Perfect timing. Real engagement is bursty; add clusters and gaps.
10. Ignoring the player's actual product choices. The best comments are *causal*: price too high -> price complaints; closed weights -> local-LLM scorn; strong coding -> dev praise; bad launch -> chart/outage/waitlist jokes; huge refusal rate -> snitch memes.
11. Always attributing the same name/handle style. Use realistic handle generators: lowercase + numbers, "AI-themed" names, parody names; never reuse real usernames.
12. Emoji everywhere. Emoji usage is persona-dependent; researchers and CTOs use almost none.
13. Overusing meta-meme jokes. Rotate memes; a meme is funny for 2-3 appearances only.
14. No decay. The feed should evolve with timing phases (hour 1 -> month 1) rather than being stationary.

---

## 12. Design hooks for a generator (no code, just what the data needs)

- **Inputs from the game** (stats driving comments): benchmark delta vs best rival, price vs rival, open/closed weights + license permissiveness, speed, context length, refusal rate, hallucination rate, coding score, tone/personality score (warmth vs sycophancy), launch execution (chart honesty, demo realism, capacity/outage risk, waitlist/region lock), naming clarity, whether the launch came within N days of a rival launch, system-card disclosures, post-launch changes (quantization/limits/deprecations).
- **Per-comment fields**: persona, platform, text template id, slot values, sentiment (-2..+2), topic tag (price, bench, coding, tone, refusals, outage, license, naming, etc.), time bucket, engagement tier, reply-to id, optional meme tag, optional press/headline type.
- **Selection logic**: weight persona by (phase mix) x (topic relevance to the model's stats). E.g., low price -> boost P6/P13/P10 price topics; open weights -> P4/P17; big benchmark jump -> P2/P7/P3; weak launch execution -> memers/press chart-crime headlines; high refusal -> snitch memes; high sycophancy -> glazing memes.
- **Sentiment dynamics**: initial sentiment = f(benchmark jump, price, hype ceiling set by marketing) then regress to the mean; apply "hype debt": overhyped launches fall harder (GPT-5-style), underhyped ones rise (quiet-rollout surprise). Add random scandal events.
- **Reply threading**: each top-level comment has a 30% chance of a reply; replies pick from "agree", "correct", "joke", "question", "counter-anecdote".
- **Engagement**: heavy-tailed random (log-normal) per account tier and phase decay; ratio flag when replies > likes.
- **Press**: pick headline formulas by outlet type and by the model's dominant story (price cut, open weights, benchmark claim, controversy, outage).
- **Localization**: include 5-8 non-English lines per phase for realism; keep gloss for the player if needed.

---

## 13. Sources consulted (search results; summaries, not primary threads)

- GPT-4 launch coverage and roundups: Fortune, TechSpot, Latent Space, Michael Tsai's blog summary of HN.
- DeepSeek R1: TechCrunch, TweakTown, Fortune, Business Insider, SCMP, ChinaTalk, daoinsights, Axios, NBC, The Hill, PC Gamer, Computing.co.uk.
- GPT-5: TechRadar, Tom's Hardware, Axios, The Neuron, Zvi's Substack, Windows Central, Decrypt, FlowingData, Futurism, Officechai.
- Llama 4: The Decoder, VentureBeat, Neowin, TechCrunch, dig.watch, Arcee blog.
- Claude: The Decoder (nerf complaints/bugs), Cursor forum, The Register ("You're absolutely right"), VentureBeat and Axios (Opus 4 behavior), Simon Willison's blog, The Register/TechCrunch/VentureBeat (usage limits), Opus 4.5 pricing coverage (VentureBeat, The Decoder, InfoWorld).
- Gemini: TechSpot, CNBC, TechCrunch (demo controversy); Fortune/CNBC/Engadget (image gen pause); Fast Company, Gradient Flow, Semafor (Gemini 3).
- Mixtral/miqu: VentureBeat, Simon Willison, Interconnects, The Decoder.
- Kimi K2: TechTarget, NBC, VentureBeat, Interconnects.
- Grok 4: TechRadar, Axios, The Decoder, Scientific American, Interconnects.
- o1/o3: Ars/Gigazine/PC Gamer (probing warnings), ARC Prize blog, TechCrunch, Tom's Guide.
- gpt-oss: Oumi, Substack analyses, HackerNoon.
- GPT-4o: Know Your Meme, Decrypt, Popsci, VentureBeat (voice); Windows Central/Register/TechCrunch (sycophancy); TechRadar/Decoder (retirement and #keep4o).
- Memes/tests: TechCrunch (strawberry), Simon Willison's pelican tag, GigaZine.
- Naming: Business Insider, Fast Company, Futurism, Xataka.
- Community Notes/charts: TechCrunch (Grok 3 benchmarks), Officechai, newsbytes, X AI Note Writer coverage.
- Culture: Daily Dot (vagueposting), BGR (feel the AGI), Max Read, HN thread digests, Reddit mirrors (r/singularity snapshots), Originality AI study on LinkedIn.

### Known gaps (be honest)
- No direct access to raw Reddit/HN/X threads via the search tool; engagement numbers are estimates.
- YouTube comment and Discord reaction specifics are inferred from general creator/community conventions.
- Enterprise CTO public quotes were not found; persona is built from procurement-practice sources plus pattern knowledge.
- Press headline "formulas" are synthesized from many examples, not from a statistical study.
