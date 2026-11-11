# 13. AI model types for the tycoon (beyond text LLMs)

Goal: the game currently only trains text chat models. This file lists 22 real AI model categories
companies sell, with examples, the year each became commercially good (for unlock timing), who pays,
a rough price, the typical scandal, and one game mechanic idea.

Confidence tags:
- [S] = checked in web search on 2026-11-11 (secondary sources, prices may be stale)
- [M] = background knowledge, not re-checked in this pass. Verify before shipping numbers.
- "Good year" is a judgment call for game unlock pacing, not a benchmark.

---

## 1. Image generation
- **Examples:** DALL-E (OpenAI), Midjourney, Stable Diffusion (Stability AI), Google Imagen / Nano Banana.
- **Good year:** 2023 (Midjourney v5 photorealism). Founded 2021 (DALL-E) and July-Aug 2022 (Midjourney, SD) [S].
- **Who pays:** consumers, ad agencies, game studios, e-commerce. Price: about $10-120/mo subscriptions [M].
- **Risk:** copyright suits. Getty v. Stability (UK): Stability mostly won in Nov 2025 [S]. Disney and Universal sued Midjourney; Warner Bros. also sued [S].
- **Game mechanic:** "Prompt Lab": spend credits on prompts, and bad prompts create off-brand art that sells for less.

## 2. Video generation
- **Examples:** OpenAI Sora (Sora 2 launched Sept 30, 2025 [S]), Google Veo 3.1, Kling (Kuaishou), Runway Gen-4.5 (Dec 2025 [S]).
- **Good year:** 2025 (Veo 3 and Sora 2 with synced audio) [M for Veo 3 date]. Veo 2 was announced Dec 2024 [S].
- **Who pays:** ad studios, creators, Hollywood previs. Price: about $0.10-0.50/sec via API [S, Sora/Veo tables].
- **Risk:** deepfakes of real people, Sora likeness misuse. One source says Sora was discontinued in 2026, which I could not confirm [S, unverified].
- **Game mechanic:** "Shot Budget": each clip costs seconds of runtime, and bad clips trigger a "viral backlash" event.

## 3. Music generation
- **Examples:** Suno (v3 era, late 2023), Udio, ElevenLabs Music (launched 2025 with Merlin and Kobalt licences [S]).
- **Good year:** 2024 (Suno v3, Udio). Suno's public history starts 2023 (Bark Apr 2023, web app Dec 2023) [S].
- **Who pays:** creators, indie game devs, ads, TikTok. Price: about $10-30/mo [M].
- **Risk:** label lawsuits (RIAA vs Suno and Udio, 2024) [M]. Licensed-vs-unlicensed training split.
- **Game mechanic:** "Charts": songs from your model enter a fake chart, and royalties depend on licensing deals you sign.

## 4. Text to speech (TTS)
- **Examples:** ElevenLabs (founded 2022, beta public Jan 2023 [S]), OpenAI TTS, Google Cloud TTS, Azure Neural TTS.
- **Good year:** 2023 (ElevenLabs), 2022-2023 for Azure neural voices [M].
- **Who pays:** audiobooks, YouTube, game studios (NPC voices), call centers. Price: ElevenLabs starts about $5/mo [M].
- **Risk:** fake political robocalls (2024 New Hampshire Biden robocall) [M].
- **Game mechanic:** "Voice Casting": hire voice styles for your NPCs. Each one has a hidden accent and emotion range.

## 5. Voice cloning
- **Examples:** ElevenLabs Instant/Professional Voice Cloning, Respeecher, Resemble AI.
- **Good year:** 2023. Some products clone from about 1 minute of audio [S, one source; treat as marketing].
- **Who pays:** dubbing studios, actors (licensed voice), accessibility (ALS voice banking), creators. Price: per-minute or subscription, about $5-100/mo [M].
- **Risk:** voice-fraud scams, impersonation of CEOs and family members. Consent and "voice rights" laws are new [M].
- **Game mechanic:** "Voice Contracts": sign real actors. Ignoring consent triggers a lawsuit event.

## 6. Speech to text (STT)
- **Examples:** OpenAI Whisper (open weights Sept 2022), Deepgram Nova-3, AssemblyAI Universal.
- **Good year:** 2022-2023 (Whisper made accurate STT cheap) [M for year].
- **Who pays:** call centers, meeting apps, media, medical notes. Price [S, varies by source]: Whisper API about $0.36/hr; AssemblyAI Universal about $0.15/hr; Deepgram Nova-3 about $0.26/hr batch.
- **Risk:** hallucinated text in medical transcripts (reported with Whisper, 2024) [M].
- **Game mechanic:** "Transcript Desk": transcribe jobs fast, but a low-accuracy model mis-tags customers and loses contracts.

## 7. Machine translation
- **Examples:** Google Translate (switched to neural MT in 2016 [S]), DeepL (launched Aug 2017 [S]), Microsoft Translator.
- **Good year:** 2016-2017.
- **Who pays:** businesses (localization), travelers, governments. DeepL Pro about $105-690 per user per year [S].
- **Risk:** mistranslation in legal and medical text, and misuse of translation for scams [M].
- **Game mechanic:** "Language Packs": unlock languages to sell to more markets. Wrong translations lower reviews in that market.

## 8. Code assistants
- **Examples:** GitHub Copilot (GA 2022 [M]), Cursor (2023 [M]), Claude Code, Windsurf.
- **Good year:** 2023 (GPT-4 era) [M].
- **Who pays:** developers, companies. Price [S]: Copilot Pro $10/mo, Pro+ $39/mo; Cursor Pro $20/mo; Copilot Business $19/user/mo.
- **Risk:** licensing and training-data suits (GitHub Copilot class action, filed 2022 [M]). Insecure generated code.
- **Game mechanic:** "Tech Debt": fast output is cheap, but bugs add hidden costs that show up in later server outages.

## 9. 3D model generation
- **Examples:** Meshy, Tripo, Rodin (Hyper3D), Sloyd.
- **Good year:** 2024-2025 for textured meshes [M].
- **Who pays:** indie game devs, Roblox and Unity creators, 3D printing. Price [S]: Tripo Pro $20/mo, Meshy Pro $20/mo, API credits about $0.01 each (Tripo).
- **Risk:** training on artists' models without consent; asset-store flooding [M].
- **Game mechanic:** "Asset Forge": generate props for the player's map. Low-poly models sell cheap, high-poly sell for more.

## 10. AI avatars and lip sync (talking heads)
- **Examples:** Synthesia (founded 2017, avatars from 2020 [M]), HeyGen, D-ID.
- **Good year:** 2023-2024.
- **Who pays:** corporate training, marketing, multilingual ads. Price [S]: Synthesia Starter about $19/mo; HeyGen Creator about $29/mo; Pro tiers $49-89/mo.
- **Risk:** deepfake scams with fake presenters, consent for face and voice use [M].
- **Game mechanic:** "Spokesperson": hire an AI avatar to sell your product. Trust drops if the avatar is caught lying.

## 11. Voice agents (AI phone and call bots)
- **Examples:** ElevenLabs Agents, Vapi, Retell AI, Bland AI.
- **Good year:** 2024-2025 (low-latency speech models) [M].
- **Who pays:** customer service, sales, clinics, restaurants. Price: about $0.05-0.15 per minute [M].
- **Risk:** robocall rules, impersonation, wrong promises made to customers [M].
- **Game mechanic:** "Receptionist": a bot answers customer calls. A bad answer costs reputation.

## 12. Self-driving (robotaxi)
- **Examples:** Waymo (driverless paid rides), Tesla Robotaxi (Austin, June 2025 [S]), Zoox, Baidu Apollo Go.
- **Good year:** 2020 for the first public driverless rides (Waymo, Phoenix) [M]. Scale and profit 2024-2026.
- **Who pays:** riders, cities (fleet contracts), delivery firms. Price: ride fare, often similar to a taxi [M].
- **Risk:** crashes, recalls, NHTSA probes. Waymo was reported at 14 US cities by Sept 2026 [S].
- **Game mechanic:** "Fleet": start with one car on one street. Each new city unlocks after a safety score threshold.

## 13. Robotics foundation models (VLA)
- **Examples:** Google Gemini Robotics (Mar 2025 [M]; 1.5 Sept 2025 [S]), Physical Intelligence pi0 (Oct 2024 [M]), Figure AI Helix (Feb 2025 [M]).
- **Good year:** not mature yet. Expect 2026-2028 for real factory jobs [M].
- **Who pays:** factories (BMW piloted Figure 02 for 11 months [S, company claim]), warehouses, home robots. Price: enterprise leases, unknown [M].
- **Risk:** injuries, safety certification, humanoid hype versus reality [M].
- **Game mechanic:** "Factory Shift": a robot does a task. Bad training shows up as slow output and random breakdowns.

## 14. Protein and biology (drug discovery)
- **Examples:** AlphaFold 2 (2020-2021), AlphaFold 3 (May 2024 [S]), Isomorphic Labs (founded 2021; $600M raise Apr 2025 [S]), EvolutionaryScale ESM3 [M].
- **Good year:** 2024 (AlphaFold 3, drug-discovery focus).
- **Who pays:** pharma (Lilly, Novartis, J&J partnerships [S]). Price: multi-million-dollar deals, milestone-based [M].
- **Risk:** biosecurity misuse (designing harmful proteins) [M]. Results that never reach clinical trials.
- **Game mechanic:** "Drug Pipeline": each candidate passes trials over many in-game years. Most fail; one wins a huge payout.

## 15. Weather forecasting
- **Examples:** Google GraphCast (2023), GenCast, WeatherNext (enterprise via BigQuery Mar 2025 [S]), WeatherNext 2 open weights Aug 2026 [S, secondary sources; check the licence].
- **Good year:** 2023-2025 (beats classic models on many metrics) [M].
- **Who pays:** airlines, insurers, energy traders, governments, farms. Price: enterprise data licences [M].
- **Risk:** big forecast misses during disasters; trust problems [M].
- **Game mechanic:** "Storm Insurance": forecast events and price coverage. Miss a hurricane, and payouts wipe out your margin.

## 16. Embeddings
- **Examples:** OpenAI text-embedding-3-small/large (Jan 25, 2024 [S]), Cohere Embed, Voyage AI, open models (BGE, E5).
- **Good year:** 2024 (cheap and good enough for RAG search) [M].
- **Who pays:** developers building search, RAG chatbots, companies. Price: cents per million tokens [M].
- **Risk:** low headline risk. Privacy leaks if stored vectors reveal source text [M].
- **Game mechanic:** "Index": sell fast search over the player's own data. Bad embeddings return wrong results and churn users.

## 17. AI search and answer engines
- **Examples:** Perplexity (main search product launched Dec 2022 [S]), ChatGPT search (2024 [M]), Google AI Overviews (2024 [M]).
- **Good year:** 2024.
- **Who pays:** consumers (about $20/mo Pro [M]), ads, enterprises.
- **Risk:** publisher lawsuits over scraping and summaries (for example Dow Jones v. Perplexity, Oct 2024 [M]).
- **Game mechanic:** "Citations": answers need sources. Unsourced answers lower trust and cost you the publisher deals.

## 18. OCR and document AI
- **Examples:** Mistral OCR (first release Mar 2025 [S]; OCR 4 since [S]), Google Document AI, AWS Textract, Azure Document Intelligence.
- **Good year:** 2025.
- **Who pays:** banks, insurers, law firms, government (invoices, forms). Price [S]: Mistral OCR about $4 per 1,000 pages ($2 batch).
- **Risk:** wrong extraction of amounts and names causing financial errors [M].
- **Game mechanic:** "Paperwork Office": clear the inbox of documents. Accuracy determines your fines.

## 19. Recommendation systems
- **Examples:** YouTube (DNN paper 2016 [M]), TikTok For You, Netflix, Spotify.
- **Good year:** 2016-2017 (deep learning recsys). Mature and profitable since then [M].
- **Who pays:** ad platforms, retailers, streaming. Price: runs inside a product, so it is not sold directly [M].
- **Risk:** addictive design, filter bubbles, EU Digital Services Act rules [M].
- **Game mechanic:** "Feed Tuning": the feed boosts your game ads. Player retention rises, but a "time well spent" meter can drop.

## 20. Game NPCs and generative characters
- **Examples:** Inworld AI (founded 2021 [M]), Convai, Replica, Roblox Cube and Roblox AI assistant tools [M].
- **Good year:** 2024 (real-time LLM dialogue with voice).
- **Who pays:** game studios, metaverse platforms. Price: usage-based or enterprise [M].
- **Risk:** NPCs saying offensive things, unsafe content, cost per conversation [M].
- **Game mechanic:** "Town Mind": NPCs remember what players did. A bad memory tweak makes a town riot.

## 21. Medical imaging AI
- **Examples:** IDx-DR (first autonomous FDA-authorized diagnostic, Apr 2018 [M]), Aidoc, Viz.ai, Paige.
- **Good year:** 2018 (first autonomous FDA clearance) to 2020s for scale [M].
- **Who pays:** hospitals, insurers, radiologist groups. Price: per-scan or per-seat contracts [M].
- **Risk:** missed diagnoses, bias, FDA recalls [M].
- **Game mechanic:** "Scanner": review scans fast. Missed cases cost lives and licences.

## 22. Computer-use and browser agents
- **Examples:** Anthropic computer use (beta Oct 2024 [M]), OpenAI Operator (Jan 2025 [M]), Google Project Mariner [M].
- **Good year:** 2025 (reliable enough for simple web tasks) [M].
- **Who pays:** enterprises (back-office), consumers. Price: subscription or per-task [M].
- **Risk:** unauthorized purchases, deleting data, prompt injection on web pages [M].
- **Game mechanic:** "Intern": give an agent tasks with limited permissions. One mistake triggers a refund event.

---

## Unlock timeline (suggested for the game)

| Era (game year) | Unlock categories |
|---|---|
| Early (2022-2023) | Image gen, TTS, voice cloning, STT, machine translation, code assistant |
| Mid (2024) | Video gen, music gen, 3D gen, avatars, embeddings, AI search, NPCs, protein biology |
| Late (2025) | Voice agents, OCR, computer-use agents, robotics (early), robotaxi |
| Endgame (2026+) | Robotics (factory scale), weather, medical imaging at scale, recsys upgrades |

## Notes on unverified items
- Sora discontinuation: sources conflict. Check OpenAI's official pages before using it in-game.
- Weather and some licensing claims come from secondary articles. Check the repositories.
- Prices in [M] items are from background knowledge and should be checked on vendor pricing pages.
