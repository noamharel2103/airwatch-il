# 07 - Roblox's own AI tooling and the wider ecosystem (research, as of 2026-11-11)

Scope: what Roblox ships (GitHub org `Roblox`, Studio, Creator Docs, DevForum) and what the community has built, evaluated for one specific use: building an original Roblox "AI-lab tycoon" with heavy help from Claude Code on Windows, including possible in-game AI-generated "reactions / social posts" for models the player releases.

## 0. Method, confidence and caveats (read first)

- The research sandbox could not reach `create.roblox.com`, `devforum.roblox.com`, `about.roblox.com` or most third-party blogs (DNS blocked), and `gh` had no repo access. What did work: `github.com` web pages (repo pages, org listings, GitHub search, release pages, and the `Roblox/creator-docs` markdown/YAML via `github.com/.../blob/main/...`) plus WebSearch summaries.
- Therefore: **tool tables, setup steps, TextGenerator/GenerationService specs, Script Sync, skills, BYOK and Open Cloud MCP details come from the official `Roblox/creator-docs` source files (high confidence)**. DevForum announcement contents are known only through search-engine summaries (medium confidence). Star counts and "last updated" values come from GitHub pages fetched today (2026-11-11); some pages show no commit date, marked "n/d".
- Things I could not verify are flagged "UNVERIFIED". Pricing/quotas for Assistant are the biggest gap: no official figure was found.
- Recommendation: before building, open https://create.roblox.com/docs/studio/mcp and https://create.roblox.com/docs/reference/engine/classes/TextGenerator once in a browser to confirm nothing changed.

## 1. Headline findings (TL;DR)

1. **The standalone `Roblox/studio-rust-mcp-server` is dead.** Archived 2026-04-03 (501 stars, 96 forks). Final release tag "END - Product discontinued". Roblox says engineering moved to the **MCP server built into Roblox Studio**. Do not install the old `rbx-studio-mcp.exe`.
2. **Studio now has a built-in MCP server** (`stdio` transport) with ~26 tools in ~10 groups, and **Quick Connect** for Claude Code, Claude Desktop, Cursor, Codex CLI, Gemini CLI, Antigravity and VS Code. Windows launch command: `cmd.exe /c %LOCALAPPDATA%\Roblox\mcp.bat`.
3. **Roblox publishes an official Claude Code plugin**: `Roblox/roblox-studio-agent-plugin` (MIT, 33 stars, updated 2026-11-10). Install in Claude Code with `/plugin` and search "Roblox Studio". It contains no code, only config + a setup skill; it launches Studio's own MCP.
4. **Studio MCP can call Open Cloud with no API key** (`open_cloud_invoke` tool) with a per-game permission model (Safe / Balanced / Full / Custom) - a major safety feature for agent use.
5. **Script Sync (Studio beta)** is Roblox's native file-sync (Studio <-> disk). Rojo remains the better choice if you want the filesystem as source of truth for the whole project. The official "coding harness" guide pairs Script Sync + MCP + an AI editor.
6. **In-game AI**: `TextGenerator` (LLM text, engine API) is real and usable; `GenerationService` (Cube-based 3D generation at runtime) exists. Both are moderated by Roblox. Constraints that matter for this game: rate limit starts at 100 requests/min/experience; output must go through text filtering; must disclose AI; **cross-session AI memory or "extended" chat pushes the experience to Restricted (18+)**. Fine for short, one-shot reactions; avoid persistent AI personas with memory.
7. **A big ecosystem of agent skills / templates** for Roblox + Claude Code exists (many 2026, many low-star, quality varies). Best starting points: Roblox's own plugin + `MSayib/roblox-dev-skill` + `gamedev-skills/awesome-gamedev-agent-skills` (has an explicit `roblox-simulator-economy` skill for idle/tycoon) + a Rojo/Rokit toolchain.
8. **Roblox Build** (mobile prompt-to-game, 2D/2.5D only) and **Scene Generator** (RDC26) are not useful for a hand-crafted, Claude-Code-driven tycoon, but are context.

## 2. Official Roblox GitHub org: inventory (111 repos; 2026-11-11)

Org page: https://github.com/Roblox. Relevant repos (stars / last-updated as shown today):

| Repo | Stars | Updated | What it is | Relevance to this game |
|---|---|---|---|---|
| `Roblox/roblox-studio-agent-plugin` | 33 | 2026-11-10 | Official Claude Code / Cowork / Codex / ChatGPT plugin wiring Studio's built-in MCP + setup skill. MIT. | **High** - the supported way to connect Claude Code. |
| `Roblox/creator-docs` | 898 | 2026-11-11 | Source of create.roblox.com/docs (Markdown in `content/en-us/`, engine API as YAML in `content/en-us/reference`). CC-BY-4.0 prose, MIT samples. 4.1k forks, 2,206 commits. | **High** - clone locally so Claude can grep authoritative API docs offline. |
| `Roblox/studio-rust-mcp-server` | 501 | 2026-04-03 (archived) | Old standalone MCP server (Rust). | Obsolete; reference only. |
| `Roblox/cube` | 1.3k | 2026-05-28 | "Foundation Model for 3D Intelligence": Cube 3D v0.5 (text->shape) + CubePart (May 2026). | Low for runtime (research license, GPU needed); explains what GenerationService is. |
| `Roblox/open-game-eval` | 76 | 2026-10-05 | Eval framework for LLMs on Roblox tasks (84 core tasks; paper "OpenGameEval" arXiv 2610.02563). | Medium - shows how to measure agent quality; finding: agents that inspect before editing succeed more. |
| `Roblox/RobloxGuard-1.0` | 68 | 2026-08-11 | Llama-3.1-8B-based safety classifier that guards the Text Generation API. RAIL-MS license. | Context: this is what moderates `TextGenerator`. |
| `Roblox/voice-safety-classifier` | 105 | 2026-06-17 (README says no longer updated) | WavLM voice toxicity classifier, 8 languages. | Not needed. |
| `Roblox/Sentinel` | 118 | 2026-08-18 | Apache-2.0 library for realtime rare-text-class detection. | Not needed. |
| PII classifier (Hugging Face `Roblox/roblox-pii-classifier-v2`, Apache-2.0; v2 Aug 2026) | - | 2026-08 | Detects attempts to share/request PII. | Not needed; relevant only if you build custom chat. |
| `Roblox/react-luau` | 589 | 2026-10-30 | React 17 port to Luau (read-only mirror). | Optional UI framework for tycoon HUD. |
| `Roblox/jest-roblox` | 50 | 2026-11-10 | Jest port for Luau; runs in Roblox or via Open Cloud Luau Execution; Wally packages `Jest`/`JestGlobals` 3.20.0. | Medium - unit-test economy math. |
| `Roblox/rodux` | 338 | 2026-06-30 | Redux-style state. | Optional. |
| `Roblox/signals` | 53 | 2026-11-10 | Declarative state mgmt for Luau. | Optional. |
| `Roblox/roblox-blender-plugin` | 258 | 2026-04-20 | Upload Blender assets to Roblox via Open Cloud. | Medium for custom machine/lab props. |
| `Roblox/foreman`, `tarmac` | 263 / 141 | 2026-05 / 2025-07 | Older toolchain/asset tools (Rokit supersedes foreman). | Skip. |
| `Roblox/rocale-cli` | 39 | 2026-05-14 | CLI to build/upload/run Roblox projects in OCALE (Open Cloud Luau Execution). | Low-medium for CI. |
| `Roblox/rbxasset` | 29 | 2026-04-23 | Deploy from GitHub to Creator Store. | Low. |
| `Roblox/data-stores-batch-processor-cli` | 20 | 2026-10-01 | Run Luau across DataStores. | Low (live ops). |
| `Roblox/FAI-RL`, `SmoothCache`, `FlashTex` | 14 / 48 / 171 | mixed | Roblox ML research code. | Not relevant. |
| `Roblox/avatar`, `gear`, `resources` | 131 / 55 / 20 | 2026-10/11 | Avatar/gear source assets. | Not relevant. |
| Archived: `roact` (624), `testez` (210), `t`, `js-to-lua`, `place-ci-cd-demo` | - | - | Legacy. | Avoid for new code. |

A GitHub org search for "skills" returned zero Roblox-owned repos; the only official agent artifacts are the plugin repo and the docs.

## 3. `Roblox/studio-rust-mcp-server` (old, archived)

- Link: https://github.com/Roblox/studio-rust-mcp-server - 501 stars, 96 forks, Rust (axum + rmcp), **archived 2026-04-03**, last release tag "END" (product discontinued; "1 commit to main since").
- Old tools (6): `run_code`, `insert_model`, `get_console_output`, `start_stop_play`, `run_script_in_play_mode`, `get_studio_mode`.
- Old install (Windows): download `rbx-studio-mcp.exe` release, run installer (auto-edits Claude Desktop/Cursor config), plus Studio plugin. Claude Code: `claude mcp add --transport stdio Roblox_Studio -- '<path>' --stdio`.
- Why it matters now: tutorials from 2025 still reference it; ignore them. Migrate to the built-in server (section 4). The old tool names (`run_code`) do not exist in the new server (`execute_luau` is the equivalent).

## 4. Studio's built-in MCP server (the current official path)

Source: creator-docs `content/en-us/studio/mcp.md` and `studio/mcp-open-cloud.md` (read via GitHub), cross-checked with search summaries of DevForum posts "Studio MCP Server Updates and External LLM Support for Assistant", "Assistant Updates: Mesh Generation, New MCP Server Tools, Screenshot Tool, and More" and "New Studio Testing APIs and Assistant Improvements".

### 4.1 What it is
Built into Roblox Studio, MCP over `stdio`, runs locally, lets an AI client read the data model, edit scripts, insert assets, run Luau, playtest, simulate input, capture screenshots, generate meshes/materials. Requirements: latest Roblox Studio + an MCP client. Works on Windows and macOS only (not claude.ai web).

### 4.2 Tools (official docs, by group)
- **Scripts:** `script_read` (whole script or line range, dot paths), `multi_edit` (several edits in one op; creates script if path missing), `script_search` (fuzzy name search, max 10), `script_grep` (pattern search, max 50).
- **Assets / generation:** `generate_mesh` (textured mesh from text/image; optional bounding-box Part; max triangles default 10,000), `generate_material` (MaterialVariant from text), `generate_procedural_model` (parametrized model built of primitives, rebuilds when Size/attributes change; limit 50 per rolling 24h per the Assistant guide), `wait_job_finished`, `search_asset`, `insert_asset`, `upload_image`, `store_image`.
- **Data model:** `subagent` (types: explore, playtest), `search_game_tree`, `inspect_instance`.
- **Luau execution:** `execute_luau` (in Edit, Client or Server data model).
- **Playtesting:** `get_studio_state`, `start_stop_play`, `get_console_output`, `screen_capture` (JPEG encoding rolled out because Claude Desktop hit a 1 MB tool-result limit with PNG).
- **Input simulation:** `character_navigation`, `user_keyboard_input`, `user_mouse_input`.
- **Docs + skills:** `http_get` (allow-listed Roblox docs URLs only), `skill` (loads Roblox/user skills).
- **Place mgmt:** `save_place`. **Sessions:** `list_roblox_studios`. **Feedback:** `submit_feedback`.
- **Open Cloud:** `open_cloud_invoke` (method, endpoint under apis.roblox.com, body, scopes, files) - no API key; Studio authenticates.
- Every call takes `studio_id`; one client can drive several Studio windows. A third-party guide counted 26 tools in 8 groups as of 2026-09-30 (UNVERIFIED count; the docs now show more groups).
- Teleport testing: playtest automation works across teleports in the same experience without publishing (with limits).

### 4.3 Enable and connect (Windows, Claude Code)
Official sequence:
1. Update Roblox Studio to latest; sign in; open a place.
2. In Studio: **Assistant -> ... -> Manage MCP Servers -> Enable "Studio as MCP server"** (green indicator shows connected client count).
3. **Quick connect:** Assistant Settings -> MCP Servers -> expand Quick connect -> toggle **Claude Code** (or Claude Desktop, Cursor, Codex CLI, Gemini CLI, Antigravity, VS Code). Restart the client.
4. **Manual (Claude Code CLI) if Quick connect is missing:**
   ```
   claude mcp add Roblox_Studio -- cmd.exe /c "%LOCALAPPDATA%\Roblox\mcp.bat"
   ```
   (Official doc gives the command `cmd.exe /c %LOCALAPPDATA%\Roblox\mcp.bat`; the `claude mcp add` wrapper is my composition - verify with `claude mcp list`. Use `--scope user` or `--scope project` as desired; project scope writes `.mcp.json` which can be committed.)
   Manual JSON for Claude Desktop / `.mcp.json`:
   ```json
   { "mcpServers": { "Roblox_Studio": { "command": "cmd.exe", "args": ["/c", "%LOCALAPPDATA%\\Roblox\\mcp.bat"] } } }
   ```
5. **Preferred for Claude Code:** install the official plugin (section 5), which registers `plugin:roblox-studio:windows` automatically.
6. Verify: ask "list my open Roblox Studio windows" (calls `list_roblox_studios`); `/mcp` in Claude Code.
- Claude Desktop: Settings -> Developer -> Edit Config, add the same JSON block, restart (fully quit from tray).
- Troubleshooting from docs: restart Studio and client; confirm `mcp.bat` exists; check JSON commas. Community reports of handshake failures exist for Antigravity on Windows 11 (not Claude Code).

### 4.4 Permission model for external clients (Open Cloud via MCP)
- Click **MCP** (bottom-right of Studio) -> MCP Permissions, or Assistant -> Settings -> MCP Permissions. Access levels: Safe / Balanced (default per game) / Full / Custom; per person, per game; applies only to external clients, not the built-in Assistant.
- Sections: look at game, edit game, players & social, save/load data (DataStore/MemoryStore via `execute_luau`, requires "Enable Studio Access to API Services"), connect to internet (HTTP with domain allow-list), publish & manage assets, money & monetization, player consequences (bans), security & credentials.
- High-risk: Money & monetization, Player consequences, Security & credentials, `universe:write`, `universe-places:write`. **Keep these off for an agent.** Permissions are saved per published game; Claude can only upload files from folders you approve.
- Built-in skills: `rbx-open-cloud-usage`, `rbx-permissions`, `rbx-import-asset` (3D import from .glb/.fbx with triangle checks and moderation wait).
- Warning (docs): MCP clients can read/modify your open places; trust only your clients. **Not every change is undoable - commit/publish a version first.**

### 4.5 Version/changes timeline (from searches; medium confidence)
- 2025: open-source Rust server announced on DevForum ("Introducing the Open Source Studio MCP Server").
- Feb 2026: Assistant gets external LLM support (bring your own API key: Anthropic, OpenAI, Google) and Studio runs MCP natively.
- Mar-Apr 2026: built-in MCP formally recommended; Apr 3 standalone archived; Apr 16 "Roblox Studio going agentic" (Planning Mode, Mesh Generation, Procedural Models beta, self-correcting test loop).
- Spring 2026: Mesh generation + `generate_mesh`/`generate_material` MCP tools + screenshot tool; Studio Testing APIs (`StudioTestService`, multiplayer test 1-8 clients) feeding `user_*_input` tools; creator-authored Skills (also usable from Claude Desktop/Code/Cursor).
- Aug 2026 (Japanese report, UNVERIFIED vs Roblox notes): fix for MCP returning "method not implemented" and for the server auto-disabling.
- Sept 2026 RDC26: Scene Generator across Build and Studio; AI testing agents; Fall Creator Roadmap lists "Open Cloud APIs for AI tools" slipped to Late 2026 and "Expanding Creator Hub APIs to MCP" to Early 2027.
- Studio version referenced by one skill README: 0.746.0.7461269 (verified 2026-11-07).

### 4.6 Limitations / gotchas
- Studio must be open with a place loaded; one Studio = one session (use `studio_id` for several).
- No headless Studio; CI uses Open Cloud Luau Execution instead (section 10).
- Large screenshots can exceed client result limits (mitigated by JPEG).
- `http_get` only fetches allow-listed Roblox docs, not arbitrary URLs.
- Skills are account-scoped, not place-scoped (docs); a community request for place-scoped skills is unconfirmed.
- Assistant/generation quotas are real (procedural models 50/24h; mesh gen has daily quota; devs complain of limits) - exact numbers not found.

## 5. `Roblox/roblox-studio-agent-plugin` (official Claude Code plugin)

- https://github.com/Roblox/roblox-studio-agent-plugin - 33 stars, MIT, 3 commits, updated 2026-11-10.
- Layout: `.claude-plugin/plugin.json`, `.codex-plugin/`, `.agents/plugins/`, `skills/roblox-get-started/`, `evals/`, `assets/`, `SECURITY.md`. "Contains no code of its own, only configuration and skill instructions."
- What it does: Claude Code and Claude desktop (Cowork), ChatGPT desktop and Codex CLI connect to Studio's built-in MCP, then you can "build, script, playtest and debug."
- **Install (Claude Code, Windows):** run `/plugin`, search "Roblox Studio", install. Or just say "get me set up with Roblox Studio" - the `roblox-get-started` skill checks prerequisites, can install/open Studio (outside sandbox, signature-checked), and walks you through enabling the Studio MCP setting.
- Verify: `/mcp` shows `plugin:roblox-studio:macos` and `plugin:roblox-studio:windows`; only the one matching your OS connects (the other failing is expected). Launches `mcp.bat` via `cmd.exe`.
- Data handling: asset search, AI generation, and Open Cloud calls go to Roblox under your Studio account; tool results Claude reads go to Anthropic as conversation context; plugin collects no telemetry.
- Limits: Studio on Windows/macOS only; not claude.ai web; edits are live and not all undoable.
- How it helps the tycoon: gives Claude the `skill` tool for Roblox-specific guidance, playtest loop and docs lookup; low setup friction.

## 6. Studio-native AI features (non-MCP)

Sources: creator-docs `ai/accelerated-workflows.md`, `assistant/guide.md`, `assistant/skills.md`, `assistant/mcp.md`, `studio/material-generator.md`, `studio/texture-generator.md`.
- **Code Assist:** inline completions in the script editor.
- **Assistant:** chat agent in Studio; multi-chat per place (cloud-saved, branching), modes incl. **Plan** (Agent dropdown -> Plan: analyzes code/data model, proposes step plan, asks clarifying questions), run/edit instances and scripts, bulk property edits, Creator Store search, screen-capture subagent, slash commands `/insert_asset`, `/generate_mesh`, `/generate_procedural_model`, `/generate_texture`. Prompting tips: use exact instance names, select objects, say edit-time vs runtime, describe the object not the image.
- **BYOK:** Assistant -> ... -> Manage API Keys -> pick Anthropic / OpenAI / Google, enter key, pick model. Keys stored on device. (This is separate from connecting Claude Code over MCP, which needs no Anthropic API key beyond your Claude subscription.)
- **Skills (creator-authored):** one Markdown file with frontmatter `name` (no `rbx-` prefix), `description`, `enabled`; body = instructions; built-in `rbx-create-skill` helps author; account-scoped; duplicates of Roblox skills do not receive updates. Skills also surface through MCP clients.
- **Mesh generation / Cube:** textured MeshPart from text or image (bounding box via selected part; default 10k triangles max).
- **Procedural Models:** parametrized, primitive-part models in a GeneratedFolder (50 per rolling 24h).
- **Material Generator** (Window -> 3D): seamless tiling variants saved to Material Manager (Studs Per Tile, Organic toggle). **Texture Generator** (Model tab -> Texture): Fast = 1K diffuse (~30 s), Quality = 4K PBR via SurfaceAppearance; also `/generate_texture` and MCP.
- **Avatar Auto-Setup**, **Interactive 3D / 4D generation** (beta; schemas `Car5`, `Body1`; for player-generated vehicles/weapons).
- **Roblox Build:** mobile text-to-game (2D/2.5D clickers/arcade; free daily prompts, Robux credits; editing in Studio converts it to a normal Studio game). Not suited to this project.
- **Cost/quota status:** UNVERIFIED. DevForum threads ("Studio Assistant Limits and Reliability", "Increase Roblox Assistant Usage Limit") show users hitting limits; a third-party aggregator claims usage-based credits from 2026-06-01 (unconfirmed). Using Claude Code via MCP bypasses Assistant's quota for text reasoning, but `generate_*` tools still hit Roblox's generation quotas.

How it helps this game: use `generate_mesh`/Texture Generator for server racks, GPU cabinets, holo-panels; Material Generator for lab floors/walls; procedural models for scalable server-rack rows (nice for expanding tycoon floors); Planning mode as a second opinion; Assistant skills to encode house conventions.

## 7. In-experience AI APIs (runtime) and the "reactions / social posts" idea

### 7.1 `TextGenerator` (engine LLM API)
Source: creator-docs `reference/engine/classes/TextGenerator.yaml` (read directly).
- Instance with properties `SystemPrompt` (string), `Temperature` (default 0.7, clamped [0.4, 1.0]), `TopP` (default 0.9, clamped [0.5, 1.0]), `Seed` (int, default 0).
- `TextGenerator:GenerateTextAsync(request)` (yields, not thread-safe). Request keys: `UserPrompt`, `ContextToken`, `MaxTokens`, `JsonSchema` (JSON Schema string -> structured output; the page's summary is inconsistent about whether JsonSchema is officially listed, treat as supported but test). Response: `GeneratedText`, `ContextToken`, `Model`.
- Rate limit: starts at **100 requests/minute per experience** and scales with concurrent users (the first beta said "per second"; docs/announcement now say per minute). Overflow returns a customizable error.
- Model: Roblox-enhanced open-source LLM; **no tool calling / agents** (community SDK note). Quality is "may make mistakes".
- Moderation: input and output moderated; Roblox Guard 1.0 screens all text. Docs: "All generated text must be processed through `TextService:FilterStringAsync()`" before showing to users.
- Access: beta started limited to Moderate/Restricted maturity; later expanded to **any maturity rating except experiences with extended interactions**. Fall 2026 roadmap still lists the full feature as delayed to Late 2026 (status words in roadmap vs engine docs differ; the API itself is documented in engine reference).
- Status note: the older Open Cloud Text Generation API was slated for deprecation in favor of the engine API.
- Community wrapper: "Lmaas SDK" (DevForum) wraps TextGenerator.

### 7.2 Policy constraints (Generative AI game requirements, `generative-AI.md`)
- All content, AI-generated or not, must follow Community Standards. With Roblox APIs (`GenerationService`, `TextGenerator`) inputs/outputs are moderated; with third-party AI you are responsible and text must go through `TextChatService` (filtering).
- Disclose AI interactions in the Content Ratings Questionnaire; adding AI alone does not change the rating.
- Outputs must match the experience's maturity classification (Roblox tools aim for All Ages).
- **Extended interactions** (main purpose is continuous chat with an AI character, or AI keeps **cross-session memory**) -> answer Yes to "Extended AI" -> **Restricted, 18+ only**. Design rule for this game: no persistent chatbots, no saved AI conversation memory across sessions.
- Players must be told it's AI, e.g. "This is an AI-powered conversation, not human. It may make mistakes." and shown at start and throughout; steer medical/professional questions to authoritative resources and handle self-harm signals.

### 7.3 Feasibility: live reactions / social posts for released models
Design (all server-side):
- When a player "releases" a model, the server builds a small structured prompt (model name, benchmark stats, flavor tags) and calls `GenerateTextAsync` with a `SystemPrompt` such as a fictional tech-social-feed persona, `MaxTokens` ~60, and a `JsonSchema` for `{handle, post, sentiment}`; then `TextService:FilterStringAsync` (per recipient as required) and render in a feed GUI.
- Budget: 100 req/min/experience at launch. Batch: one call that returns 3-5 posts as an array via JsonSchema; cache per release; cooldown per player; global token-bucket in a ModuleScript; **fall back to pre-written template posts** on error/rate-limit.
- Use fictional companies/handles only (avoid real brand names/people).
- Seed + low temperature make tests reproducible; vary Seed per release for variety.
Verdict: **feasible and policy-compatible** if outputs are short, one-shot, filtered, disclosed, and not remembered across sessions. Treat as optional flavor, never as core loop.

Cheaper/safer alternative (recommended as the default): **pre-generate** thousands of reaction snippets and post templates with Claude Code at dev time into a Luau data module, assemble them procedurally at runtime (fill-in-the-blank with stats). Zero runtime cost, deterministic, fully reviewable for moderation, works offline, no rate limit. Use `TextGenerator` only as an "extra spice" layer.

Third path: `HttpService` to an external LLM (OpenAI/Anthropic). Possible (HTTP requests, server only, domain must be enabled; secrets must never reach the client) but you own moderation/disclosure, cost, uptime and the provider's ToS; not recommended for a kids-heavy audience.

### 7.4 `GenerationService` (runtime 3D)
- Class `GenerationService`: "generate 3D objects from text prompts" via Cube. `GenerateMeshAsync` (server, deprecated in favor of `GenerateModelAsync`), `LoadGeneratedMeshAsync` (client; EditableMesh not replicated; each generationId loads once), `GenerateModelAsync(inputs{TextPrompt|Image, Size, MaxTriangles, GenerateTextures}, schema{PredefinedSchema "Car5"/"Body1" or SchemaDefinition.Groups})` returns a Model; `SegmentMeshAsync` Studio-only.
- Runtime availability of `GenerateModelAsync` is not stated; rate/prompt limits and pricing not documented. Not needed for the tycoon core.

### 7.5 Other natural-language APIs
- `AudioTextToSpeech` (TTS, full release) and Speech-to-Text API (full release) exist; could voice an "AI lab announcer". Low priority.

## 8. Community MCP servers / plugins for Studio (Claude-compatible)

Now that the official server is built in, community servers are useful mainly for features the official one lacks (breakpoints, profiling, filesystem sync, richer scene ops). Security note: all of these run arbitrary Luau in your place via a plugin; prefer official first.

| Repo | Stars | Updated | Status/License | Tools / notes | Setup (Windows, Claude Code) |
|---|---|---|---|---|---|
| `boshyxd/robloxstudio-mcp` | 497 | archived 2026-06-06 | Archived (owner lost npm access); v2.7.0-next.6, 43 tools | Read-heavy 31-tool "Inspector" edition lists `get_file_tree`, `grep_scripts`, `get_playtest_output`, `capture_screenshot`, etc. | `claude mcp add robloxstudio -- npx -y robloxstudio-mcp@latest`; Windows fallback `cmd /c npx -y ...`; enable Allow HTTP Requests; install plugin |
| `Chrrxs/robloxstudio-mcp` (active fork) | 367 | 2026-11-10 | Based on boshyxd 2.7.0; 190 commits | Runtime debugging (`eval_server_runtime`, breakpoints), solo/multiplayer playtest, MicroProfiler/script profiler, memory breakdown, `find_and_replace_in_scripts`, Creator Store, monetization via Open Cloud (risky), docs/skills lookup | `claude mcp add robloxstudio -- npx -y @chrrxs/robloxstudio-mcp@latest --auto-install-plugin`, restart Studio, wait for "Connected" |
| `S4US/Roqer` | 200 | 2026-11-10 | AGPL-3.0 (<=0.1.6 MIT); desktop app | Own agent UI using ChatGPT/Claude/Gemini CLIs or any OpenAI/Anthropic-compatible API; diff review per script edit, autonomy levels; Blender, Rojo sync, animations; tools also usable as MCP | `git clone`, `npm install`, `npm run build:all`, `npm run start:desktop`; Node 20+ |
| `hope1026/weppy-roblox-mcp` | 76 | 2026-11-07 | Proprietary "WEPPY license" (Basic free, Pro paid), telemetry on by default | Sync, playtest, UI studio, up to 5 Studios; Pro-gated features | `npx -y @weppy/roblox-mcp@latest` (Node 22+) or installer script |
| `EL4CTEO/rbx-studio-mcp` | 14 | n/d | MIT; 35 tools + console panel | `tree`, `script_edit`, `playtest`, `screenshot`, datastore, terrain, etc. | `claude mcp add rbx-studio -- npx -y @el4cteo/rbx-studio-mcp`; plugin install via `--install-plugin`; port 44755 |
| `Mishaadevv/Roblox-MCP` | 0 | n/d | MIT; 50 tools | Launch/open places, GUI building | clone, npm build, copy `MCPBridge.luau` |
| RbxSync (`Smokestack-Games/rbxsync`, `devmarissa/rbxsync`; docs.rbxsync.dev) | n/d | n/d | Two repos found; canonical unclear | Extract game to files, sync to Studio, `run_code`, `run_test`, git tools; needs `loadstring` | cargo build; MCP config |
| `ZubeidHendricks/roblox-studio-mcp-claude-code` | n/d | n/d | Community Claude Code guide/server | Seen in search; not inspected | - |
| `Arther-hup/forge-context-engine` ("Nexus") | 76 | 2026-11-11 | MIT; Go, 263 commits | Project memory graph, staged pipelines (analyze/draft/review/validate/commit), snapshots/rollback around Claude Code; README is promotional, no install steps | evaluate before use |
| `roxlit/installer` | 5 | n/d | MIT | Sets up Rojo + MCP + "context packs" in `.roxlit/context/`; Windows x64, unsigned (SmartScreen warning) | - |
| `sebattfg/ZeroScript-Free` | 431 | 2025-09-25 | - | Browser extension turning chatbots into Studio agent | skip |
| `Claude-Reverser/MCP-Sploit` | 97 | 2026-05-07 | - | Drives Luau VM via an exploit executor dylib | **Avoid** (ToS-violating) |
| Ropilot, Ropanion (closed/DevForum plugins) | - | - | Commercial | In-Studio agent plugins | not needed |

Bottom line: use the official built-in MCP first. Add `Chrrxs/robloxstudio-mcp` only if you need profiler/breakpoint/multi-client playtest depth; keep its Open Cloud monetization tools disabled (its own README warns the agent controls the key's permissions and the "confirm" flag is self-set).

## 9. Skills, templates and CLAUDE.md conventions for Luau (community)

### 9.1 Skill packs (Claude Code)
| Repo | Stars | Updated | License | Content | Install |
|---|---|---|---|---|---|
| `gamedev-skills/awesome-gamedev-agent-skills` | 8.3k | 2026-11-11 | Apache-2.0 | 77 skills; 8 Roblox: `roblox-luau`, `roblox-datastores`, `roblox-ui`, `roblox-networking`, `roblox-characters`, `roblox-physics`, `roblox-studio-workflow`, **`roblox-simulator-economy`** (idle/tycoon cost curves, offline earnings); also a game-jam/prototyping workflow | `claude plugin marketplace add gamedev-skills/awesome-gamedev-agent-skills` then `claude plugin install gamedev@awesome-gamedev-agent-skills` (or `npx skills add gamedev-skills/awesome-gamedev-agent-skills`, Node 22.20+) |
| `brockmartin/roblox-game-skill` | 429 | 2026-03-04 | n/d | Lifecycle skill; 7 genre templates incl. **tycoon**; 7 workflows (debug loop, security audit, monetization audit, publish checklist); 3 MCP modes (written for older MCP, 39-tool full mode); no Rojo mention | skill in `~/.claude/skills/roblox-game/` |
| `SyphoDev-yt/roblox-ai-skills` | 151 | 2026-11-04 | n/d | `create-roblox-game` (README example: "make me a tycoon game"), Rojo+Knit scaffold, UI-from-JSON, map checker, Blender mesh/texture/anim, VFX, SFX; 7 agents | `install.ps1` then `/roblox-skills-setup`; Knit is aging/avoid |
| `MSayib/roblox-dev-skill` | 85 | 2026-11-08 | MIT | v2.22.0; SKILL.md router + 14 references: strict Luau, architecture, **server authority, remote validation, anti-exploit**, DataStores, UI, perf, monetization, Studio MCP guidance incl. "what an agent could break"; checked against Studio 0.746 / Luau 0.745; optional offline Roblox API docs | PowerShell `irm ... | iex` installer (inspect first) |
| `EL4CTEO/roblox-skills` | 106 | 2026-11-04 | MIT | 23 Agent Skills incl. `roblox-data-stores`, `roblox-monetization`, `roblox-analytics-liveops`, `roblox-npc-ai`, `roblox-studio-mcp`; also a zip for Studio Assistant Skills | `/plugin marketplace add EL4CTEO/roblox-skills` then `/plugin install roblox-skills@roblox-skills` |
| `andrian-syh/roblox-best-practices-skill` | 14 | 2026-11-08 | MIT | 43 reference files; mandatory script layout VARIABLES/FUNCTIONS/INITIALIZATION; acceptable-use rules | `install.ps1` |
| `gogolumo/rbsmithy-roblox-claude-skill` | 16 | 2026-11-06 | MIT free edition (Pro paid) | Luau, Rojo, multiplayer, release checks | copy to `.claude/skills/rbsmithy` |
| `izzyfrm/roblox-ai` | 198 | 2026-11-05 | n/d | 12k reference images + 2.2k CC0 SFX (UI/shop/HUD styles); attach 2-5 images per prompt; rights caveat | clone; reference only, build original art |
| `szlay/roblox-base` | 1 | 2026-07-26 | n/d | Template (Hungarian UI): CLAUDE.md, `.mcp.json`, 32 skills, check loop (format/lint/type on each edit), `/setup`, `/feature`, `/review`, `scripts/check.ps1`; rules: server decides, data must survive, no external executable content | read as a pattern for hooks |
| Others (tiny): `rodrigo-guerraa/roblox-hub`, `m4bwav/roblox-agent`, `WojciechJelen/roblox-dev-kit`, `zunxo7/luaumap` (token-efficient code map for Rojo projects), `Onur45500/blockforge`, `ishsharm0/roblox-gamesmith` | <=7 | recent | varies | Experimental | inspect before use |

Prompt-injection / supply-chain caution: skills are instructions Claude follows. Read them before installing; prefer a few well-scoped ones; pin versions; never run `curl | bash` blindly.

### 9.2 Tycoon reference implementations (read, don't copy blindly)
- `pogogt12/slime-tycoon-forge` (71 stars, MIT per README, 257 commits): README describes server-authoritative simulation, ledger with idempotency keys, session-locked DataStore, offline replay cap, headless balance simulator. Page showed only README/HTML - verify code exists.
- `Arshispro/luau-tycoon-core` (70 stars, MIT, 261 commits): `/src/server` authoritative services, Ledger Service, Station Registry, Upgrade DAG, Save Coordinator, typed Signal Bus. README-only visible.
- Both are patterns worth stealing (idempotent purchase ledger, single-writer saves) for the tycoon's economy.

### 9.3 CLAUDE.md conventions for a Luau/Rojo project (synthesized from the above)
Include in `CLAUDE.md`:
- Stack: Rojo 7.7.x, Rokit-pinned tools, `--!strict` everywhere, StyLua formatting, selene lint, luau-lsp type checks with a Rojo sourcemap.
- Layout: `src/server` -> ServerScriptService, `src/client` -> StarterPlayerScripts, `src/shared` -> ReplicatedStorage; `*.server.luau`, `*.client.luau`, `init.luau` rules.
- Authority rules: server owns currency/progression; client only requests; validate every RemoteEvent argument (type, range, rate-limit); never trust client-sent prices.
- Persistence: session-locked DataStore wrapper, schema version + migrations, retry with backoff, never write on every tick.
- Economy: data-driven tables (`Config/Models.luau`), pure functions for cost curves unit-tested with Jest/Lune.
- AI rules: all runtime AI text goes through one `AiTextService` module with rate limit, JsonSchema, filtering, fallback templates, disclosure string; no persisted conversation memory.
- Workflow rules: read before edit (matches OpenGameEval finding), run `scripts/check.ps1` after each change, playtest via MCP before declaring done, small commits, never touch monetization/ban/API-key settings, never `execute_luau` destructive ops without confirmation, back up/publish a version before large agent runs.
- Do not use deprecated libs: Roact (use react-luau or plain Instances), Knit (aging), TestEZ (use jest-roblox).
- Point Claude at the local clone of `Roblox/creator-docs` for API truth.

## 10. Rojo, luau-lsp and the file-based toolchain

| Tool | Link | Stars | Latest | Notes |
|---|---|---|---|---|
| Rojo | github.com/rojo-rbx/rojo | 1.9k | **v7.7.1** (Oct 2) | MPL-2.0. `rojo serve` + Studio plugin; `rojo sourcemap`; `rojo build`; `syncback`; v7.7.1 fixed Windows `\\?\` path issues. Docs: rojo.space/docs. |
| Rokit | github.com/rojo-rbx/rokit | 510 | **1.2.0** (Sep 30) | Toolchain manager (Foreman/Aftman replacement). Windows: `Invoke-RestMethod https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.ps1 \| Invoke-Expression` or `rokit.exe self-install`. `rokit.toml` pins versions. |
| luau-lsp | github.com/JohnnyMorganz/luau-lsp | 564 | **1.70.1** (2026-09-27) | Language server + `luau-lsp analyze` CLI for CI; reads Rojo `sourcemap.json` (`rojo sourcemap --watch default.project.json --output sourcemap.json`); companion Studio plugin for non-Rojo instances. VS Code/Neovim/Zed/JetBrains clients. No dedicated Claude Code LSP plugin found (generic Lua LSP plugins target lua-language-server, not Luau). Practical AI use: run `luau-lsp analyze --sourcemap sourcemap.json ...` in a hook after every edit so Claude gets type errors. |
| StyLua | github.com/JohnnyMorganz/StyLua | 2.3k | 2.6.0 referenced | `stylua --check`, `stylua.toml` (set `syntax = "Luau"`, tabs/spaces choice). |
| Selene | github.com/Kampfkarren/selene | 841 | n/d | Rust linter; `selene.toml` + Roblox std (`std = "roblox"`). |
| Wally | github.com/UpliftGames/wally | 511 | n/d | Package manager (MPL-2.0); `rokit add wally`. |
| Lune | github.com/lune-org/lune | 979 | **v0.11.1** (Oct 21) | Standalone Luau runtime; run pure-logic tests/scripts and place/model file manipulation without Studio. Not a game runner. |
| jest-roblox | github.com/Roblox/jest-roblox | 50 | 3.20.0 packages | Tests in Roblox or via Open Cloud Luau Execution. |

Workflow pattern repeated across community guides: Claude Code edits `.luau` files -> `rojo serve` syncs into Studio -> MCP verifies by playtest/console/screenshot. Official alternative: Script Sync (below).

### Script Sync (official, beta)
- Enable: File -> Beta Features -> Script Sync (restart Studio). Right-click a folder -> Sync to... -> choose directory. Two-way; resumes on reopen; "Open in External Editor".
- Layout: `name.luau` (ModuleScript), `.server.luau`, `.client.luau`, `.local.luau`, `.legacy.luau`, `.plugin.luau`, folders, `init.*.luau`.
- Limits: 10,000 scripts per top-level instance; 128 top-level instances; only Script/LocalScript/ModuleScript/Folder; scripts with attributes/tags can lose data; no external debugger control; avoid multi-person sync in Team Create.
- Docs: "If you want to version-control your entire project or make the file system the source of truth, Rojo is better."
- Official coding-harness guide (`ai/coding-harness.md`): Script Sync + MCP + AI editor, build in phases, commit once working, give the agent a spec file, allowlist MCP tools.
- **Recommendation for this game:** Rojo (entire project in Git, Rokit-pinned), with Studio used for assets/Workspace/terrain saved as `.rbxm` or the place file; use MCP for inspection/playtest.

### CI / headless
- Open Cloud **Luau Execution API** (OCALE): headless run of Luau in a place version; 5-minute task limit, 10 concurrent tasks per place, create endpoint ~5/min; key scope `universe.place.luau-execution-session:write`; poll task then read logs; plugin code often fails there. Used by `Roblox/place-ci-cd-demo` (archived), `rocale-cli`, jest-roblox.
- For cheap CI: Lune + luau-lsp analyze + StyLua check + selene on pure modules.

## 11. Evaluation / meta resources
- `Roblox/open-game-eval`: tasks are Lua files with prompt, place, setup, `check_scene`, `check_game`; submitted to an Open Eval API (needs Open Cloud key with `studio-evaluations`); 50 jobs/hour, 100/day; supports Claude/Gemini/OpenAI; leaderboard file; annotations for expected tool calls. Use to borrow the "inspect first, then edit" principle and to write your own eval prompts (e.g., "add upgrade X") with automated checks.
- Search listing on GitHub for "roblox claude" returns 393 repos; "roblox mcp" 448; i.e. the space is crowded - favor repos with commit history, license, and clear non-network behavior.

## 12. Gaps and open questions
- Exact Assistant/MCP generation quotas and pricing: not found.
- Whether `GenerateModelAsync` is runtime-callable: not stated.
- Whether `JsonSchema` in TextGenerator is stable/fully supported: listed in field table, absent from the summary line.
- Official DevForum text of the MCP/Assistant announcements was not directly readable; dates above are from search summaries.
- Whether Studio MCP exposes place-scoped skills to external clients: unconfirmed.

## 13. Recommended AI-assisted Roblox dev workflow (Windows, step by step)

Goal: Claude Code writes and tests Luau in a Git-based Rojo project, verifies in Studio via the official MCP, and ships a tycoon with a safe, optional runtime-AI flavor layer.

### Phase A - One-time machine setup
1. Install Roblox Studio (latest), sign in once, create/publish a blank experience (permissions are per published game).
2. Install Git for Windows, VS Code, Node.js LTS (for optional tools), and Claude Code (native Windows install). Keep PowerShell 7 handy.
3. Install **Rokit** via the PowerShell one-liner from its README; open a new terminal.
4. Create the repo; `rokit init`; `rokit add rojo-rbx/rojo`, `JohnnyMorganz/StyLua`, `Kampfkarren/selene`, `JohnnyMorganz/luau-lsp`, `lune-org/lune`, `UpliftGames/wally` (add `Roblox/jest-roblox` via Wally). Commit `rokit.toml`.
5. Install the Rojo VS Code extension and Luau Language Server extension; install the Rojo plugin into Studio (`rojo plugin install` or Creator Store); install the luau-lsp companion Studio plugin if desired.
6. Clone `Roblox/creator-docs` next to your project (or add it as a read-only reference folder, ignored by Git) so Claude can grep `content/en-us/reference/engine/classes/*.yaml`.

### Phase B - Connect Claude Code to Studio (official path)
7. In Studio: Assistant -> ... -> Manage MCP Servers -> enable "Studio as MCP server".
8. In Claude Code: `/plugin`, search "Roblox Studio", install the official plugin (or toggle Quick connect -> Claude Code, or add the `cmd.exe /c %LOCALAPPDATA%\Roblox\mcp.bat` server manually). Restart Claude Code.
9. Verify: `/mcp` shows `plugin:roblox-studio:windows` connected; ask Claude to "list my Roblox Studio windows".
10. In Studio -> MCP Permissions for your game: keep **Balanced**; leave Money/monetization, Player consequences, Security/credentials, `universe:write` OFF; do not approve upload folders until needed; leave "Connect to the internet" off.
11. In Claude Code settings, allowlist read-only MCP tools (`list_roblox_studios`, `script_read`, `script_search`, `script_grep`, `search_game_tree`, `inspect_instance`, `get_console_output`, `screen_capture`, `get_studio_state`) and keep `execute_luau`, `multi_edit`, `start_stop_play`, `insert_asset`, `open_cloud_invoke` on prompt-for-approval.

### Phase C - Project skeleton and guardrails
12. Scaffold `default.project.json` (Rojo) with `src/server`, `src/client`, `src/shared`, plus `stylua.toml`, `selene.toml`, `.luaurc`, `sourcemap.json` generation (`rojo sourcemap --watch`), `.gitignore` (place file, sourcemap, creator-docs clone).
13. Write `CLAUDE.md` per section 9.3 and a short `docs/` spec of the tycoon (loop: research -> train models -> release -> reputation/revenue -> upgrade lab). Reference `docs/research/01-reference-game.md` for the reference game study.
14. Add skills selectively: official plugin skill, `MSayib/roblox-dev-skill` (security/authority), and `gamedev-skills` `roblox-simulator-economy` + `roblox-datastores` + `roblox-ui`. Read each SKILL.md first.
15. Add a `scripts/check.ps1` (stylua --check, selene, `luau-lsp analyze`, Lune/Jest unit tests) and a Claude Code **PostToolUse hook** that runs it after Luau edits, so errors loop back to Claude (pattern from `szlay/roblox-base`).
16. Commit a clean baseline. Before any large agent run: Studio File -> Publish to Roblox As (version history) and `git commit`.

### Phase D - Daily loop
17. Start `rojo serve`; in Studio click Connect in the Rojo plugin. Open Claude Code in the repo.
18. Start each feature in **Plan** (Claude's plan mode, optionally Studio Assistant Plan for a second opinion). Plan in phases; each phase must be playtestable (official guidance).
19. Claude reads before it edits (inspect scripts/instances via MCP or files), edits `.luau` files, runs `check.ps1`, then verifies in Studio: `start_stop_play`, `get_console_output`, `screen_capture`, `character_navigation` / `user_*_input` for UI clicks (buy buttons, upgrade panels).
20. Put the economy in pure, data-driven modules and unit-test it with Jest/Lune (cost curves, offline earnings caps, prestige). Have Claude write a headless balance simulator.
21. Use Studio-native generators for assets: `generate_mesh` / Texture Generator for props, Material Generator for floors, procedural models for scalable server racks. Check moderation results and keep prompts original (avoid copying existing games' branded assets).
22. Commit per phase with a message that records the playtest evidence.

### Phase E - Runtime AI layer (optional, after the core loop works)
23. Build `AiTextService` (server module): token-bucket under ~60 req/min, structured prompt + `JsonSchema`, `MaxTokens` small, `pcall`, `TextService:FilterStringAsync`, template fallback, AI disclosure label in the feed UI, no persisted AI context.
24. Pre-generate a large library of reaction/post templates with Claude Code into `Config/Reactions.luau`; use `TextGenerator` only to remix flavor for "big release" moments.
25. Fill the Content Ratings Questionnaire honestly (AI text on screen); keep answers consistent with non-extended interactions.

### Phase F - Test, secure, ship
26. Remote/exploit audit pass (use `roblox-dev-skill` references) on every RemoteEvent and purchase path; DataStore session-lock review; Studio multiplayer test with 2-4 clients (`StudioTestService`) for join/leave and shared state.
27. Optional CI: GitHub Actions running Rokit tools, StyLua/selene/luau-lsp analyze and Lune/Jest tests on pull requests; defer OCALE runs until needed (quota, 5-minute limit).
28. Publish manually from Studio; keep monetization (game passes/dev products) configured by a human in Creator Hub, not by the agent.
29. Maintenance: re-check the DevForum "Creator Roadmap" and Assistant/MCP release posts monthly; tool names and quotas changed several times in 2026.

### When to deviate
- If Rojo friction appears, fall back to Script Sync (official) for scripts only.
- If you need profiling/breakpoints/multiclient depth, add `Chrrxs/robloxstudio-mcp` (active) but not its monetization tools.
- If Claude Code cannot see the Studio server (plugin shows macOS entry failing is normal; Windows entry failing is not), re-run `/plugin`, restart Studio and Claude, confirm `%LOCALAPPDATA%\Roblox\mcp.bat` exists, then fall back to the manual `cmd.exe /c` registration.

## 14. Source list (key links)
- GitHub: Roblox org https://github.com/Roblox ; plugin https://github.com/Roblox/roblox-studio-agent-plugin ; creator-docs https://github.com/Roblox/creator-docs ; archived server https://github.com/Roblox/studio-rust-mcp-server ; cube https://github.com/Roblox/cube ; open-game-eval https://github.com/Roblox/open-game-eval ; RobloxGuard https://github.com/Roblox/RobloxGuard-1.0 ; Chrrxs fork https://github.com/Chrrxs/robloxstudio-mcp ; boshyxd https://github.com/boshyxd/robloxstudio-mcp ; Roqer https://github.com/S4US/Roqer ; skills: https://github.com/gamedev-skills/awesome-gamedev-agent-skills , https://github.com/MSayib/roblox-dev-skill , https://github.com/EL4CTEO/roblox-skills , https://github.com/brockmartin/roblox-game-skill , https://github.com/SyphoDev-yt/roblox-ai-skills ; tooling: rojo-rbx/rojo, rojo-rbx/rokit, JohnnyMorganz/luau-lsp, JohnnyMorganz/StyLua, Kampfkarren/selene, UpliftGames/wally, lune-org/lune.
- Official docs (read via creator-docs source): studio/mcp, studio/mcp-open-cloud, assistant/guide, assistant/skills, assistant/mcp, ai/accelerated-workflows, ai/coding-harness, ai/build-with-assistant, ai/build, generative-AI, scripting/sync, studio/material-generator, studio/texture-generator, reference/engine/classes/TextGenerator, GenerationService.
- DevForum (via search summaries): "Studio MCP Server Updates and External LLM Support for Assistant" (4415631), "Assistant Updates: Mesh Generation, New MCP Server Tools, Screenshot Tool, and More" (4527258), "Assistant Updates: Introducing Creator-Authored Skills" (4728447), "New Studio Testing APIs and Assistant Improvements" (4657854), "Text Generation API Beta: Expanding Access" (3952348), "[Beta] Introducing Text Generation API" (3556520), "Creator Roadmap 2026: Fall Update" (4880208), "RDC26: What We Announced" (4865880), "Studio Script Sync Now in Beta" (4065468).
- Newsroom: Roblox Studio going agentic (April 2026), Introducing Roblox Cube (March 2025), Open-sourcing Roblox PII Classifier (Nov 2025), safety models via ROOST (Aug 2026), RDC 2026 post (Sept 2026).
