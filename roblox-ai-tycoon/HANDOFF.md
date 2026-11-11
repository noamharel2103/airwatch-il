# HANDOFF: full context for the next conversation

> Read this whole file first, then `docs/design/00-player-vision.md`. It holds everything the owner asked for in the first planning session (2026-11-11), so nothing gets lost.

## 1. What we're building
- A **Roblox game** where you run an **AI company**: train LLMs, release them, compete against the AI labs, and grow from a small startup into one of the biggest companies in the world.
- It is a **private game for the owner to play solo.** It might be released publicly some day, but not now.
- Reference games:
  - **Start an AI Company** (Roblox, Kairo Experiences, Oct 2026): use it as the base for mechanics and improve on it.
  - **Build a Phone Empire** (Roblox): copy the idea of its time system.
- Use the reference game's mechanics, but give the game **its own name and visual style**. Do not copy its assets.

## 2. Owner's rules (do not break)
1. **Never use Fable models.** Only Opus, Sonnet or Haiku for subagents.
2. **Subagents do research only, never code.** The owner said this explicitly. The main session may write design docs, and code when the owner asks for it.
3. The owner wants **very, very deep research** and is fine with many agents.
4. **Repo:** `noamharel2103/airwatch-il`, branch `claude/blissful-tesla-86xnws`.
   - The old "airwatch" project is unused. It was deleted from this branch only; `main` is untouched.
   - Everything for the game lives in `roblox-ai-tycoon/`.
5. Commit and push every change to that branch.
6. The owner writes in Hebrew. Answer in Hebrew.

## 3. What the owner wants in the game
### General
- **Fun first.**
- **Fairly easy, but not trivial.** After **1–2 hours** of play you should be among the top AI companies in the world.
- **Realistic:**
  - Salaries, company money, funding and valuations match reality.
  - GPU and hardware prices match the in-game year.
- **Real competitor companies:** OpenAI, Anthropic, Google DeepMind, Meta, xAI, Mistral, DeepSeek, Qwen and others.
  - They release their **real models on the real dates** from 2023, then plausible future models.
  - Keep all lab and model names in one table so they can be switched to parody names if the game is ever published.
- **A decent starting budget** to hire developers. (A realistic 2023 AI seed round was about $3.4M at a $16M valuation.)

### Time system (like Build a Phone Empire)
- The game **starts January 2023**. Hardware, prices, models and competitors always match the in-game date, and time keeps moving into the future (2027–2035+).
- **The date is always shown at the top right.**
- **Speed controls:** pause, x1, x2, x4. Faster is riskier: things can break or go wrong if you aren't watching (outages, staff poached, failed training runs, missed events).
- **Pacing proposal:** about 2 minutes of real time per in-game month at x1, so 2023 to late 2026 takes about 1.5 hours.

### World and office
- A **bigger office** than in the reference game, which grows over time.
- **Most employees are not visible.** You **talk to them through the computer** (a Slack-style chat app). A few key people can be visible.
- **The computer is the hub for everything.** It has a desktop with apps. The reference game's retro style is OK, but ours should look more polished.
- **Still open:** the owner was about to send an image of how the office should look and how the player sees it ("you don't always see it from inside, there's something special"). **Ask for the image.**

### Screens and systems
- **Title screen:** save slots ("folders") for several companies. The reference shows 3 folders: an existing company ("Stage 3 · funded startup · Worth $4M") and "New company — start in your bedroom".
- **Daily goals with cash rewards.** The reference shows them on a corkboard: "Train a Medium model", "Collect what your AI earned", "Launch with tech reviewers ×2".
- **Lab → Train:**
  - What the owner dislikes in the reference: you pick one option per category (Size S/M/L, Data Web/Books/Code/Chats, Personality Friendly/Clever/Quick).
  - What we want instead: **many options, multi-select and mixes.** For example a data mix in percentages, architecture (dense/MoE), context length, several post-training stages (SFT, RLHF, RL/reasoning), safety, tools/agents, multimodal, distillation and quantization.
  - Full catalog: `docs/research/10-training-options.md`.
- **Lab → Models:**
  - List of all your models with score, user count and an **Update** button. Updates can make a model smarter or add features, and we want **many more options** than the reference (vision, voice, tools, long context, reasoning mode, agents, a cheaper/faster distilled version and more).
  - **Benchmarks against other models**, including the real ones, plus a leaderboard.
- **Consumer app** for your AI (like the Claude app), with subscription plans, users and features.
- **Lab → Research:** a research tree.
- **Parts (hardware):**
  - What the owner dislikes in the reference: unrealistic prices and it isn't fun.
  - What we want: real hardware for the current year (A100, H100, H200, B200, GB200, Rubin and later), real prices, and cloud rental vs buying. It must be fun.
- **Bank:**
  - Company valuation, setting your AI's price, **investors** offering money for equity, and a **balance** of income vs costs.
  - It must **look good**: charts and investor cards.
- Other reference apps: Team, Furnish, Mail, Goals, Company.

### Release reactions (the owner's top priority)
- When you release a model, people's reactions must be **realistic and really good**: social media posts, Reddit, Hacker News, press headlines, benchmarks revealed one by one, Arena Elo, controversies (jailbreaks, contamination accusations), outages from demand, and effects on users and revenue.
- Design v0.1 is in `docs/design/01-reactions-system.md`: 23 triggers, 16 personas, launch phases, about 120 templates, and the effect on gameplay.
- **Still to do:** upgrade it to v0.2 with **600+ templates** using reports 04 and 11.

## 4. What's in the repo now (`roblox-ai-tycoon/`)
| File | Contents |
|---|---|
| `HANDOFF.md` | This file |
| `docs/design/00-player-vision.md` | The owner's vision from the screenshots and notes |
| `docs/design/01-reactions-system.md` | Reactions system design v0.1 |
| `docs/research/01-reference-game.md` | Start an AI Company: mechanics, facts, 25 opportunities to improve |
| `docs/research/02-fun-and-retention.md` | What makes tycoon games fun: 24 ranked feature ideas |
| `docs/research/03-roblox-dev-ecosystem.md` | Tooling and libraries: Rojo 7.7, Rokit, Wally, ProfileStore, Vide/Fusion, Jest-Lua+Lune; avoid Knit, TestEZ, Roact, DataStore2 |
| `docs/research/04-real-model-releases.md` | 52 real launches 2019–2026, a reception model with formulas, 150+ templates |
| `docs/research/05-ai-industry-economics.md` | Scaling laws, hardware, data, business, talent, about 40 events, 12 formulas |
| `docs/research/06-competitor-games.md` | Competing games, gaps, 35 ideas |
| `docs/research/07-roblox-ai-tooling.md` | Built-in Studio MCP, the Claude Code plugin, TextGenerator, a 29-step Windows workflow |
| `docs/research/08-salaries-and-finances.md` | Salaries by role and year, lab finances, API prices; ready Lua table in §5 |
| `docs/research/09-labs-models-hardware-timeline.md` | About 150 real releases Jan 2023–Nov 2026, profiles of 15 labs plus a rival-traits table, GPUs and prices by year, projections to 2035 |
| `docs/research/10-training-options.md` | 100+ training options in 11 stages, 39 "what goes wrong" events |
| `docs/research/11-online-reactions.md` | 20 personas, a trigger-to-reaction matrix, timing, engagement realism, memes |

**Research caveat:**
- Network access was limited: roblox.com, reddit.com, youtube.com and most sites were blocked, and the shared search budget ran out. Most facts therefore come from search-result summaries.
- Every report tags each fact as verified, background knowledge, estimate or disputed.
- 2026 numbers are the weakest.

## 5. Connecting to Roblox Studio (the owner's computer, Windows)
The cloud session cannot connect, because it doesn't run on the owner's computer. On the PC:
1. Open Roblox Studio and go to **Assistant → Manage MCP Servers**. Check the server is enabled.
2. Clone the repo:
   ```
   git clone -b claude/blissful-tesla-86xnws https://github.com/noamharel2103/airwatch-il.git
   cd airwatch-il
   ```
3. Add the MCP server:
   ```
   claude mcp add --transport stdio Roblox_Studio -- "cmd.exe" "/c" "cd /d %LOCALAPPDATA%\Roblox && .\mcp.bat"
   ```
4. Run `claude`, then `/mcp`. It should show `Roblox_Studio` as connected.
5. Optional: Roblox's official plugin `Roblox/roblox-studio-agent-plugin`, installed via `/plugin`.

## 6. Open questions for the owner
- [ ] The office image: how it should look and how the player sees it.
- [ ] The owner wrote "there's also a game called…" and the message was cut off. Which game?
- [ ] Final game name. None chosen yet; it must be original.

## 7. Next steps (suggested order)
1. Get the office image and the missing game name.
2. Merge the 11 reports into a full GDD (`docs/GDD.md`): screens, economy, time, training, models, product, bank, rivals, events.
3. Reactions v0.2 with 600+ templates.
4. Config data tables:
   - real timeline of labs and models
   - GPUs by year
   - salaries
   - training options
   - events
5. Once the owner approves:
   - Rojo project scaffold
   - code for the time system and computer OS
   - code for Lab/Train, Models and the release sequence
   - code for Bank and Parts
