# 02 - Fun and Retention: Research for an AI-Lab Tycoon on Roblox

Goal: an original, single-player-first Roblox game where the player runs an AI lab. They train LLMs, release them, and compete with rival labs.

This document covers what makes tycoon, idle, and business-sim games sticky, how to build satisfying feedback, how to pace progression and offline earnings, how to design events and rivals, and a ranked list of feature ideas adapted to an AI-lab theme.

---

## 0. Method and source quality

**Searches:** 41 web searches across Roblox tycoons, Roblox analytics, idle/incremental design, Game Dev Tycoon, Software Inc, Universal Paperclips, Cookie Clicker, Big Ambitions, juice/game feel, Balatro, Vampire Survivors, Hades, Mini Motorways, Dwarf Fortress, and Hearthstone reveals.

**Page reads:** Every WebFetch attempt failed with a DNS error (`ENOTFOUND`). The affected hosts were `gamedeveloper.com`, `www.gamespot.com`, `www.destructoid.com`, `www.cubix.co`, and `ericguan.substack.com`. Their claims below come from search-result snippets only. To verify them, the session's network allowlist needs those hosts added. The GDC Vault talks were also not read, only their listing pages.

**Source-quality tiers used in this doc:**

- **Tier A:** Official Roblox Creator Hub docs (create.roblox.com), developer's own press or blog posts, Wikipedia-derived pages on the game.
- **Tier B:** Named journalism (PC Gamer, Game Informer, GamesRadar), GDC Vault listings, academic venues (DiGRA).
- **Tier C:** Developer forums, personal blogs, SEO content, AI-generated review summary sites (vaporlens, creation.dev, rolearn.dev, rowatcher.com). Use these as hypotheses to test, not facts.

Where a claim rests on Tier C, it is flagged.

---

## 1. Core loop patterns that keep players engaged

### 1.1 The basic tycoon loop

The common structure is: produce -> sell -> earn currency -> reinvest in capacity -> produce faster. One practitioner's version is that the loop should feel passive enough to relax in, but active enough to need attention (Tier C, creation.dev / search summary). Roblox tycoons are usually built this way, and one commentary piece calls the genre "the genre that built Roblox and still hasn't peaked" (Tier C, https://rowatcher.com/news/tycoon-games-the-genre-that-built-roblox-and-still-hasn-t-peaked).

A RoWatcher article argues that "the core loop mistake" kills most Roblox games (Tier C, https://rowatcher.com/news/the-core-loop-mistake-killing-most-roblox-games). The recurring theme across these pieces is that progression amplifies a loop but cannot replace a good one. Raph Koster's *A Theory of Fun* is cited for the idea that fun is learning a pattern. This is a reasonable design frame, though the source is a secondary summary.

### 1.2 Three loop timescales

The most useful structure for this game is three nested loops, which matches what the best idle games do:

| Loop | Length | Example in this game | What it must deliver |
|---|---|---|---|
| **Short** | 5-60 seconds | Click/assign a GPU job, watch progress, get a loss-curve drop | Immediate feedback, "one more click" |
| **Medium** | 5-20 minutes | Train a model, benchmark it, release it, see the reaction | A completed "project" with a verdict |
| **Long** | Hours to weeks | Build out a lab, earn a generation reset, rise in the rival rankings | Identity, goals, a reason to return |

The mistake to avoid is a medium loop that is too thin to finish, or a long loop that never shows any progress until far later.

### 1.3 Cookie Clicker and Universal Paperclips loop structure

- **Cookie Clicker:** click -> buy generators -> cookies per second grows -> prestige resets for permanent multipliers. Each prestige level adds a permanent +1% CpS, and the bonuses stack additively. Heavenly Chips are a spendable currency earned at roughly 1:1 with prestige levels (Tier A/C, https://cookieclicker.wiki.gg/wiki/Prestige). The tension is built in. Reset too early and you lack chips for impactful upgrades. Wait too long and progress slows. Players must judge when a reset pays off.
- **Universal Paperclips:** the core loop is click to earn, then spend on upgrades that raise income. Frank Lantz has said clicker games have a slot-machine-like pull (Tier B/C, search summaries citing interviews), and he designed one as a deliberate counterpoint to AAA games (Tier B, Lantz interviews referenced in search results). The game has a defined ending of about 6-8 hours (Tier C, search summary). An academic-style analysis calls it closer to a market simulation than an idle game, because you manage wire supply, price, and inventory (Tier C).

**Lesson for us:** Paperclips shows that a finite, authored arc (with a real ending) can sit inside an idle structure. Cookie Clicker shows that a prestige reset with a chip-like currency can create long-term reasons to play. Both are useful for an AI-lab game that ends with a "singularity" style milestone.

### 1.4 Tycoon-specific loop evidence

- **Simulator and tycoon genre:** Roblox simulators (Pet Simulator X, Mining Simulator) run a loop of perform action -> earn currency -> buy upgrades -> unlock new area. Each area is a progression tier (Tier C, search summaries from creation.dev and rolearn.dev).
- **Lumber Tycoon 2:** described as retaining players by presenting unique physics-based problems, and long-term players invent their own transport solutions (Tier C, search summary).
- **Retention through a generator cap:** one practitioner suggests a generator with a maximum capacity that takes around 18 hours to fill. That creates a soft appointment, not a bolted-on daily bonus (Tier C, rowatcher search snippet).

---

## 2. Roblox-specific retention data

### 2.1 Official metric definitions (Tier A)

Roblox defines retention as the share of users who return after their first visit at 1, 7, and 30 days (https://create.roblox.com/docs/en-us/production/analytics/retention). Cohorts are grouped by the date a user first joined. D7 and D30 for recent cohorts fill in only after enough time passes. Roblox also notes that cohort retention is useful for measuring the impact of major updates, events, or marketing campaigns.

Average session time is total play time divided by the number of sessions (https://create.roblox.com/docs/production/analytics). Sessions map to visits in the Open Cloud Analytics API. A DevForum thread reports that teleports may count as separate sessions, but that is not official and needs to be checked.

### 2.2 Benchmarks (Tier C, do not treat as truth)

- RoWatcher gives tycoon targets of D1 around 20-28% and D7 around 12-18% (https://rowatcher.com/news/retention-benchmarks-by-roblox-genre-what-good-actually-looks-like). The source is a single vendor and Roblox does not publish benchmarks.
- RoWatcher also proposes D7/D1 ratios and session-length decline as loop-quality signals. Those thresholds are informal and self-described as triangulated.

**Practical takeaway:** Instrument D1, D7, average session length, and sessions per user from the first build, and compare cohorts across events and updates. Do not design to someone else's benchmark.

### 2.3 Algorithm and platform noise (Tier A/C)

A DevForum thread on the "Recommended For You" algorithm update reports tycoon developers seeing D1 drop sharply after the change, from a stable 18.5% to around 9.5% in one case (https://devforum.roblox.com/t/boost-your-discovery-with-the-improved-recommended-for-you-algorithm-and-analytics-for-creators/3587441). A Roblox staff reply said elevated D1 lined up with periods without ad campaigns. RoWatcher's "D1 is a platform problem, D7 is a design problem" (https://rowatcher.com/news/d1-is-a-platform-problem-d7-is-a-design-problem) makes the same split. Early retention is shaped by discovery and ads, and later retention is shaped by the loop.

**Takeaway:** For a single-player-first game, D7 and session depth are the metrics that reflect design quality. D1 mostly reflects traffic source.

### 2.4 Events and retention (Tier C, anecdotal)

A RoLearn case study describes a tycoon with about 8,000 concurrent users. It added a limited-time bundle, available for 72 hours every two weeks. Revenue went up, while D1 stayed flat (20% before, 21% after) and D7 stayed roughly flat (https://rolearn.dev/case-studies/tycoon-monetization-overhaul). The same source reports that a monetization overhaul tripled revenue without hurting retention. Single cases and vendor marketing, so weight them lightly.

A second RoLearn report claims seasonal events average 2.1x revenue in their windows (Tier C, unverified, no retention split).

**Takeaway:** Events appear to drive monetization more than retention. Design events to create reasons to return for the core loop, not just to sell.

### 2.5 Daily rewards (Tier A for features, Tier C for effect)

Roblox's Engagement Rewards package provides a framework for daily login streaks and time-played rewards (https://create.roblox.com/docs/en-us/resources/feature-packages/engagement-rewards). A RoWatcher critique argues that fixed-interval daily bonuses are the weakest schedule for producing persistent behavior (https://rowatcher.com/news/reward-schedules-in-roblox-why-daily-login-bonuses-backfire). That is an opinion piece. The stronger theory is variable-ratio or "earned when ready" timing, which matches the generator-cap idea above.

---

## 3. Satisfying feedback ("juice")

### 3.1 Canonical sources

- **"Juice It or Lose It"** (Martin Jonasson and Petri Purho, GDC Independent Games Summit): the GDC Vault listing describes it as neat tricks to make any game more satisfying (https://gdcvault.com/play/1016487/Juice-It-or-Lose). Secondary summaries say the talk demonstrates about 20 small tweaks, each building on the last, and describes juicy things as wobbling, squirting, bouncing, and making cute noises (Tier C, search summaries). Counterpoint: Folmer Kelly's "Don't Juice It or Lose It" argues against over-juicing.
- **"The Art of Screenshake"** (Jan Willem Nijman): most sources place it at INDIGO 2013, though some say a GDC Europe Independent Games Summit (Tier C, venue disputed). It argues for physicality: screenshake, slow motion, particles.
- **Steve Swink, *Game Feel*:** frames game feel as "virtual sensation" and argues it is "in many ways the essence of videogames" (Tier B, book, cited in search summary).
- **Hicks et al., "Good Game Feel: An Empirically Grounded Framework for Juicy Design" (DiGRA 2018):** an academic framework for juicy design (Tier B). The search result URL (dl.digra.org/index.php/dl/article/download/793/793) was not opened, so verify the link before citing it externally.

### 3.2 Balatro as a modern example

- Balatro layers feedback on every scoring event. Card animation, then chip counter, then multiplier, then final score, with each channel feeding the next (Tier C, https://blakecrosley.com/guides/design/balatro). The exact timing values in that analysis are unverified, since no developer source was found.
- Screen shake intensity is said to scale with the size of the score, so shake acts as a data channel before the number appears (Tier C).
- GMTK's "Balatro's Cursed Design Problem" argues that hiding the score preview creates tension, since players feel they need outside tools to calculate outcomes (Tier B-ish, https://gmtk.substack.com/p/balatros-cursed-design-problem). Relevant to us: avoid hiding critical information that the player must compute.

### 3.3 Reveal moments

- Hearthstone's opening animation is built to create anticipation and make the cards feel like valuable objects (Tier B, PC Gamer, https://www.pcgamer.com/behind-the-addictive-psychology-and-seductive-art-of-loot-boxes/). Designers tune the anticipation window down to fractions of a second.
- A RoWatcher observation: revealing rarity and item at the same time removes the amplification that comes from the gap between them (Tier C). Separating "it's a rare one" from "here is the model" stretches the reveal into two beats.
- Variable-ratio reinforcement is the usual psychological frame for irregular rewards (Tier B/C). Use it for reveals, not for money-spending pressure.

### 3.4 Numbers, popups, and counting

- Damage-number guides note that popups make hits feel impactful, convey information, and need pooling because many can fire at once (Tier C, bugnet.io search snippet).
- Counting numbers with tick sounds is a common approach (Balatro analyses, Tier C).

### 3.5 Feedback checklist for this game

Each significant event (training finished, benchmark passed, release, rival overtakes you) should have at least four channels:

1. Visual: a card, badge, or flash.
2. Number: a count-up with a tick.
3. Audio: a distinct sound, pitched up as value rises.
4. Camera or UI: a shake or a brief panel slide.
5. Narrative: a one-line headline or rival reaction.

Keep the layers short. The longer the reveal, the less the player wants to repeat it.

---

## 4. Progression pacing, offline earnings, and prestige

### 4.1 Pacing principles

- **Early game:** Teach the core loop within the first 60 seconds. One practitioner says the main fun mechanic should appear that quickly (Tier C, creation.dev snippet). Do not overwhelm with systems.
- **Staggered unlocks:** Add a new layer when the old one is understood. Mini Motorways has a fair, gradual difficulty ramp with cities unlocked through points (Tier C, reviews and fan-compiled order). Mini Metro's next city unlocks after a modest point threshold, so casual play still works (Tier B/C, review).
- **Gradual versus step growth:** A Substack essay on Vampire Survivors argues gradual stat growth holds pacing better than infrequent power spikes (Tier C, https://jboger.substack.com/p/the-secret-sauce-of-vampire-survivors).

### 4.2 Offline earnings

- **The cap question:** Practitioners disagree on the size of offline gains. One view is that offline income should be capped because it is a major retention tool. Another is that offline should pay only part of the active rate, such as money but not XP (Tier C, search snippets from r/incremental_games and a developer blog).
- **Welcome-back screen:** A common pattern is to show what you earned while away. Players reportedly want offline gains that feel substantial and a small gap between idle and offline progress (Tier C).
- **Roblox implementation:** A DevForum approach records the leave timestamp, compares it with the login time, and multiplies the per-second rate by the elapsed seconds. Save the timestamp in a DataStore so it survives rejoins (Tier C, https://devforum.roblox.com/t/how-to-make-an-offline-earning-system/3761245). Wrap DataStore calls in pcall, save on PlayerRemoving and BindToClose, and mind rate limits (Tier C, Coddy and creation.dev tutorials). Verify API details against the official DataStore docs.
- **AFK bonus effect:** A practitioner says that a small AFK or offline bonus can lengthen sessions because players feel safe stepping away (Tier C, creation.dev snippet).

**Recommendation:** For an AI lab, offline should mean "training runs keep going and the lab keeps earning, but at a reduced rate, with a welcome-back report of what finished." Cap the window (for example, 8-12 hours at full rate, then taper) so offline never fully replaces play.

### 4.3 Prestige design

- **Cookie Clicker:** permanent multipliers from prestige levels, plus a spendable currency that resets with the run (https://cookieclicker.wiki.gg/wiki/Prestige). One guide describes a cube-root-like relationship between lifetime cookies and chips, meaning each doubling costs about eight times more cookies (Tier C, unverified).
- **Early versus late resets:** Early resets give big jumps, and later ones give diminishing returns. The cost curve creates a natural difficulty curve without level design (Tier C, idle design search snippets).
- **Timing:** One designer reported the first prestige took 25-35 minutes for most players, and they would compress it to 15-20 (Tier C). One forum thread says resets should happen often enough not to bore, but not so often that setup is tedious. A postmortem suggests offering the reset just before the wall causes churn.
- **Contested value:** Some critics argue prestige is a developer crutch that should be questioned (Tier C). Treat it as something to earn, not a default.
- **Multiplier steps:** A Roblox tycoon guide suggests 2x on the first rebirth, 3x on the second, and so on, with 5-10 levels, and says each rebirth should feel meaningful (Tier C, creation.dev). Gate special content behind rebirth counts so resets feel like progress, not just bigger numbers (Tier C).

**Recommendation:** Call the prestige "a new generation" (for example, Gen 1 -> Gen 2). Keep research points as a permanent currency across generations (the Heavenly Chips analog). Give each generation a new bonus category, such as "scaling law" or "inference efficiency," so the reset changes how the player plays rather than just scaling numbers. Target 15-20 minutes for the first reset.

### 4.4 Monetization and compliance (Roblox)

- **Passes vs developer products:** Passes are one-time purchases. Developer products repeat. Developer products have a 1 Robux minimum and 1 billion Robux maximum (https://create.roblox.com/docs/en-us/production/monetization/passes.md, developer products page).
- **Cross-experience sales:** The developer product page warns that cross-experience developer product sales are being disabled from May 30, 2026. Check the current status before shipping.
- **Randomized items:** If you sell randomized rewards for Robux or in-experience currency, you must disclose the actual numerical odds before purchase (https://create.roblox.com/docs/en-us/production/monetization/paid-random-items). Keys, re-roll tokens, and spin tickets bought with Robux are covered. Earned randomized rewards are exempt.
- **Monetization advice (Tier C):** Sell speed and convenience, not prestige currency. Avoid "XP traps" with paywalled prestige currency and flattening curves after the first hour.

For an AI-lab game, the safest monetization is cosmetic (lab skins, model name cards) and convenience (more concurrent training slots), with prestige and research points earned only through play.

---

## 5. Random events, rivals, news feeds, and narrative hooks

### 5.1 Random events in Game Dev Tycoon

- Players describe Game Dev Tycoon's events as predictable because they follow history, not chance (Tier C, GameSpot user review summary, https://www.gamespot.com/game-dev-tycoon/user-reviews/2200-12552441/). This is a fair criticism to avoid: random events should be unpredictable within a rule, not a scripted calendar.
- Some reviewers say random events interfere with production. Bad events should be recoverable, and the player should be able to respond (Tier C, Steam reviews).
- A GamingTrend reviewer described a game they never developed getting a batch of 1-star reviews that cost them fans (Tier C). That shows events can feel unfair when the player had no lever.

### 5.2 Review scores and reveal in Game Dev Tycoon

- Quality comes from design and technology points, which are allocated during development. Hype comes from marketing budget and from sequels to high-scoring games. A game that scores 8/10 or higher can be followed by a sequel (Tier C, community guide, cubix snippet).
- Players repeatedly complain that the scores are opaque. A game with fewer design and technology points can score high, while one with more points can score low, with no clear reason (Tier C, GameSpot and Steam user reviews). Lesson: explain the score breakdown after each reveal.
- Game Dev Tycoon's Metacritic iOS page shows a score of 89 (Tier A-ish, developer posts and Metacritic listing: https://www.metacritic.com/game/game-dev-tycoon/details/). The Steam store page lists "Overwhelmingly Positive" (https://store.steampowered.com/app/239820/game_dev_tycoon/).
- Greenheart Games reported that the iOS version reached about 66,520 units and about $241K in proceeds. Featured placement drove a sharp spike (Tier A, developer blog snippets, https://www.greenheartgames.com/press).

### 5.3 Software Inc

Searches did not yield a development postmortem or a design analysis of Software Inc. The only substantive coverage was a 2015 PC Gamer playthrough column (https://www.pcgamer.com/running-a-games-company-into-the-ground-in-software-inc). Treat Software Inc's design points as unverified in this document, and check the Steam page and the developer's site directly.

### 5.4 Big Ambitions

- A New York business sim by Hovgaard Games, a four-person studio. It entered Early Access on March 10, 2023, and reportedly passed 100K copies, then 150K (Tier B, press release: https://gamespress.com/Big-Ambitions-Launches-March-2023 and a later press release at https://thegg.net/press-releases/the-business-sim-sandbox-rpg-big-ambitions-has-now-sold-over-150k-copies-since-its-release/).
- Version 1.0 landed August 28, 2026, adding The Hamptons, luxury mansions, chauffeurs, golf, tennis, food delivery, and simpler business management (Tier B, https://www.pcgamesn.com/big-ambitions/1-0-tycoon-life-sim).
- Design note: a poorly calibrated supply chain can sink a shop within a few in-game days, and the character has needs (sleep, health, happiness) to balance alongside the business (Tier C, search summary). That is a "pressure to manage many coupled systems" pattern.
- No news feed or event calendar detail was found (Tier C gap).

### 5.5 Rivals and narrative hooks

- **Dwarf Fortress legends and emergent story:** a history is procedurally generated at world creation and continues during play. Players mine it for stories. Tarn Adams frames the design as breaking narrative into systems so players write it through play (Tier B/C, Adams's chapter on characterization, and GDC-related summaries). RimWorld adopted this framework (Tier C).
- **Hades keepsakes:** the relationship system rewards players with items that change how they play, so the reward is also characterization (Tier C, critical analyses on mechanicsofmagic.com and benjaminglover.substack.com). Quarter to Three argues the game keeps players going by always hinting at the next reward (Tier C). Greg Kasavin said reactivity was a narrative goal, with many moments where the game seems to notice the player (Tier C, interview summary).
- **Game Informer on simulation games as narrative machines:** a 2016 feature argues players tell their own stories through systems (https://gameinformer.com/b/features/archive/2016/11/25/letting-players-tell-the-story-simulation-games-as-narrative-machines). Tier B.
- **Paperclips' existential frame:** Lantz uses the clicker mechanic to make the player experience being compelled by an arbitrary goal (Tier C, search summary). The narrative escalates with the numbers.

**Practical design pattern:** a rival lab's release creates a headline. The headline's content reflects the rival's state (their last model, their hype, their scores), so the news feed is a readout of simulation state, not random filler. This is the Dwarf Fortress "history generator" idea applied to a rival economy.

---

## 6. Ranked feature ideas for an AI-lab tycoon

Scoring: **Fun** (1 low to 5 high) and **Effort** (1 low to 5 high). Ranked by Fun minus Effort, then by Fun. Sources in brackets show what each idea is adapted from.

| Rank | Idea | Fun | Effort | Inspiration |
|---|---|---|---|---|
| 1 | **Review-score reveal after each release**, with a breakdown: capability, safety, cost, hype. Animated tally. | 5 | 2 | Game Dev Tycoon review scores; the opacity critique is the lesson to fix |
| 2 | **Benchmark tally reveal**: each eval is a card that flips, with a count-up number and a tick | 5 | 2 | Balatro scoring layers; Hearthstone reveal |
| 3 | **Training run as a loss curve** that animates down, with plateau and breakthrough events | 4 | 2 | Cookie Clicker growth curve; Paperclips rising-number pleasure |
| 4 | **Hype meter** driven by marketing spend and prior model score; sequel bonus at 8+/10 | 4 | 2 | Game Dev Tycoon hype and sequel rule |
| 5 | **Rival headline feed** generated from rival state (their last release, scores, hype), not random | 5 | 3 | Dwarf Fortress legends; Big Ambitions feed (gap) |
| 6 | **Generation prestige (Gen 1 -> Gen 2)** with a permanent research currency and a new bonus category per generation | 5 | 3 | Cookie Clicker chips and multipliers |
| 7 | **Welcome-back report** on return: "While you were away, 2 runs finished, 1 model released, rival took #2" | 5 | 2 | Idle welcome-back screen |
| 8 | **Capped offline training** with taper (full rate for 8-12 h, then reduced) | 4 | 2 | Offline cap debates; DataStore timestamp approach |
| 9 | **Compute budget choice** (spend on training vs inference vs hiring) with tradeoffs visible | 4 | 3 | Software Inc style resource tension; Big Ambitions supply chain |
| 10 | **Random events with a response choice**: GPU shortage, dataset leak, viral jailbreak, regulator letter, talent poaching | 4 | 3 | Game Dev Tycoon events (fix the predictability critique by making responses matter) |
| 11 | **Alignment dilemma milestones**: at set points, a choice trades speed for safety, with a visible consequence | 5 | 3 | Universal Paperclips escalation; Hades narrative hooks |
| 12 | **Model naming and lineage tree** showing what descends from what | 3 | 2 | Dwarf Fortress legends; Hades keepsake identity |
| 13 | **Staff specialists** (research, data, infra, safety) with fatigue and specialties | 3 | 3 | Game Dev Tycoon staff specialization and fatigue |
| 14 | **Dataset curation mix** with a pie chart that updates; wrong mixes produce visible failure modes | 4 | 3 | Simulation-as-narrative; Factorio optimization satisfaction |
| 15 | **Rival labs with personalities** and release cadence (scripted, deterministic from a seed) | 4 | 3 | Big Ambitions world; Dwarf Fortress systemic characters |
| 16 | **Critic score vs user score split**: critics review quality, the "community" reacts to hype | 3 | 2 | Metacritic critic/user split in Game Dev Tycoon |
| 17 | **Model card reveal** with rarity tiers and a card-flip animation | 3 | 2 | Hearthstone opening; Balatro reveal |
| 18 | **Daily AI news digest** generated from sim state; one story per day | 3 | 2 | Roblox daily engagement pattern (without fixed-interval fatigue) |
| 19 | **Ablation experiments**: toggle one component, see what changed, unlock a paper | 4 | 4 | Scientific-method framing; Universal Paperclips market-sim depth |
| 20 | **Milestone achievements** as Roblox badges with unlock toasts | 2 | 1 | Roblox badges (Tier C, feature exists) |
| 21 | **Ghost/friend comparison** of model scores (optional, async, opt-in) | 3 | 3 | Leaderboard pressure without forced multiplayer |
| 22 | **Pacing "wall" detector**: if progress stalls for 10 minutes, offer a visible next goal | 3 | 2 | Churn prevention from postmortem advice (Tier C) |
| 23 | **Gacha-style compute cards with disclosed odds** | 2 | 3 | Roblox paid random items policy requires disclosure; avoid if possible |
| 24 | **Interpretability terminal** where the player inspects a model's outputs and finds quirks | 4 | 4 | Dwarf Fortress emergent stories; Hades narrative reactivity |

**Top 5 to build first:** review-score reveal, benchmark tally, loss-curve training, rival headline feed, welcome-back report. Together they cover the short loop (juice), the medium loop (release verdict), and the offline/return loop.

**Watch-outs:**

- Hide nothing the player needs to compute (Balatro GMTK critique).
- Make random events responsive, not scripted (Game Dev Tycoon critique).
- Explain every score (Game Dev Tycoon opacity critique).
- Do not let rebirth bonuses feel trivial (creation.dev rule of thumb).
- Keep monetization cosmetic or convenience-based, and disclose odds for any random sales (Roblox policy).

---

## 7. Open questions and gaps

1. **Unverified sources:** the Destructoid, GameSpot, Cubix, Gamedeveloper "math of idle," and Eric Guan idle-design pages were not reachable. Add those hosts to the session allowlist and re-verify the specific numbers in sections 4 and 5.
2. **No Software Inc design analysis found.** Need the developer's postmortems or Steam forum threads.
3. **No Big Ambitions news-feed analysis found.** Check the official site news page (https://www.bigambitionsgame.com/news) directly.
4. **Juice talk content not read.** GDC Vault pages require a login or video. A transcript or detailed summary would firm up section 3.
5. **Retention benchmarks are vendor-sourced.** Instrument our own cohorts early.
6. **Universal Paperclips postmortem not found.** Lantz interviews and the game at decisionproblem.com are the next sources to try.
7. **No AI-rival news-feed design precedent found.** This is an original area. Generative Agents (Stanford) is a possible technical reference for rival behavior, but it is not a game-design source.

---

## 8. Source index

Roblox official (Tier A):
- Retention: https://create.roblox.com/docs/en-us/production/analytics/retention
- Analytics overview: https://create.roblox.com/docs/production/analytics
- Engagement rewards: https://create.roblox.com/docs/en-us/resources/feature-packages/engagement-rewards
- Passes: https://create.roblox.com/docs/en-us/production/monetization/passes.md
- Paid random items: https://create.roblox.com/docs/en-us/production/monetization/paid-random-items

Roblox community (Tier C):
- DevForum algorithm update thread: https://devforum.roblox.com/t/boost-your-discovery-with-the-improved-recommended-for-you-algorithm-and-analytics-for-creators/3587441
- DevForum offline earnings: https://devforum.roblox.com/t/how-to-make-an-offline-earning-system/3761245
- DevForum new-user first-session retention: https://devforum.roblox.com/t/analytics-new-user-first-session-retention-new-and-returning-users/2890832

Roblox analysis (Tier C, vendor blogs):
- RoWatcher retention benchmarks: https://rowatcher.com/news/retention-benchmarks-by-roblox-genre-what-good-actually-looks-like
- RoWatcher D1/D7: https://rowatcher.com/news/d1-is-a-platform-problem-d7-is-a-design-problem
- RoWatcher core loop: https://rowatcher.com/news/the-core-loop-mistake-killing-most-roblox-games
- RoWatcher daily login critique: https://rowatcher.com/news/reward-schedules-in-roblox-why-daily-login-bonuses-backfire
- RoWatcher idle mechanics on Roblox: https://rowatcher.com/news/the-afk-revolution-how-idle-mechanics-conquered-roblox
- RoWatcher tycoon genre: https://rowatcher.com/news/tycoon-games-the-genre-that-built-roblox-and-still-hasn-t-peaked
- RoLearn tycoon monetization case: https://rolearn.dev/case-studies/tycoon-monetization-overhaul

Game references:
- Game Dev Tycoon Steam: https://store.steampowered.com/app/239820/game_dev_tycoon/
- Game Dev Tycoon Metacritic: https://www.metacritic.com/game/game-dev-tycoon/details/
- Greenheart Games press: https://www.greenheartgames.com/press
- Game Dev Tycoon iOS day-1 report (Game Developer): https://www.gamedeveloper.com/business/game-dev-tycoon-ios-release-day-1-report-a-rough-start
- Game Dev Tycoon GameSpot user review (not reachable): https://www.gamespot.com/game-dev-tycoon/user-reviews/2200-12552441/
- Game Dev Tycoon Destructoid review (not reachable): https://www.destructoid.com/reviews/review-game-dev-tycoon/
- Software Inc (PC Gamer 2015): https://www.pcgamer.com/running-a-games-company-into-the-ground-in-software-inc
- Cookie Clicker prestige: https://cookieclicker.wiki.gg/wiki/Prestige
- Universal Paperclips (Wikipedia): https://en.wikipedia.org/wiki/Universal_Paperclips
- Big Ambitions 1.0 (PCGamesN): https://www.pcgamesn.com/big-ambitions/1-0-tycoon-life-sim
- Big Ambitions press (Gamespress): https://gamespress.com/Big-Ambitions-Launches-March-2023
- Big Ambitions 150K press: https://thegg.net/press-releases/the-business-sim-sandbox-rpg-big-ambitions-has-now-sold-over-150k-copies-since-its-release/
- Big Ambitions news: https://www.bigambitionsgame.com/news
- Mini Motorways (Game Developer, not reachable): https://gamedeveloper.com/audio/-i-mini-motorways-i-and-the-delicate-art-of-marrying-complexity-and-minimalism
- Game Informer, Mini Motorways review: https://www.gameinformer.com/review/mini-motorways/contemplative-commute
- Vampire Survivors (Substack): https://jboger.substack.com/p/the-secret-sauce-of-vampire-survivors
- Vampire Survivors, Conversation/TechXplore summary: https://techxplore.com/news/2023-04-vampire-survivors-gambling-psychology-bafta-winning.pdf
- Hades keepsakes (Mechanics of Magic): https://mechanicsofmagic.com/2025/11/04/loops-and-arcs-in-hades/
- Hades narrative (Benjamin Glover): https://benjaminglover.substack.com/p/why-hades-was-a-success
- Hades II (AV Club): https://www.avclub.com/hades-ii-divided
- Balatro juice (Blake Crosley): https://blakecrosley.com/guides/design/balatro
- Balatro cursed design (GMTK): https://gmtk.substack.com/p/balatros-cursed-design-problem
- Hearthstone and loot-box psychology (PC Gamer): https://www.pcgamer.com/behind-the-addictive-psychology-and-seductive-art-of-loot-boxes/
- Simulation games as narrative machines (Game Informer): https://gameinformer.com/b/features/archive/2016/11/25/letting-players-tell-the-story-simulation-games-as-narrative-machines
- Dwarf Fortress / Adams characterization PDF: https://wileywiggins.com//documents/dorf/Adams%20-%20Characterization%20and%20Emergent%20Narrative%20in%20Dwarf%20F.pdf
- Dwarf Fortress / Short and Adams 2019 PDF: https://wileywiggins.com//documents/dorf/Short%20and%20Adams%20-%202019%20-%20Procedural%20storytelling%20in%20game%20design.pdf

Juice and game feel:
- GDC Vault, Juice It or Lose It: https://gdcvault.com/play/1016487/Juice-It-or-Lose
- Game Developer, juice summary (not reachable directly): https://gamedeveloper.com/design/video-indies-resist-the-urge-to-juice-it-or-lose-it-
- Hicks et al. DiGRA 2018 (verify link): https://dl.digra.org/index.php/dl/article/download/793/793

Idle design (search snippets only, pages not reachable):
- Eric Guan, Idle Game Design Principles: https://ericguan.substack.com/p/idle-game-design-principles
- Game Developer, The Math of Idle Games Part III: https://gamedeveloper.com/design/the-math-of-idle-games-part-iii
- DEV Community, "I built 7 idle games in 30 days": https://dev.to/aguier/i-built-7-idle-games-in-30-days-what-i-learned-about-incremental-design-5d3f
