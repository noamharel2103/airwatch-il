# 03 - Roblox Dev Ecosystem Research (tooling, libraries, platform facts, market, learning path)

Research date: 2026-11-11. Audience: a beginner-to-intermediate dev building an original "AI-lab tycoon" on Roblox (single-player first, maybe public later).

## 0. Method, confidence and caveats (read first)

- Sources: GitHub repo pages (fetched directly), Roblox docs / DevForum / press (via web search snippets), third-party trackers.
- **Limits hit during research**: (a) the sandbox could not resolve `create.roblox.com`, `devforum.roblox.com`, `about.roblox.com`, `rowatcher.com`, `rolearn.dev` for direct fetching, so Roblox docs content comes from search-result summaries, not full-page reads; (b) the shared web-search budget ran out after roughly 25 searches, so the final searches (UI-library comparison, YouTube/tutorial channels, Creator Hub learning path, DataStore best practices) were NOT performed. Section 8 (learning path) and parts of section 4 therefore lean on background knowledge and are marked `[unverified]`.
- GitHub star counts below are as fetched on 2026-11-11 (rounded by GitHub). The fetch tool could not show last-commit dates, so "status" is inferred from archive banners, open issue counts and release mentions. Always re-check the releases page before pinning a version.
- Third-party "stat" blogs (rowatcher, rolearn, creation.dev, .pages.dev SEO pages) are low-reliability; numbers from them are flagged.
- Numbers that Roblox changes often (DataStore budgets, DevEx rate) must be verified in the live docs before you rely on them.

---

## 1. Dev tooling

### 1.1 Summary table

| Tool | What it does | Stars | Status (late 2026) | Verdict for this project |
|---|---|---|---|---|
| [Rojo](https://github.com/rojo-rbx/rojo) | Syncs a filesystem project (Luau files + `default.project.json`) into Studio; builds .rbxl/.rbxm | 1.9k | Active. v7.7.0 (mid-2026) added `rojo syncback` and websocket/MessagePack sync; needs Rust 1.88+ to build from source | USE (core) |
| [Rokit](https://github.com/rojo-rbx/rokit) | Toolchain manager: pins versions of rojo, stylua, selene, wally, lune etc. in `rokit.toml` | 510 | Active; now the default in Roblox's dev-container template; reads `aftman.toml`/`foreman.toml` | USE |
| [Aftman](https://github.com/LPGhatguy/aftman) | Older toolchain manager | n/a | Effectively superseded; Rokit docs say Aftman's maintainer lost interest in Roblox. No formal "archived" notice found | AVOID (new projects) |
| [Foreman](https://github.com/Roblox/foreman) | Roblox's toolchain manager | 263 | Maintained, "work in progress", leans Roblox-internal | AVOID (use Rokit) |
| [Wally](https://github.com/UpliftGames/wally) | Cargo-inspired package manager + registry for Roblox | 511 | Maintained by Uplift Games (open issues 55, PRs 33); still the de-facto registry most libs publish to | USE (or pesde) |
| [pesde](https://github.com/pesde-pkg/pesde) | Package manager for Luau, multi-runtime (Roblox, Lune, plain Luau); own registry, can also consume Wally/git packages | 132 | Active (v0.7.x on crates.io) | OPTIONAL; promising but smaller ecosystem |
| [Selene](https://github.com/Kampfkarren/selene) | Lua linter in Rust | 841 | Stable; 132 open issues; Luau support exists but luau-lsp analysis covers much of the same ground | OPTIONAL |
| [StyLua](https://github.com/JohnnyMorganz/StyLua) | Deterministic Lua/Luau formatter | 2.3k | Active, v2.6.0 referenced in README | USE |
| [luau-lsp](https://github.com/JohnnyMorganz/luau-lsp) | Language server (type checking, autocomplete) for VS Code and others; companion Studio plugin gives DataModel info | 564 | Very active (1,967 commits) | USE (core) |
| [Lune](https://github.com/lune-org/lune) | Standalone Luau runtime (like Node/Deno) with Roblox-file APIs; for scripts, build tooling, tests off-Studio | 979 | Active | USE for tooling/pure-logic tests |
| [darklua](https://github.com/seaofvoices/darklua) | Code transformer/bundler (strip types, bundle, rename requires) | 249 | Active (v0.19.x referenced) | OPTIONAL (only if you need bundling) |
| [Jest-Lua (jsdotlua)](https://github.com/jsdotlua/jest-lua) | Jest port for Luau, community-maintained | 58 | Active; "battle-tested", runs only inside Roblox | USE for tests |
| [Roblox/jest-roblox](https://github.com/Roblox/jest-roblox) | Roblox's upstream Jest port | 50 | Public, 590 commits; community fork is the one the ecosystem installs from Wally | alternative |
| [TestEZ](https://github.com/Roblox/testez) | Older BDD test framework | 210 | **Archived 2024-09-14**, read-only | AVOID |
| [Argon](https://github.com/argon-rbx/argon) | Rojo-like sync tool with two-way sync, own CLI | 153 | Active (682 commits) | Alternative to Rojo; smaller community |
| [roblox-ts](https://github.com/roblox-ts/roblox-ts) | TypeScript -> Luau compiler | 1.3k | Active | Only if you already know TS; adds a layer for a beginner |
| [Moonwave](https://github.com/UpliftGames/moonwave) | Doc generator | - | Uplift | Skip |
| Studio "Script Sync" | Built-in Studio feature to edit scripts as files in external editors | built-in | Roblox said it has no plan to replace Rojo and Rojo is more mature ([DevForum early preview](https://devforum.roblox.com/t/early-preview-studio-script-sync/3257548); [docs](https://create.roblox.com/docs/scripting/sync)). 2026 status not confirmed | Fine for a zero-setup start, but Rojo is more robust |
| Pesto / RbxSync / Azul | Community sync alternatives | - | Community projects | Skip unless Rojo bothers you |

Notes and evidence:
- Rojo 7.7.0: `rojo syncback path/to/project --input file.rbxl` turns an existing place into a Rojo project, configured by `syncbackRules`; sync now uses websockets + MessagePack instead of long-polling + JSON ([release notes mirror](https://newreleases.io/project/github/rojo-rbx/rojo/release/v7.7.0), [docs.rs](https://docs.rs/crate/rojo/7.7.0)). The Studio plugin may need manual install for brand-new releases (`rojo plugin install`). Roblox's own [third-party tools page](https://create.roblox.com/docs/en-us/projects/external-tools) documents Rojo via Rokit.
- Rokit README: drop-in for Foreman/Aftman projects, faster installs, no manual link files ([README](https://github.com/rojo-rbx/rokit)); Roblox's [dev-container post](https://devforum.roblox.com/t/robloxrojo-for-dev-containers-start-developing-instantly-on-any-device/3043417) says the default toolchain manager changed from Aftman to Rokit.
- pesde vs Wally: pesde has its own registry, targets Roblox/Lune/plain Luau, and can use Wally and git sources ([README](https://github.com/pesde-pkg/pesde), [lib.rs](https://lib.rs/crates/pesde)). A known Wally pain point is that generated link modules break type resolution unless you also run `wally-package-types`; pesde installs avoid that (anecdotal, from a competitor's DevForum thread: [Forest Package Manager post](https://devforum.roblox.com/t/forest-package-manager-the-modern-package-platform-for-roblox/4766024) - note that post is promotional and also introduces a third manager, "Forest"). A 2026 recap says Roblox is also opening more of its Luau repos to Wally/Creator Store publishing ([Weekly Recap Apr 2026](https://devforum.roblox.com/t/weekly-recap-april-6-10-2026/4568634)).
- Knit's author recommends plain ModuleScripts + a thin Remote wrapper (see section 2.1), which reduces the need for heavy tooling.

### 1.2 Roblox's own agentic/AI tooling relevant to the workflow
- Studio now ships a built-in **MCP server** (Assistant menu -> Manage MCP Servers -> Enable Studio as MCP server) so Claude Code / Cursor / Codex can read the data model, create/run scripts, edit instances and playtest ([Roblox newsroom, Apr 2026](https://about.roblox.com/newsroom/2026/04/roblox-studio-going-agentic), [DevForum announcement](https://devforum.roblox.com/t/studio-mcp-server-updates-and-external-llm-support-for-assistant/4415631)). The older open-source server is [Roblox/studio-rust-mcp-server](https://github.com/Roblox/studio-rust-mcp-server). Community MCP servers also exist (e.g. `robloxstudio-mcp`) - vet before running; they can execute code in your place.
- A reported Aug 2026 MCP update adds new tools picked up after client restart ([MoguraVR, JP](https://www.moguravr.com/roblox-studio-mcp-server-agentic-update/)) - single secondary source.

### 1.3 Recommended stack (beginner-friendly, low-regret)

1. **VS Code** + extensions: Luau Language Server (luau-lsp), StyLua, Rojo.
2. **Rokit** (`rokit.toml`): rojo, stylua, wally (or pesde), lune; optionally selene.
3. **Rojo 7.7** with a `default.project.json`; Git for version control (this is the single biggest quality-of-life win and the thing AI coding agents work best with).
4. **Wally** for packages (largest registry); revisit pesde later.
5. **luau-lsp** in `--strict`/new type solver mode; use `--!strict` on every script.
6. **Jest-Lua** for pure game logic (economy math, upgrade formulas, offline earnings) - structure code so this logic has zero Roblox API dependencies and can also run under **Lune** locally/CI.
7. Skip for now: darklua, roblox-ts, Selene (luau-lsp covers most lint value), Argon.

Fallback for day one: pure Studio + Script Sync, move to Rojo when the project outgrows it.

---

## 2. Frameworks and libraries

### 2.1 Frameworks (Knit vs no framework)
- **Knit is archived** (2024-07-31, 631 stars). Author's rationale: Knit's design cannot use Luau types well; recommendation: plain ModuleScripts for services, a thin wrapper over RemoteEvent/UnreliableRemoteEvent/RemoteFunction, runtime type checks on inbound data ([ARCHIVAL.md](https://github.com/Sleitnick/Knit/blob/main/ARCHIVAL.md)). -> Do not start on Knit.
- Alternatives: [Flamework](https://github.com/rbxts/flamework) (roblox-ts only), [Prvd 'M Wrong](https://prvdmwrong.github.io/prvdmwrong/0.2/learn/installation) (Luau, installable via pesde/Wally), [Nevermore](https://github.com/Quenty/NevermoreEngine) (634 stars, 278 packages, 6k commits; modular loader and a huge utility set, opinionated and heavy for beginners).
- **Recommendation:** no framework. Use a "Services/Controllers as ModuleScripts" convention with a tiny bootstrap that requires and `:Init()`/`:Start()`s each module. Keep server logic as data-in/data-out modules.

### 2.2 Data saving
| Library | Stars | Status | Notes |
|---|---|---|---|
| [ProfileStore](https://github.com/MadStudioRoblox/ProfileStore) (loleris) | 354 | Current successor to ProfileService; single ModuleScript; Apache-2.0; session locking, autosave; `StartSessionAsync`/`EndSession`. [Docs](https://madstudioroblox.github.io/ProfileStore/), [DevForum](https://devforum.roblox.com/t/profilestore-save-your-player-data-easy-datastore-module/3190543) | **Best pick** |
| [ProfileService](https://github.com/MadStudioRoblox/ProfileService) | 333 | "No longer supported" but stable; README says migrate new projects to ProfileStore | legacy |
| [Lapis](https://github.com/nezuo/lapis) (nezuo) | ~36 at last index | Session locking, autosave every 5 min, validation via types; README says not battle-tested in a huge production game; MIT | good alternative with built-in schema validation/migrations |
| DataStore2 | n/a | Could not locate the repo (Kampfkarren URL 404). Widely considered obsolete vs ProfileService/Store | AVOID |
| Others listed on awesome-roblox: DataKeep, DocumentService, Lyra ([awesome-roblox](https://github.com/awesome-roblox/awesome-roblox)) | - | not evaluated | - |

ProfileStore caveats: built for per-player data, not leaderboards/global state; keep data inside `Profile.Data`; don't store non-serializable values.

### 2.3 Networking
| Lib | Stars | Status |
|---|---|---|
| [Zap](https://github.com/red-blox/zap) | 190 | IDL + codegen, buffer packing, validates received data. A rewrite is in progress on the `rewrite` branch; 0.6.x maintained by sasial-dev. Docs historically at zap.redblox.dev |
| [Blink](https://github.com/1Axen/blink) | 192 | IDL compiler in Luau, buffer networking; actively discussed ([DevForum](https://devforum.roblox.com/t/blink-an-idl-compiler-written-in-luau-for-roblox-buffer-networking-0111/2959671)) |
| [ByteNet](https://github.com/ffrostfall/ByteNet) | 185 | "advanced modern networking library", MIT |
| [Red](https://github.com/red-blox/Red) | n/a | older, from the Zap authors; superseded by Zap in spirit |
| Packet / Packeteer / BridgeNet / RbxNet | - | newer or older alternatives; not evaluated deeply ([Packeteer thread](https://devforum.roblox.com/t/packeteer-a-simple-yet-powerful-type-safe-networking-library/4739399)) |

**Recommendation for a tycoon:** plain RemoteEvents + validation at first. A single-player-first tycoon sends few messages (purchase requests, collect, upgrade). Bandwidth libs (Zap/Blink) matter for high-frequency traffic, not button clicks. If you want type-safe remote definitions anyway, Zap or Blink are the maintained picks; Zap's validation-by-schema also gives security hygiene for free.

### 2.4 UI
| Lib | Stars | Status | Notes |
|---|---|---|---|
| [Fusion](https://github.com/dphfox/Fusion) | 815 | Active, 933 commits; "Futuristic Luau" | reactive; docs/tutorials strong; used widely |
| [Vide](https://github.com/centau/vide) | 356 | Active; MIT; [docs](https://centau.github.io/vide/) | fine-grained reactivity, small, fast; lighter than React |
| [react-lua](https://github.com/jsdotlua/react-lua) (community fork of Roblox/react-lua) | 582 | React 17.x port; maintained; larger learning curve | good if you know React |
| [Roact](https://github.com/Roblox/roact) | 624 | **Archived/deprecated**, points to react-lua | AVOID |
| [Iris](https://github.com/SirMallard/Iris) | 362 | Immediate-mode (Dear ImGui style) | debug/admin tools only, not player UI |
| Plain Instances + a tiny helper | - | - | perfectly valid for a menu-heavy tycoon with Studio-built UI |

**Recommendation:** for a beginner: build static UI in Studio's UI editor, bind via a small `Update(state)` function. If you want a library, pick **Vide** or **Fusion** (both active). React-lua only if you know React. I did not get to run a direct "Fusion vs Vide" comparison search (budget limit), so choice here is based on activity/size, not benchmarks.

### 2.5 State management
- [Reflex](https://github.com/littensy/reflex) (109 stars) - "all-in-one state container", Redux-like, active (209 commits).
- [Charm](https://github.com/littensy/charm) (275 stars) - atomic state (Jotai/Recoil style), 135 commits.
- Sleitnick RbxUtil has `Silo` (state container, v0.2.0).
- Both Reflex and Charm are by littensy and usually paired with roblox-ts/React. **Recommendation:** for a tycoon, a single server-owned `PlayerState` table plus a replicated copy (Attributes, ValueObjects or one batched RemoteEvent) is enough. Adopt Charm only if you pick Vide/React-lua and want shared client/server atoms.

### 2.6 Tweens/springs/motion
- Built-in `TweenService` is enough for most tycoon UI.
- [Flipper](https://github.com/Reselim/Flipper) (144 stars, 106 commits, motors/goals), [spr](https://github.com/Fraktality/spr) (146), RbxUtil `Spring`. `ripple` (ffrostfall) URL returned 404 so unverified. Springs shine for bouncy counters/hover states - optional polish.

### 2.7 Utility: Signal / cleanup
- [RbxUtil](https://github.com/Sleitnick/RbxUtil) (475 stars; 30 modules: Signal 2.0.3, Trove 1.8.0, Comm, Component, TableUtil, Timer, TaskQueue, TypedRemote, Silo, Spring, Streamable, Input, Option, Ser, Shake...). Good grab-bag; **Trove** for cleanup, **Signal** for custom events.
- [Janitor](https://github.com/howmanysmall/Janitor) (154) - alternative cleanup.
- [LemonSignal](https://github.com/Data-Oriented-House/LemonSignal) (51) - "faster than most".
- Roblox is also open-sourcing its own Luau libs including a Signals library ([Apr 2026 recap](https://devforum.roblox.com/t/weekly-recap-april-6-10-2026/4568634)).
- **Pick:** Trove + Signal from RbxUtil.

### 2.8 Topbar, admin, ECS
- [TopbarPlus](https://github.com/1ForeverHD/TopbarPlus) (245 stars, 439 commits, v3.x on Wally) - easy topbar icons/menus; useful for Shop/Settings buttons; verify it still behaves with Roblox's current topbar.
- [Cmdr](https://github.com/evaera/Cmdr) (544) - admin console; useful as a dev "cheat console" (add money, skip time).
- ECS: [Jecs](https://github.com/Ukendio/jecs) (484), [Matter](https://github.com/matter-ecs/matter) (119), Planck - only if you need thousands of simulated entities; over-engineering for a tycoon.

### 2.9 Best picks (condensed)
Rojo + Rokit + Wally; ProfileStore; plain Remotes (Zap/Blink later); Vide or Fusion (or plain Instances); Charm optional; Trove + Signal; TweenService first; TopbarPlus + Cmdr optional.

---

## 3. Open-source Roblox games and codebases to study

| Project | What it is | What to learn |
|---|---|---|
| [Miner's Haven source](https://github.com/berezaa/minershaven) (182 stars, Apache-2.0, `minershaven.rbxl` + `src/` extracted via rbxlx-to-rojo; [DevForum thread](https://devforum.roblox.com/t/miners-haven-open-sourced-everything-you-need-to-make-your-own-factory-game/350767), [Medium post](https://medium.com/@berezaa/releasing-miners-haven-to-the-public-domain-b925eac1729)) | A massive factory/idle tycoon (conveyors, upgraders, prestige/rebirth). Source is from Sept 2019 so code style/APIs are dated | Genuinely the best study target for an automation/idle tycoon: machine placement, tick-based production, prestige layers, data schema. License: use code in original commercial projects, don't use the Miner's Haven brand |
| Vesteria open-source ([DevForum](https://devforum.roblox.com/t/vesteria-open-source/842436)) | MMORPG | large-scale architecture (inventory, abilities, UI) |
| Price Point, Slither (listed under "Experiences" in [awesome-roblox](https://github.com/awesome-roblox/awesome-roblox)) | OSS experiences | not evaluated in depth |
| Maze World ([MayGo, DevForum](https://devforum.roblox.com/t/open-source-maze-world/629093), [repo](https://github.com/maygo/maze-world)) | Small Rojo/Tarmac/Remodel game | Reference for a complete small Rojo project layout |
| Tetragon Fortress (TF2-style FPS, listed in [phoenixcausesoof/awesome-roblox](https://awesome.ecosyste.ms/projects/github.com%2Fphoenixcausesoof%2Fawesome-roblox)) | FPS | networking/prediction (not tycoon relevant) |
| Nevermore ([repo](https://github.com/Quenty/NevermoreEngine)) | Utility monorepo | UI/state/binders patterns |
| Roblox's own templates/samples (creator-docs) | not fetched | `[unverified]` |

Caution: "tycoon kits" on BuiltByBit / pages.dev SEO sites are mostly low quality; reviews report some do not function ([BuiltByBit review](https://builtbybit.com/resources/tycoon-kit.77254/reviews)). I found no large modern commercial tycoon with open source on GitHub; a GitHub topics page for tycoon/Lua lists ~2 small repos (unvetted: [topic page](https://github.com/topics/tycoon?l=lua)). Studying Miner's Haven + the Rojo-based small projects is the realistic path.

---

## 4. Platform facts relevant to a tycoon

### 4.1 DataStores
- Per-key value limit: 4 MB (4,194,304). Per-key throughput over the last 60s: reads 25 MB/min, writes 4 MB/min. Request budgets scale with concurrent users - search snippet of the official [error codes and limits](https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits) page: reads/removes `300 + concurrentUsers * 40`/min; ordered writes `300 + concurrentUsers * 20`. Older forum posts cite `60 + players * 10`, so the formulas have changed ([older thread](https://devforum.roblox.com/t/i-dont-understand-the-datastore-limit/1643516); a 2025 forum post speculates about ~40 req/min/user from early 2026 - unconfirmed). **Verify in live docs.**
- Practical rule: one DataStore key per player (ProfileStore does this), autosave every few minutes (not every action), save on `PlayerRemoving` and `BindToClose`, never use DataStore for fast-changing shared state.
- Studio testing needs "Enable Studio Access to API Services".
- Data-loss pitfalls (from general knowledge `[unverified this session]`): not handling session lock, saving non-serializable values, forgetting to version your schema, wiping data on failed load.

### 4.2 MessagingService / MemoryStore
- MessagingService: max message 1 KB; per-server send limit `600 + 240 * players`/min (older `150 + 60 * players`); shared across Open Cloud ([API ref](https://create.roblox.com/docs/reference/engine/classes/MessagingService.md), [limits post](https://devforum.roblox.com/t/enhanced-messagingservice-limits/2835576)). At-most-once delivery, not guaranteed - never use for currency.
- MemoryStore: per sorted map or queue 1,000,000 items / 100 MB; each structure on one partition (~50,000 RPM best case); items have TTL ([docs](https://create.roblox.com/docs/cloud-services/memory-stores), [partition limits](https://create.roblox.com/docs/en-us/cloud-services/memory-stores/per-partition-limits)). Value-size figures conflict across sources.
- **For a single-player-first tycoon you need neither.** Use them later for global leaderboards (MemoryStore SortedMap / OrderedDataStore), cross-server events, or trading. Roblox's Aug 2026 recap mentions "Persistent Leaderboards" ([recap](https://devforum.roblox.com/t/weekly-recap-august-24%E2%80%9328-2026-persistent-leaderboards-opencloud-apis/4836039)).

### 4.3 Server vs client authority and exploit prevention
Based on Roblox's [client-server boundary](https://create.roblox.com/docs/scripting/security/client-server-boundary) and [server-side detection](https://create.roblox.com/docs/scripting/security/server-side-detection) docs (via summary):
- Server is the source of truth for money, inventory, unlocks, timers.
- Treat every remote argument as hostile: validate type, range, ownership, distance, cooldown.
- Client sends **intent**, never outcomes: `BuyItem("GPU_Rack_2")`, server looks up price and checks balance. Never accept a price or an amount from the client.
- Rate-limit per player; compare to plausible maximums; neutralize silently; Roblox advises against banning solely on client-side detection.
- Keep remotes directional and narrow; clean up per-player state on leave.
- Even single-player-first: build server-authoritative from day one (Studio's local server/client test) - retrofitting is painful, and "single-player" Roblox games still run on a server.

### 4.4 Offline progress (idle earnings)
Consistent community pattern ([DevForum threads](https://devforum.roblox.com/t/how-to-make-an-offline-earning-system/3761245), [this one](https://devforum.roblox.com/t/how-do-steal-a-games-calculate-offline-cash/3854950)):
1. Save `lastSeen = os.time()` (use `DateTime.now().UnixTimestamp`) with the profile on leave/autosave.
2. On join, `elapsed = now - lastSeen`; clamp (e.g. 8-24h cap, commonly a monetization hook: gamepass for a higher cap).
3. Earnings = production rate (computed from owned machines) * elapsed * offline efficiency (<1.0).
4. Apply as a single event with a "Welcome back" summary UI; optionally offer 2x via dev product.
5. Never rely on a running server loop for offline players - compute on load, deterministic and idempotent. Guard against clock exploits by always using server time.
The formula should be pure math, unit-testable in Jest-Lua/Lune.

### 4.5 Mobile UI
Community guidance (unofficial, numbers vary - [DevForum mobile guide](https://devforum.roblox.com/t/developing-for-mobile-a-guide-for-beginner-roblox-creators/3785900), [creation.dev](https://www.creation.dev/blog/roblox-ui-design-best-practices)):
- Use Scale not Offset, add UIScale + UIAspectRatioConstraint; use UIListLayout/UIGridLayout; test with Studio's device emulator on a small and a large phone.
- Touch targets roughly 44-48 px minimum (sources range up to ~10% of screen height).
- Respect safe areas and Roblox's reserved touch controls (bottom-left thumbstick, bottom-right jump); keep important functions within ~2 taps; shallow menus; large readable numbers (tycoons have lots of currency text).
- Test console/gamepad navigation if you plan to support it. I did not find console-topbar-specific guidance.
- Over half of Roblox play is on mobile ([unverified general knowledge]).

### 4.6 Performance with many parts
- Official [Design for performance](https://create.roblox.com/docs/performance-optimization/design) / [Improve](https://create.roblox.com/docs/performance-optimization/improve.md) docs: biggest CPU costs are expensive scripts, many physics-simulated parts, heavy loops.
- Tycoon tips: Anchor everything static; avoid per-frame loops (use events/attributes, batch updates with a single Heartbeat accumulator); use MeshParts instead of unions; pool dropper/ore parts (PartCache) or avoid physical drops entirely (just add numbers + play an effect); set `CanCollide/CanQuery/CanTouch` false on decor; use CollectionService tags rather than scanning descendants; Parallel Luau/Actors only for measured hotspots and keep messages small; profile with MicroProfiler.
- **StreamingEnabled** ([docs](https://create.roblox.com/docs/projects/streaming)): content loads/unloads by distance. Scripts must not assume parts exist (`WaitForChild` with timeouts, `PersistentLoaded`, ModelStreamingMode Persistent/Atomic for key models). For a small single-player tycoon base, streaming is optional; if you plan a big shared map or mobile-heavy audience, enable it early rather than retrofitting.
- Community thread: part count itself matters less than server memory and physics - [DevForum](https://devforum.roblox.com/t/how-many-parts-is-too-many-parts/1974661).

### 4.7 AI and Studio features / newer APIs (2025-2026)
- **Studio Assistant went agentic (April 2026):** planning mode, procedural model generation, mesh generation (Cube), self-testing loop; built-in MCP server for external agents ([newsroom](https://about.roblox.com/newsroom/2026/04/roblox-studio-going-agentic), [TNW](https://thenextweb.com/news/roblox-ai-assistant-agentic-tools-planning-procedural-models), [Assistant update post](https://devforum.roblox.com/t/assistant-update-boost-your-productivity-by-executing-complex-tasks/3920088)). Third-party summaries; verify in Studio.
- **Cube 3D**: open-source 1.8B-param text-to-3D model; Mesh Generation API (beta since March 2025) ([newsroom](https://about.roblox.com/newsroom/2025/03/introducing-roblox-cube), [DevForum beta](https://devforum.roblox.com/t/beta-cube-3d-generation-tools-and-apis-for-creators/3558947)) - useful for placeholder server-rack/GPU art.
- **Luau new type solver** has left beta and is being rolled out as default for non-strict/nocheck scripts ([general release post](https://devforum.roblox.com/t/general-release-luau%E2%80%99s-new-type-solver/4084991)); type functions (`keyof` etc.) and generics improvements ongoing ([2026-08-24 notes](https://create.roblox.com/docs/updates/2026-08-24.md)). Use `--!strict`.
- **Deprecations:** legacy game pass and developer-product APIs deprecated April 23, 2026 -> use Open Cloud; PhysicsService reported deprecated in favor of updated APIs ([Apr 2026 recap](https://devforum.roblox.com/t/weekly-recap-april-6-10-2026/4568634)). Aug 2026 recap adds Open Cloud APIs for Analytics, Events, Experiments, Thumbnails.
- **RDC26 (Sept 11, 2026) headlines** ([Roblox newsroom](https://about.roblox.com/newsroom/2026/09/rdc-2026-the-world-needs-more-play), [91mobiles](https://www.91mobiles.com/gaming/roblox-announces-standalone-game-apps-at-rdc-2026/), [pockettactics](https://www.pockettactics.com/roblox/rdc-2026)): standalone game apps ("Roblox Everywhere", no firm date); an offline solo mode alongside multiplayer (expected mid-2027, early access sooner - directly relevant to a single-player-first design); in-browser play via Chrome (target end of 2026); Roblox Wallet (creator earnings paid in real currency daily, eligible US 18+ later in 2026) and Roblox Card (2027). Press coverage; timelines may slip. Official roadmaps: [Spring 2026](https://devforum.roblox.com/t/creator-roadmap-2026-spring-update/4625473), [RDC26 recap](https://devforum.roblox.com/t/rdc26-what-we-announced/4865880).
- **Design implication:** keep all game logic separable from "multiplayer" (server module + client view) so an offline/solo mode, if you adopt it later, is a smaller step.

### 4.8 Monetization
- Types: game passes (one-time), developer products (repeatable, e.g. cash packs, time-skips), subscriptions, private servers, Premium payouts/Creator Rewards, ads. See [monetization docs](https://create.roblox.com/docs/production/monetization).
- **Premium payouts:** Engagement-Based Payouts were deprecated July 24, 2025 and replaced by the **Creator Rewards** program ([docs](https://create.roblox.com/docs/production/monetization/engagement-based-payouts)); third-party reports say it is based on "qualified play time" of Premium/ad-eligible users and paid monthly. Mechanics beyond that are unverified (community figures like 5-15 R$/user/day are anecdotal).
- **Revenue share:** Roblox takes ~30% marketplace fee so creators get ~70% of Robux price (third-party sourced; verify). **DevEx rate:** sources conflict - $0.0035 vs ~$0.0038 per Robux (reported increase Sept 5, 2025); a ~42% higher "qualifying" rate for US 18+ spend was announced April 2026, effective June 8 ([Roblox newsroom](https://about.roblox.com/newsroom/2026/04/roblox-fuels-high-fidelity-games-over-18-players-increases-qualifying-devex-rate-42), [netinfluencer](https://www.netinfluencer.com/roblox-to-raise-developer-exchange-rate-for-games-aimed-at-18-plus-players-as-adult-cohort-surges/)). Re-check before budgeting.
- Tycoon-typical products: 2x cash pass, auto-collect, extra lab slots, VIP, offline-earnings cap upgrade, dev-product cash/time-skip packs, limited-time boosts, premium cosmetic skins for the lab. Keep it fair (kids audience; don't hard-paywall core loop).
- Legal/policy: dev needs to follow Roblox's Community Standards and age-appropriate rules (original IP; AI-lab theme is fine, avoid real company branding/trademarks like OpenAI/Anthropic logos).

### 4.9 Discovery and metrics if published
Roblox's [discovery docs](https://create.roblox.com/docs/discovery.md) (via summary):
- Top signals: **play-through rate** from Home "Recommended for You" impressions; qualified play sessions per user; play days per user and playtime per user across D1, D2-7, D8-28; bounce rates (<60s is bad). Average playtime counted per user, capped at 60 min per user per game per day. Engagement is "per user", not total.
- Ranking ignores engagement from users acquired via ads, curation, friends, search or social media for recommendation purposes -> you can't buy your way into the algorithm; core loop + retention + accurate title/thumbnail/metadata matter.
- Practical: great first 60 seconds (clear first purchase), strong D1/D7 return hooks (daily rewards, offline earnings welcome, timed events), thumbnails/icons that match the actual experience, frequent updates, favorites/follows. Use the Creator Hub Analytics (and new Open Cloud analytics APIs).
- A third-party claim (rowatcher) that D1 return rate and session-over-session growth dominate is unverified.

---

## 5. Market: top tycoon / business sim games and why they work

Data reliability: all from third-party trackers/blogs (rowatcher, rotrends, listicles) - numbers conflict; use qualitatively. Live charts: Roblox Discover, plus trackers such as [RoMonitor/RoTrends](https://rotrends.com/game/9299166304), [Bloxodes](https://bloxodes.com/stats/games/roblox-tycoon-2514698662), [Rowatcher](https://rowatcher.com/news/tycoon-games-the-genre-that-built-roblox-and-still-hasn-t-peaked) (not fetchable here).

Observations:
- Tycoon is reported as the #2 most-played Roblox category after obbies, with top titles regularly >100k CCU (unverified blog claim, [rowatcher](https://rowatcher.com/news/tycoon-games-the-genre-that-built-roblox-and-still-hasn-t-peaked)). Spread is huge: one tracker lists "Be a Lucky Block" ~112k CCU while Retail Tycoon's all-time peak was reported as tiny (data quality doubtful).
- Frequently recommended deep business sims: Retail Tycoon 2, Theme Park Tycoon 2 (deep building tools), Restaurant Tycoon 2, Car Dealership Tycoon, Miner's Haven (idle/factory) ([creation.dev list](https://www.creation.dev/blog/best-roblox-tycoon-games), [pocketgamer.com](https://www.pocketgamer.com/roblox/best-tycoon-games), [obby.fun](https://www.obby.fun/blog/best-roblox-tycoon-games)).
- Platform-wide mega hits of 2025 are tycoon/sim-adjacent: **Grow a Garden** and **Steal a Brainrot** drove Roblox's record ~47M concurrent users in Aug 2025 ([pocketgamer.biz](https://www.pocketgamer.biz/robloxs-peak-concurrent-user-count-hits-record-474m-as-steal-a-brainrot-and-grow-a-garden-compete), [Tubefilter](https://www.tubefilter.com/2025/08/25/roblox-grow-garden-steal-brainrot-admin-war-record/amp/)). Reported peaks: Grow a Garden ~21-22M, Steal a Brainrot ~25M. A case study (single analytics blog, unverified) claims D7 retention ~6% (Brainrot) vs ~28% (Grow a Garden) and credits Grow a Garden's loop depth ([rolearn case study](https://rolearn.dev/case-studies/brainrot-game-meme-culture-25m-ccu)).

Mechanics that recur in successful tycoon/idle sims (synthesis; mix of sourced and general design knowledge):
1. Instant first-minute reward: first purchase within seconds; visible growth of the base.
2. Layered progression: buy -> upgrade -> automate -> prestige/rebirth (Miner's Haven's rebirth layers).
3. Return hooks: offline earnings, daily/streak rewards, timers (crops growing, research running), limited-time events (the "admin abuse" weekend events drove huge spikes).
4. Short mobile-friendly sessions; clear numbers and big buttons.
5. Social/competitive layer: leaderboards, visiting friends' bases, trading, rarity/collections.
6. Monetization that speeds rather than gates: 2x, auto-collect, time skips, luck boosts, VIP.
7. Frequent content updates keep D7/D28 up.
Relevance to an AI-lab theme: research queues/training runs as timers, GPU/data-center capacity as machines, compute-cost vs revenue as the economy, "model release" as the prestige event, benchmark leaderboards as the social layer (all original, no real brands).

---

## 6. Open questions I could not verify this session
- Exact current DataStore budgets (conflicting formulas).
- Whether Studio Script Sync has left preview (2026).
- Last-commit dates for each repo (fetch tool doesn't show them).
- Real retention benchmarks (no first-party data).
- Status of `ripple`, DataStore2, Packet repos (404s).
- Official Roblox mobile/console UI guidance, Creator Hub learning path content.

## 7. Suggested next research steps
1. Re-run the skipped searches once more search budget/network access is available (create.roblox.com and devforum.roblox.com need to be allowed in the session network settings for full-page reads).
2. Read Miner's Haven `src/` for its economy/prestige architecture.
3. Prototype the economy as pure Luau + Lune/Jest tests before building any UI.

---

## 8. Beginner learning path `[mostly unverified - from background knowledge; search budget exhausted]`
Suggested order (check each link is still current):
1. Roblox Creator Hub: "Get started", "Scripting" and "Luau" fundamentals (create.roblox.com/docs); Roblox's official tutorials (e.g. building a first game).
2. Luau language docs and style: [luau.org](https://luau.org) (typing, performance); [Roblox Lua Style Guide](https://roblox.github.io/lua-style-guide/).
3. YouTube channels commonly recommended by the community (verify quality/recency): BrawlDev, AlvinBlox, TheDevKing, GnomeCode (all `[unverified]`).
4. Concepts to master in order: Instances/Services -> events & Remotes (client/server) -> DataStores via ProfileStore -> UI (Scale, layouts) -> CollectionService/tags -> modules and types -> testing -> optimization (MicroProfiler).
5. Community help: DevForum "Help and Feedback > Scripting Support", Roblox Discord/Reddit servers; [awesome-roblox](https://github.com/awesome-roblox/awesome-roblox) for the OSS index.
6. Project order: (a) one-plot tycoon with 5 buttons; (b) save/load with ProfileStore; (c) offline earnings; (d) upgrades/prestige; (e) UI polish + mobile; (f) monetization stubs; (g) playtest, analytics.
7. AI-assisted workflow: Rojo + Git + Claude Code, plus Studio's built-in MCP server (see 1.2). Keep a written design doc and review all AI-written code for server-authority and data-safety mistakes.

---

## 9. Source index (main links)
- Rojo: https://github.com/rojo-rbx/rojo ; 7.7.0: https://newreleases.io/project/github/rojo-rbx/rojo/release/v7.7.0
- Rokit: https://github.com/rojo-rbx/rokit ; Aftman: https://github.com/LPGhatguy/aftman ; Foreman: https://github.com/Roblox/foreman
- Wally: https://github.com/UpliftGames/wally ; pesde: https://github.com/pesde-pkg/pesde
- StyLua: https://github.com/JohnnyMorganz/StyLua ; luau-lsp: https://github.com/JohnnyMorganz/luau-lsp ; Selene: https://github.com/Kampfkarren/selene
- Lune: https://github.com/lune-org/lune ; darklua: https://github.com/seaofvoices/darklua ; Jest-Lua: https://github.com/jsdotlua/jest-lua
- ProfileStore: https://github.com/MadStudioRoblox/ProfileStore ; Lapis: https://github.com/nezuo/lapis
- Zap: https://github.com/red-blox/zap ; Blink: https://github.com/1Axen/blink ; ByteNet: https://github.com/ffrostfall/ByteNet
- Fusion: https://github.com/dphfox/Fusion ; Vide: https://github.com/centau/vide ; react-lua: https://github.com/jsdotlua/react-lua
- Reflex: https://github.com/littensy/reflex ; Charm: https://github.com/littensy/charm ; RbxUtil: https://github.com/Sleitnick/RbxUtil
- Knit (archived): https://github.com/Sleitnick/Knit ; Miner's Haven: https://github.com/berezaa/minershaven
- Roblox Studio agentic: https://about.roblox.com/newsroom/2026/04/roblox-studio-going-agentic
