--!strict
-- Difficulty picker. DP.row = 5 level buttons with the description under them (new company
-- dialog). DP.ask = the one-time popup for companies made before difficulty levels existed.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS:WaitForChild("Shared")
local Difficulty = require(Shared.Difficulty)
local UI = require(script.Parent.UI)
local Net = require(script.Parent.Net)
local T = UI.T
local new = UI.new

local DP = {}

-- Row of 5 buttons under a small wrap frame. The chosen one is coloured, the rest are grey,
-- and its description shows under the row. onPick(id) runs on every change.
function DP.row(parent: Instance, initial: string?, onPick: ((string) -> ())?)
	local current = Difficulty.normalize(initial)
	local wrap = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = parent })
	UI.list(wrap, 8)
	local grid = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 52), LayoutOrder = 1, Parent = wrap })
	new("UIGridLayout", { CellSize = UDim2.new(0.2, -6, 1, 0), CellPadding = UDim2.fromOffset(6, 0), SortOrder = Enum.SortOrder.LayoutOrder, Parent = grid })
	local desc = UI.label(wrap, "", 15, T.sub)
	desc.LayoutOrder = 2

	local paint: () -> ()
	paint = function()
		UI.clear(grid)
		local lvl0 = Difficulty.get(current)
		desc.Text = lvl0.name .. ": " .. lvl0.desc
		for i, lvl in ipairs(Difficulty.list) do
			local on = lvl.id == current
			UI.button(grid, lvl.name, function()
				current = lvl.id
				paint()
				if onPick then
					onPick(current)
				end
			end, on and lvl.color or UI.GHOST, { LayoutOrder = i, TextSize = 13 })
		end
	end
	paint()
	return wrap
end

-- The one-time popup: pick a level, CONTINUE, then ARE YOU SURE? with BACK and YES.
-- On YES the server saves the choice (setDifficulty) and onDone runs.
function DP.ask(host: Instance, onDone: () -> ())
	local overlay = new("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.35, Size = UDim2.fromScale(1, 1), ZIndex = 300, Parent = host })
	local d = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(700, 330), ZIndex = 301, Parent = overlay })
	UI.fit(d)
	UI.skin(d, T.bg)
	local bar = new("Frame", { BackgroundColor3 = T.yellow, Size = UDim2.new(1, 0, 0, 60), ZIndex = 302, Parent = d })
	new("TextLabel", { Text = "PICK YOUR DIFFICULTY", FontFace = UI.HEAVY, TextSize = 24, TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = Color3.fromRGB(40, 22, 0), Size = UDim2.fromScale(1, 1), ZIndex = 303, Parent = bar })
	local body = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(28, 76), Size = UDim2.new(1, -56, 1, -96), ZIndex = 302, Parent = d })
	UI.list(body, 12)

	local current = Difficulty.DEFAULT
	local showPick: () -> ()
	local function showConfirm()
		UI.clear(body)
		local lvl = Difficulty.get(current)
		UI.label(body, "ARE YOU SURE?", 26, T.red, { FontFace = UI.HEAVY })
		UI.label(body, "You can not change this later.", 18, T.text)
		UI.label(body, "Difficulty: " .. lvl.name, 18, lvl.color, { FontFace = UI.BOLD })
		local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 64), Parent = body })
		UI.list(row, 16, true, Enum.HorizontalAlignment.Center)
		UI.button(row, "BACK", showPick, "ghost", { Size = UDim2.new(0.42, 0, 1, 0), TextSize = 18 })
		UI.button(row, "YES", function()
			local ok = Net.act("setDifficulty", current)
			if ok then
				overlay:Destroy()
				onDone()
			end
		end, T.red, { Size = UDim2.new(0.42, 0, 1, 0), TextSize = 18 })
	end
	showPick = function()
		UI.clear(body)
		UI.label(body, "Your company was made before difficulty levels existed. Choose one now.", 16, T.text)
		DP.row(body, current, function(id: string)
			current = id
		end)
		local cont = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 64), Parent = body })
		UI.button(cont, "CONTINUE", showConfirm, T.green, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(0.7, 0, 1, 0), TextSize = 20 })
	end
	showPick()
	for _, c in ipairs(overlay:GetDescendants()) do
		if c:IsA("GuiObject") then
			c.ZIndex = math.max(c.ZIndex, 302)
		end
	end
end

return DP
