# 05 — AI Industry Economics: Real Numbers for an AI-Lab Tycoon

> Research brief for an original Roblox tycoon in which the player starts an AI lab in a garage around 2017 and grows it into a frontier lab racing toward AGI. The goal is **realistic numbers and events** that a designer can turn into balancing tables. The game should stay **original**: real companies are referenced here only as calibration data. In game, use fictional labs, chips and people.
>
> Compiled: November 2026. Method: about 60 web searches over Epoch AI, vendor spec sheets, financial reporting, court trackers and trade press. **Limits:** the shared web-search budget ran out before the "techniques" and "events" sections could be searched separately, and direct page fetches were blocked by the sandbox (epoch.ai, wikipedia.org, arxiv.org and a16z.com could not be fetched; only search-result summaries were available). Each fact is labelled:
> - **[V]** verified in this session from the linked search results, or
> - **[K]** well-established background knowledge (canonical paper or event) that was **not re-verified** this session. Check these before using them in marketing copy. They are fine for game balancing.
>
> Several late-2026 figures (valuations, run rates) come from single secondary reports. They are marked *(single source)*.

---

## Table of contents
1. [Scaling laws and training compute](#1-scaling-laws-and-training-compute)
2. [Hardware, datacenters, power, cloud prices](#2-hardware-datacenters-power-cloud-prices)
3. [Data](#3-data)
4. [Techniques timeline](#4-techniques-timeline)
5. [Business: funding, revenue, pricing, users](#5-business-funding-revenue-pricing-users)
6. [Talent](#6-talent)
7. [Industry events as random game events](#7-industry-events-as-random-game-events)
8. [Suggested era timeline for the game](#8-suggested-era-timeline-for-the-game)
9. [Realistic ranges table for designers](#9-realistic-ranges-table-for-designers)
10. [Ready-to-use game formulas](#10-ready-to-use-game-formulas)
11. [Sources](#11-sources)

---

## 1. Scaling laws and training compute

### 1.1 The core identity: compute ≈ 6·N·D
Training a dense transformer costs about **6 FLOP per parameter per token**: 2 for the forward pass and 4 for the backward pass.

`C ≈ 6 × N (parameters) × D (training tokens)`

Sanity checks from real models:

| Model | N | D | 6ND | Reported / estimated | Tag |
|---|---|---|---|---|---|
| GPT-3 (2020) | 175B | 300B | 3.15e23 | 3.14e23 (reported by OpenAI, per Epoch) | [V] |
| Llama 3.1 405B (2024) | 405B | 15.6T | 3.8e25 | 3.8e25 | [V] |
| DeepSeek-V3 (Dec 2024, MoE) | 37B *active* (671B total) | 14.8T | ≈3.3e24 | for MoE, use **active** params | [V] inputs |
| Chinchilla (2022) | 70B | 1.4T | 5.9e23 | — | [K] |

**Game note:** for mixture-of-experts (MoE) models, N in the formula is the *active* parameter count. That is how MoE buys "big model quality at small-model cost". It works well as a tech-tree upgrade.

### 1.2 Kaplan et al. (OpenAI, Jan 2020): "Scaling Laws for Neural Language Models"
- Loss falls as a power law in parameters, data and compute.
- **L(N) = (N_c / N)^α_N**, with **α_N ≈ 0.076** and **N_c ≈ 8.8×10¹³** non-embedding parameters [V].
- The companion laws (from the paper, [K]): L(D) = (D_c/D)^0.095 with D_c ≈ 5.4×10¹³ tokens, and L(C_min) = (C_c/C)^0.050.
- Kaplan's compute-optimal recipe favored **growing the model faster than the data** (N ∝ C^0.73). This recipe guided GPT-3: 175B parameters on only 300B tokens [V/K].

### 1.3 Hoffmann et al. (DeepMind, 2022): "Chinchilla"
- Parametric fit: **L(N, D) = E + A/N^α + B/D^β**
- Commonly cited constants: **E = 1.69, A = 406.4, B = 410.7, α = 0.34, β = 0.28** [V].
- A 2024 replication (Besiroglu et al., Epoch) refit them as **E = 1.82, A = 482, B = 2085, α = 0.35, β = 0.37**. It also argued the published constants were inconsistent with the paper's own headline result [V].
- Compute-optimal allocation: **N\* ∝ C^(β/(α+β))** and **D\* ∝ C^(α/(α+β))**, so both scale roughly as **C^0.5** [V].
- Rule of thumb: **about 20 tokens per parameter** is "Chinchilla-optimal" [K]. Chinchilla (70B params, 1.4T tokens) beat Gopher (280B) at the same compute.
- **The over-training era (2023 onward):** labs train well past 20 tokens per parameter because inference cost depends on N. Llama 3 405B used about 38 tokens/param. Small models use far more. Llama 3 8B used about 15T tokens, roughly 1,900 tokens/param [K].

**Game mechanic idea:** let the player choose the "tokens per parameter" ratio. A low ratio gives a cheaper training run but a worse and costlier-to-serve model. Around 20 gives the best quality per training dollar. A high ratio gives a model that is cheap to serve at scale.

### 1.4 Algorithmic progress
- Epoch (Ho et al., NeurIPS 2024): the compute needed to reach a fixed language-model performance level **halves about every 8 months** (90% CI roughly 2 to 22 months) [V].
- 60–95% of performance gains came from more compute and data. Algorithms contributed 5–40% [V].
- The Transformer alone was worth "almost two years" of algorithmic progress [V].
- **Game translation:** research upgrades multiply "effective compute". About 2.8× per year from algorithms, stacked on 4–5× per year from physical compute.

### 1.5 Compute growth trends (Epoch AI)
- **Frontier training compute grew 4–5× per year** from 2010 to May 2024 [V].
- Epoch's trends page (updated Feb 2026): frontier *language-model* compute has grown **about 5× per year since 2020** [V].
- Decomposition of that growth: **more chips about 1.69×/yr**, **longer training runs about 1.53×/yr**, **faster chips (FLOP/s per chip) about 1.41×/yr** [V].
- **Final-run training cost grows about 2.4× per year** (95% CI 2.0–3.1×) since 2016. At this rate the largest runs pass **$1B by about 2027** [V].
- Staff costs were **29–49%** of total amortized model-development cost for the models Epoch studied [V].
- Epoch counted **33 publicly known models trained with ≥10²⁵ FLOP** (as of its insight), all since GPT-4 in March 2023 [V]. Epoch projects about **10 models above 10²⁶ FLOP by 2026 and more than 200 by 2030** [V].

### 1.6 Notable training runs (calibration table)
| Year | Model | Params | Tokens | Train FLOP | Est. final-run cost | Hardware | Tag |
|---|---|---|---|---|---|---|---|
| 2017 | Transformer (big) | 213M | ~WMT | ~2e19 | <$10k | 8× P100, 3.5 days | [K] |
| 2018 | BERT-Large | 340M | 3.3B words | ~3e20 | ~$7k (TPU) | 64 TPU chips, 4 days | [K] |
| 2019 | GPT-2 | 1.5B | ~40GB WebText (~10B tok) | ~1.5e21 | ~$50k | TPUv3 | [K] |
| 2020 | GPT-3 | 175B | 300B | 3.14e23 | **$4.6M** (Lambda, at $1.50/V100-hr). Other estimates up to $12M | V100 cluster | [V] |
| 2022 | Chinchilla | 70B | 1.4T | 5.9e23 | ~$1–3M | TPUv3/v4 | [K] |
| 2022 | PaLM | 540B | 780B | 2.5e24 | ~$10M+ | 6,144 TPUv4, **MFU 46.2%** | [V] MFU |
| 2023 | GPT-4 | ~1.8T MoE (leak, unconfirmed) | ~13T (leak) | **2.1e25** | **~$40M** (Epoch, final run). **~$63M** (SemiAnalysis leak, $1/A100-hr). Altman: ">$100M" total | ~25,000 A100 × 90–100 days, **MFU 32–36%** | [V] |
| 2023 | Gemini 1.0 Ultra | ? | ? | **5e25** | ~$30M (Epoch) | ~57,000 TPU chips | [V] |
| 2024 | Llama 3.1 405B | 405B | 15.6T | 3.8e25 | ~$60M at $2/hr (≈30.8M H100-hrs) | 16,384 H100, **MFU 38–43%**, 54+ days | [V] |
| 2024 | DeepSeek-V3 | 671B (37B active) | 14.8T | ~3.3e24 | **$5.576M** (2.788M H800-hrs at $2; final run only, excludes R&D) | ~2,048 H800 | [V] |
| 2025 | Grok 3 | ? | ? | **3.5–4.6e26** | ~$100Ms | ~100k H100 (Colossus) | [V] |
| 2025 | Grok 4 | ? | ? | **~5e26** (largest known run at the time) | **~$490M** (246M H100-hrs) | Colossus, 200k+ GPUs. Energy ≈ a town of 4,000 people. ~154kt CO₂. ~754M L water | [V] |
| 2025–26 | Frontier (GPT-4.5, Claude Opus 4.5-class) | ? | ? | **~10^26.5–10^27** (third-party read of Epoch) | $0.5–1B+ | 100k–400k GPU clusters | [V] (low confidence) |

**Takeaway curve for the game (frontier final-run compute):**
`2017: ~1e20 → 2018: 1e21 → 2019: 1e22 → 2020: 3e23 → 2022: 2e24 → 2023: 2e25 → 2024: 5e25 → 2025: 5e26 → 2026: ~1e27 → 2028 (projection): ~1e28 → 2030 (projection): ~1e29`
Note: the 2018–2019 steps are interpolated, not measured.

---

## 2. Hardware, datacenters, power, cloud prices

### 2.1 Accelerator progression
Dense throughput is listed. Vendor "sparse" numbers are 2× these, so be careful when comparing.

| Chip | Year | Low-precision dense throughput | Memory | Bandwidth | Power | Approx. price | Tag |
|---|---|---|---|---|---|---|---|
| GTX 1080 Ti (garage tier) | 2017 | ~11 TFLOPS FP32 | 11 GB | 484 GB/s | 250 W | ~$700 | [K] |
| **V100** | May 2017 | 125 TFLOPS FP16 tensor | 16/32 GB HBM2 | 900 GB/s | 300 W | ~$8–10k (unverified MSRP $10k). DGX-1 (8×V100) ~$150k | [V]/[K] |
| TPU v3 | 2018 | ~123 TFLOPS BF16 | 32 GB | — | — | cloud only | [K] |
| **A100** | May 2020 | 312 TFLOPS BF16 | 40/80 GB HBM2e | 1.6–2.0 TB/s | 400 W | ~$10–15k | [V] specs, [K] price |
| TPU v4 | 2021 | 275 TFLOPS BF16 | 32 GB | 1.2 TB/s | — | cloud | [K] |
| **H100 SXM** | 2022–23 | **989 TFLOPS BF16**, ~1,979 FP8 | 80 GB HBM3 | 3.35 TB/s | 700 W | **$25–30k** (Raymond James est.; reported up to $40k street). **Est. build cost ~$3,320** | [V] |
| H800 / A800 / H20 | 2023–24 | China-compliant cut-downs (reduced interconnect or compute) | — | — | — | — | [V] |
| TPU v5e / v5p | 2023 | 197 / 459 TFLOPS BF16 | 16 / 95 GB | — | — | cloud. v5p pod = 8,960 chips | [V] |
| **H200** | 2024 | ≈H100 compute | **141 GB HBM3e** | 4.8 TB/s | 700 W | ~$30–35k [K]. Cloud ~$2.45–2.58/hr | [V] |
| TPU v6e Trillium | 2024 | 918 TFLOPS BF16 | 32 GB | — | — | 256-chip pod | [V] |
| **B200** | 2024–25 | ~2,250 BF16, **~4,500 FP8**, ~9,000 FP4 TFLOPS | 192 GB HBM3e | 8 TB/s | ~1,000 W | **~$30–40k** (industry est.) | [V] |
| **GB200 NVL72** (rack: 72 GPUs + 36 CPUs) | 2025 | **~720 PFLOPS FP8 dense**, 1,440 PFLOPS FP4 (sparse) | ~13.5 TB HBM | NVLink 130 TB/s | **~120–132 kW per rack**, liquid-cooled | **~$3.0–3.4M per rack** | [V] |
| **B300 / GB300 (Blackwell Ultra)** | 2025 | ~1.5× B200 FP4 (14 PFLOPS sparse FP4) | **288 GB HBM3e** | 8 TB/s | 1,200–1,400 W | — | [V] |
| TPU v7 Ironwood | 2025 | **2,307 BF16 / 4,614 FP8 TFLOPS** | 192 GiB | 7.37 TB/s | — | **9,216-chip pod**, 1.77 PB HBM | [V] |
| **Vera Rubin NVL144** | H2 2026 | **50 PFLOPS FP4 per GPU**. Rack 3.6 EF FP4 (3.3× GB300 NVL72) | 288 GB **HBM4** | — | — | — | [V] |
| **Rubin Ultra NVL576** | H2 2027 | about 4× Rubin NVL144 per rack | 1 TB HBM4e per package. 365 TB per rack | — | ~600 kW rack [K] | — | [V] |
| **Feynman** | 2028 | next-gen / "custom" HBM, 3D stacking | — | — | — | — | [V] |

**Patterns worth modelling:**
- About **1.4× per year FLOP/s per chip** (Epoch) [V]. Big jumps come with each generation (~every 2 years) and with precision changes (FP16 → FP8 → FP4).
- Memory is the real bottleneck for inference. HBM capacity grew 16 GB → 80 → 141 → 192 → 288 GB → 1 TB/package from 2017 to 2027.
- Per-chip power grew 300 W → 400 → 700 → 1,000 → 1,400 W. Rack density grew from ~10 kW to ~130 kW to ~600 kW. That drives the shift from air to liquid cooling.
- **Nvidia gross margin is huge.** A ~$3.3k build cost against a ~$25–30k price is about 800–1,000% markup [V]. The game can include a mid-game "build your own chip (TPU-like)" project that cuts unit cost but needs years of R&D.

### 2.2 Nvidia data-center revenue (a demand thermometer)
| Fiscal year (ends late Jan) | Data-center revenue | Tag |
|---|---|---|
| FY2023 (≈2022) | $15.0B | [V] |
| FY2024 (≈2023) | $47.5B | [V] |
| FY2025 (≈2024) | $115.2B | [V] |
| FY2026 (≈2025) | $193.7B | [V] |

### 2.3 Shortages and supply chain
- **2023 H100 shortage:** Dell quoted **~39-week** lead times for H100 servers. Omdia reported 36 weeks up to a year. Some OEMs waited 6 months for chips [V].
- **Root cause: TSMC CoWoS advanced packaging.** Nvidia used 40–50% of CoWoS capacity. TSMC met only about 80% of CoWoS demand in 2023, and expected about 1.5 years to ease [V].
- **Easing:** by April 2024, Dell lead times were down to **8–12 weeks** [V].
- **Game event:** "Packaging bottleneck". Chip orders are delayed 6–12 months and the spot rental price spikes 2–3×.

### 2.4 Cloud GPU rental prices over time
| Period | H100 price / GPU-hour | Notes | Tag |
|---|---|---|---|
| 2020 | V100 ~$1.50 (Lambda), A100 ~$1–4 | GPT-3-era pricing | [V] |
| Late 2023 (peak shortage) | **$7–10** marketplace. SemiAnalysis index ~$6.62 | — | [V] |
| Late 2024 | down to ~$2.85–3.50 (−64% from peak) | supply caught up | [V] |
| Jun 2025 | Silicon Data index **$2.36** | — | [V] |
| Dec 2025 → Jan 2026 | $2.00 → $2.20 (**+10% rebound in 4 weeks**) | demand returns | [V] |
| Feb 2026 | SemiAnalysis index ~$2.83 | — | [V] |
| 2026 hyperscaler list prices | Azure ~$6.98, Oracle $10.00 PAYG. Vast.ai ~$1.65 | 4× spread between marketplace and hyperscaler | [V] |
| H200 (2025–26) | ~$2.45–2.58 | CoreWeave, Nebius | [V] |
| Epoch's Grok 4 costing | $1.90–2.20 per H100-hr (90% CI) | — | [V] |

**Game pattern:** each new chip enters at a premium of about $6–10/hr, during a shortage. It then decays by about 50–70% over 18–24 months, and shows small rebounds when a demand wave hits.

### 2.5 Model FLOPs Utilization (MFU)
MFU is the share of the chips' peak FLOP/s that actually does useful training work.

| Run | MFU | Tag |
|---|---|---|
| GPT-3 (2020) | 21.3% | [V] |
| Megatron-Turing NLG | 30.2% | [V] |
| Gopher | 32.5% | [V] |
| GPT-4 (leak) | 32–36%, hurt by failures and checkpoint restarts | [V] |
| Llama 3 405B | 38–43% | [V] |
| PaLM 540B | 46.2% (HFU 57.8%) | [V] |
| ByteDance MegaScale (175B on 12,288 GPUs) | 55.2% | [V] |

**Game knob:** MFU starts around 20% in the garage and can be upgraded to about 55% through "infra engineering" research. Big clusters should suffer **hardware-failure events**. Llama 3 reported frequent GPU and host failures during its 54-day run [K].

### 2.6 Datacenter build cost, power, cooling
- **Cost per GW of AI capacity:** Jensen Huang has put it at **$50–60B per GW** all-in (Sep 2025 remarks, repeated to G20 ministers). Nvidia's equipment share grew from **~$18B to $40B+ per GW** as it started selling networking, CPUs and storage too. Critics (Chanos) say the non-GPU shell, power and cooling alone is **$20–30B per GW**. Huang has also said a 1 GW factory earns **~$50B per year in rental revenue** [V].
- **xAI Colossus (Memphis):** **100,000 H100s installed in 122 days**, online in Sept 2024 in a converted Electrolux factory. Initial grid power was ~150 MW, bridged with **mobile gas turbines** (reported 35 turbines / ~420 MW, which became a local-pollution controversy). Colossus 2 (Southaven, MS) targets **>1 GW**, which SemiAnalysis calls the "first gigawatt datacenter". Reported combined target is ~2 GW by end of 2026. Reported cost is ~$7B for the first phase [V].
- **Stargate (OpenAI, Oracle, SoftBank, Jan 2025):** **$500B over 4 years and ~10 GW** headline. Abilene, TX: ~1.2 GW planned. About 0.2–0.3 GW was operational by April 2026 (Epoch estimate). Up to 400,000 Nvidia chips. A planned extra 600 MW Abilene expansion was dropped in 2026, with Microsoft taking over an adjacent site. Six more US sites are under construction, with >9 GW projected by 2029 [V].
- **Hyperscaler capex (Amazon, Microsoft, Alphabet, Meta):** ~**$410B in 2025**, and ~**$700–745B planned for 2026** (+~77%). Rough 2026 split: Amazon ~$200B, Microsoft ~$190B, Alphabet $175–185B, Meta $125–145B [V]. For reference, the 2023 total was around $150B [K].
- **US grid share:** data centers used **1.9% of US electricity in 2018 (76 TWh)** and **4.4% in 2023 (176 TWh)**. Projection: **6.7–12% by 2028 (325–580 TWh)** (LBNL/DOE, Dec 2024) [V].
- **Rack density and cooling:** legacy racks run 5–15 kW. Air cooling tops out around 20–40 kW. **GB200 NVL72 is ~120–140 kW per rack** and needs direct-to-chip liquid cooling. Best hyperscale PUE is ~1.10. Liquid-cooled AI halls reach 1.03–1.15. Air-cooled sites run 1.2–1.4+ [V].
- **Nuclear deals:** Microsoft and Constellation signed a **20-year PPA to restart Three Mile Island Unit 1** (835 MW, ~$1.6B restart, target 2028). Amazon bought a **$650M datacenter campus** at Talen's Susquehanna nuclear plant, which was later challenged by utilities over grid impact [V]. Google and Kairos Power signed an SMR deal (Oct 2024, ~500 MW by 2035) [K].

**Simple power math for the game:** an H100 server uses ~10.2 kW per 8 GPUs, so about 1.3 kW per GPU all-in. **100k H100 ≈ 150 MW. 1 GW ≈ 500k–700k Blackwell-class GPUs** (with ~1.8 kW per GB200 GPU all-in) [V/derived].

---

## 3. Data

### 3.1 Dataset sizes over time
| Year | Dataset / model | Size | Tag |
|---|---|---|---|
| 2018 | BERT (BooksCorpus + Wikipedia) | 3.3B words | [K] |
| 2019 | GPT-2 WebText | 40 GB, ~8M pages | [K] |
| 2020 | GPT-3 | 300B tokens seen (from ~570 GB filtered Common Crawl + books + Wiki) | [V]/[K] |
| 2022 | Chinchilla | 1.4T tokens | [K] |
| 2023 | Llama 2 | 2T tokens | [K] |
| 2023 | GPT-4 (leak) | ~13T tokens (incl. repeated epochs) | [V] |
| 2024 | FineWeb (open) | 15T tokens of filtered Common Crawl | [K] |
| 2024 | Llama 3 / 3.1 | 15–15.6T tokens | [V] |
| 2024 | DeepSeek-V3 | 14.8T tokens | [V] |
| 2025 | Qwen3 | **36T tokens, 119 languages** (≈2× Qwen2.5's 18T) | [V] |
| 2025 | Llama 4 | ~30T+ tokens (multimodal) | [K] |

**Trend:** frontier dataset size grew about 2.5–3× per year [K, consistent with Epoch].

### 3.2 The "data wall"
- Epoch: the effective stock of quality-adjusted **public human text is ~300T tokens** (90% CI 100T–1,000T). Frontier runs would **use all of it between 2026 and 2032**, or earlier if models are heavily over-trained [V].
- Epoch also notes that exhausting public text does **not** necessarily halt progress. Escape routes include synthetic data, multimodal data, RL environments, private data and repeated epochs [V].
- **Synthetic data** [K]:
  - The Phi series (Microsoft) used "textbook-quality" synthetic data.
  - Reasoning models are trained by RL on verifiable problems (math, code), which in effect produces synthetic data.
  - Risk: "model collapse" when models recursively train on their own output (Shumailov et al., *Nature* 2024).
- **Game mechanic:** a "Data" resource that depletes. Each training run consumes tokens. When the free web pool is exhausted, the player must buy licenses, generate synthetic data (costs compute, with a collapse risk if overused), or build RL environments.

### 3.3 Licensing deals (cost of data)
| Deal | Value | Tag |
|---|---|---|
| Reddit → Google (Feb 2024) | **~$60M per year**. Reddit's IPO filing: $203M total data contracts over 2–3 years | [V] |
| Reddit → OpenAI (May 2024) | ~$70M per year reported | [V] |
| News Corp → OpenAI (May 2024) | **up to $250M over 5 years** (largest disclosed) | [V] |
| AP → OpenAI (Jul 2023) | 2-year deal, undisclosed (first major news deal) | [V] |
| Axel Springer → OpenAI (Dec 2023) | undisclosed ("tens of millions €/yr" reported) | [V]/[K] |
| Shutterstock (all AI buyers, 2023) | ~$104M AI-licensing revenue | [V] |
| Typical Big Tech publisher deal | $25–50M each (per Reddit CFO, secondary) | [V] |
| Meta → Scale AI (Jun 2025) | ~$14.3B for 49%, and CEO Alexandr Wang joined Meta | [K] |

### 3.4 Lawsuits (risk events)
- **Bartz v. Anthropic:** authors' class action. Judge Alsup ruled in June 2025 that training on lawfully acquired books is fair use, but downloading pirated libraries is not [K]. This led to a **$1.5B settlement (~$3,000 per book for ~500k works)** [V amount; per-book figure K]. Its final approval was still under submission in mid-2026, per one tracker [V].
- **NYT v. OpenAI and Microsoft** (filed Dec 2023): still active. Summary-judgment briefing closed in April 2026, and NYT amended its complaint in June 2026. No merits ruling yet [V].
- **Getty v. Stability AI:** the **UK High Court largely sided with Stability on 4 Nov 2025**. Getty won a narrow trademark point and has permission to appeal. In the US, the motion to dismiss was denied in April 2026, so the trademark claims survive [V].
- **Volume:** a tracker listed **51 US copyright suits against AI companies by Oct 2025**, rising to ~139 entries on its Aug 2026 litigation map [V].

---

## 4. Techniques timeline
*This section is mostly [K]. The search budget ran out before targeted searches could be made. The dates and headline claims are from the canonical papers, linked in section 11.*

| Year | Technique | What it improved | Rough size of effect (game-usable) |
|---|---|---|---|
| 2017 | **Transformer** ("Attention Is All You Need", Jun 2017) | Parallel training; replaced RNNs | Epoch: worth ~2 years of algorithmic progress [V]. In game: ×3–5 effective compute |
| 2017 | Mixed-precision training (FP16), PPO (RL) | Cheaper training | ×2 throughput |
| 2018 | **Pre-train then fine-tune** (GPT-1, BERT) | One model, many tasks | Unlocks "products" |
| 2019 | GPT-2 (1.5B), staged release over "misuse" fears | Zero-shot generation | First safety-PR event |
| 2020 | **Scaling laws** (Kaplan); GPT-3 in-context learning | Predictable returns to compute | Unlocks a "forecasting" stat |
| 2021 | Codex/Copilot; CLIP/DALL·E; RoPE; LoRA | Code; image-text models; cheap fine-tuning | New revenue lines |
| 2022 | **Chinchilla** (compute-optimal data) | Same compute, better model | ~×2–4 effective compute vs Kaplan allocation |
| 2022 | **InstructGPT / RLHF** (Mar 2022) | Helpfulness | Labelers preferred a **1.3B InstructGPT over the 175B GPT-3**, i.e. ~100× parameter-equivalent on usefulness [K] |
| 2022 | Chain-of-thought prompting; FlashAttention | Reasoning; memory-efficient attention | FlashAttention ~2–4× attention speed |
| 2022 (Nov) | **ChatGPT** (product, not technique) | UX | 100M MAU in ~2 months [V] |
| 2023 | **GPT-4**, multimodal input; Constitutional AI / RLAIF; DPO; open weights (Llama) | Quality jump; cheaper alignment | Open weights become a market force |
| 2023–24 | **Mixture-of-Experts** (Mixtral, GPT-4 rumored, DeepSeek) | Quality per FLOP | Active params ≈ 5–10% of total. ~3–5× cheaper at equal quality |
| 2024 | **Long context** (Gemini 1.5: 1M–10M tokens) | Whole-codebase or book input | Context 2k (2020) → 8–32k (2023) → 128k–1M (2024) |
| 2024 | GPT-4o native multimodal (voice, vision); speculative decoding; FP8 training | Real-time voice; inference speed | Inference ×2–3 cheaper |
| 2024 (Sep) | **Reasoning / test-time compute** (OpenAI o1) | Math, code, science | Second scaling axis: accuracy rises ~log-linearly with thinking tokens |
| 2025 (Jan) | **DeepSeek-R1** (open reasoning via RL with verifiable rewards); **distillation** | Cheap reasoning | Frontier-like reasoning at a fraction of the cost [V cost of V3] |
| 2025 | **Agents** (computer use, coding agents: Claude Code, Codex), tool use, MCP | Multi-hour autonomous tasks | METR: the length of tasks agents can complete has doubled about every 7 months since 2019 [K] |
| 2025–26 | RL scaling, "RL environments" economy; huge MoE; agent-driven revenue | Autonomy | Claude Code alone at **>$2.5B run rate** by Feb 2026 [V] |
| 2026+ (speculative) | Automated AI research, continual learning | Self-improvement loop | Game endgame: "recursive self-improvement" multiplier |

**Distillation:** a big "teacher" model trains a small "student". It typically keeps 90%+ of quality at a fraction of the cost to serve. This is behind small models such as GPT-4o mini at $0.15 per million input tokens [V price].

---

## 5. Business: funding, revenue, pricing, users

### 5.1 Funding and valuations (calibration; game labs are fictional)
**OpenAI-like trajectory**
| Date | Event | Valuation | Tag |
|---|---|---|---|
| 2015 | Non-profit founded, "$1B pledged" (far less actually given) | — | [K] |
| 2016 | Total first-year spend ~$11M, ~$7M of it on salaries | — | [V] |
| Jul 2019 | Microsoft invests $1B; capped-profit structure | — | [V] |
| Jan 2023 | Microsoft multi-billion expansion (~$10B; total commitment $13B, of which $11.6B funded by Sep 2025) | **$29B** (early-2023 deal) | [V] |
| Oct 2023 → Feb 2024 | Employee tender offer | **$86B** | [V] |
| Oct 2024 | $6.6B round (Thrive, Microsoft, Nvidia, SoftBank) | **$157B** | [V] |
| Mar 2025 | $40B round led by SoftBank ($30B) | **$300B** post | [V] |
| Oct 2025 | Secondary sale; recapitalization into a PBC (Microsoft ~27%, stake worth ~$135B) | **$500B** | [V] |
| Feb–Mar 2026 | $110B announced at $730B pre, closed at **$122B** (Amazon, Nvidia, SoftBank) | **$852B** | [V] |
| Nov 2026 | First close ~$11B of a larger round | **$1.25T** *(single source)* | [V] |

**Anthropic-like trajectory**
| Date | Event | Valuation | Run-rate revenue | Tag |
|---|---|---|---|---|
| 2021 | Founded by ex-OpenAI staff | — | — | [K] |
| Mar 2025 | Series E | ~$61.5B | ~$1–2B | [K] |
| Sep 2025 | Series F ~$13B | **$183B** | ~$5B | [V] |
| Feb 2026 | Series G **$30B** | **$380B** | **$14B**, ">10× growth per year for 3 years". Claude Code >$2.5B | [V] |
| Apr 2026 | — | — | crossing $30B | [V] |
| May 2026 | Series H **$65B** | **$965B** | **$47B** | [V] |
| end Jul 2026 | — | — | **>$65B** (Bloomberg, unconfirmed) | [V] |

**xAI:** Series E of $20B at ~$230B. **Merged into SpaceX in Feb 2026**, with xAI valued at $250B inside a combined $1.25T [V].
**Other labs (all [K]):** Mistral (~€11.7B, 2025), Safe Superintelligence (~$32B with no product, 2025), Thinking Machines Lab (~$2B seed at ~$12B, 2025). These are good templates for "a star researcher spins out and raises billions on reputation" events.

**Valuation-to-revenue multiples:** at frontier labs, typically **20–40× run-rate revenue** (e.g. $380B / $14B ≈ 27×; $965B / $47B ≈ 20×; $300B / ~$12B ≈ 25×) [derived].

### 5.2 Revenue and burn
- **OpenAI:**
  - 2024 revenue ~$3.7B with a ~$5B loss [K].
  - **2025 revenue ~$13B. Reported 2025 net loss of $38.5B** (one report citing audited financials) [V].
  - Run rate: **~$20B at end-2025 → $25B in Feb 2026 → >$40B in Aug 2026 → ~$50B (FT) or ~$70B (Axios, grossed-up) in Sep 2026**. Target was $70B+ by end-2026 [V].
  - Projected cash burn: **$115B through 2029** (The Information, 2025). Later reports say **~$280B through 2030** [V].
  - Ads business: ~$1B run rate in 2026 [V].
- **Anthropic:** run rate **$1B (end-2024) → ~$9B (end-2025) → $14B (Feb 2026) → $47B (May 2026) → $65B+ (Jul 2026)** [V/K].
- **Lesson for the game:** frontier labs lose money for years because compute capex outruns revenue. The game loop should let the player run **deeply negative cash flow funded by raises**. The fail state is "can't raise the next round".

### 5.3 API pricing (price collapse)
| Date | Model class | Input $/M tokens | Output $/M tokens | Tag |
|---|---|---|---|---|
| 2020–21 | GPT-3 davinci | $60 (blended) | $60 | [V] |
| Late 2022 | GPT-3.5-level (text-davinci-003) | **~$20** | ~$20 | [V] |
| Mar 2023 | GPT-3.5-turbo | $2 → $1.50 → $0.50 | — | [K] |
| Mar 2023 | **GPT-4 (8k)** | **$30** | **$60** | [V] |
| Nov 2023 | GPT-4 Turbo | $10 | $30 | [K] |
| May 2024 | GPT-4o | $5 → **$2.50** | $15 → **$10** | [V] |
| Jul 2024 | **GPT-4o mini** | **$0.15** | **$0.60** | [V] |
| Late 2024 | GPT-3.5-level quality from cheapest models | **~$0.07** (≈280× drop in ~2 years, from $20) | — | [V] |
| 2025–26 | Frontier "pro" and reasoning tiers | $1–15 | $10–75+ | [K] |

- **Rate of decline:** a16z "LLMflation" estimates **~10× per year cheaper at constant capability** [V]. Epoch: **9× to 900× per year depending on the capability threshold (median ~50×)**. A Feb-2026 update (secondary) gives 5–10×/yr, or ~47% per quarter [V].
- **Counter-trend:** the frontier price per token stays roughly flat at $2–15 per million input tokens. Reasoning models use 10–100× more tokens per task, so **cost per task can rise** even while cost per token falls [V].

### 5.4 Consumer subscriptions and users
- Price points: **$20/month** (ChatGPT Plus, Feb 2023; Claude Pro; Gemini Advanced) and **$200/month** "Pro/Max" tiers (late 2024–2025) [K].
- ChatGPT users:
  - **100M MAU in Jan 2023**, about 2 months after launch.
  - 100M WAU in Nov 2023; 200M (Aug 2024); 300M (Dec 2024); 400M (Feb 2025); 500M (Mar 2025); ~700M (Aug 2025); **800M (Oct 2025)**.
  - **900M WAU and 50M paying subscribers (Feb 2026)**, so ~5.5% convert to paid.
  - **~1B WAU around mid/late 2026**, about seven months later than OpenAI's internal goal [V].
- **Game numbers:** paid conversion is 3–6% of weekly actives. Consumer ARPU is about $20–25 per paid user per month.

### 5.5 Inference cost and margins
- **Huang's rule of thumb:** a $50–60B GW-scale factory → ~$50B/yr rental revenue, about a 1–1.2-year gross payback before power and operations [V].
- Labs report inference **gross margins of roughly 40–60%**, squeezed by free users and by the reasoning-token explosion [K].
- **Enterprise:** large seat deals run $20–60 per seat per month. Big multi-year cloud and compute commitments now reach hundreds of billions [K], e.g. OpenAI–Oracle ~$300B over 5 years (Sep 2025) and the AWS–OpenAI $38B deal (Nov 2025).

---

## 6. Talent

| Data point | Value | Tag |
|---|---|---|
| OpenAI top researcher pay, 2016 (non-profit, Form 990) | **Ilya Sutskever $1.9M** (incl. sign-on, $900k base). Ian Goodfellow >$800k. Pieter Abbeel $425k | [V] |
| 2017 (same filings) | Top earner ~$749k | [V] |
| 2025–26 frontier-lab software engineer median total comp | OpenAI ~$555–795k. Anthropic ~$600–710k (self-reported, equity illiquid). OpenAI base ~$350–400k | [V] |
| Research scientist | OpenAI L4 ~$771k → L5 ~$1.47M (median ~$1M). Anthropic RS median ~$746–827k | [V] |
| Meta Superintelligence Labs, summer 2025 | Packages of **$100M+** over several years, mostly stock ("$100M sign-on bonus" claims disputed). **Ruoming Pang (from Apple): $200M+** (Bloomberg). Thinking Machines staff reportedly turned down **$200M to $1B+** offers (Meta disputes the reporting) | [V] |
| Headcount | OpenAI: ~4,500 (Mar 2026), with plans to reach ~8,000 by end-2026. Historical [K]: ~120 (2019), ~375 (early 2023), ~770 (Nov 2023 board crisis letter), ~3,000 (2025). Anthropic: smaller than OpenAI [V for 2026 figure] |
| Core team behind a frontier model | 100–300 core contributors; GPT-4 credits listed ~280 people [K] |

**Game translation:**
- Talent tiers:
  - Intern: $50k/yr
  - Engineer: $200–400k
  - Senior researcher: $1M
  - "Star" researcher: $10M+/yr equivalent, poachable
  - "Legend": $100M+ package
- Poaching events: a rival offers 2–10× salary. If the player doesn't match (cash or equity), the researcher leaves and takes a research multiplier with them.
- Equity matters: late-game labs pay mostly in stock. Model "illiquid equity" as cheap now but a dilution risk later.

---

## 7. Industry events as random game events
Each entry gives the real-world anchor, then a suggested in-game effect. Events marked [K] were not re-verified this session.

### 7.1 Supply and hardware
| Event (real anchor) | Game effect |
|---|---|
| **H100 shortage 2023**: 39-week lead times; CoWoS packaging limits [V] | Chip orders queued 6–12 months; rental prices ×2–3 |
| **GPU rental price collapse 2024–25**: $8 → $2/hr [V] | Cheap compute window: −60% rental cost |
| Rental rebound Dec 2025 (+10% in 4 weeks) [V] | +10–30% rental cost |
| Large-cluster hardware failures (GPT-4's low MFU attributed to failures and restarts) [V] | Training run loses 5–15% progress unless "checkpointing" is researched |
| New chip launch delays (Blackwell 2024 design respin) [K] | Next-gen hardware arrives 1–2 quarters late |

### 7.2 Geopolitics and export controls
| Event | Game effect |
|---|---|
| **Oct 2022 US controls** cut China off from A100/H100 [V] | Region-locked markets; "compliant" lower-tier chip SKUs |
| **Oct 2023** update closes the A800/H800 loophole [K] | Specific chip SKUs banned mid-game |
| **Jan 2025 "AI Diffusion Rule"** (tiered countries) → **rescinded 13 May 2025** [V] | Temporary sales cap on foreign datacenters, then lifted |
| **Apr 2025 H20 license requirement**, reversed ~3 months later [V] | Nvidia-like vendor takes a write-down; supply whiplash |
| Using Huawei Ascend chips anywhere deemed a violation (May 2025 guidance) [V] | Compliance-risk event for using rival chips |

### 7.3 Open-source and competitive shocks
| Event | Game effect |
|---|---|
| **DeepSeek-V3/R1, Jan 2025**: "$5.6M" model [V] → Nvidia lost ~$590B in market value in one day (27 Jan 2025) [K] | Player's API prices forced −50%; investor sentiment −20% |
| Llama weights leak (Mar 2023), then official open releases [K] | Commodity floor: low-tier model revenue → 0 |
| Competitor launches a free tier or price cut [V price history] | Market share −10% unless matched |

### 7.4 Governance, drama, people
| Event | Game effect |
|---|---|
| **OpenAI board fires CEO, 17 Nov 2023**; ~95% of ~770 staff threaten to quit; CEO reinstated within 5 days [K] | "Board crisis": 3–7 day freeze on all actions; morale check; possible loss of the team |
| Co-founder or chief scientist departs to start a rival (SSI 2024; Anthropic founding 2021; Thinking Machines 2025) [K] | Lose 1 star researcher + 5–15% of staff; new rival lab spawns |
| **Meta poaching wave, summer 2025** ($100M–$200M+ packages) [V] | Bidding war: match the offer or lose talent |
| Recapitalization / structure fights (Musk v. OpenAI suit 2024–26; OpenAI PBC conversion Oct 2025) [V/K] | Legal costs; temporary block on fundraising |
| Mega-merger (xAI into SpaceX, Feb 2026) [V] | Late-game "merge with a conglomerate" option |

### 7.5 Legal and regulatory
| Event | Game effect |
|---|---|
| **Authors' class action → $1.5B settlement** (Bartz v. Anthropic, 2025) [V] | Fine scaled to the data used: ~$3k per pirated book |
| **NYT v. OpenAI** (Dec 2023 → ongoing) [V] | Ongoing legal drain of $X per month; possible injunction on a data source |
| Getty v. Stability (UK ruling for Stability, Nov 2025) [V] | Lawsuit coin-flip event; win = reputation boost |
| **EU AI Act**: in force 1 Aug 2024; bans apply Feb 2025; general-purpose AI model obligations Aug 2025; **10²⁵ FLOP "systemic risk" threshold**; fines up to 7% of global turnover [K] | Crossing 1e25 FLOP triggers compliance costs (evals, reporting); EU market lockout if ignored |
| US Executive Order 14110 (Oct 2023; 10²⁶ FLOP reporting threshold) → revoked Jan 2025 [K] | Regulation pendulum event |
| California SB 1047 vetoed (Sep 2024); SB 53 signed (Sep 2025) [K] | State-law event: transparency-report requirement |
| Italy temporarily bans ChatGPT (Mar–Apr 2023) [K] | Country market shut for 1 month |

### 7.6 Safety and reliability incidents
| Event | Game effect |
|---|---|
| Chatbot misbehavior PR crisis (Bing "Sydney", Feb 2023) [K] | Reputation −; usage −5% unless "alignment" research is done |
| Sycophancy rollback (GPT-4o update rolled back, Apr 2025) [K] | Forced model rollback; lose a week of progress |
| Image model historical-accuracy controversy (Gemini, Feb 2024) [K] | Feature disabled for a month; stock price −5% |
| Major outage (ChatGPT multi-hour outages 2023–24; cloud region failures) [K] | Revenue loss for X hours; churn +1% |
| Jailbreak or misuse report (bio/cyber uplift evaluations) [K] | Regulators demand evals; −20% speed for one model release |
| Prompt-injection or agent mishap (agents deleting data) [K] | Enterprise trust − |

### 7.7 Energy and infrastructure
| Event | Game effect |
|---|---|
| **Grid connection queue** → xAI uses gas turbines; pollution complaints [V] | Choose: wait 1–3 years for grid power, or pay for turbines (+cost, +reputation hit) |
| **Nuclear restart deal** (Three Mile Island, 835 MW by 2028) [V] | Unlock a "nuclear PPA": cheap clean power after a 3–4 year delay |
| Datacenter share of US power 4.4% → 6.7–12% [V] | Rising electricity price as player capacity grows |
| Stargate site expansion cancelled (Abilene +600 MW) [V] | Partner pulls out; capacity −X% |
| Water usage controversy (Grok 4 ~754M liters) [V] | Local permit denied without investing in "closed-loop cooling" |

### 7.8 Market and finance
| Event | Game effect |
|---|---|
| Record mega-rounds ($40B 2025; $122B 2026) [V] | "Hot market": valuation multiple ×1.5 |
| "AI bubble" fears / capex-trap headlines (2026) [V] | Valuation multiple ×0.6; next raise harder |
| Revenue-metric dispute (OpenAI $50B vs $70B, "grossed-up") [V] | Credibility event: investor trust − |

---

## 8. Suggested era timeline for the game
Game time can be compressed (e.g. 1 real minute = 1 in-game week). The eras below anchor which techs, chips, prices and events unlock.

### Era 0 — "The Garage" (2017)
- **Hardware:** consumer GPUs (GTX 1080 Ti class, ~11 TFLOPS, ~$700). One V100-class workstation is a luxury (~$10k). Cloud V100 ~$1.50–3/hr.
- **Compute frontier:** ~1e19–1e20 FLOP. Training runs cost $1k–$100k.
- **Unlocks:** "Attention" (Transformer) research; first paper; Kaggle-style contests for prize money.
- **Money:** savings, angel checks of $50k–$2M. Researcher salary $150k–$1M+ for top names (cf. a $1.9M package in 2016).
- **Events:** "Big Tech poaches your cofounder"; "conference best-paper award" (reputation).

### Era 1 — "Pretraining" (2018–2019)
- **Hardware:** V100 clusters, TPU v3 pods.
- **Frontier:** 1e21–1e22 FLOP; models of 100M–1.5B params; datasets of 3B words to 40GB.
- **Unlocks:** pre-train + fine-tune; "staged release" safety decision (GPT-2 event).
- **Money:** first strategic partner ($1B-class cloud-credit deal in 2019 is the real anchor). Seed/Series A at $10M–$1B valuations.

### Era 2 — "Scaling" (2020–2021)
- **Hardware:** **A100** (312 TFLOPS BF16, 40/80GB).
- **Frontier:** 3e23 FLOP; 175B params; 300B tokens; ~$5–12M training run; MFU ~21%.
- **Unlocks:** scaling-laws research (lets the player *forecast* loss); API product (pricing ~$60/M tokens); code models; image models.
- **Money:** revenue tens of millions; valuations $1–20B.

### Era 3 — "The Chat Boom" (2022–2023)
- **Hardware:** **H100** (989 TFLOPS BF16, $25–30k). **Shortage event:** 39-week lead times; rental $7–10/hr.
- **Frontier:** 2e25–5e25 FLOP; ~$40–100M; MoE; RLHF; 1.4T → 13T tokens.
- **Unlocks:** RLHF → chatbot product (100M users in 2 months); $20/mo subscription; API price $30/$60 → $10/$30.
- **Money:** $29B → $86B valuations; revenue $1–4B; ~400–800 staff.
- **Events:** board crisis; Italy ban; NYT lawsuit; export controls; Sydney incident; open-weight leak.

### Era 4 — "Reasoning & Capex" (2024–2025)
- **Hardware:** H200 → **B200 / GB200 NVL72** ($3M racks, 120 kW, liquid cooling); TPU Ironwood pods of 9,216 chips; rental collapses to ~$2/hr for H100.
- **Frontier:** 1e26 → 5e26 FLOP; ~$100–500M runs; 100k–200k GPU clusters (built in ~4 months); 150 MW → 1 GW sites; gas turbines; nuclear PPAs.
- **Unlocks:** test-time reasoning (new scaling axis); long context (1M); distillation; MoE efficiency (the DeepSeek shock); agents/coding tools.
- **Money:** $157B → $300B → $500B valuations; revenue $4B → $13B; losses $5B → $38B; hyperscaler capex ~$410B.
- **Events:** DeepSeek shock; diffusion rule on/off; H20 ban; $1.5B copyright settlement; poaching wars ($100–200M packages); EU AI Act general-purpose AI obligations.

### Era 5 — "Agents & Gigawatts" (2026–2027)
- **Hardware:** **Vera Rubin NVL144** (HBM4, 50 PF FP4 per GPU) → **Rubin Ultra NVL576** (~600 kW racks, 2027). Each GW costs $50–60B.
- **Frontier:** ~1e27 → 1e28 FLOP; $1B+ runs; multiple GW campuses; data wall reached (public text ~300T tokens used up); synthetic data and RL environments become the main data source.
- **Unlocks:** autonomous agents (multi-day tasks), agent marketplaces, ads, enterprise "AI employees".
- **Money:** $380B → ~$1T valuations; run rates $25B → $65B+; capex ~$700B/yr industry-wide; IPO or mega-merger option.
- **Events:** bubble scare; partner cancels expansion; grid-queue crisis; revenue-accounting scandal; regulatory compute thresholds triggered.

### Era 6 — "The AGI Race" (2028+, speculative / game fiction)
- **Hardware:** "Feynman-class" chips, 3D-stacked custom HBM, own-silicon option; 5–10 GW campuses; space or orbital datacenters as a fictional stretch goal (cf. SpaceX–xAI merger narratives).
- **Frontier:** 1e28–1e30 FLOP; $10–100B runs.
- **Unlocks:** automated AI researchers (research speed ×N), recursive self-improvement; win condition "AGI" gated by alignment/safety research to avoid a "bad ending".
- **Events:** international treaty or compute caps; nationalization threat; catastrophic-misuse incident; superstar defection; power-grid emergency.

---

## 9. Realistic ranges table for designers

| Quantity | 2017 | 2020 | 2023 | 2025 | 2026–27 | 2028+ (extrapolated) |
|---|---|---|---|---|---|---|
| Frontier training compute (FLOP) | 1e19–1e20 | 3e23 | 2e25–5e25 | 3e26–5e26 | 1e27–1e28 | 1e28–1e30 |
| Frontier final-run cost | $10k–$100k | $5–12M | $40–100M | $100–500M | $0.5–2B | $5–100B |
| Largest cluster (GPUs) | 8–256 | ~10k V100 | ~25k A100 | 100k–200k H100/GB200 | 400k–1M | multi-million |
| Site power | <1 MW | ~10 MW | 20–50 MW | 150 MW–1 GW | 1–2 GW per campus | 5–10 GW |
| Per-chip dense low-precision TFLOPS | 125 (V100) | 312 (A100) | 989 BF16 / 1,979 FP8 (H100) | 4,500 FP8 / 9,000 FP4 (B200) | 50,000 FP4 (Rubin) | ~100k+ |
| HBM per chip | 16 GB | 40–80 GB | 80 GB | 141–288 GB | 288 GB–1 TB | 1–2 TB |
| Chip price | $8–10k | $10–15k | $25–40k | $30–40k (rack $3M) | $40–60k [extrap.] | — |
| Cloud $/GPU-hr (newest gen) | $1.5–3 (V100) | $1–4 (A100) | $4–10 (H100 peak) | $2–3.5 (H100); $3–6 (B200) | $2–8 | — |
| MFU | 15–25% | ~21% | 32–40% | 38–46% | 40–55% | 50–60% |
| Training tokens | <10B | 300B | 2–13T | 15–36T | 30–100T (incl. synthetic) | synthetic-dominated |
| Params (frontier) | 0.1–0.3B | 175B | 0.5–1.8T (MoE) | 0.4–2T+ (MoE) | multi-T MoE | — |
| Context window | 512 | 2k | 8k–32k (128k late) | 128k–1M | 1M–10M | — |
| API price, frontier (input $/M) | — | $60 | $30 → $10 | $1–15 | $1–15 (flat at frontier) | flat |
| API price, fixed capability | — | $60 | $2–20 | $0.07–0.15 | ~$0.01 | ~0 |
| Price decline at fixed quality | — | — | ~10×/yr | 10–50×/yr | 5–10×/yr | — |
| Top-lab valuation | $0.1–1B | $1–20B | $29–86B | $157–500B | $380B–$1.25T | trillions |
| Top-lab revenue (run rate) | ~0 | <$0.1B | $1–4B | $5–20B | $25–70B | $100B+ |
| Annual loss (top lab) | $10–30M | ~$0.5B | $0.5–5B | $5–40B | $15–50B | — |
| Mega-round size | $1B pledges | $1B | $10B | $40B | $30–122B | — |
| Staff (top lab) | 50–100 | 150–300 | 400–800 | 2,000–3,000 | 4,500–8,000 | — |
| Senior researcher pay (TC) | $0.3–2M | $0.5–1M | $0.8–1.5M | $1–10M | $1–$200M (stars) | — |
| Weekly active users (top chatbot) | — | — | 100M | 400–800M | 900M–1B+ | — |
| Paid conversion | — | — | ~3% | ~5% | ~5–6% | — |
| Hyperscaler capex (big 4) | ~$70B | ~$110B | ~$150B | ~$410B | ~$700–745B | $800B+ |
| Datacenter share of US power | ~2% | ~2.5% | 4.4% | ~5–6% | 6–8% | 6.7–12% (2028) |
| Data licensing deal size | — | — | $10–60M/yr | $60–250M (multi-yr) | — | — |
| Copyright settlement | — | — | — | $1.5B (≈$3k/book) | — | — |
| Cost per GW of AI DC | — | — | — | $35–50B | $50–60B | — |

---

## 10. Ready-to-use game formulas
These are derived from the sources above. Tune the constants for fun; the shape matches reality.

1. **Training compute:** `C = 6 · N_active · D` (FLOP).
2. **Wall-clock training time:** `T_hours = C / (GPUs × peak_FLOPs × MFU × 3600)`.
   - Example: 1e25 FLOP on 10,000 H100 (989e12) at 40% MFU = 1e25 / (10,000 × 3.96e14 × 3,600) ≈ **701 hours ≈ 29 days**.
3. **Training cost:** `Cost = GPU_hours × $/GPU_hr`.
   - Example above: 7.0M GPU-hours × $2 = **$14M**. Llama 3.1 405B (3.8e25) works out to ~$60M, which matches the reported scale.
4. **Loss / "IQ" (Chinchilla-style):** `L = E + A / N^0.34 + B / D^0.28` with E = 1.69, A = 406.4, B = 410.7. Map loss to a game "Capability Score", e.g. `Score = 100 × (3.0 − L)`.
   - Use **effective compute** = physical compute × algorithmic multiplier. The multiplier doubles every ~8 months of research.
5. **Chinchilla-optimal sizing:** `N_opt ≈ sqrt(C / 120)`, `D_opt ≈ 20 · N_opt`.
   - At C = 1e24: N ≈ 91B, D ≈ 1.8T.
   - At C = 1e26: N ≈ 0.9T, D ≈ 18T.
6. **Hardware price decay:** `rental_price(t) = launch_price × 0.55^(years since launch)`, plus shortage events (×2–3) and rebounds (+10–30%).
7. **API price at fixed capability:** `price(t) = p0 / 10^(years)` (LLMflation). Frontier price stays flat; the capability score rises.
8. **Power:** `MW ≈ GPUs × kW_per_GPU_all_in / 1000` (H100 ≈ 1.3–1.5 kW all-in; GB200 ≈ 1.8–1.9 kW). `Facility_MW = IT_MW × PUE` (1.1–1.4).
9. **Datacenter capex:** `$/GW ≈ $50–60B` (late era). About 60–70% of that is chips and networking; the rest is shell, power and cooling. Build time: 4 months (heroic, Colossus-style) to 24 months (normal), plus a 1–5 year grid queue unless on-site generation is bought.
10. **Valuation:** `Valuation ≈ run_rate_revenue × multiple`. Multiple ~20–40× in a "hot market", ~10× in a "bubble-fear" event; frontier capability adds a premium.
11. **Users → revenue:** `paid = WAU × 0.05`; `consumer_rev = paid × $20–25 × 12`; API/enterprise ≈ 1–1.5× consumer revenue in later eras.
12. **Data pool:** `public_text = 300T tokens` (shared global pool, slowly growing). Each run consumes D tokens; repeated epochs give diminishing returns after ~4 passes [K: Muennighoff et al. 2023]. Synthetic data costs compute (`~1 FLOP-equivalent per generated token × model size`) and adds a "collapse risk" if it exceeds about 50% of the mix.

---

## 11. Sources
Grouped by section. A [K] fact without a link here comes from canonical literature that was not fetched this session.

### Scaling and compute
- Epoch AI — Training compute of frontier AI models grows by 4–5x per year: https://epoch.ai/blog/training-compute-of-frontier-ai-models-grows-by-4-5x-per-year
- Epoch AI — Trends (updated Feb 2026): https://epoch.ai/trends
- Epoch AI — Training compute decomposition: https://epoch.ai/data-insights/training-compute-decomposition
- Epoch AI — How much does it cost to train frontier AI models (2.4x/yr): https://epoch.ai/blog/how-much-does-it-cost-to-train-frontier-ai-models ; paper https://arxiv.org/abs/2405.21015
- Epoch AI — Models over 1e25 FLOP: https://epoch.ai/data-insights/models-over-1e25-flop
- Epoch AI — Large-scale AI models data: https://epoch.ai/data/large-scale-ai-models?view=table
- Epoch AI — Model counts by compute threshold: https://epoch.ai/blog/model-counts-compute-thresholds
- Epoch AI — Grok 4 training resources: https://epoch.ai/data-insights/grok-4-training-resources ; coverage https://mezha.media/en/news/grok-4-costs-490-million-usd-304898
- Epoch AI llms.txt (largest known run, Grok 4 ~5e26): https://epoch.ai/llms.txt
- AI 2027 tracker (frontier 10^26.5–10^27): https://ai2027-tracker.com/predictions/training-compute/
- Ho et al., Algorithmic progress in language models: https://arxiv.org/abs/2403.05812 ; NeurIPS https://proceedings.neurips.cc/paper_files/paper/2024/hash/6b066da6a23bc55f9b887e7298102884-Abstract.html
- Kaplan et al. 2020: https://arxiv.org/pdf/2001.08361.pdf ; notes https://cs.uwaterloo.ca/~k587pate/notes/scaling-laws-kaplan.html
- Chinchilla constants and replication: https://www.emergentmind.com/topics/chinchilla-scaling-law ; https://theorempath.com/papers/chinchilla ; https://marikgoldstein.github.io/posts/scaling-laws.html
- Lambda — GPT-3 technical overview ($4.6M): https://lambda.ai/blog/demystifying-gpt-3
- GPT-4 leak summary (SemiAnalysis via The Decoder): https://the-decoder.com/gpt-4-architecture-datasets-costs-and-more-leaked/
- Meta Llama 3.1 blog: https://ai.meta.com/blog/meta-llama-3-1/ ; case study https://ttsugriy.github.io/distributed-training-book/synthesis/34-case-study-llama3
- DeepSeek-V3 technical report: https://arxiv.org/abs/2412.19437
- PaLM paper (MFU table): https://arxiv.org/pdf/2204.02311
- MegaScale (55.2% MFU): https://huggingface.co/papers/2402.15627
- Lambda MFU white paper: https://lambda.ai/hubfs/4.%20Resources/White%20Papers/Lambda%20MFU.pdf

### Hardware, datacenters, power
- H100 specs: https://www.thundercompute.com/blog/nvidia-h100-specs-full-guide ; https://inferencex.semianalysis.com/chips/h100
- H100 cost and margin (Raymond James via Tom's Hardware): https://www.tomshardware.com/news/nvidia-makes-1000-profit-on-h100-gpus-report ; https://www.techspot.com/news/99839-nvidia-garners-reported-1000-profit-each-h100-gpu.html
- B200 specs and price: https://jarvislabs.ai/ai-faqs/nvidia-b200-specs ; https://getdeploying.com/reference/cloud-gpu/nvidia-b200
- GB200 NVL72: https://www.nvidia.com/en-us/data-center/gb200-nvl72/ ; https://inferencex.semianalysis.com/chips/gb200-nvl72 ; https://aiwiki.ai/wiki/nvidia_gb200 ; https://mars.exxactcorp.com/blog/hpc/nvidia-blackwell-deployments-gb200-nvl72-dgx-hgx-b200-hgx-b100
- H200 / B300: https://www.runpod.io/articles/guides/nvidia-h200-gpu ; https://vast.ai/article/nvidia-b300-vs-h200-blackwell-ultra-upgrade ; https://introl.com/blog/nvidia-blackwell-ultra-b300-infrastructure-requirements-2025
- V100 / A100: https://datacrunch.io/blog/nvidia-v100-gpu-specs ; https://www.tomshardware.com/news/nvidia-ampere-A100-gpu-7nm ; https://getdeploying.com/gpus/nvidia-a100-vs-nvidia-v100
- Google TPU7x Ironwood docs (with v5p/v6e comparison): https://docs.cloud.google.com/tpu/docs/tpu7x ; https://www.storagereview.com/news/google-ironwood-tpu-a-massive-leap-in-ai-inference-performance
- Nvidia roadmap (Rubin, Rubin Ultra, Feynman): https://www.tomshardware.com/pc-components/gpus/nvidia-announces-rubin-gpus-in-2026-rubin-ultra-in-2027-feynam-after ; https://www.networkworld.com/article/3848394/nvidia-details-its-gpu-cpu-and-system-roadmap-for-the-next-three-years.html ; https://www.tweaktown.com/news/110521/nvidia-updates-roadmap-with-new-details-on-its-next-gen-gpu-feynman-coming-in-2028/index.html
- Nvidia data-center revenue: https://www.pcgamer.com/hardware/nvidia-reports-a-truly-astonishing-usd193-7-billion-in-annual-data-center-revenue-in-its-latest-earnings-call-up-75-percent-year-on-year-while-little-old-gaming-brought-in-usd16-billion/ ; https://bullfincher.io/companies/nvidia-corporation/revenue-by-segment
- H100 shortage / CoWoS: https://www.theregister.com/2024/04/11/dell_ai_server_lead_times/ ; https://www.3dincites.com/2023/07/iftle-563-is-cowos-capacity-causing-a-gpu-shortage/ ; https://www.trendforce.com/news/2023/08/29/news-cowos-demand-surges-tsmc-raises-urgent-orders-by-20-non-tsmc-suppliers-benefit/
- GPU rental prices: https://www.silicondata.com/blog/h100-rental-price-over-time ; https://www.silicondata.com/blog/h100-price-spike ; https://introl.com/blog/gpu-cloud-price-collapse-h100-64-percent-drop-2025 ; https://intuitionlabs.ai/articles/h100-rental-prices-cloud-comparison ; https://www.codesota.com/hardware/h100
- Cost per GW: https://cryptobriefing.com/nvidia-g20-ai-infrastructure-investment/ ; https://fourweekmba.com/ai-huang-says-nvidia-now-sells-over-40b-of-gear-per-gigawatt/ ; https://www.tftc.io/jensen-huang-1gw-ai-factory-50-billion-rent-payback ; https://www.tikr.com/blog/jensen-huang-two-gigawatts-to-us-is-like-80-billion-43-new-gigawatts-coming-in-2027
- xAI Colossus: https://convergedigest.com/xai-activates-project-colossus-in-memphis-with-100k-h100-gpus/ ; https://newsletter.semianalysis.com/p/xais-colossus-2-first-gigawatt-datacenter ; https://www.bisnow.com/national/news/data-center/musk-xai-building-memphis-data-center-bigger-faster-than-ai-rivals-131026 ; https://infra-insider.beehiiv.com/p/inside-xai-s-1-2-gigawatt-leap ; https://www.globaldatacenterhub.com/p/can-elon-musks-7b-colossus-in-memphis
- Stargate: https://epochai.substack.com/p/openai-stargate-where-the-us-sites ; https://www.tomshardware.com/tech-industry/oracle-rebuts-incorrect-reporting-on-stargate-expansion ; https://www.wsls.com/business/2026/03/27/microsoft-takes-over-a-texas-ai-data-center-expansion-after-openai-backs-away/ ; https://finance.yahoo.com/news/openai-first-stargate-hold-400-180014007.html
- Hyperscaler capex: https://finance.yahoo.com/sectors/technology/articles/hyperscalers-hit-700-billion-2026-111243744.html ; https://aiweekly.co/alerts/amazon-microsoft-alphabet-meta-plan-725b-ai-capex-in-2026 ; https://techstrong.ai/articles/big-techs-unprecedented-725-billion-bet-on-ai-infrastructure-in-2026/
- LBNL/DOE data-center energy report: https://www.energy.gov/articles/doe-releases-new-report-evaluating-increase-electricity-demand-data-centers ; https://www.datacenterdynamics.com/en/news/doe-data-centers-consumed-44-of-us-power-in-2023-could-hit-12-by-2028
- Liquid cooling / rack density: https://blogs.nvidia.com/blog/blackwell-platform-water-efficiency-liquid-cooling-data-centers/ ; https://introl.com/blog/gb200-nvl72-deployment-72-gpu-liquid-cooled ; https://coreweave.com/blog/why-you-need-liquid-cooling-for-ai-performance-at-scale
- Three Mile Island / Microsoft: https://www.tomshardware.com/tech-industry/artificial-intelligence/microsoft-inks-deal-to-restart-three-mile-island-nuclear-reactor-to-fuel-its-voracious-ai-ambitions ; https://www.eenews.net/articles/microsoft-inks-deal-to-restart-three-mile-island-to-power-ai

### Export controls
- https://www.tomshardware.com/tech-industry/artificial-intelligence/nvidia-celebrates-dumping-of-biden-era-ai-chip-export-rules-simpler-new-policy-promised
- https://www.steptoe.com/en/news-publications/international-compliance-blog/trump-administration-charts-new-path-on-ai-export-controls-with-significant-new-guidance-and-rescission-of-diffusion-rule.html
- https://builtin.com/articles/trump-lifts-ai-chip-ban-china
- https://www.wilmerhale.com/en/sitecore/content/whlaunch/home/research/news-publications/20250515-us-export-controls-on-ai-diffusion-officially-paused-but-new-guidance-elevates-risk-for-ai-related-exports

### Data
- Epoch — Will we run out of data: https://epoch.ai/blog/will-we-run-out-of-data-limits-of-llm-scaling-based-on-human-generated-data ; paper https://arxiv.org/pdf/2211.04325
- Qwen3 technical report: https://ar5iv.labs.arxiv.org/html/2505.09388 ; https://aman.ai/primers/ai/qwen3/
- Reddit/Google: https://the-decoder.com/reddit-signs-60-million-annual-training-data-deal-with-google/ ; https://www.maginative.com/article/reddit-is-selling-user-content-data-ai-content-licensing-deal-ahead-of-ipo
- Reddit/OpenAI: https://searchengineland.com/openai-may-pay-reddit-70m-for-licensing-deal-451882
- Licensing trackers: https://llmpulse.ai/blog/ai-content-licensing-deals/ ; https://qz.com/ai-training-data-pricing-licensing-deals-market-052126 ; https://everything-pr.com/ai-licensing-tracker/
- Copyright litigation: https://chatgptiseatingtheworld.com/2025/10/08/status-of-all-51-copyright-lawsuits-v-ai-oct-8-2025/ ; https://bannerwitcoff.com/artificial-intelligence-case-tracker ; https://chatgptiseatingtheworld.com/wp-content/uploads/2026/08/Map-of-Copyright-Ltgn-v.-AI-cs-in-United-States-Aug-31-2026-139.pdf

### Business
- OpenAI $300B round: https://www.benzinga.com/25/04/44580172/openai-finalizes-historic-40-billion-funding-round-valuing-company-at-300-billion-with-backing-from-softbank-and-microsoft
- OpenAI $157B: https://capacitymedia.com/article/openai-closes-funding-round
- OpenAI $86B tender: https://www.bloomberg.com/news/articles/2023-10-18/openai-is-in-talks-to-sell-shares-at-an-86-billion-valuation ; https://www.bnnbloomberg.ca/openai-deal-lets-employees-sell-shares-at-86-billion-valuation-1.2036074
- OpenAI $852B: https://siliconangle.com/2026/03/31/openai-just-closed-record-breaking-122b-funding-round-brings-value-852b/ ; https://builtin.com/articles/openai-raises-122b-852b-valuation-20260401 ; https://www.coindesk.com/tech/2026/04/01/openai-raises-a-record-usd122-billion-at-as-revenue-crosses-usd2-billion-per-month
- OpenAI $1.25T (single source): https://nairametrics.com/2026/11/07/openai-secures-11-billion-in-fresh-funding-at-1-25-trillion-valuation/
- OpenAI restructure / Microsoft stake: https://www.fortune.com/2025/10/28/openai-restructure-for-profit-microsoft-pbc-long-term-gains-agi ; https://decrypt.co/346554/microsoft-135-billion-stake-openai-legal-pressure
- OpenAI revenue run rate: https://www.thestar.com.my/tech/tech-news/2026/09/29/openai039s-annual-recurring-revenue-nears-70-billion-axios-reports ; https://news.bgov.com/artificial-intelligence/openais-annualized-revenue-nears-50-billion-ft-says ; https://www.techloy.com/openai-hits-25-billion-in-annualized-revenue-while-anthropic-surges-to-19-billion/ ; https://www.emarketer.com/content/openai-1-billion-ad-run-rate-puts-its-2026-target-within-closer-reach
- OpenAI losses / burn: https://fortune.com/2025/11/12/openai-cash-burn-rate-annual-losses-2028-profitable-2030-financial-documents/ ; https://the-decoder.com/openai-has-reportedly-misjudged-its-cash-burn-by-80-billion/ ; https://www.techrepublic.com/article/news-openai-compute-costs-280-billion-cash-burn/ ; https://www.crowdfundinsider.com/2026/09/311511-openai-sees-278-billion-cash-drain-by-2030-amid-compute-buildout/
- Anthropic Series G: https://www.anthropic.com/news/anthropic-raises-30-billion-series-g-funding-380-billion-post-money-valuation
- Anthropic Series F / $5B run rate: https://www.constellationr.com/blog-news/insights/anthropic-lands-183-billion-valuation-hits-5-billion-annual-revenue-run-rate
- Anthropic Series H ($965B, $47B run rate): https://decrypt.co/369434 ; https://aimagazine.com/news/anthropic-claude-enterprise-ai-agents-and-965bn-valuation ; https://runtimewire.com/article/anthropic-revenue-run-rate-65-billion-ipo
- SpaceX–xAI merger: https://fortune.com/2026/02/02/elon-musk-spacex-xai-ipo-trillion ; https://news.bloomberglaw.com/ip-law/elon-musks-spacex-said-to-combine-with-xai-ahead-of-mega-ipo
- API price history: https://www.deeplearning.ai/the-batch/falling-llm-token-prices-and-what-they-mean-for-ai-companies/ ; https://tokencostcalculator.pages.dev/llm-price-history/ ; https://siliconcanals.com/the-cost-of-running-a-top-tier-ai-query-dropped-280-fold-in-roughly-18-months-from-20-per-million-tokens-in-late-2022-to-seven-cents-by-late-2024-a-price-collapse-with-no-real-parallel-in/
- Epoch inference price trends: https://epoch.ai/data-insights/llm-inference-price-trends ; https://arxiv.org/html/2511.23455v1
- a16z LLMflation: https://a16z.com/llmflation-llm-inference-cost/
- ChatGPT user growth: https://techcrunch.com/2025/03/06/chatgpt-doubled-its-weekly-active-users-in-under-6-months-thanks-to-new-releases/ ; https://www.techrepublic.com/article/news-chatgpt-700-million-weekly-users/ ; https://thenextweb.com/news/chatgpt-1-billion-weekly-active-users-openai-target

### Talent
- Meta poaching: https://www.axios.com/2025/08/06/meta-ai-talent-jobs-pay-openai-apple ; https://www.entrepreneur.com/business-news/meta-offers-former-apple-manager-hundreds-of-millions-in-pay/494485 ; https://www.techrepublic.com/article/news-meta-billion-dollars-ai-poaching-failed/ ; https://www.deeplearning.ai/the-batch/metas-hiring-spree-pushes-up-salaries-for-ai-engineers-across-the-industry
- Comp data: https://www.levels.fyi/company/OpenAI/salaries ; https://www.levels.fyi/companies/anthropic/salaries/software-engineer/title/research-scientist ; https://www.herohunt.ai/blog/what-openai-and-anthropic-pay-engineers-2026/
- OpenAI 2016 pay (NYT via secondary): https://www.inverse.com/article/43928-elon-musk-openai ; https://www.theregister.com/2019/05/03/open_ai_finances/ ; https://projects.propublica.org/nonprofits/organizations/810861541
- OpenAI headcount 2026: https://fortune.com/2026/03/21/openai-double-headcount-this-year-sam-altman-anthropic-google/ ; https://www.bloomberg.com/news/articles/2026-03-21/openai-plans-to-almost-double-its-headcount-this-year-ft-says

### Canonical papers for [K] items (not fetched this session)
- Vaswani et al. 2017, Attention Is All You Need: https://arxiv.org/abs/1706.03762
- Devlin et al. 2018, BERT: https://arxiv.org/abs/1810.04805
- Radford et al. 2019, GPT-2: https://openai.com/index/better-language-models/
- Brown et al. 2020, GPT-3: https://arxiv.org/abs/2005.14165
- Hoffmann et al. 2022, Chinchilla: https://arxiv.org/abs/2203.15556
- Besiroglu et al. 2024, Chinchilla replication: https://arxiv.org/abs/2404.10102
- Ouyang et al. 2022, InstructGPT: https://arxiv.org/abs/2203.02155
- Wei et al. 2022, Chain-of-thought: https://arxiv.org/abs/2201.11903
- Dao et al. 2022, FlashAttention: https://arxiv.org/abs/2205.14135
- Bai et al. 2022, Constitutional AI: https://arxiv.org/abs/2212.08073
- Rafailov et al. 2023, DPO: https://arxiv.org/abs/2305.18290
- Fedus et al. 2021, Switch Transformer (MoE): https://arxiv.org/abs/2101.03961
- Gemini 1.5 (long context): https://arxiv.org/abs/2403.05530
- OpenAI o1 (Learning to reason with LLMs): https://openai.com/index/learning-to-reason-with-llms/
- DeepSeek-R1: https://arxiv.org/abs/2501.12948
- Shumailov et al. 2024, model collapse (Nature): https://www.nature.com/articles/s41586-024-07566-y
- Muennighoff et al. 2023, Scaling data-constrained LMs: https://arxiv.org/abs/2305.16264
- METR 2025, Measuring AI ability to complete long tasks: https://arxiv.org/abs/2503.14499
- Llama 3 Herd of Models: https://arxiv.org/abs/2407.21783
- EU AI Act (Regulation (EU) 2024/1689): https://eur-lex.europa.eu/eli/reg/2024/1689/oj
