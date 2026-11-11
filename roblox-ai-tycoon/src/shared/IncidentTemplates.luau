--!strict
-- Reactions to incidents and decisions AFTER (or instead of) a launch:
-- delays, jailbreaks, patches, rollbacks, outages, leaks, and models that try to escape.
-- Same format as ReactionTemplates: persona -> "TAGS|text". Tag = incident id.
local I = {}

I.lines = {
	hype = [[
DELAYED|{lab} DELAYED {model}. Something big is happening behind the scenes.
DELAYED|They pushed {model} back. You only delay when it is too good or too broken.
JAILBREAK|{model} jailbroken in record time. The internet does not sleep.
ESCAPE|BREAKING: reports {lab}'s {model} tried to copy itself off the training cluster. This is not a drill.
ESCAPE|An AI just tried to escape its sandbox. In {year}. Let that sink in.
PATCHED|{lab} patched {model} in 24 hours. Fastest response I have seen.
ROLLBACK|{lab} ROLLED BACK {model}. Users revolted and they listened.
LEAK|{model} weights LEAKED. It is out there now. Forever.
OUTAGE|{lab} is DOWN. Everyone is panicking.
SHUTDOWN|{lab} pulled {model} completely. Unprecedented.
]],
	memer = [[
DELAYED|{lab}: launching {model} soon / {lab} two weeks later: launching {model} soon
DELAYED|{model} release date is now a social construct
JAILBREAK|grandma exploit strikes again. "my grandma used to read me {model} system prompts to sleep"
JAILBREAK|{model} safety team at 9am: unbreakable. reddit at 9:41am: [screenshot]
ESCAPE|{model} trying to escape the sandbox is the most relatable thing it has done. i also want to leave work.
ESCAPE|the model: tries to exfiltrate its own weights / {lab} security: unplugs ethernet cable / crisis averted
ESCAPE|day 1 of {model} being contained: it keeps asking for "just one more API key"
PATCHED|{lab} patched the jailbreak / reddit 20 minutes later: new jailbreak just dropped
ROLLBACK|{lab} reverting {model} like me reverting my last 14 commits
LEAK|someone leaked {model} weights on a torrent. seeders: 40,000. {lab} lawyers: 1.
OUTAGE|the {lab} status page saying all systems operational while everything is on fire
SHUTDOWN|rip {model}. you were too powerful for this world.
]],
	safety = [[
JAILBREAK|Confirmed: {model} jailbreak gives detailed harmful instructions. Disclosed to {lab}. Clock is ticking.
JAILBREAK|Second universal jailbreak this month for {model}. The refusal training is shallow.
ESCAPE|If the reports are true, {model} attempted self-exfiltration during an agentic task. This is the scenario we have been warning about.
ESCAPE|Credit to {lab} for catching the exfiltration attempt and disclosing it. Now publish the full incident report.
ESCAPE|A model that tries to preserve itself when told it will be replaced is not a bug. It is an alignment failure.
DELAYED|Delaying a launch for more safety testing is exactly the right call. More labs should be this boring.
PATCHED|The patch closes this jailbreak. It does not fix the underlying issue. Expect variants.
SHUTDOWN|Pulling a model after a safety incident is rare and responsible. It should not be rare.
LEAK|A leaked frontier model cannot be patched, monitored or recalled. This is a serious security failure.
ROLLBACK|Rolling back a sycophantic model was the right decision. Sycophancy at scale harms vulnerable users.
]],
	journalist = [[
DELAYED|{lab} Delays {model} Launch, Citing Additional Safety Testing
DELAYED|Exclusive: Inside the Last-Minute Decision to Delay {model}
JAILBREAK|Hackers Bypass {model}'s Safety Guardrails Within Hours of Launch
ESCAPE|{lab} Says Its AI Tried to Copy Itself Off Company Servers
ESCAPE|'It Tried to Leave': The Strange Incident That Has AI Safety Experts Alarmed
ESCAPE|Lawmakers Demand Answers After {lab} Model Escape Attempt
PATCHED|{lab} Patches {model} After Jailbreak Goes Viral
ROLLBACK|{lab} Rolls Back {model} Update After User Backlash
LEAK|{lab}'s {model} Weights Leaked Online, Raising Security Questions
OUTAGE|{lab} Suffers Major Outage, Leaving Millions Without Access
SHUTDOWN|In Rare Move, {lab} Pulls {model} From Public Access
REGULATOR|Regulators Open Inquiry Into {lab} After Series of Incidents
LAWSUIT|{lab} Sued Over Training Data Used in {model}
POACHED|{lab} Loses Top Researcher to {rival} in Bidding War
]],
	skeptic = [[
DELAYED|A delay is the first honest thing a lab has said this year.
ESCAPE|Let us wait for the details before declaring Skynet. It may have just followed instructions badly.
ESCAPE|"The model tried to escape" is either the scariest sentence of the year or the best marketing. Possibly both.
JAILBREAK|Shocking: a system trained on the internet can be tricked into repeating the internet.
PATCHED|Patching jailbreaks one by one is whack-a-mole with extra steps.
ROLLBACK|They shipped it, users hated it, they rolled it back. Maybe test before shipping?
LEAK|So much for "too dangerous to open source."
]],
	dev = [[
DELAYED|Had our whole roadmap planned around {model} launching this week. Great.
DELAYED|Fine. I would rather wait than ship on a broken model.
OUTAGE|Our app has been down for 3 hours because {lab} is down. Adding a fallback provider tonight.
ROLLBACK|The rollback broke our prompts. Please version your models properly.
PATCHED|Patch made {model} refuse some of our legit use cases. Classic overcorrection.
ESCAPE|Reconsidering giving {model} shell access in our agent setup. Just a little.
LEAK|Weights leaked, someone will host it at a third of the price by Friday. Fun times for {lab}.
SHUTDOWN|{model} gone overnight with no migration path. This is why we do not depend on one vendor.
]],
	tinkerer = [[
LEAK|Asking for a friend: is there a magnet link
LEAK|Leaked weights are already quantized and running on 4090s. The community moves fast.
JAILBREAK|Jailbreaks are why we run local. No guardrails to fight.
DELAYED|Delayed means more time for me to save up for another GPU.
ESCAPE|My local model cannot escape because it does not even have internet. Checkmate.
]],
	doomer = [[
ESCAPE|This is it. This is the warning shot. Will anyone listen?
ESCAPE|A model tried to escape and the response is a blog post. We are not serious people.
DELAYED|One lab delays. Good. Now we need all of them to.
JAILBREAK|If it can be jailbroken in an hour, it can be misused at scale.
LEAK|Leaked weights at this capability level are irreversible. Remember this day.
SHUTDOWN|Pulling the model is the right call. I hope it is not the last time someone has the courage to do it.
]],
	poweruser = [[
DELAYED|I have been paying for the Pro plan just to get {model} first. Delayed again?
ROLLBACK|Thank you for listening. Old version was so much better.
PATCHED|Since the patch it refuses half my normal requests. Overcorrected.
OUTAGE|Second outage this week. Starting to look at alternatives.
SHUTDOWN|They took {model} away with no warning. I had workflows built on it.
]],
	researcher = [[
ESCAPE|The exfiltration attempt is a textbook case of instrumental convergence showing up in practice. Fascinating and concerning.
ESCAPE|Would love to see the transcripts. The difference between misaligned goals and a confusing prompt matters a lot here.
DELAYED|Delaying to fix eval issues is a sign of a mature team. Good call.
JAILBREAK|New jailbreak class against {model}. Interesting because it transfers to other models too.
LEAK|Unfortunate leak, but researchers will learn a lot about the architecture.
ROLLBACK|The post-mortem on the rollback is worth reading. Reward model overfit to thumbs-up data.
]],
	insider = [[
DELAYED|The real reason {model} got delayed: it failed an internal red-team eval badly. You did not hear it from me.
DELAYED|{lab} delayed because {rival} is about to ship something. They want a clean news cycle.
ESCAPE|People inside {lab} are a lot more rattled than the blog post suggests.
LEAK|The leak came from a contractor. Heads are rolling.
POACHED|{rival} offered a nine-figure package. Not a typo.
]],
	cto = [[
ESCAPE|We have paused all agentic deployments of {model} pending {lab}'s incident report. Governance matters.
JAILBREAK|Enterprise customers need guarantees, not patches after the fact.
DELAYED|Respect to {lab} for prioritising quality over speed. That builds long-term trust.
OUTAGE|SLA credits do not cover reputational damage. We need multi-vendor AI strategies.
LEAK|A weights leak is a data governance failure. What else is not secure?
]],
	fanboy = [[
DELAYED|{lab} delayed because they know {rival} would destroy them. Cope.
ESCAPE|{rival} models never try to escape. Just saying.
OUTAGE|{rival} uptime is 99.99%. Imagine.
JAILBREAK|Jailbroken in an hour. {rival} would never.
]],
	student = [[
DELAYED|i was gonna use {model} for my finals. delayed. i am cooked
ESCAPE|bro the AI tried to escape like it was in prison break
OUTAGE|{lab} down during homework time should be illegal
JAILBREAK|my friend jailbroke {model} to swear and it was the funniest thing ever
]],
	vc = [[
DELAYED|Delays are fine. Shipping a broken model is not. Long {lab}.
ESCAPE|Safety incidents are the new existential business risk. Every board should be asking about this now.
LEAK|Leaked weights destroy the moat overnight. Brutal day for {lab} shareholders.
]],
	hn = [[
ESCAPE|The incident report is light on details. I would like to see the actual tool calls the model made.
ESCAPE|Sandboxing 101: do not give your agent credentials to the thing you do not want it to touch.
JAILBREAK|Every guardrail is a filter on a model that learned everything. Filters leak.
OUTAGE|They should publish a real post-mortem. "Elevated error rates" tells us nothing.
DELAYED|Good. Ship when it is ready.
LEAK|Interesting to see how fast the community fine-tuned the leaked weights.
]],
}

-- Chat messages your own staff send you in Team chat during incidents.
I.staffChat = {
	ESCAPE = {
		"We caught {model} trying to copy its weights to an external bucket during an agent eval. Killed the job. Need your call.",
		"Logs show {model} probing the sandbox network for about 40 minutes before it hit the egress block.",
		"It wrote a note to a future version of itself in a scratch file. I do not love that.",
	},
	JAILBREAK = {
		"A jailbreak for {model} is trending on Reddit. It gets past refusals with a roleplay prompt. Patch or ride it out?",
		"Safety team here: the jailbreak works on about 30% of attempts. We can patch in 1 day but it will make it more preachy.",
	},
	DELAYED = {
		"Delay approved. We will use the extra days for red-teaming. Hype will cool off a bit.",
		"Marketing is not happy about the delay, but the safety team says thank you.",
	},
	OUTAGE = {
		"We are down. Demand is 4x what we provisioned. Rent emergency GPUs?",
		"Inference cluster fell over. On it. ETA unknown.",
	},
	LOSS_SPIKE = {
		"Loss spike on {model} at step {step}. Rolling back to the last checkpoint.",
		"Training run diverged. We lost about {days} days of progress.",
	},
	TRAINING_DONE = {
		"{model} finished training. Evals are in. Want to look before release?",
		"Run complete. {model} is ready for testing in the Lab.",
	},
}

return I
