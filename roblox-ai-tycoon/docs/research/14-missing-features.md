# AI Company Tycoon: Missing Features (ranked)

Goal: after "best company in the world" there is nothing to do. These are the features that long-term management and tycoon games use to keep players going, ranked by impact on endgame depth.

Note on sources: the searches returned mostly forum posts, aggregator pages and SEO guides. Claims marked (general) come from common genre knowledge, not a specific source. Specific numbers are examples, not tested values.

## Ranked list

### 1. Prestige / "Go Public Again" reset (medium)
- **What:** A voluntary reset of most progress (company, cash, offices) in exchange for permanent legacy points that multiply future runs or unlock starting perks.
- **Who does it well:** Cookie Clicker (ascension / heavenly chips), AdVenture Capitalist (Pecorella's own design), Realm Grinder (layered abdicate / reincarnate / ascend).
- **Why players love it:** Each run is faster than the last, and the player chooses the moment to reset, which turns the endgame into a new loop instead of a finished one.
- **How it could work here:** When the company reaches "Best in the World", offer "Found a New Company" in 2023 again. Keep legacy points (earned from achievements, rivals bought, AGI milestones) that buy starting perks: a head start on research, a free GPU batch, a loan that never defaults. The first reset should be reachable in a few hours, later tiers take longer.
- **Sources:** https://gamedeveloper.com/design/the-math-of-idle-games-part-iii ; https://en.wikipedia.org/wiki/Incremental_game ; https://tapdynasty.pages.dev/how-does-prestige-work/ (fan guide)

### 2. Rival AI companies that compete for the market (big)
- **What:** Several AI rivals with their own models, hiring, funding and launch schedules. They release products, poach staff and can beat you to a benchmark.
- **Who does it well:** Software Inc (simulated market where rivals ship products and can overtake you; the market is randomized each run).
- **Why players love it:** The game never stops being a race. A win is only meaningful while someone is chasing you.
- **How it could work here:** Make 4 to 6 rival labs with personalities (safety-first, speed-first, cheap clones, big-tech buyout). They take cards from your launch calendar, leak staff, and can buy the company you were about to buy. Your goal shifts from "be first" to "stay first".
- **Sources:** https://gamingrespawn.com/?p=581 (review, competitors mention) ; https://store.steampowered.com/app/362620/Software_Inc

### 3. Long multi-branch tech tree with a deep late game (medium)
- **What:** A research tree with several branches (models, chips, safety, infrastructure, robotics) that never fully ends. Late tiers are expensive and add new decisions, not just bigger numbers.
- **Who does it well:** Factorio (infinite research, ever-more-expensive science, Space Age as a new layer). Game Dev Tycoon (research unlocks that carry to custom engines).
- **Why players love it:** There is always a next node to plan for, and the choice of branch changes how you play.
- **How it could work here:** Add a second tree for "Frontier" topics (AGI alignment, quantum compute, space data centers) that only opens after the first best-company goal. Each tier changes a rule (e.g. new model class needs its own safety review).
- **Sources:** https://forums.factorio.com/viewtopic.php?p=347639 ; https://game-platform-web-5a2.pages.dev/en/factorio/guides/endgame (third-party guide) ; https://forum.greenheartgames.com/t/end-game-content-and-future-of-game-dev-tycoon/489

### 4. Public company mode: shareholders, quarterly earnings, stock price (medium)
- **What:** Going public creates a stock price and quarterly targets from a board. Missing targets costs you the CEO seat or triggers a hostile takeover attempt.
- **Who does it well:** Capitalism Lab (KPI pressure and long-term planning focus, per developer site). Big Ambitions uses goals and wealth tiers (general).
- **Why players love it:** It adds a second clock (earnings) on top of the research clock, so the endgame has pressure again.
- **How it could work here:** After IPO, every quarter has a target (revenue, safety score, user growth). Buybacks, dividends or stock splits become spending options. A hostile-takeover event lets rivals or the government try to buy you.
- **Sources:** https://www.capitalismlab.com/?p=8 ; https://www.gamestar.de/artikel/radikalste-wirtschaftssimulation-begeistert-angewidert,3398694.html (critical take on KPIs)

### 5. Market eras and world shocks that change the rules (small to medium)
- **What:** Years or eras (AI winter, compute shortage, energy crisis, "AGI race") that change prices, demand and rules for a fixed period.
- **Who does it well:** Big Ambitions (unexpected events force strategy changes; developer credits this for replayability).
- **Why players love it:** Your old plan stops working and you must adapt. Replayability comes from the events, not the map.
- **How it could work here:** A random event deck per era: GPU prices triple, a chip fab burns down, a country bans training runs over X FLOPs, a viral model makes a niche category hot. Events are scheduled with seeds so runs differ.
- **Sources:** https://primagames.com/reviews/big-ambitions-review ; https://www.gameskinny.com/?p=83169 (critique: grind, repetitive loop)

### 6. Regulation and lobbying (medium)
- **What:** Governments pass rules (safety testing, data laws, export limits, model licensing) that you can comply with, fight with lobbying money, or dodge by moving offices.
- **Who does it well:** Capitalism Lab (policy and industry pressure, general). Lobbying systems in Victoria-style sims (general).
- **Why players love it:** Political systems create a second game beside the tech game and make your choices feel bigger.
- **How it could work here:** The existing government shutdown becomes part of a policy track. Lobby points buy delays, carve-outs, or public trust. A failed safety law leaves you with a fine and a public scandal.
- **Sources:** https://www.capitalismlab.com/?p=693 (challenge modes, general)

### 7. Safety and trust reputation track with real trade-offs (medium)
- **What:** A public trust score that goes down with hacks, leaks, bias scandals and layoffs, and up with safety research and open-source releases. Low trust closes markets and triggers audits.
- **Who does it well:** Not directly in a single game above. Closest: the outage and hack loop already in the game plus the reputation systems in Software Inc (general).
- **Why players love it:** It makes "doing it the right way" a real choice rather than a checkbox, and it gives the late game a moral dimension.
- **How it could work here:** Every model launch asks for a safety budget. Skipping it is faster but raises the odds of a scandal event. Trust unlocks government contracts and certain endgame projects.
- **Sources:** https://yukaichou.com/gamification-analysis/endgame-design-veteran-retention/ (endgame should give new motivations)

### 8. Endgame megaprojects (big) — the "rocket" for this game
- **What:** Huge, repeatable projects that take many in-game months and many systems at once: a 1 GW data center campus, a national-scale compute cluster, a moon-based training site, the first AGI system.
- **Who does it well:** Factorio's rocket launch as a finish line, which players then repeat with their own goals (the rocket is the built-in finish line, after which players mostly set their own).
- **Why players love it:** A project that needs everything you've built at once is the best possible "final exam". Doing it again, bigger, is fun.
- **How it could work here:** Megaprojects need power contracts, cooling, chips, staff and a launch approval. Each one has a score, and the best scores go on a leaderboard. Make them repeatable with rising difficulty.
- **Sources:** https://forums.factorio.com/viewtopic.php?p=462751 ; https://forums.factorio.com/viewtopic.php?p=347681

### 9. Named talent system with poaching (medium)
- **What:** Each hire is a named person with traits (speed, safety, morale, specialty), a salary and loyalty. Rivals can poach them.
- **Who does it well:** Software Inc (staff and team management is a core system). Game Dev Tycoon (staff skills, general).
- **Why players love it:** Individual people become characters you remember. Losing a star engineer hurts.
- **How it could work here:** Stars can be recruited, trained, given a title, and leave for rivals or start their own lab (which then competes with you, linking to #2).
- **Sources:** https://store.steampowered.com/app/362620/Software_Inc (general)

### 10. Product line and portfolio (big)
- **What:** Several products (chatbot, coding agent, image model, robot, self-driving car, assistant device) that share infrastructure and each have their own market.
- **Who does it well:** Software Inc (multiple teams and projects at once, per a reference-game analysis). Mad Games Tycoon 2 (several game types to make).
- **Why players love it:** You have to balance attention across products, and each one can fail on its own.
- **How it could work here:** Each product has a lifecycle (launch, growth, decline, sunset). Models you already trained can be reused in a new product at a discount.
- **Sources:** https://store.steampowered.com/app/1342330 ; https://gamasutra.com/design/what-should-we-do-with-mediocre-gameplay-depth-in-management-games- (critique of shallow depth)

### 11. Compute infrastructure depth: data centers, power, cooling (big)
- **What:** Your GPUs go into data centers you build, with power capacity, cooling, networking and location (cheap power vs. close to users).
- **Who does it well:** Factorio (resource logistics as depth). Capitalism Lab (infrastructure and supply chain, general).
- **Why players love it:** A real logistics puzzle. Players enjoy solving bottlenecks.
- **How it could work here:** Replace the box-of-GPUs flow with rack slots, power grid MW, and cooling tiers. Power contracts are a late-game market.
- **Sources:** https://forums.factorio.com/viewtopic.php?p=151832 (end game theory and ideas, general)

### 12. Vertical integration: own chip fab and suppliers (big)
- **What:** Build or buy a chip fab, power plant, or data center operator, and sell capacity to rivals.
- **Who does it well:** Capitalism Lab (supply chain and ownership depth, general). Factorio (building the whole chain).
- **Why players love it:** Owning the supply chain is a satisfying late-game power move.
- **How it could work here:** Late-game buy options for suppliers. Owning them lowers your costs but adds fixed upkeep and makes you a target for regulation.
- **Sources:** https://www.capitalismlab.com/?p=9537

### 13. Hostile takeovers, mergers and antitrust (medium)
- **What:** Beyond buying rivals, you can make hostile bids, merge with rivals, or be investigated for antitrust if you own too much.
- **Who does it well:** Capitalism Lab (corporate deals, general). Big Ambitions and Software Inc have acquisition-style decisions (general).
- **Why players love it:** Corporate drama and scheming.
- **How it could work here:** A hostile bid needs stock buys over several days. Antitrust review can split your company or block a deal.
- **Sources:** https://www.capitalismlab.com/?p=9537 (general)

### 14. Espionage, sabotage and leaks (medium)
- **What:** Rivals can steal your research (lower cost for them), leak your model weights, or sabotage a launch. You can run counter-intelligence.
- **Who does it well:** Software Inc has competitor interference in the market (per review). Hacking theme is the existing outage/hack loop.
- **Why players love it:** Raises stakes and reuses the existing hack event system.
- **How it could work here:** Use the existing hack event as the entry point. Add a security budget and a "red team" staff role.
- **Sources:** https://gamingrespawn.com/?p=581 (general)

### 15. Scenario and challenge modes (small)
- **What:** Fixed challenge setups with modifiers ("no GPUs for 2 years", "start in 2035 with 1 employee", "no loans", "safety-only company").
- **Who does it well:** Mad Games Tycoon 2 (start years 1976 to 2020 and scenarios), Game Dev Tycoon (mods extended lifespan).
- **Why players love it:** Quick new goals with a clear win condition. Easy to share results.
- **How it could work here:** A "Challenge" menu with 10 to 20 modifier sets, each with a leaderboard. Cheap to build because it is just config.
- **Sources:** https://store.steampowered.com/app/1342330 ; https://vaporlens.app/app/239820/game_dev_tycoon/stats

### 16. Sandbox after victory with a legacy score (small)
- **What:** After the win, unlock a free sandbox with no goal, plus a stored "legacy score" that compares runs.
- **Who does it well:** Satisfactory and Oxygen Not Included (self-defined success after victory, per forum posts). Mad Games Tycoon 2 (freeplay mode, per aggregator).
- **Why players love it:** Players set their own targets once the game stops telling them what to do.
- **How it could work here:** Keep the existing time speeds. Add a run history page: total revenue, safety score, number of rivals bought, time to #1.
- **Sources:** https://forums.factorio.com/viewtopic.php?p=347596 ; https://www.gamestar.de/artikel/radikalste-wirtschaftssimulation-begeistert-angewidert,3398694.html

### 17. Achievement-based permanent unlocks across runs (small)
- **What:** Achievements unlock permanent bonuses or cosmetics that carry into the next company (not just a badge).
- **Who does it well:** Game Dev Tycoon (research carries over into custom engines, per fan wiki). Cookie Clicker achievements that add multipliers.
- **Why players love it:** Each achievement feels useful and gives a reason to try new things.
- **How it could work here:** Tie every goal to a permanent perk, for example "Own 5 rivals: rivals start 10% weaker in every future run."
- **Sources:** https://sites.google.com/ecsd.us/fluffs-store/wiki/game-dev-tycoon-2-0-wiki (fan wiki)

### 18. Staff culture, morale and burnout (medium)
- **What:** Morale depends on overtime, pay, perks and team size. Low morale causes quits, slower work, and leaks.
- **Who does it well:** Software Inc (staff management depth, general). Game Dev Tycoon (team balance, general).
- **Why players love it:** Makes the people part of the game, not just a count.
- **How it could work here:** The existing outage fix work costs morale. Add a "crunch" button with a payoff and a cost.
- **Sources:** https://store.steampowered.com/app/362620/Software_Inc (general)

### 19. Idle offline earnings with a catch-up choice (small)
- **What:** While the game is closed, the company earns, with a cap, and the player chooses to collect or reinvest on return.
- **Who does it well:** Idle games generally (Cookie Clicker, AdVenture Capitalist).
- **Why players love it:** Coming back to a result is rewarding.
- **How it could work here:** Only if the game is designed for return visits. Use this only with the time system (x1, x2, x4) already in place.
- **Sources:** https://en.wikipedia.org/wiki/Incremental_game

### 20. Long-run score and leaderboards with friends (small)
- **What:** Global or friends leaderboards for net worth, safety score and time to #1 per challenge.
- **Who does it well:** Most tycoon and idle games (general). Roblox-native leaderboards via OrderedDataStore.
- **Why players love it:** Competitive pride with no extra content needed.
- **How it could work here:** Pair with challenge modes (#15) so each challenge has a board.
- **Sources:** https://devforum.roblox.com/t/how-to-make-your-game-have-replayability/1082534 (general)

## Top picks to build first
1. Prestige / new company reset (#1), the single biggest long-term hook.
2. Rival AI labs (#2), turns the win into an ongoing race.
3. Megaprojects (#8), a repeatable finish line.
4. Market eras and world shocks (#5), cheap and makes each run different.
5. Challenge modes (#15) and sandbox with legacy score (#16), cheap, extend the game with config.

## Design rules from the sources
- Endgame should add new decisions and roles, not just harder numbers (Yu-kai Chou; Factorio players).
- Prestige reset must feel worth it: first reset reachable in a short time, later tiers slower, tuned on real data (Roblox tycoon guides, Pecorella).
- Avoid grind loops like drive-park-restock (Big Ambitions criticism), so every new layer should change a decision, not just repeat a chore.

## Sources
- https://gamedeveloper.com/design/the-math-of-idle-games-part-iii
- https://en.wikipedia.org/wiki/Incremental_game
- https://tapdynasty.pages.dev/how-does-prestige-work/
- https://store.steampowered.com/app/362620/Software_Inc
- https://gamingrespawn.com/?p=581
- https://forums.factorio.com/viewtopic.php?p=347639
- https://forums.factorio.com/viewtopic.php?p=347681
- https://forums.factorio.com/viewtopic.php?p=347596
- https://forums.factorio.com/viewtopic.php?p=462751
- https://forums.factorio.com/viewtopic.php?p=151832
- https://game-platform-web-5a2.pages.dev/en/factorio/guides/endgame
- https://forum.greenheartgames.com/t/end-game-content-and-future-of-game-dev-tycoon/489
- https://vaporlens.app/app/239820/game_dev_tycoon/stats
- https://sites.google.com/ecsd.us/fluffs-store/wiki/game-dev-tycoon-2-0-wiki
- https://store.steampowered.com/app/1342330
- https://www.capitalismlab.com/?p=8
- https://www.capitalismlab.com/?p=693
- https://www.capitalismlab.com/?p=9537
- https://www.gamestar.de/artikel/radikalste-wirtschaftssimulation-begeistert-angewidert,3398694.html
- https://primagames.com/reviews/big-ambitions-review
- https://www.gameskinny.com/?p=83169
- https://yukaichou.com/gamification-analysis/endgame-design-veteran-retention/
- https://gamasutra.com/design/what-should-we-do-with-mediocre-gameplay-depth-in-management-games-
- https://devforum.roblox.com/t/how-to-make-your-game-have-replayability/1082534
- https://forums.factorio.com/viewtopic.php?p=347596
