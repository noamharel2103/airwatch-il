--!strict
-- Things you can buy for your room. They show up in the room and help a little.
-- speed: training rounds a bit faster (a nicer place to work). hype: looks great on stream.
-- spot: where it goes, as a fraction of the floor (x left/right, z back/front), rot in degrees.
local Decor = {}

Decor.list = {
	{ id = "plant", name = "Big plant", price = 60, speed = 1.01, spot = { -0.3, 0.3, 0 }, blurb = "Fresh air. Slightly smarter models." },
	{ id = "poster", name = "AI poster", price = 25, hype = 1, spot = { -0.49, -0.15, 90 }, wall = true, blurb = "'Attention is all you need' on the wall." },
	{ id = "lava", name = "Lava lamp", price = 40, hype = 1, spot = { -0.05, -0.3, 0 }, blurb = "Hypnotic. Good for thinking." },
	{ id = "beanbag", name = "Bean bag", price = 120, speed = 1.01, spot = { -0.02, 0.22, 20 }, blurb = "For naps between training runs." },
	{ id = "whiteboard", name = "Whiteboard", price = 150, speed = 1.02, spot = { 0.49, -0.2, -90 }, wall = true, blurb = "Draw the architecture before you build it." },
	{ id = "fridge", name = "Mini fridge", price = 250, speed = 1.02, spot = { 0.47, 0.2, -90 }, blurb = "Energy drinks always cold." },
	{ id = "monitor", name = "Second monitor", price = 280, speed = 1.03, spot = { -0.12, -0.33, 0 }, blurb = "Loss curves on one, code on the other." },
	{ id = "chair", name = "Gaming chair", price = 350, speed = 1.02, spot = { -0.2, -0.15, 180 }, blurb = "Your back says thank you." },
	{ id = "neon", name = "Neon 'AI' sign", price = 300, hype = 3, spot = { 0.49, 0.25, -90 }, wall = true, blurb = "Every startup needs one." },
	{ id = "coffee", name = "Espresso machine", price = 400, speed = 1.03, spot = { 0.0, 0.42, 180 }, blurb = "Researchers run on coffee." },
	{ id = "trophy", name = "Trophy shelf", price = 500, hype = 2, spot = { 0.49, 0.44, -90 }, wall = true, blurb = "For benchmarks you win." },
	{ id = "stream", name = "Streaming setup", price = 600, hype = 4, spot = { 0.18, 0.05, 0 }, blurb = "Ring light and a mic. Go live." },
	{ id = "sofa", name = "Sofa", price = 900, speed = 1.02, spot = { -0.25, 0.42, 180 }, blurb = "Where the best ideas happen." },
	{ id = "fish", name = "Aquarium", price = 1200, speed = 1.02, hype = 1, spot = { 0.05, -0.46, 0 }, blurb = "Calm fish, calm engineers." },
	{ id = "treadmill", name = "Treadmill desk", price = 1400, speed = 1.03, spot = { 0.38, 0.25, -90 }, blurb = "Walk while the model trains." },
	{ id = "drone", name = "Drone on display", price = 1500, hype = 2, spot = { -0.12, 0.3, 0 }, blurb = "It doesn't do anything. It looks amazing." },
	{ id = "arcade", name = "Arcade machine", price = 2500, hype = 4, spot = { -0.46, 0.3, 90 }, blurb = "Team morale, maxed." },
	{ id = "robot", name = "Robot dog", price = 6000, hype = 5, spot = { 0.05, 0.2, 30 }, blurb = "Walks around. Visitors lose their minds." },
}

Decor.byId = {}
for _, d in ipairs(Decor.list) do
	Decor.byId[d.id] = d
end

function Decor.speed(owned): number
	local s = 1
	for id in pairs(owned or {}) do
		local d = Decor.byId[id]
		if d and d.speed then
			s *= d.speed
		end
	end
	return s
end

return Decor
