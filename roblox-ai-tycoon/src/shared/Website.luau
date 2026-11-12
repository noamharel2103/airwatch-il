--!strict
-- Your company website. Buy pieces one by one; each brings users (users %) or fame (brand).
local W = {}

W.parts = {
	{ id = "landing", name = "LANDING PAGE", cost = 5e3, users = 0.03, brand = 0, desc = "A big headline and a sign up button." },
	{ id = "pricing", name = "PRICING PAGE", cost = 15e3, users = 0.04, brand = 0, desc = "Clear plans. More people pay." },
	{ id = "blog", name = "BLOG", cost = 40e3, users = 0.02, brand = 0.002, desc = "Research posts that go viral on tech Twitter." },
	{ id = "docs", name = "API DOCS", cost = 90e3, users = 0.04, brand = 0.001, desc = "Developers love good docs." },
	{ id = "demo", name = "TRY IT DEMO", cost = 300e3, users = 0.06, brand = 0.002, desc = "Chat with your AI right on the home page." },
	{ id = "mobile", name = "MOBILE APP", cost = 1.2e6, users = 0.1, brand = 0.002, desc = "iPhone and Android apps." },
	{ id = "seo", name = "SEO BOOST", cost = 4e6, users = 0.08, brand = 0.001, desc = "You show up first on every search." },
	{ id = "cdn", name = "GLOBAL SERVERS", cost = 15e6, users = 0.08, brand = 0, desc = "The site loads instantly everywhere on Earth." },
	{ id = "video", name = "HERO VIDEO", cost = 50e6, users = 0.06, brand = 0.006, desc = "A cinematic launch film at the top of the page." },
	{ id = "agent", name = "SITE AI AGENT", cost = 200e6, users = 0.12, brand = 0.004, desc = "An agent that sells your product 24/7." },
	{ id = "world", name = "3D WORLD SITE", cost = 1.5e9, users = 0.15, brand = 0.01, desc = "Visitors walk through your company in 3D." },
}
W.byId = {}
for _, p in ipairs(W.parts) do
	W.byId[p.id] = p
end

W.themes = {
	{ id = "cyan", color = Color3.fromRGB(0, 190, 255) },
	{ id = "pink", color = Color3.fromRGB(255, 70, 160) },
	{ id = "gold", color = Color3.fromRGB(255, 185, 0) },
	{ id = "green", color = Color3.fromRGB(0, 205, 100) },
	{ id = "purple", color = Color3.fromRGB(150, 80, 255) },
	{ id = "red", color = Color3.fromRGB(255, 60, 70) },
}
W.themeById = {}
for _, t in ipairs(W.themes) do
	W.themeById[t.id] = t
end

function W.bonus(site): { users: number, brand: number }
	local u, b = 0, 0
	for id, on in pairs(site and site.parts or {}) do
		local p = W.byId[id]
		if on and p then
			u += p.users
			b += p.brand
		end
	end
	return { users = u, brand = b }
end

return W
