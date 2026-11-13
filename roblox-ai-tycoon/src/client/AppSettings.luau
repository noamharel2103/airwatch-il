--!strict
-- Settings app on the computer: music, sound effects and hover sounds.
-- Same settings as the SETTINGS popup in the side bar (Extras): they are saved through the same
-- "setSettings" meta call, and the same defaults and volume rules are used.
local RS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local UI = require(script.Parent.UI)
local Extras: any = require(script.Parent.Extras)
local T = UI.T
local new = UI.new

local App: any = { id = "settings", name = "Settings", icon = "gear", color = Color3.fromRGB(120, 128, 150) }
-- set by Main: the sound module (Fx) so volume and hover changes apply at once
App.fx = nil

-- same defaults as Extras (hover sounds are off on phones)
local cfg: any = { music = true, musicVol = 0.5, sfx = true, sfxVol = 1, hover = not game:GetService("UserInputService").TouchEnabled }
local loaded = false
local liveCtx: any = nil

local function meta(action: string, arg: any?): any
	local rf = RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("Meta")
	if not rf then
		return nil
	end
	local ok, res = pcall(function()
		return (rf :: RemoteFunction):InvokeServer(action, arg)
	end)
	return ok and res or nil
end

-- push the values into the sound system (music tracks and the sound effects module)
local function applyAll()
	local music = SoundService:FindFirstChild("Music")
	if music then
		for _, s in ipairs(music:GetChildren()) do
			if s:IsA("Sound") and s.IsPlaying then
				s.Volume = cfg.music and 0.35 * cfg.musicVol or 0
			end
		end
	end
	if App.fx then
		App.fx.volume = cfg.sfx and cfg.sfxVol or 0
		App.fx.hover = cfg.hover
	end
end

local build

-- every setting goes through here: save on the server, apply to sound, keep the side bar popup in step
local function change(key: string, value: any)
	cfg[key] = value
	meta("setSettings", cfg)
	applyAll()
	-- the SETTINGS popup in the side bar keeps its own copy: Extras.setValues updates it when it exists
	if Extras.setValues then
		Extras.setValues(table.clone(cfg))
	end
	if liveCtx then
		build(liveCtx)
	end
end

local function loadSettings()
	task.spawn(function()
		local info = meta("info")
		if info and info.settings then
			for k, v in pairs(info.settings) do
				if cfg[k] ~= nil then
					cfg[k] = v
				end
			end
		end
		loaded = true
		applyAll()
		if liveCtx and liveCtx.body.Parent then
			build(liveCtx)
		end
	end)
end

build = function(ctx: any)
	UI.clear(ctx.body)
	UI.clear(ctx.tabs)
	local sc = UI.scroll(ctx.body)
	UI.list(sc, 12)
	UI.pad(sc, 0, 0, 12, 8)

	local function toggle(label: string, key: string)
		local on = cfg[key] == true
		local row = UI.card(sc)
		UI.list(row, 10)
		local line = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 64), LayoutOrder = 1, Parent = row })
		new("TextLabel", { Text = label, FontFace = UI.HEAVY, TextSize = 22, Size = UDim2.new(0.55, 0, 1, 0), Parent = line })
		UI.button(line, on and "ON" or "OFF", function()
			change(key, not on)
		end, on and T.green or T.red, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0.36, 0, 0, 56), TextSize = 20 })
	end

	local function volume(label: string, key: string)
		local v = tonumber(cfg[key]) or 0
		local row = UI.card(sc)
		UI.list(row, 10)
		new("TextLabel", { Text = label .. "   " .. math.floor(v * 100 + 0.5) .. "%", FontFace = UI.HEAVY, TextSize = 22, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = 1, Parent = row })
		local bar = UI.bar(row, v, T.accent, 14)
		bar.LayoutOrder = 2
		local grid = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 56), LayoutOrder = 3, Parent = row })
		new("UIGridLayout", { CellSize = UDim2.new(0.2, -8, 1, 0), CellPadding = UDim2.fromOffset(10, 0), SortOrder = Enum.SortOrder.LayoutOrder, Parent = grid })
		for i, pct in ipairs({ 0, 25, 50, 75, 100 }) do
			local on = math.abs(v - pct / 100) < 0.01
			UI.button(grid, pct .. "%", function()
				change(key, pct / 100)
			end, on and T.green or UI.GHOST, { LayoutOrder = i, TextSize = 18 })
		end
	end

	toggle("MUSIC", "music")
	volume("MUSIC VOLUME", "musicVol")
	toggle("SOUND EFFECTS", "sfx")
	volume("SOUND VOLUME", "sfxVol")
	toggle("HOVER SOUNDS", "hover")
end

function App.mount(ctx: any)
	liveCtx = ctx
	build(ctx)
	if not loaded then
		loadSettings()
	end
end

function App.close()
	liveCtx = nil
end

return App
