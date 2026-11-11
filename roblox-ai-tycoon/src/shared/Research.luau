--!strict
-- Research tree. Research points come from researchers each day.
-- `from` = earliest real date the idea is public (you can't research o1-style RL in Jan 2023... unless you're a genius: star researchers cut the date gate by up to 6 months).
local R = {}

R.nodes = {
	{ id = "rlhf", name = "RLHF", from = "2023-01", cost = 40, algo = 1.0, desc = "Human feedback makes the model actually helpful.", tier = 1 },
	{ id = "rope", name = "RoPE scaling", from = "2023-03", cost = 50, algo = 1.05, desc = "Unlocks 128K context.", tier = 1 },
	{ id = "flash", name = "FlashAttention 2", from = "2023-07", cost = 60, algo = 1.25, desc = "Faster attention kernels. Everything trains faster.", tier = 1 },
	{ id = "dpo", name = "DPO", from = "2023-06", cost = 60, algo = 1.0, desc = "Preference tuning without a reward model.", tier = 1 },
	{ id = "cai", name = "Constitutional AI", from = "2023-01", cost = 80, algo = 1.0, req = { "rlhf" }, desc = "The model aligns itself to written principles.", tier = 2 },
	{ id = "moe", name = "Mixture of Experts", from = "2023-06", cost = 120, algo = 1.1, desc = "More capacity for the same compute.", tier = 2 },
	{ id = "synthetic", name = "Synthetic data", from = "2023-06", cost = 100, algo = 1.15, desc = "Your model writes textbook-quality training data.", tier = 2 },
	{ id = "vision", name = "Vision encoder", from = "2023-09", cost = 140, algo = 1.0, desc = "See images.", tier = 2 },
	{ id = "tools", name = "Function calling", from = "2023-06", cost = 90, algo = 1.0, desc = "Models call tools and APIs.", tier = 2 },
	{ id = "distill", name = "Distillation", from = "2023-03", cost = 110, algo = 1.0, desc = "Small students learn from big teachers.", tier = 2 },
	{ id = "longctx", name = "Million-token context", from = "2024-02", cost = 220, algo = 1.0, req = { "rope" }, desc = "Read whole codebases.", tier = 3 },
	{ id = "mla", name = "Latent attention (MLA)", from = "2024-05", cost = 200, algo = 1.1, req = { "moe" }, desc = "Tiny KV cache.", tier = 3 },
	{ id = "fp8", name = "FP8 training", from = "2024-06", cost = 220, algo = 1.0, req = { "flash" }, desc = "Almost double throughput.", tier = 3 },
	{ id = "voice", name = "Native voice", from = "2024-05", cost = 260, algo = 1.0, req = { "vision" }, desc = "Real-time speech in and out.", tier = 3 },
	{ id = "finemoe", name = "Fine-grained MoE", from = "2024-05", cost = 260, algo = 1.15, req = { "moe" }, desc = "Hundreds of tiny experts.", tier = 3 },
	{ id = "arena", name = "Arena codename tests", from = "2024-03", cost = 80, algo = 1.0, desc = "Test anonymously before launch.", tier = 3 },
	{ id = "reasoning", name = "Reasoning RL", from = "2024-09", cost = 420, algo = 1.2, req = { "rlhf", "synthetic" }, desc = "Think before you answer. The biggest leap of 2024.", tier = 4 },
	{ id = "computeruse", name = "Computer use", from = "2024-10", cost = 300, algo = 1.0, req = { "tools", "vision" }, desc = "Clicks and types like a person.", tier = 4 },
	{ id = "mtp", name = "Multi-token prediction", from = "2024-12", cost = 240, algo = 1.05, desc = "Faster decoding.", tier = 4 },
	{ id = "honesty", name = "Honesty tuning", from = "2024-06", cost = 200, algo = 1.0, req = { "cai" }, desc = "Less sycophancy, fewer hallucinations.", tier = 4 },
	{ id = "imagegen", name = "Native image generation", from = "2025-03", cost = 380, algo = 1.0, req = { "vision" }, desc = "The model draws.", tier = 4 },
	{ id = "hybrid", name = "Hybrid thinking", from = "2025-02", cost = 300, algo = 1.0, req = { "reasoning" }, desc = "User picks fast or deep.", tier = 5 },
	{ id = "agents", name = "Agent RL environments", from = "2025-02", cost = 600, algo = 1.15, req = { "reasoning", "tools" }, desc = "Hours-long autonomous tasks.", tier = 5 },
	{ id = "muon", name = "Muon optimizer", from = "2025-02", cost = 420, algo = 1.1, desc = "Better optimizer, fewer FLOPs.", tier = 5 },
	{ id = "linear", name = "Linear attention", from = "2025-01", cost = 380, algo = 1.05, desc = "Cheap long context.", tier = 5 },
	{ id = "sparseattn", name = "Sparse attention", from = "2025-09", cost = 480, algo = 1.1, req = { "mla" }, desc = "Halves long-context cost.", tier = 5 },
	{ id = "video", name = "Video understanding", from = "2025-01", cost = 420, algo = 1.0, req = { "vision" }, desc = "Watch and understand video.", tier = 5 },
	{ id = "fp4", name = "FP4 training", from = "2025-10", cost = 650, algo = 1.0, req = { "fp8" }, desc = "Blackwell-era precision.", tier = 6 },
	{ id = "megactx", name = "10M context", from = "2025-04", cost = 700, algo = 1.0, req = { "longctx", "linear" }, desc = "Infinite memory, almost.", tier = 6 },
	{ id = "diffusion", name = "Diffusion LMs", from = "2025-06", cost = 800, algo = 1.0, desc = "Generate whole blocks at once.", tier = 6 },
	{ id = "selfimprove", name = "Automated AI research", from = "2026-06", cost = 2000, algo = 1.6, req = { "agents" }, desc = "Your models do research for you. Research speed x2.", tier = 7 },
	{ id = "continual", name = "Continual learning", from = "2027-03", cost = 3000, algo = 1.4, req = { "selfimprove" }, desc = "Models learn after release. Updates are free.", tier = 7 },
	{ id = "ownchip", name = "Custom AI chip", from = "2026-01", cost = 2500, algo = 1.0, req = { "fp8" }, desc = "Design your own accelerator: 40% cheaper compute.", tier = 7 },
	{ id = "worldmodel", name = "World models", from = "2027-09", cost = 4000, algo = 1.3, req = { "video" }, desc = "Simulate reality. Robotics opens up.", tier = 8 },
	{ id = "agi", name = "Recursive self-improvement", from = "2029-01", cost = 9000, algo = 2.5, req = { "continual", "worldmodel" }, desc = "The last invention.", tier = 9 },
}

local Format = require(script.Parent:WaitForChild("Format"))
R.byId = {} :: { [string]: any }
for _, n in ipairs(R.nodes) do
	n.fromDay = Format.dayFromString(n.from)
	R.byId[n.id] = n
end

return R
