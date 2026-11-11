# Reference Game Research: "Start an AI Company" (Roblox)

Research date: 2026-11-11. Purpose: study mechanics to build an ORIGINAL, more fun and more realistic AI-company tycoon. We do not copy name, art, or assets.

## Research limitations (read first)
- WebFetch was blocked for roblox.com, startanaicompany.wiki, rivalducks.com and bloxstatus.com (hosts not in the session network allowlist). Everything below comes from WebSearch result summaries, not from reading the pages directly.
- No Reddit threads, YouTube transcripts, Discord, or player reviews were found. The "praise/complaints" section is therefore mostly INFERRED, and labeled so.
- Re-run this research with roblox.com, rivalducks.com, bloxstatus.com, startanaicompany.wiki, reddit.com and youtube.com allowed for a verified second pass.

Legend: [V] = stated in at least one search-result source; [I] = inference; [?] = unknown.

## 1. Facts
| Item | Finding |
|---|---|
| Name | Start an AI Company (also written "Start a AI Company") [V] |
| Developer | Kairo Experiences [V] |
| Release | October 2026 [V, single-sourced summary] |
| Last update | 2026-11-06 per trackers; no published schedule [V] |
| Age rating | All ages [V] |
| Visits | ~144.7K, ~185.5K and ~314K in three different tracker snapshots (growing fast, early Nov 2026) [V] |
| Concurrent players | 581, 792 and ~1,100 (snapshot of Nov 8) in three snapshots [V]. Small-to-mid hit, not a top-tier game. |
| Ratings (likes %) | Not found [?]. Code unlock is tied to like milestones (1k likes per official page; 500 per a tracker), so likes are in the hundreds to ~1k [I]. |
| Community | No official Discord; announcements posted on the game page; no official wiki/Trello per Destructoid. A fan wiki exists (startanaicompany.wiki) [V] |
| Codes | UPDATE (3.8k Cash + a new robot); LAUNCH mentioned by one tracker. Redeemed in laptop settings (gear icon) after the tutorial [V] |

Do not confuse with "Build an AI [HACK]" by Lucky Loop (rebirths, GPUs, hacking) or "AI Tycoon" (robloxden codes list). [V]

## 2. Core loop (as far as verified)
1. Start in a bedroom with a laptop. Tutorial teaches the laptop UI. [V]
2. Choose model parameters: size, data, personality. [V from search summary of the game description]
3. Train the model (time-based, faster with more GPUs). [V/I]
4. Launch the model. Users arrive: a good model brings thousands of users, a great one "goes viral". [V]
5. Users generate Cash. Income continues while offline (idle). [V]
6. Spend Cash on GPUs/servers (racks fill your server space; fan wiki has a GPU tier list), better hardware to satisfy bigger-model requirements, staff, and offices. [V]
7. Bigger offices: bedroom -> co-working space -> office -> HQ -> tower -> campus. [V]
8. Sell the company for billions and restart stronger (prestige/rebirth). [V]
Also: "deploying robotic labor" (robots; code rewards a robot) and "risky operations" per one guide's description. [V, vague]

Resources identified: Cash [V], GPUs/servers [V], users [V], model size/data/personality choices [V], robots [V]. Researchers/staff hiring mentioned in the official blurb as "hire staff" [V]. Explicit data-acquisition or electricity/cooling economy: not found [?], likely absent [I].

## 3. Progression / unlocks / prestige
- Linear location ladder (6 tiers) [V].
- Hardware gating: models have hardware requirements you must meet by upgrades [V, Destructoid].
- Prestige: sell company for billions, restart stronger [V]. Exact multiplier formula [?].
- Update cadence: one update in the first ~5 weeks (Nov 6) [V].

## 4. Model releases and feedback
- Release = pressing launch; outcome tiers by quality: user thousands (good) vs viral (great) [V].
- How reactions are visualized (user counters, tweets, news popups, reviews): not found [?]. Assume a simple counter and popups [I].
- No evidence of competitors, benchmarks, safety/regulation events, or failure states [I].

## 5. UI/UX and world
- Laptop-centered UI with settings gear and code box [V].
- 3D world: personal spaces that expand through the six location tiers; server racks physically fill the space [V/I]. Robots appear as worker NPCs [V/I].
- Layout details (HUD, shop menus, camera) [?].

## 6. Monetization
- Gamepasses/dev products: not verified [?]. Searches found no 2x-cash pass listing. Typical genre pattern (2x cash, auto-collect, extra GPU slots, Robux cash packs, robots) is likely [I].
- Code system with like-milestone gating as an engagement/like-farming tactic [V].

## 7. Praise and complaints
Verified: none from players (no sources found). Known only: rapid growth in visits and CCU in the first weeks [V].
Likely (inferred from genre and feature descriptions, NOT sourced):
- Praise: relatable theme, clear short loop, offline income, satisfying visible growth, robots.
- Complaints: shallow decisions, grind/idle waiting, prestige repetition, little realism, pay-to-win passes, thin content (one update so far), no social/competitive layer.

## 8. Opportunities (15+) for our original game
1. Real compute economics: GPU purchase vs cloud rental, power, cooling, depreciation, supply shortages, hardware generations. (Reference: just buy GPUs.)
2. Data as a first-class resource: licensing, scraping risk and lawsuits, synthetic data, quality vs quantity, data cleaning crews.
3. Meaningful model design: architecture/size/data mix/training duration trade-offs with visible loss curves and diminishing returns, not a size slider.
4. Failed and flawed runs: diverging training, bugs, overfitting, hallucination, bias; the player must evaluate with benchmarks before shipping.
5. Benchmarks and leaderboards: public evals, benchmark gaming, contamination; reputation tied to results.
6. Real competitors: AI rival companies (NPC) racing for leads, poaching staff, price wars, open-source releases that collapse margins.
7. Talent management: researchers with specialties, morale, burnout, salaries, poaching, culture, hiring pipeline.
8. Funding realism: seed to Series A+, valuation, dilution, investor pressure, burn rate, runway, IPO or acquisition instead of a pure "sell for billions" reset.
9. Product layer: ship APIs, chat apps, enterprise deals; pricing and inference cost per query, so scale can lose money.
10. Release events with texture: launch-day press, social reactions, reviews, outages from demand spikes, viral moments and backlash, shown as a live feed.
11. Safety, ethics and regulation: red-teaming, incidents, audits, laws that change by region, trade-offs of speed vs safety.
12. Prestige that is not a reset: legacy bonuses via research reputation, spin-off companies, endowed labs, or "second company" mode with different strategy.
13. Multiplayer and social: shared server market, co-op labs, player rivalry, trading compute, public leaderboards of model scores.
14. Player agency in the 3D world: build and lay out your own office/datacenter (cooling aisles, power), not just upgrade tiers; visible employees at desks.
15. Events and crises: chip export bans, power outages, data breach, leak of weights, talent raid, hype/bubble cycles that vary the economy.
16. Active play, not only idle: minigames (debugging a training run, interviewing candidates, demo day pitches) with mastery rewards.
17. Long-term content cadence: seasonal "AI eras" (new hardware generation, new paradigm) and frequent updates; documented roadmap and Discord/wiki for community.
18. Fair monetization: cosmetics (office themes, avatars), convenience that does not break progress, no mandatory pay-to-win; avoid like-gated codes as the main hook.
19. Education value: tooltips that explain real concepts (parameters, tokens, compute, inference), to appeal to parents and attract broad audiences.
20. Telemetry-driven tuning and retention hooks: daily goals, quests, clear "next goal" always on screen; the reference's goals appear to be purely purchase-based.

## 9. Sources
- Roblox page: https://www.roblox.com/games/112240686603278/Start-an-AI-Company (surfaced in search, not fetched)
- Pro Game Guides codes: https://progameguides.com/roblox/start-an-ai-company-codes/
- Destructoid codes: https://www.destructoid.com/start-an-ai-company-codes/
- GGRecon codes: https://www.ggrecon.com/guides/all-start-an-ai-company-codes-to-redeem-free-rewards/
- MrGuider codes: https://www.mrguider.org/roblox/start-an-ai-company-codes/
- Fan wiki (unverified): http://startanaicompany.wiki/
- Trackers: https://rivalducks.com/apps/radar/games/10771193632-start-an-ai-company , http://bloxstatus.com/games/start-an-ai-company/updates/
- Similar game: https://www.roblox.com/games/84637477108843/Build-an-AI ; https://robloxden.com/game-codes/ai-tycoon
