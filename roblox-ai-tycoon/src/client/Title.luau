--!strict
-- Title screen: 3 save folders, new company (name + city), continue, delete.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS:WaitForChild("Shared")
local Config = require(Shared.Config)
local Format = require(Shared.Format)
local UI = require(script.Parent.UI)
local Net = require(script.Parent.Net)
local T = UI.T
local new = UI.new

local Title = {}

function Title.show(gui: ScreenGui, onPlay: () -> ())
	local o = new("Frame", { Name = "Title", BackgroundColor3 = Color3.fromRGB(12, 14, 20), Size = UDim2.fromScale(1, 1), ZIndex = 200, Parent = gui })
	local Assets = require(RS.Shared.Assets)
	new("ImageLabel", { Name = "Bg", BackgroundTransparency = 1, Image = Assets.titleBg, ScaleType = Enum.ScaleType.Crop, Size = UDim2.fromScale(1, 1), ZIndex = 200, Parent = o })
	local function z()
		for _, d in ipairs(o:GetDescendants()) do
			if d:IsA("GuiObject") and d.Name ~= "Bg" then
				d.ZIndex = 201
			end
		end
	end
	local logo = new("TextLabel", { Text = Config.GAME_TITLE, FontFace = UI.HEAVY, TextSize = 96, TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 90), Size = UDim2.fromOffset(1000, 110), Parent = o })
	new("UIStroke", { Color = Color3.fromRGB(28, 36, 64), Thickness = 5, ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual, Parent = logo })
	logo.TextColor3 = Color3.fromRGB(255, 210, 40)
	new("TextLabel", { Text = "Build an AI lab from a laptop to the biggest company on Earth. Starts January 2023.", TextSize = 18, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 200), Size = UDim2.fromOffset(1000, 24), Parent = o })
	local row = new("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 280), Size = UDim2.fromOffset(1080, 320), Parent = o })
	UI.list(row, 30, true, Enum.HorizontalAlignment.Center)
	local status = new("TextLabel", { Text = "Loading your companies...", TextSize = 14, TextColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.25, BackgroundColor3 = Color3.fromRGB(28, 36, 64), TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 620), Size = UDim2.fromOffset(760, 30), Parent = o })
	UI.corner(status, 10)
	z()

	local function newCompanyDialog(slot)
		local d = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.55), Size = UDim2.fromOffset(820, 560), BackgroundColor3 = T.panel, Parent = o })
		UI.corner(d, 20)
		UI.pad(d, 24)
		UI.list(d, 12)
		UI.label(d, "New company", 28, T.text, { FontFace = UI.HEAVY })
		UI.label(d, "Company name", 14, T.sub)
		local box = new("TextBox", { Text = "", PlaceholderText = "e.g. Nomad AI", PlaceholderColor3 = T.dim, ClearTextOnFocus = false, BackgroundTransparency = 0, BackgroundColor3 = T.panel2, Size = UDim2.new(1, 0, 0, 44), TextSize = 18, Parent = d })
		UI.corner(box, 10)
		UI.pad(box, 0, 14)
		UI.label(d, "Where do you start?", 14, T.sub)
		local grid = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = d })
		new("UIGridLayout", { CellSize = UDim2.new(1 / 3, -8, 0, 96), CellPadding = UDim2.fromOffset(10, 10), Parent = grid })
		local chosen = Config.LOCATIONS[1].id
		local cards = {}
		for _, l in ipairs(Config.LOCATIONS) do
			local b = new("TextButton", { Text = "", BackgroundColor3 = l.id == chosen and T.accent or T.panel2, Parent = grid })
			UI.corner(b, 12)
			new("TextLabel", { Text = l.name, FontFace = UI.BOLD, TextSize = 14, Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -24, 0, 18), Parent = b })
			new("TextLabel", { Text = l.desc, TextSize = 11, TextColor3 = Color3.fromRGB(205, 210, 225), Position = UDim2.fromOffset(12, 28), Size = UDim2.new(1, -24, 0, 60), TextYAlignment = Enum.TextYAlignment.Top, Parent = b })
			cards[l.id] = b
			b.MouseButton1Click:Connect(function()
				chosen = l.id
				for id, c in pairs(cards) do
					c.BackgroundColor3 = id == chosen and T.accent or T.panel2
				end
			end)
		end
		UI.label(d, "You start with $150K and a gaming laptop. The bank will lend you a bit more.", 13, T.yellow)
		local btns = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 48), Parent = d })
		UI.list(btns, 10, true)
		UI.button(btns, "Back", function()
			d:Destroy()
		end, "ghost", { Size = UDim2.fromOffset(120, 46) })
		UI.button(btns, "Start company", function()
			status.Text = "Setting up..."
			local res = Net.slots("play", slot, box.Text, chosen)
			if res and res.ok then
				o:Destroy()
				onPlay()
			end
		end, "success", { Size = UDim2.fromOffset(300, 46), TextSize = 18 })
		z()
	end

	task.spawn(function()
		local res = Net.slots("list")
		local slots = res and res.slots or {}
		status.Text = res and (res.persistent and "Your companies save automatically." or "Saving is off in this test session (publish the game and enable Studio API access to keep saves).") or "Could not reach the server"
		for slot = 1, 3 do
			local info = slots[tostring(slot)]
			local f = new("TextButton", { Text = "", BackgroundColor3 = Color3.fromRGB(232, 205, 150), Size = UDim2.fromOffset(330, 240), Parent = row })
			UI.corner(f, 14)
			UI.stroke(f, Color3.fromRGB(28, 36, 64), 4)
			local tab = new("Frame", { BackgroundColor3 = Color3.fromRGB(232, 205, 150), Position = UDim2.fromOffset(180, -22), Size = UDim2.fromOffset(120, 30), Parent = f })
			UI.corner(tab, 10)
			local paper = new("Frame", { BackgroundColor3 = Color3.fromRGB(248, 246, 240), Position = UDim2.fromOffset(24, 70), Size = UDim2.new(1, -48, 0, 120), Parent = f })
			UI.corner(paper, 6)
			UI.pad(paper, 12, 14)
			UI.list(paper, 4)
			if info then
				new("TextLabel", { Text = info.company, FontFace = UI.HEAVY, TextSize = 24, TextColor3 = Color3.fromRGB(30, 30, 34), Size = UDim2.new(1, 0, 0, 28), Parent = paper })
				new("TextLabel", { Text = info.stage .. "  |  " .. info.date, TextSize = 13, TextColor3 = Color3.fromRGB(110, 110, 120), Size = UDim2.new(1, 0, 0, 16), Parent = paper })
				new("TextLabel", { Text = "Worth " .. Format.money(info.valuation or 0), FontFace = UI.BOLD, TextSize = 18, TextColor3 = Color3.fromRGB(40, 150, 80), Size = UDim2.new(1, 0, 0, 22), Parent = paper })
				local del = UI.button(f, "Delete", function()
					Net.slots("delete", slot)
					o:Destroy()
					Title.show(gui, onPlay)
				end, "ghost", { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -12), Size = UDim2.fromOffset(80, 28), TextSize = 12 })
			else
				new("TextLabel", { Text = "+  New company", FontFace = UI.HEAVY, TextSize = 22, TextColor3 = Color3.fromRGB(30, 30, 34), Size = UDim2.new(1, 0, 0, 28), Parent = paper })
				new("TextLabel", { Text = "Start with a laptop and $150K", TextSize = 14, TextColor3 = Color3.fromRGB(110, 110, 120), Size = UDim2.new(1, 0, 0, 18), Parent = paper })
			end
			f.MouseButton1Click:Connect(function()
				if info then
					status.Text = "Loading " .. info.company .. "..."
					local r = Net.slots("play", slot)
					if r and r.ok then
						o:Destroy()
						onPlay()
					end
				else
					newCompanyDialog(slot)
				end
			end)
		end
		z()
	end)
end

return Title
