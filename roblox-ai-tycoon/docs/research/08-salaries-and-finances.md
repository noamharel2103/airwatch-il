# 08 — Salaries & Company Finances (2023 → 2026)

> Research for the AI-lab tycoon game. The game starts January 2023 and runs year by year. "Today" is November 2026, so 2026 figures cover only part of the year.
> Goal: make employee pay, funding rounds, revenue, burn and prices match reality closely enough that a player who follows AI news will recognise them.

## How to read this document

Each number carries a confidence tag:

| Tag | Meaning |
|---|---|
| **[S]** | Found in a web search during this research session. The source is linked in the Sources section at the end of each part. |
| **[BK]** | Taken from the researcher's background knowledge of widely reported events, mostly before mid-2026. Not re-checked in this session. Usually reliable, but verify before you quote it in marketing. |
| **[E]** | A designer estimate, interpolated or extrapolated from [S] and [BK] data. Use it as a game-balance default, not as a fact. |
| **[D]** | Disputed: the company denied it, or sources conflict sharply. |

Units: USD unless noted. "TC" means annual total compensation: base salary + bonus + equity vesting per year. "ARR" means annualized revenue run rate, usually last month × 12, so it is not audited revenue. "B" = billion, "M" = million, "K" = thousand.

**Research limit:** the shared web-search budget ran out after about 57 searches. Some rows rely on [BK] or [E] where another search would normally have confirmed them. The biggest gaps are listed in §9.

---

## 0. TL;DR for the game designer

1. **Pay at AI labs about doubled from 2023 to 2025 for the top ~10% of technical staff, then flattened in 2026.** Typical big-lab engineers went from about $300K–$900K TC (2023) to $400K–$1.2M (2025–26). Star researchers went from "a few million" (2023) to "$10M–$100M+ per year" during Meta's 2025 hiring spree.
2. **Equity is most of the pay.** At OpenAI, stock pay averaged about **$1.5M per employee in 2025**, roughly 46% of revenue [S]. In the game, pay most compensation in "stock" that vests over 4 years. Cash burn then stays lower than total compensation cost, but dilution goes up.
3. **Revenue curves are near-exponential.** OpenAI: ~$1–1.6B (2023) → $3.7B (2024) → $13.1B (2025) → $25B ARR (Feb 2026). Anthropic: ~$0.1B ARR (end 2023) → ~$1B (end 2024) → ~$9B (end 2025) → $47B (May 2026) → >$65B (Jul 2026) [S].
4. **Losses scale with revenue.** OpenAI lost about $21B from operations on $13B of revenue in 2025 [S]. Gross margins were only ~33–46% because inference is expensive [S].
5. **Valuations explode.** OpenAI went $29B (Jan 2023) → $157B (Oct 2024) → $300B (Mar 2025) → $500B (Oct 2025) → $852B (Mar 2026). Anthropic went ~$4B (2023) → $18B (early 2024) → $61.5B (Mar 2025) → $183B (Sep 2025) → $380B (Feb 2026) → $965B (May 2026) [S/BK].
6. **API prices fall about 3–10× per year for the same capability**, while new frontier tiers launch at premium prices. GPT-4 cost $30/$60 per million tokens in 2023. GPT-5 cost $1.25/$10 in 2025. GPT-5.5 is back up to $5/$30 in 2026 [S/BK].
7. **Consumer plans:** $20/month is the standard tier everywhere. $200/month "Pro/Max/Ultra" tiers arrived from December 2024. $8 "Go" tiers and ads arrived in 2026 [S/BK].
8. **A 2023 AI seed round** was a median of about **$3.4M at a $16M pre-money valuation**, and a median Series A was about **$12.5M at $52M pre-money** [S]. A frontier-lab-founder seed was an outlier at €105M (Mistral) [BK]. That outlier became normal for "neolabs" by 2025: $2B seeds at $10–12B valuations (Thinking Machines) [S].

---

## 1. Compensation by role

### 1.1 Market anchors (sourced data points)

| Data point | Year | Value | Tag |
|---|---|---|---|
| OpenAI offer reported by Levels.fyi: $300K base + $2M PPU over 4 yrs | Jun 2023 | **$800K TC** | [S] |
| Range of OpenAI engineer TC reported to Levels.fyi | Jun 2023 | **$325K – $1.37M**, typical base $300K + $625K equity | [S] |
| US median software-engineer TC, all companies (Levels.fyi) | 2023 → 2024 | $175K → $188K (+7.4%) | [S] |
| ML/AI engineer premium at the L3 level (Levels.fyi analysis) | late 2024 | $375K vs $279K for a non-AI peer (**1.34×**) | [S] |
| Levels.fyi 2024 report: largest single raise seen | 2024 | +$2M for a Principal AI Engineer at a FAANG company | [S] |
| OpenAI SWE TC by level (Levels.fyi, updated Dec 2025) | 2025 | L4 **$702K**, L5 **$871K**, L6 **$1.19M** | [S] |
| OpenAI overall median TC (Levels.fyi) | 2025 | ~$539K | [S] |
| Anthropic SWE TC ladder (Levels.fyi via secondary blog) | 2025–26 | Entry ~$367K, Senior ~$591K, Lead ~$780K, Staff ~$1.25M | [S] |
| Anthropic senior SWE average (11 data points) | 2025 | $621K (~1.5× Google L5) | [S] |
| OpenAI average **stock-based** compensation per employee (WSJ / Equilar) | 2025 | **$1.5M**, across ~4,000 staff. That is 34× the pre-IPO average of 18 big tech companies and 7× Google's pre-IPO level (2003) | [S] |
| OpenAI stock pay as a share of revenue | 2025 | ~46% | [S] |
| OpenAI projected SBC growth | 2025–2030 | +~$3B per year | [S] |
| OpenAI retention bonus after Meta raids (GPT-5 launch week) | Aug 2025 | ~$1.5M each, over 2 years, to ~1,000 research & engineering staff (~$1.5B total). Some reports say "all staff". | [S][D on scope] |
| OpenAI equity change | Jan 2026 | Moved from PPUs to RSUs and removed the vesting cliff | [S] |
| Google DeepMind special restricted-stock grants to keep researchers | Jan 2024 | "Up to millions of dollars per person" | [S] |
| Google DeepMind reported $20M/yr packages for top researchers (Reuters headline) | 2024–25 | $20M/yr | [S][D] |
| Meta Superintelligence Labs offers (WIRED) | Jun–Jul 2025 | ≥10 offers of **up to $300M over 4 yrs**, some >$100M in year 1 | [S][D, Meta called this "untrue"] |
| Meta CTO Bosworth: $100M applies only to "a small number of senior leadership hires" | Jul 2025 | — | [S] |
| Ruoming Pang (Apple's head of foundation models) → Meta | Jul 2025 | **>$200M** multi-year, mostly stock | [S] |
| Other ex-Apple researchers → Meta (e.g., Tom Gunter) | Jul 2025 | multi-year packages **>$100M** | [S] |
| Andrew Tulloch (Thinking Machines co-founder): Meta offer, first declined | Aug 2025 | **up to $1.5B over ≥6 yrs**, depending on stock performance | [S][D, Meta called it "inaccurate and ridiculous"] |
| Tulloch joins Meta, later leaves for Anthropic | Oct 2025 → 2026 | — | [S] |
| Meta AI hiring freeze | late Aug 2025 | freeze to "plan 2026 headcount" | [S] |
| Meta MSL layoffs | Oct 2025 | ~600 roles cut in AI units | [BK] |
| Meta company-wide layoffs + 6,000 roles closed, while capex is raised | May 2026 | ~8,000 (≈10%) | [S] |
| Carta: AI/ML engineer median salary growth | Jan 2024 → Feb 2026 | **+9.1%** salary, **+31%** initial equity grant (+59% at $1–10M-valuation startups) | [S] |
| Carta: AI-native startup valued >$500M, 80–95th-percentile engineer | 2026 | $320K salary + 0.146% equity, vs $285K + 0.10% at a non-AI startup | [S] |
| Carta: median team size at seed | 2025–26 | **4 employees** | [S] |
| SignalFire: AI engineer premium at later-stage startups | Dec 2024 | +5% salary, +10–20% equity | [S] |
| Google SWE TC medians (Levels.fyi, May 2026) | 2026 | L3 $216K, L4 $297K, L5 $423K, L6 $614K, L7 $939K | [S] |
| Meta SWE TC averages (Levels.fyi, mid-2026) | 2026 | E3 $179K, E4 $294K, E5 $476K, E6 $708K, E7 ~$1.16M | [S] |

**Posted base-salary ranges (US, from job ads; equity comes on top):**

| Company | Role | Base range | Tag |
|---|---|---|---|
| OpenAI | Research Engineer, AI for Science | $310K – $460K + equity | [S] |
| OpenAI | ML Infrastructure Engineer | $310K – $555K + equity | [S] |
| OpenAI | SWE, Monetization ML Infra | $293K – $441K + equity | [S] |
| OpenAI | SWE, Cloud Infrastructure | $255K – $490K + equity | [S] |
| OpenAI | SWE, Analytics Platform | $230K – $385K + equity | [S] |
| OpenAI | Data Infrastructure Engineer | $200K – $385K + equity | [S] |
| OpenAI | Data Infra Engineer, Research | $250K – $380K + equity | [S] |
| OpenAI | Account Executive (job-board sidebar) | $261K – $335K | [S] |
| Anthropic | Enterprise Account Executive (Tech / Industries) | **$290K – $380K OTE** (base + commission target) | [S] |
| Anthropic | Manager, Strategic Sales | $360K – $435K OTE | [S] |
| Anthropic | Research Counsel | $265K – $335K | [S] |
| Anthropic | Litigation Counsel | $265K – $320K | [S] |
| Anthropic | Other counsel | $245K – $310K | [S] |
| Anthropic | Recruiter, Research | $170K – $220K (another listing: $175K–$295K) | [S] |
| Anthropic | Recruiting Manager, Marketing & GTM | $230K – $295K | [S] |

**Levels.fyi, non-engineering roles:**

| Company | Role | TC | Tag |
|---|---|---|---|
| OpenAI | Product Designer | median ~$656K (band $656K–$956K) | [S] |
| OpenAI | Product Manager | median ~$860K ($310K base + $550K stock; secondary blog, Apr 2026); top ~$1.1M | [S] |
| Anthropic | Product Manager | $374K–$440K average (range $349K–$486K; thin data) | [S] |
| OpenAI | Overall range across roles | $144K (technical writer) → $1.265M (SWE manager) | [S] |

### 1.2 Game table — big frontier lab (OpenAI / Anthropic / Google DeepMind / Meta MSL), San Francisco

Annual TC in USD thousands, as **typical low–high** ranges. Base is usually $200K–$450K. The rest is equity and bonus. These are **[E]** interpolations anchored to the [S] points in §1.1.

| Role | 2023 | 2024 | 2025 | 2026 | Base share | Notes |
|---|---|---|---|---|---|---|
| Junior ML engineer (new grad / L3) | 220–330 | 260–380 | 330–450 | 350–480 | ~55% | Late 2024 L3 AI median $375K [S]; Anthropic entry ~$367K [S] |
| Mid ML engineer (L4) | 350–550 | 420–650 | 550–750 | 580–800 | ~40% | OpenAI L4 $702K (2025) [S] |
| Senior ML engineer (L5) | 550–850 | 620–950 | 700–1,000 | 750–1,100 | ~35% | OpenAI 2023 offer $800K [S]; OpenAI L5 $871K, Anthropic Senior ~$600K (2025) [S] |
| Staff ML engineer (L6) | 850–1,300 | 950–1,500 | 1,100–2,000 | 1,200–2,200 | ~25% | OpenAI L6 $1.19M, Anthropic Staff ~$1.25M [S] |
| Principal / Distinguished (L7+) | 1,300–3,000 | 1,500–4,000 | 2,000–6,000 | 2,000–6,000 | <20% | [E] |
| Research scientist (same level as above) | ×1.0–1.15 | ×1.0–1.15 | ×1.05–1.2 | ×1.05–1.2 | — | Multiply the matching engineering row |
| **Star researcher** ("name" on a famous paper or model) | 2,000–10,000 | 5,000–20,000 | **10,000–100,000+** | 10,000–50,000 | <5% | 2025 Meta: $100M–$300M / 4 yrs [S][D]; Pang >$200M [S]; Tulloch ≤$1.5B / 6 yrs [S][D] |
| Infra / SRE / GPU cluster engineer | 300–600 | 350–700 | 450–900 | 480–950 | ~40% | OpenAI ML-infra base $310–555K [S] |
| Data engineer | 250–450 | 280–500 | 350–650 | 370–700 | ~50% | OpenAI data-infra base $200–385K [S] |
| Product engineer (full-stack / app) | 300–550 | 330–600 | 400–750 | 420–800 | ~45% | [E] |
| Product designer | 280–550 | 320–650 | 450–900 | 500–950 | ~40% | OpenAI designer median $656K (2026) [S] |
| Product manager | 300–650 | 350–750 | 450–1,000 | 450–1,100 | ~40% | OpenAI PM ~$860K, Anthropic PM ~$400K [S] |
| Enterprise sales AE (OTE + equity) | 250–400 | 280–450 | 320–550 | 350–600 | ~50% of OTE is base | Anthropic OTE $290–380K + equity [S] |
| Sales manager / director | 350–600 | 400–700 | 450–800 | 500–900 | — | Anthropic manager OTE $360–435K [S] |
| Marketing / comms | 180–350 | 200–400 | 230–450 | 250–500 | ~60% | [E] |
| Policy researcher / safety researcher | 250–500 | 280–600 | 330–700 | 350–750 | ~50% | Alignment researchers at Anthropic are paid on the research ladder [BK]. Policy staff earn ~counsel level [E] |
| Legal counsel | 280–450 | 300–500 | 330–550 | 350–600 | ~65% | Anthropic counsel base $245–335K [S] |
| Recruiter | 160–300 | 180–330 | 200–380 | 220–400 | ~70% | Anthropic recruiter base $170–295K [S] |
| VP / Head of function | 1,500–5,000 | 2,000–6,000 | 3,000–10,000 | 3,000–10,000 | <15% | [E] |
| C-suite (non-founder) | 3,000–15,000 | 4,000–20,000 | 5,000–30,000 | 5,000–30,000 | <10% | [E]. Founder-CEOs often take token salaries (Altman had no equity until restructuring) [BK] |

### 1.3 Game table — Big Tech outside the core lab (Google/Meta/Microsoft/Amazon generalist ML teams)

Use these values for "poach from Big Tech" or "Big Tech competitor pays X". TC in USD thousands.

| Level | 2023 | 2024 | 2025 | 2026 | Source |
|---|---|---|---|---|---|
| L3 / E3 (junior) | 180–200 | 190–210 | 200–215 | 180–216 | 2026 medians [S]; earlier years back-cast at ~4–7%/yr [E] |
| L4 / E4 (mid) | 255–270 | 270–285 | 285–295 | 295–297 | [S]/[E] |
| L5 / E5 (senior) | 370–420 | 390–440 | 410–465 | 423–476 | [S]/[E] |
| L6 / E6 (staff) | 540–620 | 570–660 | 600–700 | 614–708 | [S]/[E] |
| L7 / E7 (senior staff) | 820–1,000 | 860–1,050 | 900–1,120 | 939–1,160 | [S]/[E] |
| AI/ML specialisation multiplier | ×1.15 | ×1.34 (L3, late 2024) | ×1.3 | ×1.3 (premium "stopped growing") | [S] |

### 1.4 Game table — AI startups (non-frontier), San Francisco

| Stage | Role | Base (K) | Equity (% of company, 4-yr vest) | Tag |
|---|---|---|---|---|
| Seed (≤10 people) | Founding ML engineer | 150–220 (2023) → 180–250 (2026) | 0.5% – 2.0% | [E] (Carta: AI equity grants +31–59% from 2024 to 2026 [S]) |
| Seed | Founding generalist engineer | 140–200 → 170–230 | 0.25% – 1.0% | [E] |
| Series A (15–40 people) | Senior ML engineer | 190–250 → 220–290 | 0.1% – 0.5% | [E] |
| Series B+ / unicorn (>$500M valuation) | Senior engineer, 80–95th percentile | 320 (2026) | 0.146% | [S] |
| Any stage | Non-technical hires | 60–80% of big-lab base | 1/3 of an engineer's grant | [E] |

**Startup vs big lab, rules of thumb [E]:**
- Startup **cash** is about 60–80% of big-lab base salary. Startup **equity** paper value is often 0.2–1× of big-lab equity, with much higher variance.
- Neolabs founded by famous researchers (SSI, Thinking Machines, Reflection, Periodic Labs) paid at or above big-lab levels from day one because their seed rounds were $1–2B [S].
- Model this as a "mission/upside" stat. A candidate accepts 40–60% of market cash if the startup's valuation momentum is high.

### 1.5 Data labelers / annotators / "AI tutors" (hourly)

| Tier | 2023 | 2024 | 2025 | 2026 | Examples / sources |
|---|---|---|---|---|---|
| Offshore generalist (Kenya, Philippines, Venezuela) | $1.32–$2/hr (Sama for OpenAI, TIME) | $3–6/hr (Kenyan raters). Remotasks cut off Kenya, Nigeria and Pakistan in Mar 2024 | $3–6/hr | $3–8/hr | [S] |
| US/EU generalist (writing, RLHF ranking) | $15–20/hr | $15–25/hr | $15–25/hr | $15–25/hr | Outlier median listed $19.50/hr, middle half $13.25–27.50 [S] |
| Coding / math specialist | $20–40/hr | $25–50/hr | $25–60/hr | $30–70/hr | Outlier code review $25–50/hr; Scale math expert ≤$16/hr (non-US) [S] |
| STEM PhD expert | $40–60/hr | $50–80/hr | $55–120/hr | $70–120/hr | Mercor PhD postings $55–120/hr; Mercor average ~$95–110/hr [S] |
| Professional expert (MD, lawyer, banker) | rare | $100–150/hr | $150–400/hr | $150–400/hr | Alignerr ≤$200/hr; "doctors and lawyers up to $400/hr" [S] |
| Elite (consultants, bankers, VCs on Surge) | — | — | $300–500/hr | $300–1,000/hr | Surge advertises $300–500/hr and up to $1,000/hr for VC partners [S] |

**Notes for the game:**
- Data vendors (Scale, Surge, Mercor, Turing, Labelbox) bill the lab roughly **1.3–2× the contractor rate** [E]. Contractors are 1099 workers, so there is **no benefits overhead**.
- Lawsuits over misclassification and non-payment (Scale, Surge, Outlier "it's a scam" reporting) can serve as a "reputation risk" event [S].
- Labeler mix shifted from cheap volume (2023) to expensive experts (2025–26). Model a "data quality" upgrade that switches cost from $2/hr workers to $100/hr experts.

### 1.6 Hiring bonuses, retention and benefits overhead

| Item | Value | Tag |
|---|---|---|
| Sign-on bonus, normal senior hire at a big lab | $50K – $300K cash, often front-loaded equity | [E] |
| Sign-on, star researcher (2025) | Meta packages had >$100M in year 1 for a few people [S][D]. In-game: 10–30% of a 4-yr package up front | [S]/[E] |
| Retention grant, OpenAI 2025 | ~$1.5M over 2 yrs for ~1,000 R&E staff | [S] |
| Retention grant, Google DeepMind 2024 | "millions" in restricted stock for select researchers | [S] |
| Equity vesting | 4 yrs. Historically a 1-yr cliff; OpenAI removed its cliff in Jan 2026 | [S] |
| Employee tender offers (liquidity) | OpenAI ~$6.6B secondary at a $500B valuation, Oct 2025 | [S] |
| **US benefits load (BLS ECEC, private industry, Dec 2024)** | Wages = 70.5% of compensation, so benefits ≈ 29.5%. **Cost ≈ 1.42× wages** for average workers | [S] |
| Benefits load for highly paid tech staff | **1.15–1.30× base**: Social Security caps at ~$168K–$176K, while health, 401k match, perks and payroll tax stay | [E] |
| Fully loaded "seat cost" (benefits + office + laptop + software + travel) | add $25K–$60K per head per year | [E] |
| **Recommended game multiplier** | 1.25× on cash for lab staff, 1.40× for staff earning <$150K, 1.0× on contractors | [E] |

### 1.7 Talent-war event timeline (for news-ticker events)

| Date | Event | Tag |
|---|---|---|
| 2023 | OpenAI–Google bidding for researchers. Big Tech AI layoffs elsewhere | [BK] |
| Jan 2024 | Google DeepMind gives special stock grants to stop departures | [S] |
| Mar 2024 | Microsoft "acqui-hires" Inflection AI (~$650M license and hire) | [BK] |
| Aug 2024 | Google–Character.AI license and hire (~$2.7B), Noam Shazeer returns | [BK] |
| Jun 2025 | Meta buys 49% of Scale AI for ~$14.3B, Alexandr Wang leads Meta Superintelligence Labs | [S/BK] |
| Jun–Jul 2025 | Meta poaches ~dozens from OpenAI, Apple and GDM with $100M–$300M packages | [S][D] |
| Jul 2025 | Google–Windsurf license and hire (~$2.4B) | [BK] |
| Aug 2025 | OpenAI's $1.5M retention bonuses. Meta freezes AI hiring. Tulloch's reported $1.5B offer | [S] |
| Oct 2025 | Meta cuts ~600 AI roles. Tulloch joins Meta | [S/BK] |
| 2026 | Thinking Machines loses co-founders to OpenAI. GDM losing senior researchers. Meta's 8,000 layoffs | [S] |

---

## 2. Finances of real AI companies

### 2.1 OpenAI

| Year | Funding / valuation events | Revenue | Operating loss / burn | Headcount | Users | Tag |
|---|---|---|---|---|---|---|
| **2023** | Jan: Microsoft ~$10B multi-year, ~$29B valuation [BK]. Late 2023 tender at ~$86B [BK] | ~$1.0–1.6B. ~$2B ARR by Dec [S/BK] | loss ~$0.5–1B [BK] | ~770 (Nov 2023) [BK] | ChatGPT 100M WAU (Nov 2023) [BK] | |
| **2024** | Oct: $6.6B at **$157B** (Thrive lead) + $4B credit line [BK] | **$3.7B** [S] | loss ~$5B. Operating loss $8.8B [S] | ~2,000 (Dec 2024) [S] | 200M WAU (Aug) → 300M (Dec) [BK]. 1M business seats (Sep) [S] | |
| **2025** | Mar: **$40B at $300B**, SoftBank lead ($20B conditional on restructuring) [S]. Oct: $6.6B employee secondary at **$500B** [S]. Oct: for-profit PBC restructuring [BK] | **$13.07B**. ARR $20B by Dec [S] | Operating loss **$20.9B**. Cash burn ~$8–9B [S]. Net loss ~$38.5B incl. one-off restructuring charge [S] | ~4,000 [S] | 700M WAU (Aug), 800M (Oct). 35M paying consumers (Jul, ~5%) [S] | |
| **2026** | Feb 27: $110B announced (Amazon $50B staged, Nvidia $30B, SoftBank $30B) at $730B pre. **Closed Mar 31 at $122B, $852B post** [S]. Confidential IPO filing May/Jun 2026, ~$1T target [S] | ARR **$25B (Feb)**. Q1 revenue $5.7B [S]. Unverified reports of ~$70B ARR by Q3 [S][D] | Q1 burn $3.7B. 2026 projected operating loss ~$14B. Burn forecasts $17–27B [S] | ~4,500–6,000 [E] | **1.2B WAU (Nov 2, 2026)**, 910M earlier. 9M paying business users [S] | |

- **Compute:** about $1.4T of multi-year compute commitments announced by late 2025 (Stargate, Oracle, Microsoft $250B Azure, AWS $38B, CoreWeave, AMD, Broadcom) [BK]. Inference cost quadrupled in 2025 [S]. Cumulative cash burn through 2029 was forecast at about $115B [S]. OpenAI does not expect positive cash flow until about 2029–2030 [S].
- **Margins:** adjusted gross margin about 40% (2024) → 33% (2025), below a 46% target [S]. "Compute margin" on paid users rose from ~35% (Jan 2024) to ~70% (Oct 2025) [S].

### 2.2 Anthropic

| Year | Funding / valuation | Revenue / ARR | Losses | Headcount | Customers | Tag |
|---|---|---|---|---|---|---|
| **2023** | Google ~$300M (early) + up to $2B (Oct: $500M up front). Spark-led Series C $450M (~$4.1B valuation, May). Amazon up to $4B (Sep: $1.25B first) [S/BK] | ~$100M ARR by year end [BK] | — | ~250–300 [BK] | Claude.ai launched Jul 2023 [BK] | |
| **2024** | Amazon +$2.75B (Mar), +$4B (Nov), $8B total. Series D (Menlo) ~$750M at **~$18B** [S] | ~$1B ARR end of 2024 [S] | — | ~1,000 [S/BK] | — | |
| **2025** | Google ~$1B (Jan). **Series E $3.5B at $61.5B** (Mar, Lightspeed lead) [S]. **Series F $13B at $183B** (Sep) [S]. Microsoft $5B + Nvidia $10B strategic (Nov) [BK] | $4.6B recognised revenue [S]. ARR >$5B (Aug), ~$9B (Dec) [S] | Operating loss ~$8B. Net loss $42B incl. $34B non-cash financing charge [S] | ~2,900 (Nov 2025) [S] | >300,000 business customers. Large accounts (>$100K run-rate) up ~7× in a year [S] | |
| **2026** | **Series G $30B at $380B** (Feb 12, GIC + Coatue) [S]. **Series H $65B at $965B** (May 28, incl. Amazon $5B + Google $10B. Leads: Altimeter, Dragoneer, Greenoaks, Sequoia) [S]. ~$125B raised in total [S]. Public S-1 filed Oct 26, 2026, IPO targeted ~Thanksgiving [S] | ARR $14B (Feb) → >$30B (Apr) → $47B (May) → **>$65B (end of Jul)** [S]. **H1 2026 revenue $16.3B** vs $1.2B in H1 2025 [S] | H1 operating loss only **$693M**. Net loss $80.7B, almost all a non-cash convertible-note revaluation [S] | ~4,500+ [S] | >11,900 customers at ≥$100K/yr, >1,900 at ≥$1M, ~250 at ≥$10M (Sep 30) [S]. $1M+ customers went 500 → 1,000 (Feb → Apr 2026) [S] | |

- **Margins:** 2025 gross margin about 40% on enterprise/API (about 38% including free users), below a 50% plan. Inference cost ran 23% over plan. Anthropic targets >70% by 2027 [S]. Real net revenue may be 25–30% below headline ARR because of cloud revenue-share accounting [S].
- **Compute:** deals for up to 1M Google TPUs ("tens of billions", Oct 2025), $50B for its own US data centres (Fluidstack, Nov 2025) and $30B of Azure capacity [BK].

### 2.3 Google DeepMind / Alphabet

| Year | Alphabet capex | GDM headcount | Notes | Tag |
|---|---|---|---|---|
| 2023 | ~$32B | ~2,500–3,000 (Brain + DeepMind merged in Apr 2023) | 2022 UK staff costs £594.5M, down from £969M in 2021 | [BK]/[S] |
| 2024 | ~$52.5B | ~4,000–5,000 | UK staff-cost recharges ~£1.01B. Gemini 1.5. Character.AI deal | [BK]/[S] |
| 2025 | **$91.4B** | ~6,000 (Jun 2025) | Gemini app >750M MAU (Q4 2025). Gemini 2.5/3 | [S] |
| 2026 | guidance **$175–185B**, mostly compute for GDM | ~6,500+ [E] | Senior researcher departures reported mid-2026 | [S] |

### 2.4 Meta AI (FAIR → GenAI → Meta Superintelligence Labs)

| Year | Capex | AI org events | Tag |
|---|---|---|---|
| 2023 | ~$28B | Llama 2 (open). "Year of efficiency" layoffs | [BK] |
| 2024 | **$39.2B** | Llama 3 / 3.1 405B | [S] |
| 2025 | **$72.2B** | Llama 4 disappointment. Scale AI 49% for ~$14.3B. MSL formed (Jun 30) under Alexandr Wang and Nat Friedman. $100M+ offers. Aug freeze. ~600 AI cuts (Oct) | [S]/[BK] |
| 2026 | guidance raised from $115–135B to **$125–145B** (Q1 2026) | ~8,000 company layoffs (May 20) and 6,000 roles closed while AI spend rises | [S] |

### 2.5 xAI

| Year | Funding / valuation | Revenue | Burn | Headcount | Tag |
|---|---|---|---|---|---|
| 2023 | Founded Jul 2023. Grok 1 (Nov) | ~0 | — | ~20–50 | [BK] |
| 2024 | **Series B $6B at $24B** (May). **Series C $6B at ~$45–50B** (Dec) | small | Colossus 100K GPUs (Memphis) | ~200–1,000 | [S]/[BK] |
| 2025 | Merged with X (Mar, xAI valued ~$80B) [BK]. ~$5B equity at $113B incl. X, SpaceX $2B (Jul) [S] | **$3.2B** (incl. X) [S]. xAI-only Q3 revenue $107M [S] | ~$1B/month. $7.8B cash burned in 9 months. $1.46B Q3 loss. Operating loss $6.4B for the year [S] | ~4,000 incl. annotation "tutors" [S] | |
| 2026 | **Series E $20B at $230B** (Jan). Acquired by **SpaceX at $250B** (Feb), combined entity $1.25T [S] | AI ARR ~$500M (mid-2026) [S] | AI capex ~$30.8B annualised [S] | — | |

### 2.6 Mistral AI (France)

| Year | Round | Valuation | Revenue / ARR | Tag |
|---|---|---|---|---|
| 2023 | Seed **€105M** (Jun, Lightspeed). Series A **€385M** (~$415M, Dec, a16z) | €240M → ~€2B | ~0 | [S]/[BK] |
| 2024 | Series B **€600M** (Jun, General Catalyst) | **€5.8B** (~$6.2B) | tens of €M [E] | [S] |
| 2025 | Series C **€1.7B** (Sep, ASML €1.3B for ~11%) | **€11.7B** post | ~$300M ARR [E] | [S] |
| 2026 | Series D **€3B** (Sep 8, Samsung lead) | **>€21B** (~$24B) | ~$400M ARR (early 2026). On track for **$1B ARR by end of 2026** (CFO) [S] | [S] |

### 2.7 Chinese labs

| Company | 2023 | 2024 | 2025 | 2026 | Tag |
|---|---|---|---|---|---|
| **DeepSeek** (funded by the High-Flyer hedge fund, no outside VC) | Founded Jul 2023 | V3 (Dec): reported "$5.6M" final training run (2.79M H800-hours × $2/hr, excluding R&D) | R1 (Jan) shock. **~160 staff**. SemiAnalysis: ~50K Hopper GPUs, ~$1.6B server capex, ~$944M operating cost | V4 (Flash $0.14/$0.28, Pro $1.74/$3.48 per M tokens) | [S] |
| **Alibaba (Qwen)** | Qwen open-sourced (Aug) | Qwen 2 / 2.5 | Pledged **≥380B yuan (~$53B) on cloud + AI over 3 years** (Feb). Qwen 3 | Cloud AI revenue growing at triple-digit rates | [S] |
| **Moonshot (Kimi)** | Founded Mar 2023 | ~$1B round (Alibaba lead) at **~$2.5B** (Feb) | ~$4.3B (late) | ~$10–12B (Jan–Feb). **$2B at >$20B** (May, Meituan lead). ARR >$200M (Apr). Up to **$35B** (Jul). ~$50B reported (Oct) [D] | [S]/[BK] |
| **Zhipu (Z.ai / Knowledge Atlas)** | ~2.5B yuan raised [BK] | Saudi Prosperity7 investment [BK] | Revenue ~$105M, loss ~$680–700M. H1 R&D 8× revenue | **HK IPO Jan 8, 2026**, HK$55.5B (~$7.1B). Later rally, ~$4B follow-on sale reported | [S] |
| **MiniMax** | — | net loss $465M | Revenue **$79M** (+159%). Adjusted loss $251M | **HK IPO Jan 9, 2026**, HK$71.9B (~$9.2B) at debut | [S] |

### 2.8 Other Western labs

| Company | 2023 | 2024 | 2025 | 2026 | Tag |
|---|---|---|---|---|---|
| **Cohere** (Toronto, enterprise) | $270M at ~$2.2B [BK] | **$500M at $5.5B** (Jul) | **$500M at $6.8B** (Aug, Radical + Inovia). +$100M at $7B (Sep). ARR $100M (May) → ~$150M (Oct) → est. $240M (year end) | Series E initial close of up to CAD 7B at CAD 35.7B (~US$25.5B) [D, single source] | [S] |
| **AI21 Labs** (Tel Aviv) | Series C $155M extended to **$208M** at **$1.4B** (Aug–Nov) [BK]/[S] | — | ~$300M round reported (Nvidia + Google, possibly never closed). ~$50M revenue, ~200 staff. **Nvidia in advanced talks to buy for $2–3B** (Dec) | — | [S] |
| **Perplexity** | ~$500M valuation | $73.6M at **$520M** (Jan) → **$3B** (Jun) → **$500M at $9B** (Dec) | **$14B** (May) → $100M at **$18B** (Jul) → $200M at **$20B** (Sep). ARR ~$200M | ~$500M ARR (early 2026) [D] | [S] |
| **SSI** (Sutskever) | — | Founded Jun. **$1B at $5B** (Sep, a16z + Sequoia) | **$2B at $32B** (Apr, Greenoaks). ~20–50 staff [BK] | $5B strategic round reported [D] | [S] |
| **Thinking Machines** (Murati) | — | — | Founded Feb. **$2B seed at $10–12B** (Jun–Jul, a16z) — largest seed ever | $50–60B attempt failed. Co-founders leave. Talks for $5–6B at ≥$40B (Sep) | [S] |
| **Reflection AI** | — | Founded Mar 2024 | $130M at $545M (Mar). **$2B at $8B** (Oct, Nvidia) | First open-weight model expected | [S] |

### 2.9 Industry-wide annual totals for macro events [E, from the above]

| Year | Mega-round mood | AI share of VC | Typical frontier-lab burn | GPU rental (H100, per GPU-hour) |
|---|---|---|---|---|
| 2023 | ChatGPT boom. VC overall down, AI up | ~25% | $0.5–1B/yr | **$4–10** (shortage peak $7–10 [S]) |
| 2024 | Rounds of $6B+ become normal | ~35% | $2–5B/yr | ~$2.5–4 (falling) [S/E] |
| 2025 | $40B round (OpenAI). Neolab $2B seeds | >50% | $5–20B/yr | **$1.70–2.20** (Oct 2025 trough) [S] |
| 2026 | $122B and $65B rounds. IPO filings | megadeals = 87.5% of US VC dollars (Q2) [S] | $10–30B/yr | rebound to **$2.35–2.80** contracts [S] |

---

## 3. Starting a new AI startup (the player's position in January 2023)

### 3.1 Seed / Series A benchmarks (Carta, US)

| Metric | 2023 (Q1) | 2024 | 2025 | 2026 | Tag |
|---|---|---|---|---|---|
| **AI seed** median round | **$3.4M** | ~20% bigger than non-AI (~$3.6–4M) | ~$4–5M | ~$5M | [S]/[E] |
| **AI seed** median pre-money | **$16M** (vs $13M non-AI) | **$17.9M** (+42% vs non-AI) | ~$20M | ~$20M+ (all-seed post-money median $24M, Q4 2025) | [S] |
| **AI Series A** median round | **$12.5M** (vs $5.9M non-AI) | ~$13–15M | ~$15–20M | ~$20M | [S]/[E] |
| **AI Series A** median pre-money | **$52M** | **$51.9M** | ~$64–85M (all-company median $70.8M) | ~$64M+ | [S] |
| Seed team size | 4–8 (median 4 by 2026) | | | | [S] |
| Series A team size | 15–30 | | | | [E] |

**Outlier "frontier-lab founder" rounds**, for the player who wants to build a real foundation-model company:

| Example | Date | Raise | Valuation | Tag |
|---|---|---|---|---|
| Mistral seed | Jun 2023 | €105M | ~€240M | [BK] |
| Inflection | Jun 2023 | $1.3B | ~$4B | [BK] |
| Character.AI | Mar 2023 | $150M | $1B | [BK] |
| SSI | Sep 2024 | $1B | $5B | [S] |
| Thinking Machines seed | Jun 2025 | $2B | $10–12B | [S] |
| Reflection | Oct 2025 | $2B | $8B | [S] |

**Recommended game defaults [E]:**
- Starting cash in Jan 2023: **$3–5M** for a normal seed with a team of 4–8.
- Optional "famous founder" mode: **$100M at a $250–400M valuation**, with a team of 10–20.
- Series A unlocks at ~$1–3M ARR or after a hit model release. Raise $10–20M at $50–80M pre.
- Dilution per round: 15–25%.

### 3.2 Office space

| City | 2023 | 2024 | 2025 | 2026 | Unit | Tag |
|---|---|---|---|---|---|---|
| **San Francisco** (CBRE citywide average asking, full service) | ~$72 (Q3) | $68.55 (Q1). Class A $76.57 | $70.31 (Q3), $71.19 (late) | **$72.96 (Q2, +6.2% YoY)**. AI hot-spots (Mission Bay) +14% | $/sq ft/yr | [S] |
| **New York (Manhattan)** | ~$74 | ~$75–77 | **$77.89 (Q4, CBRE)**. Class A ~$87.5 | ~$78–80 | $/sq ft/yr | [S]/[E] |
| **London West End** (prime) | ~£125–135 | ~£150 | **~£169 avg prime (+11% YoY)**. Record £201 | £100–250 Grade A range | £/sq ft/yr | [S] |
| **Tel Aviv** (Class A towers) | NIS 130/sqm/month (H1 2023) | ~NIS 125–135 (war dip) | NIS 130–180 (new towers) | **NIS 151 (Begin St)**, 139 (Yigal Alon), 144 (new towers) | NIS/sqm/month | [S] |

**Game conversion [E]:**
- Plan for **150–250 sq ft per employee**, which is ~14–23 m² including common areas.
- SF desk cost ≈ 175 sq ft × ~$72 ≈ **$12.6K per employee per year** (rent only). Add ~30% for fit-out, utilities and services, so ~$16K.
- NYC ≈ $14K–17K. London West End ≈ 175 × £169 ≈ £29.5K (~$37K), the most expensive. Tel Aviv ≈ 16 m² × NIS 145 × 12 ≈ NIS 28K (~$7.5K).
- AI-lab HQs used trophy space, roughly 1.3–1.6× these averages. Remote/coworking costs about $500–$1,000 per desk per month [E].

### 3.3 Cloud-credit programs (startup perks)

| Program | Typical max | Conditions | Tag |
|---|---|---|---|
| AWS Activate | $1K (self-funded) → $100K (Portfolio). Up to $200–300K AI tier in later years | VC/accelerator affiliation | [S] |
| Google for Startups Cloud — AI | **up to $350K** over 2 years | VC-backed, Series A or earlier | [S] |
| Microsoft for Startups Founders Hub | $1K–$5K → **up to $150K** Azure, incl. Azure OpenAI | Progressive unlock | [S] |
| NVIDIA Inception | No cash. $100K+ in partner credits, GPU discounts, training | Free to join | [S] |
| Lab API credits (OpenAI/Anthropic startup programs) | $2.5K–$100K [BK/E] | Accelerator partners | [E] |

**Game:** offer a one-time "credits" event worth $100K–$500K of compute, expiring in 12–24 months.

---

## 4. Revenue model realities

### 4.1 API prices per million tokens (input / output, list price at launch)

| Year | OpenAI | Anthropic | Google | Others | Tag |
|---|---|---|---|---|---|
| **2023** | GPT-4 **$30/$60** (Mar). GPT-4 Turbo **$10/$30** (Nov). GPT-3.5 Turbo $2 → $1/$2 | Claude 2 **$8/$24**. Claude Instant $0.80/$2.40 | PaLM 2 / Gemini Pro preview (cheap) | Mistral 7B open weights | [S]/[BK] |
| **2024** | GPT-4o **$5/$15** (May) → **$2.50/$10** (Aug). 4o-mini **$0.15/$0.60**. o1 **$15/$60** (Dec). GPT-3.5 Turbo $0.50/$1.50 | Claude 3 Opus **$15/$75**, Sonnet **$3/$15**, Haiku **$0.25/$1.25** (Mar). 3.5 Sonnet $3/$15 | Gemini 1.5 Pro ~$3.50 → **$1.25/$5**. 1.5 Flash **$0.075/$0.30** | DeepSeek V3 promo pricing | [S]/[BK] |
| **2025** | GPT-4.5 $75/$150 (Feb). GPT-4.1 $2/$8. o3 $10/$40 → $2/$8 (Jun). **GPT-5 $1.25/$10** (Aug). Mini $0.25/$2, nano $0.05/$0.40 | Opus 4 / 4.1 **$15/$75**. Sonnet 4 / 4.5 $3/$15. Haiku 4.5 $1/$5. **Opus 4.5 $5/$25** (Nov) | Gemini 2.5 Pro **$1.25/$10** (≤200K context). 2.5 Flash $0.30/$2.50. Gemini 3 Pro **$2/$12** (Nov) | DeepSeek V3 $0.27/$1.10, R1 **$0.55/$2.19**. V3.2 **$0.28/$0.42** (Sep–Dec) | [S]/[BK] |
| **2026** | GPT-5.4 $2.50/$15. **GPT-5.5 $5/$30** (Apr 23). 5.5 Pro **$30/$180**. Batch at 50% | Opus 4.6 / 4.7 / 4.8 / Opus 5 all **$5/$25**. Fast mode $10/$50. Batch at 50% | Gemini 3 Flash $0.50/$3 | DeepSeek V4 Flash **$0.14/$0.28**, V4 Pro **$1.74/$3.48** | [S] |

**Rules of thumb for game pricing [E]:**
- **Frontier tier** launches at the price the market will bear: $15–30 input / $60–75 output in 2023–24, settling to **$2–5 / $10–30** in 2025–26.
- **Mid tier** stays at about $1–3 / $5–15.
- **Small tier** falls from ~$1–2 (2023) to $0.05–0.30 (2025–26).
- **Chinese open-weight models** sell at about 1/10 of US frontier prices.
- The price for a *fixed* capability falls about **10× per year**, while each new frontier generation resets the price higher. Output tokens cost about **4–8× input tokens**. Cached input is about 10% of input price. Batch is about 50%.

### 4.2 Subscription tiers

| Tier | 2023 | 2024 | 2025 | 2026 | Tag |
|---|---|---|---|---|---|
| Free (ad-free) | ✓ | ✓ | ✓ | ChatGPT free tier gets **ads** | [S] |
| Budget (~$5–8) | — | — | ChatGPT Go launched in India (~₹399) | **ChatGPT Go $8/mo**, global (Jan) | [S]/[BK] |
| Standard **$20** | ChatGPT Plus (Feb). Claude Pro (Sep) | Google One AI Premium $19.99. Perplexity Pro $20 | same. SuperGrok $30 | same | [BK] |
| Team / Business seat | — | ChatGPT Team $25–30. Claude Team $25–30 | same | Claude Enterprise ~$20/seat + usage at API rates, 20-seat minimum [S] | [BK]/[S] |
| Power user **$100–$300** | — | **ChatGPT Pro $200** (Dec 5) | Claude Max **$100 / $200** (Apr). Google AI Ultra **$249.99** (May). SuperGrok Heavy **$300** (Jul). Perplexity Max $200 | ChatGPT Pro **$100** tier added (Apr 9). Ultra possibly cut to $99.99 with a $199.99 tier [D] | [S]/[BK] |
| Enterprise | ChatGPT Enterprise launched Aug 2023, ~$60/seat/mo, ~150-seat minimum (~$108K/yr) | — | — | quote-based, $45–75/seat | [S] |

**Conversion and counts:**
- About **5% of ChatGPT weekly actives pay**: 35M of ~700M (Jul 2025). OpenAI targets 220M paid of 2.6B (8.5%) by 2030 [S].
- ChatGPT business seats grew from 600K (Apr 2024) to 1M (Sep 2024), 2M (Feb 2025), 3M, then 7M+ ("for Work") and 9M (2026) [S].

### 4.3 Enterprise deal sizes (Anthropic, 2026 disclosure)

| Annual spend bucket | Count (Sep 30, 2026) | Tag |
|---|---|---|
| ≥ $100K | >11,900 | [S] |
| ≥ $1M | >1,900 | [S] |
| ≥ $10M | ~250 | [S] |
| Business customers total | >300,000 (Sep 2025) | [S] |

**Game [E]:** the deal-size distribution is roughly log-normal.

| Segment | Annual contract value |
|---|---|
| SMB | $5K–$50K |
| Mid-market | $50K–$500K |
| Enterprise | $0.5M–$5M |
| Strategic (cloud resellers, Big Tech, coding tools such as Cursor) | $10M–$1B+ |

Revenue concentration: early on, the top 2 API customers can be 20–25% of API revenue (Cursor and GitHub Copilot for Anthropic in 2025 [BK]).

### 4.4 Gross margin and inference cost

| Company | Metric | 2024 | 2025 | Target | Tag |
|---|---|---|---|---|---|
| OpenAI | Adjusted gross margin (revenue − inference) | ~40% | **~33%** (plan was 46%) | ~70% by 2029 [BK] | [S] |
| OpenAI | "Compute margin" on paid usage | ~35% (Jan) | ~70% (Oct) | — | [S] |
| Anthropic | Gross margin, API/enterprise | <0–~40% [BK] | **~40%** (38% incl. free users). Inference cost +23% vs plan | >70% by 2027 | [S] |
| Anthropic | Operating margin | — | ≈ −170% (−$8B on $4.6B) | ≈ −4% in H1 2026 (−$0.69B on $16.3B) | [S] |
| Typical SaaS (for comparison) | Gross margin | 75–80% | | | [BK] |

**Inference cost for the game [E]:**
- Serving cost ≈ **30–60% of list price** for a frontier lab in 2025–26.
- Free users cost money but convert at ~5%.
- **Training a frontier model:**

| Year | Cost of the final training run | Total R&D compute per year, top lab |
|---|---|---|
| 2023 | ~$50–100M (GPT-4 ~$78–100M) | — |
| 2024 | ~$100–200M (Gemini Ultra ~$190M, AI Index) | — |
| 2025 | ~$300M–$1B | ~$5–15B |
| 2026 | ~$1–3B | ~$15–40B |

  (Pre-2025 figures are [BK]; the rest are [E].) DeepSeek's "$5.6M" counts only the final run at rental prices [S].
- **GPU economics:** H100 purchase price ≈ $25–40K [BK]. Rental: 2023 $4–10/hr, 2024 ~$2.5–4, late 2025 ~$1.70–2.20, 2026 ~$2.35–2.80 [S]. Hyperscaler on-demand is about 2–4× neocloud prices [S].

---

## 5. Suggested config skeleton (values to paste into a Lua/JSON table)

```
-- Values are mid-points of the ranges above. Units: USD per year unless noted.
SalaryTC = {
  [2023] = { JuniorMLE=275e3, MidMLE=450e3, SeniorMLE=700e3, StaffMLE=1.05e6, StarResearcher=5e6,
             Infra=450e3, DataEng=350e3, ProductEng=420e3, Designer=400e3, PM=470e3,
             SalesAE=320e3, Marketing=260e3, PolicySafety=370e3, Legal=360e3, Recruiter=230e3,
             VP=3e6, CSuite=8e6 },
  [2024] = { JuniorMLE=320e3, MidMLE=530e3, SeniorMLE=780e3, StaffMLE=1.2e6, StarResearcher=1.2e7,
             Infra=520e3, DataEng=390e3, ProductEng=460e3, Designer=480e3, PM=550e3,
             SalesAE=360e3, Marketing=300e3, PolicySafety=440e3, Legal=400e3, Recruiter=250e3,
             VP=4e6, CSuite=1.1e7 },
  [2025] = { JuniorMLE=390e3, MidMLE=650e3, SeniorMLE=850e3, StaffMLE=1.5e6, StarResearcher=4e7,
             Infra=670e3, DataEng=500e3, ProductEng=570e3, Designer=670e3, PM=720e3,
             SalesAE=430e3, Marketing=340e3, PolicySafety=510e3, Legal=440e3, Recruiter=290e3,
             VP=6e6, CSuite=1.5e7 },
  [2026] = { JuniorMLE=415e3, MidMLE=690e3, SeniorMLE=920e3, StaffMLE=1.7e6, StarResearcher=2.5e7,
             Infra=710e3, DataEng=530e3, ProductEng=610e3, Designer=720e3, PM=780e3,
             SalesAE=470e3, Marketing=370e3, PolicySafety=550e3, Legal=470e3, Recruiter=310e3,
             VP=6e6, CSuite=1.5e7 },
}
-- Fraction of TC paid in cash (rest is equity → dilution, not cash burn)
CashShare = { JuniorMLE=0.55, MidMLE=0.4, SeniorMLE=0.35, StaffMLE=0.25, StarResearcher=0.05,
              Infra=0.45, DataEng=0.5, ProductEng=0.45, Designer=0.45, PM=0.4, SalesAE=0.6,
              Marketing=0.6, PolicySafety=0.5, Legal=0.65, Recruiter=0.7, VP=0.15, CSuite=0.1 }
StartupCashMultiplier = 0.7          -- startup base vs big-lab base
BenefitsLoad = { highPaid=1.25, lowPaid=1.40, contractor=1.0 }
SeatCostPerYear = { SF=16e3, NYC=16e3, London=37e3, TelAviv=7.5e3, Remote=9e3 }
LabelerHourly = { [2023]={offshore=2, generalist=18, expert=50}, [2024]={offshore=4, generalist=20, expert=70},
                  [2025]={offshore=5, generalist=20, expert=100}, [2026]={offshore=6, generalist=22, expert=120} }
H100HourlyRent = { [2023]=6.0, [2024]=3.0, [2025]=2.0, [2026]=2.6 }
Seed2023 = { amount=3.4e6, preMoney=16e6, team=5 }
SeriesA2023 = { amount=12.5e6, preMoney=52e6, team=20 }
SubPrices = { plus=20, pro=200, go=8 }          -- per month; pro from Dec 2024, go from 2025/26
PayConversion = 0.05                              -- share of active users who pay
GrossMargin = { [2023]=0.25, [2024]=0.40, [2025]=0.38, [2026]=0.50 }
```

---

## 6. Rival AI companies — valuation track for the "leaderboard" (USD B, post-money at the last round of each year)

| Company | End 2023 | End 2024 | End 2025 | 2026 (latest) |
|---|---|---|---|---|
| OpenAI | ~86 (tender) | 157 | 500 | **852** (Mar). IPO filed, ~$1T target |
| Anthropic | ~18 (Series D priced early 2024) | 18 → ~40 in talks | 183 | **965** (May). S-1 Oct |
| xAI | ~1 (seed est.) | ~50 | ~200 (talks) | 230 (Jan) → 250 in SpaceX deal |
| Mistral | ~2.1 | 6.2 | 13.7 (€11.7B) | ~24 (€21B) |
| Perplexity | ~0.5 | 9 | 20 | ~20+ |
| SSI | — | 5 | 32 | 32+ |
| Thinking Machines | — | — | 10–12 | ~40 (talks) |
| Reflection | — | ~0.5 | 8 | 8+ |
| Cohere | 2.2 | 5.5 | 7 | ~25 (CAD 35.7B) [D] |
| AI21 | 1.4 | 1.4 | 2–3 (Nvidia acquisition talks) | — |
| Moonshot | ~0.3–1 [BK] | ~3.3 | 4.3 | 20 → 35 (Jul) |
| Zhipu | ~1.5 [BK] | ~2.8 [BK] | ~6.5 | IPO 7.1 → rally |
| MiniMax | ~1.2 [BK] | ~2.5 [BK] | ~4 [BK] | IPO 9.2 |
| DeepSeek | private (no outside funding) | | | |

---

## 7. Sources

**Compensation**
- [Levels.fyi 2024 annual pay report thread](https://www.levels.fyi/community/thread/zqpz4L/levels-fyi-2024-annual-pay-report) · [levels.fyi/2024](https://levels.fyi/2024/) · [Korean summary of 2024 report (GeekNews)](https://news.hada.io/topic?id=18621)
- [LDS: Levels.fyi AI pay premium has stopped growing](https://letsdatascience.com/news/levelsfyi-tells-lds-the-ai-pay-premium-has-stopped-growing-a893d96e)
- [Levels.fyi OpenAI salaries](https://www.levels.fyi/company/OpenAI/salaries) · [Levels.fyi OpenAI PPU blog](https://www.levels.fyi/blog/openai-compensation.html) · [Levels.fyi Anthropic](https://www.levels.fyi/companies/anthropic/salaries) · [Anthropic research scientist](https://www.levels.fyi/companies/anthropic/salaries/software-engineer/title/research-scientist)
- [SF Standard: OpenAI engineers making crazy money (Jun 2023)](https://sfstandard.com/2023/06/26/the-openai-engineers-building-chatgpt-are-making-crazy-money)
- [HeroHunt: What OpenAI and Anthropic pay engineers 2026](https://www.herohunt.ai/blog/what-openai-and-anthropic-pay-engineers-2026/) · [FourWeekMBA: Anthropic senior engineers average $621K](https://fourweekmba.com/ai-anthropic-senior-engineers-average-621k-1-5x-googles-l5/)
- [Yahoo/Fortune: OpenAI $1.5M average stock comp](https://finance.yahoo.com/news/openai-paying-workers-1-5-154647420.html) · [CrowdFund Insider](https://www.crowdfundinsider.com/2026/01/257017-openais-latest-stock-compensation-sets-new-benchmarks-in-tech/)
- [TechCrunch: Meta multi-million pay, not $100M signing bonuses](https://techcrunch.com/2025/06/27/meta-is-offering-multi-million-pay-for-ai-researchers-but-not-100m-signing-bonuses/) · [Business Insider NL: winner-take-all era](https://www.businessinsider.nl/welcome-to-silicon-valleys-winner-take-all-era) · [Implicator: MSL cracks](https://www.implicator.ai/metas-superintelligence-bet-shows-cracks-as-researchers-exit/)
- [Bloomberg Tax: Meta poached Apple's Pang >$200M](https://news.bloombergtax.com/business-and-practice/meta-poached-apples-pang-with-pay-package-over-200-million) · [AppleInsider](https://appleinsider.com/articles/25/07/10/meta-lured-ai-exec-away-from-apple-with-blockbuster-200m-pay-package)
- [Gulf News: Tulloch rejected $1.5B](https://gulfnews.com/technology/who-is-andrew-tulloch-meet-the-man-who-rejected-marck-zuckerbergs-15b-job-offer-1.500223824) · [TechCrunch: Tulloch heads to Meta](https://techcrunch.com/2025/10/11/thinking-machines-lab-co-founder-andrew-tulloch-heads-to-meta/) · [Forbes AU: Tulloch joins Anthropic](https://www.forbes.com.au/news/innovation/meta-ai-engineer-andrew-tulloch-joins-anthropic/)
- [Benzinga: OpenAI $1.5M bonus](https://benzinga.com/markets/tech/25/08/46949685/zuck-poaching-effect-pushes-openai-to-announce-1-5-million-bonus-for-all-employees-even-new-hires-says-tech-entrepreneur) · [Windows Report: 1,000 R&E staff](https://windowsreport.com/openai-to-reportedly-reward-1000-research-engineering-employees-totalling-1-5-billion-in-bonuses/)
- [Seeking Alpha: Google special stock pool for AI researchers](https://seekingalpha.com/news/4055187-google-s=) · [BBC/Reuters: DeepMind $20M packages](https://bbc.bm/?p=14642)
- [Carta: AI shifts in compensation](https://carta.com/data/ai-shifts-in-compensation/) · [Carta H2 2025 startup compensation](https://carta.com/data/startup-compensation-h2-2025-full-report/) · [SignalFire: AI salary surge](https://www.signalfire.com/blog/ai-salary-surge-and-tech-talent-trends)
- [Levels.fyi Google SWE](https://levels.fyi/companies/google/salaries/software-engineer/) · [Levels.fyi Meta SWE](https://levels.fyi/companies/meta/salaries/software-engineer/) · [Meta E7](https://www.levels.fyi/companies/meta/salaries/software-engineer/levels/e7)
- [Levels.fyi OpenAI product designer](https://www.levels.fyi/companies/openai/salaries/product-designer) · [Levels.fyi Anthropic PM](https://www.levels.fyi/companies/anthropic/salaries/product-manager) · [Aakash G: AI PM salary](https://www.aakashg.com/ai-product-manager-salary/)
- Job postings: [Anthropic Scaled Enterprise AE](https://www.indexventures.com/startup-jobs/anthropic/scaled-enterprise-account-executive-industries/) · [Anthropic Enterprise AE Tech](https://jobs.generalcatalyst.com/companies/anthropic/jobs/90402254-enterprise-account-executive-tech) · [Anthropic Research Counsel](https://startup.jobs/research-counsel-anthropic-3-9903051) · [Anthropic Recruiter, Research](https://jobs.lever.co/Anthropic/e13e91b0-0792-4ebe-8584-2f8d9c8b3959) · [OpenAI ML Infrastructure Engineer](https://jobs.khoslaventures.com/companies/openai/jobs/56656440-ml-infrastructure-engineer) · [OpenAI Monetization ML Infra](https://jobs.khoslaventures.com/companies/openai/jobs/81277208-software-engineer-monetization-ml-infrastructure) · [OpenAI Research Engineer, AI for Science](https://jobs.stripes.co/companies/openai/jobs/65111552-research-engineer-ai-for-science) · [OpenAI Data Infrastructure Engineer](https://jobs.omegavp.com/companies/openai/jobs/29184978-data-infrastructure-engineer) · [OpenAI Cloud Infrastructure](https://jobs.omegavp.com/companies/openai/jobs/55845343-software-engineer-cloud-infrastructure)
- Labelers: [Inc: Outlier non-payment](https://www.inc.com/sam-blum/its-a-scam-accusations-of-mass-non-payment-grow-against-scale-ais-subsidiary-outlier-ai.html) · [The Condia: Kenyan AI workers](https://thecondia.com/kenyan-ai-workers-exploitation-openai-meta-sama-pay-gap/) · [Scale: Remotasks overview](https://scale.com/blog/remotasks-overview) · [aitrainer.work Outlier review](https://aitrainer.work/guides/outlier-review) · [Mercor CS/ML PhDs posting](https://work.mercor.com/jobs/list_AAABlWI_CHFyoDOAdyJKb4vw/cs-and-machine-learning-phds) · [Mercor: AI trainer salary](https://mercor.com/resources/experts/ai-trainer-salary-hourly-rates/) · [Moneywise: AI training jobs](https://moneywise.com/news/top-stories/ai-training-jobs-white-collar-workers-pay) · [Advisor Perspectives: $1,000/hr gig workers](https://api.advisorperspectives.com/articles/2026/02/03/some-ai-gig-workers-1-000-hour-can-last) · [FourWeekMBA: doctors and lawyers $400/hr](https://fourweekmba.com/ai-doctors-and-lawyers-now-train-ai-for-up-to-400-an-hour/)
- Benefits: [BLS ECEC Dec 2024 release (Mar 2025)](https://www.bls.gov/news.release/archives/ecec_03142025.htm) · [BLS ECEC Mar 2024 (Jun 2024)](https://www.bls.gov/news.release/archives/ecec_06182024.htm)

**Company finances**
- OpenAI: [Verdict: $40B SoftBank round](https://www.verdict.co.uk/openai-secures-40bn-in-softbank-led-funding-round/) · [Geo/Reuters: $500B secondary](https://www.geo.tv/latest/626617-openai-hits-500-billion-valuation-after-share-sale-to-softbank-others-source-says) · [SiliconANGLE: SoftBank completes](https://siliconangle.com/2025/12/30/softbank-reportedly-finalizes-openai-investment-22-5b-cash-infusion) · [Built In: $110B at $730B](https://builtin.com/articles/openai-raises-110b-730b-valuation-20260227) · [Yahoo: closes $122B at $852B](https://finance.yahoo.com/markets/stocks/articles/openai-closes-122bn-funding-round-093126735.html) · [TechSpot: made $13B, lost $21B](https://techspot.com/news/112794-openai-made-13-billion-2025-lost-21-billion.html) · [Fortune: losses through 2028](https://fortune.com/2025/11/12/openai-cash-burn-rate-annual-losses-2028-profitable-2030-financial-documents/) · [Fortune: $5B loss 2024](https://fortune.com/2024/09/28/openai-5-billion-loss-2024-revenue-forecasts-fundraising-chapgpt-fee-hikes/) · [The Decoder: revenue surging](https://the-decoder.com/openai-revenue-keeps-surging-as-company-seeks-30-billion-in-fresh-capital/) · [AI Magazine: billion users, $852B](https://aimagazine.com/news/openais-billion-users-us-852bn-valuation-and-stargate) · [StoneX: OpenAI IPO](https://www.stonex.com/en-gb/news-and-analysis/openai-ipo-everything-you-need-to-know-about-openai/) · [Techstrong: revenues outpaced by losses](https://techstrong.ai/articles/openais-fast-growing-revenues-outpaced-by-massive-scale-of-losses-ahead-of-expected-ipo/) · [Tom's Hardware: DeepSeek 160 vs OpenAI ~2,000 staff](https://www.tomshardware.com/tech-industry/artificial-intelligence/deepseek-clearly-not-interested-in-scaling-up-160-person-team-focused-on-developing-new-models) · [PYMNTS: 220M paid users by 2030](https://www.pymnts.com/artificial-intelligence-2/2025/openai-expects-chatgpt-to-have-220-million-paid-subscribers-by-2030/) · [The Decoder: 3M enterprise users](https://the-decoder.com/openai-reaches-three-million-enterprise-users-adds-new-chatgpt-business-features/)
- Anthropic: [Fortune: Amazon $4B (2023)](https://fortune.com/2023/09/25/anthropic-ai-startup-4-billion-funding-amazon-investment-big-tech/) · [KSL/Reuters factbox: investors](https://www.ksl.com/article/51641111/factbox-from-amazon-to-google-the-deep-pocketed-investors-in-anthropic) · [TipRanks: $61.5B](https://www.tipranks.com/news/amazon-backed-anthropics-valuation-skyrockets-to-61-5b-amid-ai-boom) · [GIC PDF: Series F $13B at $183B](https://www.gic.com.sg/uploads/2025/09/Anthropic-raises-13B-Series-F-at-183B-post-money-valuation.pdf) · [Anthropic: Series G $30B at $380B](https://www.anthropic.com/news/anthropic-raises-30-billion-series-g-funding-380-billion-post-money-valuation?pubDate=20250519) · [Crunchbase: Series H $65B](https://news.crunchbase.com/ai/anthropic-nears-1t-valuation-65b-seriesh/) · [Built In: $965B](https://builtin.com/articles/anthropic-raises-65b-series-h-965b-valuation-20260601) · [Bloomberg Gov: run-rate >$65B](https://news.bgov.com/financial-accounting/anthropic-revenue-run-rate-surpasses-65-billion-ahead-of-ipo) · [The Decoder: sevenfold](https://the-decoder.com/anthropic-increases-revenue-sevenfold-hits-annualized-rate-above-65-billion/) · [PPC Land: S-1 $16.3B H1](https://ppc.land/anthropic-files-for-nasdaq-ipo-with-16-3bn-in-first-half-revenue/) · [SiliconANGLE: leaked filing $8B operating loss](https://siliconangle.com/2026/09/29/leaked-anthropic-ipo-filing-reveals-8b-operating-loss-rapid-revenue-growth/) · [Hackernoon: S-1 analysis](https://hackernoon.com/anthropics-s-1-shows-$163b-in-half-year-revenue-a-900percent-nrr-and-an-$807b-loss-that-mostly-isnt) · [Verdict: IPO before Thanksgiving](https://www.verdict.co.uk/newsletters/anthropic-files-for-ipo) · [Crypto Briefing: 11,900 customers ≥$100K](https://cryptobriefing.com/anthropic-11900-customers-100k-annual-spend/) · [Crypto Briefing: $6.6M revenue per employee](https://cryptobriefing.com/anthropic-revenue-per-employee-6-6-million/)
- Margins: [Michael Parekh: OpenAI vs Anthropic metrics](https://michaelparekh.substack.com/p/ai-diving-into-openai-vs-anthropic) · [SaaStr: AI gross margins](https://www.saastr.com/have-ai-gross-margins-really-turned-the-corner/) · [WebProNews: Anthropic margin squeeze](https://www.webpronews.com/anthropics-margin-squeeze-inference-costs-bite-as-revenue-surges/)
- Google / Meta: [IEEE ComSoc: Alphabet 2026 capex](https://techblog.comsoc.org/2026/02/04/alphabets-2026-forecast-capex-soars-gemini-3-ai-model-is-a-huge-success/) · [CNBC: DeepMind staff costs 2022](https://www.cnbc.com/2023/10/11/alphabets-ai-lab-deepmind-cut-employee-costs-by-nearly-40percent-in-2022.html) · [LongTermWiki: DeepMind](https://www.longtermwiki.com/organizations/deepmind) · [Fortune: Meta $145B](https://fortune.com/2026/04/29/meta-zuckerberg-145-billion-ai-spending-roi/) · [The Next Web: Meta 8,000 layoffs](https://thenextweb.com/news/meta-layoffs-8000-zuckerberg-ai-reality-may-2026)
- xAI: [Irish Times: $1.46B quarterly loss](https://www.irishtimes.com/business/2026/01/09/musks-xai-reports-146bn-quarterly-loss) · [Yahoo: xAI burned $6.4B (SpaceX filing)](https://finance.yahoo.com/sectors/technology/articles/xai-burned-6-4b-last-222608682.html) · [Data Center Knowledge: SpaceX–xAI $1.25T](https://www.datacenterknowledge.com/business/musk-merges-xai-spacex-in-1-25t-ai-power-play-outlines-space-goals) · [Benzinga: $113B round](https://www.benzinga.com/news/topics/25/07/46453450/elon-musks-spacex-commits-2-billion-to-xai-in-5-billion-round-as-ai-startup-hits-113-billion-valuatio) · [Sacra: xAI](https://sacra.com/c/xai/) · [StartupHub: SpaceXAI $500M ARR](https://www.startuphub.ai/news/figure-elon-musk-spacexai-financial-breakdown-2026-07-09)
- Mistral: [TechCrunch: everything about Mistral](https://techcrunch.com/2025/02/28/what-is-mistral-ai-everything-to-know-about-the-openai-competitor/embed) · [École Polytechnique: €12B](https://www.polytechnique.edu/en/news/mistral-ai-gem-co-founded-two-x-graduates-doubles-its-valuation-eu12-billion) · [Euronews: €3B Samsung-led](https://www.euronews.com/2026/09/08/mistral-ai-raises-record-3-billion-in-samsung-led-funding-round) · [Channel Insider: $24B, $1B ARR target](https://www.channelinsider.com/ai/news-mistral-24b-valuation-europe-sovereign-ai-emea-france/)
- China: [Heise: DeepSeek V3 cost](https://heise.de/-10267795) · [Tom's Hardware: DeepSeek 50K GPUs, $1.6B](https://www.tomshardware.com/tech-industry/artificial-intelligence/deepseek-might-not-be-as-disruptive-as-claimed-firm-reportedly-has-50-000-nvidia-gpus-and-spent-usd1-6-billion-on-buildouts) · [SCMP: Alibaba $53B](https://www.scmp.com/tech/big-tech/article/3299858/alibaba-commits-us53-billion-ai-infrastructure-largest-private-computing-project) · [The Standard HK: 380B yuan](https://www.thestandard.com.hk/finance/article/70432/Alibaba-to-invest-380b-yuan-in-Cloud-AI) · [eWeek: Moonshot $20B](https://www.eweek.com/news/moonshot-ai-2b-funding-china-ai-race-apac/) · [Yicai: Moonshot $35B](https://www2.yicaiglobal.com/news/moonshot-ais-latest-fundraiser-lifts-valuation-to-usd35-billion-amid-kimis-silicon-valley-buzz) · [Sacra: Moonshot](https://sacra.com/c/moonshot-ai/) · [Caixin: Zhipu debut](https://www.caixinglobal.com/2026-01-08/chinas-zhipu-ai-jumps-in-hong-kong-debut-102401610.html) · [Lapaas: Zhipu losses](https://voice.lapaas.com/?p=18958) · [Jiemian: MiniMax results](https://en.jiemian.com/article/14064158.html) · [Caixin: MiniMax debut](https://www.caixinglobal.com/2026-01-09/chinese-ai-startup-minimax-pops-in-hong-kong-debut-102402143.html)
- Others: [TechCrunch: Cohere $6.8B](https://techcrunch.com/2025/08/14/cohere-hits-a-6-8b-valuation-as-investors-amd-nvidia-and-salesforce-double-down) · [Sacra: Cohere](https://sacra.com/c/cohere/) · [AI Magazine: Cohere $25B](https://aimagazine.com/news/cohere-hits-us-25bn-as-canada-nvidia-fund-sovereign-ai) · [SiliconANGLE: Nvidia–AI21](https://siliconangle.com/2025/12/30/report-nvidia-acquire-llm-startup-ai21-labs-3b/) · [Calcalist: AI21](https://www.calcalistech.com/ctechnews/article/rjswz37eze) · [Sacra: Perplexity](https://sacra.com/c/perplexity) · [VKTR: Perplexity $20B](https://www.vktr.com/ai-news/perplexity-raises-200m-at-20b-valuation-in-ai-search-push/) · [Maginative: SSI $1B at $5B](https://www.maginative.com/article/safe-superintelligence-raises-1-billion-reaching-5-billion-valuation-in-just-three-months/) · [TechCrunch: SSI $32B](https://techcrunch.com/2025/04/12/openai-co-founder-ilya-sutskevers-safe-superintelligence-reportedly-valued-at-32b) · [FourWeekMBA: Thinking Machines $2B at $12B](https://fourweekmba.com/thinking-machines-lab-officially-closes-2b-at-12b-valuation-teases-first-product-launch/) · [Forkast: TML seeks $40B](https://forkast.news/thinking-machines-lab-seeks-40b-valuation-as-nvidia-extends-its-capital-allocator-role-into-model-space/) · [SiliconANGLE: Reflection $2B at $8B](https://siliconangle.com/2025/10/09/reflection-ai-lands-2b-8b-valuation-expand-frontier-ai-infrastructure-safety-research/)

**Startups, offices, credits, GPUs**
- [Carta: AI startups 2023](https://carta.com/data/ai-startups-2023/) · [TechCrunch: valued startups 2023](https://techcrunch.com/2023/06/11/valued-startups-in-venture-market) · [Carta: AI fundraising trends 2024](https://carta.com/data/ai-fundraising-trends-2024/) · [Gunderson 2025 VC report](https://www.gunder.com/a/web/qqWcgGFzJwPtu3ThTcyfyX/2025-venture-capital-report-final.pdf) · [PitchBook Q2 2025 AI VC trends](https://files.pitchbook.com/website/files/pdf/Q2_2025_AI_VC_Trends_19893.pdf) · [TNW: megadeals 87.5% of US VC](https://thenextweb.com/news/pitchbook-q2-2026-megadeals-87-percent-us-venture-vintage-discount)
- [The Real Deal: SF AI demand 2023](https://therealdeal.com/sanfrancisco/2023/10/13/sf-office-market-sees-uptick-in-demand-by-ai-and-tech-firms) · [The Real Deal: SF 2024](https://therealdeal.com/sanfrancisco/2024/04/10/san-francisco-office-demand-rises-with-ai-leading-the-way) · [The Real Deal: Oct 2025](https://therealdeal.com/san-francisco/2025/10/16/ai-companies-driving-stellar-san-francisco-office-leasing) · [The Real Deal: Jul 2026](https://therealdeal.com/san-francisco/2026/07/01/san-francisco-office-vacancy-down-5-points-in-a-year/) · [CBRE SF figures](https://mktgdocs.cbre.com/2299/4b628c03-e0be-422a-af2b-5bd047bb9a65-960261425/San_Francisco_Office_Figures_Q.pdf) · [CBRE Manhattan Q4 2025](https://www.cbre.com/insights/figures/manhattan-office-figures-q4-2025) · [Lee & Associates NYC Q4 2025](https://www.lee-associates.com/new-york/2026/03/04/manhattan-office-leasing-2025-q4-class-b-tech-demand/) · [Langham Estate: London prime rents 2026](https://langhamestate.com/industry-community/prime-office-rent-in-london-per-sq-ft/) · [Carter Jonas Q1 2026](https://www.carterjonas.co.uk/news/2026/05/the-london-office-market-q1-2026-supply-constraints-drive-record-occupancy-costs-across-londons-office-market) · [Globes: defense-tech pushes TLV rents](https://en.globes.co.il/en/article-1001554326) · [Newmark Natam H1 2023](https://www.nmrk.com/storage-nmrk/uploads/images/Natam-Report-EN-First-half-2023.pdf) · [Globes: Spiral Tower lease](https://en.globes.co.il/en/article-1001514845)
- [Causo: startup cloud credits compared 2026](https://hub.causo.ai/startup-cloud-credits-compared-2026) · [fin.ai: startup programs compared](https://fin.ai/learn/startup-credit-programs) · [GMI Cloud: GPU credit programs](https://www.gmicloud.ai/en/blog/gpu-credit-programs-for-ai-startups-from-prototype-to-production-without-dilution)
- [IntuitionLabs: H100 rental prices](https://intuitionlabs.ai/articles/h100-rental-prices-cloud-comparison) · [FourWeekMBA: H100 rent $2.80](https://fourweekmba.com/ai-patels-data-puts-nvidia-h100-rent-up-65-in-a-year-at-2-80/) · [Silicon Data: H100 price spike](https://www.silicondata.com/blog/h100-price-spike) · [Rallies: H100 $2.35](https://rallies.ai/news/h100-gpu-rental-rates-surge-40-to-235hour-as-ai-demand-outpaces-supply)

**Pricing and subscriptions**
- [OpenAI pricing docs](https://developers.openai.com/api/docs/pricing) · [CloudZero: GPT-4 API cost](https://www.cloudzero.com/blog/gpt-4-api-cost) · [Implicator: GPT-5.5 prices](https://www.implicator.ai/openai-gpt-5-5-by-the-numbers-higher-prices-disputed-benchmarks/) · [Finout: Claude pricing 2026](https://www.finout.io/blog/claude-pricing-in-2026-for-individuals-organizations-and-developers) · [Morph: Claude API pricing](https://www.morphllm.com/anthropic-claude-api-pricing) · [The Decoder: DeepSeek V3.2 −75%](https://the-decoder.com/deepseek-slashes-api-prices-by-up-to-75-percent-with-its-latest-v3-2-model/) · [CloudZero: Gemini pricing](https://www.cloudzero.com/blog/gemini-pricing/) · [Gemini pricing history](https://geminipricing.pages.dev/pricing-history)
- [SentiSight: 2026 subscription prices](https://www.sentisight.ai/ai-price-comparison-gemini-chatgpt-claude-grok/) · [Notebookcheck: AI subscriptions 2026](https://www.notebookcheck.net/What-AI-subscriptions-cost-in-2026-and-which-one-is-worth-it.1341432.0.html) · [Sentra: ChatGPT Enterprise pricing](https://www.sentra.app/articles/chatgpt-enterprise-pricing) · [Redress: OpenAI enterprise pricing](https://redresscompliance.com/openai-enterprise-negotiation-pricing-benchmarks.html)

---

## 8. Caveats

- Levels.fyi data is self-reported and skews toward people who negotiate hard. Use the **ranges** in this document, not single points.
- Run-rate (ARR) is not revenue. Anthropic's S-1 shows $4.6B of 2025 revenue against a ~$9B year-end ARR.
- "Valuation" is post-money unless noted. Some 2026 rounds include strategic money that is mostly compute credits (Amazon, Nvidia, Google).
- Several 2026 data points come from secondary aggregators and are tagged [D]: OpenAI ~$70B ARR, Cohere $25B, SSI $5B round, Moonshot $50B, Google AI Ultra price cut. Use them for news-ticker flavour only, or treat them as optional events.
- Meta's mega-offers were officially disputed. The game can present them as rumours that become real offers only for "legendary" researchers.

## 9. Known gaps (search budget ran out)

- No primary-source figures for marketing, designer, policy or executive pay at labs. Those rows are [E].
- No new-grad PhD offer data. Background knowledge suggests $300K–$1M+ for top PhDs at labs in 2024–25.
- OpenAI and Anthropic headcount for 2024 and 2026 is partly estimated.
- Qwen and Alibaba user numbers are missing.
- Scale AI, Surge and Mercor company revenues are missing. Background knowledge: Scale ~$870M (2024); Surge >$1B (2024, bootstrapped); Mercor ~$10B valuation (late 2025).
- Exact 2023–2025 back-cast Big Tech level data is interpolated ([E]) from 2026 Levels.fyi medians.
