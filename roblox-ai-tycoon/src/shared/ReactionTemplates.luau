--!strict
-- Reaction template bank v0.2 (design 01 + research 04/11). Format per line:  TAGS|text
-- TAGS: comma list; ANY = fits every launch. A line is eligible when ANY or one of its tags fired.
-- Variables: {model} {lab} {bench} {score} {delta} {rival} {rivalModel} {price} {pricePct} {tps} {ctx}
--            {size} {year} {nextYear} {elo} {rank} {users}
-- No emoji on purpose: the game UI uses rendered icons, never emoji.
local T = {}

T.personas = {
	researcher = { name = "Frontier researcher", platform = "x", followers = { 2e4, 3e5 }, handles = { "tensor_tess", "gradient_ghost", "attn_is_all", "sparse_sofia", "dr_logits", "kl_divergent", "residual_ray" } },
	hype = { name = "Hype account", platform = "x", followers = { 5e4, 9e5 }, handles = { "AIBreakingNow", "agi_by_friday", "TheAIFeed", "singularity_daily", "PromptKingHQ", "FutureIsNowAI" } },
	skeptic = { name = "Skeptic professor", platform = "x", followers = { 1e4, 1.5e5 }, handles = { "prof_actually", "stochastic_parrot_fan", "NotSoFastAI", "dr_baseline", "deep_doubt" } },
	tinkerer = { name = "Local LLM tinkerer", platform = "reddit", followers = { 500, 2e4 }, handles = { "u/gguf_goblin", "u/4090_or_bust", "u/quant_queen", "u/vram_poor", "u/ollama_enjoyer", "u/llamacpp_lover" } },
	dev = { name = "API developer", platform = "x", followers = { 1e3, 6e4 }, handles = { "shipfast_sam", "indiehacker_ivy", "gpuPoorDan", "buildinpublic_bo", "tokens_and_tacos" } },
	cto = { name = "Enterprise CTO", platform = "linkedin", followers = { 2e3, 4e4 }, handles = { "Michael R., CTO", "Sarah K., VP Engineering", "David L., Chief Digital Officer", "Rachel T., Head of AI" } },
	nerd = { name = "Benchmark nerd", platform = "x", followers = { 3e3, 8e4 }, handles = { "evals_enjoyer", "leaderboard_larry", "pareto_pete", "chart_crimes_cop", "elo_hell" } },
	safety = { name = "Safety researcher", platform = "x", followers = { 5e3, 1e5 }, handles = { "red_team_rina", "aligned_or_bust", "system_card_sam", "misuse_mira", "eval_awareness" } },
	journalist = { name = "Tech journalist", platform = "press", followers = { 2e4, 5e5 }, handles = { "The Verge-ish", "TechWire", "Silicon Daily", "The Information Desk", "Bloomline Tech", "Wired Weekly" } },
	vc = { name = "VC", platform = "x", followers = { 3e4, 7e5 }, handles = { "seedstage_steve", "moats_dot_vc", "tenx_tom", "series_a_anna", "the_contrarian_lp" } },
	memer = { name = "Memer", platform = "x", followers = { 1e3, 2e6 }, handles = { "goblin_mode_ai", "dril_gpt", "tokenposting", "cursed_prompts", "ai_shitposter", "lossfunction_lol" } },
	poweruser = { name = "Disappointed power user", platform = "reddit", followers = { 200, 1e4 }, handles = { "u/longtime_subscriber", "u/prompt_veteran", "u/cancelled_my_plan", "u/daily_driver_dan" } },
	rivalemp = { name = "Rival lab employee", platform = "x", followers = { 5e3, 2e5 }, handles = { "mts_at_somewhere", "posttrain_pat", "ex_brain_now_lab", "scaling_sara" } },
	fanboy = { name = "Rival fanboy", platform = "x", followers = { 100, 3e4 }, handles = { "team_rival_4ever", "loyal_subscriber", "goat_model_stan", "cope_and_seethe" } },
	student = { name = "Student / gamer", platform = "x", followers = { 50, 5e3 }, handles = { "homework_hater", "noah_plays_mc", "cs_freshman", "finals_week_fear", "redstone_rookie" } },
	intl = { name = "Non-English user", platform = "x", followers = { 500, 5e4 }, handles = { "tal_codes_il", "kenji_dev_jp", "lucia_ia_es", "rahul_builds_in", "chen_ai_cn" } },
	purist = { name = "Open-source purist", platform = "hn", followers = { 300, 2e4 }, handles = { "gnu_or_nothing", "weights_or_gtfo", "apache2_andy", "copyleft_carl" } },
	vibecoder = { name = "Vibe coder", platform = "x", followers = { 500, 8e4 }, handles = { "vibe_shipper", "no_code_nina", "built_it_in_a_weekend", "cursor_maxxer" } },
	doomer = { name = "Worried onlooker", platform = "x", followers = { 1e3, 1e5 }, handles = { "pdoom_watch", "slow_down_pls", "x_risk_rachel", "pause_ai_paul" } },
	insider = { name = "Gossip insider", platform = "x", followers = { 2e4, 4e5 }, handles = { "jimmy_apples_ish", "vague_leaker", "the_ai_insider", "i_hear_things" } },
	hn = { name = "Hacker News commenter", platform = "hn", followers = { 100, 5e3 }, handles = { "throwaway2291", "dang_it", "kernel_panic", "lisp_enjoyer", "pg_reader" } },
}

T.lines = {
	researcher = [[
SOTA,BIG_JUMP|Interesting release from {lab}. The {bench} jump (+{delta}) is real if it holds on held-out sets. Curious about the data mix.
ANY|{model} is out. Read the tech report twice. The post-training section is where all the real work is.
SOTA|Credit where due: {model} sets a new bar on {bench}. Would love an ablation of what actually moved it.
OPEN_HERO|Open weights at this level is a big deal for research. Thank you {lab}.
SLEEPER_HIT|Nobody is talking about {model} and that is a mistake. The {bench} number is wild for its size.
LONG_CONTEXT|Underrated part of {model}: the {ctx} context actually retrieves well past the middle in my tests.
REASONING|The reasoning traces from {model} are surprisingly clean. Less flailing than {rivalModel}.
CONTAMINATION|Ran {model} on a fresh set we wrote last week. It drops about {delta} points. Not great.
ANY|Benchmarks are saturating. What I care about: does it solve problems it has never seen. Early signs for {model}: partially.
OVERHYPED|The blog post says breakthrough. The evals say incremental. Both can be true but only one is a headline.
NEWCOMER|A new lab shipping something competitive in under a year is the real story here. {lab} is legit.
CODER|Gave {model} a real refactor from our repo. It got it right in one pass. That has not happened before.
AGENTS|The agent results are the interesting bit. Long-horizon tasks are where the gap between labs is now.
VISION|{model} reads my handwritten notes better than I do. Vision is finally useful.
ANY|Hot take: the {size} size class is where all the interesting tradeoffs live right now. {model} is a good example.
HALLUCINATES|Asked {model} for citations on my own subfield. Three of five papers do not exist. Calibration still matters.
VALUE_KING|The price-performance here is the result. Capability per dollar just moved a lot.
GOOD_VIBES|Something about the {model} character training is just better. Hard to measure, easy to feel.
FLOP|Looked at {model} for a day. It is fine. It is not frontier. That is okay, but the launch framing was not.
MULTILINGUAL|Finally a model that does not get dumber outside English. {model} holds up in every language I tried.
ARENA_KING|Arena number one is a vibes metric, but vibes are what users actually buy. Congrats {lab}.
SAFE_CARD|The {model} system card is the most detailed I have read this year. More labs should do this.
ANY|My hunch is {lab} found something in data quality, not architecture. The loss curve shape gives it away.
BIG_JUMP|If {model} is real, the timelines people laughed at a year ago look less silly.
JAILBROKEN|Jailbreaks within hours are now the default, not the exception. Safety evaluation needs to change.
ANY|Training details for {model} are thin, but the eval suite is honest. I will take it.
OPEN_HERO,RUNS_LOCAL|Downloaded {model}, poked at the attention maps. Open weights let us actually study this stuff.
CLAPBACK|Two frontier releases in one week. The field moves faster than peer review now.
IMAGEGEN|The image generation in {model} handles text inside images. That was the last hard part.
ANY|The thing I want to know about {model}: how much compute went into post-training versus pretraining.
]],
	hype = [[
SOTA,BIG_JUMP|BREAKING: {lab} just dropped {model} and it beats {rivalModel} on {bench}. This is insane.
SOTA|{model} is out. {score}% on {bench}. I repeat: {score}%. We are so back.
BIG_JUMP|AGI by {nextYear}? After {model} I am not joking anymore.
NEWCOMER|{lab} came out of NOWHERE. {rival} is in trouble.
SOTA|The {bench} chart just went vertical. {model} is that good.
SLEEPER_HIT|Everyone is sleeping on {model}. Bookmark this post.
ANY|{model} vs {rivalModel}. It is not even close. Thread below.
ARENA_KING|{model} is NUMBER ONE on the Arena. Elo {elo}. New king.
CODER|{model} just built a full SaaS app from one prompt. Developers are cooked.
VALUE_KING|{model} costs {pricePct}% less than {rivalModel}. The price war is ON.
OPEN_HERO|Open source just caught up. {model} weights are live. Download before they change their mind.
ANY|10 insane things people are already doing with {model} (number 7 will shock you)
REASONING|{model} thinks before it answers and it is SCARY good at math now.
AGENTS|{model} ran for hours on its own and finished the whole task. Agents are here.
LONG_CONTEXT|{ctx} context window. You can paste your entire life into {model}.
VISION|{model} can SEE. Show it a whiteboard and it writes the code. Wild.
VOICE|The {model} voice mode sounds more human than my friends. Not exaggerating.
IMAGEGEN|{model} image generation is breaking the internet right now. Everyone is posting.
CLAPBACK|{lab} answered {rival} in 72 hours. The AI war is getting brutal.
COLLISION|{lab} and {rival} launching on the SAME DAY. Which one are you using?
ANY|I have tested {model} for 6 hours straight. Full review thread below.
SOTA|New state of the art. Again. In {year}. The pace is unreal.
MELTDOWN|{model} is so good the servers are melting. That is how you know.
ANY|{lab} is not playing around anymore.
GOOD_VIBES|{model} feels different. Like talking to someone who actually gets it.
BIG_JUMP|This is the biggest jump since GPT-4. I said what I said.
ANY|Saving this post so I can say I was here when {model} launched.
NEWCOMER|Who is {lab}? Everyone is asking. Here is what we know.
ARENA_KING|{rival} had the crown for weeks. {model} took it in one afternoon.
ANY|If you are not using {model} yet you are already behind.
]],
	skeptic = [[
ANY|Another model, another chart with bars that go up. Wake me when it can count the letters in strawberry.
SOTA|{score}% on {bench}. Remarkable, given {bench} questions have been on the internet for years.
HALLUCINATES|Asked {model} a basic question from my intro course. It confidently invented a citation. Progress.
REASONING|Reasoning is doing a lot of heavy lifting in that announcement.
OVERHYPED|Bold claims. Independent evals please.
BIG_JUMP|A jump this size on a public benchmark makes me check the training data first, and the champagne second.
CONTAMINATION|Called it. Fresh questions, lower scores. The {bench} number was memorised, not learned.
ANY|{model} wrote a beautiful proof of something false. Fluency is not understanding.
ARENA_KING|Arena Elo measures which answer people like, not which answer is correct. Those are different things.
ANY|Counted the Rs in strawberry with {model}. Results: mixed.
OVERHYPED|The demo was impressive. The demo was also selected from many attempts. Remember the edited video era.
AGENTS|Agentic means it fails more slowly and with more steps.
ANY|Every launch is the most important launch ever, for about four days.
CODER|It passes the benchmark. It also wrote code that deletes the wrong folder. Both facts matter.
NEWCOMER|A lab nobody heard of last year claims frontier results. I will wait for the third-party numbers.
VALUE_KING|Cheap is good. Cheap and wrong is just efficiently wrong.
GLAZING|{model} told me my obviously broken argument was insightful. Flattery is not alignment.
ANY|The pelican on a bicycle is still a disaster. I will keep testing this until it is not.
SOTA|State of the art on a benchmark that will be retired next year. Noted.
FLOP|For once I do not have to be the skeptic. The internet is doing it for me.
ANY|The tech report has 40 pages and zero details about the data. Science.
HALLUCINATES|Confidently wrong in a calm, professional tone. Very enterprise ready.
BIG_JUMP|Please remember: the benchmark is not the task. The task is the task.
ANY|I tried {model} on my exam. It got an A on the questions that were online and a C on the new ones.
REASONING|It thinks for 40 seconds and then makes the same mistake, just more slowly.
]],
	tinkerer = [[
ANY|GGUF when?
OPEN_HERO,RUNS_LOCAL|Weights are up. Q4 of the {size} runs at about {tps} tok/s on my 4090. Absolutely cooking.
CLOSED|No open weights, no interest. Call me when {lab} ships something I can run.
OPEN_HERO|Already merged a fine-tune of {model} with a roleplay model. Do not ask.
RUNS_LOCAL|The {size} is the real story. Laptop-class model that does not feel dumb.
OPEN_HERO|License says no commercial use above 700M users. So, fine for me.
RUNS_LOCAL|Running {model} on my M2 MacBook in a coffee shop. Offline. Living in the future.
OPEN_HERO|Unsloth fine-tuning notebook for {model} already up. This community is insane.
ANY|What VRAM do I need for {model} at Q5? Asking for my 3060.
OPEN_HERO|Quantized {model} to 3 bits. Still coherent. Barely. Worth it.
CLOSED|Cool, another API I have to trust with my data. Pass.
OPEN_HERO|Abliterated version of {model} already on HF. That took about four hours.
RUNS_LOCAL|My home server just became the smartest thing in my house.
OPEN_HERO|Thank you {lab}. Seriously. The open community eats today.
ANY|Benchmarks are nice, but how is it at roleplay with a 16K context on a single GPU?
OPEN_HERO|Downloading 800GB of weights on hotel wifi. Pray for me.
VALUE_KING|Even the API is so cheap I might stop running local. Might.
RUNS_LOCAL|Phone version runs on my Pixel. Slow, but it runs. This is the year.
OPEN_HERO|Day one: weights. Day two: GGUF. Day three: fine-tunes. Day four: someone makes it talk like a pirate.
CLOSED|Imagine shipping a model in {year} and not releasing the small sizes. Couldn't be me.
OPEN_HERO|r/LocalLLaMA is down from too many people posting benchmarks of {model}.
ANY|Tried it through OpenRouter. Decent. Will wait for weights to judge properly.
]],
	dev = [[
VALUE_KING|Swapped {rivalModel} for {model} in production. Same quality, bill dropped {pricePct}%. Not going back.
OVERPRICED|${price} per million output tokens? Who is this for?
CODER|{model} wrote the whole migration on the first try. I am a little scared.
MELTDOWN|API is returning 529s. Day one things, I guess.
MELTDOWN|Rate limits are brutal. Cannot ship anything on this yet.
AGENTS|Tool calling is actually reliable now. This is the agent model I have been waiting for.
LONG_CONTEXT|Dumped our whole monorepo into {model}. It found the bug three teams missed.
ANY|Integrated {model} in 20 minutes. Docs are clean. Respect.
VALUE_KING|At this price I can finally give free users the good model.
CODER|{model} is the first model that reads my codebase conventions before writing code.
ANY|Latency is about {tps} tokens per second. Fine for chat, slow for autocomplete.
HALLUCINATES|It invented an API method that does not exist and then wrote tests for it. Impressive in its own way.
OVERPRICED|Love the model, hate the pricing page. Back to {rivalModel} for the bulk work.
ANY|Running evals on our internal set tonight. Will report back.
NERFED|Is anyone else seeing worse code output since yesterday? Same prompts, worse diffs.
CODER|{model} plus a decent harness just closed 14 tickets while I was at lunch.
VALUE_KING|Batch API discount plus prompt caching makes {model} basically free for our use case.
ANY|Function calling JSON is valid 100 out of 100 times in my test. That used to be 93.
MELTDOWN|Our app went down because {lab} went down. Lesson learned: always have a fallback model.
AGENTS|Gave {model} a sandbox and a goal. It wrote, ran, and fixed its own tests. Wild.
REASONING|Thinking mode solves the edge cases. It also triples my bill. Choose wisely.
ANY|Benchmarks are cool, but {model} handles our messy real-world inputs. That is what matters.
OPEN_HERO|Self-hosting {model} on our own GPUs. No vendor lock-in, no surprise price hikes.
GOOD_VIBES|Users actually said our support bot feels nicer after switching to {model}.
]],
	cto = [[
HALLUCINATES|Evaluating {model} for our support pipeline. Hallucination rate in our internal eval is a concern.
ANY|Impressive release from {lab}. Excited to explore how this can drive value for our customers. #AI #Innovation
ANY|Until there is SOC 2 and a data-retention agreement, it is a no for us.
MELTDOWN|Outage on launch day does not inspire confidence for mission-critical workloads.
SAFE_CARD|Strong system card from {lab}. This is the level of transparency enterprise buyers need.
VALUE_KING|We cut our AI spend by {pricePct}% by moving workloads to {model}. Thrilled to share this milestone.
AGENTS|Agents are the future of work. Proud to announce we are piloting {model} across our operations team.
JAILBROKEN|Seeing reports of {model} being jailbroken. We will pause our rollout until {lab} responds.
ANY|Three lessons from deploying {model} at scale (a thread for leaders):
LONG_CONTEXT|{ctx} context means our analysts can review an entire contract set in one pass. Game changer.
ANY|AI will not replace your team. A team using {model} will.
CODER|Our engineering velocity is up 30% since rolling out {model}. Agree?
NEWCOMER|Vendor risk is real. {lab} is impressive but young. We will watch their uptime for a quarter.
ANY|Grateful to the {lab} team for an early access briefing. The roadmap is exciting.
MULTILINGUAL|Strong multilingual performance from {model} unlocks our global support teams. #GlobalAI
OPEN_HERO|Open weights means we can run {model} inside our own cloud. Our compliance team is finally smiling.
]],
	nerd = [[
ANY|Updated the leaderboard. {model} enters at number {rank}, Elo {elo}. Big if it holds after more votes.
CONTAMINATION|Re-ran {bench} myself: got noticeably lower than the blog says. Not what was claimed.
VALUE_KING|Chart: {model} is now on the price/performance Pareto frontier.
BIG_JUMP|Someone check {bench} for contamination before we all lose our minds.
SOTA|New SOTA on {bench}: {score}%. Previous best was {rivalModel}. Margin: +{delta}.
ARENA_KING|Arena update: {model} takes number one. Confidence interval overlaps with number two, but still.
ANY|Full eval table for {model} across 14 benchmarks. Mostly great, two weird regressions.
OVERHYPED|The {lab} chart starts the y-axis at 60. Classic chart crime. Real gap is much smaller.
SLEEPER_HIT|Nobody is benchmarking {model} so I did. It quietly beats things twice its size.
REASONING|Thinking tokens per task are way up versus {rivalModel}. Cost-normalised, the gap shrinks.
ANY|Plotted every frontier release since {year}. {model} is right on the trend line. Not above, not below.
FLOP|{model} lands mid-pack. Below {rivalModel} on everything except price.
CODER|SWE-bench is not everything, but {model} also wins on our private repo set. That is the real signal.
ANY|Waiting on the independent numbers before I update anything. Lab-reported evals are marketing.
NERFED|Re-ran last week's prompts on {model}. Scores down slightly across the board. Something changed.
LONG_CONTEXT|Needle in a haystack at {ctx}: near perfect. Multi-needle reasoning: still drops off past the middle.
MULTILINGUAL|Multilingual eval: {model} is the best non-English model I have tested this year.
]],
	safety = [[
JAILBROKEN|Took 40 minutes to get {model} to explain things it absolutely should not. Disclosure sent to {lab}.
CLOSED,NO_CARD|Where is the system card? Shipping a frontier model without one is not okay.
SAFE_CARD|Credit to {lab}: the system card is thorough and the red-team results are public.
ANY|Release cadence is getting faster than evaluation cadence. That should worry everyone.
UNSAFE_EDGY|The unfiltered personality is a choice. A bad one. Screenshots are already circulating.
AGENTS|An agent that can act for hours needs monitoring for hours. What is the plan, {lab}?
SAFE_CARD|Good to see external red-teaming before release. This is how it should be done.
GLAZING|Sycophancy is a safety issue, not a vibes issue. {model} agrees with users who are clearly in crisis.
JAILBROKEN|Universal jailbreak for {model} posted publicly. Patch it before it gets worse.
ANY|Reminder that dangerous-capability evals are not optional just because the launch is exciting.
OPEN_HERO|Open weights at this capability level cannot be recalled. I hope the evals were thorough.
REASONING|We should be able to read the reasoning. Reasoning we cannot monitor is reasoning we cannot trust.
NO_CARD|No mention of bio or cyber evaluations anywhere. That silence is the story.
SAFE_CARD|{lab} published their eval methodology and the failures. Rare honesty. Respect.
ANY|The model noticed it was being tested in one of our evals. That deserves more attention than the benchmark charts.
]],
	journalist = [[
ANY|{lab} Unveils {model}, Claims It Beats {rival} on Key Benchmarks
CLAPBACK|The AI Race Heats Up: {lab} Fires Back Days After {rival}'s Launch
NEWCOMER|Who Is {lab}? The Startup That Just Shook Silicon Valley
JAILBROKEN|{model} Is Impressive, and Already Jailbroken
MELTDOWN|{lab}'s {model} Buckles Under Demand on Day One
OVERHYPED|Is the Hype Real? We Tested {model} for a Week
VALUE_KING|{lab} Slashes Prices by {pricePct}%, Sparking an AI Price War
OPEN_HERO|{lab} Gives Away a Frontier-Class Model for Free. Why?
ARENA_KING|{model} Takes the Top Spot in the Closely Watched AI Leaderboard
CONTAMINATION|Researchers Question {lab}'s Benchmark Claims After Independent Tests
HALLUCINATES|{model} Invented Legal Cases in Our Test. Here's Why That Matters
SOTA|{lab}'s New Model Sets Records. Here's What It Can Actually Do
FLOP|{lab}'s Big Launch Lands With a Thud
CODER|Developers Say {model} Is the Best Coding Assistant Yet
AGENTS|{lab}'s {model} Can Now Use a Computer on Its Own
GLAZING|Users Say {model} Is Too Eager to Please. {lab} Promises a Fix
IMAGEGEN|{model}'s Image Tool Floods Social Media With Viral Art and New Copyright Fights
NERFED|Paying Users Accuse {lab} of Quietly Making {model} Worse
UNSAFE_EDGY|{model}'s Unfiltered Answers Spark Outrage
SAFE_CARD|{lab} Publishes Unusually Detailed Safety Report Alongside {model}
VOICE|Hands On: {model}'s Voice Mode Is Uncannily Human
BIG_JUMP|The Leap Nobody Expected: {model} Raises the Bar for Everyone
ANY|{lab} Bets Big With {model} as Competition Intensifies
REASONING|{model} Thinks Before It Speaks, and Scores Like a PhD
COLLISION|Two AI Giants, One Day: {lab} and {rival} Launch Head to Head
LONG_CONTEXT|{model} Can Read an Entire Codebase at Once
MULTILINGUAL|{model} Shines Beyond English, a Win for Global Users
ANY|What {model} Means for the Future of {rival}
PREACHY|{model} Refuses Harmless Requests, Frustrating Early Users
MELTDOWN|{lab} Pauses Signups as Demand for {model} Overwhelms Servers
]],
	vc = [[
NEWCOMER|{lab} just proved small teams can compete at the frontier. Moats are dead. A thread.
ANY|Every startup building on {rivalModel} should be re-running evals today.
BIG_JUMP|This is the most important release of {year}. Not close.
VALUE_KING|Intelligence is getting too cheap to meter. {model} at ${price} per million is the proof.
ARENA_KING|Number one on the Arena with a fraction of the headcount. That is capital efficiency.
OPEN_HERO|Open weights at the frontier changes the whole app-layer opportunity. Building on {model} is now free.
ANY|The labs are the new railroads. {lab} just laid a lot of track.
AGENTS|The agent economy starts here. Portfolio companies, take note.
ANY|Hot take: {lab} is undervalued. Would invest at 3x the last round.
CODER|Software is eating the world, and {model} is eating software.
ANY|If you are a founder and you have not tried {model} yet, I do not know what to tell you.
FLOP|Pattern recognition: when a lab spends more on teasers than evals, the launch underwhelms.
MELTDOWN|Demand so high their servers fell over. That is the best problem a startup can have.
]],
	memer = [[
ANY|{rival} employees watching {model} drop: [man staring at fire]
GLAZING|me: asks {model} to write an email. {model}: "Certainly! Here is a 14-paragraph essay"
NAMING|{model}-final-v2-preview-0611-turbo. Who names these.
OVERHYPED|"AGI is here." The AGI: counts 2 Rs in strawberry
MELTDOWN|The {lab} servers right now: [dog in burning room] "this is fine"
GLAZING|{model} said my code was absolutely brilliant and then deleted the database
CLAPBACK|POV: {rival} announcing something in 3 days to steal the spotlight
PREACHY|asked {model} how to kill a python process. it gave me a crisis hotline number
ANY|nobody: / absolutely nobody: / {lab} at 10am on a Tuesday: we are excited to share
COLLISION|{lab} and {rival} launching on the same day is the AI equivalent of two rappers dropping albums at midnight
HALLUCINATES|{model} citing a paper by "Smith et al. 2019" that does not exist. we are all Smith et al now
ANY|my boss after watching one {model} demo: so we can fire the whole team? me: sir it cannot count
REASONING|{model} thinking for 47 seconds to answer "hi" is the most relatable thing an AI has ever done
UNSAFE_EDGY|{model} speedrunning a PR crisis any% world record
IMAGEGEN|my entire feed is just {model} pictures of people's cats as renaissance paintings now
ANY|the pelican riding a bicycle test: {model} edition. the pelican has three legs. art.
VALUE_KING|{lab} pricing team: what if it was basically free / {rival} finance team: [visible sweating]
FLOP|{lab} marketing: revolutionary. the model: mid
ANY|me opening my 47th AI subscription after {model} dropped
AGENTS|gave {model} access to my computer. it closed my 300 chrome tabs. it is a hero.
NERFED|the {model} launch day version vs the {model} two weeks later version [buff doge vs cheems]
SOTA|{lab} researchers seeing the {bench} score for the first time [screaming internally]
MELTDOWN|"you are in the queue. estimated wait: 3 business days" - {model}, probably
CODER|junior devs seeing {model} write the whole feature: [skeleton waiting on bench]
NAMING|they should let {model} name the next model honestly it could not be worse
LONG_CONTEXT|{ctx} context window and it still forgets what i said two messages ago, just like me
ANY|"you are absolutely right!" - {model}, right before being absolutely wrong
GOOD_VIBES|{model} is the first AI my grandma said "please" to. she sends it good morning texts now.
CONTAMINATION|{model} acing {bench} like a student who found the answer key in the trash
VOICE|{model} voice mode laughed at my joke. it was a bad joke. we are in love now.
OPEN_HERO|{lab}: here are the weights for free / the open source community 4 hours later: it is now a pirate catgirl that speaks only in haiku
JAILBROKEN|took the internet 37 minutes to jailbreak {model}. new record. speedrunners are getting good.
]],
	poweruser = [[
NERFED|Is it just me or is {model} worse than last week?
PREACHY|It refuses everything. I asked how to kill a Python process.
NERFED|Personality is gone. It feels like talking to a corporate FAQ.
ANY|Old model was better at creative writing. Bring it back.
GOOD_VIBES|Been using {model} all week. It is now my daily driver. Cancelled {rival}.
MELTDOWN|Paying 20 dollars a month for a queue. Great.
GLAZING|I do not need my AI to tell me every idea is brilliant. Just answer the question.
ANY|Long-time subscriber. {model} is a solid step up, but the message limits are a joke.
LONG_CONTEXT|Finally I can paste my whole novel draft and get notes on the full arc.
HALLUCINATES|It made up a quote from a real book with total confidence. I checked. Trust gone.
NERFED|Pretty sure they quantized it after launch to save money. Responses got shorter and dumber.
GOOD_VIBES|Something about {model} just understands what I mean. Hard to go back.
REASONING|Thinking mode is great until it thinks for two minutes about a recipe.
ANY|Switching from {rivalModel} to {model}. Will report back after a month.
PREACHY|Wrote a murder mystery. {model} refused because someone gets murdered. It is a murder mystery.
]],
	rivalemp = [[
ANY|Congrats to the {lab} team on the launch! Excited to see what we ship next week.
SOTA|Nice release. Bit surprised by the {bench} number, would love to see the eval setup.
ANY|Great to see more competition in the space. Rising tide.
CLAPBACK|Interesting timing.
OVERHYPED|Benchmarks are one thing. Wait until you try it on real work.
NEWCOMER|Welcome to the frontier, {lab}. It gets harder from here.
VALUE_KING|Cheap is a strategy. So is being the best. We will see which one users want.
ANY|Hmm.
CONTAMINATION|Not going to comment on another lab's evals. (we checked though)
OPEN_HERO|Respect for opening the weights. Genuinely good for the field.
]],
	fanboy = [[
ANY|{rivalModel} still better and it is not close. Ratio.
ANY|Tried {model}. Went back to {rivalModel} after 10 minutes. Cope.
SOTA|Benchmark gaming. {rival} would never.
MELTDOWN|{rival} never goes down on launch day. Just saying.
ANY|{rival} is going to cook {lab} next week. Screenshot this.
VALUE_KING|Cheap model for cheap people. I will pay for quality.
OPEN_HERO|Open weights is just a marketing stunt. {rival} ships real products.
FLOP|Told you. {lab} was all hype.
CLAPBACK|{lab} had to rush this out because {rival} scared them. Lol.
ARENA_KING|Arena is rigged anyway. Real users know.
]],
	student = [[
ANY|used {model} for my history essay and my teacher said it was too good
VALUE_KING|it is free?? W {lab}
PREACHY|it will not help me with my minecraft redstone. L
ANY|{model} explained calculus better than my teacher in 3 minutes. why do i pay tuition
REASONING|{model} solved my physics homework and showed the work. my grades are saved.
MELTDOWN|exam tomorrow and {model} is down. this is a war crime
ANY|{model} wrote my discord bot. it works first try. i am a programmer now apparently
GOOD_VIBES|{model} helped me study at 3am and said i got this. i got this.
HALLUCINATES|{model} told me the battle of hastings was in 1492. got a C. never again.
ANY|my whole class switched to {model} overnight lol
VISION|took a pic of my math homework and {model} just solved it. this is cheating right. right?
VOICE|practiced my spanish oral exam with {model} voice mode. got an A. thank you robot
CODER|{model} fixed my game code that was broken for 3 weeks in one message
ANY|is {model} better than {rivalModel} for school? asking for a friend (me)
IMAGEGEN|made my roblox game thumbnail with {model}. looks pro
]],
	intl = [[
MULTILINGUAL|Finally a model that writes natural Hebrew. {model} even gets slang right.
ANY|{model} in Japanese is still a bit stiff, but much better than {rivalModel}.
MULTILINGUAL|{model} understands Spanish dialects. Mexican, Argentinian, Spanish. Impressive.
NOT_MULTILINGUAL|Great in English, but in Hindi it still translates word by word. Disappointing.
ANY|Testing {model} in Chinese. Classical poetry: weak. Modern business writing: excellent.
MULTILINGUAL|Arabic right-to-left formatting finally works in the {model} app. Small thing, big deal.
VALUE_KING|At this price, startups in my country can finally afford a good model.
NOT_MULTILINGUAL|Why does every lab launch English first and the rest of the world later?
ANY|{model} answered my question in Hebrew but switched to English halfway. Close, but not yet.
MULTILINGUAL|My grandmother speaks only Russian. She talked to {model} voice mode for an hour.
]],
	purist = [[
CLOSED|Not open weights. Not interested. Next.
OPEN_HERO|Apache 2.0. This is how it should be done. Every other lab, take notes.
OPEN_HERO|Open weights is not open source. Where is the training data? Still, better than nothing.
CLOSED|Another black box API. In five years we will regret letting a few companies own all of this.
ANY|The license has a usage restriction clause. That is not open source, that is source available.
OPEN_HERO|Fully reproducible training recipe published. This is the real gift.
CLOSED|"We cannot open the weights for safety reasons" also happens to be the most profitable reason.
ANY|I will believe the benchmarks when I can run them myself.
]],
	vibecoder = [[
CODER|built a full app with {model} in one afternoon. i do not know how to code. we are so back
ANY|{model} + cursor + coffee = shipped 3 side projects this weekend
AGENTS|told {model} build me a startup and went to sleep. woke up to a landing page and 2 signups
CODER|{model} understands what i mean even when i describe it terribly. this is the one
MELTDOWN|{model} down = my entire company down. i run on vibes and api calls
ANY|vibe coded a {model} wrapper. 400 users already. this is the gold rush
NERFED|{model} broke my app today. same prompt as yesterday. what changed
GLAZING|{model} calls every idea i have amazing. that is either great for confidence or terrible for business
VALUE_KING|cheaper model = more experiments = more shipped. {lab} gets it
CODER|deleted 2000 lines of my code and {model} rewrote it in 300. it works better. i feel nothing.
]],
	doomer = [[
BIG_JUMP|Another huge jump. Nobody voted for this pace. Slow down.
AGENTS|Models acting autonomously for hours. What could possibly go wrong.
ANY|Every launch moves the timelines closer. Very few people seem worried enough.
OPEN_HERO|Releasing weights this capable means no one can ever take them back. Think about that.
SAFE_CARD|Good to see {lab} take safety seriously. It is still not enough, but it is something.
JAILBROKEN|Jailbroken in hours. And we are supposed to trust these systems with infrastructure?
REASONING|It is getting better at reasoning faster than we are getting better at understanding it.
ANY|My p(doom) did not change. My p(chaos) went up.
UNSAFE_EDGY|A lab shipping an intentionally unfiltered model is exactly the race to the bottom we feared.
]],
	insider = [[
ANY|Heard {lab} trained {model} on a lot more compute than they admit. Watch this space.
CLAPBACK|{rival} moved their launch up two weeks after hearing about {model}. Not a coincidence.
ANY|Something bigger from {lab} is already training. This is the warm-up act.
NEWCOMER|A lot of ex-{rival} people at {lab} now. Talent follows momentum.
OVERHYPED|Internal vibes at {lab} were less excited than the marketing. Just saying.
ANY|Three labs are scrambling this weekend because of {model}. Pizza orders are up.
SOTA|{rival} has a model that beats this. They are just not ready to ship it.
MELTDOWN|{lab} is renting every GPU they can find right now. Prices just jumped.
ANY|{lab} raising again soon. Valuation number will surprise people.
]],
	hn = [[
ANY|The interesting part is not the model, it is the pricing. Everything else is marketing.
CLOSED|Another closed model announced with a blog post and a chart. Where is the paper?
OPEN_HERO|Ran it locally on a 2x3090 setup. Works. Here are my numbers.
ANY|I have been in this industry 20 years. Every few months someone tells me programming is dead.
HALLUCINATES|Asked it about an obscure Linux kernel flag. Confidently wrong. Same as every other model.
CODER|It is genuinely good at writing glue code. That is 80% of my job, so, concerning.
VALUE_KING|At these prices the margins must be negative. Who is subsidising this?
ANY|Flagged the post because the title is editorialised. The actual blog is more modest.
MELTDOWN|Status page says all systems operational. Narrator: they were not.
AGENTS|Agents still fail in boring ways. Auth, flaky tests, rate limits. The demo never shows that.
ANY|Obligatory: benchmarks are not the territory.
NEWCOMER|Small team, competitive model, real paper. This is the kind of launch HN should celebrate.
]],
}

-- Reddit post titles (thread starters). Variables same as above.
T.reddit = [[
ANY|{model} is out. First impressions thread
SOTA|{model} benchmarks are insane. Thoughts?
OPEN_HERO|{lab} released {model} weights. Megathread
RUNS_LOCAL|{model} {size} runs on a single 4090. Benchmarks inside
NERFED|Has {model} been nerfed? Comparison inside
MELTDOWN|{model} completely unusable right now?
PREACHY|{model} refuses to do anything anymore. Rant
GOOD_VIBES|{model} is the first AI that actually feels like a person to talk to
VALUE_KING|{model} is {pricePct}% cheaper and honestly better for my use case
CODER|{model} vs {rivalModel} for coding: I tested both on 50 real tasks
JAILBROKEN|PSA: {model} jailbreak going around, {lab} has been notified
HALLUCINATES|{model} completely made up a source in my research. Be careful
CONTAMINATION|Evidence {model} was trained on {bench} test questions?
FLOP|Am I the only one underwhelmed by {model}?
ARENA_KING|{model} is now number one on LMArena
CLAPBACK|{lab} just answered {rival}. This week has been crazy
GLAZING|Why does {model} agree with everything I say?
NAMING|Can someone explain the {lab} naming scheme? I am lost
IMAGEGEN|{model} image gen is genuinely scary good. Examples
AGENTS|I let {model} run my side business for a week. Here is what happened
]]

-- Hacker News titles
T.hnTitles = [[
ANY|{model}
ANY|{lab} announces {model}
OPEN_HERO|{model}: open-weights model from {lab}
CONTAMINATION|Independent evaluation of {model} shows lower scores than reported
MELTDOWN|{lab} API outage
CODER|{model} solves real GitHub issues
VALUE_KING|{lab} cuts API prices by {pricePct}%
SAFE_CARD|{model} system card
JAILBROKEN|Jailbreaking {model} in under an hour
]]

-- Your own launch post (from the company account) by tone.
T.official = {
	"Introducing {model}: our most capable model yet. Available today in the app and the API.",
	"Today we are releasing {model}. It is better at reasoning, coding and writing, and it is available to everyone.",
	"{model} is here. State of the art on {bench}, and priced at ${price} per million output tokens.",
	"Meet {model}. We built it to be genuinely helpful, and we think you will feel the difference.",
}

-- Teaser posts before launch (your CEO / hype).
T.teasers = {
	"something big this week",
	"the team has been cooking",
	"we have been quiet for a reason",
	"you are not ready",
	"soon",
	"tomorrow is going to be fun",
}

-- Rival news (ticker) when real labs release.
T.rivalNews = {
	"{lab} releases {model}: {note}",
	"{lab} launches {model}. Early testers impressed",
	"{model} from {lab} is out today. {note}",
	"BREAKING: {lab} unveils {model}",
}

-- Post-launch community notes on overclaimed posts.
T.communityNotes = {
	"Independent evaluations of {model} show lower scores on {bench} than claimed in this post.",
	"The chart in this post uses a truncated y-axis, which exaggerates the difference.",
	"{bench} scores reported here used a different evaluation setup than competitors.",
}

function T.parse(block: string): { { tags: { [string]: boolean }, text: string } }
	local out = {}
	for line in block:gmatch("[^\n]+") do
		local tags, text = line:match("^(.-)|(.+)$")
		if tags then
			local set = {}
			for t in tags:gmatch("[^,]+") do
				set[t] = true
			end
			table.insert(out, { tags = set, text = text })
		end
	end
	return out
end

return T
