--!strict
-- Unboxing: the box shakes, pops open, and every part you bought slides out one by one.
local RS = game:GetService("ReplicatedStorage")
local Assets = require(RS:WaitForChild("Shared"):WaitForChild("Assets"))
local Format = require(RS.Shared.Format)
local UI = require(script.Parent.UI)
local T = UI.T
local new = UI.new

local Unbox = {}

function Unbox.play(host: Instance, items, onDone: (() -> ())?)
	local o = new("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.35, Size = UDim2.fromScale(1, 1), ZIndex = 60, Parent = host })
	local title = UI.label(o, "YOUR PACKAGE", 30, T.yellow, { FontFace = UI.HEAVY, TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 90), Size = UDim2.fromOffset(800, 40), ZIndex = 61 })
	-- the box
	local box = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.45), Size = UDim2.fromOffset(260, 200), BackgroundColor3 = Color3.fromRGB(196, 150, 96), ZIndex = 61, Parent = o })
	UI.corner(box, 4)
	UI.stroke(box, T.line, 5)
	local lid = new("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 0, 10), Size = UDim2.new(1, 20, 0, 40), BackgroundColor3 = Color3.fromRGB(176, 130, 80), ZIndex = 62, Parent = box })
	UI.corner(lid, 4)
	UI.stroke(lid, T.line, 5)
	new("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(0, 34, 1, 0), BackgroundColor3 = Color3.fromRGB(235, 215, 160), ZIndex = 62, Parent = box })
	-- shake
	for i = 1, 8 do
		UI.tween(box, 0.07, { Rotation = (i % 2 == 0) and 7 or -7 })
		task.wait(0.07)
	end
	box.Rotation = 0
	UI.tween(lid, 0.35, { Position = UDim2.new(0.5, 0, 0, -160), Rotation = -25 }, Enum.EasingStyle.Back)
	task.wait(0.3)
	UI.tween(box, 0.4, { Position = UDim2.fromScale(0.5, 0.82), Size = UDim2.fromOffset(200, 150) })
	lid:Destroy()
	title.Text = "UNPACKED"
	-- items
	local row = new("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.42), Size = UDim2.new(0.9, 0, 0, 230), ZIndex = 61, Parent = o })
	UI.list(row, 16, true, Enum.HorizontalAlignment.Center)
	local total = 0
	for i, it in ipairs(items) do
		if i > 6 then
			break
		end
		total += it.power
		local card = new("Frame", { Size = UDim2.fromOffset(200, 220), BackgroundColor3 = T.panel2, ZIndex = 61, Parent = row })
		UI.corner(card, 4)
		UI.stroke(card, T.line, 4)
		local sc = new("UIScale", { Scale = 0, Parent = card })
		new("ImageLabel", { BackgroundTransparency = 1, Image = Assets.icons.parts, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 12), Size = UDim2.fromOffset(100, 100), ZIndex = 62, Parent = card })
		new("TextLabel", { Text = "x" .. it.n, FontFace = UI.HEAVY, TextSize = 20, TextColor3 = T.yellow, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 112), Size = UDim2.new(1, 0, 0, 26), ZIndex = 62, Parent = card })
		new("TextLabel", { Text = it.name, FontFace = UI.FONT, TextSize = 17, TextColor3 = T.text, BackgroundTransparency = 1, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(8, 140), Size = UDim2.new(1, -16, 0, 44), ZIndex = 62, Parent = card })
		new("TextLabel", { Text = (it.kind == "buy" and "BOUGHT" or "RENTED"), FontFace = UI.BOLD, TextSize = 11, TextColor3 = it.kind == "buy" and T.green or T.accent, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(0, 190), Size = UDim2.new(1, 0, 0, 18), ZIndex = 62, Parent = card })
		UI.tween(sc, 0.35, { Scale = 1 }, Enum.EasingStyle.Back)
		task.wait(0.35)
	end
	if #items > 6 then
		UI.label(o, "+" .. (#items - 6) .. " more", 18, T.text, { TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.62, 0), Size = UDim2.fromOffset(400, 30), ZIndex = 61 })
	end
	UI.label(o, string.format("+%.1f H100s of compute", total), 22, T.green, { FontFace = UI.HEAVY, TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.66, 0), Size = UDim2.fromOffset(800, 34), ZIndex = 61 })
	local btn = UI.button(o, "INSTALL ALL", function()
		o:Destroy()
		if onDone then
			onDone()
		end
	end, T.green, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.72, 0), Size = UDim2.fromOffset(340, 60), TextSize = 20, ZIndex = 63 })
	for _, d in ipairs(btn:GetDescendants()) do
		if d:IsA("GuiObject") then
			d.ZIndex = 64
		end
	end
end

return Unbox
